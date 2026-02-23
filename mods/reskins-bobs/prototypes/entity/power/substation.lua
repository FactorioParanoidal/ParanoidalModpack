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
	icon_name = "substation",
	base_entity_name = "substation",
	mod = "bobs",
	group = "power",
	particles = { ["big"] = 2 },
}

local tier_map = {
	["substation"] = { tier = 1, prog_tier = 2 },
	["bob-substation-2"] = { tier = 2, prog_tier = 3 },
	["bob-substation-3"] = { tier = 3, prog_tier = 4 },
	["bob-substation-4"] = { tier = 4, prog_tier = 5 },
}

---@param tint data.Color
---@return data.RotatedAnimation
local function get_substation_remnant_animation(tint)
	---@type data.RotatedAnimation
	local remnant_animation = {
		layers = {
			-- Base
			{
				filename = "__reskins-bobs__/graphics/entity/power/substation/base/remnants/substation-remnants.png",
				width = 182,
				height = 134,
				direction_count = 1,
				shift = util.by_pixel(2.5, 0.5),
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/entity/power/substation/remnants/substation-remnants-mask.png",
				width = 182,
				height = 134,
				direction_count = 1,
				shift = util.by_pixel(2.5, 0.5),
				tint = tint,
				scale = 0.5,
			},
			{
				filename = "__reskins-bobs__/graphics/entity/power/substation/remnants/substation-remnants-highlights.png",
				width = 182,
				height = 134,
				direction_count = 1,
				shift = util.by_pixel(2.5, 0.5),
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				scale = 0.5,
			},
		},
	}

	return remnant_animation
end

-- Reskin entities, create and assign extra details
for name, map in pairs(tier_map) do
	-- Initialize table address
	local entity = data.raw[inputs.type][name]
	if not entity then
		goto continue
	end

	local tier = reskins.lib.tiers.get_tier(map)
	inputs.tint = reskins.lib.tiers.get_tint(tier)

	reskins.lib.setup_standard_entity(name, tier, inputs)

	-- Initialize table addresses
	local remnant = data.raw["corpse"][name .. "-remnants"]

	-- Reskin remnants
	local remnant_animation = get_substation_remnant_animation(inputs.tint)
	remnant.animation = make_rotated_animation_variations_from_sheet(1, remnant_animation)

	-- Reskin entities
	entity.pictures = {
		layers = {
			-- Base
			{
				filename = "__reskins-bobs__/graphics/entity/power/substation/base/substation.png",
				priority = "high",
				width = 138,
				height = 270,
				direction_count = 4,
				shift = util.by_pixel(0, 1 - 32),
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/entity/power/substation/substation-mask.png",
				priority = "high",
				width = 138,
				height = 270,
				direction_count = 4,
				shift = util.by_pixel(0, 1 - 32),
				tint = inputs.tint,
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-bobs__/graphics/entity/power/substation/substation-highlights.png",
				priority = "high",
				width = 138,
				height = 270,
				direction_count = 4,
				shift = util.by_pixel(0, 1 - 32),
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				scale = 0.5,
			},
			-- Shadow
			{
				filename = "__reskins-bobs__/graphics/entity/power/substation/base/substation-shadow.png",
				priority = "high",
				width = 370,
				height = 104,
				direction_count = 4,
				shift = util.by_pixel(62, 42 - 32),
				draw_as_shadow = true,
				scale = 0.5,
			},
		},
	}

	::continue::
end
