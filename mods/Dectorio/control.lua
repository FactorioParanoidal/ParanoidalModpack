--------------------------
-- COPYRIGHT & LICENSE  --
--------------------------

-- Dectorio, a mod for Factorio
-- https://github.com/jpanther/dectorio
-- Copyright (c) 2017-2024 James "PantherX" Panther

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- A copy of the GNU General Public License is packaged along with
-- this program.  You can also see <http://www.gnu.org/licenses/>.

--------------------------

-- control

DECT = require("config")

-- HELPER FUNCTIONS
-- ---------------------------------

-- Send chat notification to all players or force
local function notify(txt, force)
	if force ~= nil then
		force.print(txt)
	else
		for k, p in pairs(game.players) do
			game.players[k].print(txt)
		end
	end
end

-- BOOTSTRAP FUNCTIONS
-- ---------------------------------

-- Things to check when the mod is updated or other mods are added/removed
local function on_configuration_changed(data)
	-- Notify version and updates
	if data.mod_changes ~= nil and data.mod_changes["Dectorio"] ~= nil and data.mod_changes["Dectorio"].old_version == nil then
		notify({"dect-notify.version", {"dect-notify.dectorio"}, data.mod_changes["Dectorio"].new_version})
	elseif
		data.mod_changes ~= nil and data.mod_changes["Dectorio"] ~= nil and data.mod_changes["Dectorio"].old_version ~= nil
	 then
		-- Reset tech and recipes
		for _, force in pairs(game.forces) do
			force.reset_recipes()
			force.reset_technologies()
		end

		-- Notify version change
		local oldver = data.mod_changes["Dectorio"].old_version
		local newver = data.mod_changes["Dectorio"].new_version
		notify({"dect-notify.new-version", {"dect-notify.dectorio"}, oldver, newver})
	end

	-- Check for incompatible mods and notify
	if data.mod_changes ~= nil then
		local mod_incompatibility = false
		for mod, version in pairs(script.active_mods) do
			if DECT.INCOMPATIBLE.MODS[mod] then
				if DECT.ENABLED[DECT.INCOMPATIBLE.MODS[mod].component] then
					mod_incompatibility = true
				end
			end
		end
		if mod_incompatibility == true then
			for mod, version in pairs(script.active_mods) do
				if DECT.INCOMPATIBLE.MODS[mod] then
					incompatible = DECT.INCOMPATIBLE.MODS[mod]
					if DECT.ENABLED[incompatible.component] and not incompatible.setting then
						notify({"dect-notify.incompatible", {"dect-notify.dectorio"}})
						notify({"dect-notify.reason-" .. incompatible.reason, {"dect-notify.dectorio"}, incompatible.name})
						notify({"dect-notify.recommended-action", {"dect-notify.dectorio"}, incompatible.name, incompatible.component})
						notify({"dect-notify.mod-portal", {"dect-notify.dectorio"}})
					elseif DECT.ENABLED[incompatible.component] and incompatible.setting then
						if settings[incompatible.setting.type][incompatible.setting.name].value == incompatible.setting.value then
							notify({"dect-notify.incompatible", {"dect-notify.dectorio"}})
							notify({"dect-notify.reason-" .. incompatible.reason, {"dect-notify.dectorio"}, incompatible.name})
							notify(
								{
									"dect-notify.recommended-setting",
									{"dect-notify.dectorio"},
									{"mod-setting-name." .. incompatible.setting.name},
									incompatible.name
								}
							)
						end
					end
				end
			end
		end
	end

	-- Check if Alien Biomes was added
	if
		data.mod_changes ~= nil and data.mod_changes["alien-biomes"] ~= nil and
			data.mod_changes["alien-biomes"].old_version == nil
	 then
		if DECT.ENABLED["landscaping"] then
			for _, force in pairs(game.forces) do
				local tech = force.technologies
				local rec = force.recipes
				if tech["dect-landscaping"].researched and script.active_mods["alien-biomes"] then
					for _, tile in pairs(prototypes.tile) do
						if rec["dect-alien-biomes-" .. tile.name] then
							rec["dect-alien-biomes-" .. tile.name].enabled = true
						end
					end
					for _, entity in pairs(prototypes.entity) do
						if rec["dect-alien-biomes-" .. entity.name] then
							rec["dect-alien-biomes-" .. entity.name].enabled = true
						end
					end
					notify({"dect-notify.supported-mod-added", {"dect-notify.dectorio"}, "Alien Biomes"})
				end
			end
		end
	end

	-- Check if Alien Biomes was removed
	if
		data.mod_changes ~= nil and data.mod_changes["alien-biomes"] ~= nil and
			data.mod_changes["alien-biomes"].new_version == nil
	 then
		if DECT.ENABLED["landscaping"] then
			for _, force in pairs(game.forces) do
				local tech = force.technologies
				local rec = force.recipes
				if tech["dect-landscaping"].researched then
					for _, tile in pairs(DECT.CONFIG.BASE_TILES) do
						rec["dect-base-" .. tile].enabled = true
					end
					notify({"dect-notify.supported-mod-removed", {"dect-notify.dectorio"}, "Alien Biomes"})
				end
			end
		end
	end
end

-- ENTITY FUNCTIONS
-- ---------------------------------

-- Clear any decorations around a given entity
local function destroy_decoratives_near_entity(entity)
	if DECT.CONFIG.SETTINGS["remove_decoratives_near_entity"] then
		if entity.type ~= "entity-ghost" and entity.type ~= "tile-ghost" then
			entity.surface.destroy_decoratives({area = entity.bounding_box})
		end
	end
end

-- When a new entity is built
local function on_built_entity(event)
	destroy_decoratives_near_entity(event.entity)
end

-- If the Lawnmower is used to select an area
local function on_selected_area(event)
	if event.item ~= "dect-lawnmower" then
		return
	end
	local surface = game.players[event.player_index].surface
	game.play_sound({path = "dect-lawnmower", position = event.area.left_top})
	surface.destroy_decoratives({area = event.area})
end

-- If the Lawnmower is used to alt-select an area
local function on_alt_selected_area(event)
	if event.item ~= "dect-lawnmower" then
		return
	end
	local surface = game.players[event.player_index].surface
	game.play_sound({path = "dect-lawnmower", position = event.area.left_top})
	local corpses = surface.find_entities_filtered {area = event.area, type = "corpse"}
	for _, corpse in pairs(corpses) do
		if not (corpse.name == "transport-caution-corpse") and not (corpse.name == "invisible-transport-caution-corpse") then
			corpse.destroy()
		end
	end
end

-- EVENTS
-- ---------------------------------

script.on_configuration_changed(on_configuration_changed)
script.on_event(defines.events.on_built_entity, on_built_entity)
script.on_event(defines.events.on_robot_built_entity, on_built_entity)
script.on_event(defines.events.on_player_selected_area, on_selected_area)
script.on_event(defines.events.on_player_alt_selected_area, on_alt_selected_area)
