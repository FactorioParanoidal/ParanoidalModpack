local BioInd = require('common')('Bio_Industries')

BI.Settings.Bio_Cannon = settings.startup["BI_Bio_Cannon"].value
BI.Settings.BI_Bio_Fuel = settings.startup["BI_Bio_Fuel"].value
BI.Settings.BI_Game_Tweaks_Stack_Size = settings.startup["BI_Game_Tweaks_Stack_Size"].value
BI.Settings.BI_Game_Tweaks_Recipe = settings.startup["BI_Game_Tweaks_Recipe"].value
BI.Settings.BI_Game_Tweaks_Tree = settings.startup["BI_Game_Tweaks_Tree"].value
BI.Settings.BI_Game_Tweaks_Player = settings.startup["BI_Game_Tweaks_Player"].value
BI.Settings.BI_Game_Tweaks_Disassemble = settings.startup["BI_Game_Tweaks_Disassemble"].value
BI.Settings.BI_Game_Tweaks_Bot = settings.startup["BI_Game_Tweaks_Bot"].value
BI.Settings.BI_Solar_Additions = settings.startup["BI_Solar_Additions"].value

local ICONPATH = "__Bio_Industries__/graphics/icons/"

----Update the Wood Pipe Images
require ("prototypes.Wood_Products.pipes")

--- Update the Rail Images
require ("prototypes.Wood_Products.wooden_rail_bridge_update")

--- Bridge Rail Remnants
require ("prototypes.Wood_Products.update_bridge_rails_remnants")
require ("prototypes.Wood_Products.tint_rails_remnants_function")

-- Concrete Rail
---- Update Standard Rails to use and look like concrete
set_tint_to_rails(
  {
    data.raw["straight-rail"]["straight-rail"],
    data.raw["curved-rail"]["curved-rail"]
  },
  {r = 183/255, g = 183/255, b = 183/255, a = 1}
) -- concrete

set_tint_to_remnants(
  {
    data.raw["rail-remnants"]["straight-rail-remnants"],
    data.raw["rail-remnants"]["curved-rail-remnants"]
  },
  {r = 183/255, g = 183/255, b = 183/255, a = 1}
) -- concrete

-- Wood Rail
set_tint_to_rails(
  {
    data.raw["straight-rail"]["bi-straight-rail-wood"],
    data.raw["curved-rail"]["bi-curved-rail-wood"]
  },
  {r = 183/255, g = 125/255, b = 62/255, a = 1}
) -- wood

set_tint_to_remnants(
  {
    data.raw["rail-remnants"]["straight-rail-remnants-wood"],
    data.raw["rail-remnants"]["curved-rail-remnants-wood"]
  },
  {r = 183/255, g = 125/255, b = 62/255, a = 1}
) -- wood

--- Power Rail
set_tint_to_rails(
  {
    data.raw["straight-rail"]["straight-rail"],
    data.raw["curved-rail"]["curved-rail"]
  },
  {r = 150/255, g = 150/255, b = 150/255, a = 1}
) -- mix

-- vanilla rail icon & images update
data.raw["straight-rail"]["straight-rail"].icon = ICONPATH .. "straight-rail-concrete.png"
data.raw["straight-rail"]["straight-rail"].icon_size = 32
data.raw["straight-rail"]["straight-rail"].icon_mipmaps = 1
data.raw["curved-rail"]["curved-rail"].icon = ICONPATH .. "curved-rail-concrete.png"
data.raw["curved-rail"]["curved-rail"].icon_size = 32
data.raw["curved-rail"]["curved-rail"].icon_mipmaps = 1
data.raw["rail-planner"]["rail"].icon = ICONPATH .. "rail-concrete.png"
data.raw["rail-planner"]["rail"].icon_size = 32
data.raw["rail-planner"]["rail"].icon_mipmaps = 1

--- Wood Rail added to Tech
thxbob.lib.tech.add_recipe_unlock("railway", "bi-rail-wood")


--- If Bob, move Vanilla Rail to Rail 2 also add Power Rail.
if data.raw.technology["bob-railway-2"] then
  thxbob.lib.tech.remove_recipe_unlock ("railway", "rail")
  thxbob.lib.tech.add_recipe_unlock("bob-railway-2", "rail")
  thxbob.lib.tech.add_recipe_unlock("bob-railway-2", "bi-rail-wood-to-concrete")
  thxbob.lib.tech.add_recipe_unlock("bob-railway-2", "bi-rail-wood-bridge")
  thxbob.lib.tech.add_recipe_unlock("bob-railway-2", "bi-rail-power")
  thxbob.lib.tech.add_recipe_unlock("bob-railway-2", "bi-power-to-rail-pole")
else
  thxbob.lib.tech.add_recipe_unlock("railway", "bi-rail-wood-to-concrete")
  thxbob.lib.tech.add_recipe_unlock("rail-signals", "bi-rail-wood-bridge")
  thxbob.lib.tech.add_recipe_unlock("rail-signals", "bi-rail-power")
  thxbob.lib.tech.add_recipe_unlock("rail-signals", "bi-power-to-rail-pole")
end

-- Damage Bonus to Ammo
-- Don't duplicate what NE does
if not mods["Natural_Evolution_Buildings"] then
  thxbob.lib.tech.add_recipe_unlock ("military", "bi-dart-magazine-standard")
  thxbob.lib.tech.add_recipe_unlock ("military-2", "bi-dart-magazine-enhanced")
  thxbob.lib.tech.add_recipe_unlock ("military-3", "bi-dart-magazine-poison")
end

require("prototypes.Bio_Turret.technology-updates")
require("prototypes.Bio_Cannon.technology-updates")

if not mods["Natural_Evolution_Buildings"] and BI.Settings.Bio_Cannon then
  -- add Prototype Artillery as pre req for artillery
  thxbob.lib.tech.add_prerequisite("artillery", "bi-tech-bio-cannon")
end

--- Move Stone Crusher up in tech tree
thxbob.lib.tech.add_recipe_unlock("steel-processing", "bi-stone-crusher")
thxbob.lib.tech.add_recipe_unlock("steel-processing", "bi-crushed-stone-1")

-- Unlock recipes for Crushed Stone from concrete/hazard concrete
thxbob.lib.tech.add_recipe_unlock("advanced-material-processing-2", "bi-crushed-stone-2")
thxbob.lib.tech.add_recipe_unlock("advanced-material-processing-2", "bi-crushed-stone-3")
thxbob.lib.tech.add_recipe_unlock("advanced-material-processing-2", "bi-crushed-stone-4")
thxbob.lib.tech.add_recipe_unlock("advanced-material-processing-2", "bi-crushed-stone-5")
thxbob.lib.tech.add_prerequisite("advanced-material-processing-2", "concrete")

-- Add Wooden Chests
thxbob.lib.tech.add_recipe_unlock("logistics", "bi-wooden-chest-large")
thxbob.lib.tech.add_recipe_unlock("logistics-2", "bi-wooden-chest-huge")
thxbob.lib.tech.add_recipe_unlock("logistics-3", "bi-wooden-chest-giga")

-- Add Big and Huge electric poles to tech tree
thxbob.lib.tech.add_recipe_unlock ("logistics", "bi-wooden-pole-big")
thxbob.lib.tech.add_recipe_unlock ("electric-energy-distribution-2", "bi-wooden-pole-huge")

--- Wood Floors
-- Make wood placeable only if Dectorio isn't installed. Should leave existing flooring intact.
if not mods["Dectorio"] then
  data.raw.item["wood"].place_as_tile = {
    result = "bi-wood-floor",
    condition_size = 4,
    condition = { "water-tile" }
  }
end


--- Make it so that the Base game tile "grass" can't be placed in blueprints
--- New as of 0.16
for _, tile in pairs{
  "grass-1",
  "grass-2",
  "grass-3",
  "grass-4",
} do
  BI_Functions.lib.remove_from_blueprint(tile)
end

if mods["alien-biomes"] then
  BioInd.writeDebug("Removing AB tiles from blueprints")
  for _, tile in pairs({
    "frozen-snow-0",
    "frozen-snow-1",
    "frozen-snow-2",
    "frozen-snow-3",
    "frozen-snow-4",
    "frozen-snow-5",
    "frozen-snow-6",
    "frozen-snow-7",
    "frozen-snow-8",
    "frozen-snow-9",
    "mineral-aubergine-dirt-1",
    "mineral-aubergine-dirt-2",
    "mineral-aubergine-dirt-3",
    "mineral-aubergine-dirt-4",
    "mineral-aubergine-dirt-5",
    "mineral-aubergine-dirt-6",
    "mineral-aubergine-sand-1",
    "mineral-aubergine-sand-2",
    "mineral-aubergine-sand-3",
    "mineral-beige-dirt-1",
    "mineral-beige-dirt-2",
    "mineral-beige-dirt-3",
    "mineral-beige-dirt-4",
    "mineral-beige-dirt-5",
    "mineral-beige-dirt-6",
    "mineral-beige-sand-1",
    "mineral-beige-sand-2",
    "mineral-beige-sand-3",
    "mineral-black-dirt-1",
    "mineral-black-dirt-2",
    "mineral-black-dirt-3",
    "mineral-black-dirt-4",
    "mineral-black-dirt-5",
    "mineral-black-dirt-6",
    "mineral-black-sand-1",
    "mineral-black-sand-2",
    "mineral-black-sand-3",
    "mineral-brown-dirt-1",
    "mineral-brown-dirt-2",
    "mineral-brown-dirt-3",
    "mineral-brown-dirt-4",
    "mineral-brown-dirt-5",
    "mineral-brown-dirt-6",
    "mineral-brown-sand-1",
    "mineral-brown-sand-2",
    "mineral-brown-sand-3",
    "mineral-cream-dirt-1",
    "mineral-cream-dirt-2",
    "mineral-cream-dirt-3",
    "mineral-cream-dirt-4",
    "mineral-cream-dirt-5",
    "mineral-cream-dirt-6",
    "mineral-cream-sand-1",
    "mineral-cream-sand-2",
    "mineral-cream-sand-3",
    "mineral-dustyrose-dirt-1",
    "mineral-dustyrose-dirt-2",
    "mineral-dustyrose-dirt-3",
    "mineral-dustyrose-dirt-4",
    "mineral-dustyrose-dirt-5",
    "mineral-dustyrose-dirt-6",
    "mineral-dustyrose-sand-1",
    "mineral-dustyrose-sand-2",
    "mineral-dustyrose-sand-3",
    "mineral-grey-dirt-1",
    "mineral-grey-dirt-2",
    "mineral-grey-dirt-3",
    "mineral-grey-dirt-4",
    "mineral-grey-dirt-5",
    "mineral-grey-dirt-6",
    "mineral-grey-sand-1",
    "mineral-grey-sand-2",
    "mineral-grey-sand-3",
    "mineral-purple-dirt-1",
    "mineral-purple-dirt-2",
    "mineral-purple-dirt-3",
    "mineral-purple-dirt-4",
    "mineral-purple-dirt-5",
    "mineral-purple-dirt-6",
    "mineral-purple-sand-1",
    "mineral-purple-sand-2",
    "mineral-purple-sand-3",
    "mineral-red-dirt-1",
    "mineral-red-dirt-2",
    "mineral-red-dirt-3",
    "mineral-red-dirt-4",
    "mineral-red-dirt-5",
    "mineral-red-dirt-6",
    "mineral-red-sand-1",
    "mineral-red-sand-2",
    "mineral-red-sand-3",
    "mineral-tan-dirt-1",
    "mineral-tan-dirt-2",
    "mineral-tan-dirt-3",
    "mineral-tan-dirt-4",
    "mineral-tan-dirt-5",
    "mineral-tan-dirt-6",
    "mineral-tan-sand-1",
    "mineral-tan-sand-2",
    "mineral-tan-sand-3",
    "mineral-violet-dirt-1",
    "mineral-violet-dirt-2",
    "mineral-violet-dirt-3",
    "mineral-violet-dirt-4",
    "mineral-violet-dirt-5",
    "mineral-violet-dirt-6",
    "mineral-violet-sand-1",
    "mineral-violet-sand-2",
    "mineral-violet-sand-3",
    "mineral-white-dirt-1",
    "mineral-white-dirt-2",
    "mineral-white-dirt-3",
    "mineral-white-dirt-4",
    "mineral-white-dirt-5",
    "mineral-white-dirt-6",
    "mineral-white-sand-1",
    "mineral-white-sand-2",
    "mineral-white-sand-3",
    "vegetation-blue-grass-1",
    "vegetation-blue-grass-2",
    "vegetation-green-grass-1",
    "vegetation-green-grass-2",
    "vegetation-green-grass-3",
    "vegetation-green-grass-4",
    "vegetation-mauve-grass-1",
    "vegetation-mauve-grass-2",
    "vegetation-olive-grass-1",
    "vegetation-olive-grass-2",
    "vegetation-orange-grass-1",
    "vegetation-orange-grass-2",
    "vegetation-purple-grass-1",
    "vegetation-purple-grass-2",
    "vegetation-red-grass-1",
    "vegetation-red-grass-2",
    "vegetation-turquoise-grass-1",
    "vegetation-turquoise-grass-2",
    "vegetation-violet-grass-1",
    "vegetation-violet-grass-2",
    "vegetation-yellow-grass-1",
    "vegetation-yellow-grass-2",
    "volcanic-blue-heat-1",
    "volcanic-blue-heat-2",
    "volcanic-blue-heat-3",
    "volcanic-blue-heat-4",
    "volcanic-green-heat-1",
    "volcanic-green-heat-2",
    "volcanic-green-heat-3",
    "volcanic-green-heat-4",
    "volcanic-orange-heat-1",
    "volcanic-orange-heat-2",
    "volcanic-orange-heat-3",
    "volcanic-orange-heat-4",
    "volcanic-purple-heat-1",
    "volcanic-purple-heat-2",
    "volcanic-purple-heat-3",
    "volcanic-purple-heat-4",
  }) do
    BI_Functions.lib.remove_from_blueprint(tile)
  end
end

--- Adds Solar Farm, Solar Plant, Musk Floor, Bio Accumulator and Substation to Tech tree
if BI.Settings.BI_Solar_Additions then
  if data.raw.technology["bob-solar-energy-2"] then
    thxbob.lib.tech.add_recipe_unlock("bob-electric-energy-accumulators-3", "bi-bio-accumulator")
    thxbob.lib.tech.add_recipe_unlock("electric-energy-distribution-2", "bi-large-substation")
    thxbob.lib.tech.add_recipe_unlock("bob-solar-energy-2", "bi-bio-solar-farm")
    thxbob.lib.tech.add_recipe_unlock("bob-solar-energy-2", "bi-solar-boiler-panel")
    --~ thxbob.lib.tech.add_recipe_unlock("bob-solar-energy-2", "bi-solar-boiler")
  else
    thxbob.lib.tech.add_recipe_unlock("electric-energy-accumulators", "bi-bio-accumulator")
    thxbob.lib.tech.add_recipe_unlock("electric-energy-distribution-2", "bi-large-substation")
    thxbob.lib.tech.add_recipe_unlock("solar-energy", "bi-bio-solar-farm")
    thxbob.lib.tech.add_recipe_unlock("solar-energy", "bi-solar-boiler-panel")
    --~ thxbob.lib.tech.add_recipe_unlock("solar-energy", "bi-solar-boiler")
  end

  if data.raw.technology["bob-solar-energy-3"] then
    thxbob.lib.tech.add_recipe_unlock("bob-solar-energy-3", "bi-solar-mat")
  else
    thxbob.lib.tech.add_recipe_unlock("solar-energy", "bi-solar-mat")
  end

  --- Electric redo if Bob' Electric
  -- Huge Electric Pole
  if data.raw.item["tinned-copper-cable"] then
    thxbob.lib.recipe.remove_ingredient("bi-wooden-pole-huge", "wood")
    thxbob.lib.recipe.add_new_ingredient("bi-wooden-pole-huge", {
      type = "item",
      name = "tinned-copper-cable",
      amount = 15}
    )
  end

  -- Solar Farm
  if data.raw.item["solar-panel-large"] then
    thxbob.lib.recipe.remove_ingredient("bi-bio-solar-farm", "solar-panel")
    thxbob.lib.recipe.add_new_ingredient("bi-bio-solar-farm", {
      type = "item",
      name = "solar-panel-large",
      amount = 30}
    )
  end

  -- Huge Sub Station
  if data.raw.item["substation-3"] then
    thxbob.lib.recipe.remove_ingredient("bi-large-substation", "substation")
    thxbob.lib.recipe.add_new_ingredient("bi-large-substation", {
      type = "item",
      name = "substation-3",
      amount = 6}
    )
  end

  if data.raw.item["electrum-alloy"] then
    thxbob.lib.recipe.remove_ingredient("bi-large-substation", "steel-plate")
    thxbob.lib.recipe.add_new_ingredient("bi-large-substation", {
      type = "item",
      name = "electrum-alloy",
      amount = 10}
    )
  end

  -- Huge Accumulator
  if data.raw.item["large-accumulator-2"] then
    thxbob.lib.recipe.remove_ingredient("bi-bio-accumulator", "accumulator")
    thxbob.lib.recipe.add_new_ingredient("bi-bio-accumulator", {
      type = "item",
      name = "large-accumulator",
      amount = 30}
    )
  end

  if data.raw.item["aluminium-plate"] then
    thxbob.lib.recipe.remove_ingredient("bi-bio-accumulator", "copper-cable")
    thxbob.lib.recipe.add_new_ingredient("bi-bio-accumulator", {
      type = "item",
      name = "aluminium-plate",
      amount = 50}
    )
  end

  -- Solar Mat
  if data.raw.item["aluminium-plate"] then
    thxbob.lib.recipe.remove_ingredient("bi-solar-mat", "steel-plate")
    thxbob.lib.recipe.add_new_ingredient("bi-solar-mat", {
      type = "item",
      name = "aluminium-plate",
      amount = 1}
    )
  end

  if data.raw.item["silicon-wafer"] then
    thxbob.lib.recipe.remove_ingredient("bi-solar-mat", "copper-cable")
    thxbob.lib.recipe.add_new_ingredient("bi-solar-mat", {
      type = "item",
      name = "silicon-wafer",
      amount = 4}
    )
  end

  -- Solar Boiler / Plant
  if data.raw.item["angels-electric-boiler"] then
    thxbob.lib.recipe.remove_ingredient("bi-solar-boiler-panel", "boiler")
    thxbob.lib.recipe.add_new_ingredient("bi-solar-boiler-panel", {
      type = "item",
      name = "angels-electric-boiler",
      amount = 1}
    )
    --~ thxbob.lib.recipe.remove_ingredient ("bi-solar-boiler", "boiler")
    --~ thxbob.lib.recipe.add_new_ingredient ("bi-solar-boiler", {type = "item", name = "angels-electric-boiler", amount = 1})
  end
end

require("prototypes.Bio_Farm.compatible_recipes") -- Bob and Angels mesh
require("prototypes.Bio_Farm.technology2")

if BI.Settings.BI_Bio_Fuel or mods["Natural_Evolution_Buildings"] then
  thxbob.lib.tech.add_recipe_unlock("bi-tech-advanced-biotechnology", "bi-purified-air-2")
end

-- Adds Bio recipes
if BI.Settings.BI_Bio_Fuel then
  thxbob.lib.tech.add_recipe_unlock("bi-tech-advanced-biotechnology", "bi-bio-reactor")
  thxbob.lib.tech.add_recipe_unlock("bi-tech-advanced-biotechnology", "bi-cellulose-1")
  thxbob.lib.tech.add_recipe_unlock("bi-tech-advanced-biotechnology", "bi-cellulose-2")
  thxbob.lib.tech.add_recipe_unlock("bi-tech-advanced-biotechnology", "bi-biomass-1")
  -- "bi-biomass-2" is more advanced than "bi-biomass-3"!
  thxbob.lib.tech.add_recipe_unlock("bi-tech-advanced-biotechnology", "bi-biomass-3")
  thxbob.lib.tech.add_recipe_unlock("bi-tech-advanced-biotechnology", "bi-biomass-2")
  thxbob.lib.tech.add_recipe_unlock("bi-tech-advanced-biotechnology", "bi-battery")
  thxbob.lib.tech.add_recipe_unlock("bi-tech-advanced-biotechnology", "bi-biomass-conversion-1")
  thxbob.lib.tech.add_recipe_unlock("bi-tech-advanced-biotechnology", "bi-biomass-conversion-2")
  thxbob.lib.tech.add_recipe_unlock("bi-tech-advanced-biotechnology", "bi-biomass-conversion-3")
  thxbob.lib.tech.add_recipe_unlock("bi-tech-advanced-biotechnology", "bi-biomass-conversion-4")
  thxbob.lib.tech.add_recipe_unlock("bi-tech-advanced-biotechnology", "bi-acid")
  thxbob.lib.tech.add_recipe_unlock("bi-tech-advanced-biotechnology", "bi-bio-boiler")

  -- Blacklist bioreactor in Assembler Pipe Passthrough
  if mods["assembler-pipe-passthrough"] then
    appmod.blacklist['bi-bio-reactor'] = true
  end

  if mods["angelspetrochem"] then
    thxbob.lib.tech.add_recipe_unlock("bi-tech-advanced-biotechnology", "bi-sulfur-angels")
  else
    thxbob.lib.tech.add_recipe_unlock("bi-tech-advanced-biotechnology", "bi-sulfur")
  end
  thxbob.lib.recipe.add_new_ingredient("bi-adv-fertiliser-1", {type = "fluid", name = "bi-biomass", amount = 10})
  thxbob.lib.recipe.add_new_ingredient("bi-adv-fertiliser-2", {type = "fluid", name = "bi-biomass", amount = 10})
else
  thxbob.lib.recipe.add_new_ingredient("bi-adv-fertiliser-1", {type = "item", name = "fertiliser", amount = 50})
  thxbob.lib.recipe.remove_ingredient ("bi-adv-fertiliser-2", "fertiliser")
  thxbob.lib.recipe.add_new_ingredient("bi-adv-fertiliser-2", {type = "item", name = "fertiliser", amount = 30})
end


--- if the Alien Artifact is in the game, use if for some recipes
if data.raw.item["alien-artifact"] then
  --- Advanced Fertiliser will use Alien Artifact
  thxbob.lib.recipe.remove_ingredient("bi-adv-fertiliser-1", "bi-biomass")
  thxbob.lib.recipe.add_new_ingredient("bi-adv-fertiliser-1", {
    type = "item",
    name = "alien-artifact",
    amount = 5}
  )
  thxbob.lib.tech.add_recipe_unlock("bi-tech-advanced-biotechnology", "bi-adv-fertiliser-1")
end


------- Adds a Mk3 recipe for wood if you're playing with Natural Evolution Buildings
if mods["Natural_Evolution_Buildings"] then
  thxbob.lib.recipe.remove_ingredient("bi-adv-fertiliser-1", "bi-biomass")
  thxbob.lib.recipe.remove_ingredient("bi-adv-fertiliser-1", "alien-artifact")
  thxbob.lib.recipe.add_new_ingredient("bi-adv-fertiliser-1", {
    type = "fluid",
    name = "NE_enhanced-nutrient-solution",
    amount = 50}
  )
end


------------ Support for Bob's Greenhouse
if data.raw["item"]["bob-greenhouse"] then
  data.raw["item"]["seedling"].place_result = "seedling"
  data.raw["item"]["seedling"].icon = ICONPATH .. "Seedling.png"
  data.raw["item"]["seedling"].icon_size = 32
  data.raw["item"]["fertiliser"].icon = ICONPATH .. "fertiliser_32.png"
  data.raw["item"]["fertiliser"].icon_size = 32

  if BioInd.AB_tiles() then
    data.raw["item"]["fertiliser"].place_as_tile = {
      result = "vegetation-green-grass-3",
      condition_size = 1,
      condition = { "water-tile" }
    }
  else
    data.raw["item"]["fertiliser"].place_as_tile = {
      result = "grass-3",
      condition_size = 1,
      condition = { "water-tile" }
    }
  end
end


if settings.startup["angels-use-angels-barreling"] and settings.startup["angels-use-angels-barreling"].value then
  data.raw.technology["bi-tech-fertiliser"].prerequisites = {
    "bi-tech-bio-farming",
    -- AND (
    "water-treatment", -- sulfur
    -- OR
    "angels-fluid-barreling", -- barreling (needed 'water-treatment' as prerequisites)
    -- )
  }
end


----- Angels Merge ----
if mods["angelspetrochem"] then
    data.raw.item["pellet-coke"].icon = "__angelspetrochem__/graphics/icons/pellet-coke.png"
    data.raw.item["pellet-coke"].icon_size = 32
    data.raw.item["pellet-coke"].fuel_acceleration_multiplier = 1.1
    data.raw.item["pellet-coke"].fuel_top_speed_multiplier = 1.2

    data.raw.recipe["pellet-coke"].category = "biofarm-mod-smelting"
    thxbob.lib.tech.remove_recipe_unlock ("angels-coal-processing-2", "pellet-coke")
    thxbob.lib.tech.add_recipe_unlock("angels-coal-cracking", "pellet-coke")
end


if data.raw.item["ash"] and mods["pycoalprocessing"] then
  -- # grep -E "(name|result)\s*=\s*.bi-ash" -rn *

  -- Bio_Farm/compatible_recipes.lua:30:      {type = "item", name = "bi-ash", amount = 10}
  thxbob.lib.recipe.replace_ingredient ("bi-fertiliser-2", "bi-ash", "ash")

  -- Bio_Farm/compatible_recipes.lua:201:       {type = "item", name = "bi-ash", amount = 40},
  if mods["angelsrefining"] then
    thxbob.lib.recipe.replace_ingredient ("bi-slag-slurry", "bi-ash", "ash")
  end

  -- Bio_Farm/recipe.lua:42:    {type = "item", name = "bi-ash", amount = 10},
  thxbob.lib.recipe.replace_ingredient ("bi-seed-2", "bi-ash", "ash")
  -- Bio_Farm/recipe.lua:144:   {type = "item", name = "bi-ash", amount = 10},
  thxbob.lib.recipe.replace_ingredient ("bi-seedling-2", "bi-ash", "ash")
  -- Bio_Farm/recipe.lua:251:   {type = "item", name = "bi-ash", amount = 10},
  thxbob.lib.recipe.replace_ingredient ("bi-logs-2", "bi-ash", "ash")

  -- Bio_Farm/recipe.lua:451:       result = "bi-ash",
  data.raw.recipe["bi-ash-1"].result = "ash"
  -- Bio_Farm/recipe.lua:471:       result = "bi-ash",
  data.raw.recipe["bi-ash-2"].result = "ash"

  -- Bio_Farm/recipe.lua:609:   {type = "item", name = "bi-ash", amount = 2},
  thxbob.lib.recipe.replace_ingredient ("bi-stone-brick", "bi-ash", "ash")
  -- Bio_Farm/recipe.lua:746:   {type = "item", name = "bi-ash", amount = 10}
  thxbob.lib.recipe.replace_ingredient ("bi-fertiliser-1", "bi-ash", "ash")

  if BI.Settings.BI_Bio_Fuel then
    -- Bio_Fuel/recipe.lua:209:     {type = "item", name = "bi-ash", amount = 10},
    thxbob.lib.recipe.replace_ingredient ("bi-biomass-2", "bi-ash", "ash")
    -- Bio_Fuel/recipe.lua:401:     {type = "item", name = "bi-ash", amount = 10},
    thxbob.lib.recipe.replace_ingredient ("bi-sulfur", "bi-ash", "ash")
    -- Bio_Fuel/recipe.lua:425:     {type = "item", name = "bi-ash", amount = 10},
    thxbob.lib.recipe.replace_ingredient ("bi-sulfur-angels", "bi-ash", "ash")
  end

  -- Bio_Farm/item.lua:105:   name = "bi-ash",
  data.raw.item["bi-ash"] = nil
  data.raw.recipe["bi-ash-1"].icon = "__pycoalprocessinggraphics__/graphics/icons/ash.png"
  data.raw.recipe["bi-ash-1"].icon_size = 32
  data.raw.recipe["bi-ash-2"].icon = "__pycoalprocessinggraphics__/graphics/icons/ash.png"
  data.raw.recipe["bi-ash-2"].icon_size = 32

  -- Use ash icon from pycoalprocessing in icons of recipes using ash
  data.raw.recipe["bi-seed-2"].icon = ICONPATH .. "py_bio_seed2.png"
  data.raw.recipe["bi-seed-2"].icon_size = 32
  data.raw.recipe["bi-seedling-2"].icon = ICONPATH .. "py_Seedling2.png"
  data.raw.recipe["bi-seedling-2"].icon_size = 32
  data.raw.recipe["bi-logs-2"].icon = ICONPATH .. "py_raw-wood-mk2.png"
  data.raw.recipe["bi-logs-2"].icon_size = 32
  data.raw.recipe["bi-ash-1"].icon = ICONPATH .. "py_ash_raw-wood.png"
  data.raw.recipe["bi-ash-1"].icon_size = 32
  data.raw.recipe["bi-ash-2"].icon = ICONPATH .. "py_ash_woodpulp.png"
  data.raw.recipe["bi-ash-2"].icon_size = 32
  data.raw.recipe["bi-stone-brick"].icon = ICONPATH .. "py_bi_stone_brick.png"
  data.raw.recipe["bi-stone-brick"].icon_size = 32
  data.raw.recipe["bi-sulfur"].icon = ICONPATH .. "py_bio_sulfur.png"
  data.raw.recipe["bi-sulfur"].icon_size = 32
end

----- If Bob's bobrevamp, then ----
if mods["bobrevamp"] then
  thxbob.lib.tech.remove_recipe_unlock ("bi-tech-coal-processing-1", "bi-solid-fuel")
  thxbob.lib.tech.add_recipe_unlock("solid-fuel", "bi-solid-fuel")
end

----- If Simple Silicon is active, add solar cell to Musk floor (solar mat) recipe
if mods["SimpleSilicon"] then
    thxbob.lib.recipe.add_new_ingredient("bi-solar-mat", {
    type = "item",
    name = "SiSi-solar-cell",
    amount = 1
  })
end


--- Enable Productivity in Recipies
BI_Functions.lib.allow_productivity("bi-seed-1")
BI_Functions.lib.allow_productivity("bi-seed-2")
BI_Functions.lib.allow_productivity("bi-seed-3")
BI_Functions.lib.allow_productivity("bi-seed-4")

BI_Functions.lib.allow_productivity("bi-seedling-1")
BI_Functions.lib.allow_productivity("bi-seedling-2")
BI_Functions.lib.allow_productivity("bi-seedling-3")
BI_Functions.lib.allow_productivity("bi-seedling-4")

BI_Functions.lib.allow_productivity("bi-logs-1")
BI_Functions.lib.allow_productivity("bi-logs-2")
BI_Functions.lib.allow_productivity("bi-logs-3")
BI_Functions.lib.allow_productivity("bi-logs-4")

BI_Functions.lib.allow_productivity("bi-stone-brick")
BI_Functions.lib.allow_productivity("bi-crushed-stone-1")
BI_Functions.lib.allow_productivity("bi-crushed-stone-2")
BI_Functions.lib.allow_productivity("bi-crushed-stone-3")
BI_Functions.lib.allow_productivity("bi-crushed-stone-4")
BI_Functions.lib.allow_productivity("bi-crushed-stone-5")

BI_Functions.lib.allow_productivity("bi-resin-pulp")
BI_Functions.lib.allow_productivity("bi-press-wood")
BI_Functions.lib.allow_productivity("bi-resin-wood")
BI_Functions.lib.allow_productivity("bi-woodpulp")
BI_Functions.lib.allow_productivity("bi-wood-from-pulp")

BI_Functions.lib.allow_productivity("bi-liquid-air")
BI_Functions.lib.allow_productivity("bi-nitrogen")

BI_Functions.lib.allow_productivity("bi-biomass-1")
BI_Functions.lib.allow_productivity("bi-biomass-2")
BI_Functions.lib.allow_productivity("bi-biomass-3")

BI_Functions.lib.allow_productivity("bi-biomass-conversion-1")
BI_Functions.lib.allow_productivity("bi-biomass-conversion-2")
BI_Functions.lib.allow_productivity("bi-biomass-conversion-3")
BI_Functions.lib.allow_productivity("bi-biomass-conversion-4")

BI_Functions.lib.allow_productivity("bi-battery")
BI_Functions.lib.allow_productivity("bi-acid")
BI_Functions.lib.allow_productivity("bi-sulfur")
BI_Functions.lib.allow_productivity("bi-sulfur-angels")
BI_Functions.lib.allow_productivity("bi-plastic-1")
BI_Functions.lib.allow_productivity("bi-plastic-2")
BI_Functions.lib.allow_productivity("bi-cellulose-1")
BI_Functions.lib.allow_productivity("bi-cellulose-2")
