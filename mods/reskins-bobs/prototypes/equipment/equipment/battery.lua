-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.equipment.equipment) then
	return
end

-- Note that for equipment, the icons property is not used, so omit type information
-- so that an icon is not set on the equipment prototype.
local inputs = {
	icon_name = "battery",
	mod = "bobs",
	group = "equipment",
}

-- Setup defaults
reskins.lib.set_inputs_defaults(inputs)

local batteries = {
	["battery-equipment"] = { tier = 1 },
	["battery-mk2-equipment"] = { tier = 2 },
	["bob-battery-mk3-equipment"] = { tier = 3 },
	["bob-battery-mk4-equipment"] = { tier = 4 },
	["bob-battery-mk5-equipment"] = { tier = 5 },
	["bob-battery-mk6-equipment"] = { tier = 6 },
}

-- Reskin equipment
for name, map in pairs(batteries) do
	-- Fetch equipment
	local equipment = data.raw["battery-equipment"][name]
	if not equipment then
		goto continue
	end

	local tier = reskins.lib.tiers.get_tier(map)
	inputs.tint = reskins.lib.tiers.get_tint(tier)

	-- Construct icon
	reskins.lib.construct_icon(name, tier, inputs)

	-- Reskin the equipment
	---@type data.Sprite
	equipment.sprite = {
		layers = {
			-- Base
			{
				filename = "__reskins-bobs__/graphics/equipment/equipment/battery/battery-equipment-base.png",
				width = 64,
				height = 128,
				priority = "medium",
				flags = { "no-crop" },
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/equipment/equipment/battery/battery-equipment-mask.png",
				width = 64,
				height = 128,
				priority = "medium",
				flags = { "no-crop" },
				tint = inputs.tint,
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-bobs__/graphics/equipment/equipment/battery/battery-equipment-highlights.png",
				width = 64,
				height = 128,
				priority = "medium",
				flags = { "no-crop" },
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				scale = 0.5,
			},
		},
	}

	::continue::
end
