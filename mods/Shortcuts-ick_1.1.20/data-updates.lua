--[[ Copyright (c) 2021 npc_strider, ickputzdirwech
	* Original mod by npc_strider.
	* For direct use of code or graphics, credit is appreciated and encouraged. See LICENSE.txt for more information.
	* This mod may contain modified code sourced from base/core Factorio.
	* This mod has been modified by ickputzdirwech.
]]

--[[ Overview of data-updates.lua:
	* Remote hiding
	* Generation of disabled equipment
]]


require("prototypes.custom-inputs-updates")
require("prototypes.research-requirements-updates")


---------------------------------------------------------------------------------------------------
-- REMOTE HIDING
---------------------------------------------------------------------------------------------------
local function hide_the_remote(recipe, technology, item)
	if item then
		if item.flags then
			table.insert(item.flags, "only-in-cursor")
			table.insert(item.flags, "spawnable")
		else
			item.flags = {"only-in-cursor", "spawnable"}
		end
	end
	local recipe_prototype = data.raw.recipe[recipe]
	local tech_prototype = data.raw.technology[technology]
	if recipe_prototype then
		recipe_prototype.hidden = true
		if technology ~= nil and tech_prototype then
			local effect = tech_prototype.effects
			for i, e in pairs(effect) do
				if effect[i].type == "unlock-recipe" then
					if effect[i].recipe == recipe then
						table.remove(effect, i)
						return
					end
				end
			end
		end
	end
end

if settings.startup["artillery-targeting-remote"].value == true then
	hide_the_remote("artillery-targeting-remote", "artillery", data.raw.capsule["artillery-targeting-remote"])
end

if settings.startup["discharge-defense-remote"].value == true then
	hide_the_remote("discharge-defense-remote", "discharge-defense-equipment", data.raw.capsule["discharge-defense-remote"])
end

if settings.startup["spidertron-remote"].value == "enabled" then
	hide_the_remote("spidertron-remote", "spidertron")
end
if settings.startup["spidertron-remote"].value == "enabled-hidden" then
	hide_the_remote("spidertron-remote", "spidertron", data.raw["spidertron-remote"]["spidertron-remote"])
end

-- SUPPORTED MODS
if mods["aai-programmable-vehicles"] then
	if data.raw["selection-tool"]["unit-remote-control"] then
		hide_the_remote("unit-remote-control", nil, data.raw["selection-tool"]["unit-remote-control"])
	end
	if data.raw["selection-tool"]["path-remote-control"] then
		hide_the_remote("path-remote-control", nil, data.raw["selection-tool"]["path-remote-control"])
	end
end

if mods["AdvancedArtilleryRemotesContinued"] then
	if data.raw.capsule["artillery-cluster-remote"] then
		hide_the_remote("artillery-cluster-remote", "artillery", data.raw.capsule["artillery-cluster-remote"])
	end
	if data.raw.capsule["artillery-discovery-remote"] then
		hide_the_remote("artillery-discovery-remote", "artillery", data.raw.capsule["artillery-discovery-remote"])
	end
end

if mods["MIRV"] and data.raw.capsule["mirv-targeting-remote"] and data.raw.technology["mirv-technology"] and settings.startup["mirv-targeting-remote"].value == true then
	hide_the_remote("mirv-targeting-remote", "mirv-technology", data.raw.capsule["mirv-targeting-remote"])
end

if mods["landmine-thrower"] and data.raw.capsule["landmine-thrower-remote"] and data.raw.technology["landmine-thrower"] and settings.startup["landmine-thrower-remote"].value == true then
	hide_the_remote("landmine-thrower-remote", "landmine-thrower", data.raw.capsule["landmine-thrower-remote"])
end

if settings.startup["well-planner"] and settings.startup["well-planner"].value == true then
	hide_the_remote("well-planner")
end

if mods["VehicleWagon2"] and settings.startup["winch"].value == true then
	hide_the_remote("winch", "vehicle-wagons", data.raw["selection-tool"]["winch"])
end

-- OTHER MODS
if mods["circuit-checker"] and data.raw["selection-tool"]["circuit-checker"] then
	hide_the_remote(nil, nil, data.raw["selection-tool"]["circuit-checker"])
end

if mods["Kux-OrbitalIonCannon"] and data.raw.item["ion-cannon-targeter"] and data.raw.technology["orbital-ion-cannon"] then
	hide_the_remote("ion-cannon-targeter", "orbital-ion-cannon", data.raw.item["ion-cannon-targeter"])
end

if mods["OreEraser"] and data.raw["selection-tool"]["Ore Eraser"] then
	hide_the_remote(nil, nil, data.raw["selection-tool"]["Ore Eraser"])
end

--Remove shortcuts from PickerInventoryTools
if mods["PickerInventoryTools"] then
	if data.raw.shortcut["toggle-active-defense-equipment"] then
		data.raw.shortcut["toggle-active-defense-equipment"] = nil
	end
	if data.raw.shortcut["toggle-night-vision-equipment"] then
		data.raw.shortcut["toggle-night-vision-equipment"] = nil
	end
end


---------------------------------------------------------------------------------------------------
-- GENERATION OF DISABLED EQUIPMENT
---------------------------------------------------------------------------------------------------
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
		-- make it compatible with NightvisionToggles, GunEquipment and Nanobots
		if string.sub(name,1,8) ~= "disabled" and name ~= "nvt-night-vision-equipment" and string.sub(name,1,16) ~= "personal-turret-" and string.sub(name,1,7) ~= "picker-" then

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
