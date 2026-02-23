--data.raw["technology"]["xxx"].prerequisites = {"xxx", "xxx"}
--data.raw.technology["xxx"].hidden = true

--bobmods.lib.tech.add_recipe_unlock("technology", "recipe")
--bobmods.lib.tech.remove_recipe_unlock("technology", "recipe")

--bobmods.lib.tech.replace_prerequisite("technology", "old", "new")
--bobmods.lib.tech.add_prerequisite("technology", "prerequisite")
--bobmods.lib.tech.remove_prerequisite("technology", "prerequisite")

--bobmods.lib.recipe.add_ingredient("recipe", { type = "item", name = "ingredient", amount = 2})
--bobmods.lib.recipe.set_energy_required("recipe", 2)
--bobmods.lib.recipe.set_ingredient("recipe", { type = "item", name = "item", amount = 20})
--bobmods.lib.recipe.set_result("recipe", {name = "item", type = "item", amount = 5})

--###############################################################################################
--баланс мостовых рельс
if mods["beautiful_straight_bridge_railway"] then
	data.raw["rail-planner"]["bbr-rail-brick"].subgroup = "transport-rail"
	data.raw["rail-planner"]["bbr-rail-brick"].order = "d"
	data.raw["rail-planner"]["bbr-rail-brick"].icons =
		{ { icon = "__zzzparanoidal__/graphics/train/bbr-rail-brick-icon.png", size = 64, icon_mipmaps = 4 } }
	bobmods.lib.recipe.clear_ingredients("bbr-rail-brick")
	bobmods.lib.recipe.add_ingredient("bbr-rail-brick", { type = "item", name = "iron-stick", amount = 2 })
	bobmods.lib.recipe.add_ingredient("bbr-rail-brick", { type = "item", name = "concrete", amount = 20 })
	bobmods.lib.recipe.add_ingredient("bbr-rail-brick", { type = "item", name = "steel-plate", amount = 2 })
	bobmods.lib.recipe.add_ingredient("bbr-rail-brick", { type = "item", name = "angels-stone-crushed", amount = 10 })
	bobmods.lib.recipe.set_energy_required("bbr-rail-brick", 2)
end
--###############################################################################################
--будет вшито в биоиндустрию
--дробление камня в ангеловских дробилках руды
data.raw["assembling-machine"]["angels-burner-ore-crusher"].crafting_categories =
	{ "ore-refining-t1", "biofarm-mod-crushing" }
data.raw["assembling-machine"]["angels-ore-crusher"].crafting_categories = { "ore-refining-t1", "biofarm-mod-crushing" }
data.raw["assembling-machine"]["angels-ore-crusher-2"].crafting_categories =
	{ "ore-refining-t1", "biofarm-mod-crushing" }
data.raw["assembling-machine"]["angels-ore-crusher-3"].crafting_categories =
	{ "ore-refining-t1", "biofarm-mod-crushing" }
data.raw["assembling-machine"]["ore-crusher-4"].crafting_categories = { "ore-refining-t1", "biofarm-mod-crushing" }
--коксование в доменке
data.raw["assembling-machine"]["angels-blast-furnace"].crafting_categories =
	{ "blast-smelting", "biofarm-mod-smelting" }
data.raw["assembling-machine"]["angels-blast-furnace-2"].crafting_categories =
	{ "blast-smelting", "blast-smelting-2", "biofarm-mod-smelting" }
data.raw["assembling-machine"]["angels-blast-furnace-3"].crafting_categories =
	{ "blast-smelting", "blast-smelting-2", "blast-smelting-3", "biofarm-mod-smelting" }
data.raw["assembling-machine"]["angels-blast-furnace-4"].crafting_categories =
	{ "blast-smelting", "blast-smelting-2", "blast-smelting-3", "blast-smelting-4", "biofarm-mod-smelting" }

----------------SEO fix----------------

--Баланс водных насосов
-- data.raw["assembling-machine"]["water-pumpjack-1"].energy_usage = "600kW"
-- data.raw["assembling-machine"]["water-pumpjack-2"].energy_usage = "1000kW"
-- data.raw["assembling-machine"]["water-pumpjack-3"].energy_usage = "1350kW"
-- data.raw["assembling-machine"]["water-pumpjack-4"].energy_usage = "1700kW"
-- data.raw["assembling-machine"]["water-pumpjack-5"].energy_usage = "2100kW"

-- data.raw["assembling-machine"]["water-pumpjack-1"].crafting_speed = 0.2
-- data.raw["assembling-machine"]["water-pumpjack-2"].crafting_speed = 0.4
-- data.raw["assembling-machine"]["water-pumpjack-3"].crafting_speed = 0.6
-- data.raw["assembling-machine"]["water-pumpjack-4"].crafting_speed = 0.8
-- data.raw["assembling-machine"]["water-pumpjack-5"].crafting_speed = 1

--Баланс агрегатора росы
data.raw["assembling-machine"]["dpa"].energy_usage = "1000kW"

--Синие фильтрующие манипуляторы встают на место
data.raw.technology["filter-inserters"].hidden = true
bobmods.lib.tech.add_recipe_unlock("bob-express-inserter", "fast-inserter")

bobmods.lib.recipe.set_ingredient("landfill", { type = "item", name = "stone", amount = 50 }) --Отсыпка по 50

-- Seems like already fixed
--фикс стрелок порта для сероводорода промывочных машин
data.raw["assembling-machine"]["angels-washing-plant"].fluid_boxes[4].pipe_connections[1].type = "output"
data.raw["assembling-machine"]["angels-washing-plant-2"].fluid_boxes[4].pipe_connections[1].type = "output"

--###############################################################################################
--Последние правки Space X
data.raw["assembling-machine"]["space-telescope-uplink-station"].icon =
	"__expanded-rocket-payloads-continued__/graphic/space-telescope-uplink-station-32.png" --фикс неправильной иконки
data.raw["recipe"]["osmium-ore-processing"].category = "angels-ore-processing-4" --фикс слишком легкого осмия
data.raw["recipe"]["osmium-processed-processing"].category = "pellet-pressing-4" --фикс слишком легкого осмия
data.raw["recipe"]["osmium-pellet-smelting"].category = "blast-smelting-4" --фикс слишком легкого осмия
data.raw["recipe"]["casting-powder-osmium"].category = "powder-mixing-4" --фикс слишком легкого осмия
bobmods.lib.tech.add_prerequisite("astrometrics", "advanced-osmium-smelting") --Астрометрика под осмий
bobmods.lib.tech.add_recipe_unlock("bi-tech-stone-crushing-1", "stone-crushed-2") --открываем рецепт камня
data.raw["rocket-silo"]["rocket-silo"].energy_usage = "250000kW" --увеличиваем потребление энергии ракетной шахтой
data.raw["rocket-silo"]["rocket-silo"].module_specification.module_slots = 6 --но добавляем ей больше слотов модулей
bobmods.lib.tech.add_prerequisite("advanced-osmium-smelting", "angels-ore-processing-5") --фикс дерева осмия
bobmods.lib.tech.add_prerequisite("advanced-osmium-smelting", "angels-powder-metallurgy-5") --фикс дерева осмия
bobmods.lib.tech.remove_prerequisite("spidertron", "radar") --фикс паукатрона
--###############################################################################################
--Баланс телепортера под параноидал
bobmods.lib.recipe.set_ingredients("teleporter", {
	{ type = "item", name = "bob-speed-module-5", amount = 2 },
	{ type = "item", name = "space-science-pack", amount = 50 },
	{ type = "item", name = "bob-advanced-processing-unit", amount = 50 },
	{ type = "item", name = "low-density-structure", amount = 150 },
	{ type = "item", name = "bob-silver-zinc-battery", amount = 100 },
	{ type = "item", name = "bob-nitinol-alloy", amount = 150 },
})
data.raw.technology["teleporter"].unit.ingredients = {
	{ "automation-science-pack", 1 },
	{ "logistic-science-pack", 1 },
	{ "military-science-pack", 1 },
	{ "chemical-science-pack", 1 },
	{ "bob-advanced-logistic-science-pack", 1 },
	{ "production-science-pack", 1 },
	{ "utility-science-pack", 1 },
	{ "space-science-pack", 1 },
}
data.raw.technology["teleporter"].unit.count = 2000
bobmods.lib.tech.add_prerequisite("teleporter", "space-science-pack")
--###############################################################################################
-- попытка исправить ошибку с отсутсвием насоса на старте
data.raw.container["crash-site-spaceship"].minable = {
	mining_time = 5,
	results = {
		{ name = "steel-plate", amount_min = 5, amount_max = 25 },
		{ name = "iron-gear-wheel", amount_min = 5, amount_max = 20 },
		{ name = "electronic-circuit", amount_min = 4, amount_max = 12 },
		{ name = "concrete", amount_min = 25, amount_max = 85 },
		{ name = "pipe", amount_min = 5, amount_max = 45 },
		{ name = "bob-aluminium-plate", amount_min = 5, amount_max = 85 },
		{ name = "bob-titanium-plate", amount_min = 5, amount_max = 85 },
		{ name = "condensator3", amount_min = 5, amount_max = 35 },
		{ name = "bob-processing-electronics", amount_min = 1, amount_max = 5 },
		{ name = "bob-insulated-cable", amount_min = 11, amount_max = 39 },
		{ name = "salvaged-generator", amount = 1 },
		{ name = "offshore-mk0-pump", amount = 1 },
	},
}
