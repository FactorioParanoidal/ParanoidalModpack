-- Per-force counters of the quality-control panel. Only counts what the mod's own handlers
-- processed; this is not a statistic of the whole factory.
local M = {}

function M.add(force_index, key, amount)
    if not storage or not force_index then return end
    local root = storage.ic_stats
    if not root then
        root = {}
        storage.ic_stats = root
    end
    local counters = root[force_index]
    if not counters then
        counters = {}
        root[force_index] = counters
    end
    counters[key] = (counters[key] or 0) + (amount or 1)
end

function M.get(force_index)
    local root = storage and storage.ic_stats
    return root and root[force_index] or {}
end

function M.reset(force_index)
    if storage and storage.ic_stats then storage.ic_stats[force_index] = nil end
end

return M
