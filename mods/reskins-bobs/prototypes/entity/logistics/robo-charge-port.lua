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
	icon_name = "robo-charge-port",
	base_entity_name = "roboport",
	mod = "bobs",
	group = "logistics",
	particles = { ["medium"] = 2 },
	make_remnants = false,
}

local tier_map = {
	["bob-robo-charge-port"] = { tier = 1, prog_tier = 2, image_index = 1 },
	["bob-robo-charge-port-large"] = { tier = 1, prog_tier = 2, image_index = 1, is_large = true },
	["bob-robo-charge-port-2"] = { tier = 2, prog_tier = 3, image_index = 2 },
	["bob-robo-charge-port-large-2"] = { tier = 2, prog_tier = 3, image_index = 2, is_large = true },
	["bob-robo-charge-port-3"] = { tier = 3, prog_tier = 4, image_index = 3 },
	["bob-robo-charge-port-large-3"] = { tier = 3, prog_tier = 4, image_index = 3, is_large = true },
	["bob-robo-charge-port-4"] = { tier = 4, prog_tier = 5, image_index = 4 },
	["bob-robo-charge-port-large-4"] = { tier = 4, prog_tier = 5, image_index = 4, is_large = true },
}

local function charge_port_base(shift_x, shift_y, image_index, tint)
	local shift = { shift_x, shift_y }
	return {
		-- Base
		{
			filename = "__reskins-bobs__/graphics/entity/logistics/robo-charge-port/robo-charge-port-" .. image_index .. "-base.png",
			priority = "medium",
			animation_speed = 0.2,
			width = 60,
			height = 56,
			repeat_count = 12,
			shift = shift,
			scale = 0.5,
		},
		-- Mask
		{
			filename = "__reskins-bobs__/graphics/entity/logistics/robo-charge-port/robo-charge-port-mask.png",
			priority = "medium",
			animation_speed = 0.2,
			width = 60,
			height = 56,
			repeat_count = 12,
			shift = shift,
			tint = tint,
			scale = 0.5,
		},
		-- Highlights
		{
			filename = "__reskins-bobs__/graphics/entity/logistics/robo-charge-port/robo-charge-port-highlights.png",
			priority = "medium",
			animation_speed = 0.2,
			width = 60,
			height = 56,
			repeat_count = 12,
			shift = shift,
			blend_mode = reskins.lib.settings.blend_mode, -- "additive",
			scale = 0.5,
		},
		-- Shadow
		{
			filename = "__reskins-bobs__/graphics/entity/logistics/robo-charge-port/robo-charge-port-shadow.png",
			priority = "medium",
			animation_speed = 0.2,
			width = 70,
			height = 58,
			repeat_count = 12,
			shift = util.by_pixel(shift_x * 32 + 2.5, shift_y * 32 + 0.5),
			draw_as_shadow = true,
			scale = 0.5,
		},
		-- Lights Mask
		{
			filename = "__reskins-bobs__/graphics/entity/logistics/robo-charge-port/robo-charge-port-lights-mask.png",
			priority = "medium",
			animation_speed = 0.2,
			width = 32,
			height = 32,
			frame_count = 12,
			shift = util.by_pixel(shift_x * 32, shift_y * 32 + 1),
			draw_as_glow = true,
			tint = tint,
			scale = 0.5,
		},
		-- Lights Highlights
		{
			filename = "__reskins-bobs__/graphics/entity/logistics/robo-charge-port/robo-charge-port-lights-highlights.png",
			priority = "medium",
			animation_speed = 0.2,
			width = 32,
			height = 32,
			frame_count = 12,
			shift = util.by_pixel(shift_x * 32, shift_y * 32 + 1),
			draw_as_glow = true,
			blend_mode = "additive",
			scale = 0.5,
		},
	}
end

-- Reskin entities, create and assign extra details
for name, map in pairs(tier_map) do
	---@type data.RoboportPrototype
	local entity = data.raw[inputs.type][name]
	if not entity then
		goto continue
	end

	local tier = reskins.lib.tiers.get_tier(map)
	inputs.tint = reskins.lib.tiers.get_tint(tier)

	if map.is_large then
		inputs.icon_base = "large-" .. inputs.icon_name .. "-" .. map.image_index
		inputs.icon_mask = "large-" .. inputs.icon_name
		inputs.icon_highlights = "large-" .. inputs.icon_name
	else
		inputs.icon_base = inputs.icon_name .. "-" .. map.image_index
		inputs.icon_mask = nil
		inputs.icon_highlights = nil
	end

	reskins.lib.setup_standard_entity(name, tier, inputs)

	-- Reskin entities
	entity.base_animation = { layers = {} }

	-- Setup array bounds
	local array_start, array_end = -0.5, 0.5
	if map.is_large then
		array_start = -1
		array_end = 1
	end

	-- Generate charge port array
	for i = array_start, array_end do
		for j = array_start, array_end do
			local charge_port_array = charge_port_base(i, j, map.image_index, inputs.tint)
			for k = 1, #charge_port_array do
				table.insert(entity.base_animation.layers, charge_port_array[k])
			end
		end
	end

	-- Restore some defaults
	entity.recharging_animation = {
		filename = "__reskins-bobs__/graphics/entity/logistics/roboport/base/roboport-recharging.png",
		priority = "high",
		width = 37,
		height = 35,
		frame_count = 16,
		scale = 1.5,
		animation_speed = 0.5,
	}

	::continue::
end
