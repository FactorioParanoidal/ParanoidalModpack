-- Status signals for the circuit network. A hidden constant combinator sits inside the workshop or
-- post and is connected to both of its circuit connectors with script wires, so every network the
-- player connects to the building receives the signals. Created only when network control is on.
local names = require("scripts.expansion.names")
local M = {}

local connectors = {"circuit_red", "circuit_green"}

function M.create(host)
    if not (host and host.valid) then return nil end
    local emitter = host.surface.create_entity({
        name = names.emitter, position = host.position, force = host.force,
        create_build_effect_smoke = false, raise_built = false,
    })
    if not emitter then return nil end
    emitter.destructible = false
    emitter.operable = false
    for _, id in ipairs(connectors) do
        local from = emitter.get_wire_connector(defines.wire_connector_id[id], true)
        local to = host.get_wire_connector(defines.wire_connector_id[id], true)
        if from and to then from.connect_to(to, false, defines.wire_origin.script) end
    end
    return emitter
end

function M.destroy(emitter)
    if emitter and emitter.valid then emitter.destroy() end
end

-- values: array of {signal name, value}. Rewrites the section only when something changed.
function M.set(record, values)
    local emitter = record.emitter
    if not (emitter and emitter.valid) then return end
    local parts = {}
    for index, entry in ipairs(values) do parts[index] = entry[2] end
    local key = table.concat(parts, ",")
    if record.emitted == key then return end
    record.emitted = key
    local behavior = emitter.get_or_create_control_behavior()
    local section = behavior.get_section(1) or behavior.add_section()
    if not section then return end
    local filters = {}
    for _, entry in ipairs(values) do
        local value = math.floor(entry[2] + 0.5)
        if value ~= 0 then
            filters[#filters + 1] = {value = {type = "virtual", name = entry[1], quality = "normal"}, min = value}
        end
    end
    section.filters = filters
end

-- Sum of a command signal on both wires of the building.
function M.read(host, name)
    if not (host and host.valid) then return 0 end
    if not host.get_wire_connector(defines.wire_connector_id.circuit_red, false) then return 0 end
    return host.get_signal({type = "virtual", name = name},
        defines.wire_connector_id.circuit_red, defines.wire_connector_id.circuit_green) or 0
end

return M
