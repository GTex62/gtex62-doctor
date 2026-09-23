-- Doctor is a single-panel widget, like SitRep — this file still exists
-- (rather than folding panel geometry into layout.lua) purely to keep the
-- same theme/layout/panels/palettes split OSA and SitRep use.
--
-- Box geometry below comes from the annotated previz
-- (design/gtex62-doctor-03-measured.jpg): panel 1021.8 x 580, DCM 483.5 x
-- 173.4, RUNTIME 483.5 x 148, CONFIG 483.5 x 125.8, PROVIDERS 483.5 x
-- 507.2 — every value snapped to the 8px grid. Gutters match OSA: 28px
-- chassis edge to panel on both sides, 16px inner box margins, 32px
-- between boxes vertically. Columns are 480 wide
-- (16 + 480 + 32 + 480 + 16 = 1024 = panel width); the left stack
-- (168 + 144 + 128, 32px gaps) sums to PROVIDERS' 504 height, so DCM and
-- RUNTIME each snap down (173.4 -> 168, 148 -> 144) to keep the 32px gaps
-- the measured previz's ~30px gaps round to. Geometry only — box borders
-- and static titles, no data/tables/text content yet.
local panels = {
  main = {
    title = "DOC",
    column = "main",
    x = 28,
    y = 40,
    width = 1024,
    height = 576,
    boxes = {
      dcm = {
        x = 16,
        y = 56,
        width = 480,
        height = 168,
        title = "DCM",
      },
      runtime = {
        x = 16,
        y = 256,
        width = 480,
        height = 144,
        title = "RUNTIME",
      },
      config = {
        x = 16,
        y = 432,
        width = 480,
        height = 128,
        title = "CONFIG",
      },
      providers = {
        x = 528,
        y = 56,
        width = 480,
        height = 504,
        title = "PROVIDERS",
      },
    },
  },
}

return panels
