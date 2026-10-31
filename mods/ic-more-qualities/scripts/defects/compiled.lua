-- Prototype-derived lookup tables of the defect scheduler, built lazily from `prototypes` and the
-- data-stage classification (mod-data). Deterministic, identical on every peer; not kept in storage:
-- rebuilt after load and reset on a configuration change.
--
-- What a crafting machine can ever need:
--   * roll       - a recipe whose item products are all finished and defect-capable (a defect roll
--                  before quality control 10);
--   * defect in  - a recipe with a finished item ingredient: its recipe quality can be a defect (ruins,
--                  start items, older crafts), the result is capped or reset to standard;
--   * recycling  - a recycler: its recipe follows the inserted item, defective results become standard;
--   * normal result - a recipe of the registry "ic-normal-result": a positive result becomes standard.
-- A machine prototype whose crafting categories (or fixed recipe) contain none of these is never
-- tracked, unless a production mode is set on it.
local eligibility = require("scripts.defects.eligibility")
local classify = require("scripts.defects.classify")
local M = {}

local recipes, categories, machines = {}, {}, {}

function M.reset()
    recipes, categories, machines = {}, {}, {}
end

-- Per recipe name: {energy, recycling, any_item, all_finished, exempt, roll, defect_input, normal_result,
-- watched}.
-- watched: the recipe can ever need a decision (see the header).
local function build_recipe(prototype)
    local finished, no_defect = eligibility.finished(), eligibility.no_defect()
    local category = prototype.category
    local info = {energy = prototype.energy, category = category, recycling = classify.recycling[category] == true}
    local any_item, all_finished, exempt = false, true, false
    for _, product in pairs(prototype.products) do
        if product.type == "item" then
            any_item = true
            local name = product.name
            if not finished[name] then all_finished = false end
            if no_defect[name] then exempt = true end
        end
    end
    info.any_item, info.all_finished, info.exempt = any_item, any_item and all_finished, exempt
    info.roll = any_item and all_finished and not exempt
    local defect_input = false
    for _, ingredient in pairs(prototype.ingredients) do
        if ingredient.type == "item" and finished[ingredient.name] then
            defect_input = true
            break
        end
    end
    info.defect_input = defect_input and not info.recycling
    -- Recycling of an item that can be defective: the result must become standard (idle look minimum).
    info.watched_recycling = info.recycling and classify.watched_recycling(prototype, finished, no_defect)
    info.normal_result = any_item and not info.recycling and eligibility.normal_result()[prototype.name] == true
    info.watched = info.recycling or (any_item and (info.roll or info.defect_input or info.normal_result))
    return info
end

function M.recipe(name)
    local info = recipes[name]
    if info == nil then
        local prototype = prototypes.recipe[name]
        info = prototype and build_recipe(prototype) or false
        recipes[name] = info
    end
    return info or nil
end

-- Per crafting category: watched (any watched recipe), min_energy (fastest recipe), watched_min (fastest
-- recycling of an item that can be defective).
local function category(name)
    local info = categories[name]
    if not info then
        info = {watched = false}
        local found = prototypes.get_recipe_filtered({{filter = "category", category = name}})
        for recipe_name, prototype in pairs(found) do
            local recipe = recipes[recipe_name]
            if recipe == nil then
                recipe = build_recipe(prototype)
                recipes[recipe_name] = recipe
            end
            if recipe then
                local energy = recipe.energy
                if energy > 0 then
                    if not info.min_energy or energy < info.min_energy then info.min_energy = energy end
                    if recipe.watched_recycling and (not info.watched_min or energy < info.watched_min) then
                        info.watched_min = energy
                    end
                end
                if recipe.watched then info.watched = true end
            end
        end
        categories[name] = info
    end
    return info
end

-- Per machine prototype name: {relevant, recycler, min_energy, watched_min, emissions}.
-- name: optional, the entity name if already known (no API read on a cache hit).
function M.machine(entity, name)
    name = name or entity.name
    local info = machines[name]
    if not info then
        local prototype = entity.prototype
        info = {relevant = false, recycler = false}
        for category_name in pairs(prototype.crafting_categories or {}) do
            local data = category(category_name)
            if classify.recycling[category_name] then info.recycler = true end
            if data.watched then info.relevant = true end
            if data.min_energy and (not info.min_energy or data.min_energy < info.min_energy) then
                info.min_energy = data.min_energy
            end
            if data.watched_min and (not info.watched_min or data.watched_min < info.watched_min) then
                info.watched_min = data.watched_min
            end
        end
        local kind = prototype.type
        local fixed = (kind == "assembling-machine" or kind == "rocket-silo") and prototype.fixed_recipe
        if fixed then
            local recipe = M.recipe(fixed)
            info.relevant = recipe ~= nil and recipe.watched
            info.min_energy = recipe and recipe.energy > 0 and recipe.energy or info.min_energy
        end
        local source = prototype.electric_energy_source_prototype or prototype.burner_prototype
        info.emissions = source and source.emissions_per_joule or nil
        machines[name] = info
    end
    return info
end

-- Names of every relevant crafting machine prototype (for the surface search at a configuration change).
function M.relevant_names(types)
    local list = {}
    for name, prototype in pairs(prototypes.get_entity_filtered(types)) do
        local info = machines[name]
        if not info then
            -- Same as M.machine without an entity.
            info = M.machine({prototype = prototype}, name)
        end
        if info.relevant then list[#list + 1] = name end
    end
    table.sort(list)
    return list
end

return M
