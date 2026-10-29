-- Timer wheel shared by the defect scheduler, the refinement workshop and the control post: records are
-- looked at only on the tick they are due, no table is walked on ticks without work.
-- buckets: {[tick] = array of record ids} (kept in storage); record.due tells which entry is current, so a
-- record moved to an earlier tick leaves a stale entry behind that is skipped when its tick comes.
-- Emptied arrays are reused (a local pool: its content is not game state, a reloaded game simply
-- starts with an empty pool).
local M = {}
local pool = {}

-- Schedules `record` (needs record.id) at `tick`.
function M.add(buckets, record, tick)
    record.due = tick
    local bucket = buckets[tick]
    if not bucket then
        local count = #pool
        if count > 0 then
            bucket = pool[count]
            pool[count] = nil
        else
            bucket = {}
        end
        buckets[tick] = bucket
    end
    bucket[#bucket + 1] = record.id
end

-- Schedules the record at `tick` unless it is already due earlier.
function M.advance(buckets, record, tick)
    local due = record.due
    if not due or due > tick then M.add(buckets, record, tick) end
end

-- Removes and returns the bucket of `tick` (nil without work). Give it back with release().
function M.take(buckets, tick)
    local bucket = buckets[tick]
    if bucket then buckets[tick] = nil end
    return bucket
end

function M.release(bucket)
    for index = #bucket, 1, -1 do bucket[index] = nil end
    pool[#pool + 1] = bucket
end

-- Rebuilds the buckets: every record (a table of id -> record) is looked at within `spread` ticks
-- after `tick`, in id order (deterministic). Stale buckets of an older schedule are dropped.
function M.spread(records, tick, spread)
    local ids = {}
    for id in pairs(records) do ids[#ids + 1] = id end
    table.sort(ids)
    local buckets = {}
    for index, id in ipairs(ids) do M.add(buckets, records[id], tick + 1 + index % spread) end
    return buckets
end

return M
