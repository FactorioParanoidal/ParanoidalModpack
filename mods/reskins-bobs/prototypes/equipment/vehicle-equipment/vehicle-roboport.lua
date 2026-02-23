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
	icon_name = "vehicle-roboport",
	equipment_category = "utility",
	mod = "bobs",
	group = "vehicle-equipment",
	technology_icon_size = 256,
}

-- Setup defaults
reskins.lib.set_inputs_defaults(inputs)

local vehicle_roboports = {
	["bob-vehicle-roboport-equipment-1"] = { tier = 1, prog_tier = 2, base = 1 },
	["bob-vehicle-roboport-equipment-2"] = { tier = 2, prog_tier = 3, base = 1 },
	["bob-vehicle-roboport-equipment-3"] = { tier = 3, prog_tier = 4, base = 2 },
	["bob-vehicle-roboport-equipment-4"] = { tier = 4, prog_tier = 5, base = 2 },
}

-- Reskin equipment
for name, map in pairs(vehicle_roboports) do
	-- Fetch equipment
	local equipment = data.raw["roboport-equipment"][name]
	if not equipment then
		goto continue
	end

	local tier = reskins.lib.tiers.get_tier(map)
	inputs.tint = reskins.lib.tiers.get_tint(tier)

	-- Setup icon handling
	inputs.icon_base = inputs.icon_name .. "-" .. map.base

	-- Construct icon
	reskins.lib.construct_icon(name, tier, inputs)

	-- Reskin the equipment
	equipment.sprite = {
		layers = {
			-- Base
			{
				filename = "__reskins-bobs__/graphics/equipment/vehicle-equipment/vehicle-roboport/" .. inputs.icon_base .. "-equipment-base.png",
				size = 128,
				priority = "medium",
				flags = { "no-crop" },
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/equipment/vehicle-equipment/vehicle-roboport/vehicle-roboport-equipment-mask.png",
				size = 128,
				priority = "medium",
				flags = { "no-crop" },
				tint = inputs.tint,
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-bobs__/graphics/equipment/vehicle-equipment/vehicle-roboport/vehicle-roboport-equipment-highlights.png",
				size = 128,
				priority = "medium",
				flags = { "no-crop" },
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				scale = 0.5,
			},
		},
	}

	::continue::
end
