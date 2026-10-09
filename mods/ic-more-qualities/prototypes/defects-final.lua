-- Late data-stage integration of the defect system. Runs after the defect
-- qualities are registered (data-final-fixes). Returns prototypes and log lines.
local classify = require("scripts.defects.classify")
local model = require("scripts.defects.model")
local M = {}

M.mod_data_name = "ic-defects-classification"
M.crafting_machine_types = {"assembling-machine", "furnace", "rocket-silo"}

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
                for tier = 1, 5 do dictionary["ic-defect-" .. tier] = 1 / model.multiplier(-tier) end
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

function M.apply(raw, options)
    options = options or {}
    local mode = options.mode or "materials"
    local supply = options.supply_reduction or 0
    local wire = options.wire_reduction or 0
    assert(supply >= 0 and wire >= 0, "Pole reductions must be non-negative")
    for tier = 1, 5 do assert(raw.quality["ic-defect-" .. tier], "Defect qualities must be registered first") end

    local finished, reasons = classify.classify(raw, mode)
    local white = 0
    for _, recipe in pairs(raw.recipe or {}) do
        local has_item = false
        for _, product in ipairs(classify.products(recipe)) do
            if product.type == "item" then has_item = true break end
        end
        -- Intermediates, raw materials and mixed outputs: no positive quality.
        if has_item and not classify.quality_allowed(recipe, finished) and recipe.allow_quality ~= false then
            recipe.allow_quality = false
            white = white + 1
        end
    end
    local drills = 0
    for _, drill in pairs(raw["mining-drill"] or {}) do
        drill.allowed_effects = M.without_quality(drill.allowed_effects)
        drills = drills + 1
    end
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
        "IC defects: drills without quality effect: " .. drills .. "; crafting machines with defect energy: " .. machines,
        "IC defects: pole reduction supply " .. supply .. ", wire " .. wire .. "; clamped poles: "
            .. (#clamped > 0 and table.concat(clamped, ", ") or "none"),
    }
    for _, reason in ipairs(sorted_keys(excluded)) do
        report[#report + 1] = "IC defects: excluded " .. reason .. " (" .. #excluded[reason] .. "): "
            .. table.concat(excluded[reason], ", ")
    end
    local prototypes = {{
        type = "mod-data",
        name = M.mod_data_name,
        data_type = "ic-more-qualities.defects",
        data = {mode = mode, finished = finished},
    }}
    return prototypes, report, finished, reasons
end

return M
