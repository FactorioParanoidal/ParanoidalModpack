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

--- Number of queued tasks, O(1). Used on every queued target, so it must not walk the queue.
--- (Queue.count used the globals `active`/`last`/`next`, always reported 0, and the queue was never capped.)
function Queue.length(t)
    if not t.active then
        return 0
    end
    return t.last - t.next + 1
end

function Queue.count(t)
    return Queue.length(t), table.size(t._hash)
end

function Queue.get_hash(t, entity)
    return Queue.get_hash_at(t, entity.position)
end

function Queue.get_hash_at(t, position)
    return t._hash[cantorPair_v7(position)]
end

--- Drop every queued task at once
function Queue.clear(t)
    if t.active then
        for i = t.next, t.last do
            t[i] = nil
        end
    end
    t._hash = {}
    t.active = false
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

    -- Take the task out before running it: an action may queue its target again, and clearing
    -- the hash afterwards used to wipe the hash of that new entry.
    t._hash[data.hash] = nil
    t[t.next] = nil
    t.next = t.next + 1
    if t.next > t.last then
        t.active = false
    end

    if Queue[data.action] then
        return Queue[data.action](data)
    end
    return false
end

Queue.mt = {__index = Queue, __call = nil}
local mt = {
    __call = function(_, ...)
        return Queue.new(...)
    end
}

return setmetatable(Queue, mt)
