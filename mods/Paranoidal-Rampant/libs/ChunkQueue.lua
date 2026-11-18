local chunkQueue = {}

function chunkQueue.isLive(map, chunk)
    if type(chunk) ~= "table" then
        return false
    end
    local column = map[chunk.x]
    return column and column[chunk.y] == chunk
end

function chunkQueue.get(map, index)
    local chunk = map.processQueue[index]
    if chunkQueue.isLive(map, chunk) then
        local repair = map.chunkQueueRebuild
        local mapped = repair and repair.slots[chunk]
        if not mapped or repair.indices[mapped] == index then return chunk end
    end
end

function chunkQueue.append(map, chunk)
    local queue = map.processQueue
    local slot = #queue + 1
    queue[slot] = chunk
    local slots = map.chunkQueueSlots
    if slots then
        slots[chunk] = slot
    end
end

function chunkQueue.invalidate(map, chunk)
    local slots = map.chunkQueueSlots
    local slot = slots and slots[chunk]
    if slot then
        map.processQueue[slot] = false -- keep a dense array until the bounded compaction finishes
        slots[chunk] = nil
    end
    map.chunkQueueHoles = (map.chunkQueueHoles or 0) + 1
    local rebuild = map.chunkQueueRebuild
    local newSlot = rebuild and rebuild.slots[chunk]
    if newSlot then
        rebuild.queue[newSlot] = false
        rebuild.slots[chunk] = nil
        rebuild.holes = rebuild.holes + 1
    end
end

local forwardCursors = {"cleanupIndex", "scanPlayerIndex", "scanEnemyIndex", "scanResourceIndex", "seedTargetIndex"}

local function moveCursor(indices, old, outgoing, bounce)
    local n = #indices
    if n == 0 then
        return 1, true
    end
    local lo, hi = 1, n + 1
    while lo < hi do
        local mid = math.floor((lo + hi) / 2)
        if indices[mid] < old then lo = mid + 1 else hi = mid end
    end
    if outgoing then
        if lo <= n then return lo, true end
        if bounce then return n, false end
        return 1, true
    end
    if indices[lo] == old then return lo, false end
    if lo > 1 then return lo - 1, false end
    return 1, true
end

-- Copy at most a fixed number of slots per maintenance call. Readers keep using
-- the old order until the whole new queue is ready. Positions in newly appended
-- chunks are included in the same pass. Occasional isolated holes are cheaper
-- to skip than copying an otherwise healthy large surface.
function chunkQueue.maintain(map, discard)
    local old = map.processQueue
    local rebuild = map.chunkQueueRebuild
    local holes = map.chunkQueueHoles or 0
    if not rebuild then
        if map.chunkQueueSlots and (holes == 0 or (holes < 64 and holes * 4 < #old)) then
            return
        end
        rebuild = {queue = {}, indices = {}, slots = {}, next = 1, holes = 0}
        map.chunkQueueRebuild = rebuild
    end
    local n = #old
    local last = math.min(n, rebuild.next + 255)
    for i = rebuild.next, last do
        local chunk = old[i]
        if chunkQueue.isLive(map, chunk) and not rebuild.slots[chunk] then
            local slot = #rebuild.queue + 1
            rebuild.queue[slot] = chunk
            rebuild.indices[slot] = i
            rebuild.slots[chunk] = slot
        elseif discard and type(chunk) == "table" and not chunkQueue.isLive(map, chunk) then
            discard(map, chunk)
            old[i] = false
        end
    end
    if last < n then
        rebuild.next = last + 1
        return
    end
    local indices = rebuild.indices
    for _, field in ipairs(forwardCursors) do
        map[field] = moveCursor(indices, map[field] or 1, true, false)
    end
    map.processIndex, map.outgoingScanWave = moveCursor(indices, map.processIndex or 1, map.outgoingScanWave, true)
    map.processStaticIndex, map.outgoingStaticScanWave = moveCursor(indices, map.processStaticIndex or 1, map.outgoingStaticScanWave, true)
    map.processQueue = rebuild.queue
    map.chunkQueueSlots = rebuild.slots
    map.chunkQueueHoles = rebuild.holes
    map.chunkQueueRebuild = nil
end

return chunkQueue
