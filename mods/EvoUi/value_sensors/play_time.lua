require "template"

local sensor = ValueSensor.new("play_time")
sensor.show_days = sensor:make_on_click_checkbox_handler("show_days")
sensor.show_seconds = sensor:make_on_click_checkbox_handler("show_seconds")
sensor.show_personal_time = sensor:make_on_click_checkbox_handler("show_personal_time")


local function format_play_time(ticks, settings)
    local seconds = math.floor(ticks / 60)
    local minutes = math.floor(seconds / 60)
    local hours = math.floor(minutes / 60)
    local days = math.floor(hours / 24)

    local result = {""}
    if days > 0 and settings.show_days then
        if days == 1 then
            table.insert(result, {"sensor.play_time.single_day_fragment"})
        else
            table.insert(result, {"sensor.play_time.multi_day_fragment", tostring(days)})
        end
        table.insert(result, ' ')
        hours = hours % 24
    end

    if settings.show_seconds then
        table.insert(result, string.format("%d:%02d:%02d", hours, minutes % 60, seconds % 60))
    else
        table.insert(result, string.format("%d:%02d", hours, minutes % 60))
    end

    return result
end


function sensor:get_line(player)
    local desc = {"", format_play_time(game.tick, self.settings)}

    if self.settings.show_personal_time then
        table.insert(desc, ' ')
        table.insert(desc, {"sensor.play_time.personal_time_fragment", format_play_time(player.online_time, self.settings)})
    end

    return {self.format_key, desc}
end


function sensor:settings_gui(player_index)
    local player = game.players[player_index]
    local sensor_settings = storage.EvoUi[player.name].sensor_settings[self.name]
    local root_name = self:settings_root_name()

    local root = player.gui.center.add{type="frame",
                                       name=root_name,
                                       direction="vertical",
                                       caption={"sensor.play_time.settings.title"}}
    root.add{type="checkbox", name="EvoUi_sensor_play_time_checkbox_show_days",
             caption={"sensor.play_time.settings.show_days"},
             state=sensor_settings.show_days}

    root.add{type="checkbox", name="EvoUi_sensor_play_time_checkbox_show_seconds",
             caption={"sensor.play_time.settings.show_seconds"},
             state=sensor_settings.show_seconds}

    root.add{type="checkbox", name="EvoUi_sensor_play_time_checkbox_show_personal_time",
             caption={"sensor.play_time.settings.show_personal_time"},
             state=sensor_settings.show_personal_time or false}

    root.add{type="button", name="EvoUi_sensor_play_time_close", caption={"settings_close"}}
end


ValueSensor.register(sensor)
