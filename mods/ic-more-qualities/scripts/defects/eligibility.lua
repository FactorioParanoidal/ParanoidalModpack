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

-- Finished products that never get defects (weapons, ammo, turrets unless enabled by setting).
local no_defect_cache
function M.no_defect()
    if not no_defect_cache then
        local mod_data = prototypes.mod_data[M.mod_data_name]
        no_defect_cache = mod_data and mod_data.data.no_defect or {}
    end
    return no_defect_cache
end

-- Deterministic prototype-derived cache; rebuilt after load/configuration.
function M.reset()
    cache = nil
    no_defect_cache = nil
end

function M.is_finished(name)
    return M.finished()[name] == true
end

return M
