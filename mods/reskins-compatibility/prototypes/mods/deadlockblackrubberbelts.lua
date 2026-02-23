-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Compatibility
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["DeadlockBlackRubberBelts"] then
	return
end
if reskins.bobs and (reskins.bobs.triggers.logistics.entities == false) then
	return
end

local actions = require("__DeadlockBlackRubberBelts__.code.functions")

local inputs = {
	type = "transport-belt",
	base = "steel",
}

local tier_map = {
	["basic-transport-belt"] = { tier = 0 },
	["transport-belt"] = { tier = 1 },
	["fast-transport-belt"] = { tier = 2 },
	["express-transport-belt"] = { tier = 3 },
	["turbo-transport-belt"] = { tier = 4 },
	["ultimate-transport-belt"] = { tier = 5 },
}

reskins.lib.set_inputs_defaults(inputs)

-- Reskin entities
for name, map in pairs(tier_map) do
	---@type data.TransportBeltPrototype
	local entity = data.raw[inputs.type][name]
	if not entity then
		goto continue
	end
	inputs.tint = reskins.lib.tiers.get_belt_tint(map.tier) -- actions.hsva2rgba(reskins.lib.RGBtoHSV(reskins.library.tiers.get_belt_tint(map.tier)).h, 0.8, 1)

	---@type data.IconData[]
	local base_icon_data = {
		{
			icon = actions.icons_path .. "/rubber-belt-" .. inputs.base .. ".png",
			icon_size = 64,
			scale = 0.5,
		},
		{
			icon = actions.icons_path .. "/rubber-belt-mask.png",
			icon_size = 64,
			scale = 0.5,
			tint = inputs.tint,
		},
	}

	local icon_data = reskins.lib.tiers.add_tier_labels_to_icons(map.tier, base_icon_data)
	local pictures = reskins.lib.sprites.create_sprite_from_icons(base_icon_data, 1.0)

	reskins.lib.icons.assign_icons_to_prototype_and_related_prototypes(name, "transport-belt", icon_data, pictures)

	-- Reskin entity
	entity.belt_animation_set.animation_set = actions.get_belt_animation_set(inputs.tint, inputs.base)

	::continue::
end
