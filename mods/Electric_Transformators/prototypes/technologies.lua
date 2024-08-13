

-------technologies---------------------------------------------------------------------------
data:extend({
	{
		type = "technology",
		name = "trafo-s",
		icon = TRAFOS_GRAPHICS_BASE.."/technologies/tier-1.png",
		icon_size = 128,
		order = "c-e-c",
		prerequisites = {"electronics", "logistics"},
		effects = {{ type = "unlock-recipe", recipe = "trafo-1" }},
		unit = {
			count = 70,
			time = 30,
			ingredients = {
				{"automation-science-pack", 1}
			},
		},
	},
	--------------------
	{
		type = "technology",
		name = "trafo-m",
		icon = TRAFOS_GRAPHICS_BASE.."/technologies/tier-2.png",
		icon_size = 128,
		order = "c-e-c",
		prerequisites = {"advanced-electronics", "automation-2", "trafo-s"},
		effects = {{ type = "unlock-recipe", recipe = "trafo-2" }},
		unit = {
			count = 70,
			time = 30,
			ingredients = {
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
			},
		},
	},
	--------------------
	{
		type = "technology",
		name = "trafo-l",
		icon = TRAFOS_GRAPHICS_BASE.."/technologies/tier-3.png",
		icon_size = 128,
		order = "c-e-c",
		prerequisites = {"electric-energy-accumulators", "electric-energy-distribution-1", "trafo-m"},
		effects = {{ type = "unlock-recipe", recipe = "trafo-3" }},
		unit = {
			count = 90,
			time = 30,
			ingredients = {
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
			},
		},
	},
	--------------------
	{
		type = "technology",
		name = "trafo-xl",
		icon = TRAFOS_GRAPHICS_BASE.."/technologies/tier-4.png",
		icon_size = 128,
		order = "c-e-c",
		prerequisites = { "advanced-electronics-2", "electric-energy-distribution-2", "effectivity-module", "trafo-l"},
		effects = {{ type = "unlock-recipe", recipe = "trafo-4" }},
		unit = {
			count = 150,
			time = 60,
			ingredients = {
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
				{"production-science-pack",1} 
			},
		},
	},
	--------------------
	{
		type = "technology",
		name = "trafo-xxl",
		icon = TRAFOS_GRAPHICS_BASE.."/technologies/tier-5.png",
		icon_size = 128,
		order = "c-e-c",
		prerequisites = {"automation-3", "effectivity-module-2", "trafo-xl"},
		effects = {{ type = "unlock-recipe", recipe = "trafo-5" }},
		unit = {
			count = 600,
			time = 60,
			ingredients = {
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
				{"production-science-pack",4} },
		},
	},
})

