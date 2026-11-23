-- Pure arithmetic: the interface buffer is the entire credit, never an unlimited debt.
local M = {}
local saving = {0, 0.025, 0.05, 0.10}
local power = {0, 0.05, 0.10, 0.15}

function M.multiplier(fuel_tier, power_tier)
    return (1 + power[power_tier + 1]) / (1 - saving[fuel_tier + 1])
end

function M.refill(buffer, generated, multiplier, capacity)
    local earned = math.max(0, generated) * math.max(0, multiplier - 1)
    return math.min(capacity, math.max(0, buffer) + earned), earned
end

return M
