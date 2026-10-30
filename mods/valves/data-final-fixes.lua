-- A valve faster than the `max_fluid_flow` utility constant would look like it does not pump at
-- full speed, so cap it here, after other mods have changed the constant.
-- https://mods.factorio.com/mod/configurable-valves/discussion/687adff5090859d1e32f130e
local max_fluid_flow = data.raw["utility-constants"]["default"].max_fluid_flow

for _, valve in ipairs(require("config")) do
    local prototype = data.raw.valve[valve.name]
    assert(prototype, "Valve '" .. valve.name .. "' not found in data.raw.valve")
    prototype.flow_rate = math.min(prototype.flow_rate, max_fluid_flow)
end
