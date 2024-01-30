-- initial settings, before loading them
local display_mode = "alerts-list-display-mode-icon-only"
local show_percentage = false
local columns_for_compact_mode = 4

-- constants
local ZOOM_LEVEL = 0.1

function format_guielement_name(prefix, surface, pos)
    return prefix .. surface.index .. "_" .. pos.x .. "_" .. pos.y
end

function starts_with(str, start)
    return str:sub(1, #start) == start
end

function signalid_to_spritepath(signalid)
    local type = signalid.type
    if type == "virtual" then
        type = "virtual-signal"
    end
    return type .. "/" .. signalid.name
end

function refresh_speakers()
    if global["speaker_cache"] then
        for k, _ in pairs(global["speaker_cache"]) do
            global["speaker_cache"][k] = nil
        end

        for k, v in pairs(game.surfaces) do
            for sid, speaker in pairs(v.find_entities_filtered {type = "programmable-speaker"}) do
                table.insert(global["speaker_cache"], speaker)
            end
        end
    end
end

function remove_speaker(speaker)
    if global["speaker_cache"] then
        for k, v in pairs(global["speaker_cache"]) do
            if v == speaker then
                table.remove(global["speaker_cache"], k)
            end
        end
    end
end

function compare_signals(s1, s2)
    return s1 == s2 or (s1 and s2 and s1.type == s2.type and s1.name == s2.name)
end

function on_built(e)
    if (e.created_entity.type == "programmable-speaker") then
        if not global["speaker_cache"] then
            global["speaker_cache"] = {}
        end

        table.insert(global["speaker_cache"], e.created_entity)

        for k, player in pairs(game.players) do
            draw_gui(player)
        end
    end
end

function on_destroyed(e)
    if e.entity.type == "programmable-speaker" then
        remove_speaker(e.entity)
        for k, player in pairs(game.players) do
            draw_gui(player)
        end
    end
end

function calculate_percentage(speaker, circuit)
    local all_signals = speaker.get_merged_signals()
    local left = 0
    local right = circuit.condition["constant"]
    if all_signals then
        for k, v in pairs(all_signals) do
            if compare_signals(v.signal, circuit.condition.first_signal) then
                left = v.count
            end
            if compare_signals(v.signal, circuit.condition["second_signal"]) then
                right = v.count
            end
        end
    end
    if right == 0 then
        right = 1
    end
    percentage = left / right
    return percentage
end

function get_signal_value(signals, signalid)
    local value = 0
    if signals then
        for k, v in pairs(signals) do
            if v.signal.type == signalid.type and v.signal.name == signalid.name then
                value = v.count
                break
            end
        end
    end
    return value
end

function left_column_for(tbl, speaker, circuit)
    local elem_name = format_guielement_name("alerts_list_icons_", speaker.surface, speaker.position)
    local element = tbl[elem_name]
    if display_mode == "alerts-list-display-mode-icon-only" or display_mode == "alerts-list-display-mode-icon-and-text" then
        if not element then
            element =
                tbl.add {
                type = "sprite-button",
                name = elem_name,
                enabled = true,
                mouse_button_filter = {"left"},
                sprite = signalid_to_spritepath(speaker.alert_parameters.icon_signal_id),
                show_percent_for_small_numbers = show_percentage
            }
        end
        element.sprite = signalid_to_spritepath(speaker.alert_parameters.icon_signal_id)
        if show_percentage then
            element.number = calculate_percentage(speaker, circuit)
        else
            element.number = get_signal_value(speaker.get_merged_signals(), circuit.condition.first_signal)
        end
        element.tooltip = speaker.alert_parameters.alert_message
    -- TODO: else for complex icon (full condition?)
    end
    -- update element data
end

function right_column_for(tbl, speaker, circuit)
    if display_mode ~= "alerts-list-display-mode-icon-only" then
        local elem_name = format_guielement_name("alerts_list_info_", speaker.surface, speaker.position)
        local element = tbl[elem_name]
        if not element then
            element = tbl.add {type = "label", name = elem_name, caption = speaker.alert_parameters.alert_message}
        end
        element.caption = speaker.alert_parameters.alert_message
    end
end

function on_click(element, player)
    if element and player then
        if starts_with(element.name, "alerts_list_icons_") then
            for k, speaker in pairs(global["speaker_cache"]) do
                if speaker then 
                    if element.name == format_guielement_name("alerts_list_icons_", speaker.surface, speaker.position) then
                        player.open_map(speaker.position, ZOOM_LEVEL)
                        break
                    end
                end
            end
        end
    end
end

function fill_table_with_speakers(tbl, speakers, player)
    if not speakers then
        speakers = {}
    end

    local remove_list = {}
    for k, v in pairs(tbl.children) do
        remove_list[v.name] = v
    end

    local found_any = false

    for i, speaker in pairs(speakers) do
        -- here we do assume we always have a list of speakers that have global alert set
        if speaker and speaker.valid and speaker.alert_parameters and speaker.alert_parameters.show_alert then
            local behavior = speaker.get_control_behavior()
            if behavior and behavior["circuit_condition"] then
                if behavior.circuit_condition.fulfilled and speaker.alert_parameters.icon_signal_id then
                    found_any = true
                    left_column_for(tbl, speaker, behavior.circuit_condition)
                    right_column_for(tbl, speaker, behavior.circuit_condition)
                    remove_list[format_guielement_name("alerts_list_icons_", speaker.surface, speaker.position)] = nil
                    remove_list[format_guielement_name("alerts_list_info_", speaker.surface, speaker.position)] = nil
                end
            end
        end
    end
    for k, v in pairs(remove_list) do
        v.destroy()
    end

    if not found_any then
        -- get rid of GUI if there's nothing to be shown
        for k, player in pairs(game.players) do
            if player.gui.left["alerts_list_frame_main"] then
                player.gui.left["alerts_list_frame_main"].destroy()
            end
        end
    end
end

-- return GUI
function build_gui(player)
    if not player.gui.left["alerts_list_frame_main"] then
        -- TODO: make it transparent background?
        local gui = player.gui.left.add {type = "frame", name = "alerts_list_frame_main", direction = "vertical"}
        local columns = 2
        if display_mode == "alerts-list-display-mode-icon-only" then
            columns = columns_for_compact_mode
        end
        gui.add {
            type = "label",
            name = "alerts_list_label",
            caption = {"gui-alerts-list.label-caption"},
            tooltip = {"tooltip-alerts-list.label-caption"}
        }
        local tbl = gui.add {type = "table", name = "alerts_list_alert_table", column_count = columns}
        return gui
    else
        return player.gui.left["alerts_list_frame_main"]
    end
end

-- builds GUI and fills it with current speakers data
function draw_gui(player)
    local gui = build_gui(player)
    local tbl = gui.alerts_list_alert_table
    fill_table_with_speakers(tbl, global["speaker_cache"], player)
end

function reload_settings(player)
    display_mode = settings.get_player_settings(player)["alerts-list-display-mode"].value
    show_percentage = settings.get_player_settings(player)["alerts-list-show-percentage"].value
    columns_for_compact_mode = settings.get_player_settings(player)["alerts-list-columns-for-compact-mode"].value

    if player.gui.left["alerts_list_frame_main"] then
        player.gui.left["alerts_list_frame_main"].destroy()
    end

    draw_gui(player)
end

-- register events

script.on_init(
    function()
        for k, player in pairs(game.players) do
            reload_settings(player)
        end

        if not global["speaker_cache"] then
            global["speaker_cache"] = {}
        end
        refresh_speakers()
    end
)

script.on_configuration_changed(
    function()
        for k, player in pairs(game.players) do
            reload_settings(player)
        end

        if not global["speaker_cache"] then
            global["speaker_cache"] = {}
        end
        refresh_speakers()
    end
)

script.on_nth_tick(
    settings.startup["alerts-list-refresh-rate"].value,
    function(e)
        for k, player in pairs(game.players) do
            draw_gui(player)
        end
    end
)

script.on_event(
    defines.events.on_player_joined_game,
    function(e)
        local player = game.players[e.player_index]
        reload_settings(player)

        if not global["speaker_cache"] then
            global["speaker_cache"] = {}
        end
        refresh_speakers()
    end
)

script.on_event(
    defines.events.on_runtime_mod_setting_changed,
    function(e)
        if e.player_index ~= nil then
            local player = game.players[e.player_index]
            reload_settings(player)
        end
    end
)

script.on_event(
    {defines.events.on_built_entity, defines.events.on_robot_built_entity},
    function(e)
        on_built(e)
    end
)

script.on_event(
    {defines.events.on_pre_player_mined_item, defines.events.on_robot_mined_entity, defines.events.on_entity_died},
    function(e)
        on_destroyed(e)
    end
)

script.on_event(
    {defines.events.on_gui_click},
    function(e)
        local player = game.players[e.player_index]
        if player ~= nil and e.button == defines.mouse_button_type.left then
            on_click(e.element, player)
        end
    end
)
