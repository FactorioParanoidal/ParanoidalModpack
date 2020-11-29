--[[ Copyright (c) 2019 npc_strider
 * For direct use of code or graphics, credit is appreciated and encouraged. See LICENSE.txt for more information.
 * This mod may contain modified code sourced from base/core Factorio.
 * This mod has been modified by ickputzdirwech.
]]

--[[ Overview of control.lua:
	* Scripts for updating armor, drawing grids and managing toggles and variables.
		- Equipment functions
		- Reset equipment states
		- Debug
	* Scripts for artillery cannon fire selection tool
	* Scripts for basic shortcuts
		- Character lamp
		- Emergency locator beacon
		- Grid
		- Rail block visualisation
		- Zoom
	* Script for shortcuts that give an item
	* Scripts for spidertron shortcuts
		- Enable/disable logistics while moving
		- Auto targeting without gunner
		- Auto targeting with gunner
	* Scripts for on_lua_shortcut
	* Scripts for custom inputs
	* Scripts to enable and disable shortcuts on_player_created and on_research_finished
]]

---------------------------------------------------------------------------------------------------
-- EQUIPMENT FUNCTIONS
---------------------------------------------------------------------------------------------------
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

---------------------------------------------------------------------------------------------------
-- RESET EQUIPMENT STATE
---------------------------------------------------------------------------------------------------
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

script.on_event(defines.events.on_player_armor_inventory_changed, function(event)
		reset_state(event,0)
end)
script.on_event(defines.events.on_player_placed_equipment, function(event)
		reset_state(event,1)
end)
script.on_event(defines.events.on_player_removed_equipment, function(event)
		reset_state(event,2)
end)

---------------------------------------------------------------------------------------------------
-- DEBUG
---------------------------------------------------------------------------------------------------
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

script.on_init(initialize)
script.on_configuration_changed(initialize)
commands.add_command("shortcuts_initialize_variables", "debug: ensure that all global tables are not nil (should not happen in a normal game)", initialize)

---------------------------------------------------------------------------------------------------
-- TOGGLE ARTILLERY CANNON FIRE SELECTION TOOL
---------------------------------------------------------------------------------------------------
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

script.on_event(defines.events.on_player_selected_area, function(event)
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
end)

if settings.startup["artillery-toggle"].value == "both" or settings.startup["artillery-toggle"].value == "artillery-turret" or settings.startup["artillery-toggle"].value == "artillery-wagon" then
	script.on_event(defines.events.on_robot_built_entity, function(event)
		local entity = event.created_entity
		if (entity.type == "artillery-turret" or entity.type == "artillery-wagon") and string.sub(entity.name,1,9) == "disabled-" then
			rendering.draw_sprite{
				sprite = "utility.warning_icon",
				x_scale = 1, y_scale = 1,
				target_offset = {0.0,-0.25},
				render_layer = "entity-info-icon-above",
				target = entity,
				surface = entity.surface,
				forces = {entity.force}
			}
		end
	end)
end

---------------------------------------------------------------------------------------------------
-- BASIC
---------------------------------------------------------------------------------------------------
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

local function signal_flare(player)
	if settings.global["disable-zoom"].value == true then
		player.force.print({"", "[img=utility.danger_icon] [color=1,0.1,0.1]", {"entity-name.character"}, " " ..  player.name .. " [gps=" .. math.floor(player.position.x+0.5) .. "," .. math.floor(player.position.y+0.5) ..  "][/color] [img=utility.danger_icon]"})
	else
		player.print({"", {"error.error-message-box-title"}, ": ", {"technology-name.military"}, " ", {"entity-name.beacon"}, " ", {"gui-mod-info.status-disabled"}})
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

local function big_zoom(player)
	if settings.global["disable-zoom"].value == true then
		player.zoom = settings.get_player_settings(player)["zoom-level"].value
	else
		player.print({"", {"error.error-message-box-title"}, ": ", {"controls.alt-zoom-out"}, " ", {"gui-mod-info.status-disabled"}})
	end
end

---------------------------------------------------------------------------------------------------
-- GIVE ITEM
---------------------------------------------------------------------------------------------------
local allowed_items = {
	"artillery-cluster-remote",
	"artillery-discovery-remote",
	"artillery-jammer-tool",
	"artillery-targeting-remote",
	"check-circuit",
	"discharge-defense-remote",
	"ion-cannon-targeter",
	"mirv-targeting-remote",
	"module-inserter",
	"path-remote-control",
	"unit-remote-control",
	"spidertron-remote",
	"squad-spidertron-remote",
	"tree-killer",
	"well-planner",
	"winch"}

local function give_shortcut_item(player, prototype_name)
	if game.item_prototypes[prototype_name] and player.clear_cursor() then
		player.cursor_stack.set_stack({name = prototype_name})
		if prototype_name == "tree-killer" then
			player.cursor_stack.trees_and_rocks_only = true
		end
	end
end

---------------------------------------------------------------------------------------------------
-- SPIDERTRON
---------------------------------------------------------------------------------------------------
local function spidertron_shortcuts(player, player_vehicle, prototype_name)
	player.set_shortcut_available(prototype_name, true)
	if player_vehicle == true then
		player.set_shortcut_toggled(prototype_name, true)
	elseif player_vehicle == false then
		player.set_shortcut_toggled(prototype_name, false)
	end
end

script.on_event(defines.events.on_player_driving_changed_state, function(event)
	local player = game.players[event.player_index]
	if settings.startup["spidertron-logistics"].value == true then
		if player.driving == true then
			if player.vehicle.type == "spider-vehicle" then
				spidertron_shortcuts(player, player.vehicle.enable_logistics_while_moving, "spidertron-logistics")
			end
		end
		if player.driving == false then
			player.set_shortcut_available("spidertron-logistics", false)
		end
	end
	if settings.startup["spidertron-automatic-targeting"].value == true then
		if player.driving == true then
			if player.vehicle.type == "spider-vehicle" then
				spidertron_shortcuts(player, player.vehicle.vehicle_automatic_targeting_parameters.auto_target_without_gunner, "targeting-without-gunner")
				spidertron_shortcuts(player, player.vehicle.vehicle_automatic_targeting_parameters.auto_target_with_gunner, "targeting-with-gunner")
			end
		end
		if player.driving == false then
			player.set_shortcut_available("targeting-without-gunner", false)
			player.set_shortcut_available("targeting-with-gunner", false)
		end
	end
end)

script.on_event(defines.events.on_gui_closed, function(event)
	if event.gui_type == 1 and event.entity.type == "spider-vehicle" and event.entity.get_driver() ~= nil then
		local driver = event.entity.get_driver()
		if driver.is_player() then
			if settings.startup["spidertron-logistics"].value == true then
				spidertron_shortcuts(driver, event.entity.enable_logistics_while_moving, "spidertron-logistics")
			end
			if settings.startup["spidertron-automatic-targeting"].value == true then
				spidertron_shortcuts(driver, event.entity.vehicle_automatic_targeting_parameters.auto_target_without_gunner, "targeting-without-gunner")
				spidertron_shortcuts(driver, event.entity.vehicle_automatic_targeting_parameters.auto_target_with_gunner, "targeting-with-gunner")
			end
		else --If driver is a character
			if settings.startup["spidertron-logistics"].value == true then
				spidertron_shortcuts(driver.player, event.entity.enable_logistics_while_moving, "spidertron-logistics")
			end
			if settings.startup["spidertron-automatic-targeting"].value == true then
				spidertron_shortcuts(driver.player, event.entity.vehicle_automatic_targeting_parameters.auto_target_without_gunner, "targeting-without-gunner")
				spidertron_shortcuts(driver.player, event.entity.vehicle_automatic_targeting_parameters.auto_target_with_gunner, "targeting-with-gunner")
			end
		end
	end
end)

---------------------------------------------------------------------------------------------------
-- ON LUA SHORTCUT
---------------------------------------------------------------------------------------------------
script.on_event(defines.events.on_lua_shortcut, function(event)
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
	elseif prototype_name == "big-zoom" then
		big_zoom(player)

-- VEHICLE
	elseif prototype_name == "spidertron-logistics" then
		if player.driving == true then
			if player.vehicle.type == "spider-vehicle" then
				if player.vehicle.enable_logistics_while_moving == true then
					player.vehicle.enable_logistics_while_moving = false
					player.set_shortcut_toggled(prototype_name, false)
				else
					player.vehicle.enable_logistics_while_moving = true
					player.set_shortcut_toggled(prototype_name, true)
				end
			end
		end
	elseif prototype_name == "targeting-without-gunner" then
	if player.driving == true then
		if player.vehicle.type == "spider-vehicle" then
			if player.vehicle.vehicle_automatic_targeting_parameters.auto_target_without_gunner == true then
				local params = player.vehicle.vehicle_automatic_targeting_parameters
				params.auto_target_without_gunner = false
				player.vehicle.vehicle_automatic_targeting_parameters = params
				player.set_shortcut_toggled(prototype_name, false)
			else
				local params = player.vehicle.vehicle_automatic_targeting_parameters
				params.auto_target_without_gunner = true
				player.vehicle.vehicle_automatic_targeting_parameters = params
				player.set_shortcut_toggled(prototype_name, true)
			end
		end
	end
	elseif prototype_name == "targeting-with-gunner" then
		if player.driving == true then
			if player.vehicle.type == "spider-vehicle" then
				if player.vehicle.vehicle_automatic_targeting_parameters.auto_target_with_gunner == true then
					local params = player.vehicle.vehicle_automatic_targeting_parameters
					params.auto_target_with_gunner = false
					player.vehicle.vehicle_automatic_targeting_parameters = params
					player.set_shortcut_toggled(prototype_name, false)
				else
					local params = player.vehicle.vehicle_automatic_targeting_parameters
					params.auto_target_with_gunner = true
					player.vehicle.vehicle_automatic_targeting_parameters = params
					player.set_shortcut_toggled(prototype_name, true)
				end
			end
		end

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

-- GIVE ITEM
	elseif prototype_name == "pump-shortcut" then
		give_shortcut_item(player, "pump-selection-tool")
	elseif prototype_name == "give-rail-signal-planner" then
		give_shortcut_item(player, "rail-signal-planner")
	elseif prototype_name == "cliff-fish-item-on-ground" then
		 give_shortcut_item(player, "tree-killer")
		 if	player.cursor_stack.name == "tree-killer" then
			player.cursor_stack.trees_and_rocks_only = false
			player.cursor_stack.entity_filters = {game.entity_prototypes["cliff"].name, game.entity_prototypes["fish"].name, game.entity_prototypes["item-on-ground"].name}
		end
	elseif game.shortcut_prototypes[prototype_name] then
		for _, item_name in pairs(allowed_items) do
			if item_name == prototype_name then
				give_shortcut_item(player, prototype_name)
			end
		end
	end
end)

---------------------------------------------------------------------------------------------------
-- CUSTOM INPUTS
---------------------------------------------------------------------------------------------------
-- BASIC
if settings.startup["flashlight-toggle"].value == true then
	script.on_event("flashlight-toggle", function(event)
	  toggle_light(game.players[event.player_index])
	end)
end
if settings.startup["signal-flare"].value == true then
	script.on_event("signal-flare", function(event)
	  signal_flare(game.players[event.player_index])
	end)
end
if settings.startup["draw-grid"].value == true then
	script.on_event("draw-grid", function(event)
		draw_grid(event.player_index)
	end)
end
if settings.startup["rail-block-visualization-toggle"].value == true then
	script.on_event("rail-block-visualization-toggle", function(event)
	  toggle_rail(game.players[event.player_index])
	end)
end
if settings.startup["big-zoom"].value == true then
	script.on_event("big-zoom", function(event)
	  big_zoom(game.players[event.player_index])
	end)
end

-- BLUEPRINT
if settings.startup["tree-killer"].value == true then
	script.on_event("tree-killer", function(event)
		give_shortcut_item(game.players[event.player_index], "tree-killer")
	end)
	script.on_event("cliff-fish-item-on-ground", function(event)
		local player = game.players[event.player_index]
		give_shortcut_item(player, "tree-killer")
		if player.cursor_stack.name == "tree-killer" then
			player.cursor_stack.trees_and_rocks_only = false
			player.cursor_stack.entity_filters = {game.entity_prototypes["cliff"].name, game.entity_prototypes["fish"].name, game.entity_prototypes["item-on-ground"].name}
		end
	end)
end
if settings.startup["well-planner"] and settings.startup["well-planner"].value == true then
	script.on_event("well-planner", function(event)
		if game.players[event.player_index].force.technologies["oil-processing"].researched == true then
			give_shortcut_item(game.players[event.player_index], "well-planner")
		end
	end)
end

-- ARTILLERY
if settings.startup["artillery-targeting-remote"].value == true then
	script.on_event("artillery-targeting-remote", function(event)
		if game.players[event.player_index].force.technologies["artillery"].researched == true then
			give_shortcut_item(game.players[event.player_index], "artillery-targeting-remote")
		end
	end)
end
local artillery_toggle = settings.startup["artillery-toggle"].value
if artillery_toggle == "both" or artillery_toggle == "artillery-wagon" or artillery_toggle == "artillery-turret" then
	script.on_event("artillery-jammer-tool", function(event)
		if game.players[event.player_index].force.technologies["artillery"].researched == true then
			give_shortcut_item(game.players[event.player_index], "artillery-jammer-tool")
		end
	end)
end
if settings.startup["mirv-targeting-remote"] and settings.startup["mirv-targeting-remote"].value == true then
	script.on_event("mirv-targeting-remote", function(event)
		if game.players[event.player_index].force.technologies["mirv-technology"].researched == true then
			give_shortcut_item(game.players[event.player_index], "mirv-targeting-remote")
		end
	end)
end
if settings.startup["ion-cannon-targeter"] and settings.startup["ion-cannon-targeter"].value == true then
	script.on_event("ion-cannon-targeter", function(event)
		if game.players[event.player_index].force.technologies["orbital-ion-cannon"].researched == true then
			give_shortcut_item(game.players[event.player_index], "ion-cannon-targeter")
		end
	end)
end

-- EQUIPMENT
if settings.startup["belt-immunity-equipment"].value == true then
	script.on_event("belt-immunity-equipment", function(event)
		update_state(event, "belt-immunity-equipment")
		return
	end)
end
if settings.startup["discharge-defense-remote"].value == true then
	script.on_event("discharge-defense-remote", function(event)
		if game.players[event.player_index].force.technologies["discharge-defense-equipment"].researched == true then
			give_shortcut_item(game.players[event.player_index], "discharge-defense-remote")
		end
	end)
end
if settings.startup["night-vision-equipment"].value == true then
	script.on_event("night-vision-equipment", function(event)
		update_state(event, "night-vision-equipment")
		return
	end)
end
if settings.startup["active-defense-equipment"].value == true then
	script.on_event("active-defense-equipment", function(event)
		update_state(event, "active-defense-equipment")
		return
	end)
end

-- VEHICLES
if settings.startup["spidertron-remote"].value == "enabled" or settings.startup["spidertron-remote"].value == "enabled-hidden" then
	script.on_event("spidertron-remote", function(event)
		if game.players[event.player_index].force.technologies["spidertron"].researched == true then
			give_shortcut_item(game.players[event.player_index], "spidertron-remote")
		end
	end)
end
if settings.startup["spidertron-logistics"].value == true then
	script.on_event("spidertron-logistics", function(event)
		local player = game.players[event.player_index]
		if player.driving == true then
			if player.vehicle.type == "spider-vehicle" then
				if player.vehicle.enable_logistics_while_moving == true then
					player.vehicle.enable_logistics_while_moving = false
					player.set_shortcut_toggled("spidertron-logistics", false)
				else
					player.vehicle.enable_logistics_while_moving = true
					player.set_shortcut_toggled("spidertron-logistics", true)
				end
			end
		end
	end)
end
if settings.startup["spidertron-automatic-targeting"].value == true then
	script.on_event("targeting-without-gunner", function(event)
		local player = game.players[event.player_index]
		if player.driving == true and player.vehicle.type == "spider-vehicle" then
			if player.vehicle.vehicle_automatic_targeting_parameters.auto_target_without_gunner == true then
				local params = player.vehicle.vehicle_automatic_targeting_parameters
				params.auto_target_without_gunner = false
				player.vehicle.vehicle_automatic_targeting_parameters = params
				player.set_shortcut_toggled("targeting-without-gunner", false)
			else
				local params = player.vehicle.vehicle_automatic_targeting_parameters
				params.auto_target_without_gunner = true
				player.vehicle.vehicle_automatic_targeting_parameters = params
				player.set_shortcut_toggled("targeting-without-gunner", true)
			end
		end
	end)
	script.on_event("targeting-with-gunner", function(event)
		local player = game.players[event.player_index]
		if player.driving == true and player.vehicle.type == "spider-vehicle" then
			if player.vehicle.vehicle_automatic_targeting_parameters.auto_target_with_gunner == true then
				local params = player.vehicle.vehicle_automatic_targeting_parameters
				params.auto_target_with_gunner = false
				player.vehicle.vehicle_automatic_targeting_parameters = params
				player.set_shortcut_toggled("targeting-with-gunner", false)
			else
				local params = player.vehicle.vehicle_automatic_targeting_parameters
				params.auto_target_with_gunner = true
				player.vehicle.vehicle_automatic_targeting_parameters = params
				player.set_shortcut_toggled("targeting-with-gunner", true)
			end
		end
	end)
end
if settings.startup["winch"] and settings.startup["winch"].value == true then
	script.on_event("winch", function(event)
		if game.players[event.player_index].force.technologies["vehicle-wagons"].researched == true then
			give_shortcut_item(game.players[event.player_index], "winch")
		end
	end)
end

---------------------------------------------------------------------------------------------------
-- ON PLAYER CREATED
---------------------------------------------------------------------------------------------------
script.on_event(defines.events.on_player_created, function(event)
	local player = game.players[event.player_index]
	local tech = player.force.technologies
	local setting = settings.startup
	local mod = game.active_mods

	if setting["flashlight-toggle"].value == true then
		player.set_shortcut_toggled("flashlight-toggle", true)
	end
	if setting["active-defense-equipment"].value == true then
		player.set_shortcut_available("active-defense-equipment", false)
	end
	if setting["belt-immunity-equipment"].value == true then
		player.set_shortcut_available("belt-immunity-equipment", false)
	end
	if setting["night-vision-equipment"].value == true then
		player.set_shortcut_available("night-vision-equipment", false)
	end
	if setting["spidertron-logistics"].value == true then
		player.set_shortcut_available("spidertron-logistics", false)
	end
	if setting["spidertron-automatic-targeting"].value == true then
		player.set_shortcut_available("targeting-without-gunner", false)
		player.set_shortcut_available("targeting-with-gunner", false)
	end

	if tech["automobilism"].researched == false and mod["VehicleSnap"] then
		player.set_shortcut_available("VehicleSnap-shortcut", false)
	end

	if tech["artillery"].researched == false then
		local artillery_toggle = setting["artillery-toggle"].value
		if artillery_toggle == "both" or artillery_toggle == "artillery-wagon" or artillery_toggle == "artillery-turret" then
			player.set_shortcut_available("artillery-jammer-tool", false)
		end
		if setting["artillery-targeting-remote"].value == true then
			player.set_shortcut_available("artillery-targeting-remote", false)
			if mod["AdvArtilleryRemotes"] then
				player.set_shortcut_available("artillery-cluster-remote", false)
				player.set_shortcut_available("artillery-discovery-remote", false)
			end
		end
	end

	if mod["circuit-checker"] and tech["circuit-network"].researched == false then
		player.set_shortcut_available("check-circuit", false)
	end

	if tech["discharge-defense-equipment"].researched == false and setting["discharge-defense-remote"].value == true then
		player.set_shortcut_available("discharge-defense-remote", false)
	end

	if mod["MIRV"] and tech["mirv-technology"].researched == false and setting["mirv-targeting-remote"].value == true then
		player.set_shortcut_available("mirv-targeting-remote", false)
	end

	if tech["modules"].researched == false and mod["ModuleInserter"] then
		player.set_shortcut_available("module-inserter", false)
	end

	if tech["oil-processing"].researched == false then
		if mod["pump"] then
			player.set_shortcut_available("pump-shortcut", false)
		end
		if mod["WellPlanner"] and setting["well-planner"].value == true then
			player.set_shortcut_available("well-planner", false)
		end
	end

	if mod["Orbital Ion Cannon"] and tech["orbital-ion-cannon"].researched == false and setting["ion-cannon-targeter"].value == true then
		player.set_shortcut_available("ion-cannon-targeter", false)
	end

	if tech["personal-roboport-equipment"].researched == false and mod["PickerInventoryTools"] and mod["Nanobots"] then
		player.set_shortcut_available("toggle-equipment-bot-chip-feeder", false)
		player.set_shortcut_available("toggle-equipment-bot-chip-items", false)
		player.set_shortcut_available("toggle-equipment-bot-chip-launcher", false)
		player.set_shortcut_available("toggle-equipment-bot-chip-nanointerface", false)
		player.set_shortcut_available("toggle-equipment-bot-chip-trees", false)
	end

	if tech["rail-signals"].researched == false and mod["RailSignalPlanner"] then
		player.set_shortcut_available("give-rail-signal-planner", false)
	end

	if tech["railway"].researched == false then
		if setting["rail-block-visualization-toggle"].value == true then
			player.set_shortcut_toggled("rail-block-visualization-toggle", false)
		end
		if mod["QoL-TempStations"] then
			player.set_shortcut_available("shortcut-temporarystations", false)
		end
	end

	if tech["spidertron"].researched == false then
		local spidertron_remote = setting["spidertron-remote"].value
		if spidertron_remote == "enabled" or spidertron_remote == "enabled-hidden" then
			player.set_shortcut_available("spidertron-remote", false)
		end
		if mod["Spider_Control"] then
			player.set_shortcut_available("squad-spidertron-follow", false)
			player.set_shortcut_available("squad-spidertron-remote", false)
		end
		if mod["SpidertronWaypoints"] then
			player.set_shortcut_available("spidertron-remote-waypoint", false)
			player.set_shortcut_available("spidertron-remote-patrol", false)
		end
		if tech["automobilism"].researched == false then
			if mod["aai-programmable-vehicles"] and setting["aai-remote-controls"].value == true then
				player.set_shortcut_available("path-remote-control", false)
				player.set_shortcut_available("unit-remote-control", false)
			end
			if mod["car-finder"] then
				player.set_shortcut_available("car-finder-button", false)
			end
		end
	end

	if mod["VehicleWagon2"] and tech["vehicle-wagons"].researched == false and setting["winch"].value == true then
		player.set_shortcut_available("winch", false)
	end

end)

---------------------------------------------------------------------------------------------------
-- ON RESEARCH FINISHED
---------------------------------------------------------------------------------------------------
script.on_event(defines.events.on_research_finished, function(event)
	for _,player in pairs(event.research.force.players) do
		local research = event.research.name
		local setting = settings.startup
		local mod = game.active_mods

		if research == "automobilism" and mod["VehicleSnap"] then
			player.set_shortcut_available("VehicleSnap-shortcut", true)
		end

		if research == "automobilism" or research == "spidertron" then
			if mod["aai-programmable-vehicles"] and setting["aai-remote-controls"].value == true then
				player.set_shortcut_available("path-remote-control", true)
				player.set_shortcut_available("unit-remote-control", true)
			end
			if mod["car-finder"] then
				player.set_shortcut_available("car-finder-button", true)
			end
		end

		if research == "artillery" then
			local artillery_toggle = setting["artillery-toggle"].value
			if artillery_toggle == "both" or artillery_toggle == "artillery-wagon" or artillery_toggle == "artillery-turret" then
				player.set_shortcut_available("artillery-jammer-tool", true)
			end
			if setting["artillery-targeting-remote"].value == true then
				player.set_shortcut_available("artillery-targeting-remote", true)
				if mod["AdvArtilleryRemotes"] then
					player.set_shortcut_available("artillery-cluster-remote", true)
					player.set_shortcut_available("artillery-discovery-remote", true)
				end
			end
		end

		if research == "circuit-network" and mod["circuit-checker"] then
			player.set_shortcut_available("check-circuit", true)
		end

		if research == "discharge-defense-equipment" and setting["discharge-defense-remote"].value == true then
			player.set_shortcut_available("discharge-defense-remote", true)
		end

		if research == "mirv-technology" and mod["MIRV"] and setting["mirv-targeting-remote"].value == true then
			player.set_shortcut_available("mirv-targeting-remote", true)
		end

		if research == "modules" and mod["ModuleInserter"] then
			player.set_shortcut_available("module-inserter", true)
		end

		if research == "oil-processing" then
			if mod["pump"] then
				player.set_shortcut_available("pump-shortcut", true)
			end
			if mod["WellPlanner"] and setting["well-planner"].value == true then
				player.set_shortcut_available("well-planner", true)
			end
		end

		if research == "orbital-ion-cannon" and mod["Orbital Ion Cannon"] and setting["ion-cannon-targeter"].value == true then
			player.set_shortcut_available("ion-cannon-targeter", true)
		end

		if research == "personal-roboport-equipment" and mod["PickerInventoryTools"] and mod["Nanobots"] then
			player.set_shortcut_available("toggle-equipment-bot-chip-feeder", true)
			player.set_shortcut_available("toggle-equipment-bot-chip-items", true)
			player.set_shortcut_available("toggle-equipment-bot-chip-launcher", true)
			player.set_shortcut_available("toggle-equipment-bot-chip-nanointerface", true)
			player.set_shortcut_available("toggle-equipment-bot-chip-trees", true)
		end

		if research == "rail-signals" and mod["RailSignalPlanner"] then
			player.set_shortcut_available("give-rail-signal-planner", true)
		end

		if research == "railway" then
			if setting["rail-block-visualization-toggle"].value == true then
				player.set_shortcut_available("rail-block-visualization-toggle", true)
			end
			if mod["QoL-TempStations"] then
				player.set_shortcut_available("shortcut-temporarystations", true)
			end
		end

		if research == "spidertron" then
			local spidertron_remote = setting["spidertron-remote"].value
			if spidertron_remote == "enabled" or spidertron_remote == "enabled-hidden" then
				player.set_shortcut_available("spidertron-remote", true)
			end
			if mod["Spider_Control"] then
				player.set_shortcut_available("squad-spidertron-follow", true)
				player.set_shortcut_available("squad-spidertron-remote", true)
			end
			if mod["SpidertronWaypoints"] then
				player.set_shortcut_available("spidertron-remote-waypoint", true)
				player.set_shortcut_available("spidertron-remote-patrol", true)
			end
		end

		if research == "vehicle-wagons" and mod["VehicleWagon2"] and setting["winch"].value == true then
			player.set_shortcut_available("winch", true)
		end

	end
end)
