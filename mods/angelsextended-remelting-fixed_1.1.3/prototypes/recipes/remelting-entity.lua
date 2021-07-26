data:extend(
{
	-- Alloy Mixer
	{
		type = "recipe",
		name = "alloy-mixer",
		energy_required = 5,
		enabled = "false",
		ingredients ={
			{"iron-plate", 10},
		},
		result= "alloy-mixer",
	},
	{
		type = "recipe",
		name = "alloy-mixer-2",
		energy_required = 5,
		enabled = "false",
		ingredients ={
			{"alloy-mixer", 1},
		},
		result= "alloy-mixer-2",
	},
	{
		type = "recipe",
		name = "alloy-mixer-3",
		energy_required = 5,
		enabled = "false",
		ingredients ={
			{"alloy-mixer-2", 1},
		},
		result= "alloy-mixer-3",
	},
	{
		type = "recipe",
		name = "alloy-mixer-4",
		energy_required = 5,
		enabled = "false",
		ingredients ={
			{"alloy-mixer-3", 1},
		},
		result= "alloy-mixer-4",
	},
}
)