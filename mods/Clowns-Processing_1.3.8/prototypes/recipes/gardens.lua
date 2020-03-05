data:extend(
{
	--[[{
		type = "recipe",
		name = "swamp-garden-generation",
		icon = "__bobgreenhouse__/graphics/icons/seedling.png",
		icon_size = 32,
		subgroup = "bob-greenhouse-items",
		order = "g[temperate-garden-generation]",
		category = "bob-greenhouse",
		energy_required = 600,
		enabled = true,
		ingredients =
		{
			{type = "item", name = "seedling", amount = 1000},
			{type = "fluid", name = "water", amount = 1000},
			{type = "item", name = "fertiliser", amount = 200}
		},
		results =
		{
		{type = "item", name = "swamp-garden", amount = 1}
		},
	},]]

	--[[
	{
		type = "recipe",
		name = "temperate-garden-generation",
		category = "seed-extractor",
		subgroup = "farming-gardens",
		enabled = true,
		energy_required = 1000,
		ingredients =
		{
			{type = "item", name = "solid-soil", amount = 500},
			--{type = "fluid", name = "water", amount = 1000},
			{type = "item", name = "solid-fertilizer", amount = 500}
		},
		results=
		{
			{type = "item", name = "temperate-garden", amount = 1}
		},
		icon = "__angelsbioprocessing__/graphics/icons/temperate-garden.png",
		icon_size = 32,
		order = "ac",
    },
	{
		type = "recipe",
		name = "desert-garden-generation",
		category = "seed-extractor",
		subgroup = "farming-gardens",
		enabled = true,
		energy_required = 1000,
		ingredients =
		{
			{type = "item", name = "solid-soil", amount = 500},
			--{type = "fluid", name = "water", amount = 1000},
			{type = "item", name = "solid-fertilizer", amount = 500}
		},
		results=
		{
			{type = "item", name = "desert-garden", amount = 1}
		},
		icon = "__angelsbioprocessing__/graphics/icons/desert-garden.png",
		icon_size = 32,
		order = "bc",
    },
	{
		type = "recipe",
		name = "swamp-garden-generation",
		category = "seed-extractor",
		subgroup = "farming-gardens",
		enabled = true,
		energy_required = 1000,
		ingredients =
		{
			{type = "item", name = "solid-soil", amount = 500},
			--{type = "fluid", name = "water", amount = 1000},
			{type = "item", name = "solid-fertilizer", amount = 500}
		},
		results=
		{
			{type = "item", name = "swamp-garden", amount = 1}
		},
		icon = "__angelsbioprocessing__/graphics/icons/swamp-garden.png",
		icon_size = 32,
		order = "cc",
    },
	]]

	--[[{
		type = "recipe",
		name = "swamp-garden-generation",
		icon = "__bobgreenhouse__/graphics/icons/seedling.png",
		icon_size = 32,
		subgroup = "bob-greenhouse-items",
		order = "g[temperate-garden-generation]",
		category = "bob-greenhouse",
		energy_required = 600,
		enabled = true,
		ingredients =
		{
			{type = "item", name = "seedling", amount = 1000},
			{type = "fluid", name = "water", amount = 1000},
			{type = "item", name = "fertiliser", amount = 200}
		},
		results =
		{
		{type = "item", name = "swamp-garden", amount = 1}
		},
	},]]

	--MUTATION

	{
		type = "recipe",
		name = "temperate-garden-mutation",
		category = "seed-extractor",
		subgroup = "farming-gardens",
		enabled = false,
		energy_required = 600,
		ingredients =
		{
			{type = "item", name = "desert-garden", amount = 1},
			{type = "item", name = "swamp-garden", amount = 1},
			{type = "item", name = "uranium-235", amount = 1},
		},
		results=
		{
			{type = "item", name = "temperate-garden", amount = 1}
		},
		icon = "__angelsbioprocessing__/graphics/icons/temperate-garden.png",
		icon_size = 32,
		order = "ac",
    },
	{
		type = "recipe",
		name = "desert-garden-mutation",
		category = "seed-extractor",
		subgroup = "farming-gardens",
		enabled = false,
		energy_required = 600,
		ingredients =
		{
			{type = "item", name = "temperate-garden", amount = 1},
			{type = "item", name = "swamp-garden", amount = 1},
			{type = "item", name = "uranium-235", amount = 1},
		},
		results=
		{
			{type = "item", name = "desert-garden", amount = 1}
		},
		icon = "__angelsbioprocessing__/graphics/icons/desert-garden.png",
		icon_size = 32,
		order = "bc",
    },
	{
		type = "recipe",
		name = "swamp-garden-mutation",
		category = "seed-extractor",
		subgroup = "farming-gardens",
		enabled = false,
		energy_required = 600,
		ingredients =
		{
			{type = "item", name = "desert-garden", amount = 1},
			{type = "item", name = "temperate-garden", amount = 1},
			{type = "item", name = "uranium-235", amount = 1},
		},
		results=
		{
			{type = "item", name = "swamp-garden", amount = 1}
		},
		icon = "__angelsbioprocessing__/graphics/icons/swamp-garden.png",
		icon_size = 32,
		order = "cc",
	},
	{
		type = "recipe",
		name = "diammonium-phosphate-fertilizer",
		icon = "__angelsbioprocessing__/graphics/icons/solid-fertilizer.png",
		icon_size = 32,
		category = "chemistry",
		subgroup = "clowns-phosphorus",
		order = "c",
		energy_required = 10,
		enabled = false,
		allow_decomposition = false,
		ingredients =
		{
			{type="fluid", name="liquid-phosphoric-acid", amount=10},
			{type="fluid", name="gas-ammonia", amount=10},
		},
		results =
		{
			{type="item", name="solid-fertilizer", amount=1}
		},
	},
})
