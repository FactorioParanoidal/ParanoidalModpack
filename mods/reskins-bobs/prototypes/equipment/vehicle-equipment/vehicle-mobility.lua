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
	equipment_category = "utility",
	mod = "bobs",
	group = "vehicle-equipment",
	icon_layers = 1,
}

-- Setup defaults
reskins.lib.set_inputs_defaults(inputs)

local equipment_list = {
	"vehicle-motor",
	"vehicle-engine",
}

-- Reskin equipment
for _, icon_name in pairs(equipment_list) do
	-- Fetch equipment
	local name = "bob-" .. icon_name .. "-equipment"
	local equipment = data.raw["movement-bonus-equipment"][name]
	if not equipment then
		goto continue
	end

	inputs.icon_name = icon_name

	-- Construct icon
	reskins.lib.construct_icon(name, 0, inputs)

	-- Reskin the equipment
	equipment.sprite = {
		filename = "__reskins-bobs__/graphics/equipment/vehicle-equipment/" .. icon_name .. "/" .. name .. ".png",
		size = 128,
		priority = "medium",
		scale = 0.5,
	}

	::continue::
end
