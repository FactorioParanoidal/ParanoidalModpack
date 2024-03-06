--data.raw["technology"]["xxx"].prerequisites = {"xxx", "xxx"}
--data.raw.technology["xxx"].hidden = true

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
concrete_brick_fix.layer = "225"
concrete_brick_fix.variants.material_background = 
  {
    picture = "__zzzparanoidal__/graphics/grid/concrete.png", count = 8,
    hr_version = {picture = "__zzzparanoidal__/graphics/grid/hr-concrete.png", count = 8, scale = 0.5}
  }
data:extend{concrete_brick_fix}
data.raw["item"]["concrete-brick"].place_as_tile.result = "concrete-brick-fix"
-------------------------------------------------------------------------------------------------
--замена tile для reinforced-concrete-brick
local reinforced_concrete_brick_fix = table.deepcopy(data.raw["tile"]["refined-concrete"])
reinforced_concrete_brick_fix.name = "reinforced-concrete-brick-fix"
reinforced_concrete_brick_fix.minable = {mining_time = 0.1, result = "reinforced-concrete-brick"}
reinforced_concrete_brick_fix.layer = "230"
reinforced_concrete_brick_fix.variants.material_background = 
  {
    picture = "__zzzparanoidal__/graphics/smooth/concrete.png", count = 8, 
    hr_version = {picture = "__zzzparanoidal__/graphics/smooth/hr-concrete.png", count = 8,scale = 0.5}
  }
data:extend{reinforced_concrete_brick_fix}
data.raw["item"]["reinforced-concrete-brick"].place_as_tile.result = "reinforced-concrete-brick-fix"
-------------------------------------------------------------------------------------------------
--подмена графики стандартного кирпича
if settings.startup["stone-path-concrete"].value then
  local stone_variants = util.table.deepcopy(data.raw.tile["refined-concrete"].variants)
  stone_variants.material_background.picture = "__zzzparanoidal__/graphics/patches/concrete.png"
  stone_variants.material_background.hr_version = {picture = "__zzzparanoidal__/graphics/patches/hr-concrete.png", count = 8, scale = 0.5}
  data.raw.tile["stone-path"].variants = stone_variants
end
-------------------------------------------------------------------------------------------------
--замена текстуры для "бетон с разметкой опасности"
data.raw.tile["hazard-concrete-left"].variants.material_background.picture = "__zzzparanoidal__/graphics/grid/hazard-concrete-left.png"
data.raw.tile["hazard-concrete-left"].variants.material_background.hr_version = {picture = "__zzzparanoidal__/graphics/grid/hr-hazard-concrete-left.png", count = 8, scale = 0.5}
data.raw.tile["hazard-concrete-right"].variants.material_background.picture = "__zzzparanoidal__/graphics/grid/hazard-concrete-right.png"
data.raw.tile["hazard-concrete-right"].variants.material_background.hr_version = {picture = "__zzzparanoidal__/graphics/grid/hr-hazard-concrete-right.png", count = 8, scale = 0.5}
-------------------------------------------------------------------------------------------------
--отбираем возможность размещения у "титаново-бетонный кирпич", ибо нету графики для него
data.raw.item["titanium-concrete-brick"].place_as_tile = nil
--###############################################################################################
--сокрытие каменных труб
data.raw["item"]["stone-pipe"].flags = {"hidden"}
data.raw["recipe"]["angels-stone-pipe-casting"].hidden = true
data.raw["item"]["stone-pipe-to-ground"].flags = {"hidden"}
data.raw["recipe"]["angels-stone-pipe-to-ground-casting"].hidden = true
--###############################################################################################
-- добавляем зависимости в техологии для последовательности развития
bobmods.lib.tech.add_prerequisite ("electronics-machine-1", "steel-processing")
bobmods.lib.tech.add_prerequisite ("radar", "electronics")
bobmods.lib.tech.add_prerequisite ("electric-lab", "electronics")
--bobmods.lib.tech.add_prerequisite ("bi-tech-bio-farming", "ore-crushing")
bobmods.lib.tech.add_prerequisite ("logistic-science-pack", "electronics")
bobmods.lib.tech.add_prerequisite ("logistic-science-pack", "angels-bronze-smelting-1")
bobmods.lib.tech.add_prerequisite ("bio-wood-processing", "bi-tech-bio-farming")
bobmods.lib.tech.add_prerequisite ("angels-metallurgy-1", "ore-crushing")
bobmods.lib.tech.add_prerequisite ("angels-lead-smelting-1", "basic-chemistry-2")
bobmods.lib.tech.add_prerequisite ("JunkTrain_tech", "steel-processing")
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
bobmods.lib.tech.add_prerequisite ("bi-tech-bio-farming-2", "logistic-science-pack")
bobmods.lib.tech.add_prerequisite ("adv-seed-extraction", "logistic-science-pack")
bobmods.lib.tech.add_prerequisite ("nanobots-cliff", "logistic-science-pack")
--синие банки
bobmods.lib.tech.add_prerequisite ("remelting-alloy-mixer-2", "chemical-science-pack")
bobmods.lib.tech.add_prerequisite ("bio-nutrient-paste-2", "chemical-science-pack")
bobmods.lib.tech.add_prerequisite ("bio-refugium-fish-3", "chemical-science-pack")
bobmods.lib.tech.add_prerequisite ("bio-refugium-hatchery-2", "chemical-science-pack")
bobmods.lib.tech.add_prerequisite ("worker-robots-speed-1", "chemical-science-pack")
bobmods.lib.tech.add_prerequisite ("Rubber-Processing", "chemical-science-pack")
bobmods.lib.tech.add_prerequisite ("worker-robots-battery-1", "chemical-science-pack")
bobmods.lib.tech.add_prerequisite ("bet-tech", "chemical-science-pack")
bobmods.lib.tech.add_prerequisite ("roboport-interface", "chemical-science-pack")
bobmods.lib.tech.add_prerequisite ("bio-farm-3", "chemical-science-pack")
bobmods.lib.tech.add_prerequisite ("toolbelt-2", "chemical-science-pack")
bobmods.lib.tech.add_prerequisite ("worker-robots-storage-1", "chemical-science-pack")
bobmods.lib.tech.add_prerequisite ("steel-axe-4", "chemical-science-pack")
bobmods.lib.tech.add_prerequisite ("research-speed-3", "chemical-science-pack")
bobmods.lib.tech.add_prerequisite ("inserter-capacity-bonus-3", "chemical-science-pack")
bobmods.lib.tech.add_prerequisite ("OilBurning-3", "chemical-science-pack")
bobmods.lib.tech.add_prerequisite ("advanced-aerodynamics", "chemical-science-pack")
bobmods.lib.tech.add_prerequisite ("mining-productivity-2", "chemical-science-pack")
bobmods.lib.tech.add_prerequisite ("CW-air-filter-cleaning-3", "chemical-science-pack")
bobmods.lib.tech.add_prerequisite ("CW-air-filtering-3", "chemical-science-pack")
bobmods.lib.tech.add_prerequisite ("fast-miniloader", "chemical-science-pack")
bobmods.lib.tech.add_prerequisite ("inserter-stack-size-bonus-2", "chemical-science-pack")
bobmods.lib.tech.add_prerequisite ("bio-refugium-butchery-3", "chemical-science-pack")
bobmods.lib.tech.add_prerequisite ("physical-projectile-damage-5", "chemical-science-pack")
bobmods.lib.tech.add_prerequisite ("refined-flammables-3", "chemical-science-pack")
bobmods.lib.tech.add_prerequisite ("weapon-shooting-speed-5", "chemical-science-pack")
bobmods.lib.tech.add_prerequisite ("laser-shooting-speed-3", "chemical-science-pack")

--bobmods.lib.tech.add_prerequisite ("xxx", "chemical-science-pack")

--фиолетовые
bobmods.lib.tech.add_prerequisite ("water-washing-3", "production-science-pack")

--bobmods.lib.tech.add_prerequisite ("xxx", "production-science-pack")

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
--[[
--убираем био-рельсы
if mods["Bio_Industries"] then
data.raw["rail-planner"]["bi-rail-wood"].flags = {"hidden"}
data.raw["recipe"]["bi-rail-wood"].hidden = true
data.raw["rail-planner"]["bi-rail-wood-bridge"].flags = {"hidden"}
end]]
--###############################################################################################
--переносим рецепты в новые вкладки
--перенос в логику
if not mods["angelsindustries"] then

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
bobmods.lib.tech.add_prerequisite ("flat-lamp-t", "electronics")
bobmods.lib.tech.add_prerequisite ("flat-lamp-t", "logistic-science-pack")
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
data.raw["item-subgroup"]["train-transport"] = {type = "item-subgroup", name = "train-transport", group = "transport", order = "e"}
data.raw["item-subgroup"].transport = {type = "item-subgroup", name = "transport", group = "transport", order = "f"}
data.raw["item-subgroup"]["bob-locomotive"] = {type = "item-subgroup", name = "bob-locomotive", group = "transport", order = "e-a1"}
data.raw["item-subgroup"]["bob-cargo-wagon"] = {type = "item-subgroup", name = "bob-cargo-wagon", group = "transport", order = "e-a2"}
data.raw["item-subgroup"]["bob-fluid-wagon"] = {type = "item-subgroup", name = "bob-fluid-wagon", group = "transport", order = "e-a3"}
data.raw["item-subgroup"]["transport-drones"] = {type = "item-subgroup", name = "transport-drones", group = "transport", order = "ez"}
data.raw["item-subgroup"]["bet-logistics"] = {type = "item-subgroup", name = "bet-logistics", group = "transport", order = "ez"}

data.raw["recipe"]["rail"].subgroup = "transport-rail"
data.raw["recipe"]["rail"].order = "b"
data.raw["rail-planner"].rail.subgroup = "transport-rail"
data.raw["rail-planner"].rail.order = "b"
-------------------------------------------------------------------------------------------------
--жд светофоры, станции и тп

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

if mods["betterCargoPlanes"] then
data.raw["recipe"]["better-cargo-plane"].subgroup = "aircraft"
data.raw["item-with-entity-data"]["better-cargo-plane"].subgroup = "aircraft"
data.raw["recipe"]["even-better-cargo-plane"].subgroup = "aircraft"
data.raw["item-with-entity-data"]["even-better-cargo-plane"].subgroup = "aircraft"
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
data.raw["item"]["duct"].subgroup = "FluidMustFlow"
data.raw["item"]["duct-long"].subgroup = "FluidMustFlow"
data.raw["recipe"]["check-valve"].subgroup = "FluidMustFlow"
data.raw["item"]["check-valve"].subgroup = "FluidMustFlow"
data.raw["recipe"]["overflow-valve"].subgroup = "FluidMustFlow"
data.raw["item"]["overflow-valve"].subgroup = "FluidMustFlow"
data.raw["recipe"]["underflow-valve"].subgroup = "FluidMustFlow"
data.raw["item"]["underflow-valve"].subgroup = "FluidMustFlow"
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
if mods["Flow Control"] then
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
end
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
if mods["Nanobots"] then
data.raw["item"]["roboport-interface"].subgroup = "bob-logistic-roboport"
data.raw["item"]["roboport-interface-cc"].subgroup = "bob-logistic-roboport"
end

end --конец mods["angelsindustries"]

--###############################################################################################
if settings.startup["fitolamps"].value then
data.raw["assembling-machine"]["bi-bio-farm"].working_visualisations[1].animation.layers[1].tint = {r=230, g=20, b=190}
data.raw["assembling-machine"]["bi-bio-farm"].working_visualisations[1].animation.layers[1].hr_version.tint = {r=230, g=20, b=190}

data.raw["assembling-machine"]["bi-bio-greenhouse"].working_visualisations[1].animation.layers[1].tint = {r=230, g=130, b=210}
data.raw["assembling-machine"]["bi-bio-greenhouse"].working_visualisations[1].animation.layers[1].hr_version.tint = {r=230, g=130, b=210}
end
--###############################################################################################
-- твики из TrainOverhaul
data.raw.item["solid-fuel"].fuel_acceleration_multiplier = 1.05 --base 1.2
data.raw.item["solid-fuel"].fuel_top_speed_multiplier = 1 -- base 1.05

data.raw.item["rocket-fuel"].fuel_acceleration_multiplier = 1.2 -- base 1.8
data.raw.item["rocket-fuel"].fuel_top_speed_multiplier = 1 -- base 1.5

--###############################################################################################
-- баланс электрички
if mods["BatteryElectricTrain"] then

data.raw.locomotive["bet-locomotive"].max_health = 2000
data.raw.locomotive["bet-locomotive"].max_speed = 2
data.raw.locomotive["bet-locomotive"].max_power = "1000kW"
data.raw.locomotive["bet-locomotive"].reversing_power_modifier = 1
data.raw.locomotive["bet-locomotive"].braking_force = 20
data.raw.locomotive["bet-locomotive"].friction_force = 0.25
data.raw.locomotive["bet-locomotive"].air_resistance = 0.004
data.raw.locomotive["bet-locomotive"].resistances[1] = {type = "fire", decrease = 50, percent = 70}
data.raw.locomotive["bet-locomotive"].resistances[2] = {type = "physical", decrease = 30, percent = 50}
data.raw.locomotive["bet-locomotive"].resistances[3] = {type = "impact", decrease = 100, percent = 80}
data.raw.locomotive["bet-locomotive"].resistances[4] = {type = "explosion", decrease = 30, percent = 50}
data.raw.locomotive["bet-locomotive"].resistances[5] = {type = "acid", decrease = 70, percent = 80}
--[[
data.raw.locomotive["bet-locomotive"].minimap_representation.filename = "__base__/graphics/entity/diesel-locomotive/diesel-locomotive-minimap-representation.png"
data.raw.locomotive["bet-locomotive"].minimap_representation.flags = {"icon"}
data.raw.locomotive["bet-locomotive"].minimap_representation.size = {20, 40}
data.raw.locomotive["bet-locomotive"].minimap_representation.scale = 0.5

data.raw.locomotive["bet-locomotive"].selected_minimap_representation.filename = "__base__/graphics/entity/diesel-locomotive/diesel-locomotive-selected-minimap-representation.png"
data.raw.locomotive["bet-locomotive"].selected_minimap_representation.flags = {"icon"}
data.raw.locomotive["bet-locomotive"].selected_minimap_representation.size = {20, 40}
data.raw.locomotive["bet-locomotive"].selected_minimap_representation.scale = 0.5
]]
-------------------------------------------------------------------------------------------------
--баланс акб
data.raw.item["bet-fuel-1-full"].fuel_acceleration_multiplier = 1.5
data.raw.item["bet-fuel-1-full"].fuel_top_speed_multiplier = 1

data.raw.item["bet-fuel-2-full"].fuel_acceleration_multiplier = 2
data.raw.item["bet-fuel-2-full"].fuel_top_speed_multiplier = 1.5

data.raw.item["bet-fuel-3-full"].fuel_acceleration_multiplier = 2.5
data.raw.item["bet-fuel-3-full"].fuel_top_speed_multiplier = 2

data.raw.item["bet-fuel-4-full"].fuel_acceleration_multiplier = 3.5
data.raw.item["bet-fuel-4-full"].fuel_top_speed_multiplier = 3

bobmods.lib.tech.add_prerequisite("bet-fuel-2", "battery-2")
bobmods.lib.recipe.replace_ingredient("bet-fuel-2-empty", "battery", "lithium-ion-battery")

bobmods.lib.tech.add_prerequisite("bet-fuel-3", "battery-3")
bobmods.lib.recipe.replace_ingredient("bet-fuel-3-empty", "battery", "silver-zinc-battery")

bobmods.lib.tech.add_prerequisite("bet-fuel-4", "raw-speed-module-4")
bobmods.lib.recipe.replace_ingredient("bet-fuel-4-empty", "battery", "silver-zinc-battery")
bobmods.lib.recipe.replace_ingredient("bet-fuel-4-empty", "effectivity-module-3", "raw-speed-module-4")
bobmods.lib.recipe.add_ingredient("bet-fuel-4-empty", {"advanced-processing-unit", 3})

--recycling battery
--исправление переработки батарей
--в моде на электро-батарейковый поезд какая-то зубодробительная хрень с расчетом поэтому просто ввел количество

bobmods.lib.recipe.remove_result("bet-fuel-2-recycling", "battery")
bobmods.lib.recipe.set_result("bet-fuel-2-recycling", {"lithium-ion-battery", 405})

bobmods.lib.recipe.remove_result("bet-fuel-3-recycling", "battery")
bobmods.lib.recipe.set_result("bet-fuel-3-recycling", {"silver-zinc-battery", 675})

bobmods.lib.recipe.remove_result("bet-fuel-4-recycling", "battery")
bobmods.lib.recipe.set_result("bet-fuel-4-recycling", {"silver-zinc-battery", 816})
-------------------------------------------------------------------------------------------------
--зарядные
data.raw.furnace["bet-charger-1"].icon = "__zzzparanoidal__/graphics/train/electric/factory_var_1_icon.png"
data.raw.item["bet-charger-1"].icon = "__zzzparanoidal__/graphics/train/electric/factory_var_1_icon.png"
data.raw.recipe["bet-charger-1"].icon = "__zzzparanoidal__/graphics/train/electric/factory_var_1_icon.png"
data.raw.recipe["bet-charger-1"].icon_size = 32

data.raw.furnace["bet-charger-1"].working_visualisations.animation =
{			
  filename = "__zzzparanoidal__/graphics/train/electric/av1_sheet.png",			
  width = 320,
  height = 320,			
  shift = {1.0, -1.0},
  frame_count = 16,
  line_length = 4,			
  animation_speed = 0.3,			
  scale = 0.5,
}

data.raw.furnace["bet-charger-1"].animation = 
{			
  filename = "__zzzparanoidal__/graphics/train/electric/av1_sheet.png",			
  width = 320,
  height = 320,			
  shift = {1.0, -1.0},
  frame_count = 16,
  line_length = 4,			
  animation_speed = 0.3,			
  scale = 0.5,
}
-------------------------------------------------------------------------------------------------
data.raw.furnace["bet-charger-2"].icon = "__zzzparanoidal__/graphics/train/electric/factory_var_2_icon.png"
data.raw.item["bet-charger-2"].icon = "__zzzparanoidal__/graphics/train/electric/factory_var_2_icon.png"
data.raw.recipe["bet-charger-2"].icon = "__zzzparanoidal__/graphics/train/electric/factory_var_2_icon.png"
data.raw.recipe["bet-charger-2"].icon_size = 32
data.raw.technology["bet-charger-2"].icon = "__zzzparanoidal__/graphics/train/electric/bet-charger-2_tech.png"
data.raw.technology["bet-charger-2"].icon_size = 256
data.raw.technology["bet-charger-2"].icon_mipmaps = 4
data.raw.furnace["bet-charger-2"].working_visualisations.animation =
{			
  filename = "__zzzparanoidal__/graphics/train/electric/av2_sheet.png",			
  width = 256,
  height = 256,			
  shift = {0.5, -0.5},
  frame_count = 36,
  line_length = 6,			
  animation_speed = 0.1,			
  scale = 0.5,
}

data.raw.furnace["bet-charger-2"].animation =
{			
  filename = "__zzzparanoidal__/graphics/train/electric/av2_sheet.png",			
  width = 256,
  height = 256,			
  shift = {0.5, -0.5},
  frame_count = 36,
  line_length = 6,			
  animation_speed = 0.1,			
  scale = 0.5,
}
-------------------------------------------------------------------------------------------------
data.raw.furnace["bet-charger-3"].icon = "__zzzparanoidal__/graphics/train/electric/factory_var_3_icon.png"
data.raw.item["bet-charger-3"].icon = "__zzzparanoidal__/graphics/train/electric/factory_var_3_icon.png"
data.raw.recipe["bet-charger-3"].icon = "__zzzparanoidal__/graphics/train/electric/factory_var_3_icon.png"
data.raw.recipe["bet-charger-3"].icon_size = 32
data.raw.technology["bet-charger-3"].icon = "__zzzparanoidal__/graphics/train/electric/bet-charger-3_tech.png"
data.raw.technology["bet-charger-3"].icon_size = 256
data.raw.technology["bet-charger-3"].icon_mipmaps = 4

data.raw.furnace["bet-charger-3"].working_visualisations.animation =
{			
  filename = "__zzzparanoidal__/graphics/train/electric/av3_sheet.png",			
  width = 256,
  height = 256,
  shift = {0.4, -0.5},
  frame_count = 25,
  line_length = 5,			
  animation_speed = 0.05,
  scale = 0.5,
}

data.raw.furnace["bet-charger-3"].animation =
{			
  filename = "__zzzparanoidal__/graphics/train/electric/av3_sheet.png",			
  width = 256,
  height = 256,
  shift = {0.4, -0.5},
  frame_count = 25,
  line_length = 5,			
  animation_speed = 0.05,
  scale = 0.5,
}
end
--###############################################################################################
--баланс поездов
--локомотив мк1
data.raw.locomotive.locomotive.max_health = 1200
data.raw.locomotive.locomotive.weight = 2000
data.raw.locomotive.locomotive.max_speed = 1.2
data.raw.locomotive.locomotive.max_power = "800kW"
data.raw.locomotive.locomotive.reversing_power_modifier = 0.5
data.raw.locomotive.locomotive.braking_force = 14
data.raw.locomotive.locomotive.friction_force = 0.27
data.raw.locomotive.locomotive.air_resistance = 0.008
data.raw.locomotive.locomotive.energy_per_hit_point = 5
data.raw.locomotive.locomotive.burner.effectivity = 0.8
-------------------------------------------------------------------------------------------------
data.raw.locomotive["bob-locomotive-2"].air_resistance = 0.0065
-------------------------------------------------------------------------------------------------
--вагон мк1
data.raw["cargo-wagon"]["cargo-wagon"].weight = 1000
data.raw["cargo-wagon"]["cargo-wagon"].max_speed = 1.5
data.raw["cargo-wagon"]["cargo-wagon"].braking_force = 3
data.raw["cargo-wagon"]["cargo-wagon"].friction_force = 0.3
data.raw["cargo-wagon"]["cargo-wagon"].air_resistance = 0.007
-------------------------------------------------------------------------------------------------
data.raw["cargo-wagon"]["bob-cargo-wagon-3"].max_speed = 10
-------------------------------------------------------------------------------------------------
--вагон-цистерна мк1
data.raw["fluid-wagon"]["fluid-wagon"].weight = 1000
data.raw["fluid-wagon"]["fluid-wagon"].max_speed = 1.5
data.raw["fluid-wagon"]["fluid-wagon"].braking_force = 3
data.raw["fluid-wagon"]["fluid-wagon"].friction_force = 0.3
data.raw["fluid-wagon"]["fluid-wagon"].air_resistance = 0.007
-------------------------------------------------------------------------------------------------
data.raw["fluid-wagon"]["bob-fluid-wagon-3"].max_speed = 10
-------------------------------------------------------------------------------------------------
--артиллерийский вагон мк1
data.raw["artillery-wagon"]["artillery-wagon"].weight = 4000
data.raw["artillery-wagon"]["artillery-wagon"].max_speed = 1.5
data.raw["artillery-wagon"]["artillery-wagon"].braking_force = 3
data.raw["artillery-wagon"]["artillery-wagon"].friction_force = 0.5
data.raw["artillery-wagon"]["artillery-wagon"].air_resistance = 0.0065
-------------------------------------------------------------------------------------------------
data.raw["artillery-wagon"]["bob-artillery-wagon-3"].max_speed = 5
--###############################################################################################
--баланс мостовых рельс
if mods["beautiful_straight_bridge_railway"] then
data.raw["rail-planner"]["bbr-rail-brick"].subgroup = "transport-rail"
data.raw["rail-planner"]["bbr-rail-brick"].order = "d"
data.raw["rail-planner"]["bbr-rail-brick"].icons = {{icon = "__zzzparanoidal__/graphics/train/bbr-rail-brick-icon.png", size = 64, icon_mipmaps = 4},}
bobmods.lib.recipe.clear_ingredients("bbr-rail-brick")
bobmods.lib.recipe.add_ingredient("bbr-rail-brick", {"iron-stick", 2})
bobmods.lib.recipe.add_ingredient("bbr-rail-brick", {"concrete", 20})
bobmods.lib.recipe.add_ingredient("bbr-rail-brick", {"steel-plate", 2})
bobmods.lib.recipe.add_ingredient("bbr-rail-brick", {"stone-crushed", 10})
bobmods.lib.recipe.set_energy_required("bbr-rail-brick", 2)
end
--###############################################################################################
--убираем рецепт бетона из бетона
data.raw["recipe"]["angels-concrete"].hidden = true
bobmods.lib.tech.remove_recipe_unlock("angels-stone-smelting-2", "angels-concrete")
-------------------------------------------------------------------------------------------------
--графические фиксы
data.raw.technology["plutonium-fuel-cell"].icon_size = 64
data.raw.technology["plutonium-fuel-cell"].icon_mipmaps = 4

data.raw.technology["thorium-plutonium-fuel-cell"].icon_size = 64
data.raw.technology["thorium-plutonium-fuel-cell"].icon_mipmaps = 4

data.raw.technology["effect-transmission"].icon = "__base__/graphics/technology/effect-transmission.png"
data.raw.technology["effect-transmission"].icon_size = 256

data.raw.technology["effect-transmission-2"].icon = "__base__/graphics/technology/effect-transmission.png"
data.raw.technology["effect-transmission-2"].icon_size = 256

data.raw.technology["effect-transmission-3"].icon = "__base__/graphics/technology/effect-transmission.png"
data.raw.technology["effect-transmission-3"].icon_size = 256

data.raw.technology["electric-energy-distribution-2"].icon = "__base__/graphics/technology/electric-energy-distribution-2.png"
data.raw.technology["electric-energy-distribution-2"].icon_size = 256

data.raw.technology["electric-substation-2"].icon = "__base__/graphics/technology/electric-energy-distribution-2.png"
data.raw.technology["electric-substation-2"].icon_size = 256

data.raw.technology["electric-substation-3"].icon = "__base__/graphics/technology/electric-energy-distribution-2.png"
data.raw.technology["electric-substation-3"].icon_size = 256

data.raw.technology["electric-substation-4"].icon = "__base__/graphics/technology/electric-energy-distribution-2.png"
data.raw.technology["electric-substation-4"].icon_size = 256

data.raw.technology["electric-energy-distribution-1"].icon = "__base__/graphics/technology/electric-energy-distribution-1.png"
data.raw.technology["electric-energy-distribution-1"].icon_size = 256

data.raw.technology["electric-pole-2"].icon = "__base__/graphics/technology/electric-energy-distribution-1.png"
data.raw.technology["electric-pole-2"].icon_size = 256

data.raw.technology["electric-pole-3"].icon = "__base__/graphics/technology/electric-energy-distribution-1.png"
data.raw.technology["electric-pole-3"].icon_size = 256

data.raw.technology["electric-pole-4"].icon = "__base__/graphics/technology/electric-energy-distribution-1.png"
data.raw.technology["electric-pole-4"].icon_size = 256

data.raw.technology["angels-advanced-gas-processing"].icons = {{icon = "__reskins-angels__/graphics/technology/petrochem/advanced-gas-processing/advanced-gas-processing-technology-base.png", icon_size = 256, icon_mipmaps = 2}}

if data.raw.technology["angels-advanced-gas-processing-2"] then
data.raw.technology["angels-advanced-gas-processing-2"].icons = {{icon = "__reskins-angels__/graphics/technology/petrochem/advanced-gas-processing/advanced-gas-processing-technology-base.png", icon_size = 256, icon_mipmaps = 2}}
end

data.raw.technology["advanced-ore-refining-5"].icon_size = 256
data.raw.technology["advanced-ore-refining-5"].icon_mipmaps = 4
--###############################################################################################
--будет вшито в биоиндустрию
--дробление камня в ангеловских дробилках руды
data.raw["assembling-machine"]["burner-ore-crusher"].crafting_categories = {"ore-refining-t1", "biofarm-mod-crushing"}
data.raw["assembling-machine"]["ore-crusher"].crafting_categories = {"ore-refining-t1", "biofarm-mod-crushing"}
data.raw["assembling-machine"]["ore-crusher-2"].crafting_categories = {"ore-refining-t1", "biofarm-mod-crushing"}
data.raw["assembling-machine"]["ore-crusher-3"].crafting_categories = {"ore-refining-t1", "biofarm-mod-crushing"}
data.raw["assembling-machine"]["ore-crusher-4"].crafting_categories = {"ore-refining-t1", "biofarm-mod-crushing"}
--коксование в доменке
data.raw["assembling-machine"]["blast-furnace"].crafting_categories = {"blast-smelting", "biofarm-mod-smelting"}
data.raw["assembling-machine"]["blast-furnace-2"].crafting_categories = {"blast-smelting", "blast-smelting-2", "biofarm-mod-smelting"}
data.raw["assembling-machine"]["blast-furnace-3"].crafting_categories = {"blast-smelting", "blast-smelting-2", "blast-smelting-3", "biofarm-mod-smelting"}
data.raw["assembling-machine"]["blast-furnace-4"].crafting_categories = {"blast-smelting", "blast-smelting-2", "blast-smelting-3", "blast-smelting-4", "biofarm-mod-smelting"}

----------------SEO fix----------------
--убираем неправильные зависимости
bobmods.lib.tech.remove_prerequisite("cement-mixture-1", "concrete") --бетон
bobmods.lib.tech.remove_prerequisite("angels-stone-smelting-2", "concrete") --бетон
bobmods.lib.tech.remove_prerequisite("plastic-1", "plastics") --пластик


-- добавляем зависимости в техологии для последовательности развития
bobmods.lib.tech.add_prerequisite ("concrete", "angels-stone-smelting-2") --бетон
bobmods.lib.tech.add_prerequisite ("bi-tech-wooden-storage-1", "bi-tech-resin-extraction") --деревянный ящик
bobmods.lib.tech.add_prerequisite ("angels-steel-smelting-1", "angels-nitrogen-processing-1") --сталь
bobmods.lib.tech.add_prerequisite ("angels-steel-smelting-1", "angels-flare-stack") --сталь
bobmods.lib.tech.add_prerequisite ("angels-invar-smelting-1", "zinc-processing") --сталь
bobmods.lib.tech.add_prerequisite ("plastics", "plastic-1") --пластик

--Фикс огромных аккумуляторов
bobmods.lib.recipe.add_ingredient("bi-bio-accumulator", {"accumulator", 30})

--Фикс магния
bobmods.lib.tech.remove_prerequisite("advanced-magnesium-smelting", "powder-metallurgy-1") --удаляем лишнюю
bobmods.lib.tech.add_prerequisite ("advanced-magnesium-smelting", "ore-processing-4") --добавить пресс гранулятор мк4
bobmods.lib.tech.add_prerequisite ("advanced-magnesium-smelting", "angels-metallurgy-4") --добавить доменки мк4

--Фикс обеднённого урана и осмия by Kiska Ra
bobmods.lib.tech.remove_prerequisite("advanced-depleted-uranium-smelting-1", "powder-metallurgy-1") --удаляем лишнюю
bobmods.lib.tech.remove_prerequisite("advanced-osmium-smelting", "powder-metallurgy-1")

--Фикс техи турбины
bobmods.lib.tech.remove_recipe_unlock("bob-steam-turbine-1", "steam-turbine") --удаляем вторую турбину мк1
bobmods.lib.tech.add_prerequisite ("bob-steam-turbine-1", "nuclear-power") --добавить теху в ядерку

--Добавляем осмий в лейт гейм рецепты
bobmods.lib.recipe.add_ingredient("hull-component", {"clowns-plate-osmium", 100})
bobmods.lib.recipe.add_ingredient("space-thruster", {"clowns-plate-osmium", 100})
bobmods.lib.recipe.add_ingredient("fuel-cell", {"clowns-plate-osmium", 100})
bobmods.lib.recipe.add_ingredient("habitation", {"clowns-plate-osmium", 100})
bobmods.lib.recipe.add_ingredient("life-support", {"clowns-plate-osmium", 100})
bobmods.lib.recipe.add_ingredient("command", {"clowns-plate-osmium", 100})
bobmods.lib.recipe.add_ingredient("astrometrics", {"clowns-plate-osmium", 100})
bobmods.lib.recipe.add_ingredient("ftl-drive", {"clowns-plate-osmium", 100})

--Баланс водных насосов
data.raw["assembling-machine"]["water-pumpjack-1"].energy_usage = "600kW"
data.raw["assembling-machine"]["water-pumpjack-2"].energy_usage = "1000kW"
data.raw["assembling-machine"]["water-pumpjack-3"].energy_usage = "1350kW"
data.raw["assembling-machine"]["water-pumpjack-4"].energy_usage = "1700kW"
data.raw["assembling-machine"]["water-pumpjack-5"].energy_usage = "2100kW"

data.raw["assembling-machine"]["water-pumpjack-1"].crafting_speed = 0.2
data.raw["assembling-machine"]["water-pumpjack-2"].crafting_speed = 0.4
data.raw["assembling-machine"]["water-pumpjack-3"].crafting_speed = 0.6
data.raw["assembling-machine"]["water-pumpjack-4"].crafting_speed = 0.8
data.raw["assembling-machine"]["water-pumpjack-5"].crafting_speed = 1

--Баланс агрегатора росы
data.raw["assembling-machine"]["dpa"].energy_usage = "1000kW"

--Синие фильтрующие манипуляторы встают на место
data.raw.technology["filter-inserters"].hidden = true
bobmods.lib.tech.add_recipe_unlock("express-inserters", "filter-inserter")

bobmods.lib.recipe.set_ingredient("landfill", {"stone", 50}) --Отсыпка по 50
if data.raw["technology"]["radars-1"] then
data.raw["technology"]["radars-1"].hidden = true --Убираем лишнее исследование на радар
end
bobmods.lib.tech.add_prerequisite ("radars-2", "radar") --Добавим радар1 к радару2
bobmods.lib.tech.remove_prerequisite("radars-2", "radars-1") --фикс радара 2

--Фикс пластин вольфрама и дешевых труб
bobmods.lib.recipe.set_ingredients("tungsten-carbide-x", { { "solid-carbon", 8 }, { "tungsten-oxide", 12 } }) 

bobmods.lib.tech.remove_recipe_unlock("tungsten-alloy-processing", "tungsten-carbide-2x")
data.raw["recipe"]["tungsten-carbide-2x"].hidden = true

data.raw["recipe"]["angels-copper-tungsten-pipe-casting"].hidden = true
data.raw["recipe"]["angels-copper-tungsten-pipe-to-ground-casting"].hidden = true
data.raw["recipe"]["angels-tungsten-pipe-casting"].hidden = true
data.raw["recipe"]["angels-tungsten-pipe-to-ground-casting"].hidden = true

bobmods.lib.tech.remove_recipe_unlock("angels-copper-tungsten-smelting-1", "angels-copper-tungsten-pipe-casting")
bobmods.lib.tech.remove_recipe_unlock("angels-copper-tungsten-smelting-1", "angels-copper-tungsten-pipe-to-ground-casting")
bobmods.lib.tech.remove_recipe_unlock("tungsten-alloy-processing", "angels-copper-tungsten-pipe-casting")
bobmods.lib.tech.remove_recipe_unlock("tungsten-alloy-processing", "angels-copper-tungsten-pipe-to-ground-casting")
bobmods.lib.tech.remove_recipe_unlock("angels-tungsten-smelting-1", "angels-tungsten-pipe-casting")
bobmods.lib.tech.remove_recipe_unlock("angels-tungsten-smelting-1", "angels-tungsten-pipe-to-ground-casting")

--рецепты для новых донных насосов
bobmods.lib.recipe.set_ingredients("seafloor-pump", { { "mining-drill-bit-mk1", 3 }, { "pipe", 25 }, { "basic-circuit-board", 10 }, { "iron-plate", 25 } }) 
bobmods.lib.recipe.set_ingredients("seafloor-pump-2", { { "mining-drill-bit-mk2", 3 }, { "steel-pipe", 30 }, { "electronic-circuit", 15 }, { "steel-plate", 30 }, { "seafloor-pump", 2 } }) 
bobmods.lib.recipe.set_ingredients("seafloor-pump-3", { { "mining-drill-bit-mk3", 3 }, { "titanium-pipe", 25 }, { "advanced-circuit", 15 }, { "titanium-plate", 25 }, { "seafloor-pump-2", 2 } }) 
bobmods.lib.tech.add_recipe_unlock("water-washing-2", "seafloor-pump-2")
bobmods.lib.tech.add_recipe_unlock("water-washing-3", "seafloor-pump-3")

--фикс кривых исследований углерода
bobmods.lib.tech.remove_recipe_unlock("angels-coal-processing-2", "coke-purification-3")
bobmods.lib.tech.remove_recipe_unlock("angels-coal-processing-3", "coke-purification-2")
bobmods.lib.tech.add_recipe_unlock("angels-coal-processing-3", "coke-purification-3")

--фикс недоступности исследования артиллерии
bobmods.lib.tech.remove_prerequisite("artillery", "radars-1")

--удалены зеленые катализаторы из дублирующего исследования (теперь он в шлаке где и должен быть)
bobmods.lib.tech.remove_recipe_unlock("geode-processing-2", "catalysator-green")

--перенос харкода из angelsrefining и исправление цен на здания на правильные
--Разжижители
bobmods.lib.recipe.set_ingredients("liquifier", { { "iron-plate", 40 }, { "basic-circuit-board", 3 }, { "pipe", 40 }, { "stone-brick", 60 } })
bobmods.lib.recipe.set_ingredients("liquifier-2", { { "bronze-alloy", 40 }, { "electronic-circuit", 3 }, { "bronze-pipe", 40 }, { "clay-brick", 60 }, { "liquifier", 2 } })
bobmods.lib.recipe.set_ingredients("liquifier-3", { { "aluminium-plate", 40 }, { "advanced-circuit", 3 }, { "brass-pipe", 40 }, { "concrete", 60 }, { "liquifier-2", 2 } })
bobmods.lib.recipe.set_ingredients("liquifier-4", { { "titanium-plate", 40 }, { "processing-unit", 3 }, { "titanium-pipe", 40 }, { "refined-concrete", 60 }, { "liquifier-3", 2 } })
-- --Термальный экстрактор
bobmods.lib.recipe.set_ingredients("thermal-extractor", { { "aluminium-plate", 24 }, { "advanced-circuit", 5 }, { "brass-pipe", 12 }, { "concrete", 20 }, { "brass-gear-wheel", 12 }, { "intermediate-structure-components", 5 } })
-- --Хим заводы
bobmods.lib.recipe.set_ingredients("angels-chemical-plant", { { "iron-plate", 40 }, { "basic-circuit-board", 3 }, { "pipe", 40 }, { "iron-gear-wheel", 25 } })
bobmods.lib.recipe.set_ingredients("angels-chemical-plant-2", { { "bronze-alloy", 40 }, { "electronic-circuit", 3 }, { "bronze-pipe", 40 }, { "steel-gear-wheel", 25 }, { "angels-chemical-plant", 2 } })
bobmods.lib.recipe.set_ingredients("angels-chemical-plant-3", { { "aluminium-plate", 40 }, { "advanced-circuit", 3 }, { "brass-pipe", 40 }, { "brass-gear-wheel", 25 }, { "angels-chemical-plant-2", 2 } })
bobmods.lib.recipe.set_ingredients("angels-chemical-plant-4", { { "titanium-plate", 40 }, { "processing-unit", 3 }, { "titanium-pipe", 40 }, { "titanium-gear-wheel", 25 }, { "angels-chemical-plant-3", 2 } })


--фикс стрелок порта для сероводорода промывочных машин
data.raw['assembling-machine']['washing-plant'].fluid_boxes[4].pipe_connections[1].type = "output"
data.raw['assembling-machine']['washing-plant-2'].fluid_boxes[4].pipe_connections[1].type = "output"

--Перенос Каркаса 1 в Металлургию 1 (AKMF)
bobmods.lib.tech.remove_recipe_unlock("steel-processing", "basic-structure-components")
bobmods.lib.tech.add_recipe_unlock("angels-metallurgy-1", "basic-structure-components")

--Перенос Каркаса 2, примитивного Цинка и Никеля в Металлургию 2 (AKMF)
bobmods.lib.tech.remove_recipe_unlock("angels-zinc-smelting-1", "zinc-electrolysis-x")
bobmods.lib.tech.remove_recipe_unlock("angels-nickel-smelting-1", "nickel-electrolysis-x")
bobmods.lib.tech.remove_recipe_unlock("angels-invar-smelting-1", "invar-alloy-x")
bobmods.lib.tech.add_recipe_unlock("angels-metallurgy-2", "zinc-electrolysis-x")
bobmods.lib.tech.add_recipe_unlock("angels-metallurgy-2", "nickel-electrolysis-x")
bobmods.lib.tech.add_recipe_unlock("angels-metallurgy-2", "invar-alloy-x")
bobmods.lib.tech.remove_recipe_unlock("angels-invar-smelting-1", "intermediate-structure-components")
bobmods.lib.tech.add_recipe_unlock("angels-metallurgy-2", "intermediate-structure-components")

--Перенос Каркаса 3, примитивного Титана и Кобальта в Металлургию 3 (AKMF https://discord.com/channels/569536773701500928/1196117081691795496)
bobmods.lib.tech.remove_recipe_unlock("angels-cobalt-smelting-1", "cobalat-electrolysis-x")
bobmods.lib.tech.remove_recipe_unlock("angels-titanium-smelting-1", "titanium-electrolysis-x")
bobmods.lib.tech.add_recipe_unlock("angels-metallurgy-3", "cobalat-electrolysis-x")
bobmods.lib.tech.add_recipe_unlock("angels-metallurgy-3", "titanium-electrolysis-x")
bobmods.lib.tech.remove_recipe_unlock("titanium-processing", "advanced-structure-components")
bobmods.lib.tech.add_recipe_unlock("angels-metallurgy-3", "advanced-structure-components")
