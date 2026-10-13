require("prototypes.utils")
require("prototypes.remove-tech-final")

local conf_early_quality = settings.startup["ic-more-qualities-early-quality"].value

if conf_early_quality then
    require("prototypes.early-quality-final")
end

if settings.startup["ic-more-qualities-defects-preview"].value then
    data:extend(require("prototypes.defects-preview").prepare(data.raw))
    -- research_evolution_factor labels technologies in its data-final-fixes, which runs before this
    -- mod creates the quality-control researches: add the same "evolution +X%" effect here.
    if mods["research_evolution_factor"] then
        local ok, params = pcall(require, "__research_evolution_factor__.parameters")
        if not ok then params = {science_packet_cost = {}, constant_factor = 0.15, linear_factor = 0.35} end
        for level = 1, 10 do
            local tech = data.raw.technology["ic-defect-control-" .. level]
            if tech and tech.unit and tech.unit.count and not tech.hidden then
                local sum = 0
                for _, ingredient in pairs(tech.unit.ingredients or {}) do
                    local name = ingredient.name or ingredient[1]
                    local amount = ingredient.amount or ingredient[2] or 0
                    sum = sum + amount * (params.science_packet_cost[name] or 1)
                end
                local inc = tech.unit.count * sum * 0.00001 * params.linear_factor + params.constant_factor * 0.01
                tech.effects = tech.effects or {}
                table.insert(tech.effects, {
                    type = "nothing",
                    effect_description = {"research-evolution-factor-effect",
                        tostring(math.floor((1 - math.exp(-inc)) * 100000 + 0.5) * 0.001)},
                })
            end
        end
    end
    if mods["zzzparanoidal"] then
        require("prototypes.defects-quality-modules")(data.raw)
    end
    local startup = settings.startup
    local prototypes, report, finished, reasons = require("prototypes.defects-final").apply(data.raw, {
        mode = startup["ic-more-qualities-defects-ingredient-mode"].value,
        supply_reduction = startup["ic-more-qualities-defects-pole-supply-reduction"].value,
        wire_reduction = startup["ic-more-qualities-defects-pole-wire-reduction"].value,
        everywhere = startup["ic-more-qualities-quality-everywhere"].value,
        weapons = startup["ic-more-qualities-defects-weapons"].value,
    })
    data:extend(prototypes)
    for _, line in ipairs(report) do log(line) end

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
