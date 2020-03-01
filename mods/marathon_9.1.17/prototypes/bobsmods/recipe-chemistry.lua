
marathon.update_recipe("alumina",
{
	energy_required = 6,
	result_count = 6,
	ingredients = {
		{type="item", name="sodium-hydroxide", amount=10},
		{type="item", name="bauxite-ore", amount=2},
	}
})

if data.raw.item["lead-plate"] and data.raw.item["sulfuric-acid"] then
	marathon.update_recipe("battery",
	{
		ingredients = {
			{type="item", name="lead-plate", amount=4},
			{type="fluid", name="sulfuric-acid", amount=40},
			{type="item", name="plastic-bar", amount=2}
		}
	})
end

marathon.update_recipe("coal-cracking",
{
	energy_required = 6,
	ingredients = {
		{type="item", name="coal", amount=3},
		{type="fluid", name="water", amount=20}
	},
	results = {
		{type="fluid", name="heavy-oil", amount=8}
	}
})

marathon.update_recipe("ferric-chloride-solution",
{
	energy_required = 5,
	results = {
		{type="fluid", name="ferric-chloride-solution", amount=30}
	}
})

marathon.update_recipe("liquid-fuel",
{
	energy_required = 3,
	ingredients = {
		{type="fluid", name="light-oil", amount=30}
	}
})

marathon.update_recipe("lithium-chloride",
{
	energy_required = 2,
	ingredients = {
		{type="fluid", name="lithia-water", amount=50}
	}
})

marathon.update_recipe("sulfur-2",
{
	energy_required = 1.5
})

marathon.update_recipe("sulfuric-acid-2",
{
	ingredients = {
		{type="fluid", name="water", amount=10},
		{type="fluid", name="sulfur-dioxide", amount=1},
	},
	results = {
		{type="fluid", name="sulfuric-acid", amount=10}
	}
})
