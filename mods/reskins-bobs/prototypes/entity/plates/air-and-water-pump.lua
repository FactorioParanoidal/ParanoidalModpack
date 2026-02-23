-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.plates.entities) then
	return
end

-- Set input parameters
local inputs = {
	type = "assembling-machine",
	base_entity_name = "chemical-plant",
	mod = "bobs",
	group = "plates",
	particles = { ["big"] = 1, ["medium"] = 2 },
	make_remnants = false,
}

local tier_map = {
	["bob-water-pump"] = { tier = 1, prog_tier = 2, pump_type = "water" },
	["bob-water-pump-2"] = { tier = 2, prog_tier = 3, pump_type = "water" },
	["bob-water-pump-3"] = { tier = 3, prog_tier = 4, pump_type = "water" },
	["bob-water-pump-4"] = { tier = 4, prog_tier = 5, pump_type = "water" },
	["bob-air-pump"] = { tier = 1, prog_tier = 2, pump_type = "air" },
	["bob-air-pump-2"] = { tier = 2, prog_tier = 3, pump_type = "air" },
	["bob-air-pump-3"] = { tier = 3, prog_tier = 4, pump_type = "air" },
	["bob-air-pump-4"] = { tier = 4, prog_tier = 5, pump_type = "air" },
}

local function generate_recipe_mask(pump_type, layer, blend_mode)
	local recipe_mask = reskins.lib.sprites.make_4way_animation_from_spritesheet({
		filename = "__reskins-bobs__/graphics/entity/plates/" .. pump_type .. "-pump/" .. pump_type .. "-pump-recipe-" .. layer .. ".png",
		width = 128,
		height = 176,
		shift = util.by_pixel(0, -12),
		blend_mode = blend_mode,
		scale = 0.5,
	})
	return recipe_mask
end

-- Generate water and air pump working visualisation tables
local recipe_tint_mask = {
	["water"] = generate_recipe_mask("water", "tint-mask"),
	["air"] = generate_recipe_mask("air", "tint-mask"),
}

local recipe_ligtening_mask = {
	["water"] = generate_recipe_mask("water", "lightening-mask"),
	["air"] = generate_recipe_mask("air", "lightening-mask"),
}

local recipe_tint_highlights = generate_recipe_mask("water", "tint-highlights", "additive")

-- Reskin entities, create and assign extra details
for name, map in pairs(tier_map) do
	---@type data.AssemblingMachinePrototype
	local entity = data.raw[inputs.type][name]
	if not entity then
		goto continue
	end

	local tier = reskins.lib.tiers.get_tier(map)
	inputs.tint = reskins.lib.tiers.get_tint(tier)

	-- Icon handling
	inputs.icon_name = map.pump_type .. "-pump"

	reskins.lib.setup_standard_entity(name, tier, inputs)

	-- Reskin entities
	entity.corpse = "medium-remnants"
	entity.match_animation_speed_to_activity = false
	entity.graphics_set.animation = reskins.lib.sprites.make_4way_animation_from_spritesheet({
		layers = {
			-- Base
			{
				filename = "__reskins-bobs__/graphics/entity/plates/" .. map.pump_type .. "-pump/" .. map.pump_type .. "-pump-base.png",
				width = 148,
				height = 186,
				frame_count = 4,
				line_length = 4,
				frame_sequence = { 1, 2, 3, 4, 3, 2, 1 },
				animation_speed = 0.5,
				shift = util.by_pixel(0, -9.5),
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/entity/plates/" .. map.pump_type .. "-pump/" .. map.pump_type .. "-pump-mask.png",
				width = 148,
				height = 186,
				frame_count = 4,
				line_length = 4,
				frame_sequence = { 1, 2, 3, 4, 3, 2, 1 },
				animation_speed = 0.5,
				shift = util.by_pixel(0, -9.5),
				tint = inputs.tint,
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-bobs__/graphics/entity/plates/" .. map.pump_type .. "-pump/" .. map.pump_type .. "-pump-highlights.png",
				width = 148,
				height = 186,
				frame_count = 4,
				line_length = 4,
				frame_sequence = { 1, 2, 3, 4, 3, 2, 1 },
				animation_speed = 0.5,
				shift = util.by_pixel(0, -9.5),
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				scale = 0.5,
			},
			-- Shadow
			{
				filename = "__reskins-bobs__/graphics/entity/plates/" .. map.pump_type .. "-pump/" .. map.pump_type .. "-pump-shadow.png",
				width = 172,
				height = 134,
				frame_count = 4,
				line_length = 4,
				frame_sequence = { 1, 2, 3, 4, 3, 2, 1 },
				animation_speed = 0.5,
				shift = util.by_pixel(11, 1.5),
				draw_as_shadow = true,
				scale = 0.5,
			},
		},
	})

	entity.graphics_set.working_visualisations = {
		-- Recipe Tint Mask
		{
			apply_recipe_tint = "primary",
			always_draw = true,
			north_animation = recipe_tint_mask[map.pump_type].north,
			east_animation = recipe_tint_mask[map.pump_type].east,
			south_animation = recipe_tint_mask[map.pump_type].south,
			west_animation = recipe_tint_mask[map.pump_type].west,
		},
		-- Recipe Lightening Mask
		{
			always_draw = true,
			north_animation = recipe_ligtening_mask[map.pump_type].north,
			east_animation = recipe_ligtening_mask[map.pump_type].east,
			south_animation = recipe_ligtening_mask[map.pump_type].south,
			west_animation = recipe_ligtening_mask[map.pump_type].west,
		},
		-- Light
		{
			always_draw = true,
			west_animation = {
				filename = "__reskins-bobs__/graphics/entity/plates/air-pump/pump-light.png",
				width = 148,
				height = 186,
				shift = util.by_pixel(0, -9.5),
				draw_as_light = true,
				scale = 0.5,
			},
		},
	}

	-- The fluid flow is directional, a mirrored graphics set is required, but is basically just the original graphics
	-- set with north/south and east/west swapped.
	entity.graphics_set_flipped = {
		animation = {
			north = entity.graphics_set.animation.south,
			east = entity.graphics_set.animation.west,
			south = entity.graphics_set.animation.north,
			west = entity.graphics_set.animation.east,
		},
		working_visualisations = {
			-- Recipe Tint Mask
			{
				apply_recipe_tint = "primary",
				always_draw = true,
				north_animation = recipe_tint_mask[map.pump_type].south,
				east_animation = recipe_tint_mask[map.pump_type].west,
				south_animation = recipe_tint_mask[map.pump_type].north,
				west_animation = recipe_tint_mask[map.pump_type].east,
			},
			-- Recipe Lightening Mask
			{
				always_draw = true,
				north_animation = recipe_ligtening_mask[map.pump_type].south,
				east_animation = recipe_ligtening_mask[map.pump_type].west,
				south_animation = recipe_ligtening_mask[map.pump_type].north,
				west_animation = recipe_ligtening_mask[map.pump_type].east,
			},
			-- Light
			{
				always_draw = true,
				east_animation = {
					filename = "__reskins-bobs__/graphics/entity/plates/air-pump/pump-light.png",
					width = 148,
					height = 186,
					shift = util.by_pixel(0, -9.5),
					draw_as_light = true,
					scale = 0.5,
				},
			},
		},
	}

	if map.pump_type == "water" then
		table.insert(entity.graphics_set.working_visualisations, {
			apply_recipe_tint = "primary",
			always_draw = true,
			north_animation = recipe_tint_highlights.north,
			east_animation = recipe_tint_highlights.east,
			south_animation = recipe_tint_highlights.south,
			west_animation = recipe_tint_highlights.west,
		})

		table.insert(entity.graphics_set_flipped.working_visualisations, {
			apply_recipe_tint = "primary",
			always_draw = true,
			north_animation = recipe_tint_highlights.south,
			east_animation = recipe_tint_highlights.west,
			south_animation = recipe_tint_highlights.north,
			west_animation = recipe_tint_highlights.east,
		})
	end

	entity.water_reflection = {
		pictures = {
			filename = "__reskins-bobs__/graphics/entity/plates/" .. map.pump_type .. "-pump/" .. map.pump_type .. "-pump-reflection.png",
			priority = "extra-high",
			width = 28,
			height = 36,
			shift = util.by_pixel(10 / 3, 40),
			variation_count = 4,
			scale = 10 / 3,
		},
		rotate = false,
		orientation_to_variation = true,
	}

	::continue::
end
