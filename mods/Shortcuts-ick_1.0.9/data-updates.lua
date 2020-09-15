--[[ Copyright (c) 2019 npc_strider
 * For direct use of code or graphics, credit is appreciated and encouraged. See LICENSE.txt for more information.
 * This mod may contain modified code sourced from base/core Factorio
 *
 * data-updates.lua
 * Remote hiding, generation of disabled artillery and equipment, and autogeneration of unsupported modded shortcuts
--]]

-- This code has been modified by ickputzdirwech.

require("prototypes.shortcuts-mods-updates")

local function hide_the_remote(recipe, technology, item)
	if item then
		if item.flags then
			table.insert(item.flags, "only-in-cursor")
			--item.flags[#item.flags+1] = "only-in-cursor"
		else
			item.flags = {"only-in-cursor"}
		end
	end
	local recipe_prototype = data.raw.recipe[recipe]
	local tech_prototype = data.raw.technology[technology]
	if recipe_prototype then
		recipe_prototype.hidden = true
		recipe_prototype.ingredients = {{"iron-plate", 1}}
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
	hide_the_remote("artillery-targeting-remote", "artillery", data.raw["capsule"]["artillery-targeting-remote"])
end

if settings.startup["discharge-defense-remote"].value == true then
	hide_the_remote("discharge-defense-remote", "discharge-defense-equipment", data.raw["capsule"]["discharge-defense-remote"])
end

if settings.startup["spidertron-remote"].value == "enabled" then
	hide_the_remote("spidertron-remote", "spidertron")
end
if settings.startup["spidertron-remote"].value == "enabled (hide remote from inventory)" then
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

if mods["AdvArtilleryRemotes"] then
	if data.raw.capsule["artillery-cluster-remote"] then
		hide_the_remote("artillery-cluster-remote", "artillery", data.raw.capsule["artillery-cluster-remote"])
	end
	if data.raw.capsule["artillery-discovery-remote"] then
		hide_the_remote("artillery-discovery-remote", "artillery", data.raw.capsule["artillery-discovery-remote"])
	end
end

if mods["Orbital Ion Cannon"] and data.raw["item"]["ion-cannon-targeter"] and data.raw["technology"]["orbital-ion-cannon"] and settings.startup["ion-cannon-targeter"].value == true then
	hide_the_remote("ion-cannon-targeter", "orbital-ion-cannon", data.raw["item"]["ion-cannon-targeter"])
end

if mods["OutpostPlanner"] and mods["PlannerCore"] and data.raw["selection-tool"]["outpost-builder"] and settings.startup["outpost-builder"].value == true then
	hide_the_remote("outpost-builder", nil, data.raw["selection-tool"]["outpost-builder"])
end

if mods["VehicleWagon2"] and settings.startup["vehicle-wagon-2-winch"].value == true then
	hide_the_remote("winch", "vehicle-wagons", data.raw["capsule"]["winch"])
end

-- OTHER MODS
if mods["circuit-checker"] and data.raw["selection-tool"]["circuit-checker"] then
	hide_the_remote(nil, nil, data.raw["selection-tool"]["circuit-checker"])
end

if mods["RailSignalPlanner"] and data.raw["selection-tool"]["rail-signal-planner"] then
	hide_the_remote(nil, nil, data.raw["selection-tool"]["rail-signal-planner"])
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

--Remove technology_to_unlock and/or change action for mod shortcuts in order to make them available based in researched in a specific game.
if mods["circuit-checker"] and data.raw.shortcut["check-circuit"] then
	data.raw.shortcut["check-circuit"].action = "lua"
	data.raw.shortcut["check-circuit"].item_to_create = nil
	data.raw.shortcut["check-circuit"].technology_to_unlock = nil
end
if mods["Spider_Control"] and data.raw.shortcut["squad-spidertron-follow"] then
	data.raw.shortcut["squad-spidertron-follow"].technology_to_unlock = nil
end
if mods["Spider_Control"] and data.raw.shortcut["squad-spidertron-remote"] then
	data.raw.shortcut["squad-spidertron-remote"].action = "lua"
	data.raw.shortcut["squad-spidertron-remote"].item_to_create = nil
	data.raw.shortcut["squad-spidertron-remote"].technology_to_unlock = nil
end
if mods["pump"] and data.raw.shortcut["pump-shortcut"] then
	data.raw.shortcut["pump-shortcut"].action = "lua"
	data.raw.shortcut["pump-shortcut"].item_to_create = nil
	data.raw.shortcut["pump-shortcut"].technology_to_unlock = nil
end
if mods["RailSignalPlanner"] and data.raw.shortcut["give-rail-signal-planner"] then
	data.raw.shortcut["give-rail-signal-planner"].action = "lua"
	data.raw.shortcut["give-rail-signal-planner"].item_to_create = nil
end
if mods["ModuleInserter"] and data.raw.shortcut["module-inserter"] then
	data.raw.shortcut["module-inserter"].action = "lua"
	data.raw.shortcut["module-inserter"].item_to_create = nil
end

local disabled_equipment = {}
local disabled_equipment_item = {}
local equipment_list = {}

if settings.startup["night-vision-equipment"].value == true then
	equipment_list[#equipment_list+1] = "night-vision-equipment"
end
if settings.startup["belt-immunity-equipment"].value == true then
	equipment_list[#equipment_list+1] = "belt-immunity-equipment"
end
if settings.startup["active-defense-equipment"].value == true then
	equipment_list[#equipment_list+1] = "active-defense-equipment"
end

--[[if mods["GunEquipment"] then
	local NoMagazine = table.deepcopy(data.raw["item"]["personal-turret-equipment"])
	NoMagazine.name = "personal-turret-no-magazine-equipment"
	NoMagazine.localised_name = {"", {"equipment-name.personal-turret-no-magazine-equipment"}, " (", {"gui-constant.off"}, ")"}
	local FirearmMagazine = table.deepcopy(data.raw["item"]["personal-turret-equipment"])
	FirearmMagazine.name = "personal-turret-firearm-magazine-equipment"
	local PiercingRoundsMagazine = table.deepcopy(data.raw["item"]["personal-turret-equipment"])
	PiercingRoundsMagazine.name = "personal-turret-piercing-rounds-magazine-equipment"
	local UraniumRoundsMagazine = table.deepcopy(data.raw["item"]["personal-turret-equipment"])
	UraniumRoundsMagazine.name = "personal-turret-uranium-rounds-magazine-equipment"
	data:extend{NoMagazine, FirearmMagazine, PiercingRoundsMagazine, UraniumRoundsMagazine}
end]]


for i, e in pairs(equipment_list) do

	for _, equipment in pairs(data.raw[equipment_list[i]]) do
		local i = #disabled_equipment+1
		disabled_equipment[i] = util.table.deepcopy(equipment)

		--make it compatible with NightvisionToggles, GunEquipment and Nanobots
		if disabled_equipment[i].name ~= "nvt-night-vision-equipment" and string.sub(disabled_equipment[i].name,1,16) ~= "personal-turret-" then
			if string.sub(disabled_equipment[i].name,1,7) ~= "picker-" then

				local name = disabled_equipment[i].name
				if (equipment.type == "active-defense-equipment" and equipment.automatic == true) or equipment.type ~= "active-defense-equipment" then
					disabled_equipment[i].name = "disabled-" .. name
					disabled_equipment[i].localised_name = {"", {"equipment-name." .. name}, " (", {"gui-constant.off"}, ")"}
					disabled_equipment[i].sprite.tint = {0.5, 0.5, 0.5}
				elseif (equipment.type == "active-defense-equipment" and equipment.automatic == false) then
					disabled_equipment[i].name = "disabledinactive-" .. name
					disabled_equipment[i].localised_name = {"equipment-name." .. name}
				end
				disabled_equipment[i].energy_input = "0kW"
				disabled_equipment[i].take_result = name
				disabled_equipment[i].flags = {"hidden"}
				if equipment_list[i] == "belt-immunity-equipment" or (equipment.type == "active-defense-equipment" and equipment.automatic == true) then
					disabled_equipment[i].energy_source.input_flow_limit = "0kW"
					disabled_equipment[i].energy_source.buffer_capacity = "0kJ"
					disabled_equipment[i].energy_source.drain = "1kW"
				end

				if not data.raw["item"][equipment_list[i]] then --for mods which have a different item name compared to equipment name
					disabled_equipment_item[i] = util.table.deepcopy(data.raw["item"][name])
					disabled_equipment_item[i].name = "disabled-" .. name
					disabled_equipment_item[i].flags = {"hidden"}
					disabled_equipment_item[i].placed_as_equipment_result = name
				end

				--disabled_equipment_item[i] = util.table.deepcopy(data.raw["item"][equipment_list[i]]) -- LEGACY ITEM (Disable for release)
				if not disabled_equipment_item[i] then
					disabled_equipment_item[i] = util.table.deepcopy(data.raw["item"][name])
				end

				disabled_equipment_item[i].name = "disabled-" .. name
				disabled_equipment_item[i].localised_name = {"", {"equipment-name." .. name}, " (", {"gui-constant.off"}, ")"}
				disabled_equipment_item[i].localised_description = {"item-description." .. name}
				disabled_equipment_item[i].placed_as_equipment_result = name
				disabled_equipment_item[i].order = disabled_equipment_item[i].order .. "-z"
				if disabled_equipment_item[i].icon then
					disabled_equipment_item[i].icons = {{icon = disabled_equipment_item[i].icon, tint = {0.5, 0.5, 0.5}}}
					disabled_equipment_item[i].icon = nil
				end
			end
		end
	end

end

for i=1,(#disabled_equipment),1 do
	data:extend({disabled_equipment[i]})
	if disabled_equipment_item[i] then
		data:extend({disabled_equipment_item[i]})
	end
end


if settings.startup["artillery-toggle"].value == "both" or settings.startup["artillery-toggle"].value == "Artillery wagon" or settings.startup["artillery-toggle"].value == "Artillery turret" then

	local disabled_turret = {}
	local disabled_turret_item = {}
	local disabled_gun = {}
	local disable_turret_list = {}

	if settings.startup["artillery-toggle"].value == "both" then
		disable_turret_list = {"artillery-wagon", "artillery-turret",}
	elseif settings.startup["artillery-toggle"].value == "Artillery wagon" then
		disable_turret_list = {"artillery-wagon"}
	elseif settings.startup["artillery-toggle"].value == "Artillery turret" then
		disable_turret_list = {"artillery-turret"}
	end

	for i=1,(#disable_turret_list) do
		for _, entity in pairs(data.raw[disable_turret_list[i]]) do
			local i = #disabled_turret+1
			disabled_turret[i] = util.table.deepcopy(entity)
			local name = disabled_turret[i].name
			local gun = disabled_turret[i].gun

			disabled_turret_item[i] = util.table.deepcopy(data.raw["item-with-entity-data"][name])
			if disabled_turret_item[i] == nil then
				disabled_turret_item[i] = util.table.deepcopy(data.raw["item"][name])
			end
			if disabled_turret_item[i] == nil then
				disabled_turret_item[i] =  util.table.deepcopy(data.raw["item-with-entity-data"]["artillery-wagon"])
			end
			disabled_turret_item[i].name = "disabled-" .. name
			disabled_turret_item[i].place_result = "disabled-" .. name
			disabled_turret_item[i].flags = {"hidden"}
			if disabled_turret_item[i].icon then
				disabled_turret_item[i].icons = {{icon = disabled_turret_item[i].icon, tint = {0.5, 0.5, 0.5}}}
				disabled_turret_item[i].icon = nil
			end

			disabled_turret[i].name = "disabled-" .. name
			--disabled_turret[i].flags = {"hidden"} --Turns out flagging an entity (Not ITEM!) as hidden makes it immune to selection-tools...
			disabled_turret[i].localised_name = {"", {"entity-name." .. entity.name}, " (", {"gui-constant.off"}, ")"}
			if disabled_turret[i].icon then
				disabled_turret[i].icons = {{icon = disabled_turret[i].icon, tint = {0.5, 0.5, 0.5}}}
				disabled_turret[i].icon = nil
			end

			disabled_gun[i] = util.table.deepcopy(data.raw["gun"][gun])
			disabled_gun[i].name = "disabled-" .. gun
			disabled_gun[i].localised_name = {"", {"item-name." .. entity.name}, " (", {"gui-constant.off"}, ")"}
			disabled_gun[i].flags = {"hidden"}
			disabled_gun[i].attack_parameters.range = 0
			disabled_gun[i].attack_parameters.min_range = 0
			if disabled_gun[i].icon then
				disabled_gun[i].icons = {{icon = disabled_gun[i].icon, tint = {0.5, 0.5, 0.5}}}
				disabled_gun[i].icon = nil
			end

			disabled_turret[i].gun = disabled_gun[i].name
		end
	end

	for i=1,(#disabled_turret),1 do
		data:extend({disabled_turret[i]})
		if disabled_gun[i] then
			data:extend({disabled_gun[i]})
		end
		if disabled_turret_item[i] then
			data:extend({disabled_turret_item[i]})
		end
	end

end

if settings.startup["tree-killer"].value == true then
	local decon_spec = util.table.deepcopy(data.raw["deconstruction-item"]["deconstruction-planner"])
	decon_spec.name = "shortcuts-deconstruction-planner"
	decon_spec.localised_name = {"item-name.deconstruction-planner"}
	decon_spec.flags = {"only-in-cursor"}
	data:extend({decon_spec})
end


if settings.startup["autogen-color"].value == "default" or settings.startup["autogen-color"].value == "red" or settings.startup["autogen-color"].value == "green" or settings.startup["autogen-color"].value == "blue" then

	--	create a post on the discussion page if you want your shortcut to be added to this blacklist.
	local shortcut_blacklist = {
		"selection-tool",
		"max-rate-calculator",
		"module-inserter",
		"path-remote-control",
		"unit-remote-control",
		"fp_beacon_selector",
		"artillery-jammer-tool",
		"pump-selection-tool",
		"rail-signal-planner",
		"circuit-checker",
		"squad-spidertron-remote-sel",
		"merge-chest-selector",
		"trainbuilder-manual",
	}

	for _, tool in pairs(data.raw["selection-tool"]) do
		local name = tool.name
		local continue = true
		for j, blacklist in pairs(shortcut_blacklist) do
			if name == blacklist then
				continue = false
				break
			end
		end
		if continue == true then
			local create = true
			for i, shortcut in pairs(data.raw["shortcut"]) do
				if shortcut.action == "create-blueprint-item" and shortcut.item_to_create == name then
					create = false
					break
				end
			end
			if create == true then
				local icon
				local icon_size
				if tool.icon then
					icon = tool.icon
				elseif tool.icons then
					icon = tool.icons[1].icon
				else
					icon = "__core__/graphics/shoot.png"
				end

				if tool.icons and tool.icons[1].icon_size then
					icon_size = tool.icons[1].icon_size
				elseif tool.icon_size then
					icon_size = tool.icon_size
				else
					icon_size = 32
				end
				local shortcut = {
					type = "shortcut",
					name = name,
					order = tool.order,
					action = "create-blueprint-item",
					localised_name = {"item-name." .. name},
					item_to_create = name,
					style = settings.startup["autogen-color"].value,
					icon =
					{
						filename = icon,
						priority = "extra-high-no-scale",
						size = icon_size,
						scale = 1,
						flags = {"icon"}
					},
					small_icon =
					{
						filename = icon,
						priority = "extra-high-no-scale",
						size = icon_size,
						scale = 1,
						flags = {"icon"}
					},
					disabled_small_icon =
					{
						filename = icon,
						priority = "extra-high-no-scale",
						size = icon_size,
						scale = 1,
						flags = {"icon"}
					},
				}

				data:extend({shortcut})
				hide_the_remote(name, name, tool) 	--	only attempts to hide the selection-tool if the recipe/tech name matches the tool name - does not search all recipes for mention of the tool.
			end
		end
	end

end

--Remove technology_to_unlock and/or change action for mod shortcuts in order to make them available based in researched in a specific game.
if mods["WellPlanner"] and data.raw.shortcut["well-planner"] then
	data.raw.shortcut["well-planner"].action = "lua"
	data.raw.shortcut["well-planner"].item_to_create = nil
end
