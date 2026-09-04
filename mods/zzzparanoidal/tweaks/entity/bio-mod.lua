require("__zzzparanoidal__.paralib")
-- BI 2.0 не создаёт техи bi-tech-bio-farming-2/3/4 (были в BI 1.1 new_tech.lua, удалены при конверсии).
-- Тиры вешаем на техи-хосты рецептов роста, которые они крафтят: MK2 -> fertilizer (bi-*-3), MK3 -> advanced-biotechnology (bi-*-4).
paralib.bobmods.lib.tech.add_recipe_unlock("bi-tech-fertilizer", "bi-bio-farm-2") --открываем рецепт биофермы 2
paralib.bobmods.lib.tech.add_recipe_unlock("bi-tech-fertilizer", "bi-bio-greenhouse-2") --открываем рецепт теплицы 2
paralib.bobmods.lib.tech.add_recipe_unlock("bi-tech-advanced-biotechnology", "bi-bio-farm-3") --открываем рецепт биофермы 3
paralib.bobmods.lib.tech.add_recipe_unlock("bi-tech-advanced-biotechnology", "bi-bio-greenhouse-3") --открываем рецепт теплицы 3

data.raw["recipe"]["bi-logs-3"].category = "biofarm-mod-farm-2" -- Прячем рецепты под новую ферму 2
data.raw["recipe"]["bi-logs-4"].category = "biofarm-mod-farm-3" -- Прячем рецепты под новую ферму 3
data.raw["recipe"]["bi-seed-3"].category = "biofarm-mod-greenhouse-2" -- Прячем рецепты под новую теплицу 2
data.raw["recipe"]["bi-seedling-3"].category = "biofarm-mod-greenhouse-2" -- Прячем рецепты под новую теплицу 2
data.raw["recipe"]["bi-seed-4"].category = "biofarm-mod-greenhouse-3" -- Прячем рецепты под новую теплицу 3
data.raw["recipe"]["bi-seedling-4"].category = "biofarm-mod-greenhouse-3" -- Прячем рецепты под новую теплицу 3

data.raw["assembling-machine"]["bi-bio-reactor"].energy_usage = "200kW" --увеличиваем потребление биореактора мк 1
data.raw["assembling-machine"]["bi-bio-reactor"].module_slots = 1 -- 1 слот модулей для мк1
paralib.bobmods.lib.recipe.set_ingredients(
	"bi-bio-reactor",
	{ { type = "item", name = "assembling-machine-1", amount = 2}, { type = "item", name = "steel-plate", amount = 20}, { type = "item", name = "bob-basic-circuit-board", amount = 5} }
) --баланс рецепта биореактора 1
-- BI 2.0 не создаёт техи bi-tech-biomass-reprocessing-1/2 (были в BI 1.1); рецепт biomass-2 открывает advanced-biotechnology — туда же вешаем реактор MK2
paralib.bobmods.lib.tech.add_recipe_unlock("bi-tech-advanced-biotechnology", "bi-bio-reactor-2") --открываем рецепт биореактора 2
-- Фиолетовый тир 1.1 (целлюлоза 2, батарея, биомасса 3, биореактор MK3) отдан своей
-- bi-tech-advanced-biotechnology-2 — она же открывает реактор MK3
paralib.bobmods.lib.tech.remove_recipe_unlock("bi-tech-advanced-biotechnology", "bi-cellulose-2")
paralib.bobmods.lib.tech.remove_recipe_unlock("bi-tech-advanced-biotechnology", "bi-battery")
paralib.bobmods.lib.tech.remove_recipe_unlock("bi-tech-advanced-biotechnology", "bi-biomass-3")
data.raw["recipe"]["bi-biomass-2"].category = "biofarm-mod-bioreactor-2" -- Прячем рецепты под новый биореактор 2
data.raw["recipe"]["bi-biomass-3"].category = "biofarm-mod-bioreactor-3" -- Прячем рецепты под новый биореактор 3

paralib.bobmods.lib.recipe.remove_ingredient("bi-bio-greenhouse", "glass")
data.raw.item["bi-bio-greenhouse"].subgroup = "bio-bio-farm-fluid-entity"
data.raw.item["bi-bio-farm"].subgroup = "bio-bio-farm-fluid-entity"