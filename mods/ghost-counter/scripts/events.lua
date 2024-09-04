---Handles the lua shortcut button or hotkey being triggered.
---@param event EventData.on_lua_shortcut|EventData.CustomInputEvent Event table
function on_lua_shortcut(event)
    -- Exclude irrelevant lua shortcuts
    if event.prototype_name and event.prototype_name ~= NAME.shortcut.button then return end

    local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
    local cursor_stack = player.cursor_stack

    -- Abort if player has no cursor stack as they are presumably a spectator
    if not cursor_stack then return end

    if player.is_cursor_blueprint() then
        on_player_selected_blueprint(event)
    else
        local clear_cursor = player.clear_cursor()
        if clear_cursor then
            cursor_stack.set_stack({name=NAME.tool.ghost_counter})
        end
    end
end
script.on_event(defines.events.on_lua_shortcut, on_lua_shortcut)
script.on_event(NAME.input.ghost_counter_selection, on_lua_shortcut)

---Event handler for selection using GC tool
---@param event EventData.on_player_selected_area Event table
---@param ignore_tiles boolean Determines whether tiles are included in count
function on_player_selected_area(event, ignore_tiles)
    if event.item ~= NAME.tool.ghost_counter then return end

    local ghosts, requests = get_selection_counts(event.entities, ignore_tiles)

    -- Open window only if there are non-zero ghost entities
    if table_size(requests) > 0 then
        local player_index = event.player_index
        local playerdata = get_make_playerdata(player_index)

        playerdata.job = {
            area=event.area,
            ghosts=ghosts,
            requests=requests,
            requests_sorted=sort_requests(requests)
        }

        update_one_time_logistic_requests(player_index)
        update_inventory_info(player_index)
        update_logistics_info(player_index)

        Gui.toggle(player_index, true)

        playerdata.luaplayer.clear_cursor()
    end
end
script.on_event(defines.events.on_player_selected_area,
    ---@param event EventData.on_player_selected_area
    function(event) on_player_selected_area(event, true) end)
    script.on_event(defines.events.on_player_alt_selected_area,
    ---@param event EventData.on_player_selected_area
    function(event) on_player_selected_area(event, false) end)

---Handles Ghost counter being activated with a blueprint in cursor.
---@param event EventData.on_lua_shortcut|EventData.CustomInputEvent Event table
function on_player_selected_blueprint(event)
    local player_index = event.player_index
    local playerdata = get_make_playerdata(player_index)
    local entities = playerdata.luaplayer.get_blueprint_entities() or {}

    local tiles = {}
    if (playerdata.luaplayer.is_cursor_blueprint() and
        playerdata.luaplayer.cursor_stack.valid_for_read) then
        tiles = get_blueprint_tiles(playerdata.luaplayer.cursor_stack)
    end

    -- Abort if player not holding blueprint or empty blueprint
    if not (entities and #entities > 0) and not (tiles and #tiles > 0) then return end

    local requests = get_blueprint_counts(entities, tiles)

    playerdata.job = {
        area={},
        ghosts={},
        requests=requests,
        requests_sorted=sort_requests(requests)
    }

    update_one_time_logistic_requests(player_index)
    update_inventory_info(player_index)
    update_logistics_info(player_index)

    Gui.toggle(player_index, true)
end

---Updates playerdata.job.requests table as well as one-time requests to see if any can be
---considered fulfilled
---@param event EventData.on_player_main_inventory_changed Event table
function on_player_main_inventory_changed(event)
    local playerdata = get_make_playerdata(event.player_index)
    if not playerdata.is_active then return end
    if playerdata.luaplayer.controller_type ~= defines.controllers.character then return end

    register_update(playerdata.index, event.tick)
end

---Updates one-time logistic requests table as well as job.requests
---@param event EventData.on_entity_logistic_slot_changed Event table
function on_entity_logistic_slot_changed(event)
    -- Exit if event does not involve a player character
    if event.entity.type ~= "character" then return end

    local player = event.entity.player or event.entity.associated_player
    if not player then return end

    local player_index = player.index
    local playerdata = get_make_playerdata(player_index)

    -- Iterate over known one-time logistic requests to see if the event concerns any of them
    for name, request in pairs(playerdata.logistic_requests) do
        if request.slot_index == event.slot_index then
            if request.is_new then
                request.is_new = false
                return
            else
                playerdata.logistic_requests[name] = nil
            end
            break
        end
    end

    register_update(player_index, event.tick)
end

---Triggers an update if the player respawns.
---@param event EventData.on_player_respawned Event data
function on_player_respawned(event)
    local playerdata = get_make_playerdata(event.player_index)
    if not playerdata.is_active then return end
    register_update(playerdata.index, event.tick)
end
script.on_event(defines.events.on_player_respawned, on_player_respawned)

---Triggers an update if the player dies.
---@param event EventData.on_player_died Event data
function on_player_died(event)
    local playerdata = get_make_playerdata(event.player_index)
    if not playerdata.is_active then return end
    register_update(playerdata.index, event.tick)
end
script.on_event(defines.events.on_player_died, on_player_died)

---Handles `on_entity_destroyed` by looking up `event.unit_number` in ghost tables and updates
---requests tables where appropriate
---@param event EventData.on_entity_destroyed Event table
function on_ghost_destroyed(event)
    -- Since even ghost tiles have `unit_number`, exit if none is provided
    if not event.unit_number then return end

    -- Iterate over each player, and update their requests if they were tracking the entity
    for player_index, playerdata in pairs(global.playerdata) do
        if playerdata.is_active and playerdata.job.ghosts[event.unit_number] then
            local items = playerdata.job.ghosts[event.unit_number]
            for _, item in pairs(items) do
                local request = playerdata.job.requests[item.name]
                request.count = request.count - item.count
            end
            register_update(player_index, event.tick)
        end
    end
end

---Handles `on_nth_tick`—processes data for players who have had data updates. Aborts and
---unregisters itself if there were no data updates for any player since the previous function call
---@param event table Event table
function on_nth_tick(event)
    -- If no data updates happened over the last 5 ticks, unregister nth_tick handler and exit
    if event.tick - global.last_event > global.settings.min_update_interval then
        register_nth_tick_handler(false)
        return
    end

    -- Iterate over each player and process their data if they had updates
    for player_index, playerdata in pairs(global.playerdata) do
        -- If a player had registered data updates, reprocess their data
        if playerdata.has_updates then
            update_one_time_logistic_requests(player_index)

            if playerdata.is_active then
                update_inventory_info(player_index)
                update_logistics_info(player_index)

                Gui.update_list(player_index)
            end

            -- Reset `has_updates` boolean for that player
            playerdata.has_updates = false
        end
    end

    -- Check if event handlers can be unbound
    if not is_inventory_monitoring_needed() then register_inventory_monitoring(false) end
    if not is_logistics_monitoring_needed() then register_logistics_monitoring(false) end
end
