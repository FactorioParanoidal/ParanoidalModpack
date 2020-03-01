data:extend(
{
	{
		type = "recipe",
		name = "molten-iron-smelting-6",
		category = "induction-smelting",
		subgroup = "angels-iron-casting",
		energy_required = 4,
		enabled = false,
		ingredients =
		{
			{type="item", name="ingot-iron", amount=12},
			{type="item", name="ingot-magnesium", amount=12},
			{type="item", name="ingot-manganese", amount=12},
		},
		results=
		{
			{type="fluid", name="liquid-molten-iron", amount=360},
		},
		icons =
		{
			{
				icon = "__angelssmelting__/graphics/icons/molten-iron.png",
			},
			{
				icon = "__Clowns-Processing__/graphics/icons/num_6.png",
				tint = {r = 0.8, g = 0.8, b = 0.8, a = 0.5},
				scale = 0.32,
				shift = {-12, -12},
			}
		},	
		icon_size = 32,
		order = "bf",
    },
	{
		type = "recipe",
		name = "molten-aluminium-smelting-4",
		category = "induction-smelting",
		subgroup = "angels-aluminium-casting",
		energy_required = 4,
		enabled = false,
		ingredients =
		{
		  {type="item", name="ingot-aluminium", amount=12},
		  {type="item", name="ingot-magnesium", amount=12}
		},
		results=
		{
		  {type="fluid", name="liquid-molten-aluminium", amount=240},
		},
		icons =
		{
			{
				icon = "__angelssmelting__/graphics/icons/molten-aluminium.png",
			},
			{
				icon = "__angelspetrochem__/graphics/icons/num_3.png",
				tint = {r = 0.8, g = 0.8, b = 0.8, a = 0.5},
				scale = 0.32,
				shift = {-12, -12},
			}
		},	
		icon_size = 32,
		order = "bc",
    },
	{
		type = "recipe",
		name = "molten-aluminium-smelting-5",
		category = "induction-smelting",
		subgroup = "angels-aluminium-casting",
		energy_required = 4,
		enabled = false,
		ingredients =
		{
			{type="item", name="ingot-aluminium", amount=12},
			{type="item", name="ingot-magnesium", amount=12},
			{type="item", name="ingot-zinc", amount=12},
		},
		results=
		{
			{type="fluid", name="liquid-molten-aluminium", amount=360},
		},
		icons =
		{
			{
				icon = "__angelssmelting__/graphics/icons/molten-aluminium.png",
			},
			{
				icon = "__angelspetrochem__/graphics/icons/num_5.png",
				tint = {r = 0.8, g = 0.8, b = 0.8, a = 0.5},
				scale = 0.32,
				shift = {-12, -12},
			}
		},	
		icon_size = 32,
		order = "be",
    },
	{
		type = "recipe",
		name = "angels-brass-smelting-4",
		category = "induction-smelting",
		subgroup = "angels-alloys-casting",
		energy_required = 4,
		enabled = false,
		ingredients =
		{
			{type="item", name="ingot-copper", amount=18},
			{type="item", name="ingot-zinc", amount=12},
			{type="item", name="solid-white-phosphorus", amount=6},
		},
		results=
		{
			{type="fluid", name="liquid-molten-brass", amount=360},
		},
		icons =
		{
			{
				icon = "__angelssmelting__/graphics/icons/molten-brass.png",
			},
			{
				icon = "__angelspetrochem__/graphics/icons/num_4.png",
				tint = {r = 0.8, g = 0.8, b = 0.8, a = 0.5},
				scale = 0.32,
				shift = {-12, -12},
			}
		},	
		icon_size = 32,
		order = "bd",
    },
	
	{
		type = "recipe",
		name = "sponge-magnesium-titanium-smelting",
		category = "chemical-smelting",
		subgroup = "angels-titanium",
		energy_required = 6,
		enabled = false,
		ingredients =
		{
			{type="fluid", name="liquid-titanium-tetrachloride", amount=90},
			{type="item", name="solid-sodium", amount=8},
		},
		results=
		{
			{type="item", name="sponge-titanium", amount=24},
			{type="item", name="solid-salt", amount=8}
		},
		main_product= "sponge-titanium",
		icon_size = 32,
		order = "ag",
    },
	
	{
		type = "recipe",
		name = "pellet-magnesium-titanium-smelting",
		category = "chemical-smelting",
		subgroup = "angels-titanium",
		energy_required = 6,
		enabled = false,
		ingredients =
		{
			{type="item", name="pellet-titanium", amount=8},
			{type="item", name="ingot-magnesium", amount=6},
		},
		results=
		{
			{type="item", name="ingot-titanium", amount=24},
			{type="item", name="magnesium-ore", amount=6}
		},
		main_product= "ingot-titanium",
		icon_size = 32,
		order = "ai",
    },
}
)