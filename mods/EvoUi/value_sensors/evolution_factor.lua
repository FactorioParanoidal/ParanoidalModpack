require "template"

local sensor = ValueSensor.new("evolution_factor")
sensor.extra_precision = sensor:make_on_click_checkbox_handler("extra_precision")

function sensor:get_line(player)
    local percent_evo_factor = game.forces.enemy.get_evolution_factor(player.surface) * 100
    -- this nonsense is because string.format(%.4f) is not safe in MP across platforms, but integer math is
    local whole_number = math.floor(percent_evo_factor)
    local fractional_component = math.floor((percent_evo_factor - whole_number) * 10)
    if self.settings.extra_precision then
        fractional_component = math.floor((percent_evo_factor - whole_number) * 10000)
        return {self.format_key, string.format("%d.%04d%%", whole_number, fractional_component)}
    end

    return {self.format_key, string.format("%d.%d%%", whole_number, fractional_component)}
end


function sensor:settings_gui(player_index)
    local player = game.players[player_index]
    local sensor_settings = storage.EvoUi[player.name].sensor_settings[self.name]
    local root_name = self:settings_root_name()

    local root = player.gui.center.add{type="frame",
                                       name=root_name,
                                       direction="vertical",
                                       caption={"sensor.evolution_factor.settings.title"}}
    root.add{type="checkbox", name="EvoUi_sensor_evolution_factor_checkbox_extra_precision",
             caption={"sensor.evolution_factor.settings.extra_precision"},
             state=sensor_settings.extra_precision}

    root.add{type="button", name="EvoUi_sensor_evolution_factor_close", caption={"settings_close"}}
end

ValueSensor.register(sensor)
