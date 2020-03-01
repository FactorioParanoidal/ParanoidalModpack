data:extend(
{
	{
		type = "recipe",
		name = "thorium-nuclear-fuel-reprocessing",
		energy_required = 50,
		enabled = false,
		category = "centrifuging",
		ingredients = {{"used-up-thorium-fuel-cell", 5}},
		icon = "__Clowns-Nuclear__/graphics/icons/thorium-nuclear-fuel-reprocessing.png",
		icon_size = 32,
		crafting_machine_tint =
		{
			primary = {r = 1, g = 1, b = 0}, -- thorium
			secondary = {r = 1, g = 0.7, b = 0}, -- plutonium
			tertiary = {r = 1, g = 1, b = 0}, --thorium
		},
		subgroup = "clowns-nuclear-cells",
		order = "c-a-b",
		results =
		{
			{type="item", name="thorium-232", amount=3},
			{type="item", name="plutonium-239", amount=1}
		},
	},

	{
		type = "recipe",
		name = "advanced-nuclear-fuel-reprocessing",
		energy_required = 50,
		enabled = false,
		category = "chemistry",
		ingredients =
		{
			{type="item", name="used-up-uranium-fuel-cell", amount=5},
			{type="fluid", name="liquid-nitric-acid", amount=300}--20
		},
		icon = "__Clowns-Nuclear__/graphics/icons/nuclear-fuel-reprocessing.png",
		icon_size = 32,
		subgroup = "clowns-nuclear-cells",
		order = "c-b-a",
		results =
		{
			{type="item", name="uranium-238", amount="3"},
			{type="item", name="plutonium-239", amount="2"},
			{type="item", name="strontium-90", amount="3"},--1
			{type="item", name="caesium-137", amount="3"},--1
			{type="fluid", name="water-radioactive-waste", amount="300"}--100 (matching the waste liq)
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
			{type="item", name="used-up-thorium-fuel-cell", amount=5},
			{type="fluid", name="liquid-nitric-acid", amount=300}--20 (matching the waste liq)
		},
		icon = "__Clowns-Nuclear__/graphics/icons/thorium-nuclear-fuel-reprocessing.png",
		icon_size = 32,
		subgroup = "clowns-nuclear-cells",
		order = "c-b-b",
		results =
		{
			{type="item", name="thorium-232", amount="8"},--3 (needs to be less than 19/10)
			{type="item", name="plutonium-239", amount="5"},--1
			{type="item", name="protactinium-231", amount="15"},--1--3
			{type="fluid", name="water-radioactive-waste", amount="300"}--20--60
		},
	},
	{
		type = "recipe",
		name = "advanced-thorium-nuclear-fuel-reprocessing|b",
		energy_required = 50,
		enabled = false,
		category = "chemistry",
		ingredients =
		{
			{type="item", name="used-up-thorium-fuel-cell", amount=5},
			{type="fluid", name="liquid-nitric-acid", amount=150}--making this path lower than the other one, to give options, may need balance
		},
		icon = "__Clowns-Nuclear__/graphics/icons/thorium-nuclear-fuel-reprocessing.png",
		icon_size = 32,
		subgroup = "clowns-nuclear-cells",
		order = "c-b-b",
		results =
		{
			{type="item", name="thorium-232", amount="5"},
			{type="item", name="plutonium-239", amount="8"},
			{type="item", name="strontium-90", amount="9"},
			{type="fluid", name="water-radioactive-waste", amount="150"}
		},
	},

}
)
