table.insert(data.raw.technology['automated-rail-transportation'].effects,{type = "unlock-recipe",recipe = "fuel-train-stop"})

data:extend({
util.merge{data.raw['train-stop']['train-stop'],
		{
			name = "fuel-train-stop",
			icon = "__FuelTrainStop__/graphics/train-stop.png",
			minable = {mining_time = 0.2, result = "fuel-train-stop"}
		}
	},
	{
		type = "item",
		name = "fuel-train-stop",
		icon = "__FuelTrainStop__/graphics/train-stop.png",
		icon_size = 32,
		subgroup = "transport",
		order = "a[train-system]-c[train-stop]-a[fuel-train-stop]",
		place_result = "fuel-train-stop",
		stack_size = 10
	},
	{
		type = "recipe",
		name = "fuel-train-stop",
		enabled = false,
		ingredients =
			{
				{"electronic-circuit", 5},
				{"iron-plate", 6},
				{"iron-stick", 6},
				{"steel-plate", 3}
			},
		result = "fuel-train-stop"
	}
})