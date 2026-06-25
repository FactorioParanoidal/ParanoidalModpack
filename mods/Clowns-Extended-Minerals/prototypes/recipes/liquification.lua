data:extend(
{
	{
		type = "recipe",
		name = "clowns-resource2-liquification",
		category = "angels-liquifying",
		subgroup = "angels-petrochem-carbon-oil-feed",
		enabled = false,
		energy_required = 2,
		ingredients =
		{
			{type="item", name="clowns-resource2", amount=4},
			{type="fluid", name="steam", amount=10}
		},
		results=
		{
			{type="item", name="angels-solid-oil-residual", amount=1},
			{type="fluid", name="crude-oil", amount=10}
		},
		icon = "__Clowns-Extended-Minerals__/graphics/icons/clowns-resource2.png",
		icon_size = 32,
		order = "a",
	},
}
)