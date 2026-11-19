-- Independent evidence for rail transits. A sample alone never adds heat.
local rail = {}
local MIN_GAP, MAX_GAP, CELL_LIMIT = 1200, 18000, 256

function rail.drop(index, id)
    if id and index.railRequireMove then index.railRequireMove[id] = nil end
    local last = index.railLast
    local record = last and last[id]
    if record then
        record.removed = true
        last[id] = nil
    end
end

function rail.visit(map, index, id, forceName, chunk, tick)
    local u = map.universe
    if not index.rail or index.rail.epoch ~= u.frontRevision then
        index.rail = {epoch = u.frontRevision, cells = {}, slots = {}, seat = 1}
        index.railLast = {}
    end
    if not (u.activePlayerForceSet and u.activePlayerForceSet[forceName]) then
        rail.drop(index, id)
        return false
    end
    local record = index.railLast[id]
    if not record then
        record = {forceName = forceName}
        index.railLast[id] = record
    end
    if record.forceName ~= forceName then
        rail.drop(index, id)
        record = {forceName = forceName}
        index.railLast[id] = record
    end
    local fresh = index.railRequireMove
    if fresh and fresh[id] then
        -- A split/join changes IDs, not the fact that the train was here already.
        fresh[id], record.chunk = nil, chunk
        return false
    end
    if record.chunk == chunk then return false end -- stationary/dwelling in a sampled chunk
    record.chunk = chunk
    if chunk == -1 then return false end

    local data = index.rail
    local first = data.cells[chunk]
    if first and not first.train.removed and tick - first.tick <= MAX_GAP then
        if tick - first.tick < MIN_GAP then return false end -- keep the first witness
        -- If it is the same train, reaching here proves a different sampled chunk in between.
        first.tick, first.train = tick, record
        return true
    end
    if not first then
        local slot = data.seat
        local old = data.slots[slot]
        if old then data.cells[old] = nil end
        data.slots[slot] = chunk
        data.seat = slot % CELL_LIMIT + 1
    end
    data.cells[chunk] = {tick = tick, train = record}
    return false
end

return rail
