-------------------------------------------------------------------------------
--[Reviver] -- Revives the selected entity
-------------------------------------------------------------------------------
local Event = require('__kry_stdlib__/stdlib/event/event')
local Area = require('__kry_stdlib__/stdlib/area/area')
local Player = require('__kry_stdlib__/stdlib/event/player')
local lib = require('utils/lib')
local debugger = false

--as of 08/30 this is mostly incorporated into base.
--Modules are still not revived,
--items on ground are not picked up
--tile proxys are not selected  Should be added to pippette to put in hand

local rail_entities = {
	["rail-ramp"] = 1,
	["rail-support"] = 1,

	["straight-rail"] = 1,
	["elevated-straight-rail"] = 1,

	["half-diagonal-rail"] = 2,
	["elevated-half-diagonal-rail"] = 2,

	["curved-rail-a"] = 3,
	["curved-rail-b"] = 3,
	["elevated-curved-rail-a"] = 3,
	["elevated-curved-rail-b"] = 3
}

local function revive_it(event)
    local placed = event.entity
    if not lib.ghosts[placed.name] and Area(placed.selection_box):size() > 0 then
        local player = game.get_player(event.player_index)
        lib.satisfy_requests(player, placed)
    else
        -- Auto reviver hack, stops autobuilding when placing a ghost item from an item (alt mode)
        local _, pdata = Player.get(event.player_index)
        pdata.next_revive_tick = event.tick + 1
    end
end
Event.register(defines.events.on_built_entity, revive_it)

local function picker_revive_selected(event)
    local player = game.players[event.player_index]
    local selected = player.selected
    if selected and player.controller_type ~= defines.controllers.ghost then
        if selected.name == 'item-on-ground' then
            return player.mine_entity(selected)
        elseif selected.item_request_proxy and not player.cursor_stack.valid_for_read then
            lib.satisfy_requests(player, selected)
        end
    end
end
Event.register('picker-select', picker_revive_selected)

-- handles the actual ghost revival logic
local function revive_object(player,selected,name)
	local direction = selected.direction or defines.direction.north
	local position = selected.position
	if selected.type == 'underground-belt' or selected.ghost_type == 'underground-belt' then
		if selected.belt_to_ground_type == 'output' then
			direction = (direction + 8) % 16
		end
		local belt_type = selected.belt_to_ground_type
		player.build_from_cursor {position = position, direction = direction}
		local ent = player.surface.find_entity(name, position)
		if ent then
			if ent.belt_to_ground_type ~= belt_type then
				ent.rotate()
			end
		end
	elseif selected.type == 'pipe-to-ground' or selected.ghost_type == 'pipe-to-ground' then
		player.build_from_cursor {position = position, direction = direction}
		local ent = player.surface.find_entity(name, position)
		if ent and ent.direction ~= direction then
			ent.direction = direction
		end
	else
		player.build_from_cursor {position = position, direction = direction}
	end
end

-- handles ghost revival logic for rails
local function revive_rails(player,stack,selected)
	local rail_cost = rail_entities[selected.ghost_name]
	local pinv = player.get_main_inventory()
	local quality = selected.quality.name
	local pinv_rail_count = pinv.get_item_count{name="rail",quality=quality}
	-- auto place rail ramps from inventory
	if selected.ghost_name == "rail-ramp" then
		local pinv_ramp_count = pinv.get_item_count{name="rail-ramp",quality=quality}
		if pinv_ramp_count >= rail_cost then
			local _, revived_entity = selected.revive{raise_revive=true}
			-- if the revive worked, then remove the amount of items
			if revived_entity then
				pinv.remove{name="rail-ramp",count=1,quality=quality}
			end
		end
	-- auto place rail supports from inventory
	elseif selected.ghost_name == "rail-support" then
		local pinv_support_count = pinv.get_item_count{name="rail-support",quality=quality}
		if pinv_support_count >= rail_cost then
			local _, revived_entity = selected.revive{raise_revive=true}
			-- if the revive worked, then remove the amount of items
			if revived_entity then
				pinv.remove{name="rail-support",count=1,quality=quality}
			end
		end
	-- if player has enough rails in inventory, use those first
	elseif pinv_rail_count >= rail_cost then
		local _, revived_entity = selected.revive{raise_revive=true}
		-- if the revive worked, then subtract the rail_cost
		if revived_entity then
			pinv.remove{name="rail",count=rail_cost,quality=quality}
		end
	-- otherwise, use rails from cursor instead
	elseif stack.count >= rail_cost then
		local _, revived_entity = selected.revive{raise_revive=true}
		-- if the revive worked, then subtract the rail_cost
		if revived_entity then
			stack.count = stack.count - rail_cost
		end
	end
end

-- handles solar productivity when that mod is enabled
local function solar_productivity_check(stack,selected)
	-- all solar productivity entities are prefixed with "sp-"
	if not selected.ghost_name:match("^sp%-") then
		--game.print("name did not match: "..ghost_name)
		return false
	end
	-- ghost type must be either solar panel or accumulator
	if selected.ghost_type ~= "solar-panel" and selected.ghost_type ~= "accumulator" then
		--game.print("ghost type not solar panel or accumulator: "..selected.ghost_type)
		return false
	end
	-- the stack type must match the cursor place type
	if selected.ghost_type ~= stack.prototype.place_result.type then
		--game.print("ghost type "..selected.ghost_type.." did not match "..stack.prototype.place_result.type)
		return false
	end
	-- all checks have passed, so we return true
	return true
end

--- Automatically revive ghosts when hovering over them with the item in hand.
local function picker_revive_selected_ghosts(event)
    local player, pdata = Player.get(event.player_index)
    local selected = player.selected
	-- shorthand for settings
	local revive_ghost_entity = player.mod_settings['picker-revive-selected-ghosts-entity'].value
	local revive_ghost_tile = player.mod_settings['picker-revive-selected-ghosts-tile'].value
	local revive_ghost_upgrade = player.mod_settings['picker-revive-selected-ghosts-upgrade'].value
	local ignore_quality = player.mod_settings['picker-revive-ignore-quality'].value
	-- if cursor is not empty, not a blueprint, player is not a ghost, is hovered over an entity, has any ghost revival setting enabled, and is holding a valid item in the cursor
    if not player.is_cursor_empty() and not player.is_cursor_blueprint() and player.controller_type ~= defines.controllers.ghost and selected and pdata.ghost_revive and player.cursor_stack and player.cursor_stack.valid_for_read then
        local stack = player.cursor_stack
		if debugger then
			local msg = "Properties: "
			msg = msg.."\nName: "..selected.name
			msg = msg.."\nGhost Name: "..selected.ghost_name
			msg = msg.."\nType: "..selected.type
			msg = msg.."\nGhost Type: "..selected.ghost_type
			msg = msg.."\nStack Name: "..stack.prototype.place_result.name
			msg = msg.."\nStack Type: "..stack.prototype.place_result.type
			game.print(msg)
		end
		-- check if hovering over ghost entity, then try to place
		if selected.type == 'entity-ghost' and revive_ghost_entity then
			-- ghost rail revival logic
			if stack.type == "rail-planner" and stack.name ~= "rail-ramp" and rail_entities[selected.ghost_name] and pdata.next_revive_tick ~= event.tick then
				if stack.quality == selected.quality then
					revive_rails(player,stack,selected)
					goto continue
				end
			end
			-- other ghost revival logic
			if stack.prototype.place_result == prototypes.entity[selected.ghost_name] and pdata.next_revive_tick ~= event.tick then
				if ignore_quality or stack.quality == selected.quality then
					revive_object(player,selected,selected.ghost_name)
					goto continue
				end
			end
			-- solar productivity check
			if script.active_mods["solar-productivity"] and solar_productivity_check(stack, selected) then
				if ignore_quality or stack.quality == selected.quality then
					revive_object(player,selected,selected.ghost_name)
					goto continue
				end
			end
		end
		-- check if ghost upgrade, and try to place
		if selected.to_be_upgraded() and stack.prototype.place_result and selected.type == stack.prototype.place_result.type and revive_ghost_upgrade then
			local target_prototype, target_quality = selected.get_upgrade_target()
			if stack.type == 'rail-planner' and rail_entities[target_prototype.name] then
				if ignore_quality or stack.quality == selected.quality then
					-- cannot upgrade rails from cursor?
					--player.build_from_cursor {position = selected.position, direction = selected.direction}
					goto continue
				end
			end
			if target_prototype and stack.name == target_prototype.name and pdata.next_revive_tick ~= event.tick then
				--game.print(stack.quality.name.." and "..target_quality.name)
				if ignore_quality or stack.quality.name == target_quality.name then
					if selected.type == 'underground-belt' or selected.type == 'pipe-to-ground' then
						revive_object(player,selected,target_prototype)
					-- the function breaks when checking ghost properties that don't exist
					else player.build_from_cursor {position = selected.position, direction = selected.direction}
					end
					goto continue
				end
			end
		end
		-- check if ghost tile, and try to place
		if selected.type == 'tile-ghost' and revive_ghost_tile then
			local tile = stack.prototype.place_as_tile_result
			if tile and tile.result == prototypes.tile[selected.ghost_name] and pdata.next_revive_tick ~= event.tick then
				if ignore_quality or stack.quality == selected.quality then
					player.build_from_cursor {position = selected.position, direction = selected.direction, terrain_building_size = 1}
					goto continue
				end
			end
		end
		::continue::
    end
end
Event.register(defines.events.on_selected_entity_changed, picker_revive_selected_ghosts)

--- Toggles the variable to that enables automatic ghost reviver function.
local function toggle_ghost_revive(event)
	-- event.prototype_name is used when on_lua_shortcut was fired
	-- event.input_name is used when the custom-input hotkey was fired
	local event_name = event.prototype_name or event.input_name
	if event_name == "toggle-ghost-revive" then
		local player, pdata = Player.get(event.player_index)
		local setting = player.mod_settings['picker-revive-selected-ghosts-entity'].value or player.mod_settings['picker-revive-selected-ghosts-tile'].value or player.mod_settings['picker-revive-selected-ghosts-upgrade'].value
		-- check if revive functionality is enabled in settings first
		if setting then
			-- if the value does not exist, create and set it to true
			if pdata.ghost_revive == nil then
				pdata.ghost_revive = true
			else	-- otherwise, toggle the existing value 
				pdata.ghost_revive = not pdata.ghost_revive
			end
			-- then update the shortcut icon
			player.set_shortcut_toggled("toggle-ghost-revive", pdata.ghost_revive)
			--game.print("toggled to: "..tostring(pdata.ghost_revive))
		else	-- provide a message if attempt to toggle when setting is disabled
			player.print("Automatic Ghost Revive is disabled in player settings.")
		end
	end
end
Event.register('toggle-ghost-revive', toggle_ghost_revive)
Event.register(defines.events.on_lua_shortcut, toggle_ghost_revive)

-- Enable auto ghost revive on first load or when joining multiplayer game
local function init_ghost_revive_settings(event)
	local player, pdata = Player.get(event.player_index)
	local setting = player.mod_settings['picker-revive-selected-ghosts-entity'].value or player.mod_settings['picker-revive-selected-ghosts-tile'].value
    player.set_shortcut_toggled("toggle-ghost-revive", setting)
	pdata.ghost_revive = setting
end
Event.register(defines.events.on_player_joined_game, init_ghost_revive_settings)
Event.register(defines.events.on_cutscene_cancelled, init_ghost_revive_settings)

-- Update ghost revive shortcut toggle when relevant mod setting is changed (during runtime)
local function update_ghost_revive_settings(event)
	if event.setting == "picker-revive-selected-ghosts-entity" or event.setting == "picker-revive-selected-ghosts-tile" then
		local player, pdata = Player.get(event.player_index)
		local setting = player.mod_settings['picker-revive-selected-ghosts-entity'].value or player.mod_settings['picker-revive-selected-ghosts-tile'].value
		player.set_shortcut_toggled("toggle-ghost-revive", setting)
		pdata.ghost_revive = setting
	end
end
Event.register(defines.events.on_runtime_mod_setting_changed, update_ghost_revive_settings)

local function on_first_load(data)
	if game.players then if game.players[1] then
		local player = game.players[1]
		player, pdata = Player.get(player.index)
		local setting = player.mod_settings['picker-revive-selected-ghosts-entity'].value or player.mod_settings['picker-revive-selected-ghosts-tile'].value
		player.set_shortcut_toggled("toggle-ghost-revive", setting)
		pdata.ghost_revive = setting
	end end
end
--Event.register(Event.core_events.init_and_config, init_and_config_ghost_revive)
Event.on_configuration_changed(on_first_load)