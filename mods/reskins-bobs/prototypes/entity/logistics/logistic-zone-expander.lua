-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.logistics.entities) then
	return
end

-- Set input parameters
local inputs = {
	type = "roboport",
	icon_name = "zone-expander",
	base_entity_name = "roboport",
	mod = "bobs",
	group = "logistics",
	particles = { ["medium"] = 2 },
	make_remnants = false,
}

local tier_map = {
	["bob-logistic-zone-expander"] = { tier = 1, prog_tier = 2, image_index = 1 },
	["bob-logistic-zone-expander-2"] = { tier = 2, prog_tier = 3, image_index = 2 },
	["bob-logistic-zone-expander-3"] = { tier = 3, prog_tier = 4, image_index = 3 },
	["bob-logistic-zone-expander-4"] = { tier = 4, prog_tier = 5, image_index = 4 },
}

-- Reskin entities, create and assign extra details
for name, map in pairs(tier_map) do
	---@type data.RoboportPrototype
	local entity = data.raw[inputs.type][name]
	if not entity then
		goto continue
	end

	local tier = reskins.lib.tiers.get_tier(map)

	-- Setup icon details
	inputs.icon_base = "zone-expander-" .. map.image_index
	inputs.tint = reskins.lib.tiers.get_tint(tier)

	reskins.lib.setup_standard_entity(name, tier, inputs)

	-- Reskin entities
	entity.base = {
		layers = {
			-- Base
			{
				filename = "__reskins-bobs__/graphics/entity/logistics/zone-expander/zone-expander-" .. map.image_index .. "-base.png",
				width = 56,
				height = 156,
				shift = util.by_pixel(0.5, -29.5),
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/entity/logistics/zone-expander/zone-expander-mask.png",
				width = 38,
				height = 30,
				shift = util.by_pixel(0.5, 0),
				tint = inputs.tint,
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-bobs__/graphics/entity/logistics/zone-expander/zone-expander-highlights.png",
				width = 38,
				height = 30,
				shift = util.by_pixel(0.5, 0),
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				scale = 0.5,
			},
		},
	}

	entity.base_animation = {
		layers = {
			-- Antenna
			{
				filename = "__reskins-bobs__/graphics/entity/logistics/roboport/base/antennas/roboport-" .. map.image_index .. "-base-animation.png",
				priority = "medium",
				width = 83,
				height = 59,
				frame_count = 8,
				animation_speed = 0.5,
				shift = util.by_pixel(0.25, -66),
				scale = 0.5,
			},
			-- Shadow
			{
				filename = "__reskins-bobs__/graphics/entity/logistics/zone-expander/zone-expander-shadow.png",
				width = 228,
				height = 60,
				frame_count = 8,
				shift = util.by_pixel(44.5, -1.5),
				draw_as_shadow = true,
				scale = 0.5,
			},
		},
	}

	entity.water_reflection = {
		pictures = {
			filename = "__reskins-bobs__/graphics/entity/logistics/zone-expander/zone-expander-reflection.png",
			priority = "extra-high",
			width = 12,
			height = 23,
			shift = util.by_pixel(0, 45),
			variation_count = 1,
			scale = 5,
		},
		rotate = false,
		orientation_to_variation = false,
	}

	::continue::
end
