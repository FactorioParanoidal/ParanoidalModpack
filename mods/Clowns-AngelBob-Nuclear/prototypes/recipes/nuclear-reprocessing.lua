data:extend(
{
	{
		type = "recipe",
		name = "advanced-nuclear-fuel-reprocessing",
		energy_required = 50,
		enabled = false,
		category = "chemistry",
		ingredients =
		{
			{type="item", name="depleted-uranium-fuel-cell", amount=5},
			{type="fluid", name="angels-liquid-nitric-acid", amount=300}--20
		},
		icons = {{icon = "__Clowns-Nuclear__/graphics/icons/nuclear-fuel-reprocessing.png", icon_size = 32,}},
		subgroup = "clowns-nuclear-reprocessing",
		order = "a[uranium]-b[reprocessing]-a",
		results =
		{
			{type="item", name="uranium-238", amount=4},
			{type="item", name="angels-plutonium-239", amount=2},
			{type="item", name="clowns-strontium-90", amount=1},--1
			{type="item", name="clowns-caesium-137", amount=3},--1
			{type="fluid", name="clowns-water-radioactive-waste", amount=300},--100 (matching the waste liq)
			{type="item", name="angels-solid-lead-oxide", amount = 5, ignored_by_productivity = 5},
		},
	},
	{
		type = "recipe",
		name = "advanced-nuclear-fuel-reprocessing-b",
		energy_required = 50,
		enabled = false,
		category = "chemistry",
		ingredients =
		{
			{type="item", name="depleted-uranium-fuel-cell", amount=5},
			{type="fluid", name="angels-liquid-nitric-acid", amount=350}--20
		},
		icons = {{icon = "__Clowns-Nuclear__/graphics/icons/nuclear-fuel-reprocessing.png", icon_size = 32,}},
		subgroup = "clowns-nuclear-reprocessing",
		order = "a[uranium]-b[reprocessing]-b",
		results =
		{
			{type="item", name="uranium-238", amount=3},
			{type="item", name="angels-plutonium-239", amount=2},
			{type="item", name="clowns-strontium-90", amount=1},--1
			{type="item", name="clowns-caesium-137", amount=5},--1
			{type="fluid", name="clowns-water-radioactive-waste", amount=350},--100 (matching the waste liq)
			{type="item", name="angels-solid-lead-oxide", amount = 5, ignored_by_productivity = 5},
		},
	},
	{
		type = "recipe",
		name = "advanced-nuclear-fuel-reprocessing-2",
		energy_required = 50,
		enabled = false,
		category = "chemistry",
		ingredients =
		{
			{type="item", name="depleted-uranium-fuel-cell", amount=5},
			{type="fluid", name="angels-liquid-nitric-acid", amount=300}--20
		},
		icons = {{icon = "__Clowns-Nuclear__/graphics/icons/nuclear-fuel-reprocessing.png",icon_size=32}},
		subgroup = "clowns-nuclear-reprocessing",
		order = "a[uranium]-b[reprocessing]-c",
		results =
		{
			{type="item", name="uranium-238", amount=1}, --slight nerf because of lack of thorium
			{type="item", name="angels-plutonium-239", amount=1}, --slight nerf because of lack of thorium
			{type="item", name="clowns-protactinium-231", amount=4},--1--3 --slight nerf because of lack of thorium
			{type="fluid", name="clowns-water-radioactive-waste", amount=300},--100 (matching the waste liq)
			{type="item", name="angels-solid-lead-oxide", amount = 5, ignored_by_productivity = 5},
		},
	},
	{
		type = "recipe",
		name = "thorium-nuclear-fuel-reprocessing",
		energy_required = 50,
		enabled = false,
		category = "centrifuging",
		ingredients = {{type="item", name = "angels-depleted-thorium-fuel-cell", amount = 5}},
		icons= {{icon = "__Clowns-Nuclear__/graphics/icons/thorium-nuclear-fuel-reprocessing.png", icon_size = 32,}},
		crafting_machine_tint =
		{
			primary = {r = 1, g = 1, b = 0}, -- thorium
			secondary = {r = 1, g = 0.7, b = 0}, -- plutonium
			tertiary = {r = 1, g = 1, b = 0}, --thorium
		},
		subgroup = "clowns-nuclear-reprocessing",
		order = "c[thorium]-b[reprocessing]-a",
		results =
		{ -- A direct copy of bobs recipe, it is better balanced
			{type="item", name="angels-thorium-232", amount=3},
			{type="item", name="angels-plutonium-239", amount=1},
			{type="item", name="angels-solid-aluminium-oxide", amount = 5, ignored_by_productivity = 5},
			{type="item", name="angels-thorium-232", amount=1, probability=0.05},
			{type="item", name="angels-plutonium-239", amount=1, probability=0.1},
		},
	},
	{
		type = "recipe",
		name = "advanced-thorium-nuclear-fuel-reprocessing",
		energy_required = 50,
		enabled = false,
		category = "chemistry",
		ingredients =
		{
			{type="item", name="angels-depleted-thorium-fuel-cell", amount=5},
			{type="fluid", name="angels-liquid-nitric-acid", amount=300}--20 (matching the waste liq)
		},
		icons= {{icon = "__Clowns-Nuclear__/graphics/icons/thorium-nuclear-fuel-reprocessing.png", icon_size = 32,}},
		subgroup = "clowns-nuclear-reprocessing",
		order = "c[thorium]-b[reprocessing]-c",
		results =
		{
			--{type="item", name="angels-thorium-232", amount=3},--3 (needs to be less than 19/10)
			{type="item", name="angels-plutonium-239", amount=3},--1
			{type="item", name="clowns-protactinium-231", amount=15},--1--3
			{type="fluid", name="clowns-water-radioactive-waste", amount=300},--20--60
			{type="item", name="angels-slag", amount = 5, ignored_by_productivity = 5},
		},
	},
	{
		type = "recipe",
		name = "advanced-thorium-nuclear-fuel-reprocessing-b",
		energy_required = 50,
		enabled = false,
		category = "chemistry",
		ingredients =
		{
			{type="item", name="angels-depleted-thorium-fuel-cell", amount=5},
			{type="fluid", name="angels-liquid-nitric-acid", amount=150}--making this path lower than the other one, to give options, may need balance
		},
		icons= {{icon = "__Clowns-Nuclear__/graphics/icons/thorium-nuclear-fuel-reprocessing.png", icon_size = 32,}},
		subgroup = "clowns-nuclear-reprocessing",
		order = "c[thorium]-b[reprocessing]-d",
		results =
		{
			{type="item", name="angels-thorium-232", amount=1},
			{type="item", name="angels-plutonium-239", amount=6},--8
			{type="item", name="clowns-strontium-90", amount=9},
			{type="fluid", name="clowns-water-radioactive-waste", amount=150},
			{type="item", name="angels-slag", amount = 5, ignored_by_productivity = 5},
		},
	},
}
)
