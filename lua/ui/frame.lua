---@diagnostic disable: undefined-global
-- Chassis drawing (background, frame shadow/lights FX, panel box + title)
-- plus the DOC header line and the DCM, RUNTIME, CONFIG and PROVIDERS box
-- content. Each box reads a ready-to-draw view model from lua/suite/doctor.lua;
-- this file only lays out what it is handed. Structural mirror of
-- gtex62-sitrep/lua/ui/frame.lua (itself a mirror of gtex62-osa's).

local M = {}
local HOME = os.getenv("HOME") or ""
local SUITE_DIR = os.getenv("CONKY_SUITE_DIR") or (HOME .. "/.config/conky/gtex62-doctor")
local RUNTIME_ROOT = os.getenv("GTEX62_CONFIG_DIR") or os.getenv("GTEX62_CONKY_CONFIG_DIR") or (HOME .. "/.config/gtex62-core")

local FOOTER_VERSION_CACHE = {
  tick = nil,
  label = nil,
}

local function read_file(path)
  local f = io.open(path, "r")
  if not f then return nil end
  local s = f:read("*a")
  f:close()
  return s
end

-- Reads a single top-level `key = value` out of a TOML file (no section
-- handling needed here — version = "..." lives above any [section] in
-- both core.toml and suite.toml). Mirrors gtex62-osa/lua/ui/frame.lua's
-- simple_toml_value().
local function simple_toml_value(path, key)
  local s = read_file(path)
  if not s then return nil end

  for line in s:gmatch("[^\r\n]+") do
    line = line:gsub("#.*$", ""):gsub("^%s+", ""):gsub("%s+$", "")
    local parsed_key, value = line:match("^([%w_%-]+)%s*=%s*(.+)$")
    if parsed_key == key then
      return value:gsub('^"', ""):gsub('"$', "")
    end
  end

  return nil
end

-- Builds the chassis footer's version-identity string from the real
-- CORE and DOC versions, cached per-tick (os.time()) since draw_chassis_footer
-- runs every conky refresh. CORE comes from the deployed runtime's
-- core.toml (RUNTIME_ROOT), not this repo — gtex62-core has no in-repo
-- version file, only the runtime copy written by
-- gtex62-core-bootstrap-runtime. DOC comes from this repo's own
-- suite.toml. Mirrors gtex62-osa/lua/ui/frame.lua's version_identity_label().
local function version_identity_label()
  local tick = os.time()
  if FOOTER_VERSION_CACHE.tick == tick and FOOTER_VERSION_CACHE.label then
    return FOOTER_VERSION_CACHE.label
  end

  local core_version = simple_toml_value(RUNTIME_ROOT .. "/core.toml", "version")
    or simple_toml_value(RUNTIME_ROOT .. "/engine.toml", "version")
    or "UNKNOWN"
  local suite_version = simple_toml_value(SUITE_DIR .. "/suite.toml", "version")
    or simple_toml_value(RUNTIME_ROOT .. "/suites/doctor.toml", "version")
    or "UNKNOWN"

  FOOTER_VERSION_CACHE.tick = tick
  FOOTER_VERSION_CACHE.label = string.format(
    "CORE %s // DOC %s",
    string.upper(core_version),
    string.upper(suite_version)
  )

  return FOOTER_VERSION_CACHE.label
end

local function set_rgb(cr, color)
  cairo_set_source_rgb(cr, color[1], color[2], color[3])
end

local function set_rgba(cr, color, alpha)
  cairo_set_source_rgba(cr, color[1], color[2], color[3], alpha)
end

local function draw_rect(cr, x, y, w, h, line_width, color)
  cairo_set_line_width(cr, line_width)
  set_rgb(cr, color)
  cairo_rectangle(cr, x + 0.5, y + 0.5, w - 1, h - 1)
  cairo_stroke(cr)
end

local function fill_rect(cr, x, y, w, h, color)
  set_rgb(cr, color)
  cairo_rectangle(cr, x, y, w, h)
  cairo_fill(cr)
end

-- Same "-TITLE-" text-metrics convention as draw_inline_title, but plain
-- (no bg cutout) and centered on (x, y) — used for table cell content.
local function draw_text_center_mid(cr, x, y, text, font_face, font_pt, color, weight)
  if not text or text == "" then return end
  set_rgb(cr, color)
  cairo_select_font_face(cr, font_face, CAIRO_FONT_SLANT_NORMAL, weight or CAIRO_FONT_WEIGHT_NORMAL)
  cairo_set_font_size(cr, font_pt)
  local ext = cairo_text_extents_t:create()
  cairo_text_extents(cr, text, ext)
  cairo_move_to(cr, x - (ext.width / 2 + ext.x_bearing), y + (ext.height / 2))
  cairo_show_text(cr, text)
end

local function draw_vline(cr, x, y0, y1, line_width, color)
  cairo_set_line_width(cr, line_width)
  set_rgb(cr, color)
  cairo_move_to(cr, x + 0.5, y0)
  cairo_line_to(cr, x + 0.5, y1)
  cairo_stroke(cr)
end

local function draw_hline(cr, x0, x1, y, line_width, color)
  cairo_set_line_width(cr, line_width)
  set_rgb(cr, color)
  cairo_move_to(cr, x0, y + 0.5)
  cairo_line_to(cr, x1, y + 0.5)
  cairo_stroke(cr)
end

-- Vertically-centered-on-y left-aligned text — same text-metrics
-- convention as draw_text_center_mid, anchored left instead of center.
local function draw_text_left_mid(cr, x, y, text, font_face, font_pt, color, weight)
  if not text or text == "" then return end
  set_rgb(cr, color)
  cairo_select_font_face(cr, font_face, CAIRO_FONT_SLANT_NORMAL, weight or CAIRO_FONT_WEIGHT_NORMAL)
  cairo_set_font_size(cr, font_pt)
  local ext = cairo_text_extents_t:create()
  cairo_text_extents(cr, text, ext)
  cairo_move_to(cr, x, y + (ext.height / 2))
  cairo_show_text(cr, text)
end

-- Vertically-centered-on-y right-aligned text.
local function draw_text_right_mid(cr, x, y, text, font_face, font_pt, color, weight)
  if not text or text == "" then return end
  set_rgb(cr, color)
  cairo_select_font_face(cr, font_face, CAIRO_FONT_SLANT_NORMAL, weight or CAIRO_FONT_WEIGHT_NORMAL)
  cairo_set_font_size(cr, font_pt)
  local ext = cairo_text_extents_t:create()
  cairo_text_extents(cr, text, ext)
  cairo_move_to(cr, x - (ext.width + ext.x_bearing), y + (ext.height / 2))
  cairo_show_text(cr, text)
end

-- Rendered width of `text`, for fitting text into a cell.
local function text_width(cr, text, font_face, font_pt)
  cairo_select_font_face(cr, font_face, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
  cairo_set_font_size(cr, font_pt)
  local ext = cairo_text_extents_t:create()
  cairo_text_extents(cr, text, ext)
  return ext.x_advance
end

-- Trims `text` from the end (with "..") until it fits `max_w`.
local function fit_text(cr, text, font_face, font_pt, max_w)
  if not text or text == "" or text_width(cr, text, font_face, font_pt) <= max_w then return text end
  local s = text
  while #s > 1 do
    s = s:sub(1, -2)
    if text_width(cr, s .. "..", font_face, font_pt) <= max_w then return s .. ".." end
  end
  return s
end

-- Filled table-cell header: fg-filled rect with the label centered in
-- ink color — same look as OSA's meter/table headers.
local function draw_table_header(cr, x, y, w, h, label, font_pt, theme)
  fill_rect(cr, x, y, w, h, theme.colors.fg)
  draw_text_center_mid(cr, x + (w / 2), y + (h / 2), label, theme.fonts.data, font_pt, theme.colors.ink,
    CAIRO_FONT_WEIGHT_NORMAL)
end

-- Even-odd-fill hollow rectangle, exact stroke width regardless of line
-- position (unlike draw_rect's centered cairo_stroke). Used for the outer
-- chassis border, same technique as OSA's frame.lua.
local function draw_frame_rect(cr, x, y, w, h, line_width, color, alpha)
  local stroke = tonumber(line_width) or 1
  local inner_w = math.max(0, w - (stroke * 2))
  local inner_h = math.max(0, h - (stroke * 2))
  set_rgba(cr, color, tonumber(alpha) or 1.0)
  cairo_save(cr)
  cairo_new_path(cr)
  cairo_rectangle(cr, x, y, w, h)
  cairo_rectangle(cr, x + stroke, y + stroke, inner_w, inner_h)
  cairo_set_fill_rule(cr, CAIRO_FILL_RULE_EVEN_ODD)
  cairo_fill(cr)
  cairo_restore(cr)
end

local function resolve_scale(layout)
  local mode = layout and layout.scale_mode or "manual"
  if mode == "auto" then
    local w = tonumber(os.getenv("CONKY_SCREEN_W"))
    local h = tonumber(os.getenv("CONKY_SCREEN_H"))
    local bw = layout.frame and tonumber(layout.frame.width)
    local bh = layout.frame and tonumber(layout.frame.height)
    if w and h and bw and bh and bw > 0 and bh > 0 then
      return math.min(w / bw, h / bh)
    end
  end
  return tonumber(layout and layout.scale) or 1.0
end

local function panel_col_x(panel, layout)
  local cols = layout and layout.columns
  local col = panel and panel.column
  if col and cols and cols[col] then
    return tonumber(cols[col].x) or (tonumber(panel.x) or 0)
  end
  return tonumber(panel.x) or 0
end

local function resolve_panels(panels_tbl, layout)
  local resolved = {}
  for name, panel in pairs(panels_tbl) do
    if type(panel) == "table" then
      local rp = {}
      for k, v in pairs(panel) do rp[k] = v end
      rp.x = panel_col_x(panel, layout)
      resolved[name] = rp
    else
      resolved[name] = panel
    end
  end
  return resolved
end

local function clamp01(value)
  return math.max(0, math.min(1, tonumber(value) or 0))
end

local function color_luma(color)
  color = color or { 0, 0, 0 }
  return ((tonumber(color[1]) or 0) * 0.2126)
      + ((tonumber(color[2]) or 0) * 0.7152)
      + ((tonumber(color[3]) or 0) * 0.0722)
end

local function draw_soft_circle(cr, cx, cy, radius_x, radius_y, color, alpha)
  alpha = tonumber(alpha) or 1.0
  radius_y = tonumber(radius_y) or radius_x

  if cairo_pattern_create_radial and cairo_pattern_add_color_stop_rgba and cairo_set_source and cairo_pattern_destroy then
    local pattern = cairo_pattern_create_radial(cx, cy, 0, cx, cy, radius_x)
    cairo_pattern_add_color_stop_rgba(pattern, 0.00, color[1], color[2], color[3], alpha)
    cairo_pattern_add_color_stop_rgba(pattern, 0.68, color[1], color[2], color[3], alpha * 0.82)
    cairo_pattern_add_color_stop_rgba(pattern, 1.00, color[1], color[2], color[3], alpha * 0.20)
    cairo_save(cr)
    cairo_translate(cr, cx, cy)
    cairo_scale(cr, 1, radius_y / radius_x)
    cairo_translate(cr, -cx, -cy)
    cairo_set_source(cr, pattern)
    cairo_arc(cr, cx, cy, radius_x, 0, 2 * math.pi)
    cairo_fill(cr)
    cairo_restore(cr)
    cairo_pattern_destroy(pattern)
    return
  end

  cairo_save(cr)
  cairo_translate(cr, cx, cy)
  cairo_scale(cr, 1, radius_y / radius_x)
  cairo_translate(cr, -cx, -cy)
  set_rgba(cr, color, alpha)
  cairo_arc(cr, cx, cy, radius_x, 0, 2 * math.pi)
  cairo_fill(cr)
  cairo_restore(cr)
end

local function frame_lights_enabled(cfg, theme)
  local enabled = cfg.enabled
  if enabled == nil or enabled == true or enabled == "on" or enabled == "true" then
    return true
  end
  if enabled == false or enabled == "off" or enabled == "false" then
    return false
  end

  local threshold = tonumber(cfg.auto_bg_threshold) or 0.70
  return color_luma(theme.colors and theme.colors.bg) >= threshold
end

local function frame_light_color(cfg, theme, fallback)
  if cfg.color_mode ~= "auto" then
    return fallback
  end

  local bg = (theme.colors and theme.colors.bg) or { 0, 0, 0 }
  local lift = tonumber(cfg.color_lift) or 0
  local warmth = cfg.color_warmth or {}
  return {
    clamp01((bg[1] or 0) + lift + (tonumber(warmth[1]) or 0)),
    clamp01((bg[2] or 0) + lift + (tonumber(warmth[2]) or 0)),
    clamp01((bg[3] or 0) + lift + (tonumber(warmth[3]) or 0)),
  }
end

local function draw_frame_lights(cr, frame, theme)
  local cfg = theme.frame_lights or {}
  if not frame_lights_enabled(cfg, theme) then
    return
  end

  local lights = cfg.lights or {}
  if #lights == 0 then
    return
  end

  local stroke = tonumber(theme.strokes and (theme.strokes.frame or theme.strokes.line)) or 1
  local top_frame_y_offset = tonumber(cfg.top_frame_y_offset) or 0
  local light_count = math.max(1, math.floor(tonumber(cfg.light_count) or 1))
  local light_gap = tonumber(cfg.light_gap) or 0
  local radius_scale = tonumber(cfg.radius_scale) or 1
  local radius_y_scale = tonumber(cfg.radius_y_scale) or 1
  local alpha_scale = tonumber(cfg.alpha_scale) or 1
  local row_center_x = frame.x + (frame.width / 2)

  cairo_save(cr)
  cairo_rectangle(cr, frame.x + stroke, frame.y + stroke, math.max(0, frame.width - (stroke * 2)),
    math.max(0, frame.height - (stroke * 2)))
  cairo_clip(cr)

  for _, light in ipairs(lights) do
    local radius = (tonumber(light.radius) or 20) * radius_scale
    local radius_y = (tonumber(light.radius_y) or radius) * radius_y_scale
    local alpha = clamp01((tonumber(light.alpha) or 1) * alpha_scale)
    local color = frame_light_color(cfg, theme, light.color or { 1.0, 0.72, 0.28 })
    local cy = light.y == "top_frame" and (frame.y + stroke + top_frame_y_offset) or
    (frame.y + (tonumber(light.y) or stroke))
    if light.x == "center" then
      for light_index = 1, light_count do
        local cx = row_center_x + ((light_index - ((light_count + 1) / 2)) * light_gap)
        draw_soft_circle(cr, cx, cy, radius, radius_y, color, alpha)
      end
    else
      local cx = frame.x + (tonumber(light.x) or 0)
      draw_soft_circle(cr, cx, cy, radius, radius_y, color, alpha)
    end
  end

  cairo_restore(cr)
end

local function side_enabled(sides, index)
  if type(sides) ~= "table" or sides[index] == nil then
    return true
  end
  return sides[index] == true or sides[index] == 1 or sides[index] == "1" or sides[index] == "on" or
  sides[index] == "true"
end

local function side_alpha(side_alpha_values, index)
  if type(side_alpha_values) ~= "table" or side_alpha_values[index] == nil then
    return 1.0
  end
  return clamp01(side_alpha_values[index])
end

local function draw_frame_shadow(cr, frame, theme)
  local cfg = theme.frame_shadow or {}
  if cfg.enabled == false then
    return
  end

  local color = cfg.color or { 0.0, 0.0, 0.0 }
  local alpha_scale = tonumber(cfg.alpha_scale) or 1
  local sides = cfg.sides or {}
  local side_alpha_values = cfg.side_alpha or {}
  local bands = cfg.bands or {}
  if #bands == 0 then
    return
  end

  local x = frame.x
  local y = frame.y
  local w = frame.width
  local h = frame.height
  local draw_top = side_enabled(sides, 1)
  local draw_right = side_enabled(sides, 2)
  local draw_bottom = side_enabled(sides, 3)
  local draw_left = side_enabled(sides, 4)
  local top_alpha = side_alpha(side_alpha_values, 1)
  local right_alpha = side_alpha(side_alpha_values, 2)
  local bottom_alpha = side_alpha(side_alpha_values, 3)
  local left_alpha = side_alpha(side_alpha_values, 4)

  if not (draw_top or draw_right or draw_bottom or draw_left) then
    return
  end

  cairo_save(cr)
  cairo_rectangle(cr, x, y, w, h)
  cairo_clip(cr)

  for _, band in ipairs(bands) do
    local offset = tonumber(band.offset) or 0
    local width = tonumber(band.width) or 1
    local alpha = clamp01((tonumber(band.alpha) or 0) * alpha_scale)
    if width > 0 and alpha > 0 then
      local outer = math.max(0, offset - (width / 2))
      local inner = math.max(outer, offset + (width / 2))
      local outer_w = math.max(0, w - (outer * 2))
      local outer_h = math.max(0, h - (outer * 2))
      local thickness = math.max(0, inner - outer)
      local vertical_y = y + outer + (draw_top and thickness or 0)
      local vertical_h = math.max(0, outer_h - (draw_top and thickness or 0) - (draw_bottom and thickness or 0))

      if draw_top then
        set_rgba(cr, color, alpha * top_alpha)
        cairo_new_path(cr)
        cairo_rectangle(cr, x + outer, y + outer, outer_w, thickness)
        cairo_fill(cr)
      end
      if draw_bottom then
        set_rgba(cr, color, alpha * bottom_alpha)
        cairo_new_path(cr)
        cairo_rectangle(cr, x + outer, y + h - inner, outer_w, thickness)
        cairo_fill(cr)
      end
      if draw_left then
        set_rgba(cr, color, alpha * left_alpha)
        cairo_new_path(cr)
        cairo_rectangle(cr, x + outer, vertical_y, thickness, vertical_h)
        cairo_fill(cr)
      end
      if draw_right then
        set_rgba(cr, color, alpha * right_alpha)
        cairo_new_path(cr)
        cairo_rectangle(cr, x + w - inner, vertical_y, thickness, vertical_h)
        cairo_fill(cr)
      end
    end
  end

  cairo_restore(cr)
end

-- Masks the border stroke behind (x,y) with a bg-colored patch and draws
-- `title` inline on top of it, same "-TITLE-" cutout convention for both
-- panel titles and box titles — only the font size and x/y anchor differ.
local function draw_inline_title(cr, x, y, title, theme, font_pt)
  if not title or title == "" then return end

  local title_font = theme.fonts.title
  local clearance = theme.spacing.title_clearance

  cairo_select_font_face(cr, title_font, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_BOLD)
  cairo_set_font_size(cr, font_pt)

  local ext = cairo_text_extents_t:create()
  cairo_text_extents(cr, title, ext)

  set_rgb(cr, theme.colors.bg)
  cairo_rectangle(cr, x - clearance, y - (font_pt * 0.55), ext.width + clearance * 2, font_pt + clearance)
  cairo_fill(cr)

  set_rgb(cr, theme.colors.fg)
  cairo_move_to(cr, x, y + (font_pt * 0.35))
  cairo_show_text(cr, title)
end

local function draw_panel_title(cr, panel, theme)
  local pad_x = theme.spacing.title_pad_x
  draw_inline_title(cr, panel.x + pad_x, panel.y, panel.title, theme, theme.text.panel_title_pt)
end

-- Box border + inline title only — no data/table content. A box with
-- `border = false` (e.g. the header block, which has no border of its own
-- in the previz) skips the rectangle; a box with no `title` skips the label.
local function draw_panel_boxes(cr, panel, theme)
  local boxes = panel.boxes
  if type(boxes) ~= "table" then return end

  local pad_x = theme.spacing.box_title_x or theme.spacing.title_pad_x

  for _, box in pairs(boxes) do
    local box_x = panel.x + box.x
    local box_y = panel.y + box.y
    if box.border ~= false then
      draw_rect(cr, box_x, box_y, box.width, box.height, theme.strokes.line, theme.colors.fg)
    end
    draw_inline_title(cr, box_x + pad_x, box_y, box.title, theme, theme.text.body_sm_pt)
  end
end

-- Runs a suite-module view-model function; nil when it errors or returns
-- a non-table, so a data problem blanks one box instead of the widget.
local function panel_data(mod, fn_name)
  if not mod or type(mod[fn_name]) ~= "function" then return nil end
  local ok, data = pcall(mod[fn_name])
  if ok and type(data) == "table" then return data end
  return nil
end

-- DOC header line: the summary check on the left, local date/time on the
-- right, both centered on cfg.y below the panel title.
local function draw_header_line(cr, panel, theme, widgets)
  local doctor = widgets and widgets.doctor
  if not doctor then return end
  local cfg = theme.header_line or {}
  local font_pt = tonumber(cfg.font_pt) or theme.text.body_pt
  local y = panel.y + (tonumber(cfg.y) or 32)
  local ok_l, left = pcall(doctor.header_line)
  local ok_r, right = pcall(doctor.header_time)
  if ok_l then
    draw_text_left_mid(cr, panel.x + (tonumber(cfg.x) or 32), y, left, theme.fonts.data, font_pt, theme.colors.fg)
  end
  if ok_r then
    draw_text_right_mid(cr, panel.x + panel.width - (tonumber(cfg.right_pad) or 32), y, right, theme.fonts.data,
      font_pt, theme.colors.fg)
  end
end

-- RUNTIME box: ROOT / DIRECTORY table. Labels centered under ROOT, paths
-- left-aligned under DIRECTORY (trimmed to fit).
local function draw_runtime_content(cr, panel, theme, widgets)
  local box = panel.boxes and panel.boxes.runtime
  local data = box and panel_data(widgets and widgets.doctor, "runtime_panel_data")
  if not data then return end

  local cfg = theme.runtime or {}
  local x = panel.x + box.x + (tonumber(cfg.content_x) or 16)
  local y = panel.y + box.y + (tonumber(cfg.content_y) or 16)
  local header_h = tonumber(cfg.header_h) or 16
  local row_h = tonumber(cfg.row_h) or 16
  local row_gap = tonumber(cfg.row_gap) or 2
  local root_w = tonumber(cfg.root_w) or 72
  local col_gap = tonumber(cfg.col_gap) or 8
  local dir_x = x + root_w + col_gap
  local dir_w = box.width - (tonumber(cfg.content_x) or 16) * 2 - root_w - col_gap
  local header_pt = tonumber(cfg.header_font_pt) or theme.text.body_sm_pt
  local row_pt = tonumber(cfg.row_font_pt) or theme.text.body_xs_pt
  local pad = tonumber(cfg.path_x_pad) or 4

  draw_table_header(cr, x, y, root_w, header_h, "ROOT", header_pt, theme)
  draw_table_header(cr, dir_x, y, dir_w, header_h, "DIRECTORY", header_pt, theme)

  for i, row in ipairs(data.rows or {}) do
    local mid_y = y + header_h + row_gap + ((i - 1) * row_h) + (row_h / 2)
    draw_text_center_mid(cr, x + (root_w / 2), mid_y, row.label, theme.fonts.data, row_pt, theme.colors.fg,
      CAIRO_FONT_WEIGHT_NORMAL)
    local path = fit_text(cr, row.value, theme.fonts.data, row_pt, dir_w - pad)
    draw_text_left_mid(cr, dir_x + pad, mid_y, path, theme.fonts.data, row_pt, theme.colors.fg,
      CAIRO_FONT_WEIGHT_NORMAL)
  end
end

-- CONFIG box: COMPONENTS / DATA table of the five config fields.
local function draw_config_content(cr, panel, theme, widgets)
  local box = panel.boxes and panel.boxes.config
  local data = box and panel_data(widgets and widgets.doctor, "config_panel_data")
  if not data then return end

  local cfg = theme.config or {}
  local x = panel.x + box.x + (tonumber(cfg.content_x) or 16)
  local y = panel.y + box.y + (tonumber(cfg.content_y) or 16)
  local header_h = tonumber(cfg.header_h) or 16
  local row_h = tonumber(cfg.row_h) or 16
  local row_gap = tonumber(cfg.row_gap) or 2
  local label_w = tonumber(cfg.label_w) or 112
  local value_w = tonumber(cfg.value_w) or 184
  local col_gap = tonumber(cfg.col_gap) or 8
  local value_x = x + label_w + col_gap
  local header_pt = tonumber(cfg.header_font_pt) or theme.text.body_sm_pt
  local row_pt = tonumber(cfg.row_font_pt) or theme.text.body_xs_pt
  local pad = tonumber(cfg.text_x_pad) or 4

  draw_table_header(cr, x, y, label_w, header_h, "COMPONENTS", header_pt, theme)
  draw_table_header(cr, value_x, y, value_w, header_h, "DATA", header_pt, theme)

  for i, row in ipairs(data.rows or {}) do
    local mid_y = y + header_h + row_gap + ((i - 1) * row_h) + (row_h / 2)
    draw_text_left_mid(cr, x + pad, mid_y, row.label, theme.fonts.data, row_pt, theme.colors.fg,
      CAIRO_FONT_WEIGHT_NORMAL)
    draw_text_left_mid(cr, value_x + pad, mid_y, fit_text(cr, row.value, theme.fonts.data, row_pt, value_w - pad),
      theme.fonts.data, row_pt, theme.colors.fg, CAIRO_FONT_WEIGHT_NORMAL)
  end
end

-- PROVIDERS box: DOMAIN | STATE | TTL | AGE | NOTE grid. A row whose NOTE
-- carries an actionable tag is highlighted whole (fg fill, ink text) — the
-- rule is keyed on the NOTE, never on STATE. `reserved_rows` blank rows
-- follow the domains (the AirGradient row).
local function draw_providers_content(cr, panel, theme, widgets)
  local box = panel.boxes and panel.boxes.providers
  local data = box and panel_data(widgets and widgets.doctor, "providers_panel_data")
  if not data then return end

  local cfg = theme.providers or {}
  local x = panel.x + box.x + (tonumber(cfg.content_x) or 16)
  local y = panel.y + box.y + (tonumber(cfg.content_y) or 16)
  local header_h = tonumber(cfg.header_h) or 16
  local header_gap = tonumber(cfg.header_gap) or 2
  local row_h = tonumber(cfg.row_h) or 20
  local header_pt = tonumber(cfg.header_font_pt) or theme.text.body_sm_pt
  local row_pt = tonumber(cfg.row_font_pt) or theme.text.body_xs_pt
  local widths = cfg.col_widths or { 96, 88, 88, 88, 88 }
  local labels = { "DOMAIN", "STATE", "TTL", "AGE", "NOTE" }

  local total_w = 0
  local col_x = {}
  for i, w in ipairs(widths) do
    col_x[i] = total_w
    total_w = total_w + w
  end

  for i, w in ipairs(widths) do
    draw_table_header(cr, x + col_x[i] + 1, y, w - 2, header_h, labels[i], header_pt, theme)
  end

  local rows = data.rows or {}
  local reserved = tonumber(cfg.reserved_rows) or 0
  local n_rows = #rows + reserved
  if #rows == 0 then n_rows = tonumber(cfg.empty_rows) or 22 end
  local grid_y = y + header_h + header_gap
  local grid_h = n_rows * row_h

  for i, row in ipairs(rows) do
    if row.highlight then
      fill_rect(cr, x + 1, grid_y + ((i - 1) * row_h) + 1, total_w - 1, row_h - 1, theme.colors.fg)
    end
  end

  draw_rect(cr, x, grid_y, total_w + 1, grid_h + 1, theme.strokes.line, theme.colors.fg)
  for i = 1, n_rows - 1 do
    draw_hline(cr, x, x + total_w, grid_y + (i * row_h), theme.strokes.line, theme.colors.fg)
  end
  for i = 2, #widths do
    draw_vline(cr, x + col_x[i], grid_y, grid_y + grid_h, theme.strokes.line, theme.colors.fg)
  end

  for i, row in ipairs(rows) do
    local mid_y = grid_y + ((i - 1) * row_h) + (row_h / 2) + 1
    local color = row.highlight and theme.colors.ink or theme.colors.fg
    local cells = { row.domain, row.state, row.ttl, row.age, row.note }
    for c, text in ipairs(cells) do
      local w = widths[c]
      draw_text_center_mid(cr, x + col_x[c] + (w / 2), mid_y, fit_text(cr, text, theme.fonts.data, row_pt, w - 6),
        theme.fonts.data, row_pt, color, CAIRO_FONT_WEIGHT_NORMAL)
    end
  end

  local footer = cfg.footer or {}
  draw_text_center_mid(cr, x + (total_w / 2), panel.y + box.y + (tonumber(footer.y) or 492), footer.text or "",
    theme.fonts.data, tonumber(footer.font_pt) or theme.text.micro_pt, theme.colors.fg, CAIRO_FONT_WEIGHT_NORMAL)
end

-- QRH-style action line: "-LABEL.......VALUE" with a dot leader filling the
-- gap so the value sits flush right (label + value are trimmed if needed).
local function draw_leader_line(cr, x, y, w, label, value, font_pt, theme)
  local face = theme.fonts.data
  local text = "-" .. (label or "")
  local val = value or ""
  local dot_w = text_width(cr, ".", face, font_pt)
  val = fit_text(cr, val, face, font_pt, math.max(0, w - text_width(cr, text, face, font_pt) - (dot_w * 3)))
  local avail = w - text_width(cr, text, face, font_pt) - text_width(cr, val, face, font_pt)
  local dots = math.max(2, math.floor(avail / dot_w))
  draw_text_left_mid(cr, x, y, text .. string.rep(".", dots), face, font_pt, theme.colors.fg,
    CAIRO_FONT_WEIGHT_NORMAL)
  draw_text_right_mid(cr, x + w, y, val, face, font_pt, theme.colors.fg, CAIRO_FONT_WEIGHT_NORMAL)
end

-- DCM idle state: one vertical gauge per eligible enabled domain, spaced
-- equally across the box width with the edges counted as gaps too, so a small
-- count still fills the panel. theme.dcm.idle.edge_gap tunes how large the edge
-- margin is relative to the gauge-to-gauge gap. TTL on top, code below, marker = AGE
-- against that TTL (top = fresh).
local function draw_dcm_idle(cr, panel, box, theme, data)
  local cfg = (theme.dcm or {}).idle or {}
  local face, pt = theme.fonts.data, tonumber(cfg.font_pt) or theme.text.body_xs_pt
  local box_x, box_y = panel.x + box.x, panel.y + box.y
  local n = #data.gauges
  local snap = tonumber(cfg.snap) or 4
  local top, bottom = tonumber(cfg.line_top) or 40, tonumber(cfg.line_bottom) or 128
  local cap = tonumber(cfg.cap_w) or 8
  local marker = tonumber(cfg.marker) or 8
  -- edge_gap = edge margin as a multiple of the gauge-to-gauge gap (1.0 =
  -- equal, 0.5 = half a gap, 0 = flush); the n gauges then span the box width
  -- as 2*edge + (n-1) gaps.
  local edge = math.max(0, tonumber(cfg.edge_gap) or 1.0)
  local gap = box.width / ((2 * edge) + math.max(1, n - 1))

  for i, g in ipairs(data.gauges) do
    local cx = box_x + (edge * gap) + ((i - 1) * gap)
    cx = math.floor((cx / snap) + 0.5) * snap
    draw_text_center_mid(cr, cx, box_y + (tonumber(cfg.label_y) or 24), g.ttl, face, pt, theme.colors.fg,
      CAIRO_FONT_WEIGHT_NORMAL)
    draw_vline(cr, cx, box_y + top, box_y + bottom, theme.strokes.line, theme.colors.fg)
    draw_hline(cr, cx - (cap / 2), cx + (cap / 2), box_y + top, theme.strokes.line, theme.colors.fg)
    draw_hline(cr, cx - (cap / 2), cx + (cap / 2), box_y + bottom, theme.strokes.line, theme.colors.fg)
    local my = box_y + top + math.floor(((bottom - top) * g.frac) + 0.5)
    fill_rect(cr, cx - (marker / 2) + 1, my - (marker / 2), marker, marker, theme.colors.fg)
    draw_text_center_mid(cr, cx, box_y + (tonumber(cfg.code_y) or 144), g.code, face, pt, theme.colors.fg,
      CAIRO_FONT_WEIGHT_NORMAL)
  end
end

-- DCM active state: full takeover. Each entry is a domain bar, a condition
-- line, a dot-leader action line and a PROC line (the QRH procedure title).
-- When more entries are active than fit, the list scrolls one whole entry
-- block every scroll_interval_sec (a pure function of wall-clock time, so it
-- wraps without persisted state — same idiom as SitRep's alert banner).
local function draw_dcm_active(cr, panel, box, theme, data)
  local cfg = (theme.dcm or {}).active or {}
  local face, pt = theme.fonts.data, tonumber(cfg.font_pt) or theme.text.body_xs_pt
  local x = panel.x + box.x + (tonumber(cfg.content_x) or 16)
  local first_y = tonumber(cfg.first_y) or 16
  local y = panel.y + box.y + first_y
  local w = box.width - ((tonumber(cfg.content_x) or 16) * 2)
  local bar_h = tonumber(cfg.bar_h) or 16
  local line_h = tonumber(cfg.line_h) or 16
  local gap = tonumber(cfg.entry_gap) or 8
  local pad = tonumber(cfg.text_x_pad) or 8
  local entry_h = bar_h + (line_h * 3)
  local room = box.height - first_y - (tonumber(cfg.bottom_pad) or 8)
  local fit = math.max(1, math.floor((room + gap) / (entry_h + gap)))
  local total = #data.entries
  local shown = math.min(total, fit)

  local start = 0
  if total > fit then
    local interval = tonumber(cfg.scroll_interval_sec) or 3
    if interval <= 0 then interval = 3 end
    start = math.floor(os.time() / interval) % total
  end

  for i = 0, shown - 1 do
    local entry = data.entries[((start + i) % total) + 1]
    local ey = y + (i * (entry_h + gap))
    fill_rect(cr, x, ey, w, bar_h, theme.colors.fg)
    draw_text_left_mid(cr, x + pad, ey + (bar_h / 2), entry.domain, face, pt, theme.colors.ink,
      CAIRO_FONT_WEIGHT_NORMAL)
    draw_text_left_mid(cr, x + pad, ey + bar_h + (line_h / 2), fit_text(cr, entry.cond or "", face, pt, w - (pad * 2)),
      face, pt, theme.colors.fg, CAIRO_FONT_WEIGHT_NORMAL)
    draw_leader_line(cr, x + pad, ey + bar_h + line_h + (line_h / 2), w - (pad * 2), entry.label, entry.value, pt,
      theme)
    draw_text_left_mid(cr, x + pad, ey + bar_h + (line_h * 2) + (line_h / 2),
      (cfg.proc_prefix or "PROC: ") .. (entry.proc or ""), face, pt, theme.colors.fg, CAIRO_FONT_WEIGHT_NORMAL)
  end
end

local function draw_dcm_content(cr, panel, theme, widgets)
  local box = panel.boxes and panel.boxes.dcm
  local data = box and panel_data(widgets and widgets.doctor, "dcm_panel_data")
  if not data then return end
  if data.mode == "active" then
    draw_dcm_active(cr, panel, box, theme, data)
  else
    draw_dcm_idle(cr, panel, box, theme, data)
  end
end

-- Chassis footer: a single centered version-identity line near the
-- bottom of the outer frame, not tied to any panel — matches the
-- previz. Text comes from version_identity_label() above (live
-- CORE/DOC versions from core.toml/suite.toml), not a static string.
local function draw_chassis_footer(cr, theme, frame)
  local cfg = theme.footer or {}
  local label = version_identity_label()
  if not label or label == "" then return end

  local font_pt = tonumber(cfg.font_pt) or 14
  local bottom_inset = tonumber(cfg.bottom_inset) or 24
  local center_x = frame.x + (frame.width / 2)
  local y = frame.y + frame.height - bottom_inset

  draw_text_center_mid(cr, center_x, y, label, theme.fonts.title, font_pt, theme.colors.fg, CAIRO_FONT_WEIGHT_BOLD)
end

-- Draw order mirrors OSA's frame.lua: bg -> shadow -> panels/boxes/titles
-- -> footer -> lights -> outer border (on top, so it isn't dimmed by the
-- shadow bands or covered by light bleed). `widgets` is accepted for
-- parity with OSA/Doctor's per-panel data-provider table but is unused
-- until box content exists.
function M.draw(cr, theme, layout, panels, widgets)
  if type(theme) ~= "table" or type(layout) ~= "table" then return end
  widgets = widgets or {}

  local frame = layout.frame or { x = 0, y = 0, width = 1080, height = 664 }
  local scale = resolve_scale(layout)

  cairo_save(cr)
  cairo_scale(cr, scale, scale)

  fill_rect(cr, frame.x, frame.y, frame.width, frame.height, theme.colors.bg)
  draw_frame_shadow(cr, frame, theme)

  local resolved_panels = resolve_panels(panels or {}, layout)
  for _, panel in pairs(resolved_panels) do
    draw_rect(cr, panel.x, panel.y, panel.width, panel.height, theme.strokes.line, theme.colors.fg)
    draw_panel_title(cr, panel, theme)
    draw_panel_boxes(cr, panel, theme)
    draw_header_line(cr, panel, theme, widgets)
    draw_dcm_content(cr, panel, theme, widgets)
    draw_runtime_content(cr, panel, theme, widgets)
    draw_config_content(cr, panel, theme, widgets)
    draw_providers_content(cr, panel, theme, widgets)
  end

  draw_chassis_footer(cr, theme, frame)

  draw_frame_lights(cr, frame, theme)

  draw_frame_rect(
    cr,
    frame.x,
    frame.y,
    frame.width,
    frame.height,
    theme.strokes.frame or theme.strokes.line,
    theme.colors.fg,
    theme.strokes.frame_alpha
  )

  cairo_restore(cr)
end

return M
