-------------------------------------------------------------------------------
--[Reviver] -- Revives the selected entity
-------------------------------------------------------------------------------
local Event = require('__kry_stdlib__/stdlib/event/event')
local Area = require('__kry_stdlib__/stdlib/area/area')
local Player = require('__kry_stdlib__/stdlib/event/player')
local lib = require('utils/lib')
debugger = true

--as of 08/30 this is mostly incorporated into base.
--Modules are still not revived -- this is fixed in utils/lib
--items on ground are not picked up
--tile proxys are not selected  Should be added to pippette to put in hand

-- entity types that counts as "rails" for the family revival
local rail_family = {
	-- standard rails
	["straight-rail"] = true,
	["half-diagonal-rail"] = true,
	["curved-rail-a"] = true,
	["curved-rail-b"] = true,
	-- elevated rails
	["elevated-straight-rail"] = true,
	["elevated-half-diagonal-rail"] = true,
	["elevated-curved-rail-a"] = true,
	["elevated-curved-rail-b"] = true,
	-- ramps and supports
	["rail-ramp"] = true,
	["rail-support"] = true,
	-- legacy rails that may still be used by migrated saves
	["legacy-straight-rail"] = true,
	["legacy-curved-rail"] = true,
	-- rail signals
	["rail-signal"] = true,
	["rail-chain-signal"] = true
}

-- entity types that count as "belts" for family revival
local belt_family = {
	["transport-belt"] = true,
	["underground-belt"] = true,
	["splitter"] = true,
}

-- entity types that count as "pipes" for family revival
local pipe_family = {
	["pipe"] = true,
	["pipe-to-ground"] = true,
}

-- entity ghosts that should revive from ghost data instead of build_from_cursor
local ghost_revive_preferred = {
	-- for some reason, can't revive ghost signals on elevated rails using build_from_cursor
	["rail-signal"] = true,
	["rail-chain-signal"] = true,
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

-- returns true if the held cursor item is in the same family as the selected ghost
local function cursor_matches_ghost_family(stack, selected)
	if selected.type ~= "entity-ghost" then return false end
	if not stack or not stack.valid_for_read then return false end

	local ghost_type = selected.ghost_type
	local place_result = stack.prototype.place_result
	local cursor_type = place_result and place_result.type or nil

	-- any rail-family cursor item can trigger revival for any rail-family ghost
	if rail_family[ghost_type] then
		if string.match(stack.type, "rail") or rail_family[cursor_type] then
			return true
		end
	end

	-- any inserter can trigger revival for any inserter
	if ghost_type == "inserter" and cursor_type == "inserter" then
		return true
	end

	-- any belt/splitter/underground can trigger revival for any belt/splitter/underground
	if belt_family[ghost_type] and belt_family[cursor_type] then
		return true
	end

	-- any pipe/pipe-to-ground can trigger revival for any pipe/pipe-to-ground
	if pipe_family[ghost_type] and pipe_family[cursor_type] then
		return true
	end

	return false
end

-- revives the selected ghost by consuming its required item from inventory
local function revive_from_inventory_item(player, selected, item_to_place, ignore_quality)
	local pinv = player.get_main_inventory()
	if not pinv then return false end

	local cost = item_to_place.count or 1
	local quality = selected.quality and selected.quality.name or nil

	local _, revived_entity = selected.revive{raise_revive = true}
	if not revived_entity then return false end

	if ignore_quality then
		pinv.remove{
			name = item_to_place.name,
			count = cost,
		}
	else
		pinv.remove{
			name = item_to_place.name,
			count = cost,
			quality = quality,
		}
	end

	lib.satisfy_requests(player, revived_entity)

	return true
end

-- finds an inventory item that can build the selected ghost
local function get_inventory_item_to_place_ghost(player, selected, ignore_quality)
	if selected.type ~= "entity-ghost" then return nil end

	local pinv = player.get_main_inventory()
	if not pinv then return nil end

	local ghost_proto = selected.ghost_prototype
	if not ghost_proto then return nil end

	local items = ghost_proto.items_to_place_this
	if type(items) ~= "table" then return nil end

	local quality = selected.quality and selected.quality.name or nil

	for _, item in pairs(items) do
		local count = item.count or 1

		local available
		if ignore_quality then
			available = pinv.get_item_count(item.name)
		else
			available = pinv.get_item_count{
				name = item.name,
				quality = quality,
			}
		end

		if available >= count then
			return item
		end
	end

	return nil
end

-- returns true if quality does not matter, or if both qualities match
local function quality_matches(stack, selected, ignore_quality)
	return ignore_quality or stack.quality == selected.quality
end

-- returns true when item in cursor can directly place the ghost entity
local function cursor_places_ghost_directly(stack, selected)
	if selected.type ~= "entity-ghost" then return false end
	if not stack or not stack.valid_for_read then return false end

	local place_result = stack.prototype.place_result
	if not place_result then return false end

	return place_result == selected.ghost_prototype
end

-- returns the items_to_place_this entry matching the held cursor item
local function get_item_to_place_prototype_entry(stack, entity_proto)
	if not stack or not stack.valid_for_read then return nil end
	if not entity_proto then return nil end

	local items = entity_proto.items_to_place_this
	if type(items) ~= "table" then return nil end

	for _, item in pairs(items) do
		if item.name == stack.name then
			return item
		end
	end

	return nil
end

-- returns the matching placeable_by item entry for the selected ghost
local function get_item_to_place_entry(stack, selected)
	if selected.type ~= "entity-ghost" then return nil end
	return get_item_to_place_prototype_entry(stack, selected.ghost_prototype)
end

-- true if the held item can upgrade to this target prototype
local function cursor_can_upgrade_to_target(stack, target_prototype)
	if not stack or not stack.valid_for_read then return false end
	if not target_prototype then return false end

	local place_result = stack.prototype.place_result

	-- simple case: held item directly places the upgrade target
	if place_result and place_result == target_prototype then
		return true
	end

	-- advanced case: target entity is placeable_by the held item
	return get_item_to_place_prototype_entry(stack, target_prototype) ~= nil
end

-- upgrades normally when possible, otherwise applies upgrade and consumes placeable_by cost
local function upgrade_from_cursor_or_placeable_by(player, stack, selected, target_prototype)
	if not target_prototype then return false end

	local place_result = stack.prototype.place_result

	-- simple direct item case: old behavior can use build_from_cursor
	if place_result and place_result == target_prototype then
		player.build_from_cursor {
			position = selected.position,
			direction = selected.direction
		}
		return true
	end

	-- advanced case: target is placeable_by the held item
	local item_to_place = get_item_to_place_prototype_entry(stack, target_prototype)
	if not item_to_place then return false end

	local cost = item_to_place.count or 1
	if stack.count < cost then return false end

	local upgraded_entity, second_upgraded_entity = selected.apply_upgrade()
	if not upgraded_entity then return false end

	stack.count = stack.count - cost

	-- Handles module requests / request proxy cleanup after scripted upgrade.
	lib.satisfy_requests(player, upgraded_entity)

	if second_upgraded_entity then
		lib.satisfy_requests(player, second_upgraded_entity)
	end

	return true
end

-- handles entities that can use build_from_cursor
local function revive_from_cursor(player, selected, name)
	local direction = selected.direction or defines.direction.north
	local position = selected.position

	if selected.type == 'underground-belt' or selected.ghost_type == 'underground-belt' then
		if selected.belt_to_ground_type == 'output' then
			direction = (direction + 8) % 16
		end

		local belt_type = selected.belt_to_ground_type
		player.build_from_cursor {position = position, direction = direction}

		local ent = player.surface.find_entity(name, position)
		if ent and ent.belt_to_ground_type ~= belt_type then
			ent.rotate()
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

-- advanced path: manually consume cost based on items_to_place_this,
-- then revive the ghost, and satisfy module/item requests on the revived entity if possible
local function revive_from_placeable_by(player, stack, selected, item_to_place)
	local cost = item_to_place.count or 1
	local quality = selected.quality and selected.quality.name or nil

	-- Prefer consuming the cursor stack, because this event is specifically cursor-driven.
	if stack.count < cost then return false end

	local _, revived_entity = selected.revive{raise_revive = true}
	if not revived_entity then return false end

	stack.count = stack.count - cost

	lib.satisfy_requests(player, revived_entity)

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
		-- check if hovering over ghost entity, then try to place
		if selected.type == 'entity-ghost' and revive_ghost_entity and pdata.next_revive_tick ~= event.tick then
			if quality_matches(stack, selected, ignore_quality) then
				-- simple case: cursor item directly places this exact ghost entity
				if cursor_places_ghost_directly(stack, selected) then
					if ghost_revive_preferred[selected.ghost_type] then
						local item_to_place = get_item_to_place_entry(stack, selected)

						if item_to_place and revive_from_placeable_by(player, stack, selected, item_to_place) then
							goto continue
						end
					else
						revive_from_cursor(player, selected, selected.ghost_name)
						goto continue
					end
				end
				-- advanced case: ghost says this cursor item can build it via placeable_by/items_to_place_this
				local item_to_place = get_item_to_place_entry(stack, selected)
				if item_to_place then
					if revive_from_placeable_by(player, stack, selected, item_to_place) then
						goto continue
					end
				end

				-- family case: held item only needs to match the same broad build family
				if cursor_matches_ghost_family(stack, selected) then
					local inventory_item = get_inventory_item_to_place_ghost(player, selected, ignore_quality)

					if inventory_item then
						if revive_from_inventory_item(player, selected, inventory_item, ignore_quality) then
							goto continue
						end
					end
				end
			end
		end
		-- check if ghost upgrade, and try to place
		if selected.to_be_upgraded() and revive_ghost_upgrade and pdata.next_revive_tick ~= event.tick then
			local target_prototype, target_quality = selected.get_upgrade_target()
			if target_prototype and cursor_can_upgrade_to_target(stack, target_prototype) then
				if ignore_quality or stack.quality.name == target_quality.name then
					if upgrade_from_cursor_or_placeable_by(player, stack, selected, target_prototype, target_quality) then
						goto continue
					end
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