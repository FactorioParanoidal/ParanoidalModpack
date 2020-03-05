require "value_sensors.day_time"
require "value_sensors.evolution_factor"
require "value_sensors.kill_count"
require "value_sensors.play_time"
require "value_sensors.player_locations"
require "value_sensors.pollution_around_player"
require "value_sensors.remote_sensor"
require "settingsGUI"
require "remote"

if not evogui then evogui = {} end

function evogui.mod_init()
    if not global.settings then global.settings = {} end
    if not global.settings.update_delay then global.settings.update_delay = 60 end

    for _, player in pairs(game.players) do
        evogui.create_player_globals(player)
        evogui.create_sensor_display(player)
    end
end


local function mod_update_0_4_205()
    -- 0.4.204 to 0.4.205: Factorio 0.15.22 introduced a bug wherein a
    -- GUI element with more than 4 characters in its name, which was
    -- shorter than the_mod_name + 4 characters, would get deleted on
    -- load. At this time, the EvoGUI root element switched from
    -- gui.top.evoGUI to gui.top.evogui_root.
    --
    -- We need to clean up the leftovers for people updating EvoGUI
    -- from any other version of Factorio now.
    for _, player in pairs(game.players) do
        if player.gui.top.evoGUI then
            player.gui.top.evoGUI.destroy()
        end
    end
end


function evogui.mod_update(data)
    if data.mod_changes then
        if data.mod_changes["EvoGUI"] then
            -- TODO: If a more major migration ever needs doing, do that here.
            -- Otherwise, just falling back to mod_init should work fine.
            evogui.mod_init()

            mod_update_0_4_205()
        end

        evogui.validate_sensors(data.mod_changes)
    end
end

function evogui.on_gui_click(event)
    if string.starts_with(event.element.name, "evogui_settings_gui_") then
        evogui.on_settings_click(event)
    elseif event.element.name == "evoGUI_toggle_popup" then
        evogui.evoGUI_toggle_popup(event)
    elseif string.starts_with(event.element.name, "evogui_sensor_") then
        for _, sensor in pairs(evogui.value_sensors) do
            -- if the gui element name matches 'evogui_sensor_' + sensor_name, send it the on_click event.
            if string.starts_with(event.element.name, "evogui_sensor_" .. sensor.name) then
                sensor:on_click(event)
                break
            end
        end
    end
end

-- Iterate through all value_sensors, if any are associated with a mod_name that
-- has been removed, remove the sensor from the list of value_sensors.
function evogui.validate_sensors(mod_changes)
    for i = #evogui.value_sensors, 1, -1 do
        local sensor = evogui.value_sensors[i]
        if sensor.mod_name and mod_changes[sensor.mod_name] then
            -- mod removed, remove sensor from ui
            if mod_changes[sensor.mod_name].new_version == nil then
                evogui.hide_sensor(sensor)
                table.remove(evogui.value_sensors, i)
            end
        end
    end
end

function evogui.hide_sensor(sensor)
    for player_name, data in pairs(global.evogui) do
        if data.always_visible then
            data.always_visible[sensor["name"]] = false
        end
    end
    for _, player in pairs(game.players) do
        local player_settings = global.evogui[player.name]

        local sensor_flow = player.gui.top.evogui_root.sensor_flow
        evogui.update_av(player, sensor_flow.always_visible)
    end
end


function evogui.new_player(event)
    local player = game.players[event.player_index]

    evogui.create_player_globals(player)
    evogui.create_sensor_display(player)
end


function evogui.update_gui(event)
    if (event.tick % global.settings.update_delay) ~= 0 then return end

    for player_index, player in pairs(game.players) do
        local player_settings = global.evogui[player.name]
        -- saves converted from SP with no username to MP won't raise evogui.new_player
        -- so we have to check here, as well.
        if not player_settings then
            evogui.new_player({player_index = player_index})
            player_settings = global.evogui[player.name]
        elseif not player.gui.top.evogui_root then
            evogui.create_sensor_display(player)
        end

        local sensor_flow = player.gui.top.evogui_root.sensor_flow
        evogui.update_av(player, sensor_flow.always_visible)
        if player_settings.popup_open then
            evogui.update_ip(player, sensor_flow.in_popup)
        end
    end
end


function evogui.create_player_globals(player)
    if not global.evogui then global.evogui = {} end
    if not global.evogui[player.name] then global.evogui[player.name] = {} end
    local player_settings = global.evogui[player.name]

    if not player_settings.version then player_settings.version = "" end

    if not player_settings.always_visible then
        player_settings.always_visible = {
            ["evolution_factor"] = true,
            ["play_time"] = true,
        }
    end

    if not player_settings.in_popup then
        player_settings.in_popup = {
            ["day_time"] = true,
        }
    end

    if not player_settings.popup_open then player_settings.popup_open = false end

    if not player_settings.sensor_settings then
        player_settings.sensor_settings = {}
    end

    if not player_settings.sensor_settings['player_locations'] then
        player_settings.sensor_settings['player_locations'] = {
            ['show_player_index'] = false,
            ['show_position'] = false,
            ['show_surface'] = false,
            ['show_direction'] = true,
            ['show_offline'] = false,
        }
    elseif player_settings.sensor_settings['player_locations'].show_offline == nil then
        -- 0.4.3 new feature (783e3d68)
        player_settings.sensor_settings['player_locations'].show_offline = false
    end

    if not player_settings.sensor_settings['day_time'] then
        player_settings.sensor_settings['day_time'] = {
            ['show_day_number'] = false,
            ['minute_rounding'] = true,
        }
    end

    if not player_settings.sensor_settings['evolution_factor'] then
        player_settings.sensor_settings['evolution_factor'] = {
            ['extra_precision'] = false,
        }
    end

    if not player_settings.sensor_settings['play_time'] then
        player_settings.sensor_settings['play_time'] = {
            ['show_days'] = true,
            ['show_seconds'] = true,
        }
    end
end


function evogui.create_sensor_display(player)
    local root = player.gui.top.evogui_root
    local destroyed = false
    if root then
        player.gui.top.evogui_root.destroy()
        destroyed = true
    end

    if not root or destroyed then
        local root = player.gui.top.add{type="frame",
                                        name="evogui_root",
                                        direction="horizontal",
                                        style="EvoGUI_outer_frame_no_border"}

        local action_buttons = root.add{type="flow",
                                        name="action_buttons",
                                        direction="vertical",
                                        style="EvoGUI_cramped_flow_v"}
        action_buttons.add{type="button",
                           name="evoGUI_toggle_popup",
                           style="EvoGUI_expando_closed"}
        if global.evogui[player.name].popup_open then
            action_buttons.evoGUI_toggle_popup.style = "EvoGUI_expando_open"
        end
        action_buttons.add{type="button",
                           name="evogui_settings_gui_settings_open",
                           style="EvoGUI_settings"}

        local sensor_flow = root.add{type="flow",
                                     name="sensor_flow",
                                     direction="vertical",
                                     style="EvoGUI_cramped_flow_v"}
        sensor_flow.add{type="flow",
                        name="always_visible",
                        direction="vertical",
                        style="EvoGUI_cramped_flow_v"}
        sensor_flow.add{type="flow",
                        name="in_popup",
                        direction="vertical",
                        style="EvoGUI_cramped_flow_v"}
    end
end


local function update_sensors(element, sensor_list, active_sensors)
    for _, sensor in ipairs(sensor_list) do
        if active_sensors[sensor.name] then
            local status, err = pcall(sensor.create_ui, sensor, element)
            if err then error({"err_specific", sensor.name, "create_ui", err}) end
            status, err = pcall(sensor.update_ui, sensor, element)
            if err then error({"err_specific", sensor.name, "update_ui", err}) end
        else
            local status, err = pcall(sensor.delete_ui, sensor, element)
            if err then error({"err_specific", sensor.name, "delete_ui", err}) end
        end
    end
end


function evogui.update_av(player, element)
    local always_visible = global.evogui[player.name].always_visible

    update_sensors(element, evogui.value_sensors, always_visible)
end


function evogui.update_ip(player, element)
    if not global.evogui[player.name].popup_open then return end

    local in_popup = global.evogui[player.name].in_popup

    update_sensors(element, evogui.value_sensors, in_popup)
end


function evogui.evoGUI_toggle_popup(event)
    local player = game.players[event.player_index]
    local player_settings = global.evogui[player.name]

    local root = player.gui.top.evogui_root

    if player_settings.popup_open then
        -- close it
        player_settings.popup_open = false

        for _, childname in ipairs(root.sensor_flow.in_popup.children_names) do
            root.sensor_flow.in_popup[childname].destroy()
        end

        root.action_buttons.evoGUI_toggle_popup.style = "EvoGUI_expando_closed"
    else
        -- open it
        player_settings.popup_open = true

        evogui.update_ip(player, root.sensor_flow.in_popup)
        root.action_buttons.evoGUI_toggle_popup.style = "EvoGUI_expando_open"
    end
end
