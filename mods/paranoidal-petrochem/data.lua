-- Fuel additive chain (was More Petrochem Hell; loaded before PetrochemPlus).
require("prototypes.fuel-additive")

-- PetrochemPlus.
require("prototypes.items")
require("prototypes.fluids")
require("prototypes.recipes")
require("prototypes.technology")
require("prototypes.plas-wall")
require("prototypes.bobs-glass")
require("prototypes.polylactic-acid")
require("prototypes.rubber-extended")

angelsmods.functions.OV.add_unlock("angels-rubber", "liquid-rubber-2")
angelsmods.functions.OV.add_unlock("angels-chlorine-processing-2", "butadiene-chlorination")
angelsmods.functions.OV.add_unlock("angels-chlorine-processing-2", "dichlorobutene-dechlorination")
angelsmods.functions.OV.add_unlock("angels-steam-cracking-2", "vinyl-acetlyene-chlorination")
angelsmods.functions.OV.add_unlock("angels-steam-cracking-1", "catalyst-steam-cracking-butane-2")
angelsmods.functions.OV.add_unlock("angels-steam-cracking-2", "acetylene-diomerisation")
angelsmods.functions.OV.add_unlock("angels-steam-cracking-2", "catalyst-steam-cracking-acetylene")
angelsmods.functions.allow_productivity("angels-roll-rubber-converting")
if data.raw.item["angels-solid-saw"] then
  table.insert(data.raw.recipe["rubber-slabbing"].ingredients,
    { type = "item", name = "angels-solid-saw", amount = 1 })
  table.insert(data.raw.recipe["rubber-slabbing"].results,
    { type = "item", name = "angels-solid-saw", amount = 1, probability = 0.95, amount_min = 0, amount_max = 1 })
end
angelsmods.functions.set_recipe_category(data.raw.recipe["rubber-powderisation"], "angels-powder-mixing")
angelsmods.functions.set_recipe_category(data.raw.recipe["rubber-pelletisation"], "angels-pellet-pressing")
angelsmods.functions.set_recipe_category(data.raw.recipe["angels-roll-rubber-casting"], "angels-casting")
data.raw.recipe["angels-roll-rubber-converting"].subgroup = "angels-alloys-casting"
data.raw.recipe["angels-roll-rubber-casting"].subgroup = "angels-alloys-casting"

angelsmods.functions.OV.add_unlock("angels-advanced-chemistry-5", "liquid-fuel-oil-catalyst")
