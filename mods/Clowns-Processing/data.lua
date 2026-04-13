-- function to know if this is special vanilla or not (DUPLICATE OF ANGELS, since this mod seems to be calling it earlier)
if not clowns then clowns = {} end
if not clowns.functions then clowns.functions = {} end
if not clowns.tables then clowns.tables = {} end
clowns.trigger = clowns.trigger or {}
clowns.trigger.smelting_products = clowns.trigger.smelting_products or {}
clowns.trigger.smelting_products["magnesium"] = clowns.trigger.smelting_products["magnesium"] or {}

--check vanilla settings
clowns.special_vanilla = true --assume true, then find out if false
for ore_name, ore_enabled in pairs(angelsmods.trigger.ores or {}) do
  if ore_enabled and ore_name ~= "iron" and ore_name ~= "copper" and ore_name ~= "uranium" then
    clowns.special_vanilla = false
  end
end
if mods["pyrawores"] then --force full mode
  clowns.special_vanilla = false
end

if not clowns.special_vanilla --[[=false]] then
  --angelsmods.trigger.smelting_products["enable-all"] = true -- to ensure we get all the powders
  angelsmods.trigger.smelting_products["aluminium"].powder = true
  angelsmods.trigger.ores["aluminium"] = true
  angelsmods.trigger.ores["gold"] = true
  angelsmods.trigger.ores["platinum"] = true
  angelsmods.trigger.ores["silver"] = true
  angelsmods.trigger.ores["titanium"] = true
  angelsmods.trigger.ores["tungsten"] = true
  --angelsmods.trigger.refinery_products["rubyte"] = true
end
angelsmods.trigger.sintering_tech = true
angelsmods.trigger.early_chemical_furnace = true
if mods["bobassembly"] then
  settings.startup["MCP_enable_centrifuges"].value = false
end
require("prototypes.categories")

-- ITEMS
-- vanilla-items include things for angels-refining,smelting and petrochem
require("prototypes.buildings.sluicer")
require("prototypes.buildings.centrifuge") --active if setting

require("prototypes.items.vanilla-items")
require("prototypes.items.neurotoxin")
--angelsbioprocessing
require("prototypes.items.angels-bioprocessing")
--angelsindustries
--bobs

--RECIPES
--vanilla
require("prototypes.recipes.vanilla-recipes")
require("prototypes.recipes.angels-smelting")
require("prototypes.recipes.petrochem")
--angelsbioprocessing
require("prototypes.recipes.angels-bioprocessing")
--bobs
require("prototypes.recipes.bobs")


--if mods["angelsbioprocessing"] then
require("prototypes.technology.gardens")
--end
require("prototypes.technology.magnesium")
require("prototypes.technology.depleted-uranium")
require("prototypes.technology.osmium")
require("prototypes.technology.uranium")
require("prototypes.technology.mercury")
--if settings.startup["MCP_enable_centrifuges"].value then
require("prototypes.technology.centrifuging")
--end
require("prototypes.technology.salination")
require("prototypes.technology.phosphorus")

require("prototypes.overrides")
