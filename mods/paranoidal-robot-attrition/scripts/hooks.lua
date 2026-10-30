-- Extension points of the mechanic. Built-in features register here too (reliability in control.lua); other
-- features plug in the same way instead of changing the scan. All functions must be deterministic.
--
-- ctx (reused, valid during one network check): force, surface, network, busy, waiting (robots waiting to charge),
-- load (busy × busy_weight + waiting × queue_weight), queued (number of cells with a queue), cells, counts
-- (those cells and their queue lengths), risk, multiplier (all built-in multipliers together).
local M = {}

-- function(ctx) -> number: multiplies the expected crash count of the network.
M.rate = {}

-- function(robot, ctx) -> boolean: true keeps a picked robot flying (it still counts for the risk).
M.spare = {}

-- function(ctx, count) -> array of LuaEntity: which logistic robots are picked. Set by scripts/select.lua.
M.select = nil

return M
