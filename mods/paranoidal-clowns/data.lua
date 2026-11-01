clowns = clowns or {}
clowns.functions = clowns.functions or {}
clowns.tables = clowns.tables or {}
clowns.trigger = clowns.trigger or {}
clowns.trigger.smelting_products = clowns.trigger.smelting_products or {}
clowns.trigger.smelting_products["magnesium"] = clowns.trigger.smelting_products["magnesium"] or {}

---------------------------------------------------------------------------------------------------
-- Nuclear (was MadClown01's Vanilla Nuclear)
---------------------------------------------------------------------------------------------------
require("prototypes.nuclear.functions")
require("prototypes.nuclear.categories")

require("prototypes.nuclear.items.items")
require("prototypes.nuclear.items.projectiles")
require("prototypes.nuclear.items.clowns-centrifuging")

require("prototypes.nuclear.recipes.mixed-oxide")
require("prototypes.nuclear.recipes.artillery-shells")
require("prototypes.nuclear.recipes.bombs")
require("prototypes.nuclear.recipes.clowns-centrifuging")

require("prototypes.nuclear.technology.technology")

require("prototypes.nuclear.overrides.overrides")

---------------------------------------------------------------------------------------------------
-- Processing (was MadClown01's Processing)
---------------------------------------------------------------------------------------------------
-- "special vanilla": Angel's with only iron, copper and uranium ores enabled.
clowns.special_vanilla = true
for ore_name, ore_enabled in pairs(angelsmods.trigger.ores or {}) do
  if ore_enabled and ore_name ~= "iron" and ore_name ~= "copper" and ore_name ~= "uranium" then
    clowns.special_vanilla = false
  end
end

if not clowns.special_vanilla then
  angelsmods.trigger.smelting_products["aluminium"].powder = true
  angelsmods.trigger.ores["aluminium"] = true
  angelsmods.trigger.ores["gold"] = true
  angelsmods.trigger.ores["platinum"] = true
  angelsmods.trigger.ores["silver"] = true
  angelsmods.trigger.ores["titanium"] = true
  angelsmods.trigger.ores["tungsten"] = true
end
angelsmods.trigger.sintering_tech = true
angelsmods.trigger.early_chemical_furnace = true

require("prototypes.categories")

require("prototypes.buildings.sluicer")
require("prototypes.items.vanilla-items")
require("prototypes.items.neurotoxin")
require("prototypes.items.angels-bioprocessing")

require("prototypes.recipes.vanilla-recipes")
require("prototypes.recipes.angels-smelting")
require("prototypes.recipes.petrochem")
require("prototypes.recipes.angels-bioprocessing")
require("prototypes.recipes.bobs")

require("prototypes.technology.gardens")
require("prototypes.technology.magnesium")
require("prototypes.technology.depleted-uranium")
require("prototypes.technology.osmium")
require("prototypes.technology.uranium")
require("prototypes.technology.mercury")
require("prototypes.technology.salination")
require("prototypes.technology.phosphorus")

require("prototypes.overrides")

---------------------------------------------------------------------------------------------------
-- AngelBob nuclear (was MadClown01's AngelBob Nuclear)
---------------------------------------------------------------------------------------------------
angelsmods.trigger.ores["lead"] = true
angelsmods.trigger.smelting_products["lead"].plate = true

require("prototypes.angelbob.items.thorium")
require("prototypes.angelbob.items.isotopes")
require("prototypes.angelbob.items.fuels")
require("prototypes.angelbob.items.water-treatment")

require("prototypes.angelbob.recipes.clowns-centrifuging")
require("prototypes.angelbob.recipes.thorium")
require("prototypes.angelbob.recipes.nuclear-reprocessing")
require("prototypes.angelbob.recipes.fuels")
require("prototypes.angelbob.recipes.water-treatment")

require("prototypes.angelbob.technology.fuels")
require("prototypes.angelbob.technology.nuclear-reprocessing")
require("prototypes.angelbob.technology.thorium-processing")
require("prototypes.angelbob.overrides")
