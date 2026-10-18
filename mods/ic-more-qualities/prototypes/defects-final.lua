-- Late data-stage integration of the defect system. Runs after the defect
-- qualities are registered (data-final-fixes). Returns prototypes and log lines.
local classify = require("scripts.defects.classify")
local model = require("scripts.defects.model")
local M = {}

M.mod_data_name = "ic-defects-classification"
M.crafting_machine_types = {"assembling-machine", "furnace", "rocket-silo"}

-- Paranoidal (user decision 2026-10-14): upgrade chains whose recipes take only finished products
-- never get defects; the hazmat suit (user decision 2026-10-15) neither. Absent names are skipped.
M.exempt_items = {"memory-unit", "fluid-memory-unit", "memory-unit-with-tags", "fluid-memory-unit-with-tags",
    "vehicle-fuel-cell-2-equipment", "vehicle-fuel-cell-3-equipment", "vehicle-fuel-cell-4-equipment", "hazmat-suit",
    -- Flow Control restricted pipes (user decision 2026-10-18): made 1:1 from a plain pipe, always standard.
    "pipe-straight", "pipe-elbow", "pipe-junction"}
for _, tank in ipairs({"L", "M", "H", "SH", "F"}) do
    for _, suffix in ipairs({"", "-mk1", "-mk2"}) do
        M.exempt_items[#M.exempt_items + 1] = "Schall-tank-" .. tank .. suffix
    end
end
for tier = 1, 3 do
    M.exempt_items[#M.exempt_items + 1] = "bet-charger-" .. tier
    M.exempt_items[#M.exempt_items + 1] = "bet-charger-tertiary-" .. tier
end
-- Factorissimo factory buildings are immune to defects and quality (user decision 2026-10-15); the factory
-- recipes forbid quality themselves (allow_quality = false in Factorissimo).
for tier = 1, 3 do
    for _, prefix in ipairs({"factory-", "space-factory-"}) do
        M.exempt_items[#M.exempt_items + 1] = prefix .. tier
        M.exempt_items[#M.exempt_items + 1] = prefix .. tier .. "-instantiated"
    end
end

-- Groups where defects have no effect or make no sense (user decisions 2026-10-18), always standard.
-- A finished item is exempt when its place_result has one of `entity_types`, its item type is one of
-- `item_types`, it places equipment (`equipment`), or it is listed in `items`. Large storage tanks, lamps,
-- pumps, radars, boilers, generators, solar panels, burner generators and walls keep defects.
M.exempt_groups = {
    {name = "valves and small fluid tanks", entity_types = {"valve"},
        items = {"angels-valve-inspector", "bob-small-inline-storage-tank", "bob-small-storage-tank"}},
    {name = "fluid level indicators", items = {"fluid-level-indicator", "fluid-level-indicator-straight"}},
    {name = "circuit logic", entity_types = {"constant-combinator", "arithmetic-combinator", "decider-combinator",
        "selector-combinator", "power-switch", "programmable-speaker", "display-panel"}},
    {name = "rail signals, stops, supports", entity_types = {"rail-signal", "rail-chain-signal", "train-stop",
        "rail-support"}},
    {name = "heat pipes", entity_types = {"heat-pipe"}},
    {name = "beacons", entity_types = {"beacon"}},
    {name = "mines", entity_types = {"land-mine"}},
    {name = "cliff explosives, artillery remote", items = {"cliff-explosives", "artillery-targeting-remote"}},
    {name = "debug", entity_types = {"infinity-container", "infinity-pipe", "infinity-cargo-wagon", "heat-interface"},
        items = {"electric-energy-interface"}},
    {name = "modules", item_types = {"module"}},
    {name = "equipment", equipment = true},
    {name = "reactors", entity_types = {"reactor"}},
    {name = "wind turbines", items = {"texugo-wind-turbine", "texugo-wind-turbine2", "texugo-wind-turbine3",
        "wind-turbine-2"}},
    {name = "vehicles", entity_types = {"car", "locomotive", "spider-vehicle"}},
    {name = "roboports", entity_types = {"roboport"}},
}

local function group_matches(raw, group, kind, name, item)
    for _, listed in ipairs(group.items or {}) do
        if listed == name then return true end
    end
    for _, item_type in ipairs(group.item_types or {}) do
        if item_type == kind then return true end
    end
    if group.equipment and item.place_as_equipment_result then return true end
    local result = item.place_result
    if result then
        for _, entity_type in ipairs(group.entity_types or {}) do
            if raw[entity_type] and raw[entity_type][result] then return true end
        end
    end
    return false
end

local function defect_tier(name)
    local tier = type(name) == "string" and name:match("^ic%-defect%-([1-5])$")
    return tier and tonumber(tier)
end

local function sorted_keys(map)
    local list = {}
    for key in pairs(map) do list[#list + 1] = key end
    table.sort(list)
    return list
end

-- Drills must not create positive-quality ores (intermediates/raw stay white).
-- Productivity, speed, efficiency and pollution modules remain allowed.
function M.without_quality(effects)
    if effects == nil then return {"speed", "productivity", "consumption", "pollution"} end
    if type(effects) == "string" then return effects == "quality" and {} or {effects} end
    local result = {}
    for _, effect in pairs(effects) do
        if effect ~= "quality" then result[#result + 1] = effect end
    end
    return result
end

-- "Quality everywhere" mode: modules with quality fit every crafting machine and drill with slots.
function M.with_quality(machine, drill)
    if (machine.module_slots or 0) <= 0 then return false end
    local effects = machine.allowed_effects
    if effects == nil then
        if drill then return false end -- drills: nil allows every effect
        effects = {}
    elseif type(effects) == "string" then
        effects = {effects}
    end
    for _, effect in pairs(effects) do
        if effect == "quality" then return false end
    end
    local list = {}
    for _, effect in pairs(effects) do list[#list + 1] = effect end
    list[#list + 1] = "quality"
    machine.allowed_effects = list
    local categories = machine.allowed_module_categories
    if type(categories) == "table" then
        local found = false
        for _, category in pairs(categories) do if category == "quality" then found = true end end
        if not found then categories[#categories + 1] = "quality" end
    end
    return true
end

-- Defect penalty: 1/m energy (and pollution) for every crafting machine.
-- Machines that previously ignored quality keep exactly 1 for all other qualities.
function M.machine_energy(raw)
    local changed = 0
    for _, kind in ipairs(M.crafting_machine_types) do
        for _, machine in pairs(raw[kind] or {}) do
            local dictionary = machine.energy_usage_quality_multiplier
            if not machine.quality_affects_energy_usage then
                machine.quality_affects_energy_usage = true
                dictionary = {}
                for name in pairs(raw.quality) do
                    if not defect_tier(name) then dictionary[name] = 1 end
                end
            end
            if dictionary then
                -- A defect factor declared by the owner is kept (Bio gardens: a defect absorbs less, not more).
                for tier = 1, 5 do
                    local key = "ic-defect-" .. tier
                    if dictionary[key] == nil then dictionary[key] = 1 / model.multiplier(-tier) end
                end
                machine.energy_usage_quality_multiplier = dictionary
            end
            changed = changed + 1
        end
    end
    return changed
end

-- Uniform reduction in tiles. Quality bonuses must be >= 0 and cannot be
-- disabled per pole, so all base radii shrink by D and standard/positive
-- qualities receive +D. Poles with base < D are clamped and reported.
function M.poles(raw, supply, wire)
    local clamped = {}
    for name, pole in pairs(raw["electric-pole"] or {}) do
        local base_supply = pole.supply_area_distance or 0
        local base_wire = pole.maximum_wire_distance or 0
        if base_supply < supply or base_wire < wire then
            clamped[#clamped + 1] = name .. " (supply " .. base_supply .. ", wire " .. base_wire .. ")"
        end
        pole.supply_area_distance = math.max(0, base_supply - supply)
        pole.maximum_wire_distance = math.max(0, base_wire - wire)
    end
    for name, quality in pairs(raw.quality) do
        local tier = defect_tier(name)
        if tier then
            quality.electric_pole_supply_area_distance_bonus = supply * (5 - tier) / 5
            quality.electric_pole_wire_reach_bonus = wire * (5 - tier) / 5
        else
            local level = quality.level or 0
            quality.electric_pole_supply_area_distance_bonus = (quality.electric_pole_supply_area_distance_bonus or level) + supply
            quality.electric_pole_wire_reach_bonus = (quality.electric_pole_wire_reach_bonus or 2 * level) + wire
        end
    end
    table.sort(clamped)
    return clamped
end

-- Positive-quality rules shared by the game with and without defects. everywhere off: recipes of
-- intermediates, raw materials and mixed outputs get no positive quality, drills take no quality
-- modules; on: quality modules fit every crafting machine and drill with slots.
-- Returns the counts of white recipes, changed drills and opened machines.
function M.positive_quality(raw, finished, everywhere)
    local white = 0
    for _, recipe in pairs(raw.recipe or {}) do
        local has_item = false
        for _, product in ipairs(classify.products(recipe)) do
            if product.type == "item" then has_item = true break end
        end
        -- Recycling keeps native quality: results at least the input quality, modules may raise it.
        if has_item and not everywhere and not classify.recycling[recipe.category or "crafting"]
            and not classify.quality_allowed(recipe, finished) and recipe.allow_quality ~= false then
            recipe.allow_quality = false
            white = white + 1
        end
    end
    local drills = 0
    for _, drill in pairs(raw["mining-drill"] or {}) do
        if everywhere then
            if M.with_quality(drill, true) then drills = drills + 1 end
        else
            drill.allowed_effects = M.without_quality(drill.allowed_effects)
            drills = drills + 1
        end
    end
    local opened = 0
    if everywhere then
        for _, kind in ipairs({"assembling-machine", "furnace"}) do
            for _, machine in pairs(raw[kind] or {}) do
                if M.with_quality(machine, false) then opened = opened + 1 end
            end
        end
    end
    return white, drills, opened
end

-- Quality without defects: only the positive-quality rules. Returns log lines.
function M.quality_rules(raw, finished, everywhere)
    local white, drills, opened = M.positive_quality(raw, finished, everywhere)
    return {"IC quality without defects: recipes forced white " .. white .. ", quality everywhere "
        .. tostring(everywhere == true) .. ", machines opened for quality " .. opened .. "; drills changed: " .. drills}
end

function M.apply(raw, options)
    options = options or {}
    local mode = options.mode or "materials"
    local supply = options.supply_reduction or 0
    local wire = options.wire_reduction or 0
    assert(supply >= 0 and wire >= 0, "Pole reductions must be non-negative")
    for tier = 1, 5 do assert(raw.quality["ic-defect-" .. tier], "Defect qualities must be registered first") end

    local finished, reasons = classify.classify(raw, mode)
    local white, drills, opened = M.positive_quality(raw, finished, options.everywhere)
    local machines = M.machine_energy(raw)
    local clamped = M.poles(raw, supply, wire)

    local finished_count, excluded = 0, {}
    for _ in pairs(finished) do finished_count = finished_count + 1 end
    for _, name in ipairs(sorted_keys(reasons)) do
        local reason = reasons[name]
        if reason ~= "raw" and reason ~= "parameter" then
            excluded[reason] = excluded[reason] or {}
            table.insert(excluded[reason], name)
        end
    end
    local report = {
        "IC defects: mode " .. mode .. ", finished products with defects: " .. finished_count,
        "IC defects: recipes forced white (allow_quality=false): " .. white,
        "IC defects: quality everywhere " .. tostring(options.everywhere == true) .. ", machines opened for quality " .. opened
            .. "; drills changed: " .. drills .. "; crafting machines with defect energy: " .. machines,
        "IC defects: pole reduction supply " .. supply .. ", wire " .. wire .. "; clamped poles: "
            .. (#clamped > 0 and table.concat(clamped, ", ") or "none"),
    }
    for _, reason in ipairs(sorted_keys(excluded)) do
        report[#report + 1] = "IC defects: excluded " .. reason .. " (" .. #excluded[reason] .. "): "
            .. table.concat(excluded[reason], ", ")
    end
    -- Weapons, ammo and turrets get no defects unless the "defects for weapons" setting is on.
    local no_defect, exempt = {}, 0
    if not options.weapons then
        local turrets = {["ammo-turret"] = true, ["electric-turret"] = true, ["fluid-turret"] = true,
            ["artillery-turret"] = true, turret = true, ["artillery-wagon"] = true}
        local placed = {}
        for kind in pairs(turrets) do
            for name in pairs(raw[kind] or {}) do placed[name] = true end
        end
        for _, kind in ipairs({"gun", "ammo", "item", "item-with-entity-data"}) do
            for name, item in pairs(raw[kind] or {}) do
                if finished[name] and (kind == "gun" or kind == "ammo" or placed[item.place_result or ""]) then
                    no_defect[name] = true
                    exempt = exempt + 1
                end
            end
        end
    end
    report[#report + 1] = "IC defects: weapons/ammo/turrets without defects: " .. exempt
    -- Paranoidal: belt logistics (belts, underground belts, splitters, loaders, including the
    -- zzzparanoidal loader shells) never get defects; positive quality from modules is kept.
    local belt_types = {"transport-belt", "underground-belt", "splitter", "lane-splitter", "linked-belt",
        "loader", "loader-1x1"}
    local belts = {}
    for _, kind in ipairs(belt_types) do
        for name in pairs(raw[kind] or {}) do belts[name] = true end
    end
    local belt_items = 0
    for _, kind in ipairs({"item", "item-with-entity-data"}) do
        for name, item in pairs(raw[kind] or {}) do
            local result = item.place_result or ""
            if finished[name] and not no_defect[name]
                and (belts[result] or result:find("loader%-shell", 1) ~= nil) then
                no_defect[name] = true
                belt_items = belt_items + 1
            end
        end
    end
    report[#report + 1] = "IC defects: belts/undergrounds/splitters/loaders without defects: " .. belt_items
    local chain_items = 0
    for _, name in ipairs(M.exempt_items) do
        if finished[name] and not no_defect[name] then
            no_defect[name] = true
            chain_items = chain_items + 1
        end
    end
    report[#report + 1] = "IC defects: Paranoidal upgrade chains without defects (tanks, fuel cells, chargers, memory units, hazmat suit, factory buildings, Flow Control pipes): "
        .. chain_items
    local group_counts = {}
    for _, kind in ipairs(classify.item_types) do
        for name, item in pairs(raw[kind] or {}) do
            if finished[name] and not no_defect[name] then
                for index, group in ipairs(M.exempt_groups) do
                    if group_matches(raw, group, kind, name, item) then
                        no_defect[name] = true
                        group_counts[index] = (group_counts[index] or 0) + 1
                        break
                    end
                end
            end
        end
    end
    local group_total, group_parts = 0, {}
    for index, group in ipairs(M.exempt_groups) do
        group_total = group_total + (group_counts[index] or 0)
        group_parts[#group_parts + 1] = group.name .. " " .. (group_counts[index] or 0)
    end
    report[#report + 1] = "IC defects: groups without defects (" .. group_total .. "): " .. table.concat(group_parts, ", ")
    local prototypes = {{
        type = "mod-data",
        name = M.mod_data_name,
        data_type = "ic-more-qualities.defects",
        data = {mode = mode, finished = finished, no_defect = no_defect},
    }}
    return prototypes, report, finished, reasons
end

return M
