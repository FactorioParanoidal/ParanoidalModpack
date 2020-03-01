data:extend({
 { -- Advanced Aerodynamics
		type = "technology",
		name = "advanced-aerodynamics",
		icon = "__Aircraft__/graphics/Gunship.png",
		icon_size = 128,
		prerequisites = {"automobilism", "robotics"},
		unit =
		{
			count = 350,
			ingredients =
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1}
			},
			time = 45
		},
		order = "c-h-b"
	},
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 { -- Gunship
		type = "technology",
		name = "gunships",
		icon = "__Aircraft__/graphics/Gunship.png",
		icon_size = 128,
		effects =
    {
      {
        type = "unlock-recipe",
        recipe = "gunship"
      },
    },
		prerequisites = {"military-3", "advanced-aerodynamics", "rocketry"},
		unit = 
		{
			count = 500,
			ingredients = 
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
				{"military-science-pack", 1},
			},
			time = 60
		},
		order = "c-h-c"
	},
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 { -- Cargo Plane
		type = "technology",
		name = "cargo-planes",
		icon = "__Aircraft__/graphics/Cargo_Plane.png",
		icon_size = 128,
		effects =
    {
      {
        type = "unlock-recipe",
        recipe = "cargo-plane"
      },
    },
		prerequisites = {"advanced-aerodynamics"},
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
		order = "c-h-d"
	},
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 { -- Jet
		type = "technology",
		name = "jets",
		icon = "__Aircraft__/graphics/Jet.png",
		icon_size = 128,
		effects =
    {
      {
        type = "unlock-recipe",
        recipe = "jet"
      },
    },
		prerequisites = {"gunships", "explosive-rocketry", "military-4"},
		unit = 
		{
			count = 1000,
			ingredients = 
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
				{"military-science-pack", 1},
				{"production-science-pack", 1}
			},
			time = 75
		},
		order = "c-h-e"
	},
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 { -- Flying Fortress
		type = "technology",
		name = "flying-fortress",
		icon = "__Aircraft__/graphics/Flying_Fortress.png",
		icon_size = 128,
		effects =
    {
      {
        type = "unlock-recipe",
        recipe = "flying-fortress"
      },
    },
		prerequisites = {"gunships", "cargo-planes", "jets", "artillery", "space-science-pack"},
		unit = 
		{
			count = 3000,
			ingredients = 
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
				{"military-science-pack", 1},
				{"utility-science-pack", 1},
				{"production-science-pack", 1},
				{"space-science-pack", 1}
			},
			time = 120
		},
		order = "c-h-f"
	},
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 { -- High Explosive Cannon Shells
		type = "technology",
		name = "high-explosive-cannon-shells",
		icon = "__Aircraft__/graphics/High_Explosive_Shell_Tech.png",
		icon_size = 128,
		effects =
    {
      {
        type = "unlock-recipe",
        recipe = "high-explosive-cannon-shell"
      },
    },
		prerequisites = {"artillery"},
		unit = 
		{
			count = 350,
			ingredients = 
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
				{"military-science-pack", 1},
			},
			time = 45
		},
		order = "c-h-g"
	},
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 { -- Afterburner
		type = "technology",
		name = "afterburner",
		icon = "__Aircraft__/graphics/Aircraft_Afterburner_Tech.png",
		icon_size = 128,
		effects =
	{
		{
		  type = "unlock-recipe",
		  recipe = "aircraft-afterburner",
		},
	},
		prerequisites = {"advanced-aerodynamics"},
		unit =
		{
			count = 400,
			ingredients =
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
				{"utility-science-pack", 1},
			},
			time = 45,
		},
		order = "c-h-h",
 },
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 { -- Aircraft Energy Shield
		type = "technology",
		name = "aircraft-energy-shield",
		icon = "__Aircraft__/graphics/Aircraft_Energy_Shield_Tech.png",
		icon_size=128,
		effects =
	{
	{
		type = "unlock-recipe",
		recipe = "aircraft-energy-shield",
	},
	},
	prerequisites = {"advanced-aerodynamics", "energy-shield-mk2-equipment"},
	unit =
	{
		count = 400,
		ingredients =
		{
			{"automation-science-pack", 1},
			{"logistic-science-pack", 1},
			{"chemical-science-pack", 1},
			{"military-science-pack",1},
			{"utility-science-pack", 1},
		},
		time = 45,
	},
	order = "c-h-i",
	--Hey,   ^^^^^   a lil' easter egg for ya
 },
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 { -- Napalm
		type = "technology",
		name = "napalm",
		icon = "__base__/graphics/icons/flamethrower-ammo.png",
		icon_size = 32,
		effects =
	{
		{
		  type = "unlock-recipe",
		  recipe = "napalm",
		},
	},
		prerequisites = {"flammables", "jets"},
		unit =
		{
			count = 200,
			ingredients =
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
				{"military-science-pack",1},
			},
			time = 20,
		},
		order = "c-h-h",
 },
})