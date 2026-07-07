-- Восстановление 1.1-баланса машин MilesBobsExpansion2 (тиры 7-9 + electronics 4-5):
-- модификаторы 1.1 (marathon/Angels/SpaceMod/RAWs) к машинам Miles в 2.0 не цепляются,
-- воспроизводим итоговые рецепты вручную (сверено с 1.1 --dump-data).
-- Bob's 2.0 срезал модули до тира 5: срезанный тир → набор тир-5 (speed-6 → speed-5+prod-5,
-- speed-7 → speed-5+prod-5+efficiency-5).
if mods["MilesBobsExpansion2"] then
	local set = paralib.bobmods.lib.recipe.set_ingredients

	set("assembling-machine-7", {
		{ type = "item", name = "bob-assembling-machine-6", amount = 2 },
		{ type = "item", name = "bob-brass-gear-wheel", amount = 250 },
		{ type = "item", name = "bob-speed-module-5", amount = 10 },
		{ type = "item", name = "bob-copper-tungsten-alloy", amount = 2500 },
		{ type = "item", name = "bob-advanced-processing-unit", amount = 25 },
		{ type = "item", name = "anotherworld-structure-components", amount = 2 },
		{ type = "item", name = "space-science-pack", amount = 5 },
	})
	data.raw.recipe["assembling-machine-7"].energy_required = 50

	set("assembling-machine-8", {
		{ type = "item", name = "assembling-machine-7", amount = 2 },
		{ type = "item", name = "bob-cobalt-steel-gear-wheel", amount = 500 },
		{ type = "item", name = "bob-speed-module-5", amount = 10 },
		{ type = "item", name = "bob-productivity-module-5", amount = 10 },
		{ type = "item", name = "clowns-plate-magnesium", amount = 2500 },
		{ type = "item", name = "bob-advanced-processing-unit", amount = 50 },
		{ type = "item", name = "anotherworld-structure-components", amount = 5 },
		{ type = "item", name = "planetary-data", amount = 1 },
	})
	data.raw.recipe["assembling-machine-8"].energy_required = 60

	set("assembling-machine-9", {
		{ type = "item", name = "assembling-machine-8", amount = 2 },
		{ type = "item", name = "bob-speed-module-5", amount = 5 },
		{ type = "item", name = "bob-productivity-module-5", amount = 5 },
		{ type = "item", name = "bob-efficiency-module-5", amount = 5 },
		{ type = "item", name = "clowns-plate-depleted-uranium", amount = 2500 },
		{ type = "item", name = "bob-advanced-processing-unit", amount = 100 },
		{ type = "item", name = "anotherworld-structure-components", amount = 10 },
		{ type = "item", name = "station-science", amount = 1 },
	})
	data.raw.recipe["assembling-machine-9"].energy_required = 60

	set("electronics-machine-4", {
		{ type = "item", name = "bob-electronics-machine-3", amount = 4 },
		{ type = "item", name = "bob-nitinol-gear-wheel", amount = 100 },
		{ type = "item", name = "bob-speed-module-4", amount = 5 },
		{ type = "item", name = "bob-advanced-processing-unit", amount = 5 },
		{ type = "item", name = "bob-copper-tungsten-alloy", amount = 1000 },
		{ type = "item", name = "anotherworld-structure-components", amount = 5 },
		{ type = "item", name = "space-science-pack", amount = 5 },
	})
	data.raw.recipe["electronics-machine-4"].energy_required = 20

	set("electronics-machine-5", {
		{ type = "item", name = "electronics-machine-4", amount = 4 },
		{ type = "item", name = "bob-gilded-copper-cable", amount = 500 },
		{ type = "item", name = "bob-speed-module-5", amount = 5 },
		{ type = "item", name = "bob-productivity-module-5", amount = 5 },
		{ type = "item", name = "clowns-plate-magnesium", amount = 1000 },
		{ type = "item", name = "bob-advanced-processing-unit", amount = 50 },
		{ type = "item", name = "anotherworld-structure-components", amount = 10 },
		{ type = "item", name = "planetary-data", amount = 1 },
	})
	data.raw.recipe["electronics-machine-5"].energy_required = 30
end
