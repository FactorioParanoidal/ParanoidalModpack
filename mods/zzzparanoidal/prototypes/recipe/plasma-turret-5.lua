-- Финальный рецепт zzz 1.1; silver-zinc-battery переименован Bob в bob-battery-3.
data:extend({
	{
		type = "recipe",
		name = "bob-plasma-turret-5",
		enabled = false,
		energy_required = 20,
		allow_productivity = false,
		subgroup = "paranoidal-split-defense-plasma-turrets",
		order = "05",
		ingredients = {
			{ type = "item", name = "bob-advanced-processing-unit", amount = 80 },
			{ type = "item", name = "bob-battery-3", amount = 48 },
			{ type = "item", name = "bob-nitinol-alloy", amount = 80 },
			{ type = "item", name = "bob-alien-artifact-red", amount = 10 },
			{ type = "item", name = "bob-alien-artifact-green", amount = 10 },
			{ type = "item", name = "bob-plasma-turret-4", amount = 2 },
			{ type = "item", name = "bob-laser-turret-5", amount = 2 },
		},
		results = { { type = "item", name = "bob-plasma-turret-5", amount = 1 } },
	},
})
