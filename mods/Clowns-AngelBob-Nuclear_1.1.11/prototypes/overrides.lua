--REPLACE URANIUM HEXAFLUORIDE CENTRIFUGING RECIPE
data.raw.technology["advanced-uranium-processing-1"].effects =
{
	{
		type = "unlock-recipe",
		recipe = "solid-uranium-hexafluoride"
	},
	{
		type = "unlock-recipe",
		recipe = "solid-uranium-tetrafluoride"
	},
	{
		type = "unlock-recipe",
		recipe = "solid-uranium-oxide-1"
	},
	{
		type = "unlock-recipe",
		recipe = "clowns-centrifuging-20%-hexafluoride"
	},
}

table.insert(data.raw["technology"]["mixed-oxide-fuel"].effects, {type = "unlock-recipe", recipe = "thorium-mixed-oxide"})
--table.replace(data.raw["technology"]["atomic-bomb"].prerequisites, {"kovarex-enrichment-process","advanced-centrifuging-2"})
bobmods.lib.tech.replace_prerequisite("atomic-bomb", "kovarex-enrichment-process", "centrifuging-2")
bobmods.lib.recipe.replace_ingredient("thorium-fuel-cell", "iron-plate", "lead-plate")
bobmods.lib.recipe.replace_ingredient("mixed-oxide", "iron-plate", "lead-plate")
bobmods.lib.recipe.replace_ingredient("thorium-mixed-oxide", "iron-plate", "lead-plate")
angelsmods.functions.make_void("water-radioactive-waste", "water")
data.raw.recipe["uranium-processing"].results =
{
	{
		name = "35%-uranium",
		probability = 0.007,
		amount = 1
	},
	{
		name = "uranium-238",
		probability = 0.993,
		amount = 1
	}
}
