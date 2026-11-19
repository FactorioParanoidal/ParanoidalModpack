-- One persistent deadline per live hive. Earlier deadlines win; ties use
-- insertion order. There is no catch-up work for missed intervals.
local clock = {}

function clock.new()
    return {heap = {}, handles = {}, serial = 0}
end

local function earlier(a, b)
    return a.due < b.due or (a.due == b.due and a.serial < b.serial)
end

local function put(queue, slot, node)
    queue.heap[slot], queue.handles[node.id] = node, slot
end

local function raise(queue, slot, node)
    local heap = queue.heap
    while slot > 1 do
        local parent = math.floor(slot / 2)
        if not earlier(node, heap[parent]) then break end
        put(queue, slot, heap[parent])
        slot = parent
    end
    put(queue, slot, node)
end

function clock.add(queue, id, due)
    if queue.handles[id] then return end
    queue.serial = queue.serial + 1
    raise(queue, #queue.heap + 1, {id = id, due = due, serial = queue.serial})
end

function clock.drop(queue, id)
    if not queue then return end
    local slot = queue.handles[id]
    if not slot then return end
    local heap = queue.heap
    local n = #heap
    local node = heap[n]
    heap[n], queue.handles[id] = nil, nil
    if slot == n then return end
    if slot > 1 and earlier(node, heap[math.floor(slot / 2)]) then
        raise(queue, slot, node)
        return
    end
    local child = slot * 2
    while child < n do
        if child + 1 < n and earlier(heap[child + 1], heap[child]) then child = child + 1 end
        if not earlier(heap[child], node) then break end
        put(queue, slot, heap[child])
        slot, child = child, child * 2
    end
    put(queue, slot, node)
end

function clock.take(queue, tick)
    local node = queue.heap[1]
    if node and node.due <= tick then
        clock.drop(queue, node.id)
        return node.id, node.due
    end
end

return clock
