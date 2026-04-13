-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.greenhouse.entities) then
	return
end

-- Set input parameters
local inputs = {
	type = "assembling-machine",
	icon_name = "greenhouse",
	base_entity_name = "lab",
	mod = "bobs",
	group = "greenhouse",
	icon_layers = 1,
}

---@type data.AssemblingMachinePrototype
local entity = data.raw[inputs.type]["bob-greenhouse"]

-- Check if entity exists, if not, return
if not entity then
	return
end

reskins.lib.setup_standard_entity("bob-greenhouse", 0, inputs)

local greenhouse_base = reskins.lib.sprites.make_4way_animation_from_spritesheet({
	filename = "__reskins-bobs__/graphics/entity/greenhouse/greenhouse-base.png",
	width = 194,
	height = 192,
	shift = util.by_pixel(0, 0),
	scale = 0.5,
})

local greenhouse_integration_patch = {
	filename = "__base__/graphics/entity/lab/lab-integration.png",
	width = 242,
	height = 162,
	shift = util.by_pixel(0, 15.5),
	scale = 0.5,
}

local greenhouse_shadow = {
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
			greenhouse_base.north,
			greenhouse_integration_patch,
			greenhouse_shadow,
		},
	},
	east = {
		layers = {
			greenhouse_base.east,
			greenhouse_integration_patch,
			greenhouse_shadow,
		},
	},
	south = {
		layers = {
			greenhouse_base.south,
			greenhouse_integration_patch,
			greenhouse_shadow,
		},
	},
	west = {
		layers = {
			greenhouse_base.west,
			greenhouse_integration_patch,
			greenhouse_shadow,
		},
	},
}

entity.graphics_set.idle_animation = nil

local greenhouse_working = reskins.lib.sprites.make_4way_animation_from_spritesheet({
	layers = {
		-- Light Underlayer
		{
			filename = "__reskins-bobs__/graphics/entity/greenhouse/greenhouse-lit.png",
			width = 194,
			height = 192,
			shift = util.by_pixel(0, 0),
			scale = 0.5,
		},
		-- Light
		{
			filename = "__reskins-bobs__/graphics/entity/greenhouse/greenhouse-light.png",
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
		north_animation = greenhouse_working.north,
		east_animation = greenhouse_working.east,
		west_animation = greenhouse_working.west,
		south_animation = greenhouse_working.south,
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
