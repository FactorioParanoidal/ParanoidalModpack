--data.raw["technology"]["xxx"].prerequisites = {"xxx", "xxx"}

--bobmods.lib.tech.add_recipe_unlock("technology", "recipe")
--bobmods.lib.tech.remove_recipe_unlock("technology", "recipe")

--bobmods.lib.tech.replace_prerequisite("technology", "old", "new")
--bobmods.lib.tech.add_prerequisite("technology", "prerequisite")
--bobmods.lib.tech.remove_prerequisite("technology", "prerequisite")

--bobmods.lib.recipe.add_ingredient("recipe", {"ingredient", 2})
--bobmods.lib.recipe.set_energy_required("recipe", 2)
--bobmods.lib.recipe.set_ingredient("recipe", {"item", 20})
--bobmods.lib.recipe.set_result("recipe", {name = "item", type = "item", amount = 5})
--###############################################################################################
--замена tile для concrete-brick
local concrete_brick_fix = table.deepcopy(data.raw["tile"]["refined-concrete"])

concrete_brick_fix.name = "concrete-brick-fix"
concrete_brick_fix.minable = {mining_time = 0.1, result = "concrete-brick"}
--concrete_brick_fix.layer = "100"
concrete_brick_fix.variants.material_background = 
{
    picture = "__SingleColorTerrain__/graphics/concrete/concrete.png",
    count = 8,
    hr_version =
    {
      picture = "__SingleColorTerrain__/graphics/concrete/hr-concrete.png",
      count = 8,
      scale = 0.5
    }
}

data:extend{concrete_brick_fix}

data.raw["item"]["concrete-brick"].place_as_tile.result = "concrete-brick-fix"
-------------------------------------------------------------------------------------------------
--[[
--замена tile для concrete-brick
local concrete_brick_fix = table.deepcopy(data.raw["tile"]["refined-concrete"])

concrete_brick_fix.name = "concrete-brick-fix"
concrete_brick_fix.minable = {mining_time = 0.1, result = "concrete-brick"}
--concrete_brick_fix.layer = "100"
concrete_brick_fix.variants.material_background = 
{
    picture = "__SingleColorTerrain__/graphics/concrete/concrete.png",
    count = 8,
    hr_version =
    {
      picture = "__SingleColorTerrain__/graphics/concrete/hr-concrete.png",
      count = 8,
      scale = 0.5
    }
}

data:extend{concrete_brick_fix}

data.raw["item"]["concrete-brick"].place_as_tile.result = "concrete-brick-fix"
]]
--###############################################################################################
--подкрутка мода для интеграции в параноидал
if mods["Transport_Drones"] then
--подкрутка технологий
bobmods.lib.tech.remove_prerequisite("transport-system", "engine")
bobmods.lib.tech.remove_prerequisite("transport-system", "angels-oil-processing")
bobmods.lib.tech.add_prerequisite("transport-system", "steel-processing")
bobmods.lib.tech.add_prerequisite("transport-system", "angels-fluid-control")
bobmods.lib.tech.add_prerequisite("transport-system", "basic-chemistry-2")

bobmods.lib.tech.remove_science_pack("transport-system", "logistic-science-pack")
-------------------------------------------------------------------------------------------------
--поправка технологий
bobmods.lib.tech.add_prerequisite ("transport-drone-speed-1", "logistic-science-pack")
bobmods.lib.tech.add_prerequisite ("transport-drone-capacity-1", "logistic-science-pack")
-------------------------------------------------------------------------------------------------
--подкрутка рецептов
--депо
bobmods.lib.recipe.add_ingredient("fuel-depot", {"angels-storage-tank-3", 4})
bobmods.lib.recipe.add_ingredient("fuel-depot", {"valve-underflow", 1})
bobmods.lib.recipe.add_ingredient("fuel-depot", {"basic-structure-components", 5})
bobmods.lib.recipe.add_ingredient("fuel-depot", {"electronic-circuit", 10})

bobmods.lib.recipe.set_ingredient("fuel-depot", {"steel-plate", 30})

bobmods.lib.recipe.remove_ingredient("fuel-depot", "iron-plate")
bobmods.lib.recipe.remove_ingredient("fuel-depot", "iron-gear-wheel")
-------------------------------------------------------------------------------------------------
--депо запроса
bobmods.lib.recipe.add_ingredient("request-depot", {"basic-structure-components", 1})
bobmods.lib.recipe.add_ingredient("request-depot", {"electronic-circuit", 10})
bobmods.lib.recipe.add_ingredient("request-depot", {"steel-chest", 1})
bobmods.lib.recipe.add_ingredient("request-depot", {"steel-plate", 10})

bobmods.lib.recipe.remove_ingredient("request-depot", "iron-plate")
bobmods.lib.recipe.remove_ingredient("request-depot", "iron-gear-wheel")
bobmods.lib.recipe.remove_ingredient("request-depot", "iron-stick")
-------------------------------------------------------------------------------------------------
--депо снабжения
bobmods.lib.recipe.add_ingredient("supply-depot", {"basic-structure-components", 1})
bobmods.lib.recipe.add_ingredient("supply-depot", {"electronic-circuit", 10})
bobmods.lib.recipe.add_ingredient("supply-depot", {"steel-chest", 2})
bobmods.lib.recipe.add_ingredient("supply-depot", {"steel-plate", 10})

bobmods.lib.recipe.remove_ingredient("supply-depot", "iron-plate")
bobmods.lib.recipe.remove_ingredient("supply-depot", "iron-gear-wheel")
bobmods.lib.recipe.remove_ingredient("supply-depot", "iron-stick")
-------------------------------------------------------------------------------------------------
--депо буфер
bobmods.lib.recipe.add_ingredient("buffer-depot", {"basic-structure-components", 1})
bobmods.lib.recipe.add_ingredient("buffer-depot", {"electronic-circuit", 10})
bobmods.lib.recipe.add_ingredient("buffer-depot", {"steel-chest", 1})
bobmods.lib.recipe.add_ingredient("buffer-depot", {"steel-plate", 10})

bobmods.lib.recipe.remove_ingredient("buffer-depot", "iron-plate")
bobmods.lib.recipe.remove_ingredient("buffer-depot", "iron-gear-wheel")
bobmods.lib.recipe.remove_ingredient("buffer-depot", "iron-stick")
-------------------------------------------------------------------------------------------------
--депо жидкость
bobmods.lib.recipe.add_ingredient("fluid-depot", {"basic-structure-components", 1})
bobmods.lib.recipe.add_ingredient("fluid-depot", {"electronic-circuit", 10})
bobmods.lib.recipe.add_ingredient("fluid-depot", {"angels-storage-tank-3", 1})
bobmods.lib.recipe.add_ingredient("fluid-depot", {"steel-plate", 10})

bobmods.lib.recipe.remove_ingredient("fluid-depot", "iron-plate")
bobmods.lib.recipe.remove_ingredient("fluid-depot", "iron-gear-wheel")
bobmods.lib.recipe.remove_ingredient("fluid-depot", "iron-stick")
-------------------------------------------------------------------------------------------------
--дорога
bobmods.lib.recipe.add_ingredient("road", {"stone", 20})
bobmods.lib.recipe.add_ingredient("road", {"coal-crushed", 10})
bobmods.lib.recipe.add_ingredient("road", {"resin", 10})

bobmods.lib.recipe.remove_ingredient("road", "stone-brick")
bobmods.lib.recipe.remove_ingredient("road", "coal")

data.raw.recipe.road.energy_required = 5
data.raw.recipe.road.category = "smelting"
-------------------------------------------------------------------------------------------------
--машинка
bobmods.lib.recipe.add_ingredient("transport-drone", {"steel-bearing", 4})
bobmods.lib.recipe.add_ingredient("transport-drone", {"electronic-circuit", 3})
bobmods.lib.recipe.add_ingredient("transport-drone", {"simple-io", 1})
bobmods.lib.recipe.add_ingredient("transport-drone", {"motor", 3})

bobmods.lib.recipe.set_ingredient("transport-drone", {"steel-plate", 10})

bobmods.lib.recipe.remove_ingredient("transport-drone", "engine-unit")
bobmods.lib.recipe.remove_ingredient("transport-drone", "iron-gear-wheel")
-------------------------------------------------------------------------------------------------
--settings.startup["fuel-fluid"].value = "gas-hydrogen"
end
--###############################################################################################
-- добавляем зависимости в техологии для последовательности развития
bobmods.lib.tech.add_prerequisite ("electronics-machine-1", "steel-processing")
bobmods.lib.tech.add_prerequisite ("flat-lamp-t", "electronics")
bobmods.lib.tech.add_prerequisite ("radar", "electronics")
bobmods.lib.tech.add_prerequisite ("electric-lab", "electronics")
bobmods.lib.tech.add_prerequisite ("bi-tech-bio-farming", "ore-crushing")
bobmods.lib.tech.add_prerequisite ("logistic-science-pack", "electronics")
bobmods.lib.tech.add_prerequisite ("logistic-science-pack", "angels-bronze-smelting-1")
bobmods.lib.tech.add_prerequisite ("bio-wood-processing", "bi-tech-bio-farming")
bobmods.lib.tech.add_prerequisite ("angels-metallurgy-1", "ore-crushing")
bobmods.lib.tech.add_prerequisite ("angels-lead-smelting-1", "basic-chemistry-2")
--зеленые банки к зеленым банкам
bobmods.lib.tech.add_prerequisite ("warehouse-research", "logistic-science-pack")
bobmods.lib.tech.add_prerequisite ("OilBurning", "logistic-science-pack")
bobmods.lib.tech.add_prerequisite ("armor-absorb-5", "logistic-science-pack")
bobmods.lib.tech.add_prerequisite ("steel-axe-2", "logistic-science-pack")
bobmods.lib.tech.add_prerequisite ("bob-area-drills-1", "logistic-science-pack")
bobmods.lib.tech.add_prerequisite ("fluid-handling", "logistic-science-pack")
bobmods.lib.tech.add_prerequisite ("miniloader", "logistic-science-pack")
bobmods.lib.tech.add_prerequisite ("remelting-alloy-mixer-1", "logistic-science-pack")
bobmods.lib.tech.add_prerequisite ("chemical-processing-2", "logistic-science-pack")
bobmods.lib.tech.add_prerequisite ("angels-ironworks-1", "logistic-science-pack")
--убираем некоторые зависимости
bobmods.lib.tech.remove_prerequisite("angels-metallurgy-1", "electricity")
bobmods.lib.tech.remove_prerequisite("angels-nickel-smelting-1", "ore-crushing")
bobmods.lib.tech.remove_prerequisite("angels-lead-smelting-1", "ore-crushing")
bobmods.lib.tech.remove_prerequisite("angels-lead-smelting-1", "basic-chemistry")
--убираем рецепты из технологий
bobmods.lib.tech.remove_recipe_unlock("angels-stone-smelting-1", "angels-stone-pipe-casting")
bobmods.lib.tech.remove_recipe_unlock("angels-stone-smelting-1", "angels-stone-pipe-to-ground-casting")
--перенос электролиза дальше по дереву
bobmods.lib.tech.remove_recipe_unlock("basic-chemistry", "angels-electrolyser")
bobmods.lib.tech.remove_recipe_unlock("basic-chemistry", "dirt-water-separation")
bobmods.lib.tech.remove_recipe_unlock("basic-chemistry", "catalyst-metal-carrier")
bobmods.lib.tech.remove_recipe_unlock("basic-chemistry", "catalyst-metal-red")

bobmods.lib.tech.add_recipe_unlock("basic-chemistry-2", "angels-electrolyser")
bobmods.lib.tech.add_recipe_unlock("basic-chemistry-2", "dirt-water-separation")
bobmods.lib.tech.add_recipe_unlock("basic-chemistry-2", "catalyst-metal-carrier")
bobmods.lib.tech.add_recipe_unlock("basic-chemistry-2", "catalyst-metal-red")
--###############################################################################################
--целюлозное волокно в переработку древесины
data.raw["recipe"]["cellulose-fiber-raw-wood"].normal.enabled = false
data.raw["recipe"]["cellulose-fiber-raw-wood"].expensive.enabled = false
bobmods.lib.tech.add_recipe_unlock("bio-wood-processing", "cellulose-fiber-raw-wood") 
-------------------------------------------------------------------------------------------------
--ремкомплект в электричество
data.raw["recipe"]["repair-pack"].enabled = false
bobmods.lib.tech.add_recipe_unlock("electricity", "repair-pack") 
-------------------------------------------------------------------------------------------------
--конденсатор в электричество
data.raw["recipe"]["condensator"].enabled = false
bobmods.lib.tech.add_recipe_unlock("electricity", "condensator") 
-------------------------------------------------------------------------------------------------
--паровой манипулятор в автоматику
data.raw["recipe"]["steam-inserter"].enabled = false
bobmods.lib.tech.add_recipe_unlock("basic-automation", "steam-inserter") 
-------------------------------------------------------------------------------------------------
--стекло из кварца в сортировку
data.raw["recipe"]["quartz-glass"].normal.enabled = false
data.raw["recipe"]["quartz-glass"].expensive.enabled = false
bobmods.lib.tech.add_recipe_unlock("ore-crushing", "quartz-glass") 
-------------------------------------------------------------------------------------------------
--стекло из дробленки сортировку
bobmods.lib.tech.add_recipe_unlock("ore-crushing", "glass-from-ore4") 
--###############################################################################################
--скрываем рецепты шариков. технология в prototypes/micro-fix.lua
data.raw["recipe"]["alien-artifact-red-from-basic"].enabled = false
data.raw["recipe"]["alien-artifact-orange-from-basic"].enabled = false
data.raw["recipe"]["alien-artifact-yellow-from-basic"].enabled = false
data.raw["recipe"]["alien-artifact-green-from-basic"].enabled = false
data.raw["recipe"]["alien-artifact-blue-from-basic"].enabled = false
data.raw["recipe"]["alien-artifact-purple-from-basic"].enabled = false

data.raw["recipe"]["alien-artifact-from-small"].enabled = false
data.raw["recipe"]["alien-artifact-red-from-small"].enabled = false
data.raw["recipe"]["alien-artifact-orange-from-small"].enabled = false
data.raw["recipe"]["alien-artifact-yellow-from-small"].enabled = false
data.raw["recipe"]["alien-artifact-green-from-small"].enabled = false
data.raw["recipe"]["alien-artifact-blue-from-small"].enabled = false
data.raw["recipe"]["alien-artifact-purple-from-small"].enabled = false
-------------------------------------------------------------------------------------------------
--перемещаем рецепты и предметы больших шариков куда следует
data.raw["recipe"]["alien-artifact-red-from-basic"].group = "bio-processing-alien"
data.raw["recipe"]["alien-artifact-orange-from-basic"].group = "bio-processing-alien"
data.raw["recipe"]["alien-artifact-yellow-from-basic"].group = "bio-processing-alien"
data.raw["recipe"]["alien-artifact-green-from-basic"].group = "bio-processing-alien"
data.raw["recipe"]["alien-artifact-blue-from-basic"].group = "bio-processing-alien"
data.raw["recipe"]["alien-artifact-purple-from-basic"].group = "bio-processing-alien"

data.raw["recipe"]["alien-artifact-red-from-basic"].subgroup = "bio-processing-alien-large"
data.raw["recipe"]["alien-artifact-orange-from-basic"].subgroup = "bio-processing-alien-large"
data.raw["recipe"]["alien-artifact-yellow-from-basic"].subgroup = "bio-processing-alien-large"
data.raw["recipe"]["alien-artifact-green-from-basic"].subgroup = "bio-processing-alien-large"
data.raw["recipe"]["alien-artifact-blue-from-basic"].subgroup = "bio-processing-alien-large"
data.raw["recipe"]["alien-artifact-purple-from-basic"].subgroup = "bio-processing-alien-large"

data.raw["item"]["alien-artifact"].group = "bio-processing-alien"
data.raw["item"]["alien-artifact-red"].group = "bio-processing-alien"
data.raw["item"]["alien-artifact-orange"].group = "bio-processing-alien"
data.raw["item"]["alien-artifact-yellow"].group = "bio-processing-alien"
data.raw["item"]["alien-artifact-green"].group = "bio-processing-alien"
data.raw["item"]["alien-artifact-blue"].group = "bio-processing-alien"
data.raw["item"]["alien-artifact-purple"].group = "bio-processing-alien"

data.raw["item"]["alien-artifact"].subgroup = "bio-processing-alien-large"
data.raw["item"]["alien-artifact-red"].subgroup = "bio-processing-alien-large"
data.raw["item"]["alien-artifact-orange"].subgroup = "bio-processing-alien-large"
data.raw["item"]["alien-artifact-yellow"].subgroup = "bio-processing-alien-large"
data.raw["item"]["alien-artifact-green"].subgroup = "bio-processing-alien-large"
data.raw["item"]["alien-artifact-blue"].subgroup = "bio-processing-alien-large"
data.raw["item"]["alien-artifact-purple"].subgroup = "bio-processing-alien-large"
--###############################################################################################
-- замена иконки на технологии припоя
data.raw["technology"]["angels-solder-smelting-basic"].icon = "__reskins-library__/graphics/icons/shared/items/solder.png"
data.raw["technology"]["angels-solder-smelting-basic"].icon_size = 64
data.raw["technology"]["angels-solder-smelting-basic"].icon_mipmaps = 4
-------------------------------------------------------------------------------------------------
-- замена иконки рецепта дробленого камня из шлака 
data.raw["recipe"]["slag-processing-stone"].icon = "__Bio_Industries__/graphics/icons/crushed-stone.png"
data.raw["recipe"]["slag-processing-stone"].icon_size = 64
--data.raw["recipe"]["slag-processing-stone"].icon_mipmaps = 4
-------------------------------------------------------------------------------------------------
-- замена иконки на технологии "управление потоками в трубах"
data.raw["technology"]["angels-fluid-control"].icon = "__reskins-angels__/graphics/icons/petrochem/valve/valve-icon-base.png"
data.raw["technology"]["angels-fluid-control"].icon_size = 64
data.raw["technology"]["angels-fluid-control"].icon_mipmaps = 4
-------------------------------------------------------------------------------------------------
-- замена иконки свалки
data.raw["technology"]["zcs-trash-landfill"].icon = "__zzzparanoidal__/graphics/stockpile-icon.png"
--data.raw["technology"]["zcs-trash-landfill"].icon_size = 64
--data.raw["technology"]["zcs-trash-landfill"].icon_mipmaps = 4

data.raw["container"]["zcs-trash-landfill"].icon = "__zzzparanoidal__/graphics/stockpile-icon.png"
--data.raw["technology"]["zcs-trash-landfill"].icon_size = 64
--data.raw["technology"]["zcs-trash-landfill"].icon_mipmaps = 4

data.raw["item"]["zcs-trash-landfill"].icon = "__zzzparanoidal__/graphics/stockpile-icon.png"
--data.raw["item"]["zcs-trash-landfill"].icon_size = 64
--data.raw["item"]["zcs-trash-landfill"].icon_mipmaps = 4
--###############################################################################################
-- подкрутка чтобы сборщик1 мог собирать сам себя
data.raw["assembling-machine"]["assembling-machine-1"].ingredient_count = 5
-------------------------------------------------------------------------------------------------
-- подкрутка печек чтобы использовать рецепт со шлаком
data.raw["furnace"]["stone-furnace"].result_inventory_size = 2
data.raw["furnace"]["steel-furnace"].result_inventory_size = 2
data.raw["furnace"]["electric-furnace"].result_inventory_size = 2
data.raw["furnace"]["electric-furnace-2"].result_inventory_size = 2
data.raw["furnace"]["electric-furnace-3"].result_inventory_size = 2
data.raw["furnace"]["electric-steel-furnace"].result_inventory_size = 2
-------------------------------------------------------------------------------------------------
-- подкрутка рецепта погрузчика/разгрузчика
--bobmods.lib.recipe.replace_ingredient("railloader", "rail", "bi-rail-wood")
--bobmods.lib.recipe.replace_ingredient("railunloader", "rail", "bi-rail-wood")
--###############################################################################################
--нерфим плавку дробленки в печах 
--сапфирит
bobmods.lib.recipe.set_energy_required("angelsore1-crushed-smelting", 20)
bobmods.lib.recipe.set_ingredient("angelsore1-crushed-smelting", {"angels-ore1-crushed", 7})
bobmods.lib.recipe.set_result("angelsore1-crushed-smelting", {type="item", name="iron-plate", amount=4})
bobmods.lib.recipe.add_result("angelsore1-crushed-smelting", {"slag", 1})
--стиратит
bobmods.lib.recipe.set_energy_required("angelsore3-crushed-smelting", 20)
bobmods.lib.recipe.set_ingredient("angelsore3-crushed-smelting", {"angels-ore3-crushed", 7})
bobmods.lib.recipe.set_result("angelsore3-crushed-smelting", {type="item", name="copper-plate", amount=4})
bobmods.lib.recipe.add_result("angelsore3-crushed-smelting", {"slag", 1})
--рубит
bobmods.lib.recipe.set_energy_required("angelsore5-crushed-smelting", 20)
bobmods.lib.recipe.set_ingredient("angelsore5-crushed-smelting", {"angels-ore5-crushed", 7})
bobmods.lib.recipe.set_result("angelsore5-crushed-smelting", {type="item", name="lead-plate", amount=4})
bobmods.lib.recipe.add_result("angelsore5-crushed-smelting", {"slag", 1})
--бобмониум
bobmods.lib.recipe.set_energy_required("angelsore6-crushed-smelting", 20)
bobmods.lib.recipe.set_ingredient("angelsore6-crushed-smelting", {"angels-ore6-crushed", 7})
bobmods.lib.recipe.set_result("angelsore6-crushed-smelting", {type="item", name="tin-plate", amount=4})
bobmods.lib.recipe.add_result("angelsore6-crushed-smelting", {"slag", 1})
--кротиниум в prototypes/micro-fix.lua
-------------------------------------------------------------------------------------------------
--бафаем скорость первой сортировки
bobmods.lib.recipe.set_energy_required("angelsore1-crushed-processing", 2)
bobmods.lib.recipe.set_ingredient("angelsore1-crushed-processing", {"angels-ore1-crushed", 20})
bobmods.lib.recipe.set_result("angelsore1-crushed-processing", {name = "slag", type = "item", amount = 5})
bobmods.lib.recipe.set_result("angelsore1-crushed-processing", {name = "iron-ore", type = "item", amount = 10})
bobmods.lib.recipe.set_result("angelsore1-crushed-processing", {name = "copper-ore", type = "item", amount = 5})

bobmods.lib.recipe.set_energy_required("angelsore2-crushed-processing", 2)
bobmods.lib.recipe.set_ingredient("angelsore2-crushed-processing", {"angels-ore2-crushed", 20})
bobmods.lib.recipe.set_result("angelsore2-crushed-processing", {name = "slag", type = "item", amount = 5})
bobmods.lib.recipe.set_result("angelsore2-crushed-processing", {name = "iron-ore", type = "item", amount = 10})
bobmods.lib.recipe.set_result("angelsore2-crushed-processing", {name = "copper-ore", type = "item", amount = 5})

bobmods.lib.recipe.set_energy_required("angelsore3-crushed-processing", 2)
bobmods.lib.recipe.set_ingredient("angelsore3-crushed-processing", {"angels-ore3-crushed", 20})
bobmods.lib.recipe.set_result("angelsore3-crushed-processing", {name = "slag", type = "item", amount = 5})
bobmods.lib.recipe.set_result("angelsore3-crushed-processing", {name = "copper-ore", type = "item", amount = 10})
bobmods.lib.recipe.set_result("angelsore3-crushed-processing", {name = "iron-ore", type = "item", amount = 5})

bobmods.lib.recipe.set_energy_required("angelsore4-crushed-processing", 2)
bobmods.lib.recipe.set_ingredient("angelsore4-crushed-processing", {"angels-ore4-crushed", 20})
bobmods.lib.recipe.set_result("angelsore4-crushed-processing", {name = "slag", type = "item", amount = 5})
bobmods.lib.recipe.set_result("angelsore4-crushed-processing", {name = "copper-ore", type = "item", amount = 10})
bobmods.lib.recipe.set_result("angelsore4-crushed-processing", {name = "iron-ore", type = "item", amount = 5})

bobmods.lib.recipe.set_energy_required("angelsore5-crushed-processing", 2)
bobmods.lib.recipe.set_ingredient("angelsore5-crushed-processing", {"angels-ore5-crushed", 20})
bobmods.lib.recipe.set_result("angelsore5-crushed-processing", {name = "slag", type = "item", amount = 5})
bobmods.lib.recipe.set_result("angelsore5-crushed-processing", {name = "lead-ore", type = "item", amount = 10})
bobmods.lib.recipe.set_result("angelsore5-crushed-processing", {name = "nickel-ore", type = "item", amount = 5})

bobmods.lib.recipe.set_energy_required("angelsore6-crushed-processing", 2)
bobmods.lib.recipe.set_ingredient("angelsore6-crushed-processing", {"angels-ore6-crushed", 20})
bobmods.lib.recipe.set_result("angelsore6-crushed-processing", {name = "slag", type = "item", amount = 5})
bobmods.lib.recipe.set_result("angelsore6-crushed-processing", {name = "tin-ore", type = "item", amount = 10})
bobmods.lib.recipe.set_result("angelsore6-crushed-processing", {name = "quartz", type = "item", amount = 5})
-------------------------------------------------------------------------------------------------
--баф скорости дробления шлака
bobmods.lib.recipe.set_energy_required("slag-processing-stone", 2)
bobmods.lib.recipe.set_ingredient("slag-processing-stone", {"slag", 5})
bobmods.lib.recipe.set_result("slag-processing-stone", {"stone-crushed", 10})
--###############################################################################################
--крутим рельсы

--убираем био-рельсы
if mods["Bio_Industries"] then
data.raw["rail-planner"]["bi-rail-wood"].flags = {"hidden"}
data.raw["recipe"]["bi-rail-wood"].hidden = true
data.raw["rail-planner"]["bi-rail-wood-bridge"].flags = {"hidden"}
end
-------------------------------------------------------------------------------------------------
--делаем возможность обновления рельс и светофоров штатным путем
if mods["JunkTrain3"] then
data.raw["straight-rail"]["straight-scrap-rail"].next_upgrade = "straight-rail"
data.raw["curved-rail"]["curved-scrap-rail"].next_upgrade = "curved-rail"

data.raw["straight-rail"]["straight-scrap-rail"].fast_replaceable_group = "rail"
data.raw["curved-rail"]["curved-scrap-rail"].fast_replaceable_group = "rail"

data.raw["straight-rail"]["straight-rail"].fast_replaceable_group = "rail"
data.raw["curved-rail"]["curved-rail"].fast_replaceable_group = "rail"

data.raw["straight-rail"]["straight-scrap-rail"].collision_mask = {"item-layer", "object-layer", "rail-layer", "floor-layer", "water-tile"}
data.raw["curved-rail"]["curved-scrap-rail"].collision_mask = {"item-layer", "object-layer", "rail-layer", "floor-layer", "water-tile"}

data.raw["straight-rail"]["straight-rail"].collision_mask = {"item-layer", "object-layer", "rail-layer", "floor-layer", "water-tile"}
data.raw["curved-rail"]["curved-rail"].collision_mask = {"item-layer", "object-layer", "rail-layer", "floor-layer", "water-tile"}

data.raw["rail-signal"]["rail-signal-scrap"].next_upgrade = "rail-signal"
data.raw["rail-chain-signal"]["rail-chain-signal-scrap"].next_upgrade = "rail-chain-signal"
data.raw["train-stop"]["train-stop-scrap"].next_upgrade = "train-stop"

data.raw["rail-signal"]["rail-signal-scrap"].fast_replaceable_group = "rail-signal"
data.raw["rail-chain-signal"]["rail-chain-signal-scrap"].fast_replaceable_group = "rail-signal"
data.raw["train-stop"]["train-stop-scrap"].fast_replaceable_group = "rail-stop"

data.raw["rail-signal"]["rail-signal"].fast_replaceable_group = "rail-signal"
data.raw["rail-chain-signal"]["rail-chain-signal"].fast_replaceable_group = "rail-signal"
data.raw["train-stop"]["train-stop"].fast_replaceable_group = "rail-stop"

data.raw["rail-signal"]["rail-signal-scrap"].collision_mask = {"item-layer", "object-layer", "rail-layer", "floor-layer", "water-tile"}
data.raw["rail-chain-signal"]["rail-chain-signal-scrap"].collision_mask = {"item-layer", "object-layer", "rail-layer", "floor-layer", "water-tile"}
data.raw["train-stop"]["train-stop-scrap"].collision_mask = {"item-layer", "object-layer", "player-layer", "water-tile", "layer-14"}

data.raw["rail-signal"]["rail-signal"].collision_mask = {"item-layer", "object-layer", "rail-layer", "floor-layer", "water-tile"}
data.raw["rail-chain-signal"]["rail-chain-signal"].collision_mask = {"item-layer", "object-layer", "rail-layer", "floor-layer", "water-tile"}
data.raw["train-stop"]["train-stop"].collision_mask = {"item-layer", "object-layer", "player-layer", "water-tile", "layer-14"}
end
-------------------------------------------------------------------------------------------------
--меняем рецепт примитивных рельс
if mods["JunkTrain3"] then
data.raw.recipe["scrap-rail"].ingredients = 
{   
    {name = "stone-crushed", type = "item", amount = 10},
    {name = "iron-stick", type = "item", amount = 2},
    {name = "wood", type = "item", amount = 10},
    {name = "steel-plate", type = "item", amount = 2},
}
end
-------------------------------------------------------------------------------------------------
--подкручиваем рецепт стандартных рельс
bobmods.lib.recipe.set_ingredient("rail", {"stone-crushed", 10})
-------------------------------------------------------------------------------------------------
--переставляем рецепты рельс в технологиях
bobmods.lib.tech.remove_recipe_unlock("railway", "bi-rail-wood")
bobmods.lib.tech.add_recipe_unlock("railway", "rail")

bobmods.lib.tech.remove_recipe_unlock("bob-railway-2", "rail")
-------------------------------------------------------------------------------------------------
--добавляем рецепты обновления примитивов в технологию
bobmods.lib.tech.add_recipe_unlock("railway", "scrap-rail-to-rail")
bobmods.lib.tech.add_recipe_unlock("rail-signals", "rail-signal-scrap-to-rail-signal")
bobmods.lib.tech.add_recipe_unlock("rail-signals", "rail-chain-signal-scrap-to-rail-chain-signal")
bobmods.lib.tech.add_recipe_unlock("automated-rail-transportation", "train-stop-scrap-to-train-stop")
--###############################################################################################
--переносим рецепты в новые вкладки
--перенос в логику
data.raw["item-subgroup"]["circuit-network"] = {type = "item-subgroup", name = "circuit-network", group = "circuit", order = "a"}
data.raw["item-subgroup"]["circuit-network-2"] = {type = "item-subgroup", name = "circuit-network-2", group = "circuit", order = "h2"}

data.raw["recipe"]["power-switch"].group = "circuit"
data.raw["recipe"]["power-switch"].subgroup = "circuit-connection"
data.raw.item["power-switch"].subgroup = "circuit-connection"

data.raw["recipe"]["arithmetic-combinator"].group = "circuit"
data.raw["recipe"]["arithmetic-combinator"].subgroup = "circuit-combinator"
data.raw.item["arithmetic-combinator"].subgroup = "circuit-combinator"

data.raw["recipe"]["decider-combinator"].group = "circuit"
data.raw["recipe"]["decider-combinator"].subgroup = "circuit-combinator"
data.raw.item["decider-combinator"].subgroup = "circuit-combinator"

data.raw["recipe"]["constant-combinator"].group = "circuit"
data.raw["recipe"]["constant-combinator"].subgroup = "circuit-combinator"
data.raw.item["constant-combinator"].subgroup = "circuit-combinator"

data.raw["recipe"]["small-lamp"].group = "circuit"
data.raw["recipe"]["small-lamp"].subgroup = "circuit-visual"
data.raw.item["small-lamp"].subgroup = "circuit-visual"

data.raw["recipe"]["programmable-speaker"].group = "circuit"
data.raw["recipe"]["programmable-speaker"].subgroup = "circuit-auditory"
data.raw.item["programmable-speaker"].subgroup = "circuit-auditory"

if mods["InlaidLampsExtended"] then
data.raw["recipe"]["flat-lamp-c"].group = "circuit"
data.raw["recipe"]["flat-lamp-c"].subgroup = "circuit-visual"
data.raw.item["flat-lamp"].subgroup = "circuit-visual"

data.raw["recipe"]["flat-lamp-big"].group = "circuit"
data.raw["recipe"]["flat-lamp-big"].subgroup = "circuit-visual"
data.raw.item["flat-lamp-big"].subgroup = "circuit-visual"
end

if mods["DeadlockLargerLamp"] then
data.raw["recipe"]["deadlock-copper-lamp"].group = "circuit"
data.raw["recipe"]["deadlock-copper-lamp"].subgroup = "circuit-visual"
data.raw.item["deadlock-copper-lamp"].subgroup = "circuit-visual"

data.raw["recipe"]["deadlock-large-lamp"].group = "circuit"
data.raw["recipe"]["deadlock-large-lamp"].subgroup = "circuit-visual"
data.raw.item["deadlock-large-lamp"].subgroup = "circuit-visual"

data.raw["recipe"]["deadlock-floor-lamp"].group = "circuit"
data.raw["recipe"]["deadlock-floor-lamp"].subgroup = "circuit-visual"
data.raw.item["deadlock-floor-lamp"].subgroup = "circuit-visual"
end

if mods["capacity-combinator"] then
data.raw["recipe"]["capacity-combinator"].group = "circuit"
data.raw["recipe"]["capacity-combinator"].subgroup = "circuit-combinator"
data.raw.item["capacity-combinator"].subgroup = "circuit-combinator"

data.raw["recipe"]["capacity-combinator-MK2"].group = "circuit"
data.raw["recipe"]["capacity-combinator-MK2"].subgroup = "circuit-combinator"
data.raw.item["capacity-combinator-MK2"].subgroup = "circuit-combinator"
end

if mods["power-combinator"] then
data.raw["recipe"]["power-combinator"].group = "circuit"
data.raw["recipe"]["power-combinator"].subgroup = "circuit-combinator"
data.raw.item["power-combinator"].subgroup = "circuit-combinator"

data.raw["recipe"]["power-combinator-MK2"].group = "circuit"
data.raw["recipe"]["power-combinator-MK2"].subgroup = "circuit-combinator"
data.raw.item["power-combinator-MK2"].subgroup = "circuit-combinator"
end

if mods["Biter_Detector_Sentinel_Combinator"] then
data.raw["recipe"]["sentinel-combinator"].group = "circuit"
data.raw["recipe"]["sentinel-combinator"].subgroup = "circuit-input"
data.raw.item["sentinel-combinator"].subgroup = "circuit-input"

data.raw["recipe"]["sentinel-alarm"].group = "circuit"
data.raw["recipe"]["sentinel-alarm"].subgroup = "circuit-input"
data.raw.item["sentinel-alarm"].subgroup = "circuit-input"
end

if mods["LTN_Combinator_Fix"] then
data.raw["recipe"]["ltn-combinator"].subgroup = "circuit-combinator"
data.raw.item["ltn-combinator"].subgroup = "circuit-combinator"
end
if mods["LTN_Content_Reader"] then
data.raw["recipe"]["ltn-provider-reader"].subgroup = "circuit-combinator"
data.raw.item["ltn-provider-reader"].subgroup = "circuit-combinator"
data.raw["recipe"]["ltn-requester-reader"].subgroup = "circuit-combinator"
data.raw.item["ltn-requester-reader"].subgroup = "circuit-combinator"
data.raw["recipe"]["ltn-delivery-reader"].subgroup = "circuit-combinator"
data.raw.item["ltn-delivery-reader"].subgroup = "circuit-combinator"
end
-------------------------------------------------------------------------------------------------
--перенос в транспорт
if not mods["angelsindustries"] then
data.raw["item-subgroup"]["train-transport"] = {type = "item-subgroup", name = "train-transport", group = "transport", order = "e"}
data.raw["item-subgroup"].transport = {type = "item-subgroup", name = "transport", group = "transport", order = "f"}
data.raw["item-subgroup"]["bob-locomotive"] = {type = "item-subgroup", name = "bob-locomotive", group = "transport", order = "e-a1"}
data.raw["item-subgroup"]["bob-cargo-wagon"] = {type = "item-subgroup", name = "bob-cargo-wagon", group = "transport", order = "e-a2"}
data.raw["item-subgroup"]["bob-fluid-wagon"] = {type = "item-subgroup", name = "bob-fluid-wagon", group = "transport", order = "e-a3"}
data.raw["item-subgroup"]["transport-drones"] = {type = "item-subgroup", name = "transport-drones", group = "transport", order = "ez"}
data.raw["item-subgroup"]["bet-logistics"] = {type = "item-subgroup", name = "bet-logistics", group = "transport", order = "ez"}

--жд дороги
if mods["JunkTrain3"] then
data.raw["recipe"]["scrap-rail"].subgroup = "transport-rail"
data.raw["recipe"]["scrap-rail"].order = "a"
data.raw["rail-planner"]["scrap-rail"].subgroup = "transport-rail"
data.raw["rail-planner"]["scrap-rail"].order = "a"
end

data.raw["recipe"]["rail"].subgroup = "transport-rail"
data.raw["recipe"]["rail"].order = "b"
data.raw["rail-planner"].rail.subgroup = "transport-rail"
data.raw["rail-planner"].rail.order = "b"

if mods["PickerVehicles"] then
data.raw["rail-planner"]["picker-naked-rail"].flags = {"hidden"}
data.raw["rail-planner"]["picker-sleepy-rail"].flags = {"hidden"}
end
-------------------------------------------------------------------------------------------------
--жд светофоры, станции и тп
if mods["JunkTrain3"] then
data.raw["recipe"]["rail-signal-scrap"].subgroup = "transport-rail-other"
data.raw["recipe"]["rail-signal-scrap"].order = "a"
data.raw.item["rail-signal-scrap"].subgroup = "transport-rail-other"
data.raw.item["rail-signal-scrap"].order = "a"

data.raw["recipe"]["rail-chain-signal-scrap"].subgroup = "transport-rail-other"
data.raw["recipe"]["rail-chain-signal-scrap"].order = "b"
data.raw.item["rail-chain-signal-scrap"].subgroup = "transport-rail-other"
data.raw.item["rail-chain-signal-scrap"].order = "b"

data.raw["recipe"]["train-stop-scrap"].subgroup = "transport-rail-other"
data.raw["recipe"]["train-stop-scrap"].order = "c"
data.raw.item["train-stop-scrap"].subgroup = "transport-rail-other"
data.raw.item["train-stop-scrap"].order = "c"

data.raw["recipe"]["JunkTrain"].subgroup = "junk-train"
data.raw["recipe"]["JunkTrain"].order = "a"
data.raw.item["JunkTrain"].subgroup = "junk-train"
data.raw.item["JunkTrain"].order = "a"

data.raw["recipe"]["ScrapTrailer"].subgroup = "junk-train"
data.raw["recipe"]["ScrapTrailer"].order = "b"
data.raw.item["ScrapTrailer"].subgroup = "junk-train"
data.raw.item["ScrapTrailer"].order = "b"
end

data.raw["recipe"]["rail-signal"].subgroup = "transport-rail-other"
data.raw["recipe"]["rail-signal"].order = "d"
data.raw.item["rail-signal"].subgroup = "transport-rail-other"
data.raw.item["rail-signal"].order = "d"

data.raw["recipe"]["rail-chain-signal"].subgroup = "transport-rail-other"
data.raw["recipe"]["rail-chain-signal"].order = "e"
data.raw.item["rail-chain-signal"].subgroup = "transport-rail-other"
data.raw.item["rail-chain-signal"].order = "e"

data.raw["recipe"]["train-stop"].subgroup = "transport-rail-other"
data.raw["recipe"]["train-stop"].order = "f"
data.raw.item["train-stop"].subgroup = "transport-rail-other"
data.raw.item["train-stop"].order = "f"

if mods["LogisticTrainNetwork"] then
data.raw["recipe"]["logistic-train-stop"].subgroup = "transport-rail-other"
data.raw["recipe"]["logistic-train-stop"].order = "g"
data.raw.item["logistic-train-stop"].subgroup = "transport-rail-other"
data.raw.item["logistic-train-stop"].order = "g"
end

if mods["railloader"] then
data.raw["recipe"]["railloader"].subgroup = "transport-rail-other"
data.raw["recipe"]["railloader"].order = "h"
data.raw.item["railloader"].subgroup = "transport-rail-other"
data.raw.item["railloader"].order = "h"

data.raw["recipe"]["railunloader"].subgroup = "transport-rail-other"
data.raw["recipe"]["railunloader"].order = "i"
data.raw.item["railunloader"].subgroup = "transport-rail-other"
data.raw.item["railunloader"].order = "i"
end
-------------------------------------------------------------------------------------------------
--артиллерийские вагоны
data.raw["recipe"]["artillery-wagon"].subgroup = "artillery-wagon"
data.raw["recipe"]["artillery-wagon"].order = "a"
data.raw["item-with-entity-data"]["artillery-wagon"].subgroup = "artillery-wagon"
data.raw["item-with-entity-data"]["artillery-wagon"].order = "a"

data.raw["recipe"]["bob-artillery-wagon-2"].subgroup = "artillery-wagon"
data.raw["recipe"]["bob-artillery-wagon-2"].order = "b"
data.raw["item-with-entity-data"]["bob-artillery-wagon-2"].subgroup = "artillery-wagon"
data.raw["item-with-entity-data"]["bob-artillery-wagon-2"].order = "b"

data.raw["recipe"]["bob-artillery-wagon-3"].subgroup = "artillery-wagon"
data.raw["recipe"]["bob-artillery-wagon-3"].order = "c"
data.raw["item-with-entity-data"]["bob-artillery-wagon-3"].subgroup = "artillery-wagon"
data.raw["item-with-entity-data"]["bob-artillery-wagon-3"].order = "c"
-------------------------------------------------------------------------------------------------
--павуки
data.raw["recipe"]["antron"].subgroup = "spider"
data.raw["item-with-entity-data"]["antron"].subgroup = "spider"
data.raw["recipe"]["spidertron"].subgroup = "spider"
data.raw["item-with-entity-data"]["spidertron"].subgroup = "spider"
data.raw["recipe"]["tankotron"].subgroup = "spider"
data.raw["item-with-entity-data"]["tankotron"].subgroup = "spider"
data.raw["recipe"]["logistic-spidertron"].subgroup = "spider"
data.raw["item-with-entity-data"]["logistic-spidertron"].subgroup = "spider"
data.raw["recipe"]["heavy-spidertron"].subgroup = "spider"
data.raw["item-with-entity-data"]["heavy-spidertron"].subgroup = "spider"
-------------------------------------------------------------------------------------------------
--самолеты
if mods["Aircraft"] then
data.raw["recipe"]["gunship"].subgroup = "aircraft"
data.raw["item-with-entity-data"]["gunship"].subgroup = "aircraft"
data.raw["recipe"]["cargo-plane"].subgroup = "aircraft"
data.raw["item-with-entity-data"]["cargo-plane"].subgroup = "aircraft"
data.raw["recipe"]["jet"].subgroup = "aircraft"
data.raw["item-with-entity-data"]["jet"].subgroup = "aircraft"
data.raw["recipe"]["flying-fortress"].subgroup = "aircraft"
data.raw["item-with-entity-data"]["flying-fortress"].subgroup = "aircraft"
end

end
--###############################################################################################
--переносим трубы
if mods["FluidMustFlow"] then
data.raw["recipe"]["duct-small"].subgroup = "FluidMustFlow"
data.raw["item"]["duct-small"].subgroup = "FluidMustFlow"
data.raw["recipe"]["duct-t-junction"].subgroup = "FluidMustFlow"
data.raw["item"]["duct-t-junction"].subgroup = "FluidMustFlow"
data.raw["recipe"]["duct-curve"].subgroup = "FluidMustFlow"
data.raw["item"]["duct-curve"].subgroup = "FluidMustFlow"
data.raw["recipe"]["duct-cross"].subgroup = "FluidMustFlow"
data.raw["item"]["duct-cross"].subgroup = "FluidMustFlow"
data.raw["recipe"]["duct-underground"].subgroup = "FluidMustFlow"
data.raw["item"]["duct-underground"].subgroup = "FluidMustFlow"
data.raw["recipe"]["non-return-duct"].subgroup = "FluidMustFlow"
data.raw["item"]["non-return-duct"].subgroup = "FluidMustFlow"
data.raw["recipe"]["duct-end-point-intake"].subgroup = "FluidMustFlow"
data.raw["item"]["duct-end-point-intake"].subgroup = "FluidMustFlow"
data.raw["recipe"]["duct-end-point-outtake"].subgroup = "FluidMustFlow"
data.raw["item"]["duct-end-point-outtake"].subgroup = "FluidMustFlow"
end
-------------------------------------------------------------------------------------------------
if mods["Bio_Industries"] then
data.raw["recipe"]["bi-wood-pipe"].subgroup = "pipe"
data.raw["recipe"]["bi-wood-pipe"].order = "a"
data.raw["item"]["bi-wood-pipe"].subgroup = "pipe"
data.raw["item"]["bi-wood-pipe"].order = "a"

data.raw["recipe"]["bi-wood-pipe-to-ground"].subgroup = "pipe-to-ground"
data.raw["recipe"]["bi-wood-pipe-to-ground"].order = "a"
data.raw["item"]["bi-wood-pipe-to-ground"].subgroup = "pipe-to-ground"
data.raw["item"]["bi-wood-pipe-to-ground"].order = "a"
end
-------------------------------------------------------------------------------------------------
--if mods["FlowControl"] then
data.raw["recipe"]["pipe-junction"].group = "bob-logistics"
data.raw["recipe"]["pipe-junction"].subgroup = "FlowControl"
data.raw["item"]["pipe-junction"].group = "bob-logistics"
data.raw["item"]["pipe-junction"].subgroup = "FlowControl"

data.raw["recipe"]["pipe-straight"].group = "bob-logistics"
data.raw["recipe"]["pipe-straight"].subgroup = "FlowControl"
data.raw["item"]["pipe-straight"].group = "bob-logistics"
data.raw["item"]["pipe-straight"].subgroup = "FlowControl"

data.raw["recipe"]["pipe-elbow"].group = "bob-logistics"
data.raw["recipe"]["pipe-elbow"].subgroup = "FlowControl"
data.raw["item"]["pipe-elbow"].group = "bob-logistics"
data.raw["item"]["pipe-elbow"].subgroup = "FlowControl"
--end
--###############################################################################################
--переносим рецепты и предметы куда следует
--бронированный манипулятор
if mods["scattergun_turret"] then
data.raw["recipe"]["w93-hardened-inserter"].group = "bob-logistics"
data.raw["recipe"]["w93-hardened-inserter"].subgroup = "bob-logistic-tier-1"
data.raw["recipe"]["w93-hardened-inserter"].order = "z"
data.raw["item"]["w93-hardened-inserter"].group = "bob-logistics"
data.raw["item"]["w93-hardened-inserter"].subgroup = "bob-logistic-tier-1"
data.raw["item"]["w93-hardened-inserter"].order = "z"
end
-------------------------------------------------------------------------------------------------
--деревянные столбы
data.raw["recipe"]["small-electric-pole"].subgroup = "wooden-pole"
data.raw["item"]["small-electric-pole"].subgroup = "wooden-pole"

if mods["Bio_Industries"] then
data.raw["recipe"]["bi-wooden-pole-big"].subgroup = "wooden-pole"
data.raw["item"]["bi-wooden-pole-big"].subgroup = "wooden-pole"
data.raw["recipe"]["bi-wooden-pole-huge"].subgroup = "wooden-pole"
data.raw["item"]["bi-wooden-pole-huge"].subgroup = "wooden-pole"
end

data.raw["recipe"]["medium-electric-pole"].subgroup = "medium-electric-pole"
data.raw["item"]["medium-electric-pole"].subgroup = "medium-electric-pole"
data.raw["recipe"]["medium-electric-pole-2"].subgroup = "medium-electric-pole"
data.raw["item"]["medium-electric-pole-2"].subgroup = "medium-electric-pole"
data.raw["recipe"]["medium-electric-pole-3"].subgroup = "medium-electric-pole"
data.raw["item"]["medium-electric-pole-3"].subgroup = "medium-electric-pole"
data.raw["recipe"]["medium-electric-pole-4"].subgroup = "medium-electric-pole"
data.raw["item"]["medium-electric-pole-4"].subgroup = "medium-electric-pole"

data.raw["recipe"]["big-electric-pole"].subgroup = "big-electric-pole"
data.raw["item"]["big-electric-pole"].subgroup = "big-electric-pole"
data.raw["recipe"]["big-electric-pole-2"].subgroup = "big-electric-pole"
data.raw["item"]["big-electric-pole-2"].subgroup = "big-electric-pole"
data.raw["recipe"]["big-electric-pole-3"].subgroup = "big-electric-pole"
data.raw["item"]["big-electric-pole-3"].subgroup = "big-electric-pole"
data.raw["recipe"]["big-electric-pole-4"].subgroup = "big-electric-pole"
data.raw["item"]["big-electric-pole-4"].subgroup = "big-electric-pole"

data.raw["recipe"]["substation"].subgroup = "substation"
data.raw["item"]["substation"].subgroup = "substation"
data.raw["recipe"]["substation-2"].subgroup = "substation"
data.raw["item"]["substation-2"].subgroup = "substation"
data.raw["recipe"]["substation-3"].subgroup = "substation"
data.raw["item"]["substation-3"].subgroup = "substation"
data.raw["recipe"]["substation-4"].subgroup = "substation"
data.raw["item"]["substation-4"].subgroup = "substation"

if mods["LightedPolesPlus"] then
data.raw["recipe"]["lighted-small-electric-pole"].subgroup = "wooden-pole"
data.raw["item"]["lighted-small-electric-pole"].subgroup = "wooden-pole"
data.raw["recipe"]["lighted-bi-wooden-pole-big"].subgroup = "wooden-pole"
data.raw["item"]["lighted-bi-wooden-pole-big"].subgroup = "wooden-pole"
data.raw["recipe"]["lighted-bi-wooden-pole-huge"].subgroup = "wooden-pole"
data.raw["item"]["lighted-bi-wooden-pole-huge"].subgroup = "wooden-pole"

data.raw["recipe"]["lighted-medium-electric-pole"].subgroup = "medium-electric-pole"
data.raw["item"]["lighted-medium-electric-pole"].subgroup = "medium-electric-pole"
data.raw["recipe"]["lighted-medium-electric-pole-2"].subgroup = "medium-electric-pole"
data.raw["item"]["lighted-medium-electric-pole-2"].subgroup = "medium-electric-pole"
data.raw["recipe"]["lighted-medium-electric-pole-3"].subgroup = "medium-electric-pole"
data.raw["item"]["lighted-medium-electric-pole-3"].subgroup = "medium-electric-pole"
data.raw["recipe"]["lighted-medium-electric-pole-4"].subgroup = "medium-electric-pole"
data.raw["item"]["lighted-medium-electric-pole-4"].subgroup = "medium-electric-pole"

data.raw["recipe"]["lighted-big-electric-pole"].subgroup = "big-electric-pole"
data.raw["item"]["lighted-big-electric-pole"].subgroup = "big-electric-pole"
data.raw["recipe"]["lighted-big-electric-pole-2"].subgroup = "big-electric-pole"
data.raw["item"]["lighted-big-electric-pole-2"].subgroup = "big-electric-pole"
data.raw["recipe"]["lighted-big-electric-pole-3"].subgroup = "big-electric-pole"
data.raw["item"]["lighted-big-electric-pole-3"].subgroup = "big-electric-pole"
data.raw["recipe"]["lighted-big-electric-pole-4"].subgroup = "big-electric-pole"
data.raw["item"]["lighted-big-electric-pole-4"].subgroup = "big-electric-pole"

data.raw["recipe"]["lighted-substation"].subgroup = "substation"
data.raw["item"]["lighted-substation"].subgroup = "substation"
data.raw["recipe"]["lighted-substation-2"].subgroup = "substation"
data.raw["item"]["lighted-substation-2"].subgroup = "substation"
data.raw["recipe"]["lighted-substation-3"].subgroup = "substation"
data.raw["item"]["lighted-substation-3"].subgroup = "substation"
data.raw["recipe"]["lighted-substation-4"].subgroup = "substation"
data.raw["item"]["lighted-substation-4"].subgroup = "substation"
end
-------------------------------------------------------------------------------------------------
--сундуки и склады
data.raw["item"]["steel-chest"].subgroup = "logistic-chests-1"
data.raw["item"]["logistic-chest-passive-provider"].subgroup = "logistic-chests-1"
data.raw["item"]["logistic-chest-storage"].subgroup = "logistic-chests-1"
data.raw["item"]["logistic-chest-active-provider"].subgroup = "logistic-chests-1"
data.raw["item"]["logistic-chest-requester"].subgroup = "logistic-chests-1"
data.raw["item"]["logistic-chest-buffer"].subgroup = "logistic-chests-1"

data.raw["item"]["brass-chest"].subgroup = "logistic-chests-2"

data.raw["item"]["titanium-chest"].subgroup = "logistic-chests-3"

if mods["Warehousing"] then
data.raw["item"]["storehouse-basic"].subgroup = "logistic-chests-4"
data.raw["item"]["storehouse-passive-provider"].subgroup = "logistic-chests-4"
data.raw["item"]["storehouse-storage"].subgroup = "logistic-chests-4"
data.raw["item"]["storehouse-active-provider"].subgroup = "logistic-chests-4"
data.raw["item"]["storehouse-requester"].subgroup = "logistic-chests-4"
data.raw["item"]["storehouse-buffer"].subgroup = "logistic-chests-4"

data.raw["item"]["storehouse-basic"].order = "1"
data.raw["item"]["storehouse-passive-provider"].order = "4"
data.raw["item"]["storehouse-storage"].order = "6"
data.raw["item"]["storehouse-active-provider"].order = "2"
data.raw["item"]["storehouse-requester"].order = "5"
data.raw["item"]["storehouse-buffer"].order = "3"

data.raw["item"]["warehouse-basic"].subgroup = "logistic-chests-5"
data.raw["item"]["warehouse-passive-provider"].subgroup = "logistic-chests-5"
data.raw["item"]["warehouse-storage"].subgroup = "logistic-chests-5"
data.raw["item"]["warehouse-active-provider"].subgroup = "logistic-chests-5"
data.raw["item"]["warehouse-requester"].subgroup = "logistic-chests-5"
data.raw["item"]["warehouse-buffer"].subgroup = "logistic-chests-5"

data.raw["item"]["warehouse-basic"].order = "1"
data.raw["item"]["warehouse-passive-provider"].order = "4"
data.raw["item"]["warehouse-storage"].order = "6"
data.raw["item"]["warehouse-active-provider"].order = "2"
data.raw["item"]["warehouse-requester"].order = "5"
data.raw["item"]["warehouse-buffer"].order = "3"
end