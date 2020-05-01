data:extend(
{
	--CENTRIFUGING
	{
    type = "recipe",
    name = "advanced-uranium-processing",
    energy_required = 5,--50% faster than vanilla
    enabled = false,
    category = "centrifuging",
    ingredients = {{"solid-uranium-hexafluoride", 8}},--20% less ingredients than vanilla
    icon = "__Clowns-Processing__/graphics/icons/advanced-uranium-processing.png",
    icon_size = 32,
    subgroup = "raw-material",
    order = "k-a",
    results =
    {
		{
			name = "uranium-235",
			probability = 0.007,
			amount = 1
		},
		{
			name = "uranium-238",
			probability = 0.993,
			amount = 1
		}
    }
	--CHEMISTRY & SMELTING
	},
	{
		type = "recipe",
		name = "solid-uranium-hexafluoride",
		icon = "__Clowns-Processing__/graphics/icons/solid-uranium-hexafluoride.png",
		icon_size = 32,
		category = "chemistry",
		subgroup = "clowns-uranium",
		order = "f",
		energy_required = 5,
		enabled = false,
		allow_decomposition = false,
		ingredients =
		{
			{type="item", name="solid-uranium-tetrafluoride", amount=12},
			{type="fluid", name="gas-fluorine", amount=10}
		},
		results =
		{
			{type="item", name="solid-uranium-hexafluoride", amount=12}
		},
	},
	{
		type = "recipe",
		name = "solid-uranium-tetrafluoride",
		icon = "__Clowns-Processing__/graphics/icons/solid-uranium-tetrafluoride.png",
		icon_size = 32,
		category = "chemistry",
		subgroup = "clowns-uranium",
		order = "e",
		energy_required = 5,
		enabled = false,
		allow_decomposition = false,
		ingredients =
		{
			{type="item", name="solid-uranium-oxide", amount=12},
			{type="fluid", name="liquid-hydrofluoric-acid", amount=10}
		},
		results =
		{
			{type="item", name="solid-uranium-tetrafluoride", amount=12}
		},
	},
	{
		type = "recipe",
		name = "solid-uranium-oxide-1",
		icon = "__Clowns-Processing__/graphics/icons/solid-uranium-oxide.png",
		icon_size = 32,
		category = "chemical-smelting",
		subgroup = "clowns-uranium",
		order = "a",
		energy_required = 10,
		enabled = false,
		allow_decomposition = false,
		ingredients =
		{
			{type="item", name="uranium-ore", amount=24},
			{type="fluid", name="gas-hydrogen", amount=40}
		},
		results =
		{
			{type="item", name="solid-uranium-oxide", amount=24}
		},
	},
	{
		type = "recipe",
		name = "solid-uranium-oxide-2",
		icon = "__Clowns-Processing__/graphics/icons/solid-uranium-oxide.png",
		icon_size = 32,
		category = "chemical-smelting",
		subgroup = "clowns-uranium",
		order = "d",
		energy_required = 10,
		enabled = false,
		allow_decomposition = false,
		ingredients =
		{
			{type="item", name="solid-ammonium-diuranate", amount=24},
			{type="fluid", name="gas-hydrogen", amount=40}
		},
		results =
		{
			{type="item", name="solid-uranium-oxide", amount=24},
		},
	},
	{
		type = "recipe",
		name = "solid-ammonium-diuranate",
		icon = "__Clowns-Processing__/graphics/icons/solid-ammonium-diuranate.png",
		icon_size = 32,
		category = "chemistry",
		subgroup = "clowns-uranium",
		order = "c",
		energy_required = 5,
		enabled = false,
		allow_decomposition = false,
		ingredients =
		{
			{type="item", name="solid-uranyl-nitrate", amount=12},
			{type="fluid", name="gas-ammonia", amount=10}
		},
		results =
		{
			{type="item", name="solid-ammonium-diuranate", amount=12}
		},
	},
	{
		type = "recipe",
		name = "solid-uranyl-nitrate",
		icon = "__Clowns-Processing__/graphics/icons/solid-uranyl-nitrate.png",
		icon_size = 32,
		category = "chemistry",
		subgroup = "clowns-uranium",
		order = "b",
		energy_required = 5,
		enabled = false,
		allow_decomposition = false,
		ingredients =
		{
			{type="item", name="uranium-ore", amount=10},--20% less ingredients
			{type="fluid", name="liquid-nitric-acid", amount=10}
		},
		results =
		{
			{type="item", name="solid-uranyl-nitrate", amount=12}
		},
	},
}
)