require "template"

local sensor = ValueSensor.new("evolution_factor")
sensor.extra_precision = sensor:make_on_click_checkbox_handler("extra_precision")

-- Paranoidal: Rampant truce threshold (percent) for the player's surface, or nil if
-- RampantFixed is absent or its AI is off on this surface.
local function get_truce_min_evo(surface)
    local iface = remote.interfaces["rampantFixed"]
    if not (iface and iface.getTruceInfo) then return nil end
    local info = remote.call("rampantFixed", "getTruceInfo", {surfaceIndex = surface.index})
    if info and type(info.minEvo) == "number" and info.minEvo > 0 then
        return info.minEvo
    end
    return nil
end

function sensor:get_line(player)
    local percent_evo_factor = game.forces.enemy.get_evolution_factor(player.surface) * 100
    -- this nonsense is because string.format(%.4f) is not safe in MP across platforms, but integer math is
    local whole_number = math.floor(percent_evo_factor)
    local fractional_component = math.floor((percent_evo_factor - whole_number) * 10)
    local evo_text
    if self.settings.extra_precision then
        fractional_component = math.floor((percent_evo_factor - whole_number) * 10000)
        evo_text = string.format("%d.%04d%%", whole_number, fractional_component)
    else
        evo_text = string.format("%d.%d%%", whole_number, fractional_component)
    end

    local truce_min_evo = get_truce_min_evo(player.surface)
    if truce_min_evo and percent_evo_factor < truce_min_evo then
        return {"sensor.evolution_factor.format_truce", evo_text, tostring(truce_min_evo)}
    end

    return {self.format_key, evo_text}
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
