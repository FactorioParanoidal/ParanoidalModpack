require "template"

local sensor = ValueSensor.new("evolution_factor")
sensor.extra_precision = sensor:make_on_click_checkbox_handler("extra_precision")

local function read_evolution(surface, surface_index)
    local iface = remote.interfaces["rampantFixed"]
    local info = iface and iface.getTruceInfo and remote.call("rampantFixed", "getTruceInfo", {
        surfaceIndex = surface_index, includeEvolution = true
    })
    local evolution = info and info.evolution or game.forces.enemy.get_evolution_factor(surface)
    return {evolution = evolution, truce = info and info.truce, min_evo = info and info.minEvo}
end

function sensor:get_line(player, evolution_by_surface)
    local surface = player.surface
    local surface_index = surface.index
    local snapshot = evolution_by_surface and evolution_by_surface[surface_index]
    if not snapshot then
        snapshot = read_evolution(surface, surface_index)
        if evolution_by_surface then evolution_by_surface[surface_index] = snapshot end
    end
    local percent_evo_factor = snapshot.evolution * 100
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

    if snapshot.truce then
        local min_evo = snapshot.min_evo
        -- Compare in the same units as Rampant; converting to percent can round to the threshold.
        if type(min_evo) == "number" and snapshot.evolution < min_evo * 0.01 then
            return {"sensor.evolution_factor.format_truce", evo_text, tostring(min_evo)}
        end
        return {"sensor.evolution_factor.format_truce_time", evo_text}
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
