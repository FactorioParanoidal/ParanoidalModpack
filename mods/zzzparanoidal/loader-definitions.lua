-- Shared identities only: safe in both data and control stages.
local M = { names = { "bob-basic-loader", "loader", "fast-loader", "express-loader", "bob-turbo-loader", "bob-ultimate-loader" }, shells = {}, machines = {} }
-- Former AAI recipe IDs, same order as names (recipes now carry the item names).
M.old_recipes = { "aai-basic-loader", "aai-loader", "aai-fast-loader", "aai-express-loader", "aai-turbo-loader", "aai-ultimate-loader" }
-- One gate for data and control: the feature needs AAI (recipes/research) and Reskins (graphics API).
-- AAI "graphics-only" creates no loader prototypes/recipes/research, so the feature is off there.
-- Both stages pass the same inputs (active mods, startup settings), so they always agree.
function M.enabled(active, startup)
    if active["aai-loaders"] == nil or active["reskins-library"] == nil then return false end
    local mode = startup and startup["aai-loaders-mode"]
    return mode ~= nil and mode.value ~= "graphics-only"
end
function M.shell(name, mode)
    return "paranoidal-" .. name .. "-shell-" .. (mode or "output")
end
for tier, name in ipairs(M.names) do
    M.machines[name] = tier
    for _, mode in ipairs({ "input", "output" }) do
        M.shells[M.shell(name, mode)] = { machine = name, mode = mode, tier = tier }
    end
end
return M
