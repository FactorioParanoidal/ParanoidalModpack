local utils = require("__any-planet-start__.utils")
data.raw.recipe["medium-electric-pole"].enabled = true
data.raw.recipe["carbon"].enabled = true
data.raw.recipe["ice-melting"].enabled = true
data.raw.recipe["heating-tower"].enabled = true
data.raw.recipe["heat-exchanger"].enabled = true
data.raw.recipe["heat-pipe"].enabled = true
data.raw.recipe["nutrients-from-spoilage"].enabled = true
data.raw.recipe["oxide-asteroid-reprocessing"].enabled = true
data.raw.recipe["burnt-spoilage"].enabled = true
data.raw.recipe["cryogenic-plant"].enabled = true
data.raw.recipe["coal-synthesis"].enabled = true
data.raw.recipe["scrap-recycling"].enabled = true
data.raw.recipe["biochamber"].enabled = true
data.raw.recipe["biochamber"].surface_conditions = 
{
    {
        property = "pressure",
        min = 200,
        max = 2000
    }
}
data.raw["mining-drill"]["burner-mining-drill"].heating_energy = "0kW"
--data.raw.recipe["pumpjack"].enabled = true

local logistic_science = {"automation-science-pack", "logistic-science-pack"}
local automation_science = {"automation-science-pack"}
local golden_science = {"automation-science-pack","logistic-science-pack","chemical-science-pack","utility-science-pack","golden-science-pack"}
local golden_science_production = {"automation-science-pack","logistic-science-pack","chemical-science-pack","utility-science-pack","production-science-pack","golden-science-pack"}
local golden_science_military = {"automation-science-pack","logistic-science-pack","chemical-science-pack","utility-science-pack","military-science-pack","golden-science-pack"}

utils.set_packs("fluid-handling", automation_science, 10, 30)
utils.set_packs("coal-liquefaction", logistic_science, 100, 30)
utils.set_packs("oil-gathering", automation_science, 100, 30)
utils.set_packs("oil-processing", automation_science, 100, 30)
utils.set_packs("advanced-oil-processing", logistic_science, 100, 30)
utils.set_packs("sulfur-processing", logistic_science, 100, 30)
utils.set_prerequisites("gold-railgun-turret",{"planet-discovery-secretas"})
utils.set_packs("kovarex-enrichment-process",golden_science,2000,60)
utils.set_packs("gold-railgun-turret",golden_science_military,2000,60)
utils.set_packs("pentapod-egg-unrestricted",golden_science,2000,60)