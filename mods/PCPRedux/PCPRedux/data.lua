--data:extend({{type = "damage-type",name = "pcp-chemical"}})
--require("prototypes.colorLib")
require("prototypes.icon-functions")
require("prototypes.items")
require("prototypes.fluids")
require("prototypes.recipes")
require("prototypes.technology")
require("prototypes.plas-wall")
--if glass
require("prototypes.bobs-glass-OV")
--if temperate-garden  -- check that bioprocessing is installed
require("prototypes.polylactic-acid")
--if rubber or solid-rubber
if mods.apm_resource_pack_ldinc then
  angelsmods.trigger.rubber = true
  angelsmods.trigger.resin = true
end
require("prototypes.rubber-extended")

if mods.bobplates or mods.apm_resource_pack_ldinc and (data.raw.item["angels-solid-rubber"] or data.raw.item["bob-rubber"]) then
  angelsmods.functions.OV.add_unlock("angels-rubber", "liquid-rubber-2")
  angelsmods.functions.OV.add_unlock("angels-chlorine-processing-2", "butadiene-chlorination")
  angelsmods.functions.OV.add_unlock("angels-chlorine-processing-2", "dichlorobutene-dechlorination")
  angelsmods.functions.OV.add_unlock("angels-steam-cracking-2", "vinyl-acetlyene-chlorination")
  angelsmods.functions.OV.add_unlock("angels-steam-cracking-1", "catalyst-steam-cracking-butane-2")
  angelsmods.functions.OV.add_unlock("angels-steam-cracking-2", "acetylene-diomerisation")
  angelsmods.functions.OV.add_unlock("angels-steam-cracking-2", "catalyst-steam-cracking-acetylene")
  angelsmods.functions.allow_productivity("angels-roll-rubber-converting")
  if data.raw.item["angels-solid-saw"] and type(data.raw.recipe["rubber-slabbing"].ingredients) == "table" then
    table.insert(data.raw.recipe["rubber-slabbing"].ingredients,
      { type = "item", name = "angels-solid-saw", amount = 1 })
    table.insert(data.raw.recipe["rubber-slabbing"].results,
      { type = "item", name = "angels-solid-saw", amount = 1, probability = 0.95, amount_min = 0, amount_max = 1 })
  end
  if mods["angelssmelting"] then
    data.raw.recipe["rubber-powderisation"].category = "angels-powder-mixing"
    data.raw.recipe["rubber-pelletisation"].category = "angels-pellet-pressing"
    data.raw.recipe["angels-roll-rubber-casting"].category = "angels-casting"
    data.raw.recipe["angels-roll-rubber-converting"].subgroup = "angels-alloys-casting"
    data.raw.recipe["angels-roll-rubber-casting"].subgroup = "angels-alloys-casting"
  end
end

if not data.raw.item["bob-rubber"] then
  angelsmods.trigger.rubber = true
  angelsmods.functions.OV.disable_recipe("angels-solid-rubber")
  angelsmods.functions.hide("angels-solid-rubber")
end

if not data.raw.item["bob-resin"] then
  angelsmods.trigger.resin = true
  angelsmods.functions.OV.disable_recipe("angels-solid-resin")
  angelsmods.functions.hide("angels-solid-resin")
end
angelsmods.functions.OV.add_unlock("angels-advanced-chemistry-5", "liquid-fuel-oil-catalyst")
--[[if settings.startup["pcp-enable-experimental"].value then
require ("prototypes.chemical-cloud")
require ("prototypes.entity.chemical-turret")
require ("prototypes.entity.tile")
require ("prototypes.entity.wall")
end]]
