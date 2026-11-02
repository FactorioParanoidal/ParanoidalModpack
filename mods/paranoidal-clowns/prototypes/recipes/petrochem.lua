data:extend(
{
	{
		type = "recipe",
		name = "catalytic-water-separation-oxygen",
		categories = {"angels-petrochem-electrolyser"},
		subgroup = "clowns-electrolysis",
		order = "a",
		energy_required = 2,
		enabled = false,
		ingredients =
		{
			{type = "fluid", name = "angels-water-purified", amount = 1000},
			{type = "item", name = "clowns-catalyst-metal-violet", amount = 1}
		},
		results=
		{
			{type = "fluid", name = "angels-gas-oxygen", amount = 800},
			{type = "item", name = "angels-catalyst-metal-carrier", amount = 1}
		},
		icons = angelsmods.functions.create_gas_recipe_icon({"angels-gas-oxygen"}, "OOH",{{"__paranoidal-clowns__/graphics/icons/catalyst-metal-violet.png",icon_size=32}}),
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
		categories = {"angels-petrochem-electrolyser"},
		subgroup = "clowns-electrolysis",
		order = "b",
		energy_required = 2,
		enabled = false,
		ingredients =
		{
			{type = "fluid", name = "angels-water-purified", amount = 1000},
			{type = "item", name = "clowns-catalyst-metal-violet", amount = 1}
		},
		results =
		{
			{type = "fluid", name = "angels-gas-hydrogen", amount = 1200},
			{type = "item", name = "angels-catalyst-metal-carrier", amount = 1}
		},
		icons = angelsmods.functions.create_gas_recipe_icon({"angels-gas-hydrogen"}, "HHO",{{"__paranoidal-clowns__/graphics/icons/catalyst-metal-violet.png",icon_size=32}}),
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
		categories = {"chemistry"},
		subgroup = "clowns-electrolysis",
		order = "d",
		energy_required = 2,
		enabled = false,
		ingredients =
		{
			{type = "fluid", name = "angels-gas-compressed-air", amount = 1000},
			{type = "item", name = "clowns-catalyst-metal-violet", amount = 1}
		},
		results =
		{
			{type = "fluid", name = "angels-gas-nitrogen", amount = 1000},
			{type = "item", name = "angels-catalyst-metal-carrier", amount = 1}
		},
		icons = angelsmods.functions.create_gas_recipe_icon({"angels-gas-nitrogen"}, "NNO",{{"__paranoidal-clowns__/graphics/icons/catalyst-metal-violet.png",icon_size=32}}),
	},
	{
		type = "recipe",
		name = "catalytic-air-separation-oxygen",
		categories = {"chemistry"},
		subgroup = "clowns-electrolysis",
		order = "c",
		energy_required = 2,
		enabled = false,
		ingredients =
		{
			{type = "fluid", name = "angels-gas-compressed-air", amount = 1000},
			{type = "item", name = "clowns-catalyst-metal-violet", amount = 1}
		},
		results =
		{
			{type = "fluid", name = "angels-gas-oxygen", amount = 1000},
			{type = "item", name = "angels-catalyst-metal-carrier", amount = 1}
		},
		icons = angelsmods.functions.create_gas_recipe_icon({"angels-gas-oxygen"}, "OON",{{"__paranoidal-clowns__/graphics/icons/catalyst-metal-violet.png",icon_size=32}}),
	},
	{
		type = "recipe",
		name = "hydrochloric-acid-separation",
		categories = {"angels-petrochem-electrolyser"},
		subgroup = "clowns-electrolysis",
		order = "e",
		energy_required = 2,
		enabled = false,
		ingredients =
		{
			{type = "fluid", name = "angels-liquid-hydrochloric-acid", amount = 100}
		},
		results =
		{
			{type = "fluid", name = "angels-gas-chlorine", amount = 40},
			{type = "fluid", name = "angels-gas-hydrogen", amount = 60}
		},
		icons = angelsmods.functions.create_gas_recipe_icon({"angels-gas-chlorine","angels-gas-hydrogen"}, "CHOc"),
	},
	{
		type = "recipe",
		name = "hydrofluoric-acid-separation",
		categories = {"angels-petrochem-electrolyser"},
		subgroup = "clowns-electrolysis",
		order = "f",
		energy_required = 2,
		enabled = false,
		ingredients =
		{
			{type = "fluid", name = "angels-liquid-hydrofluoric-acid", amount = 100}
		},
		results =
		{
			{type = "fluid", name = "clowns-gas-fluorine", amount = 40},
			{type = "fluid", name = "angels-gas-hydrogen", amount = 60}
		},
		icons = angelsmods.functions.create_gas_recipe_icon({"clowns-gas-fluorine","angels-gas-hydrogen"}, "FHH",{"angels-liquid-hydrofluoric-acid"}),
	},
	{
		type = "recipe",
		name = "clowns-catalyst-metal-violet",
		categories = {"crafting-with-fluid"},
		subgroup = "angels-petrochem-catalysts",
		energy_required = 2,
		enabled = false,
		ingredients =
		{
			{type = "item", name = "angels-catalyst-metal-carrier", amount = 10},
			{type = "item", name = clowns.special_vanilla and "angels-solid-sodium" or "angels-platinum-ore", amount = 1},
			{type = "fluid", name = "clowns-liquid-mercury", amount = 10},
		},
		results =
		{
			{type = "item", name = "clowns-catalyst-metal-violet", amount = 10},
		},
		icon = "__paranoidal-clowns__/graphics/icons/catalyst-metal-violet.png",
		icon_size = 32,
		order = "f[catalyst-metal-violet]",
	},
}
)
