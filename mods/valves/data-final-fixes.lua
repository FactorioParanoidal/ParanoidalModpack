-- A valve faster than the fluid flow limit would look like it does not pump at full speed, so cap it here.
-- https://mods.factorio.com/mod/configurable-valves/discussion/687adff5090859d1e32f130e
-- Factorio 2.1 removed the utility constant max_fluid_flow: the limit is derived from the fluid box volume (engine
-- probe test-runs/port21-flow-20261102: a one-way valve set to 1000 per tick moved 159 / 393 / 1000 per tick with a
-- fluid box volume of 100 / 400 / 2000), so the valve is capped at its own fluid box volume.
for _, valve in ipairs(require("config")) do
    local prototype = data.raw.valve[valve.name]
    assert(prototype, "Клапан '" .. valve.name .. "' не найден в data.raw.valve")
    prototype.flow_rate = math.min(prototype.flow_rate, prototype.fluid_box.volume)
end
