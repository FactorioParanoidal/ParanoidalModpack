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

-- Recipes whose result is always normal (mod-data "ic-normal-result", see data.lua): {name = true}.
M.normal_result_name = "ic-normal-result"
local normal_result_cache
function M.normal_result()
    if not normal_result_cache then
        local mod_data = prototypes.mod_data[M.normal_result_name]
        normal_result_cache = mod_data and mod_data.data.recipes or {}
    end
    return normal_result_cache
end

-- Deterministic prototype-derived cache; rebuilt after load/configuration.
function M.reset()
    cache = nil
    no_defect_cache = nil
    normal_result_cache = nil
end

return M
