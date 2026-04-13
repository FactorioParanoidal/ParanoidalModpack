-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.vehicle_equipment.equipment) then
	return
end

-- Note that for equipment, the icons property is not used, so omit type information
-- so that an icon is not set on the equipment prototype.
local inputs = {
	icon_name = "fission-reactor",
	equipment_category = "energy",
	mod = "bobs",
	group = "equipment",
}

-- Setup defaults
reskins.lib.set_inputs_defaults(inputs)

local fission_reactors = {
	["bob-vehicle-fission-reactor-equipment-1"] = { tier = 1 },
	["bob-vehicle-fission-reactor-equipment-2"] = { tier = 2 },
	["bob-vehicle-fission-reactor-equipment-3"] = { tier = 3 },
	["bob-vehicle-fission-reactor-equipment-4"] = { tier = 4 },
	["bob-vehicle-fission-reactor-equipment-5"] = { tier = 5 },
	["bob-vehicle-fission-reactor-equipment-6"] = { tier = 6 },
}

-- Reskin equipment
for name, map in pairs(fission_reactors) do
	-- Fetch equipment
	local equipment = data.raw["generator-equipment"][name]
	if not equipment then
		goto continue
	end

	local tier = reskins.lib.tiers.get_tier(map)
	inputs.tint = reskins.lib.tiers.get_tint(tier)

	-- Construct icon
	reskins.lib.construct_icon(name, tier, inputs)

	-- Reskin the equipment
	equipment.sprite = {
		layers = {
			-- Base
			{
				filename = "__reskins-bobs__/graphics/equipment/vehicle-equipment/vehicle-fission-reactor/vehicle-fission-reactor-equipment-base.png",
				width = 128,
				height = 256,
				priority = "medium",
				flags = { "no-crop" },
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/equipment/vehicle-equipment/vehicle-fission-reactor/vehicle-fission-reactor-equipment-mask.png",
				width = 128,
				height = 256,
				priority = "medium",
				flags = { "no-crop" },
				tint = inputs.tint,
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-bobs__/graphics/equipment/vehicle-equipment/vehicle-fission-reactor/vehicle-fission-reactor-equipment-highlights.png",
				width = 128,
				height = 256,
				priority = "medium",
				flags = { "no-crop" },
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				scale = 0.5,
			},
		},
	}

	::continue::
end
