--[[ Copyright (c) 2019 - 2023 Picklock
 * Part of Picklocks Inserter
 * control.lua
 * Version 1.110.6.54
 *
 * See LICENSE.MD in the project directory for license information.
--]]

--variables
	--general
		
		local PI_debug = false
		local PI_print = false --set to false in multiplayer to avoid desyncs
		local PI_log = false
		
		local PI_general ={
			name = "Picklocks Inserter",
			version = "1.110.4",
			selector = "PI_inserter_selector",
			isControlSet = false,
			isAdmin = false,
			tick = 1
		}
	
	--databases
		PI_db_inserters = {}
		PI_db_internal ={
			index=0,
			cpt=10 		--purges per tick
		}

	--internal settings
		local PI_type = {
			assembler = "assembling-machine",
			car = "car",
			cargo = "cargo-wagon",
			chest = "container",
			furnace = "furnace",
			inserter = "inserter",
			item = "item-entity",
			lab = "lab",
			log_chest = "logistic-container",
			miner = "mining-drill",
			num = "number",
			tab = "table"
		}

		local PI_set = {
			unlock = "PI_temp_unlock",
			clear = "PI_clear_inserter",
			sel = "PI_target_selection",
			keep_sel = "PI_keep_selected",
			mark = "PI_set_mark",
			clear_max = "PI_clear_max",
			train_stop = "PI_target_train_stop",
			width = "PI_lines_to_check",
			length = "PI_extend_length"
		}

	--mod settings
		local PI_temp_unlock = settings.global[PI_set.unlock].value
		local PI_clear_inserter = settings.global[PI_set.clear].value
		local PI_target_selection  = settings.global[PI_set.sel].value
		local PI_keep_selected = settings.global[PI_set.keep_sel].value
		local PI_set_mark = settings.global[PI_set.mark].value
		local PI_clear_max  = settings.global[PI_set.clear_max].value
		local PI_target_train_stop = settings.global[PI_set.train_stop].value
		local PI_lines_to_check = settings.global[PI_set.width].value
		local PI_extend_length = settings.global[PI_set.length].value
	
--functions
	--debugging information
		function print_debug(msg)
			if PI_debug then
				--if PI_print then game.print("["..PI_general.name.." V" ..PI_general.version.. "]: "..msg) end
				if PI_print then
					for _, myPlayer in pairs(game.players) do
						myPlayer.print("["..PI_general.name.." V" ..PI_general.version.. "]: "..msg)
					end
				end
				if PI_log and PI_general.isAdmin then log("["..PI_general.name.." V" ..PI_general.version.. "]: "..msg) end
			end
		end
		
	--load
		local function PI_load(strSource)
			--local bolValue = PI_print
			--if strSource == "on_load" then PI_print = false end
			--PI_print = false
			--if PI_debug then print_debug("function started: PI_load - from " ..strSource) end
			--PI_print = bolValue
			if global.PI_db_inserters then PI_db_inserters = global.PI_db_inserters or {} end
			if PI_db_inserters == nil then PI_db_inserters = {} end
			if global.PI_db_internal then
				PI_db_internal = global.PI_db_internal or 
				{
					index=0,
					cpt=10 		--purges per tick
				}
			end
		end

	--save
--		local function PI_save()
--			--if PI_debug then print_debug("function started: PI_save") end
--			--global[PI_db.inserter] = PI_db_inserters
--		end

	--set Controls
		local function PI_set_controls (myPlayer)
			--if PI_debug then print_debug("function started: PI_set_controls") end
			myPlayer.set_shortcut_available("PI_inserter_selector_ui_sc",PI_target_selection)
			--if PI_debug then print_debug("PI_set_controls: set PI_inserter_selector_ui_sc to " ..tostring(myPlayer.is_shortcut_available("PI_inserter_selector_ui_sc")).. " for player " ..myPlayer.name ) end
			PI_general.isControlSet = true
		end

	--rounding
		local function round(x, n)
			n = math.pow(10, n or 0)
			x = x * n
			if x >= 0 then x = math.floor(x + 0.5) else x = math.ceil(x - 0.5) end
			return x / n
		end

	--Calculates bottom center of inserter to place mark there
		local function PI_get_Iserter_Position(myInserter)
			local pos_left_top = myInserter.prototype.selection_box.left_top
			local pos_right_bottom = myInserter.prototype.selection_box.right_bottom
			--Calculating center of inserter selection box
			local pos_center = (pos_left_top.x + pos_right_bottom.x) / 2
			--Calculating bottom center of the selection box
			local x = pos_center
			local y = pos_right_bottom.y
			return {x = myInserter.position.x + x, y = myInserter.position.y + y}
		end
		
	-- set mark
		local function PI_set_inserter_mark(myInserter)
			--if PI_debug then print_debug("function started: PI_set_inserter_mark") end
			local myMark = myInserter.surface.create_entity{name = "PI_mark", position = PI_get_Iserter_Position(myInserter), force = myInserter.force}
			myMark.graphics_variation = 1
			myMark.destructible = false
			return myMark
		end
		
	--remove nark
		local function PI_remove_inserter_mark(myMark)
			--if PI_debug then print_debug("function started: PI_remove_inserter_mark") end
			if myMark and myMark.valid then
				--if PI_debug then print_debug("PI_remove_inserter_mark: Removed mark") end
				myMark.destroy()
			end
		end
		
	--modify nark if mod-settings were changed
		local function PI_modify_all_marks (bolForce)
			--if PI_debug then print_debug("function started: PI_modify_all_marks") end
			--load DB from global
			PI_db_inserters = global.PI_db_inserters
			if PI_db_inserters and #PI_db_inserters > 0 then
				if not bolForce and PI_set_mark and PI_db_inserters[1].mark ~= nil then return end
				if not bolForce and not PI_set_mark and PI_db_inserters[1].mark == nil then return end
			end
			if PI_db_inserters ~= nil then
				for i = #PI_db_inserters, 1, -1 do
					if PI_set_mark then
						PI_db_inserters[i].mark = PI_set_inserter_mark (PI_db_inserters[i].inserter)
					else
						PI_remove_inserter_mark (PI_db_inserters[i].mark)
						PI_db_inserters[i].mark = nil					
					end 
				end
			end
			--save DB to global
			global.PI_db_inserters = PI_db_inserters
			
		end

	--put item stack into entity
		local function PI_PutStackBack(stack, entity)
			--if PI_debug then print_debug("function started: PI_PutStackBack") end
			if entity.type == PI_type.chest or entity.type == PI_type.log_chest then
				--if PI_debug then print_debug("entity.type: container or logistic-container") end
				if PI_temp_unlock then
					--if PI_debug then print_debug("settings: PI_temp_unlock enabled") end
					local entityInv = entity.get_inventory(1)
					local entityInvBar = entityInv.get_bar()
					entityInv.set_bar()
					stack.count = stack.count - entity.insert(stack)
					entityInv.set_bar(entityInvBar)
				else
					stack.count = stack.count - entity.insert(stack)
				end
			elseif entity.type == PI_type.assembler or entity.type == PI_type.furnace then
				--if PI_debug then print_debug("entity.type: assembling-machine or furnance") end
				stack.count = stack.count - entity.get_inventory(3).insert(stack)
			elseif entity.type == PI_type.miner or entity.type == PI_type.cargo then
				--if PI_debug then print_debug("entity.type: mining-drill or cargo-wagon") end
				stack.count = stack.count - entity.get_inventory(1).insert(stack)
			elseif entity.type == PI_type.car or entity.type == PI_type.lab then
				--if PI_debug then print_debug("entity.type: car or lab") end
				stack.count = stack.count - entity.get_inventory(2).insert(stack)
			elseif entity.type == PI_type.cargo or entity.type == PI_type.log_chest then
				--if PI_debug then print_debug("entity.type: cargo-wagon") end
				if PI_temp_unlock then
					--if PI_debug then print_debug("settings: PI_temp_unlock enabled") end
					local entityInv = entity.get_inventory(1)
					local entityInvBar = entityInv.get_bar()
					entityInv.set_bar()
					stack.count = stack.count - entity.insert(stack)
					entityInv.set_bar(entityInvBar)
				else
					stack.count = stack.count - entity.insert(stack)
				end
			end
			--if PI_debug then print_debug("PI_PutStackBack - stack.count: " ..tostring(stack.count)) end
			if stack.valid_for_read then
				--if PI_debug then print_debug("Stack could not be set back complete: " ..stack.count.. " " ..stack.name) end
				if PI_clear_inserter then
					--Delete items in hand of inserter
					if entity.type == PI_type.cargo then return end --exclude pickup entity "cargo-wagon"
					--if PI_debug then print_debug("settings: PI_clear_inserter enabled") end
					stack.clear()
					--if PI_debug then print_debug("Items in hand of inserter deleted") end
				end
			else
				--if PI_debug then print_debug("Stack was cleared succsessful") end
			end
			
		end

	--check inserter to be struck
		function PI_checkInserterIsStuck(myInserter)
			--if PI_debug then print_debug("function started: PI_checkInserterIsStuck") end   
			local myPickupTarget = myInserter.pickup_target
			if myPickupTarget == nil then return end
			if myInserter.held_stack.valid_for_read and myInserter.drop_position.x == myInserter.held_stack_position.x and myInserter.drop_position.y == myInserter.held_stack_position.y then
				--if PI_debug then print_debug("To be cleared: " ..myInserter.name.. "(" ..myInserter.type..  "/Pos:" ..myInserter.position.x.."/" ..myInserter.position.y.. "/Stack:" ..myInserter.held_stack.count.. " " ..myInserter.held_stack.name.. ")") end
				PI_PutStackBack(myInserter.held_stack, myPickupTarget)
			end
		end

	--add inserter to inserter list
		local function PI_addInserterToDB(myInserter)
			--if PI_debug then print_debug("function started: PI_addInserterToDB") end
			--load DB from global
			PI_db_inserters = global.PI_db_inserters
			if PI_db_inserters and #PI_db_inserters > 0 then
				for i = #PI_db_inserters, 1, -1 do
					if PI_db_inserters[i].inserter == myInserter then
						--if PI_debug then print_debug("PI_addInserterToDB: Inserter already in DB") end
						return
					end
				end
			end
			local myMark = nil
			--set mark
			if PI_set_mark then myMark = PI_set_inserter_mark(myInserter) end
			--add inserter
			if PI_db_inserters == nil then PI_db_inserters = {} end
			table.insert(PI_db_inserters, {inserter = myInserter, mark = myMark, tick = 1}) -- added tick
			--if PI_debug then print_debug("PI_addInserterToDB: Inserter added to DB") end
			--save DB to global
			global.PI_db_inserters = PI_db_inserters
		end

	--remove inserter from inserter list
		local function PI_remInserterFromDB(myInserter, intIndex)
			--if PI_debug then print_debug("function started: PI_remInserterFromDB") end
			--load DB from global
			PI_db_inserters = global.PI_db_inserters
			if intIndex then
				--if PI_debug then print_debug("PI_remInserterFromDB: Index given") end
				--remove mark
				PI_remove_inserter_mark (PI_db_inserters[intIndex].mark)
				table.remove(PI_db_inserters, intIndex)
				--save DB to global
				global.PI_db_inserters = PI_db_inserters
				--if PI_debug then print_debug("PI_remInserterFromDB: Inserter removed from DB") end
			else
				--if PI_debug then print_debug("PI_remInserterFromDB: Inserter given") end
				for i, myDBInserter in pairs(PI_db_inserters) do
					while PI_db_inserters[i] == nil do table.remove(PI_db_inserters, i) end
					--save DB to global
					global.PI_db_inserters = PI_db_inserters
					if PI_db_inserters[i].inserter == myInserter then
						--if PI_debug then print_debug("PI_remInserterFromDB: Inserter detected in DB") end
						PI_remInserterFromDB(myDBInserter, i)
						return
					end
				end
			end
		end

	--parse entity list and return only items with set type = inserter
		local function PI_parseSelectedEntityList(selEntities, myType, includeInactive)
			--if PI_debug then print_debug("function started: PI_parseSelectedEntityList") end
			local myTable = {}
			includeInactive = (includeInactive == true) and (myType ~= nil)
			for i, myEntity in pairs(selEntities) do
				if myEntity.valid and (myType == nil or myEntity.type == myType) and (includeInactive or myEntity.active) then
					table.insert(myTable, myEntity)
				end
			end
			return myTable
		end
	
	--parse inserter list
		local function PI_parseInserterList(myTick)
			--if PI_debug then print_debug("function started: PI_parseInserterList") end
			--load DB from global
			PI_db_inserters = global.PI_db_inserters
			if global.PI_db_internal then PI_db_internal = global.PI_db_internal end
			if PI_db_inserters and #PI_db_inserters > 0 then
				if PI_db_internal.index == 0 or PI_db_internal.index >= #PI_db_inserters then
					PI_db_internal.cpt = PI_clear_max
					PI_db_internal.index = 0
				end
				local i = PI_db_internal.index + 1
				while i <= (PI_db_internal.index + PI_db_internal.cpt) and i <= #PI_db_inserters do
				
					if PI_db_inserters[i] and PI_db_inserters[i].inserter and PI_db_inserters[i].inserter.valid then
						if myTick > (PI_db_inserters[i].tick + 120) then
							PI_checkInserterIsStuck (PI_db_inserters[i].inserter)
							if PI_keep_selected then
								PI_db_inserters[i].tick = myTick
								i = i + 1
							else
								--if PI_debug then print_debug("PI_parseInserterList: raised PI_remInserterFromDB") end
								PI_remInserterFromDB(_, i)
							end
						else
							i = i + 1
						end
					else
						PI_remInserterFromDB(_, i)
					end
				end
				PI_db_internal.index = PI_db_internal.index + PI_db_internal.cpt
			end
			--save DB to global
			global.PI_db_inserters = PI_db_inserters
			global.PI_db_internal = PI_db_internal
		end

	-- get Inserter around wagon
	-- code modified from Shia Inserter Cleaner mod by Shia https://mods.factorio.com/mod/shia-clear-inserter
		local function PI_getInsertersAroundWagon(myWagon)
			--if PI_debug then print_debug("function started: PI_getInsertersAroundWagon") end
			local inDirection = round(myWagon.orientation, 3) % 0.5
			local wagonArea = {}
			local px = round(myWagon.position.x, 2)
			local py = round(myWagon.position.y, 2)
			if inDirection == 0.25 then
				wagonArea = {
					{
						px - 3 - PI_extend_length,
						py - 1 - PI_lines_to_check
						
					},
					{
						px + 3 + PI_extend_length,
						py + 1 + PI_lines_to_check
					}
				}
				--if PI_debug then print_debug("Got area around cargo-wagon in driection "..inDirection) end
			elseif inDirection == 0 then
				wagonArea = {
					{
						px - 1 - PI_lines_to_check,
						py - 3 + PI_extend_length
					},
					{
						px + 1 + PI_lines_to_check,
						py + 3 + PI_extend_length
					}
				}
				--if PI_debug then print_debug("Got area around cargo-wagon in driection "..inDirection) end
			else
				wagonArea = {
					{
						px,
						py
					},
					{
						px,
						py
					}
				}
				--if PI_debug then print_debug("Cargo-wagon is not in a valid direction! Direction: "..inDirection) end
			end
			PI_inserters = myWagon.surface.find_entities_filtered({area=wagonArea, type = PI_type.inserter})
			--if PI_debug then print_debug("Filtered inserters around cargo-wagon") end
			for i,myInserter in pairs(PI_inserters) do
				--if PI_debug then print_debug("Detected: " ..myInserter.name.. "(" ..myInserter.type.. "/" ..myInserter.position.x.."/" ..myInserter.position.y..")") end
				PI_checkInserterIsStuck(myInserter) 
			end

		end
		
	-- get PI_inserter_selector in player hand
		local function PI_get_PI_inserter_selector (myPlayer)
			--if PI_debug then print_debug("function started: PI_get_PI_inserter_selector") end
			if PI_target_selection then
				--if PI_debug then print_debug("PI_get_PI_inserter_selector: Inserter purge planer enabled - crafting inserter purge planer") end
				--if myPlayer.clean_cursor() then -- bis V1.0
				if myPlayer.clear_cursor() then -- ab V1.1
					myPlayer.cursor_stack.set_stack({name="PI_inserter_selector", count=1})
				end
			end

		end
		
	-- remove all mark
		local function PI_remove_all_inserter_mark()
			--if PI_debug then print_debug("function started: PI_remove_all_inserter_mark") end
			--get all marks
			local pi_db_mark = game.surfaces[1].find_entities_filtered{name = "PI_mark"}
			--if PI_debug then print_debug("PI_remove_all_inserter_mark: fount marks: "..tostring(#pi_db_mark)) end
			--delete marks
			for _, myMark in pairs(pi_db_mark) do
				myMark.destroy()
			end
		end
	
		
-- handler

	--load
		script.on_init(function ()
			PI_load ("on_init")
			PI_remove_all_inserter_mark()
		end)

		script.on_load(function ()
			PI_load ("on_load")
		end)
	
	--CHeck if Mod-Settings or Mod-Version were changed since last load
		script.on_configuration_changed(function(myData)
			--ConfigurationChangedData
			--if PI_debug then print_debug("started script: on_configuration_changed") end
			local bolIsThisMod = false
			--if PI_debug then print_debug("on_configuration_changed: " ..tostring(myData.mod_startup_settings_changed)) end
			for myMod, myVersion in pairs(myData.mod_changes) do
				if myMod == "Picks-Inserter" then
					--if PI_debug then print_debug("on_configuration_changed: Mod gefunden: " ..myMod.. " " ..myVersion.new_version) end
					bolIsThisMod = true
				end
			end

			if myData.mod_startup_settings_changed or bolIsThisMod then
				--if PI_debug then print_debug("on_configuration_changed: update values for mod settings") end
				PI_temp_unlock = settings.global[PI_set.unlock].value
				PI_clear_inserter = settings.global[PI_set.clear].value
				PI_target_selection = settings.global[PI_set.sel].value
				PI_keep_selected = settings.global[PI_set.keep_sel].value
				PI_set_mark = settings.global[PI_set.mark].value
				PI_clear_max = settings.global[PI_set.clear_max].value
				PI_target_train_stop = settings.global[PI_set.train_stop].value
				PI_lines_to_check = settings.global[PI_set.width].value
				PI_extend_length = settings.global[PI_set.length].value
			end
		end)

	--mod setting
		script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
			--if PI_debug then print_debug("raised event: on_runtime_mod_setting_changed") end
			if not event or not event.player_index then return end 
			--PI_temp_unlock
			if event.setting == PI_set.unlock then PI_temp_unlock = settings.global[PI_set.unlock].value end
			--PI_clear_inserter
			if event.setting == PI_set.clear then PI_clear_inserter = settings.global[PI_set.clear].value end
			--PI_target_selection
			if event.setting == PI_set.sel then PI_target_selection = settings.global[PI_set.sel].value end
			--PI_keep_selected
			if event.setting == PI_set.keep_sel then PI_keep_selected = settings.global[PI_set.keep_sel].value end
			--PI_set_mark
			if event.setting == PI_set.mark then 
				PI_set_mark = settings.global[PI_set.mark].value
				PI_modify_all_marks (false)
			end
			--PI_clear_max
			if event.setting == PI_set.clear_max then PI_clear_max = settings.global[PI_set.clear_max].value end
			--PI_target_train_stop
			if event.setting == PI_set.train_stop then PI_target_train_stop = settings.global[PI_set.train_stop].value end
			--PI_temp_unlock
			if event.setting == PI_set.width then PI_lines_to_check = settings.global[PI_set.width].value end
			--PI_extend_length
			if event.setting == PI_set.length then PI_extend_length = settings.global[PI_set.length].value end
			--Set controls
			PI_set_controls(game.players[event.player_index])

		end)
		
	--player_created
		script.on_event(defines.events.on_player_created, function(event)
			PI_general.isAdmin = game.players[event.player_index].admin
			--if PI_debug then print_debug("raised event: on_player_joined_game") end
			PI_set_controls(game.players[event.player_index])
		end)

		
	--player_joined_game
		script.on_event(defines.events.on_player_joined_game, function(event)
			PI_general.isAdmin = game.players[event.player_index].admin
			--if PI_debug then print_debug("raised event: on_player_joined_game") end
			PI_set_controls(game.players[event.player_index])
		end)

	--train state
		-- 0 = defines.train_state.on_the_path	Normal state -- following the path.
		-- 1 = defines.train_state.path_lost	Had path and lost it -- must stop.
		-- 2 = defines.train_state.no_schedule	Doesn't have anywhere to go.	
		-- 3 = defines.train_state.no_path	Has no path and is stopped.
		-- 4 = defines.train_state.arrive_signal	Braking before a rail signal.
		-- 5 = defines.train_state.wait_signal	Waiting at a signal.
		-- 6 = defines.train_state.arrive_station	Braking before a station.
		-- 7 = defines.train_state.wait_station	Waiting at a station.
		-- 8 = defines.train_state.manual_control_stop	Switched to manual control and has to stop.
		-- 9 = defines.train_state.manual_control	Can move if user explicitly sits in and rides the train.
		--1ß = defines.train_state.destination_full	Same as no_path but all candidate train stops are full 
		script.on_event(defines.events.on_train_changed_state, function(event, old_state)
			--if PI_debug then 
			--	print_debug("raised event: on_train_changed_state fired by train " ..tostring(event.train.id))
			--	print_debug("train.state: " ..tostring(event.train.state))
			--	print_debug("old_state: " ..tostring(event.old_state))
			--end
			if PI_target_train_stop then
				--if PI_debug then print_debug("settings: PI_target_train_stop enabled") end
				--if event.train.state == 0 then
				if event.train.state == 0 or event.train.state == 3 or event.train.state == 5 or event.train.state == 10 then
					if event.old_state == 7 then
						if next(event.train.get_contents()) then
							--if PI_debug then print_debug("Detect cargo_wagons connected to train") end
							for i, myWagon in pairs(event.train.cargo_wagons) do
								--if PI_debug then print_debug("Detected: " ..myWagon.name.. "(" ..myWagon.type.. "/" ..myWagon.position.x.."/" ..myWagon.position.y..")") end
								PI_getInsertersAroundWagon(myWagon)
							end
						end
					end
				end
			end
		end)

	--select inserter
		script.on_event(defines.events.on_player_selected_area, function(event)
			--if PI_debug then print_debug("raised event: on_player_selected_area") end
			if event.item and event.item == PI_general.selector then
				--if PI_debug then print_debug("PI_inserter_selector detected") end
				local myTable = PI_parseSelectedEntityList(event.entities, PI_type.inserter, false)
				if #myTable then
					--if PI_debug then print_debug(table_size(myTable).. " Inserters selected") end
					for i, myInserter in pairs(myTable) do
						PI_addInserterToDB(myInserter)
					end
--					PI_save()
				end
			end
		end)

	--deselect inserters with alt
		script.on_event(defines.events.on_player_alt_selected_area, function(event)
			--if PI_debug then print_debug("raised event: on_player_alt_selected_area") end
			if event.item and event.item == PI_general.selector then
				--if PI_debug then print_debug("PI_inserter_selector detected") end
				local myTable = PI_parseSelectedEntityList(event.entities, PI_type.inserter, true)
				if #myTable then
					--if PI_debug then print_debug(table_size(myTable).. " Inserters selected") end
					for i, myInserter in pairs(myTable) do
						PI_remInserterFromDB(myInserter)
					end
--					PI_save()
				end
			end
		end)

	--tick
		script.on_event(defines.events.on_tick, function(event)
			--Set controls
			if not PI_general.isControlSet then 
				--if PI_debug then print_debug("raised event: on_tick: not PI_general.isControlSet") end
				PI_general.isAdmin = true
				-- PI_set_controls(game.players[1])
				PI_modify_all_marks (false)
			end
			--Work on Inserter List
			----if PI_debug then print_debug("raised event: on_tick") end
			PI_parseInserterList(event.tick)			
		end)

	--Control pressed inserter selector
		script.on_event("PI_inserter_selector_ui", function(event)
			--if PI_debug then print_debug("raised event: PI_inserter_selector_ui") end
			PI_get_PI_inserter_selector (game.players[event.player_index])
		end)
	
	--Control pressed delete all marks
		script.on_event("pi-orphan-mark-del-key", function(event)
			--if PI_debug then print_debug("raised event: pi-orphan-mark-del-key") end
			PI_remove_all_inserter_mark()
			PI_modify_all_marks (true)
		end)
	
	--Shrotcut selected
		script.on_event(defines.events.on_lua_shortcut, function(event)
			--if PI_debug then print_debug("raised event: on_lua_shortcut") end
			if (event.prototype_name == "PI_inserter_selector_ui_sc") then
			local myPlayer = game.players[event.player_index]
				--if PI_debug then print_debug("on_lua_shortcut: PI_inserter_selector_ui_sc detected") end
				PI_get_PI_inserter_selector (game.players[event.player_index])
			end
		end)
		
	--Remove entity
		--local e=defines.events
		--local remove_events = {e.on_player_mined_entity, e.on_robot_pre_mined, e.on_entity_died, e.script_raised_destroy}
		--script.on_event(remove_events, function(event)
		--	if PI_debug then print_debug("raised event: remove_events") end
		--	local myEntity = event.entity	
		--	if myEntity.type == PI_type.inserter then PI_remInserterFromDB(myEntity) end

		--end)

