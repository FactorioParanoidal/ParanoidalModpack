if mods["angelsbioprocessing"] then
  data:extend(
{
	{
		type = "technology",
		name = "garden-mutation",
		icon = "__angelsbioprocessing__/graphics/technology/seed-extractor-tech.png",
		icon_size = 128,
		order = "c",
		prerequisites =
		{
			"nuclear-power",
			"gardens"
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
				{"token-bio", 1}
			},
			time = 30
		},
	},
}
)
	local recipes={"desert-garden-generation","swamp-garden-generation","temperate-garden-generation"}
	for _,rec in pairs(recipes) do
		table.insert(data.raw["technology"]["bio-farm-1"].effects,{type = "unlock-recipe", recipe = rec})
	end
	table.insert(data.raw["technology"]["bio-farm-1"].prerequisites,"phosphorus-processing-1")
end