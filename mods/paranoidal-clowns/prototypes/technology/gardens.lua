if mods["angelsbioprocessing"] then
  data:extend(
		{
			{
				type = "technology",
				name = "garden-mutation",
				icon = "__angelsbioprocessinggraphics__/graphics/technology/seed-extractor-tech.png",
				icon_size = 128,
				order = "c",
				prerequisites =
				{
					"nuclear-power",
					"angels-gardens-3",
         			"utility-science-pack"
				},
				effects =
				{
					{
						type = "unlock-recipe",
						recipe = "temperate-garden-mutation"
					},
					{
						type = "unlock-recipe",
						recipe = "desert-garden-mutation"
					},
					{
						type = "unlock-recipe",
						recipe = "swamp-garden-mutation"
					},
				},
				unit =
				{
					count = 64,
					ingredients =
					{
						{"automation-science-pack", 4},
						{"logistic-science-pack", 4},
						{"chemical-science-pack", 4},
						{"utility-science-pack", 4},
						{"angels-token-bio", 1}
					},
					time = 30
				},
			},
		}
	)
	local recipes = {
    "clowns-diammonium-phosphate-fertilizer",
    "desert-garden-generation",
    "swamp-garden-generation",
    "temperate-garden-generation"
  }
	for _,rec in pairs(recipes) do
		table.insert(data.raw["technology"]["angels-bio-farm-2"].effects,{type = "unlock-recipe", recipe = rec})
	end
	table.insert(data.raw["technology"]["angels-bio-farm-2"].prerequisites,"phosphorus-processing-1")
end