local centrifuge_2_item = util.table.deepcopy(data.raw.item["centrifuge"])
centrifuge_2_item.name = "centrifuge-mk2"
centrifuge_2_item.place_result = "centrifuge-mk2"
centrifuge_2_item.order = "a-b"--base centrifuge is g, overriden to a-a
centrifuge_2_item.icon = nil
centrifuge_2_item.icons =
{
	{
		icon = "__base__/graphics/icons/centrifuge.png"
	},
	{
		icon = "__angelspetrochem__/graphics/icons/num_2.png",
		tint = {r = 0.8, g = 0.8, b = 0.8, a = 0.5},
		scale = 0.32,
		shift = {-12, -12}
	}
}

local centrifuge_3_item = util.table.deepcopy(data.raw.item["centrifuge"])
centrifuge_3_item.name = "centrifuge-mk3"
centrifuge_3_item.place_result = "centrifuge-mk3"
centrifuge_3_item.order = "a-c"
centrifuge_3_item.icon = nil
centrifuge_3_item.icons =
{
	{
		icon = "__base__/graphics/icons/centrifuge.png"
	},
	{
		icon = "__angelspetrochem__/graphics/icons/num_3.png",
		tint = {r = 0.8, g = 0.8, b = 0.8, a = 0.5},
		scale = 0.32,
		shift = {-12, -12}
	}
}

local centrifuge_2 = util.table.deepcopy(data.raw["assembling-machine"]["centrifuge"])
centrifuge_2.name = "centrifuge-mk2"
centrifuge_2.minable.result = "centrifuge-mk2"
centrifuge_2.fast_replaceable_group = "centrifuge"
centrifuge_2.crafting_speed = 1.25
centrifuge_2.energy_usage = "450kW"

local centrifuge_3 = util.table.deepcopy(data.raw["assembling-machine"]["centrifuge"])
centrifuge_3.name = "centrifuge-mk3"
centrifuge_3.minable.result = "centrifuge-mk3"
centrifuge_3.fast_replaceable_group = "centrifuge"
centrifuge_3.crafting_speed = 2
centrifuge_3.energy_usage = "550kW"

data:extend(
{
	centrifuge_2_item,
	centrifuge_3_item,
	centrifuge_2,
	centrifuge_3,
	{
		type = "recipe",
		name = "centrifuge-mk2",
		enabled = false,
		ingredients =
		{
			{type="item", name="centrifuge", amount=1},
			{type="item", name="titanium-plate", amount=50},
			{type="item", name="processing-unit", amount=100},
			{type="item", name="titanium-gear-wheel", amount=100},
		},
		result = "centrifuge-mk2",
		energy_required = 4,
	},
	{
		type = "recipe",
		name = "centrifuge-mk3",
		enabled = false,
		ingredients =
		{
			{type="item", name="centrifuge-mk2", amount=1},
			{type="item", name="copper-tungsten-alloy", amount=50},
			{type="item", name="advanced-processing-unit", amount=100},
			{type="item", name="tungsten-gear-wheel", amount=100},
		},
		result = "centrifuge-mk3",
		energy_required = 4,
	},

	}
)
