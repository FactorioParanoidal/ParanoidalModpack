local config = { }

---@class ValveConfig : data.ValvesModValveConfig
---@field valve_mode ValveMode
---@field default_threshold float based on the prototype

---@type table<string, ValveConfig>
---@diagnostic disable-next-line: assign-type-mismatch
config.valves = prototypes.mod_data["mod-valves"].data.valves

--- Fill in the information for each valve
for valve_name, valve_config in pairs(config.valves) do
    local prototype = prototypes.entity[valve_name]
    assert(prototype, "Failed to find prototype for: "..valve_name)
    valve_config.valve_mode = prototype.valve_mode
    if valve_config.valve_mode ~= "one-way" then
        valve_config.default_threshold = prototype.valve_threshold
    end
end

return config