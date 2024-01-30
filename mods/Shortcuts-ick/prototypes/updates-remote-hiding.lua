--[[ Copyright (c) 2022 npc_strider, ickputzdirwech
	* Original mod by npc_strider.
	* For direct use of code or graphics, credit is appreciated and encouraged. See LICENSE.txt for more information.
	* This mod may contain modified code sourced from base/core Factorio.
	* This mod has been modified by ickputzdirwech.
]]

--[[ Overview of remote-hiding-updates.lua:
	* Function
	* Vanilla items
	* Items from mods we made a shortcut for
	* Other mods
]]

-- FUNCTION
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

-- VANILLA ITEMS
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

-- IEMS FROM MODS WE MADE A SHORTCUT FOR
if mods["aai-programmable-vehicles"] then
	if data.raw["selection-tool"]["unit-remote-control"] then
		hide_the_remote("unit-remote-control", nil, data.raw["selection-tool"]["unit-remote-control"])
	end
	if data.raw["selection-tool"]["path-remote-control"] then
		hide_the_remote("path-remote-control", nil, data.raw["selection-tool"]["path-remote-control"])
	end
end

if mods["AdvancedArtilleryRemotesContinued"] then
	if data.raw.capsule["artillery-cluster-remote-artillery-shell"] then
		hide_the_remote("artillery-cluster-remote-artillery-shell", "artillery", data.raw.capsule["artillery-cluster-remote-artillery-shell"])
	end
	if data.raw.capsule["artillery-discovery-remote"] then
		hide_the_remote("artillery-discovery-remote", "artillery", data.raw.capsule["artillery-discovery-remote"])
	end
end

if mods["artillery-bombardment-remote"] or mods["artillery-bombardment-remote-reloaded"] or mods["dbots-artillery-bombardment-remote"] then
	if data.raw["selection-tool"]["artillery-bombardment-remote"] then
		hide_the_remote("artillery-bombardment-remote", "artillery-bombardment-remote", data.raw["selection-tool"]["artillery-bombardment-remote"])
	end
	if data.raw["selection-tool"]["smart-artillery-bombardment-remote"] then
		hide_the_remote("smart-artillery-bombardment-remote", "smart-artillery-bombardment-remote", data.raw["selection-tool"]["smart-artillery-bombardment-remote"])
	end
	if data.raw["selection-tool"]["smart-artillery-exploration-remote"] then
		hide_the_remote("smart-artillery-exploration-remote", "smart-artillery-exploration-remote", data.raw["selection-tool"]["smart-artillery-exploration-remote"])
	end
end

if mods["MIRV"] and data.raw.capsule["mirv-targeting-remote"] and data.raw.technology["mirv-technology"] and settings.startup["mirv-targeting-remote"].value == true then
	hide_the_remote("mirv-targeting-remote", "mirv-technology", data.raw.capsule["mirv-targeting-remote"])
end

if mods["AtomicArtilleryRemote"] and data.raw.capsule["atomic-artillery-targeting-remote"] and data.raw.technology["atomic-artillery"] and settings.startup["atomic-artillery-targeting-remote"].value == true then
	hide_the_remote("atomic-artillery-targeting-remote", "atomic-artillery", data.raw.capsule["atomic-artillery-targeting-remote"])
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

if (mods["ModuleInserter"] or mods["ModuleInserterER"]) and data.raw["selection-tool"]["module-inserter"] then
	hide_the_remote(nil, nil, data.raw["selection-tool"]["module-inserter"])
end
