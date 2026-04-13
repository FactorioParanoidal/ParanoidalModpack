--[[ Copyright (c) 2022 npc_strider, ickputzdirwech
	* Original mod by npc_strider.
	* For direct use of code or graphics, credit is appreciated and encouraged. See LICENSE.txt for more information.
	* This mod may contain modified code sourced from base/core Factorio.
	* This mod has been modified by ickputzdirwech.
]]

--[[ Overview of control.lua:
	* Scripts for updating armor, drawing grids and managing toggles and variables.
		- Equipment functions
		- Reset equipment states
		- Startup
	* Scripts for artillery cannon fire selection tool
	* Scripts for basic shortcuts
		- Character lamp
		- Emergency locator beacon
		- Grid
		- Rail block visualisation
		- Zoom
	* Script for shortcuts that give an item
	* Scripts for vehicle shortcuts
		- Functions
		- on_player_driving_changed_state
		- on_gui_closed
	* on_lua_shortcut
		- Basic
		- Equipment
		- Vehicle
		- Give item
	* Custom inputs
		- Functions
		- Basic
		- Blueprint
		- Equipment
		- Vehicle
		- Give item
]]


require("scripts.on-player-created")


---------------------------------------------------------------------------------------------------
-- STARTUP
---------------------------------------------------------------------------------------------------
local function initialize()
	for name in pairs(game.forces) do
		game.forces[name].reset_technology_effects()
	end
	if storage.shortcuts_light == nil then
		storage.shortcuts_light = {}
	end
	if storage.toggle_rail == nil then
		storage.toggle_rail = {}
	end
	if storage.shortcuts_armor == nil then
		storage.shortcuts_armor = {}
	end
	if storage.shortcuts_grid == nil then
		storage.shortcuts_grid = {}
	end
	if storage.shortcuts_jetpack == nil then
		storage.shortcuts_jetpack = {}
	end
end

script.on_init(initialize)

local function configuration_changed()
	initialize()
	for _, player in pairs(game.players) do
		ick_reset_available_shortcuts(player)
	end
end

script.on_configuration_changed(configuration_changed)


---------------------------------------------------------------------------------------------------
-- EQUIPMENT FUNCTIONS
---------------------------------------------------------------------------------------------------
local function update_armor(player)
	local power_armor = player.get_inventory(defines.inventory.character_armor)
	if power_armor and power_armor.valid then
		if power_armor[1].valid_for_read then
			if power_armor[1].grid and power_armor[1].grid.valid and power_armor[1].grid.width > 0 then
				storage.shortcuts_armor[player.index] = power_armor[1].grid
			else
				table.remove(storage.shortcuts_armor, player.index)
			end
		else
			table.remove(storage.shortcuts_armor, player.index)
		end
	end
end

local function update_state(event, equipment_type) -- toggles the armor
	local player = game.players[event.player_index]
	if player.character then
		update_armor(player)
		local grid = storage.shortcuts_armor[event.player_index]
		if grid and grid.valid then
			for _, equipment in pairs(grid.equipment) do
				if equipment.valid and equipment.type == equipment_type then
					local name = equipment.name
					local position = equipment.position
					local energy = equipment.energy
					local quality = equipment.quality
					if string.sub(equipment.name, 1, 9) ~= "disabled-" then -- disables the equipment
						if equipment_type ~= "active-defense-equipment" or (equipment_type == "active-defense-equipment" and prototypes.equipment["disabled-" .. equipment.name]) then
							grid.take{name = name, position = position}
							local new_equipment = grid.put{name = "disabled-" .. name, position = position, quality = quality}
							if new_equipment and new_equipment.valid then
								new_equipment.energy = energy
							end
							player.set_shortcut_toggled(equipment_type, false)
						end
					elseif (string.sub(equipment.name, 1, 9) == "disabled-") then -- eneables the equipment
						grid.take{name = name, position = position}
						local new_equipment = grid.put{name = (string.sub(name, 10, #name)), position = position, quality = quality}
						if new_equipment and new_equipment.valid then
							new_equipment.energy = energy
						end
						player.set_shortcut_toggled(equipment_type, true)
					end
				end
			end
		end
	end
end

local function false_shortcuts(player) -- disables things
	if settings.startup["night-vision-equipment"].value then
		player.set_shortcut_available("night-vision-equipment", false)
		player.set_shortcut_toggled("night-vision-equipment", false)
	end
	if settings.startup["active-defense-equipment"].value then
		player.set_shortcut_available("active-defense-equipment", false)
		player.set_shortcut_toggled("active-defense-equipment", false)
	end
	if settings.startup["belt-immunity-equipment"].value then
		player.set_shortcut_available("belt-immunity-equipment", false)
		player.set_shortcut_toggled("belt-immunity-equipment", false)
	end
end

local function enable_it(player, equipment, grid, type) -- enables things
	if grid.valid and equipment.valid then
		local name = equipment.name
		local position = equipment.position
		local quality = equipment.quality
		local energy = equipment.energy
		player.set_shortcut_available(type, true)
		player.set_shortcut_toggled(type, true)
		if (string.sub(equipment.name, 1, 9) == "disabled-") then
			grid.take{name = name, position = position}
			local new_equipment = grid.put{name = (string.sub(name, 10, #name)), position = position, quality = quality}
			if new_equipment and new_equipment.valid then
				new_equipment.energy = energy
			end
		end
	end
end

---------------------------------------------------------------------------------------------------
-- RESET EQUIPMENT STATE
---------------------------------------------------------------------------------------------------
local function reset_state(event, toggle) -- verifies placement of equipment and armor switching
	local player = game.players[event.player_index]
	update_armor(player)
	local grid = storage.shortcuts_armor[event.player_index]
	if grid and grid.valid then
		local e_equipment = event.equipment
		if e_equipment and toggle == 1 then -- placed equipment
			local type = e_equipment.type
			if type == "night-vision-equipment" or type == "belt-immunity-equipment" or (type == "active-defense-equipment" and prototypes.equipment["disabledinactive-" .. e_equipment.name] == nil) then
				if settings.startup[type] and settings.startup[type].value then
					for _, equipment in pairs(grid.equipment) do --	Enable all of a type of equipment, even if only one is placed in the grid.
						if equipment.valid and equipment.type == type then
							enable_it(player, equipment, grid, type)
						end
					end
				end
			end
		elseif e_equipment and toggle == 2 then -- took equipment
			local type = prototypes.equipment[e_equipment].type
			if type == "night-vision-equipment" or type == "belt-immunity-equipment" or type == "active-defense-equipment" then
				if settings.startup[type] and settings.startup[type].value then
					local value = false
					for _, equipment in pairs(grid.equipment) do
						if equipment.type == type and equipment.valid then
							if prototypes.equipment["disabledinactive-" .. equipment.name] then else
								value = true
								break
							end
						end
					end
					if value == false then
						player.set_shortcut_available(type, false)
						player.set_shortcut_toggled(type, false)
					end
				end
			end
		elseif toggle == 0 then -- placed armor with grid
			false_shortcuts(player)
			for _, equipment in pairs(grid.equipment) do
				local type = equipment.type
				if equipment.valid and type == "night-vision-equipment" or type == "belt-immunity-equipment" or (type == "active-defense-equipment" and prototypes.equipment["disabledinactive-" .. equipment.name] == nil) then
					if settings.startup[type] and settings.startup[type].value then
						enable_it(player, equipment, grid, equipment.type)
					end
				end
			end
		end
	else -- removed armor or placed armor without grid
		for _, shortcut in pairs({"night-vision-equipment", "belt-immunity-equipment", "active-defense-equipment"}) do
			if settings.startup[shortcut].value then
				player.set_shortcut_available(shortcut, false)
			end
		end
	end
end

script.on_event(defines.events.on_player_armor_inventory_changed, function(event)
	if storage.shortcuts_jetpack[event.player_index] == nil then
		reset_state(event, 0) -- If no change by the jetpack mod was detected the equipment gets reset.
	else
		storage.shortcuts_jetpack[event.player_index] = nil -- Otherwise clear the global again.
	end
end)
script.on_event(defines.events.on_player_placed_equipment, function(event)
	reset_state(event, 1)
end)
script.on_event(defines.events.on_player_removed_equipment, function(event)
	reset_state(event, 2)
end)
-- Not using on_equipment_inserted and on_equipment_removed because the changes would trigger them again.


---------------------------------------------------------------------------------------------------
-- TOGGLE ARTILLERY CANNON FIRE SELECTION TOOL
---------------------------------------------------------------------------------------------------

local function artillery_icon_draw(entity) -- If "Auto targeting" is disabled, the icon is created on the given entity.
	if entity.artillery_auto_targeting == false then
		rendering.draw_sprite{
			sprite = "tooltip-category-effect",
			tint = {r = 1},
			render_layer = "entity-info-icon-above",
			target = entity,
			surface = entity.surface,
			forces = {entity.force}
		}
	end
end

local function artillery_icon_destroy(entity) -- If "Auto targeting" is enabled, the icon is removed from the given entity.
	if entity.artillery_auto_targeting == true then
		for _, icon in pairs(rendering.get_all_objects("Shortcuts-ick")) do
			if icon.type == "sprite" and icon.target and icon.target.entity == entity then
				icon.destroy()
				break
			end
		end
	end
end

local function artillery_on_gui_closed(event) -- Creates or removes "Auto targeting"-disabled-icon for the entity which GUI was closed. Called on_gui_closed, even when artillery jammer tool setting is disabled.
	local entity = event.entity
	if event.gui_type == 1 and entity and (entity.type == "artillery-turret" or entity.type == "artillery-wagon" or (entity.type == "entity-ghost" and (entity.ghost_type == "artillery-turret" or entity.ghost_type == "artillery-wagon"))) then
		artillery_icon_draw(entity) -- Create if "Auto targeting" is disabled.
		artillery_icon_destroy(entity) -- Remove if "Auto targeting" is enabled.
	end
end

local function artillery_on_player_selected_area(event) -- Toggles "Auto targeting" for selected entities, creates or removes icon and in multiplayer prints number of toggled entities.
	if event.item == "artillery-jammer-tool" and event.entities ~= nil then
		local i = 0
		local j = 0
		for _, entity in pairs(event.entities) do
			if entity.valid then
				if entity.artillery_auto_targeting then
					entity.artillery_auto_targeting = false
					artillery_icon_draw(entity)
					i = i+1
				else
					entity.artillery_auto_targeting = true
					artillery_icon_destroy(entity)
					j = j+1
				end
			end
		end
		if game.is_multiplayer() then
			local player = game.players[event.player_index]
			local message = ("Player " .. player.name .. " on surface " .. player.surface.name .. " has ")
			if i ~= 0 and j == 0 then
				player.force.print(message .. "disabled " .. i .. " artillery")
			elseif i == 0 and j ~= 0 then
				player.force.print(message .. "enabled " .. j .. " artillery")
			elseif i ~= 0 and j ~= 0 then
				player.force.print(message .. "enabled " .. j .. " and disabled " .. i .. " artillery")
			end
		end
	end
end

--[[
script.on_event(defines.events.on_player_reverse_selected_area, function(event)
	-- enable selected artillery
	-- replace above
end)

script.on_event(defines.events.on_player_reverse_selected_area, function(event)
	-- disable selected artillery
end)

script.on_event(defines.events.on_player_alt_selected_area, function(event)
	-- enable not selected artillery on that surface
end)

script.on_event(defines.events.on_player_alt_reverse_selected_area, function(event)
	-- disable not selected artillery on that surface
	-- this event doen't exist
end)
]]

---------------------------------------------------------------------------------------------------
-- PREPARE UNINSTAL
---------------------------------------------------------------------------------------------------
script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
	local mode = settings.global["ick-prepare-uninstall"].value
	if event.setting_type == "runtime-global" and event.setting == "ick-prepare-uninstall" and mode ~= "" then

		local function enable_equipment(equipment_types)
			for _, player in pairs(game.players) do
				local armor = player.get_inventory(defines.inventory.character_armor)
				if armor and armor.valid and armor[1].valid_for_read then
					local grid = armor[1].grid
					if grid and grid.valid and grid.get_contents() then
						local count = 0
						for _, equipment_type in pairs(equipment_types) do
							for i, equipment in pairs(grid.equipment) do
								local name = equipment.name
								if string.sub(name, 1, 9) == "disabled-" and equipment.type == equipment_type then
									local position = equipment.position
									local quality = equipment.quality
									grid.take{name = name, position = position}
									local new_equipment = grid.put{name = string.sub(name, 10), position = position, quality = quality}
									if storage.shortcuts_armor[i] and storage.shortcuts_armor[i].get(position) then
										new_equipment.energy = storage.shortcuts_armor[i].get(position).energy
										storage.shortcuts_armor[i] = grid
									end
									count = count + 1
								end
							end
						end
						if count > 0 then
							game.print("PLAYER: " .. player.name .. "\nNumber of equipment pieces enabled: " .. count)
						end
					end
				end
			end
		end

		if mode == "uninstall" then
			enable_equipment({"active-defense-equipment", "belt-immunity-equipment", "night-vision-equipment"})
			game.print("\nREADY TO UNINSTALL")
		elseif mode == "active-defense-equipment" or mode == "belt-immunity-equipment" or mode == "night-vision-equipment" then
			enable_equipment({mode})
			game.print("Ready to disable the setting corresponding to " .. mode)
		else
			game.print("There went something wrong. Please make sure you entered the right word. (ERROR X)")
		end
		settings.global["ick-prepare-uninstall"] = {value = ""}
	end
end)


---------------------------------------------------------------------------------------------------
-- BASIC
---------------------------------------------------------------------------------------------------
-- CHARACTER LAMP
local function toggle_light(player)
	if player.character then
		if storage.shortcuts_light[player.index] == nil then
			storage.shortcuts_light[player.index] = true
		end
		if storage.shortcuts_light[player.index] then
			player.character.disable_flashlight()
			storage.shortcuts_light[player.index] = false
			player.set_shortcut_toggled("flashlight-toggle", false)
		elseif storage.shortcuts_light[player.index] == false then
			player.character.enable_flashlight()
			storage.shortcuts_light[player.index] = true
			player.set_shortcut_toggled("flashlight-toggle", true)
		end
	else
		player.print({"", {"error.error-message-box-title"}, ": ", {"player-doesnt-exist", {"gui.character"}}, " (", {"controller.god"}, "): ", {"entity-name.small-lamp"}, " ", {"gui-mod-info.status-disabled"}})
	end
end

-- EMERGENCY LOCATOR BEACON
local function signal_flare(player)
	if settings.global["disable-flare"].value then
		player.force.print({"", "[img=utility.danger_icon] [color=1,0.1,0.1]", {"entity-name.character"}, " " .. player.name .. " [gps=" .. math.floor(player.position.x+0.5) .. "," .. math.floor(player.position.y+0.5) .. "][/color] [img=utility.danger_icon]"})
	else
		player.print({"", {"error.error-message-box-title"}, ": ", {"technology-name.military"}, " ", {"entity-name.beacon"}, " ", {"gui-mod-info.status-disabled"}})
	end
end

-- GRID
local function draw_grid(player_index)
	local player = game.players[player_index]
	if storage.shortcuts_grid[player_index] == nil then
		storage.shortcuts_grid[player_index] = {}
	end
	-- game.print(#storage.shortcuts_grid[player_index])
	if #storage.shortcuts_grid[player_index] == 0 then
		player.set_shortcut_toggled("draw-grid", true)
		-- Opts
		local settings = settings.get_player_settings(player)
		local radius = settings["grid-radius"].value
		local chunk_size = settings["grid-chunk-size"].value
		local step = settings["grid-step"].value
		local thinn_width = settings["grid-line-width"].value
		local thicc_width = settings["grid-chunk-line-width"].value

		local ground_grid = false
		if settings["grid-ground"].value == "ground" then
			ground_grid = true
		end

		local center_x = math.floor(player.position.x)
		local center_y = math.floor(player.position.y)
		if settings["grid-chunk-align"].value == "chunk" then
			center_x = math.floor(player.position.x/chunk_size)*chunk_size
			center_y = math.floor(player.position.y/chunk_size)*chunk_size
		end
		for i = -radius, radius, step do
			local width = thinn_width
			if i % chunk_size == 0 then
				width = thicc_width
			end
			if width > 0 then
				local line = rendering.draw_line{
					color = {r = 0, g = 0, b = 0, a = 1},
					width = width,
					from = {center_x+i,center_y+radius},
					to = {center_x+i,center_y-radius},
					surface = player.surface,
					players = {player},
					draw_on_ground = ground_grid
				}
				storage.shortcuts_grid[player_index][#storage.shortcuts_grid[player_index]+1] = line.id
			end

			local width = thinn_width
			if i % chunk_size == 0 then
				width = thicc_width
			end
			if width > 0 then
				local line = rendering.draw_line{
					color = {r = 0, g = 0, b = 0, a = 1},
					width = width,
					from = {center_x+radius,center_y+i},
					to = {center_x-radius,center_y+i},
					surface = player.surface,
					players = {player},
					draw_on_ground = ground_grid
				}
				storage.shortcuts_grid[player_index][#storage.shortcuts_grid[player_index]+1] = line.id
			end
		end
	else
		player.set_shortcut_toggled("draw-grid", false)
		local grid = storage.shortcuts_grid[player_index]
		for i=1,(#grid) do
			rendering.get_object_by_id(grid[i]).destroy()
			grid[i] = nil
		end
	end
end

-- PLAYER TRASH NOT REQUESTED
local function player_trash_not_requested(player)
	local player_c
	if player.character then
		player_c = player.character -- If player has a character.
	else
		player_c = player -- If player has no character.
	end
	if player_c.get_requester_point() then
		if player_c.get_requester_point().trash_not_requested then
			player_c.get_requester_point().trash_not_requested = false
			player.set_shortcut_toggled("player-trash-not-requested", false)
		else
			player_c.get_requester_point().trash_not_requested = true
			player.set_shortcut_toggled("player-trash-not-requested", true)
		end
	end
end

local function player_on_gui_closed(event) -- Toggles player-trash-not-requested shortcut in case the setting was changed in the GUI.
	local player = game.players[event.player_index]
	if event.gui_type == 3 and player then
		local player_c
		if player.character then
			player_c = player.character -- If player has a character.
		else
			player_c = player -- If player has no character.
		end
		if player_c and player_c.get_requester_point() then
			if player_c.get_requester_point().trash_not_requested then
				player.set_shortcut_toggled("player-trash-not-requested", true)
			else
				player.set_shortcut_toggled("player-trash-not-requested", false)
			end
		end
	end
end

-- RAIL BLOCK VISUALISATION
local function toggle_rail(player)
	if storage.toggle_rail[player.index] == nil then
		storage.toggle_rail[player.index] = false
	end
	if storage.toggle_rail[player.index] then
		player.game_view_settings.show_rail_block_visualisation = false
		storage.toggle_rail[player.index] = false
		player.set_shortcut_toggled("rail-block-visualization-toggle", false)
	elseif storage.toggle_rail[player.index] == false then
		player.game_view_settings.show_rail_block_visualisation = true
		storage.toggle_rail[player.index] = true
		player.set_shortcut_toggled("rail-block-visualization-toggle", true)
	end
end

-- BIG ZOOM
local function big_zoom(player)
	if settings.global["disable-zoom"].value then
		player.zoom = settings.get_player_settings(player)["zoom-level"].value
	else
		player.print({"", {"error.error-message-box-title"}, ": ", {"controls.alt-zoom-out"}, " ", {"gui-mod-info.status-disabled"}})
	end
end

-- MINIMAP
local function toggle_minimap(player)
	if player.minimap_enabled then
		player.minimap_enabled = false
		player.set_shortcut_toggled("minimap", false)
	else
		player.minimap_enabled = true
		player.set_shortcut_toggled("minimap", true)
	end
end


---------------------------------------------------------------------------------------------------
-- GIVE ITEM
---------------------------------------------------------------------------------------------------

local function tree_killer_setup(player)
	if prototypes.item["tree-killer"] and player.clear_cursor() then
		player.cursor_stack.set_stack({name = "tree-killer"})
		local settings = settings.get_player_settings(player)
		local entity_types = {}
		if settings["environment-killer-item"].value then
			table.insert(entity_types, "item-entity")
		end
		if settings["environment-killer-cliff"].value then
			table.insert(entity_types, "cliff")
		end
		if settings["environment-killer-fish"].value then
			table.insert(entity_types, "fish")
		end
		if settings["environment-killer-rocks"].value then
			table.insert(entity_types, "simple-entity")
		end
		if settings["environment-killer-trees"].value then
			table.insert(entity_types, "tree")
		end
		if #entity_types == 2 and (entity_types[1] == "tree" or entity_types[2] == "tree") and (entity_types[1] == "simple-entity" or entity_types[2] == "simple-entity") then
			player.cursor_stack.trees_and_rocks_only = true
		else
			local filters = {}
			for _, type in pairs(entity_types) do
				for _, entity in pairs(prototypes.get_entity_filtered({{filter = "type", type = type}})) do
					if entity.has_flag("not-deconstructable") == false and (type == "cliff" or entity.mineable_properties.minable) then
						if #filters < 255 then
							if type == "simple-entity" then
								if prototypes.entity[entity.name].count_as_rock_for_filtered_deconstruction or string.sub(entity.name, 1, 14) == "fulgoran-ruin-" then
									table.insert(filters, entity.name)
								end
							else
								table.insert(filters, entity.name)
							end
						else
							player.print({"", {"Shortcuts-ick.error-environment", type}, " (ERROR 3)"})
							break
						end
					end
				end
			end
			player.cursor_stack.entity_filters = filters
		end
	end
end


local function give_shortcut_item(player, prototype_name)
	if prototypes.item[prototype_name] and player.clear_cursor() then
		player.cursor_stack.set_stack({name = prototype_name})
	end
end


---------------------------------------------------------------------------------------------------
-- VEHICLE UPDATES
---------------------------------------------------------------------------------------------------
-- FUNCTIONS
local function update_shortcuts(driver, vehicle_setting, prototype_name)
	if driver.is_player() then --If driver is a player without character
		driver.set_shortcut_available(prototype_name, true)
		driver.set_shortcut_toggled(prototype_name, vehicle_setting)
	elseif driver.player then --If driver is a character with player
		driver.player.set_shortcut_available(prototype_name, true)
		driver.player.set_shortcut_toggled(prototype_name, vehicle_setting)
	end
end

local function vehicle_shortcuts(player, name, vehicle_types, parameter)
	if player.driving then
		local continue = false
		for _, type in pairs(vehicle_types) do
			if player.vehicle.type == type then
				continue = true
				break
			end
		end
		if continue then
			local vehicle = player.vehicle
			if parameter == "auto_target_with_gunner" then
				local params = player.vehicle.vehicle_automatic_targeting_parameters
				if player.vehicle.vehicle_automatic_targeting_parameters.auto_target_with_gunner then
					params.auto_target_with_gunner = false
					player.vehicle.vehicle_automatic_targeting_parameters = params
				else
					params.auto_target_with_gunner = true
					player.vehicle.vehicle_automatic_targeting_parameters = params
				end
				vehicle = player.vehicle.vehicle_automatic_targeting_parameters
			elseif parameter == "auto_target_without_gunner" then
				local params = player.vehicle.vehicle_automatic_targeting_parameters
				if player.vehicle.vehicle_automatic_targeting_parameters.auto_target_without_gunner then
					params.auto_target_without_gunner = false
					player.vehicle.vehicle_automatic_targeting_parameters = params
				else
					params.auto_target_without_gunner = true
					player.vehicle.vehicle_automatic_targeting_parameters = params
				end
				vehicle = player.vehicle.vehicle_automatic_targeting_parameters
			elseif parameter == "logistic_point_enabled" then
				if vehicle.get_requester_point().enabled then
					vehicle.get_requester_point().enabled = false
				else
					vehicle.get_requester_point().enabled = true
				end
			elseif parameter == "trash_not_requested" then
				if vehicle.get_requester_point().trash_not_requested then
					vehicle.get_requester_point().trash_not_requested = false
				else
					vehicle.get_requester_point().trash_not_requested = true
				end
			else
				if parameter == "manual_mode" then
					vehicle = player.vehicle.train
				end
				if vehicle[parameter] then
					vehicle[parameter] = false
				else
					vehicle[parameter] = true
				end
			end
			if parameter == "manual_mode" then
				for _, driver in pairs(vehicle.passengers) do
					update_shortcuts(driver, vehicle[parameter], name)
				end
			elseif parameter == "logistic_point_enabled" then
				for _, driver in pairs({player.vehicle.get_driver(), player.vehicle.get_passenger()}) do
					update_shortcuts(driver, vehicle.get_requester_point().enabled, name)
				end
			elseif parameter == "trash_not_requested" then
				for _, driver in pairs({player.vehicle.get_driver(), player.vehicle.get_passenger()}) do
					update_shortcuts(driver, vehicle.get_requester_point().trash_not_requested, name)
				end
			elseif parameter == "enable_logistics_while_moving" then
				if vehicle.type == "car" or vehicle.type == "spider-vehicle" then
					for _, driver in pairs({player.vehicle.get_driver(), player.vehicle.get_passenger()}) do
						update_shortcuts(driver, vehicle.enable_logistics_while_moving, name)
					end
				elseif vehicle.type == "locomotive" then
					for _, driver in pairs(vehicle.train.passengers) do
						update_shortcuts(driver, vehicle.enable_logistics_while_moving, name)
					end
				end

			else
				for _, driver in pairs({player.vehicle.get_driver(), player.vehicle.get_passenger()}) do
					update_shortcuts(driver, vehicle[parameter], name)
				end
			end
		end
	end
end


-- ON_PLAYER_DRIVING_CHANGED_STATE
script.on_event(defines.events.on_player_driving_changed_state, function(event)
	local player = game.players[event.player_index]
	local setting = settings.startup

	if player.driving and player.vehicle then
		local type = player.vehicle.type
		local function enable_shortcuts(player_p, parameter, name)
			if setting[name].value then
				update_shortcuts(player_p, parameter, name)
			end
		end
		if type == "car" or type == "spider-vehicle" and game.is_multiplayer() then
			enable_shortcuts(player, player.vehicle.driver_is_gunner, "driver-is-gunner")
		end
		if type == "spider-vehicle" then
			enable_shortcuts(player, player.vehicle.vehicle_automatic_targeting_parameters.auto_target_with_gunner, "targeting-with-gunner")
			enable_shortcuts(player, player.vehicle.vehicle_automatic_targeting_parameters.auto_target_without_gunner, "targeting-without-gunner")
		end
		if player.vehicle.get_requester_point() then
			enable_shortcuts(player, player.vehicle.get_requester_point().enabled, "vehicle-logistic-requests")
			enable_shortcuts(player, player.vehicle.get_requester_point().trash_not_requested, "vehicle-trash-not-requested")
		end
		if player.vehicle.grid then
			enable_shortcuts(player, player.vehicle.enable_logistics_while_moving, "vehicle-logistics-while-moving")
		end
		if type == "locomotive" or type == "cargo-wagon" or type == "fluid-wagon" or type == "artillery-wagon" then
			enable_shortcuts(player, player.vehicle.train.manual_mode, "train-mode-toggle")
		end
	elseif player.driving == false then
		local function disable_shortcuts(name)
			if setting[name].value then
				player.set_shortcut_available(name, false)
			end
		end
		disable_shortcuts("driver-is-gunner")
		disable_shortcuts("vehicle-logistics-while-moving")
		disable_shortcuts("vehicle-logistic-requests")
		disable_shortcuts("vehicle-trash-not-requested")
		disable_shortcuts("targeting-with-gunner")
		disable_shortcuts("targeting-without-gunner")
		disable_shortcuts("train-mode-toggle")
	end
end)


-- ON_GUI_CLOSED
local function vehicle_on_gui_closed(event)
	local entity = event.entity
	if (event.gui_type == 1 or event.gui_type == 24) and entity and (entity.type == "car" or entity.type == "spider-vehicle" or entity.type == "locomotive") then
		local type = entity.type
		local setting = settings.startup
		local function search_vehicle(name, parameter)
			if setting[name].value then
				for _, driver in pairs({entity.get_driver(), entity.get_passenger()}) do
					update_shortcuts(driver, parameter, name)
				end
			end
		end
		if type == "car" or type == "spider-vehicle" then
			search_vehicle("driver-is-gunner", entity.driver_is_gunner)
		end
		if type == "spider-vehicle" then
			search_vehicle("targeting-with-gunner", entity.vehicle_automatic_targeting_parameters.auto_target_with_gunner)
			search_vehicle("targeting-without-gunner", entity.vehicle_automatic_targeting_parameters.auto_target_without_gunner)
		end
		if entity.get_requester_point() then
			search_vehicle("vehicle-logistic-requests", entity.get_requester_point().enabled)
			search_vehicle("vehicle-trash-not-requested", entity.get_requester_point().trash_not_requested)
		end
		if setting["vehicle-logistics-while-moving"].value and entity.grid then
			if entity.type == "car" or entity.type == "spider-vehicle" then
				search_vehicle("vehicle-logistics-while-moving", entity.enable_logistics_while_moving)
			elseif entity.type == "locomotive" then
				for _, driver in pairs(entity.train.passengers) do
					update_shortcuts(driver, entity.enable_logistics_while_moving, "vehicle-logistics-while-moving")
				end
			end
		end
		if setting["train-mode-toggle"].value and type == "locomotive" and entity.train.passengers then
			for _, driver in pairs(entity.train.passengers) do
				update_shortcuts(driver, entity.train.manual_mode, "train-mode-toggle")
			end
		end
	end
end

---------------------------------------------------------------------------------------------------
-- ON LUA SHORTCUT
---------------------------------------------------------------------------------------------------
local function handle_lua_shortcut(event)
	local prototype_name = event.prototype_name
	local player = game.players[event.player_index]

	-- BASIC
	if prototype_name == "flashlight-toggle" then
		toggle_light(player)
	elseif prototype_name == "signal-flare" then
		signal_flare(player)
	elseif prototype_name == "draw-grid" then
		draw_grid(event.player_index)
	elseif prototype_name == "rail-block-visualization-toggle" then
		toggle_rail(player)
	elseif prototype_name == "player-trash-not-requested" then
		player_trash_not_requested(player)
	elseif prototype_name == "big-zoom" then
		big_zoom(player)
	elseif prototype_name == "minimap" then
		toggle_minimap(player)

	-- EQUIPMENT
	elseif prototype_name == "night-vision-equipment" then
		update_state(event, "night-vision-equipment")
		return
	elseif prototype_name == "belt-immunity-equipment" then
		update_state(event, "belt-immunity-equipment")
		return
	elseif prototype_name == "active-defense-equipment" then
		update_state(event, "active-defense-equipment")
		return

	-- VEHICLE
	elseif prototype_name == "driver-is-gunner" then
		vehicle_shortcuts(player, "driver-is-gunner", { "car", "spider-vehicle" }, "driver_is_gunner")
	elseif prototype_name == "vehicle-logistics-while-moving" then
		vehicle_shortcuts(
			player,
			"vehicle-logistics-while-moving",
			{ "car", "spider-vehicle", "locomotive", "cargo-wagon", "fluid-wagon", "artillery-wagon" },
			"enable_logistics_while_moving"
		)
	elseif prototype_name == "vehicle-logistic-requests" then
		vehicle_shortcuts(
			player,
			"vehicle-logistic-requests",
			{ "car", "spider-vehicle", "locomotive", "cargo-wagon", "fluid-wagon", "artillery-wagon" },
			"logistic_point_enabled"
		)
	elseif prototype_name == "vehicle-trash-not-requested" then
		vehicle_shortcuts(
			player,
			"vehicle-trash-not-requested",
			{ "car", "spider-vehicle", "locomotive", "cargo-wagon", "fluid-wagon", "artillery-wagon" },
			"trash_not_requested"
		)
	elseif prototype_name == "targeting-with-gunner" then
		vehicle_shortcuts(player, "targeting-with-gunner", { "spider-vehicle" }, "auto_target_with_gunner")
	elseif prototype_name == "targeting-without-gunner" then
		vehicle_shortcuts(player, "targeting-without-gunner", { "spider-vehicle" }, "auto_target_without_gunner")
	elseif prototype_name == "train-mode-toggle" then
		vehicle_shortcuts(
			player,
			"train-mode-toggle",
			{ "locomotive", "cargo-wagon", "fluid-wagon", "artillery-wagon" },
			"manual_mode"
		)

	-- GIVE ITEM
	elseif prototype_name == "artillery-jammer-tool" then
		give_shortcut_item(player, "artillery-jammer-tool")
	elseif prototype_name == "tree-killer" then
		tree_killer_setup(player)
	end
end

script.on_event(defines.events.on_lua_shortcut, handle_lua_shortcut)


---------------------------------------------------------------------------------------------------
-- CUSTOM INPUTS
---------------------------------------------------------------------------------------------------
-- FUNCTIONS
local function custom_input_equipment(name)
	if settings.startup[name].value then
		script.on_event(name, function(event)
			update_state(event, name)
		end)
	end
end

local function custom_input_vehicle(name, vehicle_types, parameter)
	if settings.startup[name].value then
		script.on_event(name, function(event)
			vehicle_shortcuts(game.players[event.player_index], name, vehicle_types, parameter)
		end)
	end
end


-- GIVE ITEM
if settings.startup["tree-killer"].value then
	script.on_event("tree-killer", function(event)
		local player = game.players[event.player_index]
		if player.is_shortcut_available("tree-killer") then
			tree_killer_setup(player)
		end
	end)
end

if settings.startup["artillery-toggle"].value ~= "disabled" then
	script.on_event("artillery-jammer-tool", function(event)
		local player = game.players[event.player_index]
		if player.is_shortcut_available("artillery-jammer-tool") then
			give_shortcut_item(player, "artillery-jammer-tool")
		end
	end)
end


-- BASIC
if settings.startup["flashlight-toggle"].value then
	script.on_event("flashlight-toggle", function(event)
		toggle_light(game.players[event.player_index])
	end)
end
if settings.startup["signal-flare"].value then
	script.on_event("signal-flare", function(event)
		signal_flare(game.players[event.player_index])
	end)
end
if settings.startup["draw-grid"].value then
	script.on_event("draw-grid", function(event)
		draw_grid(event.player_index)
	end)
end
if settings.startup["rail-block-visualization-toggle"].value then
	script.on_event("rail-block-visualization-toggle", function(event)
		local player = game.players[event.player_index]
		if player.is_shortcut_available("rail-block-visualization-toggle") then
			toggle_rail(player)
		end
	end)
end
if settings.startup["player-trash-not-requested"].value then
	script.on_event("player-trash-not-requested", function(event)
		local player = game.players[event.player_index]
		if player.is_shortcut_available("player-trash-not-requested") then
			player_trash_not_requested(player)
		end
	end)
end
if settings.startup["big-zoom"].value then
	script.on_event("big-zoom", function(event)
		big_zoom(game.players[event.player_index])
	end)
end
if settings.startup["minimap"].value then
	script.on_event("minimap", function(event)
		toggle_minimap(game.players[event.player_index])
	end)
end


-- EQUIPMENT
custom_input_equipment("belt-immunity-equipment")
custom_input_equipment("night-vision-equipment")
custom_input_equipment("active-defense-equipment")


-- VEHICLE
custom_input_vehicle("driver-is-gunner", {"car", "spider-vehicle"}, "driver_is_gunner")
custom_input_vehicle("vehicle-logistics-while-moving", {"car", "spider-vehicle", "locomotive", "cargo-wagon", "fluid-wagon", "artillery-wagon"}, "enable_logistics_while_moving")
custom_input_vehicle("vehicle-logistic-requests", {"car", "spider-vehicle", "locomotive", "cargo-wagon", "fluid-wagon", "artillery-wagon"}, "logistic_point_enabled")
custom_input_vehicle("vehicle-trash-not-requested", {"car", "spider-vehicle", "locomotive", "cargo-wagon", "fluid-wagon", "artillery-wagon"}, "trash_not_requested")
custom_input_vehicle("targeting-with-gunner", {"spider-vehicle"}, "auto_target_with_gunner")
custom_input_vehicle("targeting-without-gunner", {"spider-vehicle"}, "auto_target_without_gunner")
custom_input_vehicle("train-mode-toggle", {"locomotive", "cargo-wagon", "fluid-wagon", "artillery-wagon"}, "manual_mode")


---------------------------------------------------------------------------------------------------
-- EVENTS
---------------------------------------------------------------------------------------------------
script.on_event(defines.events.on_gui_closed, function(event)
	vehicle_on_gui_closed(event)
	artillery_on_gui_closed(event)
	if settings.startup["player-trash-not-requested"].value then
		player_on_gui_closed(event)
	end
end)

if settings.startup["artillery-toggle"].value ~= "disabled" then

	script.on_event(defines.events.on_player_selected_area, function(event)
		artillery_on_player_selected_area(event)
	end)

	script.on_event(defines.events.on_robot_built_entity, function(event)
		artillery_icon_draw(event.entity) -- Create icon if "Auto targeting" is disabled.
		artillery_icon_destroy(event.entity) -- Remove icon if "Auto targeting" is enabled and a ghost was replaced.
	end, {{filter = "type", type = "artillery-turret"}, {filter = "type", type = "artillery-wagon"}})

	script.on_event(defines.events.on_built_entity, function(event)
		artillery_icon_draw(event.entity) -- Create icon if "Auto targeting" is disabled.
		artillery_icon_destroy(event.entity) -- Remove icon if "Auto targeting" is enabled and a ghost was replaced.
	end, {{filter = "type", type = "artillery-turret"}, {filter = "type", type = "artillery-wagon"}, {filter = "ghost_type", type = "artillery-turret"}, {filter = "ghost_type", type = "artillery-wagon"}})

end

remote.add_interface("Shortcuts-ick", { -- Checks if the armor inventory change was caused by the jetpack mod.
	on_character_swapped = function(data)
		if data.new_character.get_inventory(defines.inventory.character_armor).is_empty() == false and data.new_character.player then
			storage.shortcuts_jetpack[data.new_character.player.index] = true
		end
	end,
	on_lua_shortcut = handle_lua_shortcut,
})