-- Runtime view of the data-stage classification (scripts/defects/classify.lua).
-- Items absent from the set, including ones added after IC's data-final-fixes,
-- are treated as white intermediates: no defect roll, positive quality removed.
local M = {}
M.mod_data_name = "ic-defects-classification"
local cache

function M.finished()
    if not cache then
        local mod_data = prototypes.mod_data[M.mod_data_name]
        cache = mod_data and mod_data.data.finished or {}
    end
    return cache
end

-- Deterministic prototype-derived cache; rebuilt after load/configuration.
function M.reset()
    cache = nil
end

function M.is_finished(name)
    return M.finished()[name] == true
end

return M
