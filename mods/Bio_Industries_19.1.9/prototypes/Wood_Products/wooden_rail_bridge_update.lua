local BioInd = require('common')('Bio_Industries')

local ICONPATH = BioInd.modRoot .. "/graphics/entities/wood_products/rails/"

--~ local type = {
  --~ straight_rail_horizontal = { prefix = "straight-rail", dir = "horizontal" },
  --~ straight_rail_vertical = { prefix = "straight-rail", dir = "vertical" },
  --~ straight_rail_diagonal_left_top = { prefix = "straight-rail", dir = "diagonal-left-top" },
  --~ straight_rail_diagonal_right_top = { prefix = "straight-rail", dir = "diagonal-right-top" },
  --~ straight_rail_diagonal_left_bottom = { prefix = "straight-rail", dir = "diagonal-left-bottom" },
  --~ straight_rail_diagonal_right_bottom = { prefix = "straight-rail", dir = "diagonal-right-bottom" },

  --~ curved_rail_horizontal_left_bottom = { prefix = "curved-rail", dir = "horizontal-left-bottom" },
  --~ curved_rail_horizontal_right_bottom = { prefix = "curved-rail", dir = "horizontal-right-bottom" },
  --~ curved_rail_horizontal_left_top = { prefix = "curved-rail", dir = "horizontal-left-top" },
  --~ curved_rail_horizontal_right_top = { prefix = "curved-rail", dir = "horizontal-right-top" },
  --~ curved_rail_vertical_left_bottom = { prefix = "curved-rail", dir = "vertical-left-bottom" },
  --~ curved_rail_vertical_right_bottom = { prefix = "curved-rail", dir = "vertical-right-bottom" },
  --~ curved_rail_vertical_left_top = { prefix = "curved-rail", dir = "vertical-left-top" },
  --~ curved_rail_vertical_right_top = { prefix = "curved-rail", dir = "vertical-right-top" }
--~ }

--~ for class, info in pairs(type) do
  --~ local proto = data.raw[info.prefix]
  --~ data.raw[info.prefix]["bi-" .. info.prefix .. "-wood-bridge"].pictures[class].stone_path.hr_version.filename = ICONPATH .. info.prefix .. "-bridge/hr-" .. info.prefix .. "-" .. info.dir .. "-stone-path.png"
  --~ data.raw[info.prefix]["bi-" .. info.prefix .. "-wood-bridge"].pictures[class].stone_path_background.hr_version.filename = ICONPATH .. info.prefix .. "-bridge/hr-" .. info.prefix .. "-" .. info.dir .. "-stone-path-background.png"
  --~ data.raw[info.prefix]["bi-" .. info.prefix .. "-wood-bridge"].pictures[class].stone_path.filename = ICONPATH ..info.prefix .. "-bridge/" .. info.prefix .. "-" .. info.dir .. "-stone-path.png"
  --~ data.raw[info.prefix]["bi-" .. info.prefix .. "-wood-bridge"].pictures[class].stone_path_background.filename = ICONPATH .. info.prefix .. "-bridge/" .. info.prefix .. "-" .. info.dir .. "-stone-path-background.png"
--~ end

local pix = {
  "straight_rail_horizontal",
  "straight_rail_vertical",
  "straight_rail_diagonal_left_bottom",  "straight_rail_diagonal_left_top",
  "straight_rail_diagonal_right_bottom", "straight_rail_diagonal_right_top",

  "curved_rail_horizontal_left_bottom",  "curved_rail_horizontal_left_top",
  "curved_rail_horizontal_right_bottom", "curved_rail_horizontal_right_top",
  "curved_rail_vertical_left_bottom",    "curved_rail_vertical_left_top",
  "curved_rail_vertical_right_bottom",   "curved_rail_vertical_right_top",
}
local PATH, FILE, HR_FILE
local rail_type, direction, img, proto

for p, pic in ipairs(pix) do
  -- Extract rail_type and direction from the string and replace underscores with "-"
  rail_type = pic:match("^([^_]+_rail)_.+$"):gsub("_", "-")
  direction = pic:match("^.+_rail_(.+)$"):gsub("_", "-")
BioInd.show("rail_type", rail_type)
BioInd.show("direction", direction)

  -- Rails
  PATH = ICONPATH .. rail_type .. "-bridge"
  FILE = PATH .. "/" .. rail_type .. "-" .. direction .. "-"
  HR_FILE = PATH .. "/hr-" .. rail_type .. "-" .. direction .. "-"

  img = data.raw[rail_type]["bi-" .. rail_type .. "-wood-bridge"].pictures[pic]

  img.stone_path.filename = FILE .. "stone-path.png"
  img.stone_path.hr_version.filename = HR_FILE .. "stone-path.png"

  img.stone_path_background.filename = FILE.."stone-path-background.png"
  img.stone_path_background.hr_version.filename = HR_FILE.."stone-path-background.png"

  -- Remnants
  img = data.raw["rail-remnants"][rail_type .. "-remnants-wood-bridge"].pictures[pic]

  img.stone_path.filename = ICONPATH ..  "remnants/remnants.png"
  img.stone_path.hr_version.filename = ICONPATH ..  "remnants/hr-remnants.png"

  img.stone_path_background.filename = ICONPATH ..  "remnants/remnants.png"
  img.stone_path_background.hr_version.filename = ICONPATH ..  "remnants/hr-remnants.png"
end

-- Localize remnants!
local remnants
for f, form in ipairs({"straight", "curved"}) do
  remnants = data.raw["rail-remnants"][form .. "-rail-remnants-wood-bridge"]

  remnants.localised_name = {"entity-name.rail-remnants-wood-bridge"}
  remnants.localised_description = {"entity-description.rail-remnants-wood-bridge"}
end
