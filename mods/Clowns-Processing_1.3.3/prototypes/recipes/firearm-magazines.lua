data:extend(
{
	{
		type = "recipe",
		name = "copper-nickel-firearm-magazine",
		energy_required = 1,
		ingredients = 
		{
			{"copper-plate", 3},
			{"angels-plate-lead", 2}
		},
		result = "firearm-magazine",
		result_count = 1
	},
	{
		type = "recipe",
		name = "nickel-piercing-rounds-magazine",
		--enabled = false,
		energy_required = 3,
		ingredients =
		{
			{"firearm-magazine", 1},
			{"angels-plate-nickel", 5},
			{"bronze-alloy", 3}
		},
		result = "piercing-rounds-magazine"
	},
}
)