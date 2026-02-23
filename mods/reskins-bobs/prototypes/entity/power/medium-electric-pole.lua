-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.power.entities) then
	return
end
if not (reskins.bobs and reskins.bobs.triggers.power.poles) then
	return
end

-- Set input parameters
local inputs = {
	type = "electric-pole",
	icon_name = "medium-electric-pole",
	base_entity_name = "medium-electric-pole",
	mod = "bobs",
	group = "power",
	particles = { ["medium-long"] = 1 },
}

local tier_map = {
	["medium-electric-pole"] = { tier = 1, prog_tier = 2 },
	["bob-medium-electric-pole-2"] = { tier = 2, prog_tier = 3 },
	["bob-medium-electric-pole-3"] = { tier = 3, prog_tier = 4 },
	["bob-medium-electric-pole-4"] = { tier = 4, prog_tier = 5 },
}

---@param tint data.Color
---@return data.RotatedAnimation
local function get_medium_electric_pole_remnant_animation(tint)
	---@type data.RotatedAnimation
	local remnant_animation = {
		layers = {
			-- Base
			{
				filename = "__base__/graphics/entity/medium-electric-pole/remnants/medium-electric-pole-base-remnants.png",
				width = 284,
				height = 140,
				direction_count = 1,
				shift = util.by_pixel(35, -5),
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/entity/power/medium-electric-pole/remnants/medium-electric-pole-base-remnants-mask.png",
				width = 284,
				height = 140,
				direction_count = 1,
				shift = util.by_pixel(35, -5),
				tint = tint,
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-bobs__/graphics/entity/power/medium-electric-pole/remnants/medium-electric-pole-base-remnants-highlights.png",
				width = 284,
				height = 140,
				direction_count = 1,
				shift = util.by_pixel(35, -5),
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				scale = 0.5,
			},
		},
	}

	return remnant_animation
end

---@param tint data.Color
---@return data.RotatedAnimation
local function get_medium_electric_pole_remnant_animation_overlay(tint)
	---@type data.RotatedAnimation
	local remnant_animation = {
		layers = {
			-- Base
			{
				filename = "__base__/graphics/entity/medium-electric-pole/remnants/medium-electric-pole-top-remnants.png",
				width = 100,
				height = 184,
				direction_count = 1,
				shift = util.by_pixel(0, -38.5),
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/entity/power/medium-electric-pole/remnants/medium-electric-pole-top-remnants-mask.png",
				width = 100,
				height = 184,
				direction_count = 1,
				shift = util.by_pixel(0, -38.5),
				tint = tint,
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-bobs__/graphics/entity/power/medium-electric-pole/remnants/medium-electric-pole-top-remnants-highlights.png",
				width = 100,
				height = 184,
				direction_count = 1,
				shift = util.by_pixel(0, -38.5),
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				scale = 0.5,
			},
		},
	}

	return remnant_animation
end

-- Reskin entities, create and assign extra details
for name, map in pairs(tier_map) do
	---@type data.ElectricPolePrototype
	local entity = data.raw[inputs.type][name]
	if not entity then
		goto continue
	end

	local tier = reskins.lib.tiers.get_tier(map)
	inputs.tint = reskins.lib.tiers.get_tint(tier)

	reskins.lib.setup_standard_entity(name, tier, inputs)

	-- Fetch remnant
	local remnant = data.raw["corpse"][name .. "-remnants"]

	-- Reskin remnants
	local remnant_animation = get_medium_electric_pole_remnant_animation(inputs.tint)
	remnant.animation = make_rotated_animation_variations_from_sheet(3, remnant_animation)

	local remnant_animation_overlay = get_medium_electric_pole_remnant_animation_overlay(inputs.tint)
	remnant.animation_overlay = make_rotated_animation_variations_from_sheet(3, remnant_animation_overlay)

	-- Reskin entities
	entity.pictures = {
		layers = {
			-- Base
			{
				filename = "__base__/graphics/entity/medium-electric-pole/medium-electric-pole.png",
				priority = "extra-high",
				width = 84,
				height = 252,
				direction_count = 4,
				shift = util.by_pixel(3.5, -44),
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/entity/power/medium-electric-pole/medium-electric-pole-mask.png",
				priority = "extra-high",
				width = 84,
				height = 252,
				direction_count = 4,
				shift = util.by_pixel(3.5, -44),
				tint = inputs.tint,
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-bobs__/graphics/entity/power/medium-electric-pole/medium-electric-pole-highlights.png",
				priority = "extra-high",
				width = 84,
				height = 252,
				direction_count = 4,
				shift = util.by_pixel(3.5, -44),
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				scale = 0.5,
			},
			-- Shadow
			{
				filename = "__base__/graphics/entity/medium-electric-pole/medium-electric-pole-shadow.png",
				priority = "extra-high",
				width = 280,
				height = 64,
				direction_count = 4,
				shift = util.by_pixel(56.5, -1),
				draw_as_shadow = true,
				scale = 0.5,
			},
		},
	}

	::continue::
end
