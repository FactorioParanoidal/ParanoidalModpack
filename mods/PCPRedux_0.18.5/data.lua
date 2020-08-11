--data:extend({{type = "damage-type",name = "pcp-chemical"}})
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
require("prototypes.rubber-extended")
if mods.bobplates or mods.apm_resource_pack and (data.raw.item["solid-rubber"] or data.raw.item["rubber"]) then
  angelsmods.functions.OV.add_unlock("rubber", "liquid-rubber-2")
  angelsmods.functions.OV.add_unlock("chlorine-processing-2", "butadiene-chlorination")
  angelsmods.functions.OV.add_unlock("chlorine-processing-2", "dichlorobutene-dechlorination")
  angelsmods.functions.OV.add_unlock("chlorine-processing-2", "vinyl-acetlyene-chlorination")
  angelsmods.functions.OV.add_unlock("gas-steam-cracking-1", "catalyst-steam-cracking-butane-2")
  angelsmods.functions.OV.add_unlock("angels-advanced-chemistry-2", "acetylene-diomerisation")
  angelsmods.functions.OV.add_unlock("gas-steam-cracking-2", "catalyst-steam-cracking-acetylene")
  angelsmods.functions.allow_productivity("angels-roll-rubber-converting")
  if data.raw.item["solid-saw"] and type(data.raw.recipe["rubber-slabbing"].ingredients)=="table" then
    table.insert(data.raw.recipe["rubber-slabbing"].ingredients,{type="item",name="solid-saw",amount=1})
    table.insert(data.raw.recipe["rubber-slabbing"].results,{type="item",name="solid-saw",amount=1,probability=0.95,amount_min=0, amount_max=1})
  end
  if mods["angelssmelting"] then
    data.raw.recipe["rubber-powderisation"].category="powder-mixing"
    data.raw.recipe["rubber-pelletisation"].category="pellet-pressing"
    data.raw.recipe["angels-roll-rubber-casting"].category="casting"
    data.raw.recipe["angels-roll-rubber-converting"].subgroup="angels-alloys-casting"
    data.raw.recipe["angels-roll-rubber-casting"].subgroup="angels-alloys-casting"
  end
end
angelsmods.functions.OV.add_unlock("angels-advanced-chemistry-3", "liquid-fuel-oil-catalyst")
--[[if settings.startup["pcp-enable-experimental"].value then
require ("prototypes.chemical-cloud")
require ("prototypes.entity.chemical-turret")
require ("prototypes.entity.tile")
require ("prototypes.entity.wall")
end]]