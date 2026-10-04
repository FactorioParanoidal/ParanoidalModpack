-- 1.1 did not clip recipe productivity at +300%. Give the restored module
-- combinations enough headroom without assigning an arbitrary infinite cap.
-- Current pack: Quality off; beacons do not accept productivity modules.
-- Mining/lab bonuses are not recipe productivity and are deliberately excluded.
local function permits(list, value)
    if list == nil then return true end
    if type(list) == "string" then return list == value end
    for _, entry in pairs(list) do if entry == value then return true end end
    return false
end
local modules = {}
for _, module in pairs(data.raw.module or {}) do
    local hidden = module.hidden or permits(module.flags or {}, "hidden")
    if not hidden and module.effect and (module.effect.productivity or 0) > 0 then
        modules[#modules + 1] = module
    end
end
local capacity = {}
for _, entity_type in ipairs({ "assembling-machine", "furnace", "rocket-silo" }) do
    for _, machine in pairs(data.raw[entity_type] or {}) do
        local slots = machine.module_slots or 0
        local receiver = machine.effect_receiver or {}
        if slots > 0 and receiver.uses_module_effects ~= false then
            for _, module in ipairs(modules) do
                local allowed = permits(machine.allowed_module_categories, module.category)
                for effect, bonus in pairs(module.effect) do
                    if bonus ~= 0 and not permits(machine.allowed_effects or {}, effect) then
                        allowed = false
                    end
                end
                if allowed then
                    -- Restored effects carry a 0.00001 offset for engine percent rounding.
                    local productivity = math.floor(module.effect.productivity * 100 + 0.000001) / 100
                    local bonus = slots * productivity + ((receiver.base_effect or {}).productivity or 0)
                    for _, category in pairs(machine.crafting_categories or {}) do
                        capacity[category] = capacity[category] or {}
                        local by_module = capacity[category]
                        by_module[module.category] = math.max(by_module[module.category] or 0, bonus)
                    end
                end
            end
        end
    end
end
for _, recipe in pairs(data.raw.recipe) do
    if recipe.allow_productivity then
        local limit = recipe.maximum_productivity or 3
        for category, bonus in pairs(capacity[recipe.category or "crafting"] or {}) do
            if permits(recipe.allowed_module_categories, category) and bonus > limit then
                -- Round up: module definitions include a small fixed-point rounding offset.
                limit = math.ceil(bonus)
            end
        end
        if limit > (recipe.maximum_productivity or 3) then
            recipe.maximum_productivity = limit
        end
    end
end
