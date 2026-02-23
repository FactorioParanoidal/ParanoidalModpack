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
	icon_name = "vehicle-belt-immunity",
	mod = "bobs",
	group = "vehicle-equipment",
	equipment_category = "utility",
	icon_filename = "__base__/graphics/icons/belt-immunity-equipment.png",
	icon_size = 64,
}

local name = "bob-vehicle-belt-immunity-equipment"

-- Reskin equipment; fetch the equipment
local equipment = data.raw["belt-immunity-equipment"][name]

-- Check if entity exists, if not, return
if not equipment then
	return
end

-- Construct icon
reskins.lib.construct_icon(name, 0, inputs)

-- Reskin equipment
equipment.sprite = {
	filename = "__base__/graphics/equipment/belt-immunity-equipment.png",
	size = 64,
	priority = "medium",
	scale = 0.5,
}
