data:extend(
{
	--[[{
		type = "recipe",
		name = "resin-liquification",
		category = "crafting-with-fluid",
		subgroup = "petrochem-solids",
		enabled = true,
		allow_decomposition = false,
		normal =
		{
			energy_required = 2,
			ingredients =
			{
				{type="item", name="resin", amount=1}
			},
			results=
			{
				{type="fluid", name="liquid-resin", amount=40}
			},
		},
		icon_size = 32,
		order = "aa",
	},
	
	{
		type = "recipe",
		name = "plastic-liquification",
		category = "crafting-with-fluid",
		subgroup = "petrochem-solids",
		enabled = true,
		allow_decomposition = false,
		normal =
		{
			energy_required = 2,
			ingredients =
			{
				{type="item", name="plastic-bar", amount=1}
			},
			results=
			{
				{type="fluid", name="liquid-plastic", amount=40}
			},
		},
		icon_size = 32,
		order = "aa",
	},]]
	
	{
		type = "recipe",
		name = "catalytic-water-separation-oxygen",
		category = "petrochem-electrolyser",
		subgroup = "clowns-electrolysis",
		order = "a",
		energy_required = 2,
		enabled = false,
		ingredients =
		{
			{type="fluid", name="water-purified", amount=1000},
			{type="item", name="catalyst-metal-violet", amount=1}
		},
		results=
		{
			{type="fluid", name="gas-oxygen", amount=800},
			{type="item", name="catalyst-metal-carrier", amount=1}
		},
		icon = "__Clowns-Processing__/graphics/icons/catalytic-water-separation-oxygen.png",
		icon_size = 32,
		crafting_machine_tint =
		{
			primary = {r = 1, g = 0, b = 0, a = 0},
			secondary = {r = 1, g = 1, b = 1, a = 0},
			tertiary = {r = 167/255, g = 75/255, b = 5/255, a = 0/255},
		}
	},
	
	{
		type = "recipe",
		name = "catalytic-water-separation-hydrogen",
		category = "petrochem-electrolyser",
		subgroup = "clowns-electrolysis",
		order = "b",
		energy_required = 2,
		enabled = false,
		ingredients =
		{
			{type="fluid", name="water-purified", amount=1000},
			{type="item", name="catalyst-metal-violet", amount=1}
		},
		results=
		{
			{type="fluid", name="gas-hydrogen", amount=1200},
			{type="item", name="catalyst-metal-carrier", amount=1}
		},
		icon = "__Clowns-Processing__/graphics/icons/catalytic-water-separation-hydrogen.png",
		icon_size = 32,
		crafting_machine_tint =
		{
			primary = {r = 1, g = 0, b = 0, a = 0},
			secondary = {r = 1, g = 1, b = 1, a = 0},
			tertiary = {r = 167/255, g = 75/255, b = 5/255, a = 0/255},
		}
	},
	
	{
		type = "recipe",
		name = "catalytic-air-separation-nitrogen",
		category = "chemistry",
		subgroup = "clowns-electrolysis",
		order = "d",
		energy_required = 2,
		enabled = false,
		ingredients =
		{
			{type="fluid", name="gas-compressed-air", amount=1000},
			{type="item", name="catalyst-metal-violet", amount=1}
		},
		results=
		{
			{type="fluid", name="gas-nitrogen", amount=1000},
			{type="item", name="catalyst-metal-carrier", amount=1}
		},
		icon = "__Clowns-Processing__/graphics/icons/catalytic-air-separation-nitrogen.png",
		icon_size = 32,
	},
	
	{
		type = "recipe",
		name = "catalytic-air-separation-oxygen",
		category = "chemistry",
		subgroup = "clowns-electrolysis",
		order = "c",
		energy_required = 2,
		enabled = false,
		ingredients =
		{
			{type="fluid", name="gas-compressed-air", amount=1000},
			{type="item", name="catalyst-metal-violet", amount=1}
		},
		results=
		{
			{type="fluid", name="gas-oxygen", amount=1000},
			{type="item", name="catalyst-metal-carrier", amount=1}
		},
		icon = "__Clowns-Processing__/graphics/icons/catalytic-air-separation-oxygen.png",
		icon_size = 32,
	},
	{
		type = "recipe",
		name = "hydrochloric-acid-separation",
		category = "petrochem-electrolyser",
		subgroup = "clowns-electrolysis",
		order = "e",
		energy_required = 2,
		enabled = false,
		ingredients =
		{
			{type="fluid", name="liquid-hydrochloric-acid", amount=100}
		},
		results=
		{
			{type="fluid", name="gas-chlorine", amount=40},
			{type="fluid", name="gas-hydrogen", amount=60}
		},
		icon = "__angelspetrochem__/graphics/icons/liquid-hydrochloric-acid.png",
		icon_size = 32,
	},
	{
		type = "recipe",
		name = "hydrofluoric-acid-separation",
		category = "petrochem-electrolyser",
		subgroup = "clowns-electrolysis",
		order = "f",
		energy_required = 2,
		enabled = false,
		ingredients =
		{
			{type="fluid", name="liquid-hydrofluoric-acid", amount=100}
		},
		results=
		{
			{type="fluid", name="gas-fluorine", amount=40},
			{type="fluid", name="gas-hydrogen", amount=60}
		},
		icon = "__angelspetrochem__/graphics/icons/liquid-hydrofluoric-acid.png",
		icon_size = 32,
	},
	
	{
    type = "recipe",
    name = "catalyst-metal-violet",
    category = "crafting-with-fluid",
	subgroup = "petrochem-catalysts",
    energy_required = 2,
	enabled = false,
    ingredients =
	{
		{type="item", name="catalyst-metal-carrier", amount=10},
        {type="item", name="platinum-ore", amount=1},
        {type="fluid", name="liquid-mercury", amount=10},
	},
    results=
    {
		{type="item", name="catalyst-metal-violet", amount=10},
    },
    icon = "__Clowns-Processing__/graphics/icons/catalyst-metal-violet.png",
	icon_size = 32,
    order = "f[catalyst-metal-violet]",
	},
}
)