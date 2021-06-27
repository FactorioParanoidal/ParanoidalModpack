if data.raw.item["thorium-fuel-cell"] then
  data:extend(
{
	{
		type = "technology",
		name = "thorium-ore-processing",
		icon_size = 128,
		icon = "__Clowns-AngelBob-Nuclear__/graphics/technology/thorium-processing.png",
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "thorium-purification"
			},
      {
				type = "unlock-recipe",
				recipe = "thorium-crystallisation"
			},
      {
				type = "unlock-recipe",
				recipe = "thorium-ore-processing"
			},
		},
		prerequisites = {
			"advanced-uranium-processing-2",
	},
		unit =
		{
			ingredients =
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
        {"production-science-pack",1}
			},
			time = 30,
			count = 100
		},
		order = "e-p-b-c"
	},

}
)
clowns.functions.add_prereq("mixed-oxide-fuel","thorium-ore-processing")
end