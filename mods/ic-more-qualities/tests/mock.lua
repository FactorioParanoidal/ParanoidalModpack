-- Minimal Factorio-like globals for pure Lua tests. This is not an engine: it only lets the mod's
-- modules load and lets single functions run against hand-made tables.
local M = {}

-- Event ids: the given names keep their numbers, every other event name gets a fresh id.
function M.auto_events(events)
    local last = 0
    for _, id in pairs(events) do if type(id) == "number" and id > last then last = id end end
    return setmetatable(events, {__index = function(t, key)
        last = last + 1
        rawset(t, key, last)
        return last
    end})
end

function M.defines(events)
    return {
        events = M.auto_events(events or {}),
        inventory = {crafter_input = 2, furnace_source = 2, furnace_result = 3, fuel = 1, chest = 1},
        entity_status = {full_output = "full_output", working = "working"},
        entity_status_diode = {green = "green", yellow = "yellow", red = "red"},
        direction = {north = 0, east = 4, south = 8, west = 12},
        transport_line = {left_line = 1, right_line = 2},
        wire_connector_id = {circuit_red = 1, circuit_green = 2},
        wire_origin = {script = 2},
        target_type = {entity = 1},
        relative_gui_type = {furnace_gui = 1, assembling_machine_gui = 2, container_gui = 3},
        relative_gui_position = {right = 1},
        alert_type = {custom = 1},
    }
end

-- Deterministic RNG from a list (cycled), for exact outcome tests.
function M.sequence(values)
    local index = 0
    return function()
        index = index % #values + 1
        return values[index]
    end
end

function M.near(a, b, epsilon)
    assert(math.abs(a - b) < (epsilon or 1e-9), tostring(a) .. " != " .. tostring(b))
end

return M
