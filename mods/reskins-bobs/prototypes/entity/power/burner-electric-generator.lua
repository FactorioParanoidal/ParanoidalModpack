-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.power.entities) then
	return
end

local inputs = {
	type = "burner-generator",
	icon_name = "burner-electric-generator",
	base_entity_name = "steam-engine",
	mod = "bobs",
	group = "power",
	particles = { ["medium"] = 2, ["big"] = 1 },
	tint = util.color("#26262660"),
	make_remnants = false,
}

inputs.icon_filename = "__reskins-bobs__/graphics/icons/power/burner-electric-generator/burner-electric-generator.png"

local name = "bob-burner-generator"

---@type data.BurnerGeneratorPrototype
local entity = data.raw[inputs.type][name]
if not entity then
	return
end

reskins.lib.setup_standard_entity(name, 0, inputs)

entity.animation = {
	layers = {
		-- Base
		{
			filename = "__reskins-bobs__/graphics/entity/power/burner-electric-generator/burner-electric-generator.png",
			width = 212,
			height = 272,
			frame_count = 32,
			line_length = 8,
			repeat_count = 3,
			shift = util.by_pixel(0, -12.5),
			scale = 0.5,
		},
		-- Fire
		{
			filename = "__reskins-bobs__/graphics/entity/power/burner-electric-generator/burner-electric-generator-fire.png",
			priority = "high",
			line_length = 8,
			width = 58,
			height = 82,
			frame_count = 48,
			repeat_count = 2,
			blend_mode = "additive",
			shift = util.by_pixel(-1, 9.5),
			draw_as_glow = true,
			scale = 0.5,
		},
		-- Radiant Light
		{
			filename = "__reskins-bobs__/graphics/entity/power/burner-electric-generator/burner-electric-generator-working-light-animated.png",
			width = 212,
			height = 272,
			frame_count = 32,
			line_length = 8,
			repeat_count = 3,
			blend_mode = "additive",
			shift = util.by_pixel(0, -12.5),
			draw_as_glow = true,
			scale = 0.5,
		},
		-- Shadow
		{
			filename = "__reskins-bobs__/graphics/entity/power/burner-electric-generator/burner-electric-generator-shadow.png",
			width = 288,
			height = 170,
			frame_count = 32,
			line_length = 8,
			repeat_count = 3,
			draw_as_shadow = true,
			shift = util.by_pixel(30, 12),
			scale = 0.5,
		},
	},
}

entity.idle_animation = {
	layers = {
		-- Base
		{
			filename = "__reskins-bobs__/graphics/entity/power/burner-electric-generator/burner-electric-generator.png",
			width = 212,
			height = 272,
			frame_count = 32,
			line_length = 8,
			repeat_count = 3,
			shift = util.by_pixel(0, -12.5),
			scale = 0.5,
		},
		-- Shadow
		{
			filename = "__reskins-bobs__/graphics/entity/power/burner-electric-generator/burner-electric-generator-shadow.png",
			width = 288,
			height = 170,
			frame_count = 32,
			line_length = 8,
			repeat_count = 3,
			draw_as_shadow = true,
			shift = util.by_pixel(30, 12),
			scale = 0.5,
		},
	},
}

-- Handle smoke
entity.burner.smoke = {
	{
		name = "smoke",
		north_position = util.by_pixel(72 / 2, -141 / 2),
		east_position = util.by_pixel(72 / 2, -141 / 2),
		south_position = util.by_pixel(72 / 2, -141 / 2),
		west_position = util.by_pixel(72 / 2, -141 / 2),
		frequency = 15,
		starting_vertical_speed = 0.08,
		starting_frame_deviation = 60,
	},
}

entity.water_reflection = {
	pictures = {
		filename = "__reskins-bobs__/graphics/entity/power/burner-electric-generator/burner-electric-generator-reflection.png",
		priority = "extra-high",
		width = 28,
		height = 36,
		shift = util.by_pixel(5, 60),
		variation_count = 1,
		scale = 5,
	},
	rotate = false,
	orientation_to_variation = false,
}

-- Handle ambient-light
entity.burner.light_flicker = {
	color = { 0, 0, 0 },
	minimum_light_size = 0,
	light_intensity_to_size_coefficient = 0,
}
