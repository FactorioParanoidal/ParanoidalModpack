-- All ruins ordered by size
---@type table<string, Ruin[]>
local ruin_sets = {}

-- Load all ruin sets
for _, size in pairs({"small", "medium", "large"}) do
	ruin_sets[size] = require(size .. "/__init__")
end

return ruin_sets
