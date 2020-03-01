data:extend
({
  {
    type = "technology",
    name = "inserter-capacity-bonus-8",
    icon = "__base__/graphics/technology/inserter-capacity.png",
    icon_size = 128,
    prerequisites = {"inserter-capacity-bonus-7", "space-science-pack"},
	effects =
	{
	  {
		type = "inserter-stack-size-bonus",
		modifier = 0.5
	  },
	  {
		type = "stack-inserter-capacity-bonus",
		modifier = 2
	  }
	},
    unit =
    {
      count_formula = "2^(L-7)*1000",
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
        {"space-science-pack", 1}
      },
      time = 60
    },
    max_level = "infinite",
    upgrade = true,
    order = "c-k-f-e"
  }
})