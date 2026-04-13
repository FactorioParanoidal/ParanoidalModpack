data:extend(
{
	{
		type = "recipe",
		name = "mixed-oxide",
		energy_required = 50,
		enabled = false,
		ingredients =
		{
			{type="item",name="iron-plate", amount=2},
			{type="item",name="uranium-238", amount=2},
		},
		icon = "__Clowns-Nuclear__/graphics/icons/nuclear-fuel-mixed-oxide.png",
		icon_size = 32,
		subgroup = "clowns-nuclear-cells",
		order = "d-a",
		results =
		{
			{type="item",name = "uranium-fuel-cell",amount = 2},
		},
		allow_decomposition = false
	},
	
	
}
)

if mods["angelspetrochem"] then
	table.insert(data.raw["recipe"]["mixed-oxide"].ingredients, {type="item",name="angels-plutonium-239", amount= 2})
else
	table.insert(data.raw["recipe"]["mixed-oxide"].ingredients, {type="item",name="plutonium-239",amount= 2})
end