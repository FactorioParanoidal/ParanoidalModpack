local config = require("config")
local valve_config = data.raw["mod-data"]["mod-valves"].data.valves
for valve_name, _ in pairs(config.valves) do
    valve_config[valve_name] = { name = valve_name }
end