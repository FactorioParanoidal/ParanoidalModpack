-- 3 техи angels-alloys-smelting-1/2/3 (порт из 1.1 ASE, в 2.0 vanilla их нет).
-- Создаются в data-stage чтобы research_evolution_factor (data-final-fixes)
-- мог автоматически применить свой evolution-factor effect.
-- Recipe-unlock'и подвязываются позже из angels-smelting-extended-port.lua.

data:extend({
	{
		type = "technology",
		name = "angels-alloys-smelting-1",
		icon = "__zzzparanoidal__/graphics/technology/casting-bronze-tech.png",
		icon_size = 256,
		upgrade = true,
		prerequisites = {
			"angels-copper-smelting-1",
			"angels-tin-smelting-1",
			"angels-zinc-smelting-1",
			"bob-alloy-processing",
		},
		effects = {},
		unit = {
			count = 100,
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
		name = "angels-alloys-smelting-2",
		icon = "__zzzparanoidal__/graphics/technology/casting-gunmetal-tech.png",
		icon_size = 256,
		upgrade = true,
		prerequisites = {
			"angels-alloys-smelting-1",
			"angels-steel-smelting-1",
			"angels-cobalt-smelting-1",
			"angels-nickel-smelting-1",
		},
		effects = {},
		unit = {
			count = 150,
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
		name = "angels-alloys-smelting-3",
		icon = "__zzzparanoidal__/graphics/technology/casting-cobalt-steel-tech.png",
		icon_size = 256,
		upgrade = true,
		prerequisites = {
			"angels-alloys-smelting-2",
			"angels-gold-smelting-1",
			"angels-silver-smelting-1",
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
})
