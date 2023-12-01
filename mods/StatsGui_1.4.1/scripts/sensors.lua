local constants = require("constants")

local sensors = {}

for _, sensor_data in pairs(constants.builtin_sensors) do
  sensors[#sensors + 1] = require("scripts.sensor." .. sensor_data.name)
end

return sensors
