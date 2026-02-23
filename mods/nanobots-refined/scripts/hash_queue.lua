local table = require('__stdlib2__/stdlib/utils/table')

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
    t.active = false
end

function Queue.set_hash(t, data)
    --TODO: rename, not all are entities anymore
    local index = cantorPair_v7(data.entity.position)
    local hash = t._hash
    hash[index] = data.action 
    --not sure why it's putting in data.action instead of data
    --or even just true, since it doesn't seem to matter WHAT the contents are so much as that they exist
    --but I'm not going to risk changing that as well
    return index
end

function Queue.count(t)
    local count
    if not active then
        count = 0
    else
        count = last - next + 1
    end

    return count, table.size(t._hash)
end

function Queue.get_hash(t, entity)
    local index = cantorPair_v7(entity.position)
    return t._hash[index]
end

function Queue.insert(t, data)
    data.hash = Queue.set_hash(t, data)

    if not t.active then
        t.active = true
        t.last = 0
        t.next = 1
    end
    
    t.last = t.last + 1
    t[t.last] = data

    return t
end

--Executes the next action in the queue
function Queue.execute(t)
    local data = t[t.next]
    
    if not data then
        game.print("Nanobots error! Queue task missing?")
        return false
    end
    
    local success = false
    if Queue[data.action] then
        success = Queue[data.action](data)
    end
    
    local index = data.hash
    t._hash[index] = nil
    
    t[t.next] = nil
    t.next = t.next + 1
    if t.next > t.last then
        t.active = false
    end
    
        
    return success
end

Queue.mt = {__index = Queue, __call = nil}
local mt = {
    __call = function(_, ...)
        return Queue.new(...)
    end
}

return setmetatable(Queue, mt)
