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
	icon_name = "robochest",
	base_entity_name = "roboport",
	mod = "bobs",
	group = "logistics",
	particles = { ["medium"] = 2 },
	make_remnants = false,
}

local tier_map = {
	["bob-robochest"] = { tier = 1, prog_tier = 2, image_index = 1 },
	["bob-robochest-2"] = { tier = 2, prog_tier = 3, image_index = 2 },
	["bob-robochest-3"] = { tier = 3, prog_tier = 4, image_index = 3 },
	["bob-robochest-4"] = { tier = 4, prog_tier = 5, image_index = 4 },
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
	inputs.icon_base = "robochest-" .. map.image_index

	reskins.lib.setup_standard_entity(name, tier, inputs)

	entity.spawn_and_station_height = -0.25

	entity.base = {
		layers = {
			{
				filename = "__reskins-bobs__/graphics/entity/logistics/robochest/robochest-base.png",
				width = 130,
				height = 138,
				shift = util.by_pixel(0, -2.75),
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/entity/logistics/robochest/robochest-mask.png",
				width = 130,
				height = 138,
				shift = util.by_pixel(0, -2.75),
				tint = inputs.tint,
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-bobs__/graphics/entity/logistics/robochest/robochest-highlights.png",
				width = 130,
				height = 138,
				shift = util.by_pixel(0, -2.75),
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				scale = 0.5,
			},
			-- Shadow
			{
				filename = "__reskins-bobs__/graphics/entity/logistics/robochest/robochest-shadow.png",
				width = 174,
				height = 108,
				shift = util.by_pixel(12, 5),
				draw_as_shadow = true,
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
				filename = "__reskins-bobs__/graphics/entity/logistics/robochest/robochest-base-patch.png",
				width = 110,
				height = 80,
				shift = util.by_pixel(0, 5.5),
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/entity/logistics/robochest/robochest-base-patch-mask.png",
				width = 110,
				height = 80,
				shift = util.by_pixel(0, 5.5),
				tint = inputs.tint,
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-bobs__/graphics/entity/logistics/robochest/robochest-base-patch-highlights.png",
				width = 110,
				height = 80,
				shift = util.by_pixel(0, 5.5),
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				scale = 0.5,
			},
		},
	}

	entity.base_animation = util.empty_sprite()

	entity.door_animation_up = {
		filename = "__reskins-bobs__/graphics/entity/logistics/roboport/base/doors/roboport-" .. map.image_index .. "-door-up.png",
		priority = "medium",
		width = 97,
		height = 38,
		frame_count = 16,
		shift = util.by_pixel(-0.25, -29.5 + 4.5),
		scale = 0.5,
	}

	entity.door_animation_down = {
		filename = "__reskins-bobs__/graphics/entity/logistics/robochest/doors/robochest-" .. map.image_index .. "-door-down.png",
		priority = "medium",
		width = 97,
		height = 45,
		frame_count = 16,
		shift = util.by_pixel(-0.25, -9.75 + 3.5),
		scale = 0.5,
	}

	::continue::
end
