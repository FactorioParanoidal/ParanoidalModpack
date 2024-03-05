function handle_shortcut(event)
    local event_name = event.prototype_name or event.input_name
    if string.sub(event_name, 1, 13) ~= "WireShortcuts" then return end

    local player = game.players[event.player_index]
    if not player.cursor_stack then return end
    if event_name == "WireShortcuts-give-cutter" then
        give_tool(player, "wire-cutter-universal")
    else
        local advanced_mode =
            settings.get_player_settings(player)["wire-shortcuts-is-advanced-cutter"].value
        local cutter_held = player.cursor_stack.valid_for_read and
                                string.sub(player.cursor_stack.name, 1, 11) == "wire-cutter"
        local mode_name = string.sub(event_name, 20, #event_name)

        if advanced_mode and cutter_held then
            give_tool(player, "wire-cutter-" .. mode_name)
        elseif mode_name == "copper" then
            give_copper(player)
        else
            give_tool(player, mode_name .. "-wire", 200)
        end
    end
end

function give_tool(player, tool_name, count)
    if player.drag_target then 
        player.clear_cursor()
    end
    if player.clear_cursor() then
        player.cursor_stack.set_stack({name = tool_name, count = count or 1})
    end
end

function give_copper(player)
    local inv = player.get_main_inventory()
    if inv and inv.valid then
        if player.cursor_stack.valid_for_read then
            if string.sub(player.cursor_stack.name, 1, 11) == "wire-cutter" then
                player.clear_cursor()
            elseif player.cursor_stack.name == "copper-cable" then
                return
            end
        end
        local wire = inv.find_item_stack("copper-cable")
        if wire then
            player.cursor_stack.swap_stack(wire)
        else
            give_tool(player, "copper-cable")
        end
    end
end

function handle_switch_wire(player_index)
    local player = game.players[player_index]
    if player.cursor_stack.valid_for_read then
        if player.cursor_stack.name == "red-wire" then
            give_tool(player, "green-wire", 200)
        elseif player.cursor_stack.name == "green-wire" then
            give_tool(player, "red-wire", 200)
        elseif player.cursor_stack.name == "wire-cutter-red" then
            give_tool(player, "wire-cutter-green")
        elseif player.cursor_stack.name == "wire-cutter-green" then
            give_tool(player, "wire-cutter-red")
        end
    end
end

-- Some mods have entities with hidden connections that break if disconnected, we catch them here
function has_hidden_connections(entity)
    local blacklisted = {
        "se-rocket-launch-pad",
        "logistic-train-stop-lamp-control",
        "logistic-train-stop-input"
    }
    for _, filter in ipairs(blacklisted) do
        if string.sub(entity.name, 1, #filter) == filter then return true end
    end
    return false
end

function handle_disconnect(event, alt)
    if string.sub(event.item, 1, 11) == "wire-cutter" then
        disconnect_mode = string.sub(event.item, 13, #event.item)
        for _, entity in ipairs(event.entities) do
            if entity.valid and not has_hidden_connections(entity) then
                if not alt and disconnect_mode == "copper" or alt and disconnect_mode == "universal" then
                    entity.disconnect_neighbour()
                elseif not alt and disconnect_mode == "red" or alt and disconnect_mode == "green" then
                    entity.disconnect_neighbour(defines.wire_type.red)
                elseif not alt and disconnect_mode == "green" or alt and disconnect_mode == "red" then
                    entity.disconnect_neighbour(defines.wire_type.green)
                elseif disconnect_mode == "universal" or alt and disconnect_mode == "copper" then
                    entity.disconnect_neighbour(defines.wire_type.red)
                    entity.disconnect_neighbour(defines.wire_type.green)
                end
            end
        end
    end
end

script.on_event({
    defines.events.on_lua_shortcut,
    "WireShortcuts-give-red",
    "WireShortcuts-give-green",
    "WireShortcuts-give-copper",
    "WireShortcuts-give-cutter"
}, handle_shortcut)

script.on_event("WireShortcuts-switch-wire",
                function(event) handle_switch_wire(event.player_index) end)

script.on_event(defines.events.on_player_selected_area,
                function(event) handle_disconnect(event, false) end)

script.on_event(defines.events.on_player_alt_selected_area,
                function(event) handle_disconnect(event, true) end)
