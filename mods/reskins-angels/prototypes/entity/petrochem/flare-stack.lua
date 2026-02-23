-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.angels and reskins.angels.triggers.petrochem.entities) then
	return
end

-- Set input parameters
local inputs = {
	type = "furnace",
	icon_name = "flare-stack",
	base_entity_name = "storage-tank",
	mod = "angels",
	group = "petrochem",
	icon_layers = 1,
	particles = { ["big"] = 1 },
	make_remnants = false,
}

-- Create light layer for working visualisation
local refinery_lights = reskins.lib.sprites.make_4way_animation_from_spritesheet({
	filename = "__reskins-angels__/graphics/entity/petrochem/flare-stack/flare-stack-light.png",
	priority = "extra-high",
	width = 142,
	height = 429,
	shift = util.by_pixel(0, -65),
	blend_mode = "additive-soft",
	draw_as_glow = true,
	scale = 0.5,
})

local name = "angels-flare-stack"

---@type data.FurnacePrototype
local entity = data.raw[inputs.type][name]

-- Check if entity exists, if not, skip this iteration
if not entity then
	return
end

reskins.lib.setup_standard_entity(name, 0, inputs)

entity.graphics_set.animation = reskins.lib.sprites.make_4way_animation_from_spritesheet({
	layers = {
		{
			filename = "__reskins-angels__/graphics/entity/petrochem/flare-stack/flare-stack.png",
			priority = "extra-high",
			width = 142,
			height = 429,
			shift = util.by_pixel(0, -65),
			scale = 0.5,
		},
		{
			filename = "__reskins-angels__/graphics/entity/petrochem/flare-stack/flare-stack-shadow.png",
			priority = "extra-high",
			width = 382,
			height = 135,
			shift = util.by_pixel(61, 10),
			draw_as_shadow = true,
			scale = 0.5,
		},
	},
})

entity.graphics_set.working_visualisations = {
	-- Flame
	{
		fadeout = true,
		constant_speed = true,
		north_position = util.by_pixel(-3, -166),
		east_position = util.by_pixel(-3, -170),
		south_position = util.by_pixel(3, -170),
		west_position = util.by_pixel(3, -166),
		animation = {
			filename = "__base__/graphics/entity/oil-refinery/oil-refinery-fire.png",
			line_length = 10,
			width = 40,
			height = 81,
			frame_count = 60,
			animation_speed = 0.75,
			draw_as_glow = true,
			scale = 0.5,
		},
	},

	-- Light
	{
		fadeout = true,
		north_animation = refinery_lights.north,
		east_animation = refinery_lights.east,
		south_animation = refinery_lights.south,
		west_animation = refinery_lights.west,
	},
}
