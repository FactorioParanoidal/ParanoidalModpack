data:extend{
	{
		type = "technology",
		name = "enable-logistics-tab",
		icon_size = 256,
		icon = "__even-distribution__/graphics/tech.png",
		enabled = false,
		hidden = true,
		effects =
		{
		  {
			type = "character-logistic-requests",
			modifier = true
		  },
		  {
			type = "character-logistic-trash-slots",
			modifier = 10
		  }
		},
		unit =
		{
		  count = 1,
		  ingredients = {},
		  time = 1,
		},
		order = "zzzz",
	  },
}