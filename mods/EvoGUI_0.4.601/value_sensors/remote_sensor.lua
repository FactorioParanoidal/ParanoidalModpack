require "template"

RemoteSensor = {}
function RemoteSensor.new(sensor_data)
    local sensor = ValueSensor.new("remote_sensor_" .. sensor_data.name)

    sensor["mod_name"] = sensor_data.mod_name
    sensor["line"] = sensor_data.text
    sensor["display_name"] = {"sensor.remote.settings_title_format", sensor_data.mod_name, sensor_data.caption}
    sensor["color"] = sensor_data.color

    function sensor:set_line(text)
        self.line = text
    end

    function sensor:get_line(player)
        return self.line
    end

    ValueSensor.register(sensor)
    if not global.remote_sensors then
        global.remote_sensors = {}
    end

    -- store sensor data for global serialization
    global.remote_sensors[sensor_data.name] = sensor_data
end

function RemoteSensor.get_by_name(name)
    return ValueSensor.get_by_name("remote_sensor_" .. name)
end

local remote_initialized = false

function RemoteSensor.initialize()
    if remote_initialized then return end

     -- Initialize any remote sensors that were previously saved
    if global.remote_sensors then
        for _, sensor_data in pairs(global.remote_sensors) do
            if not RemoteSensor.get_by_name(sensor_data.name) then
                RemoteSensor.new(sensor_data)
            end
        end
    end

    remote_initialized = true
end

return RemoteSensor
