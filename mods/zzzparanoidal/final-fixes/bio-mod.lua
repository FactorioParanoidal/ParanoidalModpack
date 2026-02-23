bobmods.lib.tech.add_recipe_unlock("bi-tech-bio-farming-3", "bi-bio-farm-2") --открываем рецепт биофермы 2
bobmods.lib.tech.add_recipe_unlock("bi-tech-bio-farming-3", "bi-bio-greenhouse-2") --открываем рецепт теплицы 2
bobmods.lib.tech.add_recipe_unlock("bi-tech-bio-farming-4", "bi-bio-farm-3") --открываем рецепт биофермы 3
bobmods.lib.tech.add_recipe_unlock("bi-tech-bio-farming-4", "bi-bio-greenhouse-3") --открываем рецепт теплицы 3

data.raw["recipe"]["bi-logs-3"].category = "biofarm-mod-farm-2" -- Прячем рецепты под новую ферму 2
data.raw["recipe"]["bi-logs-4"].category = "biofarm-mod-farm-3" -- Прячем рецепты под новую ферму 3
data.raw["recipe"]["bi-seed-3"].category = "biofarm-mod-greenhouse-2" -- Прячем рецепты под новую теплицу 2
data.raw["recipe"]["bi-seedling-3"].category = "biofarm-mod-greenhouse-2" -- Прячем рецепты под новую теплицу 2
data.raw["recipe"]["bi-seed-4"].category = "biofarm-mod-greenhouse-3" -- Прячем рецепты под новую теплицу 3
data.raw["recipe"]["bi-seedling-4"].category = "biofarm-mod-greenhouse-3" -- Прячем рецепты под новую теплицу 3

data.raw["assembling-machine"]["bi-bio-reactor"].energy_usage = "200kW" --увеличиваем потребление биореактора мк 1
data.raw["assembling-machine"]["bi-bio-reactor"].module_specification.module_slots = 1 -- 1 слот модулей для мк1
bobmods.lib.recipe.set_ingredients(
	"bi-bio-reactor",
	{ { type = "item", name = "assembling-machine-1", amount = 2}, { type = "item", name = "steel-plate", amount = 20}, { type = "item", name = "bob-basic-circuit-board", amount = 5} }
) --баланс рецепта биореактора 1
bobmods.lib.tech.add_recipe_unlock("bi-tech-biomass-reprocessing-1", "bi-bio-reactor-2") --открываем рецепт биореактора 2
bobmods.lib.tech.add_recipe_unlock("bi-tech-biomass-reprocessing-2", "bi-bio-reactor-3") --открываем рецепт биореактора 3
data.raw["recipe"]["bi-biomass-2"].category = "biofarm-mod-bioreactor-2" -- Прячем рецепты под новый биореактор 2
data.raw["recipe"]["bi-biomass-3"].category = "biofarm-mod-bioreactor-3" -- Прячем рецепты под новый биореактор 2
bobmods.lib.tech.add_prerequisite("bi-tech-bio-farming-3", "concrete") -- Технологии под Бетон
