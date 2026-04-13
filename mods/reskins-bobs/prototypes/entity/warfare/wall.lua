-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.warfare.entities) then
	return
end

-- Make sure the wall exists
local entity_name = "bob-reinforced-wall"
local entity = data.raw["wall"][entity_name]
if not entity then
	return
end

-- Set input parameters
local inputs = {
	type = "wall",
	base_entity_name = "wall",
	mod = "bobs",
	particles = { ["tiny-stone"] = 3, ["small-stone"] = 2, ["medium-stone"] = 1 },
}

if mods["NauvisDay"] then
	inputs.make_explosions = false
end

inputs.icon_filename = "__reskins-bobs__/graphics/icons/warfare/reinforced-wall/wall.png"

local reinforced_tint_index = {
	["tiny-stone"] = util.color("#a793bf"),
	["small-stone"] = util.color("#a793bf"),
	["medium-stone"] = util.color("#9584ab"),
}

-- Parse inputs
reskins.lib.set_inputs_defaults(inputs)

if inputs.make_explosions then
	-- Create particles and explosions
	reskins.lib.create_explosion(entity_name, inputs)

	for particle, key in pairs(inputs.particles) do
		reskins.lib.create_particle(entity_name, inputs.base_entity_name, reskins.lib.particle_index[particle], key, reinforced_tint_index[particle])
	end
end

-- Create remnants
reskins.lib.create_remnant(entity_name, inputs)

-- Create icons
reskins.lib.construct_icon(entity_name, 0, inputs)

-- Reskin the gate
local remnant = data.raw["corpse"][entity_name .. "-remnants"]

-- Reskin remnants
remnant.animation = make_rotated_animation_variations_from_sheet(4, {
	filename = "__reskins-bobs__/graphics/entity/warfare/reinforced-wall/remnants/reinforced-wall-remnants.png",
	width = 118,
	height = 114,
	direction_count = 2,
	shift = util.by_pixel(3, 7.5),
	scale = 0.5,
})

-- Reskin entity
entity.pictures = {
	single = {
		layers = {
			{
				filename = "__reskins-bobs__/graphics/entity/warfare/reinforced-wall/reinforced-wall-single.png",
				priority = "extra-high",
				width = 64,
				height = 86,
				variation_count = 2,
				line_length = 2,
				shift = util.by_pixel(0, -5),
				scale = 0.5,
			},
			{
				filename = "__reskins-bobs__/graphics/entity/warfare/reinforced-wall/shadows/reinforced-wall-single-shadow.png",
				priority = "extra-high",
				width = 98,
				height = 60,
				repeat_count = 2,
				shift = util.by_pixel(10, 17),
				draw_as_shadow = true,
				scale = 0.5,
			},
		},
	},
	straight_vertical = {
		layers = {
			{
				filename = "__reskins-bobs__/graphics/entity/warfare/reinforced-wall/reinforced-wall-vertical.png",
				priority = "extra-high",
				width = 64,
				height = 134,
				variation_count = 5,
				line_length = 5,
				shift = util.by_pixel(0, 8),
				scale = 0.5,
			},
			{
				filename = "__reskins-bobs__/graphics/entity/warfare/reinforced-wall/shadows/reinforced-wall-vertical-shadow.png",
				priority = "extra-high",
				width = 98,
				height = 110,
				repeat_count = 5,
				shift = util.by_pixel(10, 29),
				draw_as_shadow = true,
				scale = 0.5,
			},
		},
	},
	straight_horizontal = {
		layers = {
			{
				filename = "__reskins-bobs__/graphics/entity/warfare/reinforced-wall/reinforced-wall-horizontal.png",
				priority = "extra-high",
				width = 64,
				height = 92,
				variation_count = 6,
				line_length = 6,
				shift = util.by_pixel(0, -2),
				scale = 0.5,
			},
			{
				filename = "__reskins-bobs__/graphics/entity/warfare/reinforced-wall/shadows/reinforced-wall-horizontal-shadow.png",
				priority = "extra-high",
				width = 124,
				height = 68,
				repeat_count = 6,
				shift = util.by_pixel(14, 15),
				draw_as_shadow = true,
				scale = 0.5,
			},
		},
	},
	corner_right_down = {
		layers = {
			{
				filename = "__reskins-bobs__/graphics/entity/warfare/reinforced-wall/reinforced-wall-corner-right.png",
				priority = "extra-high",
				width = 64,
				height = 128,
				variation_count = 2,
				line_length = 2,
				shift = util.by_pixel(0, 7),
				scale = 0.5,
			},
			{
				filename = "__reskins-bobs__/graphics/entity/warfare/reinforced-wall/shadows/reinforced-wall-corner-right-shadow.png",
				priority = "extra-high",
				width = 124,
				height = 120,
				repeat_count = 2,
				shift = util.by_pixel(17, 28),
				draw_as_shadow = true,
				scale = 0.5,
			},
		},
	},
	corner_left_down = {
		layers = {
			{
				filename = "__reskins-bobs__/graphics/entity/warfare/reinforced-wall/reinforced-wall-corner-left.png",
				priority = "extra-high",
				width = 64,
				height = 134,
				variation_count = 2,
				line_length = 2,
				shift = util.by_pixel(0, 7),
				scale = 0.5,
			},
			{
				filename = "__reskins-bobs__/graphics/entity/warfare/reinforced-wall/shadows/reinforced-wall-corner-left-shadow.png",
				priority = "extra-high",
				width = 102,
				height = 120,
				repeat_count = 2,
				shift = util.by_pixel(9, 28),
				draw_as_shadow = true,
				scale = 0.5,
			},
		},
	},
	t_up = {
		layers = {
			{
				filename = "__reskins-bobs__/graphics/entity/warfare/reinforced-wall/reinforced-wall-t.png",
				priority = "extra-high",
				width = 64,
				height = 134,
				variation_count = 4,
				line_length = 4,
				shift = util.by_pixel(0, 7),
				scale = 0.5,
			},
			{
				filename = "__reskins-bobs__/graphics/entity/warfare/reinforced-wall/shadows/reinforced-wall-t-shadow.png",
				priority = "extra-high",
				width = 124,
				height = 120,
				repeat_count = 4,
				shift = util.by_pixel(14, 28),
				draw_as_shadow = true,
				scale = 0.5,
			},
		},
	},
	ending_right = {
		layers = {
			{
				filename = "__reskins-bobs__/graphics/entity/warfare/reinforced-wall/reinforced-wall-ending-right.png",
				priority = "extra-high",
				width = 64,
				height = 92,
				variation_count = 2,
				line_length = 2,
				shift = util.by_pixel(0, -3),
				scale = 0.5,
			},
			{
				filename = "__reskins-bobs__/graphics/entity/warfare/reinforced-wall/shadows/reinforced-wall-ending-right-shadow.png",
				priority = "extra-high",
				width = 124,
				height = 68,
				repeat_count = 2,
				shift = util.by_pixel(17, 15),
				draw_as_shadow = true,
				scale = 0.5,
			},
		},
	},
	ending_left = {
		layers = {
			{
				filename = "__reskins-bobs__/graphics/entity/warfare/reinforced-wall/reinforced-wall-ending-left.png",
				priority = "extra-high",
				width = 64,
				height = 92,
				variation_count = 2,
				line_length = 2,
				shift = util.by_pixel(0, -3),
				scale = 0.5,
			},
			{
				filename = "__reskins-bobs__/graphics/entity/warfare/reinforced-wall/shadows/reinforced-wall-ending-left-shadow.png",
				priority = "extra-high",
				width = 102,
				height = 68,
				repeat_count = 2,
				shift = util.by_pixel(9, 15),
				draw_as_shadow = true,
				scale = 0.5,
			},
		},
	},
	filling = {
		filename = "__reskins-bobs__/graphics/entity/warfare/reinforced-wall/reinforced-wall-filling.png",
		priority = "extra-high",
		width = 48,
		height = 56,
		variation_count = 8,
		line_length = 8,
		shift = util.by_pixel(0, -1),
		scale = 0.5,
	},
	water_connection_patch = {
		sheets = {
			{
				filename = "__reskins-bobs__/graphics/entity/warfare/reinforced-wall/reinforced-wall-patch.png",
				priority = "extra-high",
				width = 116,
				height = 128,
				shift = util.by_pixel(0, -2),
				scale = 0.5,
			},
			{
				filename = "__reskins-bobs__/graphics/entity/warfare/reinforced-wall/shadows/reinforced-wall-patch-shadow.png",
				priority = "extra-high",
				width = 144,
				height = 100,
				shift = util.by_pixel(9, 15),
				draw_as_shadow = true,
				scale = 0.5,
			},
		},
	},
	gate_connection_patch = {
		sheets = {
			{
				filename = "__reskins-bobs__/graphics/entity/warfare/reinforced-wall/reinforced-wall-gate.png",
				priority = "extra-high",
				width = 82,
				height = 108,
				shift = util.by_pixel(0, -7),
				scale = 0.5,
			},
			{
				filename = "__reskins-bobs__/graphics/entity/warfare/reinforced-wall/shadows/reinforced-wall-gate-shadow.png",
				priority = "extra-high",
				width = 130,
				height = 78,
				shift = util.by_pixel(14, 18),
				draw_as_shadow = true,
				scale = 0.5,
			},
		},
	},
}
