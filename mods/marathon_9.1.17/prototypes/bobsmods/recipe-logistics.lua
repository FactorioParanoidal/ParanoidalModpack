if data.raw.item["brass-alloy"] then
	marathon.update_recipe("brass-pipe",
	{
		ingredients = {
			{type="item", name="brass-alloy", amount=2},
		}
	})
	marathon.update_recipe("brass-pipe-to-ground",
	{
		ingredients = {
			{type="item", name="brass-pipe", amount=15},
			{type="item", name="brass-alloy", amount=15},
		}
	})
end

if data.raw.item["bronze-alloy"] then
	marathon.update_recipe("bronze-pipe",
	{
		ingredients = {
			{type="item", name="bronze-alloy", amount=2},
		}
	})
	marathon.update_recipe("bronze-pipe-to-ground",
	{
		ingredients = {
			{type="item", name="bronze-pipe", amount=12},
			{type="item", name="bronze-alloy", amount=12},
		}
	})
end

marathon.update_recipe("copper-pipe",
{
	ingredients = {
		{type="item", name="copper-plate", amount=2},
	}
})
marathon.update_recipe("copper-pipe-to-ground",
{
	ingredients = {
		{type="item", name="copper-pipe", amount=10},
		{type="item", name="copper-plate", amount=10},
	}
})
marathon.update_recipe("plastic-pipe",
{
	ingredients = {
		{type="item", name="plastic-bar", amount=2},
	}
})
marathon.update_recipe("plastic-pipe-to-ground",
{
	ingredients = {
		{type="item", name="plastic-pipe", amount=100},
		{type="item", name="plastic-bar", amount=100},
	}
})

if data.raw.item["silicon-nitride"] then
	marathon.update_recipe("ceramic-pipe",
	{
		ingredients = {
			{type="item", name="silicon-nitride", amount=2},
		}
	})
	marathon.update_recipe("ceramic-pipe-to-ground",
	{
		ingredients = {
			{type="item", name="ceramic-pipe", amount=15},
			{type="item", name="silicon-nitride", amount=15},
		}
	})
end

marathon.update_recipe("steel-pipe",
{
	ingredients = {
		{type="item", name="steel-plate", amount=2},
	}
})
marathon.update_recipe("steel-pipe-to-ground",
{
	ingredients = {
		{type="item", name="steel-pipe", amount=12},
		{type="item", name="steel-plate", amount=12}
	}
})
--[[
marathon.update_recipe("stone-pipe",
{
	ingredients = {
		{type="item", name="stone-brick", amount=2}
	}
})
marathon.update_recipe("stone-pipe-to-ground",
{
	ingredients = {
		{type="item", name="stone-pipe", amount=10},
		{type="item", name="stone-brick", amount=10}
	}
})
]]
if data.raw.item["titanium-plate"] then
	marathon.update_recipe("titanium-pipe",
	{
		ingredients = {
			{type="item", name="titanium-plate", amount=2},
		}
	})

	marathon.update_recipe("titanium-pipe-to-ground",
	{
		ingredients = {
			{type="item", name="titanium-pipe", amount=15},
			{type="item", name="titanium-plate", amount=15},
		}
	})
end

if data.raw.item["tungsten-plate"] then
	marathon.update_recipe("tungsten-pipe",
	{
		ingredients = {
			{type="item", name="tungsten-plate", amount=2},
		}
	})

	marathon.update_recipe("tungsten-pipe-to-ground",
	{
		ingredients = {
			{type="item", name="tungsten-pipe", amount=18},
			{type="item", name="tungsten-plate", amount=18},
		}
	})
end

if data.raw.item["nitinol-alloy"] then
	marathon.update_recipe("nitinol-pipe",
	{
		ingredients = {
			{type="item", name="tungsten-plate", amount=2},
		}
	})

	marathon.update_recipe("nitinol-pipe-to-ground",
	{
		ingredients = {
			{type="item", name="nitinol-pipe", amount=250},
			{type="item", name="nitinol-plate", amount=250},
		}
	})
end

if data.raw.item["copper-tungsten-alloy"] then
	marathon.update_recipe("copper-tungsten-pipe",
	{
		ingredients = {
			{type="item", name="copper-tungsten-plate", amount=2},
		}
	})

	marathon.update_recipe("copper-tungsten-pipe-to-ground",
	{
		ingredients = {
			{type="item", name="copper-tungsten-pipe", amount=250},
			{type="item", name="copper-tungsten-alloy", amount=250},
		}
	})
end
