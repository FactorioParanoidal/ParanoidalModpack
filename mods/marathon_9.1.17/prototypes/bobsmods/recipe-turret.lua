marathon.update_recipe("bob-gun-turret-2",
{
	energy_required = 10,
	ingredients = {
		{type="item", name="gun-turret", amount=1},
		{type="item", name="steel-gear-wheel", amount=30},
		{type="item", name="steel-plate", amount=40},
	}
})

marathon.update_recipe("bob-sniper-turret-1",
{
	energy_required = 40,
	ingredients = {
		{type="item", name="iron-plate", amount=50},
		{type="item", name="iron-gear-wheel", amount=80},
		{type="item", name="copper-plate", amount=80},
	}
})

marathon.update_recipe("bob-sniper-turret-2",
{
	energy_required = 30,
	ingredients = {
		{type="item", name="bob-sniper-turret-1", amount=1},
		{type="item", name="steel-gear-wheel", amount=40},
		{type="item", name="steel-bearing", amount=30},
		{type="item", name="steel-plate", amount=40},
		{type="item", name="invar-alloy", amount=40},
	}
})
