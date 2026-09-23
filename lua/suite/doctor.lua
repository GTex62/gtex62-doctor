-- Data layer for the Doctor boxes. Reads core's shared/doctor/{profile}/
-- status.json (written by providers/doctor/fetch_doctor.sh) and turns it into
-- ready-to-draw view models; frame.lua only lays out what it is handed.
-- Same division as gtex62-sitrep's lua/suite/*.lua.
local M = {}

local HOME = os.getenv("HOME") or ""
local SUITE_DIR = os.getenv("CONKY_SUITE_DIR") or (HOME .. "/.config/conky/gtex62-doctor")
local RUNTIME_ROOT = os.getenv("GTEX62_CONFIG_DIR") or os.getenv("GTEX62_CONKY_CONFIG_DIR")
    or (HOME .. "/.config/gtex62-core")
local CACHE_ROOT = os.getenv("GTEX62_CACHE_DIR") or os.getenv("GTEX62_CONKY_CACHE_DIR")
    or (HOME .. "/.cache/gtex62-core")

local json = dofile(SUITE_DIR .. "/lua/lib/json.lua")
local qrh = dofile(SUITE_DIR .. "/lua/lib/qrh.lua")

local function read_file(path)
  local f = io.open(path, "r")
  if not f then return nil end
  local s = f:read("*a")
  f:close()
  return s
end

-- suites/doctor.toml [profiles] doctor = "..." (default "local").
local function doctor_profile()
  local s = read_file(RUNTIME_ROOT .. "/suites/doctor.toml")
  if s then
    local in_profiles = false
    for line in s:gmatch("[^\r\n]+") do
      line = line:gsub("#.*$", ""):gsub("^%s+", ""):gsub("%s+$", "")
      if line:match("^%[") then in_profiles = (line == "[profiles]") end
      if in_profiles then
        local v = line:match('^doctor%s*=%s*"([^"]*)"')
        if v and v ~= "" then return v end
      end
    end
  end
  return "local"
end

local CACHE = { tick = nil, doc = nil }

-- status.json, re-read at most once per second; nil when missing/unparseable.
function M.status()
  local tick = os.time()
  if CACHE.tick == tick then return CACHE.doc end
  CACHE.tick = tick
  local path = string.format("%s/shared/doctor/%s/status.json", CACHE_ROOT, doctor_profile())
  CACHE.doc = json.decode(read_file(path))
  return CACHE.doc
end

local STATE_WORD = {
  nominal = "NOMINAL", warn = "WARN", disabled = "DISABLED", private = "PRIVATE",
  hybrid = "HYBRID", optional = "OPTIONAL", idle = "IDLE", armed = "ARMED", running = "RUNNING",
}

local function hms(iso)
  return iso and iso:match("T(%d%d:%d%d:%d%d)Z") and (iso:match("T(%d%d:%d%d:%d%d)Z") .. "Z") or ""
end

-- AGE cell text, per doctor-design.md's AGE column section.
local function age_cell(row)
  if not row.enabled then return "" end
  -- NET/SYSTEM/TIME (1s class) blank; NET's only while the fallback flag is
  -- clear, since a climbing AGE is what confirms the fallback.
  if row.fast_track and not row.ttl_fallback then return "" end
  local kind = row.age_kind
  if kind == "ratio" then return row.age_ratio or "" end
  if kind == "date" then return row.age_ts or "" end
  if kind == "timestamp" then return hms(row.age_ts) end
  if type(row.age_sec) == "number" then return tostring(math.floor(row.age_sec)) end
  return ""
end

local function ttl_cell(row)
  if row.ttl_label then return row.ttl_label end
  if type(row.ttl_sec) == "number" then return tostring(row.ttl_sec) end
  return ""
end

-- NOTE cell: the primary tag; a trailing "+" when more actionable tags share
-- the row (the full list is DCM's job).
local function note_cell(row)
  if not row.enabled or not row.note then return "" end
  local actionable = 0
  for _, tag in ipairs(row.notes or {}) do
    if tag ~= "OPTIONAL" then actionable = actionable + 1 end
  end
  return row.note .. ((actionable > 1) and "+" or "")
end

-- PROVIDERS rows: alphabetical, one per domain in status.json's
-- domain_order. `highlight` is the actionable-NOTE rule, never STATE.
function M.providers_panel_data()
  local doc = M.status()
  local rows = {}
  if doc and type(doc.domain_order) == "table" then
    for _, key in ipairs(doc.domain_order) do
      local row = doc.domains and doc.domains[key]
      if type(row) == "table" then
        rows[#rows + 1] = {
          domain = key:upper(),
          state = STATE_WORD[row.state] or tostring(row.state or ""):upper(),
          ttl = ttl_cell(row),
          age = age_cell(row),
          note = note_cell(row),
          highlight = row.highlight == true,
        }
      end
    end
  end
  return { rows = rows, has_data = doc ~= nil }
end

-- Paths shown as ~/... where they sit under $HOME, uppercased (the data font
-- has no lowercase glyphs).
local function display_path(path)
  if not path then return "" end
  if HOME ~= "" and path:sub(1, #HOME) == HOME then path = "~" .. path:sub(#HOME + 1) end
  return path:upper()
end

function M.runtime_panel_data()
  local doc = M.status()
  local rows = {}
  for _, r in ipairs((doc and doc.runtime) or {}) do
    rows[#rows + 1] = { label = tostring(r.label or ""):upper(), value = display_path(r.path) }
  end
  return { rows = rows }
end

local function config_value(field)
  if type(field) ~= "table" or field.state == "blank" then return "BLANK" end
  if field.value then return tostring(field.value):upper() end
  return "NOMINAL" -- a set secret: presence only, never the value
end

function M.config_panel_data()
  local doc = M.status()
  local c = (doc and doc.config) or {}
  return {
    rows = {
      { label = "TIME ZONE", value = config_value(c.timezone) },
      { label = "LAT", value = config_value(c.lat) },
      { label = "LON", value = config_value(c.lon) },
      { label = "OPENWX API", value = config_value(c.openwx_api) },
      { label = "AIRNOW API", value = config_value(c.airnow_api) },
    },
  }
end


-- DCM gauge codes: three letters, or the standard abbreviation (AVN); AP and
-- WX are deliberately two letters (doctor-design.md, Domain codes and legend).
local GAUGE_CODE = {
  air = "AIR", alerts = "ALR", ap = "AP", astro = "AST", aviation = "AVN", modem = "MDM",
  orb = "ORB", pihole = "PIH", solar = "SOL", vpn = "VPN", weather = "WX",
}

-- A domain gets a gauge only if its AGE is a duration against a single TTL
-- and that TTL meaningfully exceeds Conky's own refresh cadence. 5s
-- (NETWORK) is confirmed too close to the flicker zone; the smallest
-- eligible launcher default is VPN's 10s. A DISABLED domain gets none.
local GAUGE_MIN_TTL = 10

local function gauge_eligible(row)
  return row.enabled == true and row.state ~= "disabled" and row.age_kind == "duration"
      and row.fast_track ~= true and type(row.ttl_sec) == "number" and row.ttl_sec >= GAUGE_MIN_TTL
      and type(row.age_sec) == "number"
end

-- DCM is always in exactly one state. Active (any actionable entry): every
-- entry as condition / action / PROC lines. Idle: one vertical gauge per
-- eligible, enabled domain — top = fresh, falling toward the bottom as AGE
-- nears the domain's own TTL. Entry text comes from lua/lib/qrh.lua.
function M.dcm_panel_data()
  local doc = M.status()
  if not doc then return { mode = "idle", gauges = {}, entries = {}, no_data = true } end

  if type(doc.entries) == "table" and #doc.entries > 0 then
    local entries = {}
    for _, item in ipairs(doc.entries) do
      local text = qrh.text(item)
      entries[#entries + 1] = {
        domain = tostring(item.domain or ""):upper(),
        cond = text.cond,
        label = text.label,
        value = text.value,
        proc = tostring(item.proc or "UNRECOGNIZED NOTE"):upper(),
      }
    end
    return { mode = "active", entries = entries, gauges = {} }
  end

  local gauges = {}
  for _, key in ipairs(doc.domain_order or {}) do
    local row = doc.domains and doc.domains[key]
    if type(row) == "table" and gauge_eligible(row) then
      local frac = math.max(0, math.min(1, row.age_sec / row.ttl_sec))
      gauges[#gauges + 1] = {
        code = GAUGE_CODE[key] or key:sub(1, 3):upper(),
        ttl = tostring(row.ttl_sec),
        frac = frac,
      }
    end
  end
  return { mode = "idle", gauges = gauges, entries = {} }
end

-- DOC header line: the fast top-level check (idle "NO HEALTH ALERTS" /
-- active "CHECK ACTIONS (N)"), independent of what DCM's body shows.
-- status.json older than this means the doctor loop is not running (its own
-- loop is 5s, so 6x that). Read from the file's own write time
-- (generated_epoch) — equivalent to its mtime without shelling out to stat.
local STALE_AFTER_SEC = 30

function M.status_age()
  local doc = M.status()
  if not doc or type(doc.generated_epoch) ~= "number" then return nil end
  return math.max(0, os.time() - doc.generated_epoch)
end

function M.header_line()
  local doc = M.status()
  if not doc or not doc.summary then return "NO DATA" end
  local age = M.status_age()
  if age and age > STALE_AFTER_SEC then
    return string.format("DOCTOR STALE - %dS", age)
  end
  return tostring(doc.summary.header or ""):upper()
end

function M.header_time()
  return os.date("%Y.%m.%d // %H:%M")
end

return M
