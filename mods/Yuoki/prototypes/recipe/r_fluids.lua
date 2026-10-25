data:extend({
	--[[
	{
		type = "recipe",
		name = "y-coaltoliquid-bergius-recipe",
		category = "chemistry",
		energy_required = 6,
		enabled = true,
		ingredients =
		{
			{type="item", name="coal", amount=16}
		},
		results=
		{
			{type="fluid", name="crude-oil", amount=9 },
			--{type="fluid", name="crude-oil", amount=5 },
		},
		group = "yuoki",
		subgroup = "y-fluid",
		order = "c-a",
		 icon_size = 64, icon =  "__Yuoki__/graphics/icons/ctl_b32.png",
	},

	{
		type = "recipe",
		name = "y-coaltoliquid-fischer-recipe",
		category = "chemistry",
		energy_required = 8,
		enabled = true,
		ingredients =
		{
			{type="item", name="coal", amount=6}
		},
		results=
		{
			{type="fluid", name="light-oil", amount=1},
			{type="fluid", name="petroleum-gas", amount=2}
		},
		group = "yuoki",
		subgroup = "y-fluid",
		order = "c-b",
		 icon_size = 64, icon =  "__Yuoki__/graphics/icons/ctl_ft_32.png",
	},

	{
		type = "recipe",
		name = "y-wood-gas-recipe",
		category = "chemistry",
		energy_required = 6,
		enabled = true,
		ingredients =
		{
			{type="item", name="wood", amount=9},
		},
		results=
		{
			{type="fluid", name="petroleum-gas", amount=4},
			--{type="fluid", name="petroleum-gas", amount=1}
		},
		group = "yuoki",
		subgroup = "y-fluid",
		order = "c-c",
		 icon_size = 64, icon =  "__Yuoki__/graphics/icons/wood-gas.png",
	},
	]]
	{
		type = "recipe",
		name = "y-sulfuric-acid",
		category = "yuoki-archaeology-wash",
		--category = "chemistry",
		energy_required = 4,
		ingredients = {
			{ type = "item", name = "y-toxic-dust", amount = 12 },
			{ type = "fluid", name = "water", amount = 20 },
		},
		results = { { type = "fluid", name = "sulfuric-acid", amount = 10 } },
		-- icon_size = 64, icon =  "__Yuoki__/graphics/gfx/carbon_dioxide.png",
		group = "yuoki",
		subgroup = "y-fluid",
		enabled = true,
		order = "c-d",
	},

	{
		type = "recipe",
		name = "y-water-gen-fluid",
		category = "yuoki-watergen",
		energy_required = 2,
		ingredients = {},
		results = { { type = "fluid", name = "water", amount = 1200 } },
		group = "yuoki",
		subgroup = "y-fluid",
		enabled = true,
		order = "c-e",
	},
})
