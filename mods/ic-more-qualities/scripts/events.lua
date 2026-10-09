-- Single registration point. Factorio keeps one handler per event and mod, so every subsystem
-- adds its handlers here and bind() registers each event exactly once, merging event filters.
local M = {handlers = {}, filters = {}, unfiltered = {}, order = {}}

function M.on(event, handler, filters)
    assert(event ~= nil, "Unknown event")
    local list = M.handlers[event]
    if not list then
        list = {}
        M.handlers[event] = list
        M.order[#M.order + 1] = event
    end
    list[#list + 1] = handler
    if filters then
        local merged = M.filters[event] or {}
        for _, filter in ipairs(filters) do merged[#merged + 1] = filter end
        M.filters[event] = merged
    else
        M.unfiltered[event] = true
    end
end

function M.bind()
    for _, event in ipairs(M.order) do
        local list = M.handlers[event]
        local handler = list[1]
        if #list > 1 then
            handler = function(data)
                for index = 1, #list do list[index](data) end
            end
        end
        local filters = not M.unfiltered[event] and M.filters[event] or nil
        if filters then script.on_event(event, handler, filters) else script.on_event(event, handler) end
    end
end

return M
