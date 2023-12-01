--[[ Copyright (c) 2022 npc_strider, ickputzdirwech
	* Original mod by npc_strider.
	* For direct use of code or graphics, credit is appreciated and encouraged. See LICENSE.txt for more information.
	* This mod may contain modified code sourced from base/core Factorio.
	* This mod has been modified by ickputzdirwech.
]]

--[[ Overview of disabled-equipment-updates.lua:
	* Generation of disabled equipment
]]

local equipment_list = {}

if settings.startup["night-vision-equipment"].value == true then
	table.insert(equipment_list, "night-vision-equipment")
end
if settings.startup["belt-immunity-equipment"].value == true then
	table.insert(equipment_list, "belt-immunity-equipment")
end
if settings.startup["active-defense-equipment"].value == true then
	table.insert(equipment_list, "active-defense-equipment")
end

for i, type in pairs(equipment_list) do
	for _, equipment in pairs(data.raw[type]) do
		local name = equipment.name
		-- make it compatible with NightvisionToggles, GunEquipment, Nanobots and Nullius
		if string.sub(name, 1, 8) ~= "disabled" and name ~= "nvt-night-vision-equipment" and string.sub(name, 1, 16) ~= "personal-turret-" and string.sub(name, 1, 7) ~= "picker-" and string.sub(name, 1, 8) ~= "nullius-" then

			local disabled_equipment = util.table.deepcopy(equipment)

			if (type == "active-defense-equipment" and equipment.automatic == true) or type ~= "active-defense-equipment" then
				disabled_equipment.name = "disabled-" .. name
				disabled_equipment.localised_name = {"", {"equipment-name." .. name}, " (", {"gui-constant.off"}, ")"}
			elseif (type == "active-defense-equipment" and equipment.automatic == false) then
				disabled_equipment.name = "disabledinactive-" .. name
				disabled_equipment.localised_name = {"equipment-name." .. name}
			end

			if type == "night-vision-equipment" then
				disabled_equipment.energy_input = "0kW"
			end
			
			disabled_equipment.take_result = name
			disabled_equipment.sprite.tint = {0.5, 0.5, 0.5}
			if disabled_equipment.sprite.hr_version then
				disabled_equipment.sprite.hr_version.tint = {0.5, 0.5, 0.5}
			end

			if type == "belt-immunity-equipment" or (type == "active-defense-equipment" and equipment.automatic == true) then
				disabled_equipment.energy_source.input_flow_limit = "0kW"
				disabled_equipment.energy_source.buffer_capacity = "0kJ"
				disabled_equipment.energy_source.drain = "1kW"
			end

			data:extend({disabled_equipment})
		end
	end
end
