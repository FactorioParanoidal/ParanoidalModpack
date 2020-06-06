data:extend(
{
	--MILITARY
	{
		type = "recipe",
		name = "neurotoxin-capsule",
		category = "chemistry",
		enabled = false,
		energy_required = 4,
		ingredients =
		{
			{type="fluid", name="liquid-dimethylmercury", amount=100},
			{type="item", name="steel-plate", amount=2},
			{type="item", name="plastic-bar", amount=5},
			{type="item", name="processing-unit", amount=2},
		},
		results=
		{
			{type="item", name="neurotoxin-capsule", amount=1},
		},
		icon_size = 32,
	},
}
)