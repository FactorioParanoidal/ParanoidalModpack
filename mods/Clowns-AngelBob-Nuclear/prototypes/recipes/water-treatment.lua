data:extend(
{
	{
		type = "recipe",
		name = "radioactive-waste-water-purification",
		category = "angels-water-treatment",
		subgroup = "angels-water-cleaning",
		energy_required = 10,
		enabled = false,
		ingredients =
		{
			{type="fluid", name="clowns-water-radioactive-waste", amount=100}
		},
		results=
		{
			{type="fluid", name="angels-water-red-waste", amount=100},
			{type="item", name="clowns-polonium-210", amount=1},
		},
		icons = angelsmods.functions.create_liquid_recipe_icon({"clowns-polonium-210","angels-water-red-waste"}, "WsCCl"),
		order = "k",
	},
}
)
