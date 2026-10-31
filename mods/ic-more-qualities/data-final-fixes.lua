local switches = require("scripts.switches")
-- Quality switched off: the mod adds nothing; zzzparanoidal hides quality modules and their research.
if not switches.quality() then return end

require("prototypes.utils")
require("prototypes.remove-tech-final")

-- Registry "ic-quality-closed": drop unknown names.
do
    local registry = data.raw["mod-data"][require("scripts.expansion.names").quality_closed]
    local closed = {}
    for name in pairs(registry.data.machines) do
        if data.raw["assembling-machine"][name] or data.raw["furnace"][name] then
            closed[#closed + 1] = name
        else
            registry.data.machines[name] = nil
        end
    end
    table.sort(closed)
    log("IC: machines without quality modules (" .. #closed .. "): " .. table.concat(closed, ", "))
end

-- zzzparanoidal hides modules outside its Beta 8 set: quality modules stay visible with quality,
-- with or without defects.
if mods["zzzparanoidal"] then
    require("prototypes.defects-quality-modules")(data.raw)
end

if not switches.defects() then
    -- Quality without defects: the same positive-quality rules as with defects ("quality for all
    -- production" off: raw resources and intermediates stay standard, drills without quality).
    local startup = settings.startup
    local classify = require("scripts.defects.classify")
    local finished = classify.classify(data.raw, startup["ic-more-qualities-defects-ingredient-mode"].value)
    local report = require("prototypes.defects-final").quality_rules(data.raw, finished,
        startup["ic-more-qualities-quality-everywhere"].value)
    for _, line in ipairs(report) do log(line) end
end

if switches.defects() then
    data:extend(require("prototypes.defects-preview").prepare(data.raw))
    -- research_evolution_factor labels technologies in its data-final-fixes, which runs before this
    -- mod creates the quality-control researches: add the same "evolution +X%" effect here.
    -- zzzparanoidal also runs earlier, so its evolution icon must be assigned here.
    if mods["research_evolution_factor"] then
        local ok, labels = pcall(require, "__research_evolution_factor__/evolution-label")
        if ok then
            for level = 1, 10 do
                local tech = data.raw.technology["ic-defect-control-" .. level]
                if tech then
                    labels.relabel(tech, {
                        icon = mods["zzzparanoidal"] and "__zzzparanoidal__/graphics/research-evolution-icon.png" or nil,
                        icon_size = 64,
                        use_icon_overlay_constant = false,
                    })
                end
            end
        end
    end
    local startup = settings.startup
    local prototypes, report, finished, reasons, no_defect = require("prototypes.defects-final").apply(data.raw, {
        mode = startup["ic-more-qualities-defects-ingredient-mode"].value,
        supply_reduction = startup["ic-more-qualities-defects-pole-supply-reduction"].value,
        wire_reduction = startup["ic-more-qualities-defects-pole-wire-reduction"].value,
        everywhere = startup["ic-more-qualities-quality-everywhere"].value,
        weapons = startup["ic-more-qualities-defects-weapons"].value,
    })
    data:extend(prototypes)
    for _, line in ipairs(report) do log(line) end

    -- Defective drills mine slower at runtime (scripts/defects/drill.lua); the tooltip shows only the
    -- prototype speed, so every placeable drill/pumpjack gets a short line that defects are less effective.
    local speed_line = {"ic-defects.drill-speed"}
    local function with_line(existing, key)
        if existing then return {"", existing, "\n", speed_line} end
        return {"?", {"", {key}, "\n", speed_line}, speed_line}
    end
    local drill_items = {}
    for _, kind in ipairs({"item", "item-with-entity-data"}) do
        for _, item in pairs(data.raw[kind] or {}) do
            -- Drills that never get defects (made only after green science) need no defect line or field.
            if item.place_result and data.raw["mining-drill"][item.place_result] and not no_defect[item.name] then
                drill_items[#drill_items + 1] = item
            end
        end
    end
    -- Resource drain with defects (x2...x6, drained by scripts/defects/drill.lua): the engine line shows
    -- only the prototype rate times QualityPrototype::mining_drill_resource_drain_multiplier (<= 1), so
    -- every placeable drill/pumpjack gets a field with the actual percent per quality. Item: Factoriopedia
    -- only; entity: tooltips only. The item tooltip already shows the fields of its place_result, so an
    -- item copy in tooltips printed the line twice (as zzzparanoidal loaders).
    local model = require("scripts.defects.model")
    local function drain_text(percent, quality)
        local value = percent * (quality.mining_drill_resource_drain_multiplier or 1)
            * model.quality_drain_multiplier(quality.name)
        return string.format("%.4g", value) .. "%"
    end
    local function drain_field(drill, factoriopedia)
        -- factoriopedia: the item copy (Factoriopedia only); otherwise the entity copy (tooltips only)
        local percent = drill.resource_drain_rate_percent or 100
        local values = {}
        for name, quality in pairs(data.raw.quality) do
            if not quality.hidden then values[name] = drain_text(percent, quality) end
        end
        return {
            name = {"ic-defects.drill-drain"},
            value = values.normal or drain_text(percent, {name = "normal"}),
            quality_header = "ic-defects.drill-drain-quality",
            quality_values = values,
            show_in_factoriopedia = factoriopedia,
            show_in_tooltip = not factoriopedia,
        }
    end
    local function add_field(prototype, field)
        prototype.custom_tooltip_fields = prototype.custom_tooltip_fields or {}
        table.insert(prototype.custom_tooltip_fields, field)
    end
    local described = 0
    for _, item in ipairs(drill_items) do
        local drill = data.raw["mining-drill"][item.place_result]
        if not drill.ic_defects_described then
            drill.localised_description = with_line(drill.localised_description, "entity-description." .. drill.name)
            add_field(drill, drain_field(drill, false))
            drill.ic_defects_described = true
        end
        add_field(item, drain_field(drill, true))
        item.localised_description = item.localised_description and with_line(item.localised_description)
            or {"?", {"", {"item-description." .. item.name}, "\n", speed_line},
                {"", {"entity-description." .. drill.name}, "\n", speed_line}, speed_line}
        described = described + 1
    end
    for _, drill in pairs(data.raw["mining-drill"]) do drill.ic_defects_described = nil end
    log("IC defects: drill items with the defect speed line and drain field: " .. described)

    -- Recipes whose result is always normal (registry of data.lua): unknown names are dropped, quality modules
    -- never roll on them (allow_quality = false), so a craft at normal quality stays normal without a look.
    -- Before expansion-final, which lists recipes without quality for the production modes.
    local registry = data.raw["mod-data"][require("scripts.expansion.names").normal_result]
    local normal_result = {}
    for name in pairs(registry.data.recipes) do
        local recipe = data.raw.recipe[name]
        if recipe then
            recipe.allow_quality = false
            normal_result[#normal_result + 1] = name
        else
            registry.data.recipes[name] = nil
        end
    end
    table.sort(normal_result)
    log("IC: recipes whose result is always normal (" .. #normal_result .. "): " .. table.concat(normal_result, ", "))

    -- Workshop, control post and production modes: after the classification above, so that the
    -- refinement recipes keep allow_quality and every item already exists.
    local expansion, expansion_report = require("prototypes.expansion-final").apply(data.raw, finished, reasons)
    data:extend(expansion)
    for _, line in ipairs(expansion_report) do log(line) end
end

-- Paranoidal: all qualities are unlocked at the start by control.lua, so researches no longer list
-- quality unlocks. A research left with only note effects (e.g. the evolution note) is hidden.
for _, technology in pairs(data.raw.technology) do
    local effects, removed = technology.effects, false
    for index = #(effects or {}), 1, -1 do
        if effects[index].type == "unlock-quality" then
            table.remove(effects, index)
            removed = true
        end
    end
    if removed then
        local useful = false
        for _, effect in pairs(effects) do
            if effect.type ~= "nothing" then useful = true end
        end
        if not useful then
            technology.hidden = true
            technology.enabled = false
        end
    end
end
