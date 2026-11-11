-- Derived constraints from generators, not balance configuration and never prototype writes.
local M = {}
local minimums = {}
function M.minimum(kind, name, value, source)
    assert(type(value) == "number" and value >= 1 and value % 1 == 0, "Invalid stack minimum")
    local key = kind .. "/" .. name
    local old = minimums[key]
    if not old or value > old.size then
        minimums[key] = {kind = kind, name = name, size = value, source = source}
    end
end
function M.get()
    return minimums
end
return M
