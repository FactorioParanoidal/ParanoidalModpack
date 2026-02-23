
ValueSensor = {}

if not EvoUi then EvoUi = {} end
if not EvoUi.value_sensors then EvoUi.value_sensors = {} end

function ValueSensor.new(name)
    local sensor = {
        ["name"] = name,
        ["display_name"] = { "sensor."..name..".name" },
        ["format_key"] = "sensor."..name..".format",
        ["color"] = { r = 255, g = 255, b = 255 },
    }

    function sensor:get_line(player)
        return self.display_name
    end

    function sensor:create_ui(owner)
        if owner[self.name] == nil then
            owner.add{type="label", name=self.name}
        end
    end

    function sensor:update_ui(owner)
        local player = game.players[owner.player_index]
        local sensor_settings = storage.EvoUi[player.name].sensor_settings[self.name]

        self.settings = sensor_settings

        owner[self.name].caption = self:get_line(player)
        owner[self.name].style.font_color = self.color
    end

    function sensor:delete_ui(owner)
        if owner[self.name] ~= nil then
            owner[self.name].destroy()
        end
    end

    function sensor:settings_root_name()
        return self.name.."_settings"
    end

    function sensor:on_click(event)
        if string.starts_with(event.element.name, "EvoUi_sensor_" .. self.name .. "_checkbox_") then
            local len = string.len("EvoUi_sensor_" .. self.name .. "_checkbox_")
            local function_name = event.element.name:sub(len + 1,-1)
            self[function_name](event)
        else
            self:close_settings_gui(event.player_index)
        end
    end

    function sensor:close_settings_gui(player_index)
        local player = game.players[player_index]
        local root_name = self:settings_root_name()

        player.gui.center[root_name].destroy()

        if self.settings_gui_closed then self.settings_gui_closed(player_index) end
    end

    function sensor:make_on_click_checkbox_handler(setting_name)
        local sensor_name = self.name

        return function(event)
            local player = game.players[event.player_index]
            local sensor_settings = storage.EvoUi[player.name].sensor_settings[sensor_name]

            sensor_settings[setting_name] = event.element.state
        end
    end

    return sensor
end

function ValueSensor.register(sensor)
    table.insert(EvoUi.value_sensors, sensor)
end

function ValueSensor.get_by_name(sensor_name)
    for _, sensor in pairs(EvoUi.value_sensors) do
        if sensor.name == sensor_name then
            return sensor
        end
    end
    return nil
end

return ValueSensor
