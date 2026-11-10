-- Merge only fields with known semantics; timestamps and streaks are not counters.
local table = require("__flib__.table")
local sandbox = require("scripts.sandbox")
local M = {}

local function union(destination, source)
    destination = destination or {}
    for name, value in pairs(source or {}) do if value then destination[name] = true end end
    return destination
end

local function merge_legendary(destination, source)
    destination = destination or {}
    for name, value in pairs(source or {}) do
        if type(value) == "number" then destination[name] = (destination[name] or 0) + value
        elseif type(value) == "table" then destination[name] = union(destination[name], value)
        elseif value == true then destination[name] = true end
    end
    return destination
end

function M.merge(state, event)
    local source_index, destination = event.source_index, event.destination
    local destination_index = destination.index
    local ignored = sandbox.is_force_name(event.source_name) or sandbox.is_force(destination)
    local source, own = state.forces[source_index], state.forces[destination_index]
    if not ignored then
        own = own or {}
        state.forces[destination_index] = own
        if source then
            local known = {refined=true, launches=true, paints=true, auto_deconstructed=true,
                gases=true, bosses=true, legendary=true, gases_tick=true, launch_ticks=true,
                quiet_ticks=true, quiet_crashes=true}
            for _, field in ipairs({"refined", "launches", "paints", "auto_deconstructed"}) do
                if source[field] then own[field] = (own[field] or 0) + source[field] end
            end
            own.gases = union(own.gases, source.gases)
            own.bosses = union(own.bosses, source.bosses)
            own.legendary = merge_legendary(own.legendary, source.legendary)
            local recent = {}
            for _, list in ipairs({own.launch_ticks or {}, source.launch_ticks or {}}) do
                for _, tick in ipairs(list) do
                    if tick > game.tick - 216000 then recent[#recent + 1] = tick end
                end
            end
            table.sort(recent)
            own.launch_ticks = recent
            for field, value in pairs(source) do
                if not known[field] and own[field] == nil then
                    own[field] = type(value) == "table" and table.deep_copy(value) or value
                end
            end
        end
        own.gases_tick = nil
        own.quiet_ticks, own.quiet_crashes = 0, nil
        state.unlocked.forces[destination_index] = union(state.unlocked.forces[destination_index], state.unlocked.forces[source_index])
    end
    for unit, record in pairs(state.world.cargo_pods or {}) do
        if record.force == source_index then
            if ignored then state.world.cargo_pods[unit] = nil else record.force = destination_index end
        end
    end
    state.forces[source_index] = nil
    state.unlocked.forces[source_index] = nil
    return not ignored and destination or nil
end

return M
