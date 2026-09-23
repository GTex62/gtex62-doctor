local layout = {}

-- Doctor is authored in one live coordinate space, same as OSA/SitRep.
-- Conky window dimensions are derived at runtime from this frame.
--
-- Base dimensions match the annotated previz
-- (design/gtex62-doctor-03-measured.jpg): 1075 x 651.6 outer frame, snapped
-- to the 8px grid — same grid rhythm as OSA/SitRep (theme.spacing.grid
-- = 8). At layout.scale = 1.25, a multiple of 8 always lands on a whole
-- device pixel after scaling (8 * 1.25 = 10); the unsnapped values above
-- do not, which is real render blur, not just a tidiness nit.
--
-- Width is 1080, not the nearest-8 1072: OSA (the first suite) sets the
-- edge gutter at 28px on both sides (1736 = 28 + 3*520 + 2*60 + 28), and
-- Doctor matches it (1080 = 28 + 1024 + 28) so all suites share the same
-- chassis-edge-to-panel spacing.
layout.frame = {
  x = 0,
  y = 0,
  width = 1080,
  height = 648,
}

-- scale_mode: "manual" uses layout.scale directly.
-- scale_mode: "auto" computes scale from CONKY_SCREEN_W/H vs frame dimensions.
-- Frame dimensions are the base (scale=1.0) coordinate space.
layout.scale_mode = "manual"
layout.scale = 1.00 -- scale change requires restart

-- Doctor is single-panel, so there is only one column for now.
layout.columns = {
  main = { x = 28, width = 1024 },
}

layout.rows = {
  top = 40,
  gap = 24,
}

-- scaled_frame: pre-computed for Conky window sizing at conf load time.
-- In auto mode this reads CONKY_SCREEN_W/H; export them before launching Conky.
local function _compute_scale()
  if layout.scale_mode == "auto" then
    local w = tonumber(os.getenv("CONKY_SCREEN_W"))
    local h = tonumber(os.getenv("CONKY_SCREEN_H"))
    local bw = layout.frame.width
    local bh = layout.frame.height
    if w and h and bw > 0 and bh > 0 then
      return math.min(w / bw, h / bh)
    end
  end
  return tonumber(layout.scale) or 1.0
end

local _s = _compute_scale()
layout.scaled_frame = {
  x      = math.floor(layout.frame.x * _s + 0.5),
  y      = math.floor(layout.frame.y * _s + 0.5),
  width  = math.floor(layout.frame.width * _s + 0.5),
  height = math.floor(layout.frame.height * _s + 0.5),
}

return layout
