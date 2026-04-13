data:extend(
{
	{
		type = "technology",
		name = "angels-water-treatment-5",
		icon = "__angelsrefininggraphics__/graphics/technology/water-treatment.png",
		icon_size = 128,
		prerequisites =
		{
			"angels-water-treatment-4",
		},
		effects =
		{
		  {
			type = "unlock-recipe",
			recipe = "advanced-salination"
		  },
		},
		unit =
		{
		  count = 30,
		  ingredients = {
		  {"automation-science-pack", 1},
		  {"logistic-science-pack", 1},
		  {"chemical-science-pack", 1},
		  {"production-science-pack", 1},
		  },
		  time = 15
		},
		order = "c-a"
	},
}
)