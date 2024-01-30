local table = require('__stdlib__/stdlib/utils/table')

local function NtoZ_c(x, y)
    return (x >= 0 and x or (-0.5 - x)), (y >= 0 and y or (-0.5 - y))
end

local function cantorPair_v7(pos)
    local x, y = NtoZ_c(math.floor(pos.x), math.floor(pos.y))
    local s = x + y
    local h = s * (s + 0.5) + x
    return h + h
end

local Queue = {}

function Queue.new(t)
    if t and t._hash then
        return setmetatable(t, Queue.mt)
    else
        return setmetatable({_hash = {}}, Queue.mt)
    end
end

function Queue.set_hash(t, data)
    local index = data.entity.unit_number or cantorPair_v7(data.entity.position)
    local hash = t._hash
    hash[index] = hash[index] or {}
    hash[index][data.action] = data.action
    return index
end

function Queue.count(t)
    local count = 0
    for index in pairs(t) do
        if type(index) == 'number' then
            count = count + 1
        end
    end

    return count, table.size(t._hash)
end

function Queue.get_hash(t, entity)
    local index = entity.unit_number or cantorPair_v7(entity.position)
    return t._hash[index]
end

function Queue.insert(t, data, tick, count)
    data.hash = Queue.set_hash(t, data)

    t[tick] = t[tick] or {}
    t[tick][#t[tick] + 1] = data

    return t, count
end

function Queue.next(t, _next_tick, tick_spacing, dont_combine)
    tick_spacing = tick_spacing or 1
    local count = 0
    local tick = (_next_tick and _next_tick >= game.tick and _next_tick) or game.tick
    local next_tick = function(really_dont_combine)
        tick = tick + tick_spacing
        while (dont_combine or really_dont_combine) and t[tick] do
            tick = tick + 1
        end
        count = count + 1
        return tick, count
    end
    local queue_count = function(num)
        count = count + (num or 0)
        return count
    end
    return next_tick, queue_count
end

--Tick handler, handles executing multiple data tables in a queue
function Queue.execute(t, event)
    if t[event.tick] then
        for _, data in ipairs(t[event.tick]) do
            local index = data.hash
            if Queue[data.action] then
                Queue[data.action](data)
            end
            t._hash[index][data.action] = nil
            if table.size(t._hash[index]) <= 0 then
                t._hash[index] = nil
            end
        end
        t[event.tick] = nil
    end
    return t
end

Queue.mt = {__index = Queue, __call = nil}
local mt = {
    __call = function(_, ...)
        return Queue.new(...)
    end
}

return setmetatable(Queue, mt)
