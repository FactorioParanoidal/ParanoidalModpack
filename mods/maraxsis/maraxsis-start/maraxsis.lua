local utils = require("__any-planet-start__.utils")

local k2 = mods["Krastorio2-spaced-out"] or mods["Krastorio2"]

utils.set_prerequisites("maraxsis-glassworking", nil)
utils.set_prerequisites("maraxsis-casting", {"maraxsis-glassworking"})
utils.set_prerequisites("steel-processing", {"maraxsis-casting"})
utils.set_prerequisites("electronics", {"steel-processing"})
utils.set_prerequisites("maraxsis-hydro-plant", {"tungsten-steel"})
utils.set_prerequisites("solar-energy", {"electronics"})
utils.set_prerequisites("automation-science-pack", {"solar-energy"})
utils.set_prerequisites("maraxsis-wyrm-confinement", {"steam-power", "maraxsis-piscary", "chemical-science-pack"})
utils.set_prerequisites("steam-power", {"maraxsis-hydro-plant"})
utils.set_prerequisites("ducts", {"cliff-explosives"})
utils.set_prerequisites("plastics", {"lubricant", "logistic-science-pack"})
utils.set_prerequisites("processing-unit", {"sulfur-processing", "advanced-circuit", "ducts"})
utils.set_prerequisites("tungsten-steel", {"electronics"})
utils.set_prerequisites("metallurgic-science-pack", {"big-mining-drill"})
utils.set_prerequisites("maraxsis-piscary", {"landfill", "plastics", "electric-mining-drill"})
utils.set_prerequisites("sulfur-processing", {"steam-power"})
utils.set_prerequisites("oil-gathering", {"space-science-pack"})
utils.set_prerequisites("planet-discovery-nauvis", {"rocket-fuel", "space-platform-thruster"})
utils.set_prerequisites("planet-discovery-vulcanus", {"rocket-fuel", "space-platform-thruster"})
utils.set_prerequisites("planet-discovery-fulgora", {"rocket-fuel", "space-platform-thruster", "electric-energy-accumulators"})
utils.set_prerequisites("oil-processing", {"planet-discovery-nauvis", "oil-gathering"})
utils.set_prerequisites("advanced-oil-processing", {"oil-processing", "production-science-pack"})
utils.set_prerequisites("rocket-silo", {"processing-unit", "logistic-robotics", "advanced-material-processing-2", "maraxsis-project-seadragon", "low-density-structure"})
utils.set_prerequisites("hydraulic-science-pack", {"maraxsis-wyrm-confinement", "chemical-science-pack", "maraxsis-geothermal-energy"})
utils.set_prerequisites("fission-reactor-equipment", {"power-armor", "utility-science-pack", "military-science-pack"})
utils.set_prerequisites("rocket-fuel", {"oil-gathering"})
utils.set_prerequisites("railway", {"elevated-rail", "engine", "logistics-2"})
utils.set_prerequisites("production-science-pack", {"productivity-module", "advanced-material-processing-2"})
if not k2 then utils.set_prerequisites("maraxsis-deepsea-research", {"chemical-science-pack", "hydraulic-science-pack"}) end
utils.set_prerequisites("maraxsis-sonar", {"radar"})
utils.set_prerequisites("radar", {"hydraulic-science-pack"})
utils.set_prerequisites("concrete", {"lubricant"})
utils.set_prerequisites("lubricant", {"maraxsis-hydro-plant"})
utils.set_prerequisites("electric-engine", {"engine", "lubricant"})
utils.set_prerequisites("automation-science-pack", {"concrete", "lubricant"})
utils.set_prerequisites("explosives", {"sulfur-processing", "maraxsis-piscary"})
utils.set_prerequisites("military-2", {"military", "logistic-science-pack"})
utils.set_prerequisites("cliff-explosives", {"military-2", "explosives", "fluid-handling"})
utils.set_prerequisites("low-density-structure", {"plastics", "electric-engine", "advanced-material-processing"})
utils.set_prerequisites("maraxsis-geothermal-energy", {"processing-unit", "chemical-science-pack"})
utils.set_prerequisites("exoskeleton-equipment", {"power-armor"})
utils.set_prerequisites("power-armor", {"chemical-science-pack", "electric-engine", "modular-armor", "processing-unit"})
utils.set_prerequisites("robotics", {"chemical-science-pack", "electric-engine", "battery"})
utils.set_prerequisites("chemical-science-pack", {"advanced-circuit", "sulfur-processing", "engine"})

if not mods["planet-muluna"] then
    utils.set_prerequisites("automobilism", {"space-science-pack"})
    utils.set_prerequisites("nuclear-power", {"kovarex-enrichment-process"})
else
    utils.set_prerequisites("wood-gas-processing", {"muluna-greenhouses"})
end

utils.add_recipes("tree-seeding", {"wooden-chest"})
utils.add_recipes("electric-energy-distribution-1", {"small-electric-pole"})
utils.add_recipes("plastics", {"maraxsis-smelt-microplastics"})
utils.add_recipes("electronics", {"chemical-plant"})
utils.add_recipes("tungsten-steel", {"maraxsis-tungsten-ore-dissolution"})
utils.add_recipes("biochamber", {"maraxsis-nutrients-from-tropical-fish"})
utils.add_recipes("maraxsis-casting", {"maraxsis-limestone-crushing", "molten-iron-from-lava", "molten-copper-from-lava", "casting-iron", "casting-copper", "iron-stick", "copper-cable", "iron-chest", "transport-belt"})
utils.add_recipes("steam-power", {"burner-inserter", "burner-mining-drill"})
utils.add_recipes("space-platform-thruster", {"maraxsis-atmosphere"})
utils.add_recipes("production-science-pack", {"rail"})
utils.add_recipes("oil-gathering", {"oil-refinery", "lubricant"})
utils.add_recipes("lubricant", {"biolubricant", "maraxsis-microplastics", "maraxsis-carbon-fiber-from-jelly", "firearm-magazine", "piercing-rounds-magazine"})
utils.add_recipes("automation-science-pack", {"lab"})
utils.add_recipes("low-density-structure", {"crusher"})
utils.add_recipes("explosives", {"coal-synthesis"})
utils.add_recipes("advanced-oil-processing", {"sulfur"})
utils.add_recipes("sulfur-processing", {"maraxsis-geothermal-sulfur", "maraxsis-supercritical-steam"})
utils.add_recipes("cryogenic-plant", {"maraxsis-supercritical-steam-cooling"})
utils.add_recipes("concrete", {"concrete-from-molten-iron", "stone-brick", "foundry"})
utils.add_recipes("steel-processing", {"medium-electric-pole", "light-armor", "stone-furnace"})
utils.add_recipes("space-platform", {"iron-plate", "copper-plate"})
utils.add_recipes("maraxsis-hydro-plant", {"maraxsis-fiber-degradation"})

utils.remove_recipes("maraxsis-piscary", {"maraxsis-microplastics", "maraxsis-smelt-microplastics", "maraxsis-nutrients-from-tropical-fish"})
utils.remove_recipes("oil-processing", {"chemical-plant", "oil-refinery"})
utils.remove_recipes("electronics", {"small-electric-pole", "copper-cable"})
utils.remove_recipes("rocket-turret", {"coal-synthesis"})
utils.remove_recipes("electric-energy-distribution-1", {"medium-electric-pole"})
utils.remove_recipes("maraxsis-glassworking", {"maraxsis-sand-extraction", "maraxsis-limestone-crushing", "maraxsis-atmosphere"})
utils.remove_recipes("railway", {"rail"})
utils.remove_recipes("foundry", {"foundry", "concrete-from-molten-iron", "molten-iron-from-lava", "molten-copper-from-lava", "casting-iron", "casting-copper"})
utils.remove_recipes("planet-discovery-maraxsis", {"maraxsis-diesel-submarine"})
utils.remove_recipes("steam-power", {"pipe", "pipe-to-ground", "offshore-pump"})
utils.remove_recipes("electric-mining-drill", {"maraxsis-sand-extraction"})
utils.remove_recipes("bioflux-processing", {"biolubricant"})
utils.remove_recipes("lubricant", {"lubricant"})
utils.remove_recipes("electronics", {"lab"})
utils.remove_recipes("concrete", {"iron-stick"})
utils.remove_recipes("circuit-network", {"iron-stick"})
utils.remove_recipes("electric-energy-distribution-1", {"iron-stick"})
utils.remove_recipes("military-2", {"piercing-rounds-magazine"})
utils.remove_recipes("space-platform", {"crusher"})
utils.remove_recipes("sulfur-processing", {"sulfur"})
utils.remove_recipes("maraxsis-geothermal-energy", {"maraxsis-geothermal-sulfur", "maraxsis-supercritical-steam", "maraxsis-supercritical-steam-cooling"})

utils.set_trigger("maraxsis-casting", {type = "craft-fluid", fluid = "lava"})
utils.set_trigger("solar-energy", {type = "craft-item", item = "electronic-circuit", count = 25})
utils.set_trigger("steam-power", {type = "craft-item", item = "rocket-fuel", count = 100})
utils.set_trigger("tungsten-steel", {type = "build-entity", entity = "chemical-plant"})
utils.set_trigger("electronics", {type = "craft-fluid", fluid = "molten-copper"})
utils.set_trigger("steel-processing", {type = "craft-fluid", fluid = "molten-iron"})
utils.set_trigger("maraxsis-hydro-plant", {type = "craft-item", item = "tungsten-plate", amount = 50})
utils.set_trigger("concrete", {type = "craft-fluid", fluid = "water"})
utils.set_trigger("lubricant", {type = "build-entity", entity = "maraxsis-hydro-plant"})
utils.set_trigger("automation-science-pack", {type = "craft-item", item = "foundry"})
utils.set_trigger("sulfur-processing", {type = "build-entity", entity = "maraxsis-geothermal-generator"})
utils.set_trigger("processing-unit", {type = "build-entity", entity = "maraxsis-trench-duct"})
utils.set_trigger("ducts", {type = "craft-item", item = "cliff-explosives"})

data.raw.tree["maraxsis-polylplast"].minable.results = {
    {
        type = "item",
        name = "maraxsis-coral",
        amount_min = 50,
        amount_max = 75,
    },
    {
        type = "item",
        name = "tungsten-carbide",
        amount_min = 500,
        amount_max = 750,
    }
}

for i, result in pairs(data.raw["simple-entity"]["maraxsis-mollusk-husk"].minable.results) do
    if result.name == "limestone" then
        result.name = "calcite"
    end
end

data.raw.recipe["pipe"].enabled = true
data.raw.recipe["pipe-to-ground"].enabled = true
data.raw.recipe["offshore-pump"].enabled = true
data.raw.recipe["iron-gear-wheel"].enabled = true

data.raw.recipe["small-electric-pole"].enabled = false
data.raw.recipe["wooden-chest"].enabled = false
data.raw.recipe["burner-mining-drill"].enabled = false
data.raw.recipe["firearm-magazine"].enabled = false
data.raw.recipe["iron-plate"].enabled = false
data.raw.recipe["copper-plate"].enabled = false
data.raw.recipe["stone-furnace"].enabled = false
data.raw.recipe["stone-brick"].enabled = false
data.raw.recipe["burner-inserter"].enabled = false
data.raw.recipe["iron-chest"].enabled = false
data.raw.recipe["light-armor"].enabled = false
data.raw.recipe["transport-belt"].enabled = false

local logistic_science = {"automation-science-pack", "logistic-science-pack"}
local chemical_science = {"automation-science-pack", "logistic-science-pack", "chemical-science-pack"}
local hydraulic_science = {"automation-science-pack", "logistic-science-pack", "chemical-science-pack", "hydraulic-science-pack"}
local space_science = {"automation-science-pack", "logistic-science-pack", "chemical-science-pack", "hydraulic-science-pack", "space-science-pack"}
local space_science_or_before_muluna = {"automation-science-pack", "logistic-science-pack", "chemical-science-pack", "hydraulic-science-pack", "space-science-pack"}

if mods["planet-muluna"] then
    space_science_or_before_muluna = {"automation-science-pack", "logistic-science-pack", "chemical-science-pack", "hydraulic-science-pack"} --Technologies intended to exist when starting a Muluna base.
end

local production_science = {"automation-science-pack", "logistic-science-pack", "chemical-science-pack", "space-science-pack", "production-science-pack"}
local production_space_science = {"automation-science-pack", "logistic-science-pack", "chemical-science-pack", "space-science-pack", "production-science-pack"}
local military_space_science = {"automation-science-pack", "logistic-science-pack", "military-science-pack", "chemical-science-pack", "space-science-pack"}

utils.set_packs("hydraulic-science-pack", chemical_science, 100, 30)
utils.set_packs("maraxsis-piscary", logistic_science, 100, 30)
utils.set_packs("oil-gathering", space_science, 100, 30)
utils.set_packs("advanced-oil-processing", production_space_science, 1000, 60)
utils.set_packs("flammables", space_science, 200, 60)
utils.set_packs("flamethrower", military_space_science, 200, 60)
utils.set_packs("rocketry", military_space_science, 500, 60)
utils.set_packs("explosive-rocketry", military_space_science, 500, 60)
utils.set_packs("automobilism", space_science, 500, 60)
utils.set_packs("tank", military_space_science, 1000, 60)
utils.set_packs("nuclear-power", space_science_or_before_muluna, 1000, 60)
utils.set_packs("rocket-fuel", space_science_or_before_muluna, 300, 45)
utils.set_packs("railway", production_science, 100, 30)
utils.set_packs("automated-rail-transportation", production_science, 100, 30)
utils.set_packs("fluid-wagon", production_science, 100, 30)
utils.set_packs("radar", hydraulic_science, 100, 60)
utils.set_packs("maraxsis-sonar", hydraulic_science, 100, 60)
utils.set_packs("electric-engine", logistic_science, 100, 30)
if not k2 then utils.set_packs("maraxsis-deepsea-research", hydraulic_science, 500, 60) end
utils.set_packs("cliff-explosives", logistic_science, 100, 30)
utils.set_packs("maraxsis-wyrm-confinement", chemical_science, 100, 30)
utils.set_packs("low-density-structure", logistic_science, 100, 30)
utils.set_packs("maraxsis-geothermal-energy", chemical_science, 250, 30)
utils.set_packs("rocket-silo", hydraulic_science, 1000, 60)
utils.set_packs("uranium-mining", space_science, 300, 60)

PlanetsLib.rro.soft_insert(data.raw["technology"]["planet-discovery-aquilo"].unit.ingredients, {"hydraulic-science-pack", 1})
PlanetsLib.rro.soft_insert(data.raw["technology"]["captive-biter-spawner"].unit.ingredients, {"hydraulic-science-pack", 1})
PlanetsLib.rro.soft_insert(data.raw["technology"]["foundation"].unit.ingredients, {"hydraulic-science-pack", 1})
PlanetsLib.rro.soft_insert(data.raw["technology"]["quantum-processor"].unit.ingredients, {"hydraulic-science-pack", 1})
PlanetsLib.rro.soft_insert(data.raw["technology"]["railgun"].unit.ingredients, {"hydraulic-science-pack", 1})
PlanetsLib.rro.soft_insert(data.raw["technology"]["fusion-reactor"].unit.ingredients, {"hydraulic-science-pack", 1})
PlanetsLib.rro.soft_insert(data.raw["technology"]["fusion-reactor-equipment"].unit.ingredients, {"hydraulic-science-pack", 1})

PlanetsLib.rro.soft_insert(data.raw.technology["maraxsis-hydro-plant"].effects, {
    type = "unlock-quality",
    quality = "uncommon",
})

PlanetsLib.rro.soft_insert(data.raw.technology["maraxsis-hydro-plant"].effects, {
    type = "unlock-quality",
    quality = "rare",
})

-- remove processing units and quality module 3 from hydro plant
local new_ingredients = {}
for _, ingredient in pairs(data.raw.recipe["maraxsis-hydro-plant"].ingredients) do
    if ingredient.name ~= "processing-unit" and ingredient.name ~= "quality-module-3" then
        PlanetsLib.rro.soft_insert(new_ingredients, ingredient)
    end
end
PlanetsLib.rro.soft_insert(new_ingredients, {type = "item", name = "electronic-circuit", amount = 10})
data.raw.recipe["maraxsis-hydro-plant"].ingredients = new_ingredients

-- remove agricultural tower from fishing tower
local new_ingredients = {}
for _, ingredient in pairs(data.raw.recipe["maraxsis-fishing-tower"].ingredients) do
    if ingredient.name ~= "agricultural-tower" then
        PlanetsLib.rro.soft_insert(new_ingredients, ingredient)
    end
end
PlanetsLib.rro.soft_insert(new_ingredients, {type = "item", name = "steel-plate", amount = 10})
PlanetsLib.rro.soft_insert(new_ingredients, {type = "item", name = "electronic-circuit", amount = 10})
data.raw.recipe["maraxsis-fishing-tower"].ingredients = new_ingredients

-- remove steel and green chips from agricultural tower
local new_ingredients = {}
for _, ingredient in pairs(data.raw.recipe["agricultural-tower"].ingredients) do
    if ingredient.name ~= "steel-plate" and ingredient.name ~= "electronic-circuit" then
        PlanetsLib.rro.soft_insert(new_ingredients, ingredient)
    end
end
PlanetsLib.rro.soft_insert(new_ingredients, {type = "item", name = "maraxsis-fishing-tower", amount = 1})
data.raw.recipe["agricultural-tower"].ingredients = new_ingredients

for _, condition in pairs(data.raw.recipe["foundry"].surface_conditions) do
    if condition.property == "pressure" then
        condition.min = 4000
        condition.max = nil
    end
end

data.raw.recipe["maraxsis-pressure-dome"].categories = {"maraxsis-hydro-plant","crafting"}
data.raw.recipe["biolubricant"].categories = {"maraxsis-hydro-plant","organic"}
data.raw.recipe["refined-concrete"].categories = {"crafting-with-fluid","metallurgy"}

table.insert(data.raw.technology["maraxsis-glassworking"].effects, 1, {
    type = "unlock-space-location",
    space_location = "maraxsis-trench",
    use_icon_overlay_constant = true
})

--reduce the % chance of losing carbon fiber in the water filter loop from 2.5% to 0.1%
for _, result in pairs(data.raw.recipe["maraxsis-salt-filter-cleaning"].results) do
    if result.name == "carbon-fiber" then
        assert(result.independent_probability == 0.025)
        result.independent_probability = 0.049
    end
end
