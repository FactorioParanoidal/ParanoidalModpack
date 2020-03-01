if data.raw.item["brass-alloy"] then
	marathon.update_recipe("brass-gear-wheel",
	{
		energy_required = 1.5,
		ingredients = {
			{type="item", name="brass-alloy", amount=5}
		}
	})
end

if data.raw.item["silicon-nitride"] then
	marathon.update_recipe("ceramic-bearing",
	{
		energy_required = 1.5,
		ingredients = {
			{type="item", name="silicon-nitride", amount=3},
			{type="item", name="ceramic-bearing-ball", amount=42},
		  	{type="fluid", name="lubricant", amount=3}
		}
	})

	marathon.update_recipe("ceramic-bearing-ball",
	{
		result_count = 8
	})
end

marathon.update_recipe("cobalt-oxide-from-copper",
{
	energy_required = 37.5,
	ingredients = {
		{type = "item", name = "copper-ore", amount = 7},
		{type = "item", name = "stone", amount = 2},
		{type = "item", name = "coal", amount = 2},
		{type = "fluid", name = "hydrogen", amount = 2},
	},
	results=
	{
		{type = "item", name = "copper-plate", amount = 50},
		{type = "item", name = "cobalt-oxide", amount = 2},
	},
})

marathon.update_recipe("lithium-ion-battery",
{
	energy_required = 1.5,
	ingredients = {
		{type="item", name="lithium-perchlorate", amount=4},
		{type="item", name="lithium-cobalt-oxide", amount=2},
		{type="item", name="carbon", amount=2},
		{type="item", name="plastic-bar", amount=2},
	}
})

if data.raw.item["nitinol-alloy"] then

	marathon.update_recipe("nitinol-bearing",
	{
		energy_required = 1.5,
		ingredients = {
			{type="item", name="nitinol-alloy", amount=3},
			{type="item", name="nitinol-bearing-ball", amount=42},
		  	{type="fluid", name="lubricant", amount=2}
		}
	})

	marathon.update_recipe("nitinol-bearing-ball",
	{
		result_count = 8
	})

	marathon.update_recipe("nitinol-gear-wheel",
	{
		energy_required = 1.5,
		ingredients = {
			{type="item", name="nitinol-alloy", amount=5},
		}
	})
end

marathon.update_recipe("silver-zinc-battery",
{
	energy_required = 3
})

marathon.update_recipe("steel-bearing",
{
	energy_required = 1.5,
	ingredients = {
		{type="item", name="steel-plate", amount=3},
		{type="item", name="steel-bearing-ball", amount=42},
	}
})

marathon.update_recipe("steel-bearing-ball",
{
	result_count = 8
})

marathon.update_recipe("steel-gear-wheel",
{
	energy_required = 1.5,
	ingredients = {
		{type="item", name="steel-plate", amount=5},
	}
})

if data.raw.item["titanium-plate"] then
	marathon.update_recipe("titanium-bearing",
	{
		energy_required = 1.5,
		ingredients = {
			{type="item", name="titanium-plate", amount=3},
			{type="item", name="titanium-bearing-ball", amount=42},
		  	{type="fluid", name="lubricant", amount=2}
		}
	})

	marathon.update_recipe("titanium-bearing-ball",
	{
		result_count = 8
	})

	marathon.update_recipe("titanium-gear-wheel",
	{
		energy_required = 1.5,
		ingredients = {
			{type="item", name="titanium-plate", amount=5},
		}
	})
end

if data.raw.item["tungsten-plate"] then
	marathon.update_recipe("tungsten-gear-wheel",
	{
		energy_required = 1.5,
		ingredients = {
			{type="item", name="tungsten-plate", amount=5},
		}
	})
end
