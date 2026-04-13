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
	icon_name = "roboport",
	base_entity_name = "roboport",
	mod = "bobs",
	group = "logistics",
	particles = { ["medium"] = 2 },
}

local tier_map = {
	["roboport"] = { tier = 1, prog_tier = 2, image_index = 1 },
	["bob-roboport-2"] = { tier = 2, prog_tier = 3, image_index = 2 },
	["bob-roboport-3"] = { tier = 3, prog_tier = 4, image_index = 3 },
	["bob-roboport-4"] = { tier = 4, prog_tier = 5, image_index = 4 },
}

-- Reskin entities, create and assign extra details
for name, map in pairs(tier_map) do
	---@type data.RoboportPrototype
	local entity = data.raw[inputs.type][name]
	if not entity then
		goto continue
	end

	local tier = reskins.lib.tiers.get_tier(map)
	inputs.tint = reskins.lib.tiers.get_tint(tier)

	-- Setup icon details
	inputs.icon_base = "roboport-" .. map.image_index

	reskins.lib.setup_standard_entity(name, tier, inputs)

	-- Fetch remnant
	local remnant = data.raw["corpse"][name .. "-remnants"]

	-- Reskin remnants
	remnant.animation = make_rotated_animation_variations_from_sheet(2, {
		layers = {
			-- Base
			{
				filename = "__reskins-bobs__/graphics/entity/logistics/roboport/base/remnants/roboport-remnants.png",
				width = 364,
				height = 358,
				direction_count = 1,
				shift = util.by_pixel(2, 8),
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/entity/logistics/roboport/remnants/roboport-remnants-mask.png",
				width = 364,
				height = 358,
				direction_count = 1,
				shift = util.by_pixel(2, 8),
				tint = inputs.tint,
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-bobs__/graphics/entity/logistics/roboport/remnants/roboport-remnants-highlights.png",
				width = 364,
				height = 358,
				direction_count = 1,
				shift = util.by_pixel(2, 8),
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				scale = 0.5,
			},
			-- Antenna
			{
				filename = "__reskins-bobs__/graphics/entity/logistics/roboport/base/remnants/antennas/roboport-" .. map.image_index .. "-antenna-remnants.png",
				width = 364,
				height = 358,
				direction_count = 1,
				shift = util.by_pixel(2, 8),
				scale = 0.5,
			},
			-- Door
			{
				filename = "__reskins-bobs__/graphics/entity/logistics/roboport/base/remnants/doors/roboport-" .. map.image_index .. "-door-remnants.png",
				width = 364,
				height = 358,
				direction_count = 1,
				shift = util.by_pixel(2, 8),
				scale = 0.5,
			},
		},
	})

	-- Reskin entities
	entity.spawn_and_station_height = -0.1
	entity.base = {
		layers = {
			-- Base
			{
				filename = "__reskins-bobs__/graphics/entity/logistics/roboport/base/roboport-base.png",
				width = 228,
				height = 277,
				shift = util.by_pixel(2, 7.75),
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/entity/logistics/roboport/roboport-base-mask.png",
				width = 228,
				height = 277,
				shift = util.by_pixel(2, 7.75),
				tint = inputs.tint,
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-bobs__/graphics/entity/logistics/roboport/roboport-base-highlights.png",
				width = 228,
				height = 277,
				shift = util.by_pixel(2, 7.75),
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				scale = 0.5,
			},
			-- Shadow
			{
				filename = "__reskins-bobs__/graphics/entity/logistics/roboport/base/roboport-shadow.png",
				width = 294,
				height = 201,
				draw_as_shadow = true,
				shift = util.by_pixel(28.5, 19.25),
				scale = 0.5,
			},
		},
	}

	entity.base_patch = {
		layers = {
			-- Padding
			{
				filename = "__reskins-bobs__/graphics/empty.png",
				priority = "medium",
				width = 1,
				height = 1,
			},
			-- Base
			{
				filename = "__reskins-bobs__/graphics/entity/logistics/roboport/base/roboport-base-patch.png",
				priority = "medium",
				width = 138,
				height = 100,
				shift = util.by_pixel(1.5, 5),
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/entity/logistics/roboport/roboport-base-patch-mask.png",
				priority = "medium",
				width = 138,
				height = 100,
				shift = util.by_pixel(1.5, 5),
				tint = inputs.tint,
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-bobs__/graphics/entity/logistics/roboport/roboport-base-patch-highlights.png",
				priority = "medium",
				width = 138,
				height = 100,
				shift = util.by_pixel(1.5, 5),
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				scale = 0.5,
			},
		},
	}

	entity.base_animation = {
		filename = "__reskins-bobs__/graphics/entity/logistics/roboport/base/antennas/roboport-" .. map.image_index .. "-base-animation.png",
		priority = "medium",
		width = 83,
		height = 59,
		frame_count = 8,
		animation_speed = 0.5,
		shift = util.by_pixel(-17.75, -61.25),
		scale = 0.5,
	}

	entity.door_animation_up = {
		filename = "__reskins-bobs__/graphics/entity/logistics/roboport/base/doors/roboport-" .. map.image_index .. "-door-up.png",
		priority = "medium",
		width = 97,
		height = 38,
		frame_count = 16,
		shift = util.by_pixel(-0.25, -29.5),
		scale = 0.5,
	}

	entity.door_animation_down = {
		filename = "__reskins-bobs__/graphics/entity/logistics/roboport/base/doors/roboport-" .. map.image_index .. "-door-down.png",
		priority = "medium",
		width = 97,
		height = 41,
		frame_count = 16,
		shift = util.by_pixel(-0.25, -9.75),
		scale = 0.5,
	}

	entity.recharging_animation = {
		filename = "__reskins-bobs__/graphics/entity/logistics/roboport/base/roboport-recharging.png",
		priority = "high",
		width = 37,
		height = 35,
		frame_count = 16,
		scale = 1.5,
		animation_speed = 0.5,
	}

	if name ~= "roboport" then
		entity.water_reflection = util.copy(data.raw[inputs.type]["roboport"].water_reflection)
	end

	::continue::
end
