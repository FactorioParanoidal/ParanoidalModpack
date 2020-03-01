--research.lua

data:extend {
	
{
	type = "technology",
	name = "ret-electric-locomotives",
	icon_size = 128,
	icon = graphics .. "technology/electric-trains.png",
	effects = {
		{ type = "unlock-recipe", recipe = "ret-electric-locomotive" },
		{ type = "unlock-recipe", recipe = "ret-power-pole" },
		{ type = "unlock-recipe", recipe = "ret-signal-pole" },
		{ type = "unlock-recipe", recipe = "ret-chain-pole" },
		{ type = "unlock-recipe", recipe = "ret-pole-debugger" }
	},
	prerequisites = { "railway", "electric-engine"},
	unit =
	{
		count = 200,
		ingredients =
		{
			{"automation-science-pack", 1},
			{"logistic-science-pack", 1},
			{"chemical-science-pack", 1}
		},
		time = 30
	},
	order = "c-g-c"
},

{
	type = "technology",
	name = "ret-electric-locomotives-mk2",
	icon_size = 128,
	icon = graphics .. "technology/advanced-electric-trains.png",
	effects = {
		{ type = "unlock-recipe", recipe = "ret-electric-locomotive-mk2" }
	},
	prerequisites = { "ret-electric-locomotives", "advanced-electronics-2" },
	unit =
	{
		count = 500,
		ingredients =
		{
			{"automation-science-pack", 1},
			{"logistic-science-pack", 1},
			{"chemical-science-pack", 1}
		},
		time = 30
	},
	order = "c-g-d"
},

{
	type = "technology",
	name = "ret-modular-locomotives",
	icon_size = 128,
	icon = graphics .. "technology/modular-trains.png",
	effects = {
		{ type = "unlock-recipe", recipe = "ret-modular-locomotive" },
		{ type = "unlock-recipe", recipe = "ret-train-speed-module" },
		{ type = "unlock-recipe", recipe = "ret-train-productivity-module" },
		{ type = "unlock-recipe", recipe = "ret-train-efficiency-module" },
		{ type = "unlock-recipe", recipe = "ret-train-battery-module" }
	},
	prerequisites = { "ret-electric-locomotives-mk2", "speed-module-3",
						"productivity-module-3", "effectivity-module-3"},
	unit = 
	{
		count = 500,
		ingredients = 
		{
			{"automation-science-pack", 1},
			{"logistic-science-pack", 1},
			{"chemical-science-pack", 1},
			{"utility-science-pack", 1}
		},
		time = 30
	},
	order = "c-g-e"
}

}