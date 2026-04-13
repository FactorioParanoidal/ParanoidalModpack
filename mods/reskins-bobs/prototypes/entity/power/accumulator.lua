-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.power.entities) then
	return
end
if not (reskins.bobs and reskins.bobs.triggers.power.accumulators) then
	return
end

-- Set input parameters
local inputs = {
	type = "accumulator",
	icon_name = "accumulator",
	base_entity_name = "accumulator",
	mod = "bobs",
	group = "power",
	particles = { ["medium"] = 2, ["small"] = 3 },
}

local tier_map = {
	["accumulator"] = { tier = 1, prog_tier = 2, wire = 1, letter = "H" },
	["bob-large-accumulator-2"] = { tier = 2, prog_tier = 3, wire = 1, letter = "H" },
	["bob-large-accumulator-3"] = { tier = 3, prog_tier = 4, wire = 1, letter = "H" },
	["bob-slow-accumulator"] = { tier = 1, prog_tier = 2, wire = 2, letter = "S" },
	["bob-slow-accumulator-2"] = { tier = 2, prog_tier = 3, wire = 2, letter = "S" },
	["bob-slow-accumulator-3"] = { tier = 3, prog_tier = 4, wire = 2, letter = "S" },
	["bob-fast-accumulator"] = { tier = 1, prog_tier = 2, wire = 3, letter = "F" },
	["bob-fast-accumulator-2"] = { tier = 2, prog_tier = 3, wire = 3, letter = "F" },
	["bob-fast-accumulator-3"] = { tier = 3, prog_tier = 4, wire = 3, letter = "F" },
}

local function accumulator_picture_tinted(inputs, repeat_count)
	return {
		layers = {
			-- Base
			{
				filename = "__reskins-bobs__/graphics/entity/power/accumulator/wires/accumulator-" .. inputs.wire .. ".png",
				priority = "high",
				width = 130,
				height = 189,
				repeat_count = repeat_count,
				shift = util.by_pixel(0, -11),
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/entity/power/accumulator/accumulator-mask.png",
				priority = "high",
				width = 130,
				height = 189,
				repeat_count = repeat_count,
				shift = util.by_pixel(0, -11),
				tint = inputs.tint,
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-bobs__/graphics/entity/power/accumulator/accumulator-highlights.png",
				priority = "high",
				width = 130,
				height = 189,
				repeat_count = repeat_count,
				shift = util.by_pixel(0, -11),
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				scale = 0.5,
			},
			-- Shadow
			{
				filename = "__base__/graphics/entity/accumulator/accumulator-shadow.png",
				priority = "high",
				width = 234,
				height = 106,
				repeat_count = repeat_count,
				shift = util.by_pixel(29, 6),
				draw_as_shadow = true,
				scale = 0.5,
			},
		},
	}
end

local function accumulator_charge_tinted(inputs)
	return {
		layers = {
			accumulator_picture_tinted(inputs, 24),
			{
				filename = "__base__/graphics/entity/accumulator/accumulator-charge.png",
				priority = "high",
				width = 178,
				height = 206,
				line_length = 6,
				frame_count = 24,
				draw_as_glow = true,
				shift = util.by_pixel(0, -22),
				scale = 0.5,
			},
		},
	}
end

local function accumulator_discharge_tinted(inputs)
	return {
		layers = {
			accumulator_picture_tinted(inputs, 24),
			{
				filename = "__base__/graphics/entity/accumulator/accumulator-discharge.png",
				priority = "high",
				width = 170,
				height = 210,
				line_length = 6,
				frame_count = 24,
				draw_as_glow = true,
				shift = util.by_pixel(-1, -23),
				scale = 0.5,
			},
		},
	}
end

-- Reskin entities, create and assign extra details
for name, map in pairs(tier_map) do
	---@type data.AccumulatorPrototype
	local entity = data.raw[inputs.type][name]
	if not entity then
		goto continue
	end

	local tier = reskins.lib.tiers.get_tier(map)
	inputs.wire = map.wire

	inputs.tint = reskins.lib.tiers.get_tint(tier)

	-- Setup icon base details
	inputs.icon_base = "accumulator-" .. map.wire

	-- Setup additional icon details
	inputs.icon_extras = reskins.lib.icons.get_letter(map.letter, reskins.lib.tiers.get_tint(tier))

	reskins.lib.setup_standard_entity(name, tier, inputs)

	-- Fetch remnant
	local remnant = data.raw["corpse"][name .. "-remnants"]

	-- Reskin remnants
	remnant.animation = make_rotated_animation_variations_from_sheet(1, {
		layers = {
			-- Base
			{
				filename = "__reskins-bobs__/graphics/entity/power/accumulator/remnants/wires/accumulator-" .. inputs.wire .. "-remnants.png",
				width = 172,
				height = 146,
				direction_count = 1,
				shift = util.by_pixel(2.5, 3.5),
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/entity/power/accumulator/remnants/accumulator-remnants-mask.png",
				width = 172,
				height = 146,
				direction_count = 1,
				shift = util.by_pixel(2.5, 3.5),
				tint = inputs.tint,
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-bobs__/graphics/entity/power/accumulator/remnants/accumulator-remnants-highlights.png",
				width = 172,
				height = 146,
				direction_count = 1,
				shift = util.by_pixel(2.5, 3.5),
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				scale = 0.5,
			},
		},
	})

	-- Reskin entities
	entity.chargable_graphics.picture = accumulator_picture_tinted(inputs)
	entity.chargable_graphics.charge_animation = accumulator_charge_tinted(inputs)
	entity.chargable_graphics.discharge_animation = accumulator_discharge_tinted(inputs)

	-- Remove lights
	entity.chargable_graphics.charge_light = nil
	entity.chargable_graphics.discharge_light = nil

	::continue::
end
