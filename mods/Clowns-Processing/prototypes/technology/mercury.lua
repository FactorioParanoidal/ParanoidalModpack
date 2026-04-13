data:extend(
{
	{
		type = "technology",
		name = "mercury-processing-1",
		icon_size = 128,
		icon = "__Clowns-Processing__/graphics/technology/mercury-tech.png",
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "clowns-thermal-filtering-mercury"
			},
		},
		prerequisites = {"angels-thermal-water-extraction-2"},
		unit =
		{
			ingredients =
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
			},
			time = 30,
			count = 50
		},
		order = "e"
	},
  {
    type = "technology",
    name = "mercury-processing-2",
    icon_size = 128,
    icon = "__Clowns-Processing__/graphics/technology/mercury-tech.png",
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "clowns-dimethylmercury-synthesis"
      },
      {
        type = "unlock-recipe",
        recipe = "clowns-neurotoxin-capsule"
      },
    },
    prerequisites = {"mercury-processing-1", "military-3", "angels-sodium-processing-1", "angels-chlorine-processing-2", "processing-unit"},
    unit =
    {
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"military-science-pack", 1},
      },
      time = 30,
      count = 50
    },
    order = "e"
  },
})
if mods["angelsbioprocessing"] then
  local techi = data.raw.technology["mercury-processing-2"]
  table.insert(techi.effects,{type = "unlock-recipe", recipe = "clowns-algae-violet"})
  table.insert(techi.effects,{type = "unlock-recipe", recipe = "clowns-methylmercury-algae"})
  table.insert(techi.prerequisites,"angels-bio-processing-blue")
end