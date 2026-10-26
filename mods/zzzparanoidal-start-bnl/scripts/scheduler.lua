-- Timed jobs of the BnL start: one sorted queue in storage, one on_nth_tick handler that exists
-- only while the queue is not empty. When the start content has played out nothing is left
-- registered. Jobs are {tick, kind, data}; handlers are registered by modules at load.
local M = {}

local INTERVAL = 30
local handlers = {}
local run

function M.handler(kind, fn)
    handlers[kind] = fn
end

local function queue()
    return storage.bnl and storage.bnl.queue
end

function M.at(tick, kind, data)
    local q = storage.bnl.queue
    local job = {tick = tick, kind = kind, data = data}
    local low, high = 1, #q + 1
    while low < high do
        local mid = math.floor((low + high) / 2)
        if q[mid].tick <= tick then low = mid + 1 else high = mid end
    end
    table.insert(q, low, job)
    if #q == 1 then script.on_nth_tick(INTERVAL, run) end
    return job
end

function M.after(delay, kind, data)
    return M.at(game.tick + math.max(1, math.floor(delay)), kind, data)
end

function M.cancel(kind)
    local q = queue()
    if not q then return end
    for i = #q, 1, -1 do
        if q[i].kind == kind then table.remove(q, i) end
    end
    if not q[1] then script.on_nth_tick(INTERVAL, nil) end
end

function M.has(kind)
    for _, job in ipairs(queue() or {}) do
        if job.kind == kind then return true end
    end
    return false
end

run = function(event)
    local q = storage.bnl.queue
    local now = event.tick
    while q[1] and q[1].tick <= now do
        local job = table.remove(q, 1)
        local fn = handlers[job.kind]
        if fn then
            fn(job.data, now)
        else
            log("zzzparanoidal-start-bnl: no handler for job " .. tostring(job.kind))
        end
    end
    if not q[1] then script.on_nth_tick(INTERVAL, nil) end
end

function M.on_load()
    local q = queue()
    if q and q[1] then script.on_nth_tick(INTERVAL, run) end
end

M.on_init = M.on_load

return M
