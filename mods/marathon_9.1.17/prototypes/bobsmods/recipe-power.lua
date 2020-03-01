marathon.update_recipe("boiler-2",
{
	ingredients = {
		{type="item", name="boiler", amount=2},
		{type="item", name="steel-furnace", amount=2},
	}
})

marathon.update_recipe("boiler-3",
{
	ingredients = {
		{type="item", name="boiler-2", amount=2},
		{type="item", name="steel-plate", amount=15},
	}
})

marathon.update_recipe("boiler-4",
{
	ingredients = {
		{type="item", name="boiler-3", amount=2},
		{type="item", name="steel-plate", amount=15},
	}
})

marathon.update_recipe("fast-accumulator",
{
	energy_required = 20,
	ingredients = {
		{type="item", name="iron-plate", amount=10},
		{type="item", name="electronic-circuit", amount=6},
		{type="item", name="battery", amount=8},
	}
})

marathon.update_recipe("fast-accumulator-2",
{
	energy_required = 20,
	ingredients = {
		{type="item", name="fast-accumulator", amount=1},
		{type="item", name="steel-plate", amount=10},
		{type="item", name="advanced-circuit", amount=12},
		{type="item", name="battery", amount=8},
	}
})

marathon.update_recipe("fast-accumulator-3",
{
	energy_required = 20,
	ingredients = {
		{type="item", name="fast-accumulator-2", amount=1},
		{type="item", name="steel-plate", amount=10},
		{type="item", name="processing-unit", amount=12},
		{type="item", name="battery", amount=8},
	}
})

marathon.update_recipe("large-accumulator",
{
	energy_required = 20,
	ingredients = {
		{type="item", name="iron-plate", amount=15},
		{type="item", name="battery", amount=20},
	}
})

marathon.update_recipe("large-accumulator-2",
{
	energy_required = 20,
	ingredients = {
		{type="item", name="large-accumulator", amount=1},
		{type="item", name="steel-plate", amount=15},
		{type="item", name="advanced-circuit", amount=6},
		{type="item", name="battery", amount=20},
	}
})

marathon.update_recipe("large-accumulator-3",
{
	energy_required = 20,
	ingredients = {
		{type="item", name="large-accumulator-2", amount=1},
		{type="item", name="steel-plate", amount=15},
		{type="item", name="processing-unit", amount=6},
		{type="item", name="battery", amount=20},
	}
})

marathon.update_recipe("slow-accumulator",
{
	energy_required = 20,
	ingredients = {
		{type="item", name="iron-plate", amount=10},
		{type="item", name="electronic-circuit", amount=6},
		{type="item", name="battery", amount=8},
	}
})

marathon.update_recipe("slow-accumulator-2",
{
	energy_required = 20,
	ingredients = {
		{type="item", name="slow-accumulator", amount=1},
		{type="item", name="steel-plate", amount=10},
		{type="item", name="advanced-circuit", amount=12},
		{type="item", name="battery", amount=8},
	}
})

marathon.update_recipe("slow-accumulator-3",
{
	energy_required = 20,
	ingredients = {
		{type="item", name="slow-accumulator-2", amount=1},
		{type="item", name="steel-plate", amount=10},
		{type="item", name="processing-unit", amount=12},
		{type="item", name="battery", amount=8},
	}
})

marathon.update_recipe("solar-panel",
{
	energy_required = 20,
	ingredients = {
		{type="item", name="steel-plate", amount=6},
		{type="item", name="electronic-circuit", amount=16},
		{type="item", name="copper-plate", amount=30},
	}
})

marathon.update_recipe("solar-panel-large",
{
	energy_required = 40,
	ingredients = {
		{type="item", name="steel-plate", amount=12},
		{type="item", name="electronic-circuit", amount=32},
		{type="item", name="copper-plate", amount=60},
	}
})

marathon.update_recipe("solar-panel-small",
{
	energy_required = 10,
	ingredients = {
		{type="item", name="steel-plate", amount=3},
		{type="item", name="electronic-circuit", amount=8},
		{type="item", name="copper-plate", amount=15},
	}
})

marathon.update_recipe("steam-engine-2",
{
	energy_required = 45,
	ingredients = {
		{type="item", name="steam-engine", amount=1},
		{type="item", name="steel-plate", amount=20},
		{type="item", name="iron-gear-wheel", amount=20},
	}
})

marathon.update_recipe("steam-engine-3",
{
	energy_required = 30,
	ingredients = {
		{type="item", name="steam-engine-2", amount=1},
		{type="item", name="advanced-circuit", amount=10},
		{type="item", name="steel-plate", amount=10},
		{type="item", name="iron-gear-wheel", amount=10},
	}
})

if data.raw.item["lithium-ion-battery"] then
	marathon.replace_recipe_item("large-accumulator-2", "battery", "lithium-ion-battery")
	marathon.replace_recipe_item("fast-accumulator-2", "battery", "lithium-ion-battery")
	marathon.replace_recipe_item("slow-accumulator-2", "battery", "lithium-ion-battery")
end

if data.raw.item["titanium-plate"] then
	marathon.replace_recipe_item("large-accumulator-3", "steel-plate", "titanium-plate")
	marathon.replace_recipe_item("fast-accumulator-3", "steel-plate", "titanium-plate")
	marathon.replace_recipe_item("slow-accumulator-3", "steel-plate", "titanium-plate")
else
	if data.raw.item["aluminium-plate"] then
		marathon.replace_recipe_item("large-accumulator-3", "steel-plate", "aluminium-plate")
		marathon.replace_recipe_item("fast-accumulator-3", "steel-plate", "aluminium-plate")
		marathon.replace_recipe_item("slow-accumulator-3", "steel-plate", "aluminium-plate")
	end
end

if data.raw.item["silver-zinc-battery"] then
	marathon.replace_recipe_item("large-accumulator-3", "battery", "silver-zinc-battery")
	marathon.replace_recipe_item("fast-accumulator-3", "battery", "silver-zinc-battery")
	marathon.replace_recipe_item("slow-accumulator-3", "battery", "silver-zinc-battery")
else
	if data.raw.item["lithium-ion-battery"] then
		marathon.replace_recipe_item("large-accumulator-3", "battery", "lithium-ion-battery")
		marathon.replace_recipe_item("fast-accumulator-3", "battery", "lithium-ion-battery")
		marathon.replace_recipe_item("slow-accumulator-3", "battery", "lithium-ion-battery")
	end
end

if data.raw.item["steel-pipe"] then
	marathon.add_recipe_item("boiler-2", {"steel-pipe", 10})
end

if data.raw.item["invar-alloy"] then
	marathon.replace_recipe_item("boiler-3", "steel-plate", "invar-alloy")
end

if data.raw.item["brass-pipe"] then
	marathon.add_recipe_item("boiler-3", {"brass-pipe", 10})
end

if data.raw.item["tungsten-plate"] then
	marathon.replace_recipe_item("boiler-4", "steel-plate", "tungsten-plate")
end

if data.raw.item["tungsten-pipe"] then
	marathon.add_recipe_item("boiler-4", {"tungsten-pipe", 5})
end

if data.raw.item["steel-bearing"] then
	marathon.add_new_recipe_item("steam-engine-2", {"steel-bearing", 20})
else
	marathon.add_new_recipe_item("steam-engine-2", {"iron-gear-wheel", 30})
end

if data.raw.item["steel-gear-wheel"] then
	marathon.replace_recipe_item("steam-engine-2", "iron-gear-wheel", "steel-gear-wheel")
end

if data.raw.item["titanium-bearing"] then
	marathon.add_new_recipe_item("steam-engine-3", {"titanium-bearing", 10})
else
	if data.raw.item["steel-bearing"] then
		marathon.add_new_recipe_item("steam-engine-3", {"steel-bearing", 10})
	else
		marathon.add_new_recipe_item("steam-engine-3", {"iron-gear-wheel", 20})
	end
end

if data.raw.item["titanium-gear-wheel"] then
	marathon.replace_recipe_item("steam-engine-3", "iron-gear-wheel", "titanium-gear-wheel")
else
	if data.raw.item["tungsten-gear-wheel"] then
		marathon.replace_recipe_item("steam-engine-3", "iron-gear-wheel", "tungsten-gear-wheel")
	else
		if data.raw.item["steel-gear-wheel"] then
			marathon.replace_recipe_item("steam-engine-3", "iron-gear-wheel", "steel-gear-wheel")
		end
	end
end

if data.raw.item["titanium-plate"] then
	marathon.replace_recipe_item("steam-engine-3", "steel-plate", "titanium-plate")
else
	if data.raw.item["tungsten-plate"] then
		marathon.replace_recipe_item("steam-engine-3", "steel-plate", "tungsten-plate")
	end
end
