data:extend(
{
	{
		type = "technology",
		name = "advanced-magnesium-smelting",
		icon_size = 128,
		icon = "__paranoidal-clowns__/graphics/technology/smelting-magnesium.png",
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "clowns-magnesium-ore-processing"
			},
			{
				type = "unlock-recipe",
				recipe = "clowns-magnesium-processed-processing"
			},
			{
				type = "unlock-recipe",
				recipe = "clowns-magnesium-pellet-smelting"
			},
			{
				type = "unlock-recipe",
				recipe = "clowns-molten-magnesium-smelting"
			},
			{
				type = "unlock-recipe",
				recipe = "clowns-plate-magnesium"
			},
		},
		prerequisites = {"angels-ore-processing-3", "angels-water-treatment-4"},
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
			count = 100
		},
		order = "e"
	},

	{
		type = "technology",
		name = "advanced-magnesium-smelting-2",
		icon_size = 128,
		icon = "__paranoidal-clowns__/graphics/technology/smelting-magnesium.png",
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "molten-iron-smelting-6"
			},
			{
				type = "unlock-recipe",
				recipe = "molten-aluminium-smelting-4"
			},
		},
		prerequisites = {"advanced-magnesium-smelting", "phosphorus-processing-2", "angels-manganese-smelting-1", "utility-science-pack"},
		unit =
		{
			ingredients =
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
				{"production-science-pack", 1},
				{"utility-science-pack", 1 }
			},
			time = 30,
			count = 150
		},
		order = "e"
	},
}
)

if data.raw.recipe["molten-steel-smelting-c2"] then
  table.insert(data.raw.technology["advanced-magnesium-smelting-2"].effects, 2, { type = "unlock-recipe", recipe = "molten-steel-smelting-c2" })
end
