-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Compatibility
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["NauvisDay"] then
	return
end
if not (reskins.bobs and reskins.bobs.triggers.greenhouse.entities) then
	return
end

---@type SetupStandardEntityInputs
local inputs = {
	type = "assembling-machine",
	icon_name = "dead-greenhouse",
	base_entity_name = "lab",
	mod = "compatibility",
	group = "nauvisday",
	icon_layers = 1,
}

local entity = data.raw["assembling-machine"]["dead-greenhouse"]
if not entity then
	return
end

reskins.lib.setup_standard_entity("dead-greenhouse", 0, inputs)

local dead_greenhouse_base = reskins.lib.sprites.make_4way_animation_from_spritesheet({
	filename = "__reskins-compatibility__/graphics/entity/nauvisday/dead-greenhouse/dead-greenhouse-base.png",
	width = 194,
	height = 192,
	shift = util.by_pixel(0, 0),
	scale = 0.5,
})

local dead_greenhouse_integration_patch = {
	filename = "__base__/graphics/entity/lab/lab-integration.png",
	width = 242,
	height = 162,
	shift = util.by_pixel(0, 15.5),
	scale = 0.5,
}

local dead_greenhouse_shadow = {
	filename = "__base__/graphics/entity/lab/lab-shadow.png",
	width = 242,
	height = 136,
	shift = util.by_pixel(13, 11),
	scale = 0.5,
	draw_as_shadow = true,
}

-- Reskin the entity
entity.graphics_set.animation = {
	north = {
		layers = {
			dead_greenhouse_base.north,
			dead_greenhouse_integration_patch,
			dead_greenhouse_shadow,
		},
	},
	east = {
		layers = {
			dead_greenhouse_base.east,
			dead_greenhouse_integration_patch,
			dead_greenhouse_shadow,
		},
	},
	south = {
		layers = {
			dead_greenhouse_base.south,
			dead_greenhouse_integration_patch,
			dead_greenhouse_shadow,
		},
	},
	west = {
		layers = {
			dead_greenhouse_base.west,
			dead_greenhouse_integration_patch,
			dead_greenhouse_shadow,
		},
	},
}

entity.graphics_set.idle_animation = nil

local dead_greenhouse_working = reskins.lib.sprites.make_4way_animation_from_spritesheet({
	layers = {
		-- Light Underlayer
		{
			filename = "__reskins-compatibility__/graphics/entity/nauvisday/dead-greenhouse/dead-greenhouse-lit.png",
			width = 194,
			height = 192,
			shift = util.by_pixel(0, 0),
			scale = 0.5,
		},
		-- Light
		{
			filename = "__reskins-compatibility__/graphics/entity/nauvisday/dead-greenhouse/dead-greenhouse-light.png",
			width = 194,
			height = 192,
			shift = util.by_pixel(0, 0),
			draw_as_light = true,
			scale = 0.5,
		},
	},
})

entity.graphics_set.working_visualisations = {
	{
		fadeout = true,
		north_animation = dead_greenhouse_working.north,
		east_animation = dead_greenhouse_working.east,
		west_animation = dead_greenhouse_working.west,
		south_animation = dead_greenhouse_working.south,
	},

	-- Pipe shadow fixes
	{
		always_draw = true,
		north_animation = reskins.lib.sprites.pipes.get_vertical_pipe_shadow({ 0, -1 }),
		south_animation = reskins.lib.sprites.pipes.get_vertical_pipe_shadow({ 0, 1 }),
	},
}

entity.fluid_boxes[1].pipe_picture = nil
entity.fluid_boxes[1].secondary_draw_orders = { east = 3, west = 3, south = 3 }

-- Disable burner energy source light
entity.energy_source.light_flicker = {
	color = { 0, 0, 0 },
	minimum_light_size = 0,
	light_intensity_to_size_coefficient = 0,
}
