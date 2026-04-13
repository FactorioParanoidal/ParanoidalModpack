--добавление цепочки рецептов для утилизации Хлорида кальция(AKMF)
data:extend({
	{
		type = "recipe",
		name = "Calcium-chloride-Calcium-carbonate",
		category = "chemistry",
		subgroup = "angels-petrochem-sulfur",
		energy_required = 4,
		enabled = false,
		ingredients = {
			{ type = "item", name = "angels-solid-calcium-chloride", amount = 1 },
			{ type = "item", name = "angels-solid-sodium-carbonate", amount = 1 },
		},
		localised_name = "Реакция обмена: Хлорид кальция в Карбонат кальция",
		results = {
			{ type = "item", name = "angels-solid-calcium-carbonate", amount = 1 },
			{ type = "item", name = "angels-solid-salt", amount = 2 },
		},
		icon = "__angelsbioprocessinggraphics__/graphics/icons/solid-calcium-carbonate.png",
		icon_size = 32,
		order = "h",
	},
	{
		type = "recipe",
		name = "Calcium-carbonate-Calcium-sulfate",
		category = "chemistry",
		subgroup = "angels-petrochem-sulfur",
		energy_required = 4,
		enabled = false,
		ingredients = {
			{ type = "item", name = "angels-solid-calcium-carbonate", amount = 1 },
			{ type = "fluid", name = "angels-liquid-sulfuric-acid", amount = 50 },
		},
		localised_name = "Нейтрализация Карбоната кальция до Сульфата кальция",
		results = {
			{ type = "item", name = "angels-solid-calcium-sulfate", amount = 1 },
			{ type = "fluid", name = "water", amount = 50 },
			{ type = "fluid", name = "angels-gas-carbon-dioxide", amount = 50 },
		},
		icon = "__angelspetrochemgraphics__/graphics/icons/solid-calcium-sulfate.png",
		icon_size = 32,
		order = "h",
	},
})

