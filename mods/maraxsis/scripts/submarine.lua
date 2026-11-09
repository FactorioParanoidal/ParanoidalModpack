local TRENCH_MOVEMENT_FACTOR = maraxsis_constants.TRENCH_MOVEMENT_FACTOR
local SUBMARINES = maraxsis_constants.SUBMARINES

local function trench_generation_sanity_check()
    maraxsis.sync_trench_map_seed()
end

maraxsis.on_event(maraxsis.events.on_init(), function()
    storage.submarines = storage.submarines or {}
    storage.previous_spidertron_remote_selection = storage.previous_spidertron_remote_selection or {}
    trench_generation_sanity_check()
end)

maraxsis.on_event(maraxsis.events.on_built(), function(event)
    local entity = event.entity
    if not entity.valid then return end
    if not SUBMARINES[entity.name] then return end

    storage.submarines[entity.unit_number] = entity
end)

local function exit_submarine(event)
    local player = game.get_player(event.player_index)
    if not player or not player.valid then return end
    local selected = player.selected
    local selected_submarine = selected and selected.valid and SUBMARINES[selected.name]
    local vehicle = player.vehicle

    if not vehicle or not SUBMARINES[vehicle.name] or selected_submarine then return end

    if not player.character then return end
    local safe_position = player.surface.find_non_colliding_position(player.character.name, player.position, 15, 0.5, false)
    player.vehicle.set_driver(nil)
    player.driving = false
    if not safe_position then return end
    trench_generation_sanity_check()
    player.teleport(safe_position)
end
maraxsis.register_delayed_function("exit_submarine", exit_submarine)

---when the player presses 'enter' on a submarine, should it succeed?
---@param player LuaPlayer
---@param submarine LuaEntity?
---@return boolean
local function can_enter_submarine(player, submarine)
    if not (submarine and submarine.valid and SUBMARINES[submarine.name]) then return false end
    if player.vehicle == submarine then return false end
    if player.surface ~= submarine.surface or not player.force.is_friend(submarine.force_index) then return false end

    local reach = player.character and player.character.reach_distance or 0
    reach = reach * 3
    local a = player.position
    local b = submarine.position
    local distance = math.sqrt((a.x - b.x) ^ 2 + (a.y - b.y) ^ 2)
    if distance > reach then return false end

    local has_driver = not not submarine.get_driver()
    local has_passenger = not not submarine.get_passenger()
    if has_driver and has_passenger then return false end

    return true
end

---@param player LuaPlayer
---@param submarine LuaEntity
local function enter_submarine(player, submarine)
    if not player.valid or not submarine.valid then return end

    if submarine.get_driver() == player or (player.is_player() and submarine.get_driver() == player.character) then return end

    local has_driver = not not submarine.get_driver()
    local has_passenger = not not submarine.get_passenger()

    if has_driver and has_passenger then
        return
    elseif has_driver then
        submarine.set_passenger(player)
    else
        submarine.set_driver(player)
    end
    storage.breath[player.index] = nil
end
maraxsis.register_delayed_function("enter_submarine", enter_submarine)

local OPPOSITE_SURFACE = {
    [maraxsis_constants.TRENCH_SURFACE_NAME] = maraxsis_constants.MARAXSIS_SURFACE_NAME,
    [maraxsis_constants.MARAXSIS_SURFACE_NAME] = maraxsis_constants.TRENCH_SURFACE_NAME,
}

---determines if the submarine should rise to the surface or sink to the bottom. returns nil if surface transfer is impossible
---@param submarine LuaEntity
---@return LuaSurface?, MapPosition?
local function determine_submerge_direction(submarine)
    local position = submarine.position
    local surface = submarine.surface
    local surface_name = surface.name

    local opposite_surface_name = OPPOSITE_SURFACE[surface_name]
    if not opposite_surface_name then return end
    local target_surface = game.planets[opposite_surface_name].create_surface()

    if surface_name == maraxsis_constants.MARAXSIS_SURFACE_NAME then
        local tile_at_surface = surface.get_tile(position)
        if not tile_at_surface.valid or tile_at_surface.name ~= "maraxsis-trench-entrance" then
            for _, player in pairs(game.connected_players) do
                player.create_local_flying_text {
                    text = {"maraxsis.cannot-submerge"},
                    position = position,
                    create_at_cursor = false
                }
            end
            surface.play_sound {
                path = "utility/cannot_build",
                position = position,
                volume_modifier = 1
            }
            return nil
        end
        local target_position = {x = position.x * TRENCH_MOVEMENT_FACTOR, y = position.y * TRENCH_MOVEMENT_FACTOR}
        trench_generation_sanity_check()
        target_surface.request_to_generate_chunks(target_position, 1)
        target_surface.force_generate_chunk_requests()
        target_position = target_surface.find_non_colliding_position(submarine.name, target_position, 40, 0.5, false) or target_position
        if not target_position then return nil end
        return target_surface, target_position
    elseif surface_name == maraxsis_constants.TRENCH_SURFACE_NAME then
        local target_position = {x = position.x / TRENCH_MOVEMENT_FACTOR, y = position.y / TRENCH_MOVEMENT_FACTOR}
        trench_generation_sanity_check()
        target_surface.request_to_generate_chunks(target_position, 1)
        target_surface.force_generate_chunk_requests()
        local tile_at_surface = target_surface.get_tile(target_position)
        if tile_at_surface.valid and tile_at_surface.name ~= "maraxsis-trench-entrance" then
            for _, player in pairs(game.connected_players) do
                player.create_local_flying_text {
                    text = {"maraxsis.rocks-in-the-way"},
                    position = position,
                    create_at_cursor = false
                }
            end
            surface.play_sound {
                path = "utility/cannot_build",
                position = position,
                volume_modifier = 1
            }
            return nil
        end
        return target_surface, target_position
    end

    return nil
end

local function play_submerge_sound(target, position)
    target.play_sound {
        path = "maraxsis-submerge",
        position = position,
        volume_modifier = 1
    }
end
maraxsis.register_delayed_function("play_submerge_sound", play_submerge_sound)

-- https://github.com/notnotmelon/maraxsis/issues/341
maraxsis.register_delayed_function("post_sub_teleport_inventory_restoration", function(submarine, toolbelt, lua_inventory, inventory_indicies)
    if not submarine.valid then
        if lua_inventory.valid then
            lua_inventory.destroy()
        end
        return
    end

    local function remove_hidden_toolbelt_equipment()
        local grid = submarine.grid
        if not grid then return end
        if not toolbelt.valid then return end
        assert(grid.take{equipment = toolbelt})
    end

    local function transfer_inventory_back_to_submarine()
        if not lua_inventory.valid then return end
        local inventory = submarine.get_inventory(defines.inventory.spider_trunk)
        for _, i in pairs(inventory_indicies) do
            lua_inventory[i].swap_stack(inventory[i])
        end
        lua_inventory.destroy()
    end

    remove_hidden_toolbelt_equipment()
    transfer_inventory_back_to_submarine()
end)

local function teleport_submarine(submarine, target_position, target_surface,has_player)
    local grid = submarine.grid
    if has_player then
        for i = 1,64 do
        local theta = i*(2/64)*math.pi
        local x = target_position.x + 2*math.cos(theta)
        local y = target_position.y + 2*math.sin(theta)
        target_surface.create_trivial_smoke{
            name = "maraxsis-bubbles",
            position = {x=x,y=y}
        }
        end
        for i = 1,96 do
            local theta = i*(2/96)*math.pi
            local x = target_position.x + 2.5*math.cos(theta)
            local y = target_position.y + 2.5*math.sin(theta)
            target_surface.create_trivial_smoke{
                name = "maraxsis-bubbles",
                position = {x=x,y=y}
            }
        end
        for i = 1,129 do
            local theta = i*(2/128)*math.pi
            local x = target_position.x + 3*math.cos(theta)
            local y = target_position.y + 3*math.sin(theta)
            target_surface.create_trivial_smoke{
                name = "maraxsis-bubbles",
                position = {x=x,y=y}
            }
        end
    end
    
    if not grid or grid.inventory_bonus == 0 then
        submarine.teleport(target_position, target_surface, true, false)
        return
    end
    local inventory = submarine.get_inventory(defines.inventory.spider_trunk)
    local lua_inventory = game.create_inventory(#inventory)
    local inventory_indicies = {}
    for i = 1, #inventory do
        local stack = inventory[i]
        if stack and stack.valid_for_read then
            lua_inventory[i].swap_stack(stack)
            inventory_indicies[#inventory_indicies+1] = i
        end
    end
    inventory.clear()
    submarine.teleport(target_position, target_surface, true, false)
    local toolbelt = grid.put{position = {0, 0}, name = "maraxsis-toolbelt-equipment"}
    assert(toolbelt)
    maraxsis.execute_later("post_sub_teleport_inventory_restoration", 1, submarine, toolbelt, lua_inventory, inventory_indicies)
end

---transfers a submarine between surfaces
---@param submarine LuaEntity
---@return boolean true if the submarine was successfully transferred
local function descend_or_ascend(submarine)
    local target_surface, target_position = determine_submerge_direction(submarine)
    if not target_surface then return false end
    if not target_position then return false end

    local passenger, driver = submarine.get_passenger(), submarine.get_driver()
    local has_player = false
    if passenger and not passenger.is_player() then
        passenger = passenger.player
        has_player = true
    end

    if driver and not driver.is_player() then
        driver = driver.player
        has_player = true
    end

    local old_surface = submarine.surface
    local old_position = submarine.position
    maraxsis.execute_later("play_submerge_sound", 1, old_surface, old_position)
    maraxsis.execute_later("play_submerge_sound", 1, target_surface, target_position)

    local players_to_open_gui = {}
    local players_to_preserve_spidertron_remote_selection = {}
    for _, player in pairs(game.players) do
        if player.opened == submarine and player.surface ~= target_surface then
            table.insert(players_to_open_gui, player)
        elseif player.spidertron_remote_selection then
            players_to_preserve_spidertron_remote_selection[player] = player.spidertron_remote_selection
        end
    end

    trench_generation_sanity_check()
    teleport_submarine(submarine, target_position, target_surface,has_player)

    for _, player in pairs(players_to_open_gui) do
        if player.surface ~= target_surface then
            player.set_controller {
                type = defines.controllers.remote,
                position = target_position,
                surface = target_surface
            }
        end
        player.opened = submarine
    end

    for player, spidertron_remote_selection in pairs(players_to_preserve_spidertron_remote_selection) do
        player.spidertron_remote_selection = spidertron_remote_selection
    end

    if passenger and passenger.physical_vehicle == submarine then
        trench_generation_sanity_check()
        passenger.teleport(target_position, target_surface, true)
        maraxsis.execute_later("enter_submarine", 1, passenger, submarine)
    end

    if driver and driver.physical_vehicle == submarine then
        trench_generation_sanity_check()
        driver.teleport(target_position, target_surface, true)
        maraxsis.execute_later("enter_submarine", 1, driver, submarine)
    end

    script.raise_event("maraxsis-on-submerged", {
        entity = submarine,
        old_surface_index = old_surface.index,
        old_position = old_position
    })

    return true
end

---transfers a character between trench and maraxsis surfaces when standing over trench entrance tiles
---@param character LuaEntity
---@return boolean true if the character was successfully transferred
local function descend_or_ascend_character(character)
    local target_surface, target_position = determine_submerge_direction(character)
    if not target_surface then return false end
    if not target_position then return false end

    local old_surface = character.surface
    local old_position = character.position
    maraxsis.execute_later("play_submerge_sound", 1, old_surface, old_position)
    maraxsis.execute_later("play_submerge_sound", 1, target_surface, target_position)

    trench_generation_sanity_check()
    character.teleport(target_position, target_surface, true)

    script.raise_event("maraxsis-on-submerged", {
        entity = character,
        old_surface_index = old_surface.index,
        old_position = old_position
    })
        
    return true
end

local function clean_array_of_invalid_luaobjects(array)
    local new_table = {}
    for k, v in pairs(array) do
        if v.valid then table.insert(new_table, v) end
    end
    return new_table
end

maraxsis.on_event(maraxsis.events.on_init(), function()
    storage.players_on_maraxsis = {}
    for i,player in pairs(game.players) do
        if player.surface.name == "maraxsis" then
            storage.players_on_maraxsis[i] = {player=player}
        end
    end
    storage.players_on_maraxsis_trench = {}
    for i,player in pairs(game.players) do
        if player.surface.name == "maraxsis-trench" then
            storage.players_on_maraxsis_trench[i] = {player=player}
        end
    end
end)

maraxsis.on_event(defines.events.on_player_changed_surface, function(event)
    local player = game.get_player(event.player_index)
    local cursor_stack = player.cursor_stack
    storage.players_on_maraxsis[event.player_index] = nil
    storage.players_on_maraxsis_trench[event.player_index] = nil
    if player.surface.name == "maraxsis" then
        storage.players_on_maraxsis[event.player_index] = {player = player}
    elseif player.surface.name == "maraxsis-trench" then
        storage.players_on_maraxsis_trench[event.player_index] = {player = player}
    end

    local spidertrons = storage.previous_spidertron_remote_selection[event.player_index]
    if not spidertrons then return end
    spidertrons = clean_array_of_invalid_luaobjects(spidertrons)
    if not cursor_stack or not cursor_stack.valid_for_read then return end
    if cursor_stack.type ~= "spidertron-remote" then return end
    player.spidertron_remote_selection = player.spidertron_remote_selection or spidertrons
end)

maraxsis.on_event(
    {
        defines.events.on_player_selected_area,
        defines.events.on_player_alt_selected_area,
        defines.events.on_player_alt_reverse_selected_area,
        defines.events.on_player_reverse_selected_area,
        defines.events.on_player_cursor_stack_changed
    },
    function(event)
        storage.previous_spidertron_remote_selection = storage.previous_spidertron_remote_selection or {}
        local player = game.get_player(event.player_index)
        local spidertrons = player.spidertron_remote_selection or storage.previous_spidertron_remote_selection[player.index]
        storage.previous_spidertron_remote_selection[player.index] = spidertrons
    end
)

maraxsis.on_event("maraxsis-trench-submerge", function(event)
    local player = game.get_player(event.player_index)
    if not player then return end
    local submarine = player.vehicle

    if submarine and SUBMARINES[submarine.name] then
        descend_or_ascend(submarine)
    elseif maraxsis.is_wearing_abyssal_diving_gear(player) then
        descend_or_ascend_character(player.character)
    end
end)

-- override the default toggle driving control so that submarines can be entered from further distances.
maraxsis.on_event("toggle-driving", function(event)
    local player = game.get_player(event.player_index)
    if not player then return end
    local selected = player.selected
    local selected_submarine = selected and selected.valid and SUBMARINES[selected.name]
    local submarine = player.physical_vehicle
    local surface = player.physical_surface

    if player.physical_surface ~= player.surface then return end

    -- case 1: player is not hovering the sub but trying to exit.
    if submarine and SUBMARINES[submarine.name] and not selected_submarine then
        maraxsis.execute_later("exit_submarine", 1, event)
        -- case 2: player is hovering the sub and trying to enter. the vanilla vechicle enter range is too low for water vehicles so we artificially increase it
    elseif can_enter_submarine(player, selected) then
        maraxsis.execute_later("enter_submarine", 1, player, selected)
    end
end)

maraxsis.on_event("on_spidertron_patrol_waypoint_reached", function(event)
    if event.waypoint.type ~= "submerge" then return end
    local submarine = event.spidertron
    if not submarine or not submarine.valid then return end
    if not maraxsis_constants.SUBMARINES[submarine.name] then return end

    if not descend_or_ascend(submarine) then
        submarine.force.print {"maraxsis.submarine-failed-to-submerge", submarine.gps_tag}
    end
end)

maraxsis.on_nth_tick(277, function()
    for k, submarine in pairs(storage.submarines) do
        if not submarine.valid then
            storage.submarines[k] = nil
            return
        end

        local fuel_inventory = submarine.get_fuel_inventory()
        if fuel_inventory and fuel_inventory.is_empty() and submarine.energy < 1 then
            for _, player in pairs(submarine.force.players) do
                player.add_alert(submarine, defines.alert_type.train_out_of_fuel)
            end
        else
            for _, player in pairs(submarine.force.players) do
                player.remove_alert {
                    entity = submarine,
                    type = defines.alert_type.train_out_of_fuel
                }
            end
        end
    end
end)

--- to prevent softlocks, once the player dies find a submarine and teleport to the respawn location
maraxsis.on_event(defines.events.on_player_respawned, function(event)
    local player = game.get_player(event.player_index)
    if not player or not player.valid then return end
    if not maraxsis_constants.MARAXSIS_SURFACES[player.surface.name] then return end
    local force_index = player.force_index

    local submarine_names = {}
    for submarine_name in pairs(maraxsis_constants.SUBMARINES) do
        table.insert(submarine_names, submarine_name)
    end

    local submarine_to_teleport
    for surface_name in pairs(maraxsis_constants.MARAXSIS_SURFACES) do
        local surface = game.get_surface(surface_name)
        if not surface then goto continue end
        for _, submarine in pairs(surface.find_entities_filtered{
            name = submarine_names,
            type = "spider-vehicle",
            force = force_index
        }) do
            local patrol_data = remote.call("SpidertronPatrols", "get_waypoints", submarine)
            if not patrol_data then
                submarine_to_teleport = submarine
                goto found_submarine
            end
        end
        ::continue::
    end
    ::found_submarine::

    if not submarine_to_teleport then return end

    local position = player.position
    local position = {x = position.x + 7, y = position.y - 4}
    trench_generation_sanity_check()
    teleport_submarine(submarine_to_teleport, position, player.surface_index)
end)
