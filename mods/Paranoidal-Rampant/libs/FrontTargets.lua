-- Weak objectives by region; no engine queries and no whole-surface target list.
local front = {}
local live = require("ChunkQueue").isLive
local floor = math.floor
local SIZE, LIMIT = 512, 256

function front.region(x, y)
    return floor(x / SIZE) .. ":" .. floor(y / SIZE)
end

function front.defence(chunk, count)
    if chunk.frontDefence ~= nil and chunk.frontDefence ~= count then
        chunk.frontDefenceRevision = (chunk.frontDefenceRevision or 0) + 1
    end
    chunk.frontDefence = count
end

local function touch(data, cell)
    if data.tail == cell then return end
    if cell.prev then cell.prev.next = cell.next elseif data.head == cell then data.head = cell.next end
    if cell.next then cell.next.prev = cell.prev end
    cell.prev, cell.next = data.tail, nil
    if data.tail then data.tail.next = cell else data.head = cell end
    data.tail = cell
end

local function better(a, b)
    if a.score ~= b.score then return a.score > b.score end
    if a.chunk.x ~= b.chunk.x then return a.chunk.x < b.chunk.x end
    return a.chunk.y < b.chunk.y
end

function front.observe(map, chunk, score, shore, tick)
    local data = map.frontTargets
    local epoch = map.universe.frontRevision
    if not data or data.epoch ~= epoch then
        if not score then return end
        data = {epoch = epoch, cells = {}, count = 0, turns = {}, turnSlots = {}, turnSeat = 1}
        map.frontTargets = data
    end
    local key = front.region(chunk.x, chunk.y)
    local cell = data.cells[key]
    if not cell then
        if not score then return end
        if data.count == LIMIT then
            local old = data.head
            data.cells[old.key] = nil
            data.head = old.next
            data.head.prev = nil
        else
            data.count = data.count + 1
        end
        cell = {key = key, best = {}, changing = {}, nextSeat = 1}
        data.cells[key] = cell
        touch(data, cell)
    end
    local best, changing = cell.best, cell.changing
    for i = 1, 2 do
        local a, b = best[i], changing[i]
        if a and (a.chunk == chunk or not live(map, a.chunk)) then best[i] = nil end
        if b and (not live(map, b.chunk) or (not score and b.chunk == chunk)) then changing[i] = nil end
    end
    if not best[1] then best[1], best[2] = best[2], nil end
    if not score then return end
    local entry = {chunk = chunk, score = score, shore = shore, tick = tick, cell = cell}
    if not best[1] or better(entry, best[1]) then
        best[1], best[2] = entry, best[1] or best[2]
    elseif not best[2] or better(entry, best[2]) then
        best[2] = entry
    end
    for i = 1, 2 do
        if changing[i] and changing[i].chunk == chunk then changing[i] = entry; return end
    end
    changing[cell.nextSeat] = entry
    cell.nextSeat = 3 - cell.nextSeat
end

-- At most 36 buckets / 144 slots for the configured ranges. Use the cached
-- scores for a shortlist only; only the caller tests current defence.
function front.candidates(map, x, y, radius, excluded)
    local data = map.frontTargets
    if not data or data.epoch ~= map.universe.frontRevision then return {} end
    local candidates, seen = {}, {}
    local radius2 = radius * radius
    for sx = floor((x - radius) / SIZE), floor((x + radius) / SIZE) do
        for sy = floor((y - radius) / SIZE), floor((y + radius) / SIZE) do
            local cell = data.cells[sx .. ":" .. sy]
            if cell then
                for i = 1, 4 do
                    local e = i <= 2 and cell.best[i] or cell.changing[i - 2]
                    local c = e and e.chunk
                    if c and not seen[c] and not (excluded and excluded[c]) and live(map, c) then
                        local dx, dy = c.x + 16 - x, c.y + 16 - y
                        local d2 = dx * dx + dy * dy
                        if d2 <= radius2 then
                            seen[c] = true
                            local d = math.sqrt(d2)
                            candidates[#candidates + 1] = {entry = e, distance = d, score = e.score / (1 + d / 640), chunk = c}
                        end
                    end
                end
            end
        end
    end
    table.sort(candidates, better)
    local result, n = {}, #candidates
    local top = math.min(n, 8)
    for i = 1, top do result[i] = candidates[i] end
    local rest = n - top
    if rest > 0 then
        local visited = math.min(7, rest) -- leave the 16th check for the assigned objective
        local key = front.region(x, y) .. ":" .. radius
        local turn = data.turns[key]
        if not turn then
            local old = data.turnSlots[data.turnSeat]
            if old then data.turns[old] = nil end
            data.turnSlots[data.turnSeat] = key
            data.turnSeat = data.turnSeat % LIMIT + 1
            turn = 0
        end
        for i = 1, visited do result[top + i] = candidates[top + (turn + i - 1) % rest + 1] end
        data.turns[key] = (turn + visited) % rest
    end
    return result
end

function front.used(map, entry)
    local data = map.frontTargets
    local cell = entry and entry.cell
    if data and cell and data.cells[cell.key] == cell then touch(data, cell) end
end

return front
