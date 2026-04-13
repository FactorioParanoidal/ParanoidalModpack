--добавляем рецепт для бетонного кирпича с полосами
data:extend({
	{
		type = "recipe",
		name = "hazard-concrete-brick",
		category = "crafting",
		group = "angels-casting",
		subgroup = "angels-stone-casting",
		order = "ia",
		energy_required = 1,
		enabled = false,
		allow_decomposition = false,
		always_show_products = true,
		ingredients = { { type = "item", name = "angels-concrete-brick", amount = 10 } },
		results = { { type = "item", name = "hazard-concrete-brick", amount = 10 } },
	},
})

