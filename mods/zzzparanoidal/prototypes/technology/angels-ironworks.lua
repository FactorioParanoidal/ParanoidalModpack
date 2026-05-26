-- 5 техов angels-ironworks-1/2/3/4/5 для gear-wheel casting из расплавов (1.1 ASE).
-- Recipe-unlock'и подвязываются позже из tweaks/recipe/angels-smelting-extended-port.lua.

local CASTING_TECH = "__zzzparanoidal__/graphics/technology/casting-machine-tech.png"

data:extend({
	{
		type = "technology",
		name = "angels-ironworks-1",
		icons = {
			{ icon = CASTING_TECH, icon_size = 128 },
			{ icon = "__base__/graphics/icons/iron-gear-wheel.png", icon_size = 64, shift = { 25, -25 } },
		},
		icon_size = 128,
		upgrade = true,
		prerequisites = { "angels-iron-smelting-1" },
		effects = {},
		unit = {
			count = 150,
			ingredients = {
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack", 1 },
			},
			time = 30,
		},
		order = "c-a",
	},
	{
		type = "technology",
		name = "angels-ironworks-2",
		icon = "__bobplates__/graphics/icons/brass-gear-wheel.png",
		icon_size = 32,
		upgrade = true,
		prerequisites = {
			"angels-ironworks-1",
			"angels-steel-smelting-1",
			"angels-steel-smelting-2",
		},
		effects = {},
		unit = {
			count = 300,
			ingredients = {
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack", 1 },
			},
			time = 30,
		},
		order = "c-a",
	},
	{
		type = "technology",
		name = "angels-ironworks-3",
		icon = "__bobplates__/graphics/icons/titanium-gear-wheel.png",
		icon_size = 32,
		upgrade = true,
		prerequisites = {
			"angels-ironworks-2",
			"angels-titanium-smelting-1",
		},
		effects = {},
		unit = {
			count = 300,
			ingredients = {
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack", 1 },
				{ "chemical-science-pack", 1 },
			},
			time = 30,
		},
		order = "c-a",
	},
	{
		type = "technology",
		name = "angels-ironworks-4",
		icon = "__bobplates__/graphics/icons/tungsten-gear-wheel.png",
		icon_size = 32,
		upgrade = true,
		prerequisites = {
			"angels-ironworks-3",
			"angels-nitinol-smelting-1",
			"angels-tungsten-smelting-1",
			"production-science-pack",
		},
		effects = {},
		unit = {
			count = 300,
			ingredients = {
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack", 1 },
				{ "chemical-science-pack", 1 },
				{ "production-science-pack", 1 },
			},
			time = 30,
		},
		order = "c-a",
	},
	{
		type = "technology",
		name = "angels-ironworks-5",
		icon = "__bobplates__/graphics/icons/nitinol-gear-wheel.png",
		icon_size = 32,
		upgrade = true,
		prerequisites = {
			"angels-ironworks-4",
			"bob-nitinol-processing",
			"bob-tungsten-processing",
			"utility-science-pack",
		},
		effects = {},
		unit = {
			count = 300,
			ingredients = {
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack", 1 },
				{ "chemical-science-pack", 1 },
				{ "production-science-pack", 1 },
				{ "utility-science-pack", 1 },
			},
			time = 30,
		},
		order = "c-a",
	},
})
