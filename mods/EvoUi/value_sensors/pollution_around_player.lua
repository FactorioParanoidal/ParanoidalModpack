require "template"

local sensor = ValueSensor.new("pollution_around_player")

function sensor:get_line(player)
    local surface = player.surface
    local pollution = surface.get_pollution(player.position)

    -- this nonsense is because string.format(%.1f) is not safe in MP across platforms, but integer math is
    local whole_number = math.floor(pollution)
    local fractional_component = math.floor((pollution - whole_number) * 10)

    return {self.format_key, (whole_number .. "." .. fractional_component)}
end

ValueSensor.register(sensor)
