if not evogui then evogui = {} end

if not global.evogui then global.evogui = {} end
if not global.settings then global.settings = {} end


local function toggle_always_visible(event)
    local player = game.players[event.player_index]

    local always_visible = global.evogui[player.name].always_visible
    local sensor_name = event.element.name:sub(24,-1)
    if event.element.state then
        always_visible[sensor_name] = true
    else
        always_visible[sensor_name] = nil
    end
end


local function toggle_in_popup(event)
    local player = game.players[event.player_index]

    local in_popup = global.evogui[player.name].in_popup
    local sensor_name = event.element.name:sub(24,-1)
    if event.element.state then
        in_popup[sensor_name] = true
    else
        in_popup[sensor_name] = nil
    end
end


local function on_sensor_settings_closed(player_index)
    evogui.evoGUI_settings({player_index = player_index})
end

local function trigger_settings_gui(event)
    local player = game.players[event.player_index]

    local sensor_name = event.element.name:sub(42,-1)
    local sensor = ValueSensor.get_by_name(sensor_name)
    if sensor == nil then
        error({"err_settings_whatsensor", "trigger_settings_gui"})
        return
    end

    if sensor.settings_gui == nil then
        error({"err_settings_whatsettings", "trigger_settings_gui"})
        return
    end

    if player.gui.center.evoGUI_settingsGUI ~= nil then
        player.gui.center.evoGUI_settingsGUI.destroy()
    end

    sensor.settings_gui_closed = on_sensor_settings_closed
    sensor:settings_gui(event.player_index)
end


local function add_sensor_table_row(table, sensor, always_visible, in_popup)
    local sensor_always_visible = always_visible[sensor.name] ~= nil
    local sensor_in_popup = in_popup[sensor.name] ~= nil

    table.add{type="label", caption=sensor.display_name}
    table.add{type="checkbox", name="evogui_settings_gui_av_"..sensor.name,
        caption={"settings_always_visible"}, state=sensor_always_visible}
    table.add{type="checkbox", name="evogui_settings_gui_ip_"..sensor.name,
        caption={"settings_in_popup"}, state=sensor_in_popup}
    if sensor.settings_gui ~= nil then
        local button_name = "evogui_settings_gui_trigger_settings_gui_"..sensor.name
        table.add{type="button", name=button_name,
            style="EvoGUI_settings"}
    else
        table.add{type="flow"} -- empty, but there has to be _something_ there.
    end
end

function evogui.on_settings_click(event)
    if event.element.name == "evogui_settings_gui_settings_open" then
        evogui.evoGUI_settings(event)
    elseif event.element.name == "evogui_settings_gui_settings_close" then
        evogui.evoGUI_settings_close(event)
    elseif string.starts_with(event.element.name, "evogui_settings_gui_trigger_settings_gui_") then
        trigger_settings_gui(event)
    elseif string.starts_with(event.element.name, "evogui_settings_gui_av_") then
        toggle_always_visible(event)
    elseif string.starts_with(event.element.name, "evogui_settings_gui_ip") then
        toggle_in_popup(event)
    end
end


function evogui.evoGUI_settings(event)
    local player = game.players[event.player_index]
    if player.gui.center.evoGUI_settingsGUI ~= nil then
        player.gui.center.evoGUI_settingsGUI.destroy()
        return
    end

    evogui.create_player_globals(player)
    local player_data = global.evogui[player.name]

    local root = player.gui.center.add{type="frame",
                                       direction="vertical",
                                       name="evoGUI_settingsGUI",
                                       caption={"settings_title"}}

    local core_settings = root.add{type="frame",
                                   name="core_settings",
                                   caption={"settings.core_settings.title"},
                                   direction="vertical",
                                   style="naked_frame"}

    local update_freq_flow = core_settings.add{type="flow", name="update_freq_flow", direction="horizontal"}
    update_freq_flow.add{type="label", caption={"settings.core_settings.update_freq_left"}}
    local textfield = update_freq_flow.add{type="textfield", name="textfield", style="short_number_textfield"}
    textfield.text=tostring(global.settings.update_delay)
    update_freq_flow.add{type="label", caption={"settings.core_settings.update_freq_right"}}

    local sensors_frame = root.add{type="frame",
                                   name="sensors_frame",
                                   caption={"settings.sensors_frame.title"},
                                   direction="vertical",
                                   style="naked_frame"}

    local table = sensors_frame.add{type="table", name="table", column_count=4}

    for _, sensor in ipairs(evogui.value_sensors) do
        add_sensor_table_row(table, sensor, player_data.always_visible, player_data.in_popup)
    end

    local buttons = root.add{type="flow", name="buttons", direction="horizontal"}
    buttons.add{type="button", name="evogui_settings_gui_settings_close", caption={"settings_close"}}
end


function evogui.evoGUI_settings_close(event)
    local player = game.players[event.player_index]

    local new_update_freq = tonumber(player.gui.center.evoGUI_settingsGUI.core_settings.update_freq_flow.textfield.text)
    if new_update_freq ~= nil then
        global.settings.update_delay = new_update_freq
    end

    if player.gui.center.evoGUI_settingsGUI ~= nil then
        player.gui.center.evoGUI_settingsGUI.destroy()
    end
end
