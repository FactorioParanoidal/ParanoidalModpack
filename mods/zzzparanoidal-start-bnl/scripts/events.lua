-- One handler per event for the whole mod. Modules add handlers; static ones are registered once
-- at load, dynamic ones only while a module needs them (need() reads storage only, so on_load
-- registers exactly what on_init/on_configuration_changed registered).
local M = {}

local static, filters, unfiltered = {}, {}, {}
local dynamic, dynamic_order = {}, {}

function M.on(id, fn, filter)
    local list = static[id]
    if not list then
        list = {}
        static[id] = list
    end
    list[#list + 1] = fn
    if filter then
        local merged = filters[id] or {}
        for _, entry in ipairs(filter) do merged[#merged + 1] = entry end
        filters[id] = merged
    else
        unfiltered[id] = true
    end
end

function M.dynamic(id, fn, need)
    local entry = dynamic[id]
    if not entry then
        entry = {fns = {}, needs = {}}
        dynamic[id] = entry
        dynamic_order[#dynamic_order + 1] = id
    end
    entry.fns[#entry.fns + 1] = fn
    entry.needs[#entry.needs + 1] = need
end

local function caller(list)
    if #list == 1 then return list[1] end
    return function(event)
        for i = 1, #list do list[i](event) end
    end
end

function M.install()
    for id, list in pairs(static) do
        local filter = not unfiltered[id] and filters[id] or nil
        if filter and filter[1] then
            script.on_event(id, caller(list), filter)
        else
            script.on_event(id, caller(list))
        end
    end
end

-- Registers the dynamic handlers that are needed now. Only a change is applied: several modules
-- share on_tick and call this whenever their own list runs empty, which happens every tick while
-- another module still needs the event. `entry.on` lives in the Lua state only (not saved): after
-- on_load it starts nil, so the first refresh registers exactly what storage needs.
function M.refresh()
    for _, id in ipairs(dynamic_order) do
        local entry = dynamic[id]
        local needed = false
        for _, need in ipairs(entry.needs) do
            if need() then
                needed = true
                break
            end
        end
        if needed ~= entry.on then
            entry.on = needed
            if needed then
                entry.handler = entry.handler or caller(entry.fns)
                script.on_event(id, entry.handler)
            else
                script.on_event(id, nil)
            end
        end
    end
end

return M
