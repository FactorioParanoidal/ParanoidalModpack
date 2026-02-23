data:extend(
{
	{
		type = "technology",
		name = "w93-scattergun-turrets",
		icon = "__scattergun_turret__/graphics/technology/scattergun-turret-tech.png",
		icon_size = 128,
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "w93-scattergun-turret"
			},
		},
		prerequisites =
		{
			"steel-processing",
			"military",
			"logistic-science-pack",
		},
		unit =
		{
			count = 50,
			ingredients =
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
			},
			time = 45
		}
	},
	{
		type = "technology",
		name = "w93-modular-turrets",
		icon = "__scattergun_turret__/graphics/technology/modular-turret-tech.png",
		icon_size = 128,
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "w93-modular-turret-base"
			},
			{
				type = "unlock-recipe",
				recipe = "w93-modular-gun-hmg"
			},
			{
				type = "unlock-recipe",
				recipe = "w93-hmg-turret"
			},
			{
				type = "unlock-recipe",
				recipe = "w93-hmg-turret2"
			},
			{
				type = "unlock-recipe",
				recipe = "w93-hardened-inserter"
			},
		},
		prerequisites =
		{
			"military-science-pack",
			"engine",
			"concrete",
		},
		unit =
		{
			count = 75,
			ingredients =
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"military-science-pack", 1},
			},
			time = 45
		}
	},
	{
		type = "technology",
		name = "w93-modular-turrets2",
		icon = "__scattergun_turret__/graphics/technology/modular-turret2-tech.png",
		icon_size = 128,
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "w93-modular-turret2-base"
			},
		},
		prerequisites =
		{
			"w93-modular-turrets",
			"electric-engine",
			"low-density-structure",
		},
		unit =
		{
			count = 200,
			ingredients =
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
				{"military-science-pack", 1},
			},
			time = 60
		}
	},
	{
		type = "technology",
		name = "w93-modular-turrets-gatling",
		icon = "__scattergun_turret__/graphics/technology/modular-turret-gatling-tech.png",
		icon_size = 128,
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "w93-modular-gun-gatling"
			},
			{
				type = "unlock-recipe",
				recipe = "w93-gatling-turret"
			},
			{
				type = "unlock-recipe",
				recipe = "w93-gatling-turret2"
			},
			{
				type = "unlock-recipe",
				recipe = "w93-slowdown-magazine"
			},
		},
		prerequisites =
		{
			"w93-modular-turrets",
			"electric-engine",
			"military-3",
		},
		unit =
		{
			count = 200,
			ingredients =
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"military-science-pack", 1},
				{"chemical-science-pack", 1},
			},
			time = 60
		}
	},
	{
		type = "technology",
		name = "w93-modular-turrets-lcannon",
		icon = "__scattergun_turret__/graphics/technology/modular-turret-lcannon-tech.png",
		icon_size = 128,
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "w93-modular-gun-lcannon"
			},
			{
				type = "unlock-recipe",
				recipe = "w93-lcannon-turret"
			},
			{
				type = "unlock-recipe",
				recipe = "w93-lcannon-turret2"
			},
			{
				type = "unlock-recipe",
				recipe = "w93-fragmentation-cannon-shell",
			},
		},
		prerequisites =
		{
			"w93-modular-turrets",
			"explosives"
		},
		unit =
		{
			count = 100,
			ingredients =
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"military-science-pack", 1},
			},
			time = 45
		}
	},
	{
		type = "technology",
		name = "w93-modular-turrets-dcannon",
		icon = "__scattergun_turret__/graphics/technology/modular-turret-dcannon-tech.png",
		icon_size = 128,
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "w93-modular-gun-dcannon"
			},
			{
				type = "unlock-recipe",
				recipe = "w93-dcannon-turret"
			},
			{
				type = "unlock-recipe",
				recipe = "w93-dcannon-turret2"
			},
		},
		prerequisites =
		{
			"w93-modular-turrets-lcannon",
			"military-3",
			"speed-module",
		},
		unit =
		{
			count = 200,
			ingredients =
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"military-science-pack", 1},
				{"chemical-science-pack", 1},
			},
			time = 60
		}
	},
	{
		type = "technology",
		name = "w93-modular-turrets-hcannon",
		icon = "__scattergun_turret__/graphics/technology/modular-turret-hcannon-tech.png",
		icon_size = 128,
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "w93-modular-gun-hcannon"
			},
			{
				type = "unlock-recipe",
				recipe = "w93-hcannon-turret"
			},
			{
				type = "unlock-recipe",
				recipe = "w93-hcannon-turret2"
			},
		},
		prerequisites =
		{
			"w93-modular-turrets-dcannon",
			"military-4",
			"tank",
		},
		unit =
		{
			count = 300,
			ingredients =
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
				{"military-science-pack", 1},
				{"utility-science-pack",1},
			},
			time = 60
		}
	},
	{
		type = "technology",
		name = "w93-modular-turrets-rocket",
		icon = "__scattergun_turret__/graphics/technology/modular-turret-rocket-tech.png",
		icon_size = 128,
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "w93-modular-gun-rocket"
			},
			{
				type = "unlock-recipe",
				recipe = "w93-rocket-turret"
			},
			{
				type = "unlock-recipe",
				recipe = "w93-rocket-turret2"
			},
			{
				type = "unlock-recipe",
				recipe = "w93-turret-slowdown-rocket"
			},
		},
		prerequisites =
		{
			"w93-modular-turrets",
			"rocketry",
		},
		unit =
		{
			count = 200,
			ingredients =
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
				{"military-science-pack", 1},
			},
			time = 60
		}
	},
	{
		type = "technology",
		name = "w93-modular-turrets-plaser",
		icon = "__scattergun_turret__/graphics/technology/modular-turret-plaser-tech.png",
		icon_size = 128,
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "w93-modular-gun-plaser"
			},
			{
				type = "unlock-recipe",
				recipe = "w93-plaser-turret"
			},
			{
				type = "unlock-recipe",
				recipe = "w93-plaser-turret2"
			},
		},
		prerequisites =
		{
			"w93-modular-turrets",
			"military-3",
			"laser",
			"speed-module",
		},
		unit =
		{
			count = 250,
			ingredients =
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
				{"military-science-pack", 1},
			},
			time = 60
		}
	},
	{
		type = "technology",
		name = "w93-modular-turrets-beam",
		icon = "__scattergun_turret__/graphics/technology/modular-turret-beam-tech.png",
		icon_size = 128,
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "w93-modular-gun-beam"
			},
			{
				type = "unlock-recipe",
				recipe = "w93-beam-turret"
			},
			{
				type = "unlock-recipe",
				recipe = "w93-beam-turret2"
			},
		},
		prerequisites =
		{
			"w93-modular-turrets-plaser",
			"nuclear-power",
			"military-4",
			"laser",
		},
		unit =
		{
			count = 300,
			ingredients =
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
				{"military-science-pack", 1},
				{"utility-science-pack",1},
			},
			time = 60
		}
	},
	{
		type = "technology",
		name = "w93-modular-turrets-tlaser",
		icon = "__scattergun_turret__/graphics/technology/modular-turret-tlaser-tech.png",
		icon_size = 128,
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "w93-modular-gun-tlaser"
			},
			{
				type = "unlock-recipe",
				recipe = "w93-tlaser-turret"
			},
			{
				type = "unlock-recipe",
				recipe = "w93-tlaser-turret2"
			},
		},
		prerequisites =
		{
			"w93-modular-turrets-beam",
			"space-science-pack",
			"efficiency-module-2",
		},
		unit =
		{
			count = 500,
			ingredients =
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
				{"military-science-pack", 1},
				{"utility-science-pack",1},
				{"space-science-pack",1}
			},
			time = 60
		}
	},
	{
		type = "technology",
		name = "w93-modular-turrets-radar",
		icon = "__scattergun_turret__/graphics/technology/modular-turret-radar-tech.png",
		icon_size = 128,
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "w93-modular-gun-radar"
			},
			{
				type = "unlock-recipe",
				recipe = "w93-radar-turret"
			},
			{
				type = "unlock-recipe",
				recipe = "w93-modular-gun-radar2"
			},
			{
				type = "unlock-recipe",
				recipe = "w93-radar-turret2"
			},
		},
		prerequisites =
		{
			"w93-modular-turrets2",
			"efficiency-module-2",
			"speed-module-2",
			"utility-science-pack",
		},
		unit =
		{
			count = 75,
			ingredients =
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
				{"military-science-pack", 1},
				{"utility-science-pack",1},
			},
			time = 60
		}
	},

	-- Damage Techs --
	--[[
	{
		type = "technology",
		name = "w93-modular-turrets-damage-1",
		icon = "__scattergun_turret__/graphics/technology/modular-turret-damage-tech.png",
		icon_size = 128,
		effects =
		{
			{
				type = "turret-attack",
				turret_id = "w93-hmg-turret",
				modifier = 0.1
			},
			{
				type = "turret-attack",
				turret_id = "w93-hmg-turret2",
				modifier = 0.1
			},
			{
				type = "turret-attack",
				turret_id = "w93-gatling-turret",
				modifier = 0.1
			},
			{
				type = "turret-attack",
				turret_id = "w93-gatling-turret2",
				modifier = 0.1
			},
			{
				type = "turret-attack",
				turret_id = "w93-lcannon-turret",
				modifier = 0.1
			},
			{
				type = "turret-attack",
				turret_id = "w93-lcannon-turret2",
				modifier = 0.1
			},
			{
				type = "turret-attack",
				turret_id = "w93-dcannon-turret",
				modifier = 0.1
			},
			{
				type = "turret-attack",
				turret_id = "w93-dcannon-turret2",
				modifier = 0.1
			},
			{
				type = "turret-attack",
				turret_id = "w93-hcannon-turret",
				modifier = 0.1
			},
			{
				type = "turret-attack",
				turret_id = "w93-hcannon-turret2",
				modifier = 0.1
			},
			{
				type = "turret-attack",
				turret_id = "w93-rocket-turret",
				modifier = 0.1
			},
			{
				type = "turret-attack",
				turret_id = "w93-rocket-turret2",
				modifier = 0.1
			},
		},
		prerequisites =
		{
			"w93-modular-turrets",
			"space-science-pack",
		},
		unit =
		{
			count_formula = "2^(L-1)*1000",
			ingredients =
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
				{"military-science-pack", 1},
				{"utility-science-pack",1},
				{"space-science-pack", 1}
			},
			time = 60
		},
		upgrade = true,
		max_level = "infinite"
	}
	--]]
 })