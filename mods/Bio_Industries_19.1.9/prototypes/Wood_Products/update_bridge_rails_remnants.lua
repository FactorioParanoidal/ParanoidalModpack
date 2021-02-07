--~ local BioInd = require('common')('Bio_Industries')

--~ local ICONPATH = BioInd.modRoot .. "/graphics/entities/wood_products/rails/remnants/"
--~ local PIX

--~ local rails_c_remnants = data.raw["rail-remnants"]["straight-rail-remnants-wood-bridge"]
--~ rails_c_remnants.localised_name = {"entity-name.rail-remnants-wood-bridge"}
--~ rails_c_remnants.localised_description = {"entity-description.rail-remnants-wood-bridge"}

--~ PIX = rails_c_remnants.pictures

--~ PIX.straight_rail_horizontal.stone_path_background.filename = ICONPATH ..  "remnants.png"
--~ PIX.straight_rail_horizontal.stone_path_background.hr_version.filename = ICONPATH ..  "hr-remnants.png"
--~ PIX.straight_rail_vertical.stone_path_background.filename = ICONPATH ..  "remnants.png"
--~ PIX.straight_rail_vertical.stone_path_background.hr_version.filename = ICONPATH ..  "hr-remnants.png"
--~ PIX.straight_rail_diagonal_left_top.stone_path_background.filename = ICONPATH ..  "remnants.png"
--~ PIX.straight_rail_diagonal_left_top.stone_path_background.hr_version.filename = ICONPATH ..  "hr-remnants.png"
--~ PIX.straight_rail_diagonal_right_top.stone_path_background.filename = ICONPATH ..  "remnants.png"
--~ PIX.straight_rail_diagonal_right_top.stone_path_background.hr_version.filename = ICONPATH ..  "hr-remnants.png"
--~ PIX.straight_rail_diagonal_right_bottom.stone_path_background.filename = ICONPATH ..  "remnants.png"
--~ PIX.straight_rail_diagonal_right_bottom.stone_path_background.hr_version.filename = ICONPATH ..  "hr-remnants.png"
--~ PIX.straight_rail_diagonal_left_bottom.stone_path_background.filename = ICONPATH ..  "remnants.png"
--~ PIX.straight_rail_diagonal_left_bottom.stone_path_background.hr_version.filename = ICONPATH ..  "hr-remnants.png"

--~ PIX.straight_rail_horizontal.stone_path.filename = ICONPATH ..  "remnants.png"
--~ PIX.straight_rail_horizontal.stone_path.hr_version.filename = ICONPATH ..  "hr-remnants.png"
--~ PIX.straight_rail_vertical.stone_path.filename = ICONPATH ..  "remnants.png"
--~ PIX.straight_rail_vertical.stone_path.hr_version.filename = ICONPATH ..  "hr-remnants.png"
--~ PIX.straight_rail_diagonal_left_top.stone_path.filename = ICONPATH ..  "remnants.png"
--~ PIX.straight_rail_diagonal_left_top.stone_path.hr_version.filename = ICONPATH ..  "hr-remnants.png"
--~ PIX.straight_rail_diagonal_right_top.stone_path.filename = ICONPATH ..  "remnants.png"
--~ PIX.straight_rail_diagonal_right_top.stone_path.hr_version.filename = ICONPATH ..  "hr-remnants.png"
--~ PIX.straight_rail_diagonal_right_bottom.stone_path.filename = ICONPATH ..  "remnants.png"
--~ PIX.straight_rail_diagonal_right_bottom.stone_path.hr_version.filename = ICONPATH ..  "hr-remnants.png"
--~ PIX.straight_rail_diagonal_left_bottom.stone_path.filename = ICONPATH ..  "remnants.png"
--~ PIX.straight_rail_diagonal_left_bottom.stone_path.hr_version.filename = ICONPATH ..  "hr-remnants.png"



--~ local rails_curved_c_remnants = data.raw["rail-remnants"]["curved-rail-remnants-wood-bridge"]
--~ rails_curved_c_remnants.localised_name = {"entity-name.rail-remnants-wood-bridge"}
--~ rails_curved_c_remnants.localised_description = {"entity-description.rail-remnants-wood-bridge"}
--~ PIX = rails_curved_c_remnants.pictures

--~ PIX.curved_rail_vertical_left_top.stone_path_background.filename = ICONPATH ..  "remnants.png"
--~ PIX.curved_rail_vertical_left_top.stone_path_background.hr_version.filename = ICONPATH ..  "hr-remnants.png"
--~ PIX.curved_rail_vertical_left_bottom.stone_path_background.filename = ICONPATH ..  "remnants.png"
--~ PIX.curved_rail_vertical_left_bottom.stone_path_background.hr_version.filename = ICONPATH ..  "hr-remnants.png"
--~ PIX.curved_rail_vertical_right_top.stone_path_background.filename = ICONPATH ..  "remnants.png"
--~ PIX.curved_rail_vertical_right_top.stone_path_background.hr_version.filename = ICONPATH ..  "hr-remnants.png"
--~ PIX.curved_rail_vertical_right_bottom.stone_path_background.filename = ICONPATH ..  "remnants.png"
--~ PIX.curved_rail_vertical_right_bottom.stone_path_background.hr_version.filename = ICONPATH ..  "hr-remnants.png"
--~ PIX.curved_rail_horizontal_left_top.stone_path_background.filename = ICONPATH ..  "remnants.png"
--~ PIX.curved_rail_horizontal_left_top.stone_path_background.hr_version.filename = ICONPATH ..  "hr-remnants.png"
--~ PIX.curved_rail_horizontal_right_top.stone_path_background.filename = ICONPATH ..  "remnants.png"
--~ PIX.curved_rail_horizontal_right_top.stone_path_background.hr_version.filename = ICONPATH ..  "hr-remnants.png"
--~ PIX.curved_rail_horizontal_right_bottom.stone_path_background.filename = ICONPATH ..  "remnants.png"
--~ PIX.curved_rail_horizontal_right_bottom.stone_path_background.hr_version.filename = ICONPATH ..  "hr-remnants.png"
--~ PIX.curved_rail_horizontal_left_bottom.stone_path_background.filename = ICONPATH ..  "remnants.png"
--~ PIX.curved_rail_horizontal_left_bottom.stone_path_background.hr_version.filename = ICONPATH ..  "hr-remnants.png"

--~ PIX.curved_rail_vertical_left_top.stone_path.filename = ICONPATH ..  "remnants.png"
--~ PIX.curved_rail_vertical_left_top.stone_path.hr_version.filename = ICONPATH ..  "hr-remnants.png"
--~ PIX.curved_rail_vertical_left_bottom.stone_path.filename = ICONPATH ..  "remnants.png"
--~ PIX.curved_rail_vertical_left_bottom.stone_path.hr_version.filename = ICONPATH ..  "hr-remnants.png"
--~ PIX.curved_rail_vertical_right_top.stone_path.filename = ICONPATH ..  "remnants.png"
--~ PIX.curved_rail_vertical_right_top.stone_path.hr_version.filename = ICONPATH ..  "hr-remnants.png"
--~ PIX.curved_rail_vertical_right_bottom.stone_path.filename = ICONPATH ..  "remnants.png"
--~ PIX.curved_rail_vertical_right_bottom.stone_path.hr_version.filename = ICONPATH ..  "hr-remnants.png"
--~ PIX.curved_rail_horizontal_left_top.stone_path.filename = ICONPATH ..  "remnants.png"
--~ PIX.curved_rail_horizontal_left_top.stone_path.hr_version.filename = ICONPATH ..  "hr-remnants.png"
--~ PIX.curved_rail_horizontal_right_top.stone_path.filename = ICONPATH ..  "remnants.png"
--~ PIX.curved_rail_horizontal_right_top.stone_path.hr_version.filename = ICONPATH ..  "hr-remnants.png"
--~ PIX.curved_rail_horizontal_right_bottom.stone_path.filename = ICONPATH ..  "remnants.png"
--~ PIX.curved_rail_horizontal_right_bottom.stone_path.hr_version.filename = ICONPATH ..  "hr-remnants.png"
--~ PIX.curved_rail_horizontal_left_bottom.stone_path.filename = ICONPATH ..  "remnants.png"
--~ PIX.curved_rail_horizontal_left_bottom.stone_path.hr_version.filename = ICONPATH ..  "hr-remnants.png"
