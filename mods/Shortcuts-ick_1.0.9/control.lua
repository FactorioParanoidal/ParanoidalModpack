--[[ Copyright (c) 2019 npc_strider
 * For direct use of code or graphics, credit is appreciated and encouraged. See LICENSE.txt for more information.
 * This mod may contain modified code sourced from base/core Factorio
 *
 * control.lua
 * Scripts for updating armor, toggling artillery pieces, drawing grids and managing toggles and variables.
--]]

-- This code has been modified by ickputzdirwech.

local function update_armor(event)
	local player = game.players[event.player_index]
	local power_armor = player.get_inventory(defines.inventory.character_armor)
	if power_armor and power_armor ~= nil and power_armor.valid then
		if power_armor[1].valid_for_read then
			if power_armor[1].grid and power_armor[1].grid.valid and power_armor[1].grid.width > 0 then
				global.shortcuts_armor[player.index] = power_armor[1].grid
			else
				table.remove(global.shortcuts_armor,player.index)
			end
		else
			table.remove(global.shortcuts_armor,player.index)
		end
	end
end

local function update_state(event, equipment_type) -- toggles the armor
	update_armor(event)
	local grid = global.shortcuts_armor[game.players[event.player_index].index]
	if grid then
		for _, equipment in pairs(grid.equipment) do
			if equipment.valid and equipment.type == equipment_type then
				local name = equipment.name
				local position = equipment.position
				local energy = equipment.energy
				if not (string.sub(equipment.name,1,9) == "disabled-" or string.sub(equipment.name,1,4) == "nvt-") then
					if equipment_type ~= "active-defense-equipment" or (equipment_type == "active-defense-equipment" and game.equipment_prototypes["disabled-" .. equipment.name]) then
						grid.take{name = name, position = position}
						local new_equipment = grid.put{name="disabled-" .. name, position=position}
						if new_equipment and new_equipment.valid then
							new_equipment.energy = energy
						end
						game.players[event.player_index].set_shortcut_toggled(equipment_type, false)
					end
				elseif (string.sub(equipment.name,1,9) == "disabled-") then
					grid.take{name = name, position = position}
					local new_equipment = grid.put{name=(string.sub(name,10,#name)), position=position}
					if new_equipment and new_equipment.valid then
						new_equipment.energy = energy
					end
					game.players[event.player_index].set_shortcut_toggled(equipment_type, true)
				-- make it compatible with NightvisionToggles
				elseif (string.sub(equipment.name,1,4) == "nvt-") then
					grid.take{name = name, position = position}
					local new_equipment = grid.put{name=(string.sub(name,5,#name)), position=position}
					if new_equipment and new_equipment.valid then
						new_equipment.energy = energy
					end
					game.players[event.player_index].set_shortcut_toggled(equipment_type, true)
				end
			end
		end
	end
end

local function toggle_light(player)
	if player.character then
		if global.shortcuts_light[player.index] == nil then
			global.shortcuts_light[player.index] = true
		end
		if global.shortcuts_light[player.index] == true then
			player.character.disable_flashlight()
			global.shortcuts_light[player.index] = false
			player.set_shortcut_toggled("flashlight-toggle", false)
		elseif global.shortcuts_light[player.index] == false then
			player.character.enable_flashlight()
			global.shortcuts_light[player.index] = true
			player.set_shortcut_toggled("flashlight-toggle", true)
		end
	else
		player.print({"", {"error.error-message-box-title"}, ": ", {"player-doesnt-exist", {"gui.character"}}, " (", {"controller.god"}, "): ", {"entity-name.small-lamp"}, " ", {"gui-mod-info.status-disabled"}})
	end
end
local function toggle_rail(player)
	if global.toggle_rail[player.index] == nil then
		global.toggle_rail[player.index] = false
	end
	if global.toggle_rail[player.index] == true then
		player.game_view_settings.show_rail_block_visualisation = false
		--player.map_view_settings = {["show-rail-signal-states"] = false}
		--player.map_view_settings = {["show-non-standard-map-info"] = {["show-rail-signal-states"] = false}}
		global.toggle_rail[player.index] = false
		player.set_shortcut_toggled("rail-block-visualization-toggle", false)
	elseif global.toggle_rail[player.index] == false then
		player.game_view_settings.show_rail_block_visualisation = true
		--player.map_view_settings = {["show-rail-signal-states"] = true}
		--player.map_view_settings = {["show-non-standard-map-info"] = {["show-rail-signal-states"] = true}}
		global.toggle_rail[player.index] = true
		player.set_shortcut_toggled("rail-block-visualization-toggle", true)
	end
end

local function false_shortcuts(player) -- disables things
	if settings.startup["night-vision-equipment"].value == true then
		player.set_shortcut_available("night-vision-equipment", false)
		player.set_shortcut_toggled("night-vision-equipment", false)
	end
	if settings.startup["active-defense-equipment"].value == true then
		player.set_shortcut_available("active-defense-equipment", false)
		player.set_shortcut_toggled("active-defense-equipment", false)
	end
	if settings.startup["belt-immunity-equipment"].value == true then
		player.set_shortcut_available("belt-immunity-equipment", false)
		player.set_shortcut_toggled("belt-immunity-equipment", false)
	end
	--[[if game.active_mods["PickerInventoryTools"] and game.active_mods["Nanobots"] then
		player.set_shortcut_available("toggle-equipment-bot-chip-feeder", false)
		player.set_shortcut_available("toggle-equipment-bot-chip-items", false)
		player.set_shortcut_available("toggle-equipment-bot-chip-launcher", false)
		player.set_shortcut_available("toggle-equipment-bot-chip-nanointerface", false)
		player.set_shortcut_available("toggle-equipment-bot-chip-trees", false)
		player.set_shortcut_toggled("toggle-equipment-bot-chip-feeder", false)
		player.set_shortcut_toggled("toggle-equipment-bot-chip-items", false)
		player.set_shortcut_toggled("toggle-equipment-bot-chip-launcher", false)
		player.set_shortcut_toggled("toggle-equipment-bot-chip-nanointerface", false)
		player.set_shortcut_toggled("toggle-equipment-bot-chip-trees", false)
	end]]
end

local function enable_it(player, equipment, grid, type) -- enables things
	if grid.valid and equipment.valid then
		local name = equipment.name
		local position = equipment.position
		local energy = equipment.energy
		player.set_shortcut_available(type, true)
		player.set_shortcut_toggled(type, true)
		if (string.sub(equipment.name,1,9) == "disabled-") then
			grid.take{name = name, position = position}
			local new_equipment = grid.put{name=(string.sub(name,10,#name)), position=position}
			if new_equipment and new_equipment.valid then
				new_equipment.energy = energy
			end
		end

		--[[--Make compatible with PickerInventoryTools
		if (string.sub(equipment.name,1,19) == "equipment-bot-chip-") then
			player.set_shortcut_available("toggle-"..name, true)
			player.set_shortcut_toggled("toggle-"..name, true)
		end
		if (string.sub(equipment.name,1,16) == "picker-disabled-") then
			player.set_shortcut_available("toggle-"..string.sub(name,17,#name), true)
			player.set_shortcut_toggled("toggle-"..string.sub(name,17,#name), true)
			grid.take{name = name, position = position}
			local new_equipment = grid.put{name=(string.sub(name,17,#name)), position=position}
			if new_equipment and new_equipment.valid then
				new_equipment.energy = energy
			end
		end]]

	end
end
local function reset_state(event, toggle) -- verifies placement of equipment and armor switching
	update_armor(event)
	local player = game.players[event.player_index]
	local grid = global.shortcuts_armor[game.players[event.player_index].index]
	if grid and grid.valid then
		local equipment = event.equipment
		if equipment and toggle == 1 then --place
			local type = equipment.type
			if type == "night-vision-equipment" or type == "belt-immunity-equipment" or (type == "active-defense-equipment" and game.equipment_prototypes["disabledinactive-" .. equipment.name] == nil) then
				local setting = settings.startup[type]
				if setting and setting.value then
					for _, equipment in pairs(grid.equipment) do	--	Enable all of a type of equipment, even if only one is placed in the grid.
						if equipment.valid and equipment.type == type then
							enable_it(player, equipment, grid, type)
						end
					end
				end
			end
		elseif equipment and toggle == 2 then --take
			local type = game.equipment_prototypes[equipment].type
			local name = game.equipment_prototypes[equipment].name
			if type == "night-vision-equipment" or type == "belt-immunity-equipment" or type == "active-defense-equipment" then
				local setting = settings.startup[type]
				if setting and setting.value then
					local value = false
					for _, equipment in pairs(grid.equipment) do
						if equipment.type == type and equipment.valid then
							if type ~= "active-defense-equipment" then
								value = true
								break
							elseif type == "active-defense-equipment" and game.equipment_prototypes["disabledinactive-" .. equipment.name] == nil then
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
		elseif toggle == 0 then --armor place
			false_shortcuts(player)
			for _, equipment in pairs(grid.equipment) do
				local type = equipment.type
				if equipment.valid and type == "night-vision-equipment" or type == "belt-immunity-equipment" or (type == "active-defense-equipment" and game.equipment_prototypes["disabledinactive-" .. equipment.name] == nil) then
					local setting = settings.startup[type]
					if setting and setting.value then
						enable_it(player, equipment, grid, equipment.type)
					end
				end
			end
		end
	else
		false_shortcuts(player)
	end
end

local function artillery_swap(wagon,new_name)
	local shellname = {}
	local shellcount = {}
	local inventory
	if wagon.type == "artillery-wagon" then
		inventory = wagon.get_inventory(defines.inventory.artillery_wagon_ammo)
	elseif wagon.type == "artillery-turret" then
		inventory = wagon.get_inventory(defines.inventory.artillery_turret_ammo)
	end

	for i=1,(#inventory) do
		if inventory[i].valid_for_read then
			shellname[#shellname+1] = inventory[i].name
			shellcount[#shellcount+1] = inventory[i].count
		end
	end

	local name = wagon.name
	local surface = wagon.surface.name
	local position = wagon.position
	local direction = wagon.direction
	local force = wagon.force
	local kills = wagon.kills
	local damage = wagon.damage_dealt
	local health = wagon.health
	wagon.destroy()
	local new_wagon = game.surfaces[surface].create_entity{name=new_name, position=position, direction=direction, force=force, create_build_effect_smoke=false}
	if new_wagon then
		new_wagon.kills = kills
		new_wagon.damage_dealt = damage
		new_wagon.health = health
		for i=1,(#shellcount) do
			if new_wagon.can_insert({name=shellname[i],count=shellcount[i]}) == true then
				new_wagon.insert({name=shellname[i],count=shellcount[i]})
			end
		end
	else
		game.print("ERROR: Artillery wagon failed to convert (this is not supposed to occur)")
	end
	return new_wagon
end

local function jam_artillery(event)
	if event.item == "artillery-jammer-tool" and event.entities ~= nil then
		local player = game.players[event.player_index]
		local i = 0
		local j = 0
		for _, wagon in pairs(event.entities) do
			local name = wagon.name
			local type = wagon.type
			if wagon.valid and (type == "artillery-wagon" or type == "artillery-turret") and not (string.sub(name,1,9) == "disabled-") then
				i=i+1
				local new_name = ("disabled-" .. name)
				local new_wagon = artillery_swap(wagon,new_name)
				rendering.draw_sprite{
					sprite = "utility.warning_icon",
					x_scale = 1, y_scale = 1,
					target_offset = {0.0,-0.25},
					render_layer = "entity-info-icon-above",
					target = new_wagon,
					surface = new_wagon.surface,
					forces = {new_wagon.force}
				}
			elseif wagon.valid and (type == "artillery-wagon" or type == "artillery-turret") and (string.sub(name,1,9) == "disabled-") then
				j=j+1
				local new_name = (string.sub(name,10,#name))
				artillery_swap(wagon,new_name)
			end
		end
		if game.is_multiplayer() == true then
			if i ~= 0 and j == 0 then
				player.force.print("Player " .. player.name .. " on surface " .. player.surface.name .. " has disabled " .. i .. " artillery")
			elseif i == 0 and j ~= 0 then
				player.force.print("Player " .. player.name .. " on surface " .. player.surface.name .. " has enabled " .. j .. " artillery")
			elseif i ~= 0 and j ~= 0 then
				player.force.print("Player " .. player.name .. " on surface " .. player.surface.name .. " has enabled " .. j .. " and disabled " .. i .. " artillery")
			end
		end
	end
end

local function draw_grid(player_index)
	local player = game.players[player_index]
	if global.shortcuts_grid[player_index] == nil then
		global.shortcuts_grid[player_index] = {}
	end
	-- game.print(#global.shortcuts_grid[player_index])
	if #global.shortcuts_grid[player_index] == 0 then
		player.set_shortcut_toggled("draw-grid", true)
		-- Opts
		local settings = settings.get_player_settings(player)
		local radius = settings["grid-radius"].value
		local step = settings["grid-step"].value
		local thinn_width = settings["grid-line-width"].value
		local thicc_width = settings["grid-chunk-line-width"].value
		local chunk_align = settings["grid-chunk-align"].value
		local ground_grid = settings["grid-ground"].value

		local center_x = math.floor(player.position.x)
		local center_y = math.floor(player.position.y)
		if chunk_align == true then
			center_x = math.floor(player.position.x/32)*32
			center_y = math.floor(player.position.y/32)*32
		end
		-- game.print(center_x .. ", " .. center_y)
		for i=-radius,(radius),step do
			if (center_x+i) % 32 == 0 then
				width = thicc_width
			else
				width = thinn_width
			end
			local line = rendering.draw_line{
				color = {r = 0, g = 0, b = 0, a = 1},
				width = width,
				from = {center_x+i,center_y+radius},
				to = {center_x+i,center_y-radius},
				surface = player.surface,
				players = {player},
				draw_on_ground = ground_grid
			}
			global.shortcuts_grid[player_index][#global.shortcuts_grid[player_index]+1] = line

			if (center_y+i) % 32 == 0 then
				width = thicc_width
			else
				width = thinn_width
			end
			local line = rendering.draw_line{
				color = {r = 0, g = 0, b = 0, a = 1},
				width = width,
				from = {center_x+radius,center_y+i},
				to = {center_x-radius,center_y+i},
				-- from = {center_x+radius,center_y+i}, -- 	this looks pretty cool (although not a grid)
				-- to = {center_x-i,center_y+radius},
				surface = player.surface,
				players = {player},
				draw_on_ground = ground_grid
			}
			global.shortcuts_grid[player_index][#global.shortcuts_grid[player_index]+1] = line
		end
	else
		player.set_shortcut_toggled("draw-grid", false)
		local grid = global.shortcuts_grid[player_index]
		for i=1,(#grid) do
			rendering.destroy(grid[i])
			grid[i] = nil
		end
	end
end

local function initialize()
	if global.shortcuts_light == nil then
		global.shortcuts_light = {}
	end
	if global.toggle_rail == nil then
		global.toggle_rail = {}
	end
	if global.shortcuts_armor == nil then
		global.shortcuts_armor = {}
	end
	if global.shortcuts_grid == nil then
		global.shortcuts_grid = {}
	end
end

script.on_event(defines.events.on_player_armor_inventory_changed, function(event)
		reset_state(event,0)
end)
script.on_event(defines.events.on_player_placed_equipment, function(event)
		reset_state(event,1)
end)
script.on_event(defines.events.on_player_removed_equipment, function(event)
		reset_state(event,2)
end)


local function shortcut_type(event)
	local prototype_name = event.prototype_name
	if prototype_name == "night-vision-equipment" then
		update_state(event, "night-vision-equipment")
		return
	elseif prototype_name == "belt-immunity-equipment" then
		update_state(event, "belt-immunity-equipment")
		return
	elseif prototype_name == "active-defense-equipment" then
		update_state(event, "active-defense-equipment")
		return
	elseif prototype_name == "big-zoom" then
		local player = game.players[event.player_index]
		if settings.global["disable-zoom"].value == true then
			player.zoom = settings.get_player_settings(player)["zoom-level"].value
		else
			player.print({"", {"error.error-message-box-title"}, ": ", {"controls.alt-zoom-out"}, " ", {"gui-mod-info.status-disabled"}})
		end
	elseif prototype_name == "draw-grid" then
		draw_grid(event.player_index)
	elseif prototype_name == "tree-killer" then
		local player = game.players[event.player_index]
		if player.cursor_stack.valid_for_read == false then
			if player.cursor_stack.can_set_stack({name="shortcuts-deconstruction-planner"}) then
				player.cursor_stack.set_stack({name="shortcuts-deconstruction-planner"})
				player.cursor_stack.trees_and_rocks_only = true
			end
		end
	elseif prototype_name == "artillery-jammer-remote" then
		local player = game.players[event.player_index]
			if player.clean_cursor() then
				player.cursor_stack.set_stack({name="artillery-jammer-tool"})
			end
	elseif prototype_name == "artillery-targeting-remote" then
		local player = game.players[event.player_index]
			if player.clean_cursor() then
				player.cursor_stack.set_stack({name="artillery-targeting-remote"})
			end
	elseif prototype_name == "discharge-defense-remote" then
		local player = game.players[event.player_index]
			if player.clean_cursor() then
				player.cursor_stack.set_stack({name="discharge-defense-remote"})
			end
	elseif prototype_name == "spidertron-remote" then
		local player = game.players[event.player_index]
			if player.clean_cursor() then
				player.cursor_stack.set_stack({name="spidertron-remote"})
			end
	elseif prototype_name == "path-remote-control" then
		local player = game.players[event.player_index]
			if player.clean_cursor() then
				player.cursor_stack.set_stack({name="path-remote-control"})
			end
	elseif prototype_name == "unit-remote-control" then
		local player = game.players[event.player_index]
			if player.clean_cursor() then
				player.cursor_stack.set_stack({name="unit-remote-control"})
			end
	elseif prototype_name == "artillery-cluster-remote" then
		local player = game.players[event.player_index]
			if player.clean_cursor() then
				player.cursor_stack.set_stack({name="artillery-cluster-remote"})
			end
	elseif prototype_name == "artillery-discovery-remote" then
		local player = game.players[event.player_index]
			if player.clean_cursor() then
				player.cursor_stack.set_stack({name="artillery-discovery-remote"})
			end
	elseif prototype_name == "ion-cannon-targeter" then
		local player = game.players[event.player_index]
			if player.clean_cursor() then
				player.cursor_stack.set_stack({name="ion-cannon-targeter"})
			end
	elseif prototype_name == "vehicle-wagon-2-winch" then
		local player = game.players[event.player_index]
			if player.clean_cursor() then
				player.cursor_stack.set_stack({name="winch"})
			end
	elseif prototype_name == "flashlight-toggle" then
		toggle_light(game.players[event.player_index])
	elseif prototype_name == "rail-block-visualization-toggle" then
		toggle_rail(game.players[event.player_index])
	elseif prototype_name == "signal-flare" then
		local player = game.players[event.player_index]
		if settings.global["disable-zoom"].value == true then
			player.force.print({"", "[img=utility.danger_icon] [color=1,0.1,0.1]", {"entity-name.character"}, " " ..  player.name .. " [gps=" .. math.floor(player.position.x+0.5) .. "," .. math.floor(player.position.y+0.5) ..  "][/color] [img=utility.danger_icon]"}) -- ickputzdirwech
		else
			player.print({"", {"error.error-message-box-title"}, ": ", {"technology-name.military"}, " ", {"entity-name.beacon"}, " ", {"gui-mod-info.status-disabled"}})
		end

	elseif prototype_name == "check-circuit" then
	local player = game.players[event.player_index]
		if player.clean_cursor() then
			player.cursor_stack.set_stack({name="check-circuit"})
		end
	elseif prototype_name == "squad-spidertron-remote" then
	local player = game.players[event.player_index]
		if player.clean_cursor() then
			player.cursor_stack.set_stack({name="squad-spidertron-remote"})
		end
	elseif prototype_name == "pump-shortcut" then
	local player = game.players[event.player_index]
		if player.clean_cursor() then
			player.cursor_stack.set_stack({name="pump-selection-tool"})
		end
	elseif prototype_name == "give-rail-signal-planner" then
	local player = game.players[event.player_index]
		if player.clean_cursor() then
			player.cursor_stack.set_stack({name="rail-signal-planner"})
		end
	elseif prototype_name == "well-planner" then
	local player = game.players[event.player_index]
		if player.clean_cursor() then
			player.cursor_stack.set_stack({name="well-planner"})
		end
	elseif prototype_name == "module-inserter" then
	local player = game.players[event.player_index]
		if player.clean_cursor() then
			player.cursor_stack.set_stack({name="module-inserter"})
		end

	end
end

script.on_event(defines.events.on_lua_shortcut, shortcut_type)

-- script.on_event(defines.events.on_player_main_inventory_changed, update_inventory)

script.on_event(defines.events.on_player_created, function(event)
	local player = game.players[event.player_index]
	if settings.startup["flashlight-toggle"].value == true then
		player.set_shortcut_toggled("flashlight-toggle", true)
	end
	if settings.startup["rail-block-visualization-toggle"].value == true then
		player.set_shortcut_toggled("rail-block-visualization-toggle", false)
	end

	if settings.startup["artillery-toggle"].value == "both" or settings.startup["artillery-toggle"].value == "Artillery wagon" or settings.startup["artillery-toggle"].value == "Artillery turret" then
		if player.force.technologies["artillery"].researched == false then
			player.set_shortcut_available("artillery-jammer-remote", false)
		end
	end
	if settings.startup["artillery-targeting-remote"].value == true then
		if player.force.technologies["artillery"].researched == false then
			player.set_shortcut_available("artillery-targeting-remote", false)
		end
	end
	if settings.startup["discharge-defense-remote"].value == true then
		if player.force.technologies["discharge-defense-equipment"].researched == false then
			player.set_shortcut_available("discharge-defense-remote", false)
		end
	end

	if settings.startup["aai-remote-controls"] then
		if settings.startup["aai-remote-controls"].value == true and player.force.technologies["automobilism"].researched == false and player.force.technologies["spidertron"].researched == false then
			player.set_shortcut_available("path-remote-control", false)
			player.set_shortcut_available("unit-remote-control", false)
		end
	end
	if settings.startup["artillery-targeting-remote"].value == true and game.active_mods["AdvArtilleryRemotes"] then
		if player.force.technologies["artillery"].researched == false then
			player.set_shortcut_available("artillery-cluster-remote", false)
			player.set_shortcut_available("artillery-discovery-remote", false)
		end
	end
	if settings.startup["ion-cannon-targeter"] then
		if settings.startup["ion-cannon-targeter"].value == true and player.force.technologies["orbital-ion-cannon"].researched == false then
			player.set_shortcut_available("ion-cannon-targeter", false)
		end
	end
	if settings.startup["rail-block-visualization-toggle"].value == true then
		if player.force.technologies["railway"].researched == false then
			player.set_shortcut_available("rail-block-visualization-toggle", false)
		end
	end
	if settings.startup["spidertron-remote"].value == "enabled" or "enabled (hide remote from inventory)" then
		if player.force.technologies["spidertron"].researched == false then
			player.set_shortcut_available("spidertron-remote", false)
		end
	end
	if settings.startup["vehicle-wagon-2-winch"] then
		if settings.startup["vehicle-wagon-2-winch"].value == true and player.force.technologies["vehicle-wagons"].researched == false then
			player.set_shortcut_available("vehicle-wagon-2-winch", false)
		end
	end

	if settings.startup["night-vision-equipment"].value == true then
		player.set_shortcut_available("night-vision-equipment", false)
	end
	if settings.startup["active-defense-equipment"].value == true then
		player.set_shortcut_available("active-defense-equipment", false)
	end
	if settings.startup["belt-immunity-equipment"].value == true then
		player.set_shortcut_available("belt-immunity-equipment", false)
	end

	if game.active_mods["circuit-checker"] then
		if player.force.technologies["circuit-network"].researched == false then
			player.set_shortcut_available("check-circuit", false)
		end
	end
	if game.active_mods["QoL-TempStations"] then
		if player.force.technologies["railway"].researched == false then
			player.set_shortcut_available("shortcut-temporarystations", false)
		end
	end
	if game.active_mods["Spider_Control"] then
		if player.force.technologies["spidertron"].researched == false then
			player.set_shortcut_available("squad-spidertron-follow", false)
			player.set_shortcut_available("squad-spidertron-remote", false)
		end
	end
	if game.active_mods["pump"] then
		if player.force.technologies["oil-processing"].researched == false then
			player.set_shortcut_available("pump-shortcut", false)
		end
	end
	if game.active_mods["RailSignalPlanner"] then
		if player.force.technologies["rail-signals"].researched == false then
			player.set_shortcut_available("give-rail-signal-planner", false)
		end
	end
	if game.active_mods["WellPlanner"] then
		if settings.startup["autogen-color"].value == "default" or settings.startup["autogen-color"].value == "red" or settings.startup["autogen-color"].value == "green" or settings.startup["autogen-color"].value == "blue" then
			if player.force.technologies["oil-processing"].researched == false then
				player.set_shortcut_available("well-planner", false)
			end
		end
	end
	if game.active_mods["car-finder"] then
		if player.force.technologies["automobilism"].researched == false and player.force.technologies["spidertron"].researched == false then
			player.set_shortcut_available("car-finder-button", false)
		end
	end
	if game.active_mods["VehicleSnap"] then
		if player.force.technologies["automobilism"].researched == false then
			player.set_shortcut_available("VehicleSnap-shortcut", false)
		end
	end
	if game.active_mods["ModuleInserter"] then
		if player.force.technologies["modules"].researched == false then
			player.set_shortcut_available("module-inserter", false)
		end
	end

	if game.active_mods["PickerInventoryTools"] and game.active_mods["Nanobots"] then
		if player.force.technologies["personal-roboport-equipment"].researched == false then
			player.set_shortcut_available("toggle-equipment-bot-chip-feeder", false)
			player.set_shortcut_available("toggle-equipment-bot-chip-items", false)
			player.set_shortcut_available("toggle-equipment-bot-chip-launcher", false)
			player.set_shortcut_available("toggle-equipment-bot-chip-nanointerface", false)
			player.set_shortcut_available("toggle-equipment-bot-chip-trees", false)
		end
	end

end)

script.on_event(defines.events.on_player_selected_area, jam_artillery)

script.on_init(initialize)
script.on_configuration_changed(initialize)
commands.add_command("shortcuts_initialize_variables", "debug: ensure that all global tables are not nil (should not happen in a normal game)", initialize)

script.on_event(defines.events.on_research_finished, function(event)
	for _,player in pairs(event.research.force.players) do
		
		if event.research and event.research.name == "artillery" then
			if settings.startup["artillery-toggle"].value == "both" or settings.startup["artillery-toggle"].value == "Artillery wagon" or settings.startup["artillery-toggle"].value == "Artillery turret" then
				player.set_shortcut_available("artillery-jammer-remote", true)
			end
			if settings.startup["artillery-targeting-remote"].value == true then
				player.set_shortcut_available("artillery-targeting-remote", true)
			end
			if settings.startup["artillery-targeting-remote"].value == true and game.active_mods["AdvArtilleryRemotes"] then
				player.set_shortcut_available("artillery-cluster-remote", true)
			end
			if settings.startup["artillery-targeting-remote"].value == true and game.active_mods["AdvArtilleryRemotes"] then
				player.set_shortcut_available("artillery-discovery-remote", true)
			end
		end
		if event.research and event.research.name == "discharge-defense-equipment" then
			if settings.startup["discharge-defense-remote"].value == true then
				player.set_shortcut_available("discharge-defense-remote", true)
			end
		end

		if settings.startup["aai-remote-controls"] then
			if event.research and (event.research.name == "automobilism" or "spidertron") and settings.startup["aai-remote-controls"].value == true then
				player.set_shortcut_available("path-remote-control", true)
				player.set_shortcut_available("unit-remote-control", true)
			end
		end
		if settings.startup["ion-cannon-targeter"] then
			if event.research and event.research.name == "orbital-ion-cannon" and settings.startup["ion-cannon-targeter"].value == true then
				player.set_shortcut_available("ion-cannon-targeter", true)
			end
		end
		if event.research and event.research.name == "railway" then
			if settings.startup["rail-block-visualization-toggle"].value == true then
				player.set_shortcut_available("rail-block-visualization-toggle", true)
			end
		end
		if event.research and event.research.name == "spidertron" then
			if settings.startup["spidertron-remote"].value == "enabled" or "enabled (hide remote from inventory)" then
				player.set_shortcut_available("spidertron-remote", true)
			end
		end
		if settings.startup["vehicle-wagon-2-winch"] then
			if event.research and event.research.name == "vehicle-wagons" and settings.startup["vehicle-wagon-2-winch"].value == true then
				player.set_shortcut_available("vehicle-wagon-2-winch", true)
			end
		end

		if event.research and event.research.name == "circuit-network" then
			if game.active_mods["circuit-checker"] then
				player.set_shortcut_available("check-circuit", true)
			end
		end
		if event.research and event.research.name == "railway" then
			if game.active_mods["QoL-TempStations"] then
				player.set_shortcut_available("shortcut-temporarystations", true)
			end
		end
		if event.research and event.research.name == "spidertron" then
			if game.active_mods["Spider_Control"] then
				player.set_shortcut_available("squad-spidertron-follow", true)
				player.set_shortcut_available("squad-spidertron-remote", true)
			end
		end
		if event.research and event.research.name == "oil-processing" then
			if game.active_mods["pump"] then
				player.set_shortcut_available("pump-shortcut", true)
			end
		end
		if event.research and event.research.name == "rail-signals" then
			if game.active_mods["RailSignalPlanner"] then
				player.set_shortcut_available("give-rail-signal-planner", true)
			end
		end
		if event.research and event.research.name == "oil-processing" then
			if game.active_mods["WellPlanner"] then
				if settings.startup["autogen-color"].value == "default" or settings.startup["autogen-color"].value == "red" or settings.startup["autogen-color"].value == "green" or settings.startup["autogen-color"].value == "blue" then
						player.set_shortcut_available("well-planner", true)
				end
			end
		end
		if event.research and event.research.name == "automobilism" or "spidertron" then
			if game.active_mods["car-finder"] then
				player.set_shortcut_available("car-finder-button", true)
			end
		end
		if event.research and event.research.name == "automobilism" then
			if game.active_mods["VehicleSnap"] then
				player.set_shortcut_available("VehicleSnap-shortcut", true)
			end
		end
		if event.research and event.research.name == "modules" then
			if game.active_mods["ModuleInserter"] then
				player.set_shortcut_available("module-inserter", true)
			end
		end

		if event.research and event.research.name == "personal-roboport-equipment" then
			if game.active_mods["PickerInventoryTools"] and game.active_mods["Nanobots"] then
				player.set_shortcut_available("toggle-equipment-bot-chip-feeder", true)
				player.set_shortcut_available("toggle-equipment-bot-chip-items", true)
				player.set_shortcut_available("toggle-equipment-bot-chip-launcher", true)
				player.set_shortcut_available("toggle-equipment-bot-chip-nanointerface", true)
				player.set_shortcut_available("toggle-equipment-bot-chip-trees", true)
			end
		end

	end
end)
