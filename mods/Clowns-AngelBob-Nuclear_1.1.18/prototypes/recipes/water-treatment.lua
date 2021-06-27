data:extend(
{
	{
		type = "recipe",
		name = "radioactive-waste-water-purification",
		category = "water-treatment",
		subgroup = "water-cleaning",
		energy_required = 10,
		enabled = false,
		ingredients =
		{
			{type="fluid", name="water-radioactive-waste", amount=100}
		},
		results=
		{
			{type="fluid", name="water-red-waste", amount=100},
			{type="item", name="polonium-210", amount=1},
		},
		icons = angelsmods.functions.create_liquid_recipe_icon({"polonium-210","water-red-waste"}, "wcl"),
		order = "k",
	},
}
)
