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
bobmods.lib.recipe.add_ingredient("request-depot", {"steel-chest", 2})
bobmods.lib.recipe.add_ingredient("request-depot", {"steel-plate", 10})

bobmods.lib.recipe.remove_ingredient("request-depot", "iron-plate")
bobmods.lib.recipe.remove_ingredient("request-depot", "iron-gear-wheel")
bobmods.lib.recipe.remove_ingredient("request-depot", "iron-stick")
-------------------------------------------------------------------------------------------------
--депо снабжения
bobmods.lib.recipe.add_ingredient("supply-depot", {"basic-structure-components", 1})
bobmods.lib.recipe.add_ingredient("supply-depot", {"electronic-circuit", 10})
bobmods.lib.recipe.add_ingredient("supply-depot", {"steel-chest", 5})
bobmods.lib.recipe.add_ingredient("supply-depot", {"steel-plate", 10})

bobmods.lib.recipe.remove_ingredient("supply-depot", "iron-plate")
bobmods.lib.recipe.remove_ingredient("supply-depot", "iron-gear-wheel")
bobmods.lib.recipe.remove_ingredient("supply-depot", "iron-stick")
-------------------------------------------------------------------------------------------------
--депо буфер
bobmods.lib.recipe.add_ingredient("buffer-depot", {"basic-structure-components", 1})
bobmods.lib.recipe.add_ingredient("buffer-depot", {"electronic-circuit", 10})
bobmods.lib.recipe.add_ingredient("buffer-depot", {"steel-chest", 3})
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
bobmods.lib.recipe.replace_ingredient("railloader", "rail", "bi-rail-wood")
bobmods.lib.recipe.replace_ingredient("railunloader", "rail", "bi-rail-wood")
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
-------------------------------------------------------------------------------------------------
--крутим рельсы
--data.raw.recipe["bi-rail-wood"].type = "recipe"
data.raw["straight-rail"]["straight-scrap-rail"].next_upgrade = "bi-straight-rail-wood"
data.raw["curved-rail"]["curved-scrap-rail"].next_upgrade = "bi-curved-rail-wood"

data.raw["straight-rail"]["straight-scrap-rail"].fast_replaceable_group = "rail"
data.raw["curved-rail"]["curved-scrap-rail"].fast_replaceable_group = "rail"

data.raw["straight-rail"]["bi-straight-rail-wood"].fast_replaceable_group = "rail"
data.raw["curved-rail"]["bi-curved-rail-wood"].fast_replaceable_group = "rail"

data.raw["straight-rail"]["straight-scrap-rail"].collision_mask = {"item-layer", "object-layer", "rail-layer", "floor-layer", "water-tile"}
data.raw["curved-rail"]["curved-scrap-rail"].collision_mask = {"item-layer", "object-layer", "rail-layer", "floor-layer", "water-tile"}

data.raw["straight-rail"]["bi-straight-rail-wood"].collision_mask = {"item-layer", "object-layer", "rail-layer", "floor-layer", "water-tile"}
data.raw["curved-rail"]["bi-curved-rail-wood"].collision_mask = {"item-layer", "object-layer", "rail-layer", "floor-layer", "water-tile"}