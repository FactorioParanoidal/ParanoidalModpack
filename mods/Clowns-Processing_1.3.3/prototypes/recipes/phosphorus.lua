data:extend(
{
	{
		type = "recipe",
		name = "crushed-stone-sorting",
		icons =
		{
			{
				icon = "__Clowns-Processing__/graphics/icons/sorting.png"
			},
			{
				icon = "__angelsrefining__/graphics/icons/stone-crushed.png",
				scale = 0.5,
				shift = {8, 8},
				--tint = {r = 1, g = 1, b = 0.25} WHY IS THIS EVEN HERE
			},

		},
		icon_size = 32,
		category = "ore-sorting",
		subgroup = "ore-sorting-t1",
		order = "i",
		energy_required = 1,
		enabled = false,
		allow_decomposition = false,
		ingredients =
		{
			{"stone-crushed", 20},
		},
		results =
		{
			{"slag", 7},
			{"phosphorus-ore", 1},
		},
	},

	{
		type = "recipe",
		name = "white-phosphorus-smelting",
		icon = "__Clowns-Processing__/graphics/icons/solid-white-phosphorus.png",
		icon_size = 32,
		category = "chemical-smelting",
		subgroup = "clowns-phosphorus",
		order = "a",
		energy_required = 10,
		enabled = false,
		allow_decomposition = false,
		ingredients =
		{
			{type="item", name="phosphorus-ore", amount=24},
			{type="item", name="solid-sand", amount=2},
			{type="item", name="solid-carbon", amount=2}
		},
		results =
		{
			{type="item", name="solid-white-phosphorus", amount=24},--Should make phosphorus gas
			{type="fluid", name="gas-carbon-monoxide", amount=10}
		},
	},

	{
		type = "recipe",
		name = "white-phosphorus-smelting-2",
		icon = "__Clowns-Processing__/graphics/icons/solid-white-phosphorus.png",
		icon_size = 32,
		category = "chemical-smelting",
		subgroup = "clowns-phosphorus",
		order = "a",
		energy_required = 10,
		enabled = false,
		allow_decomposition = false,
		ingredients =
		{
			{type="item", name="solid-white-phosphorus", amount=24},--24 phosphorus ore
			{type="fluid", name="liquid-phosphoric-acid", amount=10},--8 phosphorus ore
		},
		results =
		{
			{type="fluid", name="liquid-phosphoric-acid", amount=60},--48 phosphorus ore i.e. 33% productivity gain
		},
	},

	{
		type = "recipe",
		name = "phosphoric-acid",
		icon = "__Clowns-Processing__/graphics/icons/liquid-phosphoric-acid.png",
		icon_size = 32,
		category = "chemistry",
		subgroup = "clowns-phosphorus",
		order = "b",
		energy_required = 10,
		enabled = false,
		allow_decomposition = false,
		ingredients =
		{
			{type="item", name="phosphorus-ore", amount=8},
			{type="fluid", name="liquid-sulfuric-acid", amount=10},
		},
		results =
		{
			{type="fluid", name="liquid-phosphoric-acid", amount=10},
			{type="item", name="solid-calcium-sulfate", amount=1}
		},
	},
})
