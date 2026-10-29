-- Shared identities only: safe in both data and control stages.
local M = { names = { "bob-basic-loader", "loader", "fast-loader", "express-loader", "bob-turbo-loader", "bob-ultimate-loader" }, shells = {}, machines = {} }
-- One gate for data and control: the graphics need the Reskins API.
-- Both stages pass the active mods, so they always agree.
function M.enabled(active)
    return active["reskins-library"] ~= nil
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
