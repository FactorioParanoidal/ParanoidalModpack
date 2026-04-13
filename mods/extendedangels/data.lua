-- Initial requires
require("prototypes.functions")
require("prototypes.subgroups")

-- Setup numeral tint for Angel's warehouses if not already available
if mods["angelsaddons-storage"] then
  if not angelsmods.addons.storage.number_tint then
    angelsmods.addons.storage.number_tint = { r = 0.95, g = 0.65, b = 0.25, a = 1 }
  end
end

-- Enable Angel's Hidden Items
angelsmods.trigger.smelting_products["zinc"].powder = true
if mods["bobplates"] then
angelsmods.trigger.smelting_products["silver"].powder = true
else
angelsmods.trigger.ores["zinc"] = true
angelsmods.trigger.ores["lead"] = true
angelsmods.trigger.smelting_products["lead"].plate = true
end

-- Buildings
require("prototypes.buildings.petrochem")
require("prototypes.buildings.bioprocessing")
require("prototypes.buildings.refining")
require("prototypes.buildings.warehouses")

-- Items
require("prototypes.items.industries-components")
require("prototypes.items.petrochem")
require("prototypes.items.smelting")

-- Recipes
require("prototypes.recipes.industries-components")
require("prototypes.recipes.smelting")

-- Technologies
require("prototypes.technology.petrochem")
require("prototypes.technology.smelting")
require("prototypes.technology.bioprocessing")
require("prototypes.technology.refining")
require("prototypes.technology.warehouses")

-- Fallbacks
require("prototypes.recipe-builder-fallbacks")
