local ingredients_table =
{
	{type = "item", name = "coal", amount = 2},
	{type = "item", name = "iron-plate", amount = 1}
}

if settings.startup["Clockwork-flares-simple"].value then
	table.insert(ingredients_table, {type = "item", name = "copper-plate", amount =  1})
else
	table.insert(ingredients_table, {type = "item", name = "electronic-circuit", amount =  1})
end

data:extend(
{
    {
        type = "recipe",
        name = "ln-flare-capsule",
        enabled = settings.startup["Clockwork-enable-flares"].value,
        energy_required = 4,
        ingredients = ingredients_table,
        results = {{type="item", name="ln-flare-capsule", amount=2}}
    },
})