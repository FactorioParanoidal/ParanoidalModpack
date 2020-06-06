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
if data.raw.item["thorium-ore"] then
	table.insert(data.raw["technology"]["mixed-oxide-fuel"].effects, {type = "unlock-recipe", recipe = "thorium-mixed-oxide"})
	bobmods.lib.recipe.replace_ingredient("thorium-fuel-cell", "iron-plate", "lead-plate")
	bobmods.lib.recipe.replace_ingredient("thorium-mixed-oxide", "iron-plate", "lead-plate")
	bobmods.lib.recipe.replace_ingredient("mixed-oxide", "iron-plate", "lead-plate")
else
	table.insert(data.raw["technology"]["nuclear-fuel-reprocessing-2"].effects, {type = "unlock-recipe", recipe = "advanced-nuclear-fuel-reprocessing-2"})
end
--table.replace(data.raw["technology"]["atomic-bomb"].prerequisites, {"kovarex-enrichment-process","advanced-centrifuging-2"})
bobmods.lib.tech.replace_prerequisite("atomic-bomb", "kovarex-enrichment-process", "centrifuging-2")
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
--clobber vanilla and angels nuclear fuel recipes
if data.raw.technology["angels-nuclear-fuel"] then
	--bobmods.lib.tech.replace_prerequisite("nuclear-fuel-1", "rocket-fuel", "angels-rocket-fuel")
	data.raw.technology["angels-nuclear-fuel"].enabled=false
end
if data.raw.technology["nuclear-fuel"] then
	data.raw.technology["nuclear-fuel"].enabled=false
end
