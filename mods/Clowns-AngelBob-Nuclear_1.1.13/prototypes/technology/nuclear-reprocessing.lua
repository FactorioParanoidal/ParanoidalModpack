data:extend(
{
	{
		type = "technology",
		name = "nuclear-fuel-reprocessing-2",
		icon_size = 128,
		icon = "__base__/graphics/technology/nuclear-fuel-reprocessing.png",
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "advanced-nuclear-fuel-reprocessing"
			},
		},
		prerequisites = {"nuclear-fuel-reprocessing"},
		unit =
		{
			ingredients =
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
				{"production-science-pack", 1}
			},
			time = 30,
			count = 2000
		},
		order = "e-p-b-c"
	},
})
if data.raw.item["thorium-ore"] then
data:extend(
{
	{
		type = "technology",
		name = "thorium-nuclear-fuel-reprocessing-2",
		icon_size = 128,
		icon = "__Clowns-Nuclear__/graphics/technology/thorium-nuclear-fuel-reprocessing.png",
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "advanced-thorium-nuclear-fuel-reprocessing"
			},
			{
				type = "unlock-recipe",
				recipe = "advanced-thorium-nuclear-fuel-reprocessing|b"
			},
		},
		prerequisites = {"bobingabout-enrichment-process"},
		unit =
		{
			ingredients =
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
				{"production-science-pack", 1}
			},
			time = 30,
			count = 2000
		},
		order = "e-p-b-c"
	}
}
)
end
