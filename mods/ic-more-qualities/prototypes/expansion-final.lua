-- Quality-control expansion, data-final-fixes. Runs after defects-final.lua: the classification of
-- finished products and the white intermediate recipes already exist, every item is defined.
-- Builds: machine statistics from assembling machine 1, the refinement recipe of every finished product
-- with its cost (science kinds x health), repair packs as the workshop's resource, unlocks in quality
-- control 1, the hidden power interfaces of production modes and the runtime mod-data.
local names = require("scripts.expansion.names")
local rules = require("scripts.expansion.rules")
local model = require("scripts.defects.model")
local classify = require("scripts.defects.classify")
local shared = require("prototypes.expansion-shared")

local M = {}
local RAW -- data.raw being processed (passed to apply)

local function find_item(name)
    for type_name in pairs(defines.prototypes.item) do
        local prototypes = RAW[type_name]
        if prototypes and prototypes[name] then return prototypes[name] end
    end
end

local entity_cache = {}
local function find_entity(name)
    local cached = entity_cache[name]
    if cached ~= nil then return cached or nil end
    for type_name in pairs(defines.prototypes.entity) do
        local prototypes = RAW[type_name]
        if prototypes and prototypes[name] then
            entity_cache[name] = prototypes[name]
            return prototypes[name]
        end
    end
    entity_cache[name] = false
end

-- Workshop and post copy the (possibly rebalanced) assembling machine 1 of the modpack.
local function copy_stats(target, source, keys)
    if not (target and source) then return end
    for _, key in ipairs(keys) do
        if source[key] ~= nil then target[key] = table.deepcopy(source[key]) end
    end
end

local function finish_machines(raw)
    local workshop = raw.furnace[names.workshop]
    local post = raw.container[names.post]
    local am1 = raw["assembling-machine"]["assembling-machine-1"]
    local common = {"max_health", "resistances", "corpse", "dying_explosion", "damaged_trigger_effect",
        "open_sound", "close_sound", "impact_category", "repair_sound", "mined_sound"}
    copy_stats(workshop, am1, common)
    copy_stats(post, am1, common)
    copy_stats(workshop, am1, {"working_sound", "energy_usage"})
    if am1 and am1.energy_source and am1.energy_source.emissions_per_minute then
        workshop.energy_source.emissions_per_minute = table.deepcopy(am1.energy_source.emissions_per_minute)
    end
    -- Positive qualities speed up the workshop at most x4: every attempt stays several ticks long,
    -- so the script can decide each outcome before the machine completes it.
    local speeds = {}
    for name, quality in pairs(raw.quality) do
        if not model.is_defect(name) then
            local speed = quality.crafting_machine_speed_multiplier or quality.default_multiplier
                or (1 + 0.3 * (quality.level or 0))
            if speed > rules.MAX_SPEED then speeds[name] = rules.MAX_SPEED end
        end
    end
    if next(speeds) then workshop.crafting_speed_quality_multiplier = speeds end

    local am1_item = find_item("assembling-machine-1")
    if am1_item and am1_item.subgroup then
        for index, name in ipairs({names.workshop, names.post}) do
            local item = raw.item[name]
            item.subgroup = am1_item.subgroup
            item.order = (am1_item.order or "") .. "-z[ic]-" .. index
        end
    end

    local circuit = find_item("bob-basic-circuit-board") and "bob-basic-circuit-board" or "electronic-circuit"
    local function ingredients(list)
        local result = {}
        for _, entry in ipairs(list) do
            if find_item(entry[1]) then
                result[#result + 1] = {type = "item", name = entry[1], amount = entry[2]}
            end
        end
        if #result == 0 then result[1] = {type = "item", name = "iron-plate", amount = 20} end
        return result
    end
    -- Paranoidal: built from the burner assembling machine and opened together with it.
    local machine = find_item("burner-assembling-machine") and "burner-assembling-machine" or "assembling-machine-1"
    raw.recipe[names.workshop].ingredients = ingredients({
        {machine, 1}, {"repair-pack", 10}, {circuit, 5}})
    raw.recipe[names.post].ingredients = ingredients({
        {machine, 1}, {"inserter", 3}, {circuit, 5}})

    -- Burner mechanics (AAI); without it the first quality-control research (no prerequisites).
    local technology = raw.technology["burner-mechanics"] or raw.technology[model.research(1).name]
    if technology then
        technology.effects = technology.effects or {}
        table.insert(technology.effects, 1, {type = "unlock-recipe", recipe = names.post})
        table.insert(technology.effects, 1, {type = "unlock-recipe", recipe = names.workshop})
    else
        raw.recipe[names.workshop].enabled = true
        raw.recipe[names.post].enabled = true
    end

    -- Quality built their recycling in data-updates from the placeholder recipes: rebuild it now.
    if mods and mods["quality"] and data and raw == data.raw then
        local recycling = require("__quality__.prototypes.recycling")
        for _, name in ipairs({names.workshop, names.post}) do
            local key = name .. "-recycling"
            if raw.recipe[key] then
                local old = raw.recipe[key]
                raw.recipe[key] = nil
                recycling.generate_recycling_recipe(raw.recipe[name])
                if not raw.recipe[key] then raw.recipe[key] = old end
            end
        end
    end
end

-- Repair packs store their resource in the workshop's burner slots. Their fuel value is only shown
-- in tooltips: the workshop drains durability by script and nothing else accepts this category.
local function repair_resource(raw)
    for _, tool in pairs(raw["repair-tool"] or {}) do
        if tool.durability and (tool.fuel_category == nil or tool.fuel_category == "") then
            tool.fuel_category = names.repair_fuel
            tool.fuel_value = tostring(tool.durability) .. "kJ"
        end
    end
end

-- Earliest research of every item: number of science pack kinds (0 = available from the start).
local function science_kinds(raw)
    local by_recipe = {}
    for _, technology in pairs(raw.technology) do
        if technology.hidden ~= true and technology.enabled ~= false then
            local unit = technology.unit
            local kinds = unit and unit.ingredients and #unit.ingredients or 0
            for _, effect in pairs(technology.effects or {}) do
                local recipe = effect.type == "unlock-recipe" and effect.recipe
                if recipe and (by_recipe[recipe] == nil or kinds < by_recipe[recipe]) then by_recipe[recipe] = kinds end
            end
        end
    end
    local by_item = {}
    for name, recipe in pairs(raw.recipe) do
        local category = recipe.category or "crafting"
        if recipe.hidden ~= true and category ~= names.refine_category and not category:find("recycling", 1, true) then
            local kinds = 0
            if recipe.enabled == false then kinds = by_recipe[name] end
            if kinds then
                for _, product in ipairs(classify.products(recipe)) do
                    if product.type == "item" and (by_item[product.name] == nil or kinds < by_item[product.name]) then
                        by_item[product.name] = kinds
                    end
                end
            end
        end
    end
    return by_item
end

-- Finished products only (user decision 2026-10-29): materials are never defective, so their recipes only
-- served the optional reset of positive quality (1170 of 2901 recipes in Paranoidal).
local function refinement(raw, finished)
    local kinds_of = science_kinds(raw)
    local costs, recipes, count = {}, {}, 0
    for type_name in pairs(defines.prototypes.item) do
        if not names.not_refinable_types[type_name] then
            for name, item in pairs(raw[type_name] or {}) do
                local recipe_name = names.refine_recipe_prefix .. name
                if finished[name] and not item.parameter and not item.hidden and name ~= names.drive and #recipe_name <= 200
                    and not item.equipment_grid and not raw.recipe[recipe_name] then
                    local entity = item.place_result and find_entity(item.place_result)
                    local health = entity and entity.max_health or nil
                    local kinds = kinds_of[name]
                    local cost, seconds = rules.attempt(kinds, health)
                    costs[name] = {cost = cost, seconds = seconds, kinds = kinds, health = health}
                    recipes[#recipes + 1] = {
                        type = "recipe",
                        name = recipe_name,
                        category = names.refine_category,
                        enabled = true,
                        hidden = true,
                        hidden_in_factoriopedia = true,
                        hide_from_stats = true,
                        hide_from_player_crafting = true,
                        hide_from_signal_gui = true,
                        hide_from_bonus_gui = true,
                        unlock_results = false,
                        allow_decomposition = false,
                        allow_as_intermediate = false,
                        allow_intermediates = false,
                        allow_productivity = false,
                        allow_quality = true,
                        auto_recycle = false,
                        energy_required = seconds,
                        ingredients = {{type = "item", name = name, amount = 1}},
                        results = {{type = "item", name = name, amount = 1}},
                        main_product = name,
                    }
                    count = count + 1
                end
            end
        end
    end
    return costs, recipes, count
end

-- One hidden interface per machine footprint (and its rotated variant) for the extra power of
-- careful/precise modes. Only electric assemblers and furnaces can draw it.
local function mode_power(raw)
    local sizes, list = {}, {}
    for _, kind in ipairs({"assembling-machine", "furnace"}) do
        for name, machine in pairs(raw[kind] or {}) do
            local source = machine.energy_source
            if name ~= names.workshop and source and source.type == "electric" and machine.collision_box then
                local w, h = shared.box_tiles(machine.collision_box)
                for _, size in ipairs({{w, h}, {h, w}}) do
                    local key = size[1] .. "x" .. size[2]
                    if not sizes[key] then
                        sizes[key] = true
                        local power = shared.hidden_power(names.mode_power_prefix .. key, size[1], size[2])
                        power.localised_name = {"entity-name.ic-mode-power"}
                        list[#list + 1] = power
                    end
                end
            end
        end
    end
    return list
end

-- Machines without production modes (no mode panel, no saved mode). A mode changes only item
-- results (defects, quality-module boost), so it is withheld from machines that can
-- never produce an item: no recipe at all (copper lamp of LargerLamps: fixed recipe without results),
-- fluid-only recipes, voiding (Angels flare stack/clarifier: void item with probability 0). Plus, by name
-- (user decisions 2026-10-15): construction sites driven by another mod's script (Rocket Silo
-- Construction stages), carbon-capture air filters (one way of working only) and the telescopes of
-- Expanded Rocket Payloads (reached long after quality control 10: no defects left to handle).
M.no_mode_patterns = {
    "^rsc%-silo%-stage%d+$",
    "^CW%-air%-filter%-machine%-%d+$",
    "^ground%-telescope$",
    "^space%-telescope%-uplink%-station$",
}

local function yields_item(recipe)
    for _, result in ipairs(recipe.results or {}) do
        if (result.type or "item") == "item" and (result.amount or result.amount_max or 0) > 0
            and (result.probability == nil or result.probability > 0) then
            return true
        end
    end
    return false
end

function M.no_mode_machines(raw)
    local categories = {}
    for name, recipe in pairs(raw.recipe or {}) do
        if yields_item(recipe) then
            categories[recipe.category or "crafting"] = true
            for _, category in ipairs(recipe.additional_categories or {}) do categories[category] = true end
        end
    end
    local result, list = {}, {}
    for _, kind in ipairs({"assembling-machine", "furnace"}) do
        for name, machine in pairs(raw[kind] or {}) do
            local excluded = false
            for _, pattern in ipairs(M.no_mode_patterns) do
                if name:find(pattern) then excluded = true end
            end
            if not excluded then
                local fixed = machine.fixed_recipe and raw.recipe[machine.fixed_recipe]
                if machine.fixed_recipe then
                    excluded = not (fixed and yields_item(fixed))
                else
                    excluded = true
                    for _, category in ipairs(machine.crafting_categories or {}) do
                        if categories[category] then excluded = false end
                    end
                end
            end
            if excluded and name ~= names.workshop then
                result[name] = true
                list[#list + 1] = name
            end
        end
    end
    table.sort(list)
    return result, list
end

function M.apply(raw, finished, reasons)
    RAW = raw
    entity_cache = {}
    finish_machines(raw)
    repair_resource(raw)
    local costs, recipes, count = refinement(raw, finished or {})
    local prototypes = recipes
    for _, power in ipairs(mode_power(raw)) do prototypes[#prototypes + 1] = power end
    local no_quality = {}
    for name, recipe in pairs(raw.recipe) do
        if recipe.allow_quality == false then no_quality[name] = true end
    end
    local finished_count = 0
    for _ in pairs(finished or {}) do finished_count = finished_count + 1 end
    local no_mode, no_mode_list = M.no_mode_machines(raw)
    prototypes[#prototypes + 1] = {
        type = "mod-data",
        name = names.mod_data,
        data_type = "ic-more-qualities.expansion",
        data = {costs = costs, reasons = reasons or {}, no_quality = no_quality, finished_count = finished_count,
            no_mode = no_mode},
    }
    return prototypes, {"IC expansion: refinement recipes " .. count .. ", repair resource and production modes ready",
        "IC expansion: machines without production modes (no item results / by name): " .. #no_mode_list
            .. (#no_mode_list > 0 and (": " .. table.concat(no_mode_list, ", ")) or "")}
end

return M
