-- gtex62-doctor Conky Theme

----------------------------------------------------------------
-- Shared Theme Core
----------------------------------------------------------------
local theme = {}
local HOME = os.getenv("HOME") or ""
local CORE_DIR = os.getenv("GTEX62_CORE_DIR")
    or os.getenv("GTEX62_CONKY_ENGINE_DIR")
    or (HOME .. "/.config/conky/gtex62-core")
local SUITE_DIR = os.getenv("CONKY_SUITE_DIR") or (HOME .. "/.config/conky/gtex62-doctor")
local palette_catalog = dofile(SUITE_DIR .. "/theme/palettes.lua")

local function load_engine_runtime()
  local ok, runtime = pcall(dofile, CORE_DIR .. "/lua/runtime/window.lua")
  if ok and type(runtime) == "table" then
    return runtime
  end
  return nil
end

local engine_runtime = load_engine_runtime()

-- Monitor selection (0 = primary, 1 = secondary). Provisional — pending final
-- size/placement confirmation once Doctor is actually laid out on-screen.
theme.monitor_head = 0

-- Palette (own catalog — env override mirrors OSA's CONKY_OSA_PALETTE pattern)
theme.default_palette = palette_catalog.default or "amber"
theme.active_palette = os.getenv("CONKY_DOCTOR_PALETTE") or theme.default_palette
theme.palettes = palette_catalog.palettes or {}

theme.palette = theme.palettes[theme.active_palette] or theme.palettes[theme.default_palette]
theme.resolved_palette = theme.palette == theme.palettes[theme.active_palette]
    and theme.active_palette
    or theme.default_palette

theme.colors = {
  bg = theme.palette.bg,
  fg = theme.palette.fg,
  ink = theme.palette.ink,
}

theme.roles = {
  background = theme.colors.bg,
  foreground = theme.colors.fg,
  fill = theme.colors.fg,
  inverse_text = theme.colors.ink,
}

theme.strokes = {
  line = 1,
  frame = 8,
  frame_alpha = 0.99,
}

----------------------------------------------------------------
-- Theme FX
----------------------------------------------------------------
theme.frame_shadow = {
  enabled = true,
  color = { 0.0, 0.0, 0.0 },
  alpha_scale = 1.25,
  sides = { 1, 1, 1, 1 },                -- top, right, bottom, left
  side_alpha = { 1.0, 0.45, 0.45, 1.0 }, -- top, right, bottom, left
  bands = {
    { offset = 8.0,  width = 8.0, alpha = 0.40 },
    { offset = 10.0, width = 8.0, alpha = 0.30 },
    { offset = 12.0, width = 8.0, alpha = 0.20 },
    { offset = 16.0, width = 8.0, alpha = 0.10 },
  },
}

theme.frame_lights = {
  enabled = "auto",
  auto_bg_threshold = 0.70,
  color_mode = "auto",
  color_lift = 0.16,
  color_warmth = { 0.06, 0.03, 0.00 },
  radius_scale = 1.0,
  radius_y_scale = 1.0,
  alpha_scale = 1.0,
  top_frame_y_offset = 18,
  -- 3 fixtures at OSA's/SitRep's 290px gap, sized for Doctor's 1080px frame
  -- (SitRep: 2 across 752px; OSA: 6 across ~1730px). Each fixture reuses
  -- OSA's exact 6-layer glow stack below unchanged (same lit-panel
  -- look/identity across suites), only the count differs.
  light_count = 3,
  light_gap = 290,
  lights = {
    {
      x = "center",
      y = 10,
      radius = 11.451,
      radius_y = 6.972,
      color = { 1.0, 0.90, 0.90 },
      alpha = 0.7,
    },
    {
      x = "center",
      y = 22,
      radius = 22.37,
      radius_y = 7.465,
      color = { 1.0, 0.89, 0.86 },
      alpha = 0.12,
    },
    {
      x = "center",
      y = 24,
      radius = 20.248,
      radius_y = 9.704,
      color = { 1.0, 0.88, 0.82 },
      alpha = 0.22,
    },
    {
      x = "center",
      y = 26,
      radius = 28.087,
      radius_y = 12.69,
      color = { 1.0, 0.86, 0.78 },
      alpha = 0.20,
    },
    {
      x = "center",
      y = 28,
      radius = 39.192,
      radius_y = 16.423,
      color = { 1.0, 0.84, 0.74 },
      alpha = 0.16,
    },
    {
      x = "center",
      y = "top_frame",
      radius = 53.561,
      radius_y = 30.902,
      color = { 1.0, 0.82, 0.70 },
      alpha = 0.3,
    },
  },
}

----------------------------------------------------------------
-- Fonts
----------------------------------------------------------------
theme.fonts = {
  title = "Eurostile LT Std",
  data = "GTex62 OSA",
}

theme.text = {
  panel_title_pt = 21,
  body_pt = 18,
  body_sm_pt = 16,
  body_xs_pt = 14,
  micro_pt = 12,
}

theme.spacing = {
  grid = 8,
  title_pad_x = 32,
  title_clearance = 8,
  box_title_x = 20,
}

----------------------------------------------------------------
-- DOC header line
----------------------------------------------------------------
-- One-line fast check under the DOC title ("NO HEALTH ALERTS" /
-- "CHECK ACTIONS (N)") with the local date/time right-aligned. Offsets are
-- from the DOC panel's own x/y; y is the text's vertical center.
theme.header_line = {
  x = 32,
  y = 32,
  right_pad = 32,
  font_pt = 18,
}

----------------------------------------------------------------
-- DCM Section
----------------------------------------------------------------
-- DCM box (Digital Core Monitor). Coordinates relative to the dcm box.
-- Idle: vertical gauges, TTL printed on top, domain code below, marker
-- position = AGE against that TTL. Active: full takeover by QRH-style
-- entries (domain bar, condition, action line, PROC line).
theme.dcm = {
  idle = {
    label_y = 24,      -- TTL label, vertical center
    line_top = 40,
    line_bottom = 128, -- 88px travel, whole 8px multiple
    code_y = 144,      -- domain code, vertical center
    cap_w = 8,
    marker = 8,
    font_pt = 14,
    snap = 4, -- gauge x snapped to 4px (a whole device pixel at scale 1.25)
  },
  active = {
    content_x = 16,
    first_y = 16,
    bar_h = 16,
    line_h = 16,
    entry_gap = 8,
    text_x_pad = 8,
    font_pt = 14,
    -- More entries than fit: the list scrolls one whole entry block every
    -- scroll_interval_sec, wrapping (same mechanism as SitRep's alert banner).
    scroll_interval_sec = 5,
    bottom_pad = 8,
    proc_prefix = "PROC: ",
  },
}

----------------------------------------------------------------
-- RUNTIME Section
----------------------------------------------------------------
-- RUNTIME box: a ROOT / DIRECTORY table of the six roots. Coordinates are
-- relative to the runtime box (panels.lua's boxes.runtime). Row labels are
-- centered under ROOT, paths left-aligned under DIRECTORY.
theme.runtime = {
  content_x = 16,
  content_y = 16,
  header_h = 16,
  header_font_pt = 16,
  row_gap = 2,
  row_h = 16,
  row_font_pt = 14,
  root_w = 72,
  col_gap = 8,
  path_x_pad = 4,
}

----------------------------------------------------------------
-- CONFIG Section
----------------------------------------------------------------
-- CONFIG box: a COMPONENTS / DATA table of five config fields (time zone,
-- lat, lon, the two API keys). Coordinates relative to the config box.
theme.config = {
  content_x = 16,
  content_y = 16,
  header_h = 16,
  header_font_pt = 16,
  row_gap = 2,
  row_h = 16,
  row_font_pt = 14,
  label_w = 112,
  value_w = 184,
  col_gap = 8,
}

----------------------------------------------------------------
-- PROVIDERS Section
----------------------------------------------------------------
-- PROVIDERS box: DOMAIN | STATE | TTL | AGE | NOTE grid, one row per domain
-- plus `reserved_rows` blank rows (the AirGradient row — see
-- doctor-design.md, Panel growth rule), then the shared footer pointer.
-- col_widths sum to the box's 448px content width. Coordinates relative to
-- the providers box.
theme.providers = {
  content_x = 16,
  content_y = 16,
  header_h = 16,
  header_font_pt = 16,
  header_gap = 2,
  row_h = 20,
  row_font_pt = 14,
  col_widths = { 88, 88, 88, 96, 88 },
  reserved_rows = 1,
  footer = {
    y = 492,
    font_pt = 12,
    -- The data font has no "§" glyph, so the heading pointer uses "//".
    text = "TO ENABLE PROVIDERS, SEE README // PROVIDER TOGGLES",
  },
}

----------------------------------------------------------------
-- Footer
----------------------------------------------------------------
-- Chassis-level version-identity line, centered near the bottom of the
-- outer frame (not tied to any panel). Text itself is built live by
-- version_identity_label() in lua/ui/frame.lua from core.toml/suite.toml;
-- this table only holds sizing/placement.
theme.footer = {
  bottom_inset = 30, -- label center 18px below the DOC panel's bottom edge, mid-gutter (same as SitRep's footer)
  font_pt = 10,
}

-- Per-box content sections (DCM, RUNTIME, CONFIG, PROVIDERS tables) get
-- their own theme.<box> tables here as each box's content is designed.

function theme.session_text_scale()
  if engine_runtime and engine_runtime.session_text_scale then
    return engine_runtime.session_text_scale()
  end
  return 1.0
end

function theme.window_size(frame)
  if engine_runtime and engine_runtime.window_size then
    return engine_runtime.window_size(frame)
  end
  frame = frame or {}
  local scale = theme.session_text_scale()
  return {
    width = math.floor(((frame.width or 900) / scale) + 0.5),
    height = math.floor(((frame.height or 1200) / scale) + 0.5),
  }
end

function theme.core_dir()
  return CORE_DIR
end

function theme.engine_dir()
  return CORE_DIR
end

function theme.using_engine_runtime()
  return engine_runtime ~= nil
end

return theme
