-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Compatibility
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["classic-beacon"] then
	return
end
if not (reskins.bobs and reskins.bobs.triggers.modules.entities) then
	return
end

-- Flag available for Mini-Machines compatibility pass
if reskins.compatibility then
	reskins.compatibility.triggers.minimachines.beacons = true
end

-- Set input parameters
local inputs = {
	type = "beacon",
	icon_name = "beacon",
	base_entity_name = "beacon",
	mod = "compatibility",
	group = "classic-beacon",
	particles = { ["small"] = 3 },
	make_remnants = false,
}

local tier_map = {
	["beacon"] = { tier = 1, prog_tier = 3 },
	["beacon-2"] = { tier = 2, prog_tier = 4 },
	["beacon-3"] = { tier = 3, prog_tier = 5 },
}

-- Reskin entities, create and assign extra details
for name, map in pairs(tier_map) do
	---@type data.BeaconPrototype
	local entity = data.raw[inputs.type][name]
	if not entity then
		goto continue
	end

	-- Fix order shenanigans
	if name == "beacon" then
		data.raw["item"][name].order = "a[beacon]-1"
		entity.order = "z-a[beacon]-1"
	end

	local tier = reskins.lib.tiers.get_tier(map)
	inputs.tint = reskins.lib.tiers.get_tint(tier)

	reskins.lib.setup_standard_entity(name, tier, inputs)

	-- Reskin entities
	entity.corpse = "medium-remnants"
	entity.graphics_set = {
		module_icons_suppressed = false,
		animation_list = {
			-- Beacon Base
			{
				render_layer = "lower-object-above-shadow",
				always_draw = true,
				animation = {
					layers = {
						-- Base
						{
							filename = "__classic-beacon__/graphics/entity/beacon/beacon-base.png",
							width = 116,
							height = 93,
							shift = util.by_pixel(11, 1.5),
							scale = 1,
						},
						-- Mask
						{
							filename = "__reskins-compatibility__/graphics/entity/classic-beacon/beacon/beacon-mask.png",
							width = 116,
							height = 93,
							shift = util.by_pixel(11, 1.5),
							scale = 1,
							tint = inputs.tint,
						},
						-- Highlights
						{
							filename = "__reskins-compatibility__/graphics/entity/classic-beacon/beacon/beacon-highlights.png",
							width = 116,
							height = 93,
							shift = util.by_pixel(11, 1.5),
							scale = 1,
							blend_mode = reskins.lib.settings.blend_mode, -- "additive",
						},
						-- Shadow
						{
							filename = "__classic-beacon__/graphics/entity/beacon/beacon-base-shadow.png",
							width = 116,
							height = 93,
							shift = util.by_pixel(11, 1.5),
							scale = 1,
							draw_as_shadow = true,
						},
					},
				},
			},
			-- Beacon Antenna
			{
				render_layer = "object",
				always_draw = true,
				animation = {
					layers = {
						-- Base
						{
							filename = "__classic-beacon__/graphics/entity/beacon/beacon-antenna.png",
							width = 54,
							height = 50,
							line_length = 8,
							frame_count = 32,
							animation_speed = 0.5,
							shift = util.by_pixel(-1, -55),
							scale = 1,
						},
						-- Shadow
						{
							filename = "__classic-beacon__/graphics/entity/beacon/beacon-antenna-shadow.png",
							width = 63,
							height = 49,
							line_length = 8,
							frame_count = 32,
							animation_speed = 0.5,
							shift = util.by_pixel(100.5, 15.5),
							scale = 1,
							draw_as_shadow = true,
						},
					},
				},
			},
		},
	}

	if reskins.lib.settings.get_value("classic-beacon-do-high-res") == true then
		-- Beacon Base
		entity.graphics_set.animation_list[1].animation.layers[1] = {
			filename = "__classic-beacon__/graphics/entity/beacon/hr-beacon-base.png",
			width = 232,
			height = 186,
			shift = util.by_pixel(11, 1.5),
			scale = 0.5,
		}
		-- Beacon Mask
		entity.graphics_set.animation_list[1].animation.layers[2] = {
			filename = "__reskins-compatibility__/graphics/entity/classic-beacon/beacon/beacon-mask.png",
			width = 232,
			height = 186,
			shift = util.by_pixel(11, 1.5),
			tint = inputs.tint,
			scale = 0.5,
		}
		-- Beacon Highlights
		entity.graphics_set.animation_list[1].animation.layers[3] = {
			filename = "__reskins-compatibility__/graphics/entity/classic-beacon/beacon/beacon-highlights.png",
			width = 232,
			height = 186,
			shift = util.by_pixel(11, 1.5),
			blend_mode = reskins.lib.settings.blend_mode, -- "additive",
			scale = 0.5,
		}
		-- Beacon Base Shadow
		entity.graphics_set.animation_list[1].animation.layers[4] = {
			filename = "__classic-beacon__/graphics/entity/beacon/hr-beacon-base-shadow.png",
			width = 232,
			height = 186,
			shift = util.by_pixel(11, 1.5),
			draw_as_shadow = true,
			scale = 0.5,
		}
		-- Beacon Antenna Base
		entity.graphics_set.animation_list[2].animation.layers[1] = {
			filename = "__classic-beacon__/graphics/entity/beacon/hr-beacon-antenna.png",
			width = 108,
			height = 100,
			line_length = 8,
			frame_count = 32,
			animation_speed = 0.5,
			shift = util.by_pixel(-1, -55),
			scale = 0.5,
		}
		-- Beacon Antenna Shadow
		entity.graphics_set.animation_list[2].animation.layers[2] = {
			filename = "__classic-beacon__/graphics/entity/beacon/hr-beacon-antenna-shadow.png",
			width = 126,
			height = 98,
			line_length = 8,
			frame_count = 32,
			animation_speed = 0.5,
			shift = util.by_pixel(100.5, 15.5),
			draw_as_shadow = true,
			scale = 0.5,
		}
	end

	entity.water_reflection = {
		pictures = {
			filename = "__classic-beacon__/graphics/entity/beacon/beacon-reflection.png",
			priority = "extra-high",
			width = 24,
			height = 28,
			shift = util.by_pixel(0, 55),
			variation_count = 1,
			scale = 5,
		},
		rotate = false,
		orientation_to_variation = false,
	}

	::continue::
end
