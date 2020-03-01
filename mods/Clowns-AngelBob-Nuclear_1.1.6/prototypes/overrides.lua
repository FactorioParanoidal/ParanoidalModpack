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
