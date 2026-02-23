-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.power.entities) then
	return
end
if not (reskins.bobs and reskins.bobs.triggers.power.fluidgenerator) then
	return
end

-- Set input parameters
local inputs = {
	type = "generator",
	icon_name = "fluid-generator",
	base_entity_name = "steam-turbine",
	mod = "bobs",
	group = "power",
	particles = { ["medium"] = 2, ["big"] = 1 },
	make_remnants = false,
}

-- Determine which tint we're using for the bob-hydrazine-generator
if reskins.lib.settings.get_value("reskins-bobs-hydrazine-is-blue") == true then
	reskins.bobs.hydrazine_tint = util.color("#7ac1de")
else
	reskins.bobs.hydrazine_tint = nil
end

local fluid_generators = {
	["bob-fluid-generator"] = { tier = 1, prog_tier = 2, frequency = 2 / 16 },
	["bob-fluid-generator-2"] = { tier = 2, prog_tier = 3, frequency = 3 / 16 },
	["bob-fluid-generator-3"] = { tier = 3, prog_tier = 4, frequency = 4 / 16 },
	["bob-hydrazine-generator"] = { tier = 4, prog_tier = 5, frequency = 5 / 16, tint = reskins.bobs.hydrazine_tint },
}

local function setup_fluid_generator(tint)
	return {
		layers = {
			-- Base
			{
				filename = "__reskins-bobs__/graphics/entity/power/fluid-generator/fluid-generator-base.png",
				width = 202,
				height = 260,
				frame_count = 8,
				line_length = 4,
				shift = util.by_pixel(2.5, -11),
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/entity/power/fluid-generator/fluid-generator-mask.png",
				width = 202,
				height = 260,
				repeat_count = 8,
				tint = tint,
				shift = util.by_pixel(2.5, -11),
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-bobs__/graphics/entity/power/fluid-generator/fluid-generator-highlights.png",
				width = 202,
				height = 260,
				repeat_count = 8,
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				shift = util.by_pixel(2.5, -11),
				scale = 0.5,
			},
			-- Shadow
			{
				filename = "__reskins-bobs__/graphics/entity/power/fluid-generator/fluid-generator-shadow.png",
				width = 324,
				height = 260,
				repeat_count = 8,
				draw_as_shadow = true,
				shift = util.by_pixel(33, -11),
				scale = 0.5,
			},
		},
	}
end

-- Reskin entities, create and assign extra details
for name, map in pairs(fluid_generators) do
	---@type data.GeneratorPrototype
	local entity = data.raw[inputs.type][name]
	if not entity then
		goto continue
	end

	local tier = reskins.lib.tiers.get_tier(map)
	inputs.tint = map.tint or reskins.lib.tiers.get_tint(tier)

	reskins.lib.setup_standard_entity(name, tier, inputs)

	-- Reskin entities
	entity.horizontal_animation = setup_fluid_generator(inputs.tint)
	entity.vertical_animation = setup_fluid_generator(inputs.tint)

	-- Handle smoke
	if name == "bob-hydrazine-generator" then
		entity.smoke = {
			{
				name = "light-smoke",
				north_position = util.by_pixel(-30, -44),
				east_position = util.by_pixel(-30, -44),
				frequency = map.frequency,
				starting_vertical_speed = 0.08,
				starting_frame_deviation = 60,
			},
		}
	else
		entity.smoke = {
			{
				name = "smoke",
				north_position = util.by_pixel(-30, -44),
				east_position = util.by_pixel(-30, -44),
				frequency = map.frequency,
				starting_vertical_speed = 0.08,
				starting_frame_deviation = 60,
			},
		}
	end

	entity.water_reflection = {
		pictures = {
			filename = "__reskins-bobs__/graphics/entity/power/fluid-generator/fluid-generator-reflection.png",
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

	::continue::
end
