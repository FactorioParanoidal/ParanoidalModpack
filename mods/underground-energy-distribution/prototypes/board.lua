-- Paranoidal 2.0 port: common builder for the three distribution boards.
-- Values are those of the 1.1 mod (Beta 8); only the prototype format follows Factorio 2.0.
local util = require("util")

local GRAPHICS = "__underground-energy-distribution__/graphics/"

local function make_board(def)
	local board = table.deepcopy(data.raw["electric-pole"][def.base])

	board.name = def.name
	-- Base poles may carry `icons`, which would override `icon`.
	board.icons = nil
	board.icon = GRAPHICS .. def.icon
	board.icon_size = 64

	local h = def.half
	board.selection_box = {{-h, -h}, {h, h}}
	board.map_generator_bounding_box = {{-h, -h}, {h, h}}
	board.tile_width = def.tiles
	board.tile_height = def.tiles
	-- 2.0 replacement of drawing_box: a flat board has no tall sprite.
	board.drawing_box_vertical_extension = 0

	board.minable = {mining_time = 0.5, result = def.name}
	board.draw_copper_wires = false
	board.draw_circuit_wires = settings.startup["ued-settings-show-circuit"].value
	board.supply_area_distance = def.supply_area_distance
	board.maximum_wire_distance = def.maximum_wire_distance

	board.integration_patch = {
		layers = {
			{filename = GRAPHICS .. def.pole, priority = "low", width = 256, height = 256, scale = def.scale},
			{filename = GRAPHICS .. "pole-shadow.png", priority = "low", width = 256, height = 256, scale = def.scale, draw_as_shadow = true},
		}
	}
	board.integration_patch_render_layer = "decorative"
	board.pictures = {
		layers = {
			{filename = GRAPHICS .. "empty.png", priority = "low", width = 256, height = 256, scale = def.scale, direction_count = 1},
		}
	}
	board.water_reflection = nil

	board.connection_points = {{
		shadow = {copper = util.by_pixel_hr(0, 0), red = util.by_pixel_hr(0, 0), green = util.by_pixel_hr(0, 0)},
		wire = {copper = util.by_pixel_hr(0, 0), red = util.by_pixel_hr(0, 0), green = util.by_pixel_hr(0, 0)},
	}}

	-- 1.1 {"doodad-layer"}: buildings can be placed on top, boards still collide with each other and water.
	board.collision_mask = {layers = {doodad = true}}
	-- Beta 8: only the small board was fast-replaceable with poles (1.1 big pole/substation had no group).
	board.fast_replaceable_group = def.fast_replaceable_group
	board.next_upgrade = nil

	local ingredients = {}
	for _, ingredient in ipairs(def.ingredients) do
		ingredients[#ingredients + 1] = {type = "item", name = ingredient[1], amount = ingredient[2]}
	end

	data:extend({
		{
			type = "item",
			name = def.name,
			icon = GRAPHICS .. def.icon,
			icon_size = 64,
			subgroup = "energy-pipe-distribution",
			order = def.order,
			place_result = def.name,
			stack_size = 50,
		},
		{
			type = "recipe",
			name = def.name,
			enabled = false,
			ingredients = ingredients,
			results = {{type = "item", name = def.name, amount = 1}},
		},
		board,
	})
end

return make_board
