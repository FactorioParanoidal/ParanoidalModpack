-- Machines without quality modules; "quality everywhere" skips them:
--   data.raw["mod-data"]["ic-quality-closed"].data.machines[name] = true
if require("scripts.switches").quality() then
    data:extend({{
        type = "mod-data",
        name = require("scripts.expansion.names").quality_closed,
        data_type = "ic-more-qualities.quality-closed",
        data = {machines = {}},
    }})
end

-- Paranoidal quality control: workshop, control post, signals, panel. Everything belongs to the
-- defect system and is created only together with it.
if require("scripts.switches").defects() then
    require("prototypes.expansion-data")
    -- Recipes whose result is always normal. allow_quality = false only removes the quality module roll:
    -- the engine still gives the result the recipe quality, i.e. the quality of the ingredients (engine check
    -- test-runs/aq-probe-20261031), and a player sets that quality by circuit, blueprint, pasted settings
    -- or a furnace picking the recipe (test-runs/aq-probe2-20261031). Other mods add recipe names until
    -- data-final-fixes (guarded, the registry exists only with defects):
    --   data.raw["mod-data"]["ic-normal-result"].data.recipes[name] = true
    -- data-final-fixes forbids quality modules on them; the defect scheduler and handcraft reset a
    -- positive result to normal (scripts/defects/crafter.lua, handcraft.lua).
    data:extend({{
        type = "mod-data",
        name = require("scripts.expansion.names").normal_result,
        data_type = "ic-more-qualities.normal-result",
        data = {recipes = {}},
    }})
end
