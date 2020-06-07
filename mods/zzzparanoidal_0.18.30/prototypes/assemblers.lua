

--фикс рецептов
bobmods.lib.recipe.add_ingredient("assembling-machine-7", {"copper-tungsten-alloy", 2500})
bobmods.lib.recipe.add_ingredient("assembling-machine-7", {"advanced-processing-unit", 25})
bobmods.lib.recipe.add_ingredient("assembling-machine-7", {"anotherworld-structure-components", 2})

bobmods.lib.recipe.add_ingredient("electronics-machine-4", {"advanced-processing-unit", 5})
bobmods.lib.recipe.add_ingredient("electronics-machine-4", {"copper-tungsten-alloy", 1000})
bobmods.lib.recipe.add_ingredient("electronics-machine-4", {"anotherworld-structure-components", 5})

bobmods.lib.recipe.add_ingredient("assembling-machine-8", {"clowns-plate-magnesium", 2500})
bobmods.lib.recipe.add_ingredient("assembling-machine-8", {"advanced-processing-unit", 50})
bobmods.lib.recipe.add_ingredient("assembling-machine-8", {"anotherworld-structure-components", 5})

bobmods.lib.recipe.add_ingredient("electronics-machine-5", {"clowns-plate-magnesium", 1000})
bobmods.lib.recipe.add_ingredient("electronics-machine-5", {"advanced-processing-unit", 50})
bobmods.lib.recipe.add_ingredient("electronics-machine-5", {"anotherworld-structure-components", 10})

bobmods.lib.recipe.add_ingredient("assembling-machine-9", {"clowns-plate-depleted-uranium", 2500})
bobmods.lib.recipe.add_ingredient("assembling-machine-9", {"advanced-processing-unit", 100})
bobmods.lib.recipe.add_ingredient("assembling-machine-9", {"anotherworld-structure-components", 10})

--фикс загрязнений
data.raw["assembling-machine"]["assembling-machine-7"].energy_source.emissions_per_minute = 0.3
data.raw["assembling-machine"]["assembling-machine-8"].energy_source.emissions_per_minute = 0.2
data.raw["assembling-machine"]["assembling-machine-9"].energy_source.emissions_per_minute = 0.1
data.raw["assembling-machine"]["electronics-machine-4"].energy_source.emissions_per_minute = 0.3
data.raw["assembling-machine"]["electronics-machine-5"].energy_source.emissions_per_minute = 0.2

-- размажем ассемблеры по разным стадиям игры 
bobmods.lib.tech.add_prerequisite("automation-7", "space-science-pack")
bobmods.lib.tech.add_prerequisite("electronics-machine-4", "space-science-pack")
bobmods.lib.recipe.add_ingredient("assembling-machine-7", {"space-science-pack", 5})
bobmods.lib.recipe.add_ingredient("electronics-machine-4", {"space-science-pack", 5})

bobmods.lib.tech.add_prerequisite("automation-8", "observation-satellite")
bobmods.lib.tech.add_prerequisite("electronics-machine-5", "observation-satellite")
bobmods.lib.recipe.add_ingredient("assembling-machine-8", {"planetary-data", 1})
bobmods.lib.recipe.add_ingredient("electronics-machine-5", {"planetary-data", 1})

bobmods.lib.tech.add_prerequisite("automation-9", "space-lab")
bobmods.lib.recipe.add_ingredient("assembling-machine-9", {"station-science", 1})