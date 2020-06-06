local intermediatemulti = angelsmods.marathon.intermediatemulti

data:extend(
{
	--INTERMEDIATE
	{
		type = "recipe",
		name = "depleted-uranium-ore-processing",
		category = "ore-processing",
		subgroup = "clowns-depleted-uranium",
		energy_required = 2,
		enabled = false,
		ingredients ={{"uranium-238", 4 * 4}},--4 is standard
		results=
		{
			{type="item", name="processed-depleted-uranium", amount=2},
		},
		order = "a",
    },
    {
		type = "recipe",
		name = "depleted-uranium-processed-processing",
		category = "pellet-pressing",
		subgroup = "clowns-depleted-uranium",
		energy_required = 2,
		enabled = false,
		ingredients ={{"processed-depleted-uranium", 3}},
		results=
		{
			{type="item", name="pellet-depleted-uranium", amount=4},
		},
		order = "b",
    },
	--INGOT
	{
		type = "recipe",
		name = "depleted-uranium-pellet-smelting",
		category = "blast-smelting",
		subgroup = "clowns-depleted-uranium",
		energy_required = 4,
		enabled = false,
		ingredients =
		{
			{type="item", name="pellet-depleted-uranium", amount=8},
		},
		results=
		{
			{type="item", name="powder-depleted-uranium", amount=24},
		},
		order = "d",
    },
	--ALLOYING
	{
		type = "recipe",
		name = "casting-powder-depleted-uranium-1",
		category = "powder-mixing",
		subgroup = "clowns-depleted-uranium-casting",
		energy_required = 4,
		enabled = false,
		ingredients =
		{
			{type="item", name="powder-depleted-uranium", amount=12},
		},
		results=
		{
			{type="item", name="casting-powder-depleted-uranium", amount=12},
		},
		icon_size = 32,
		order = "e-a",
    },
	{
		type = "recipe",
		name = "casting-powder-depleted-uranium-2",
		category = "powder-mixing",
		subgroup = "clowns-depleted-uranium-casting",
		energy_required = 4,
		enabled = false,
		ingredients =
		{
			{type="item", name="powder-depleted-uranium", amount=12},
			{type="item", name="powder-osmium", amount=12},
			--magnesium powder? aluminium powder?
		},
		results=
		{
			{type="item", name="casting-powder-depleted-uranium", amount=24},
		},
		icon_size = 32,
		order = "e-b",
    },
	--[[{
		type = "recipe",
		name = "casting-powder-depleted-uranium-3",
		category = "powder-mixing",
		subgroup = "clowns-depleted-uranium-casting",
		energy_required = 4,
		enabled = false,
		ingredients =
		{
			{type="item", name="powder-depleted-uranium", amount=12},
			{type="item", name="powder-osmium", amount=12},
			{type="item", name="powder-aluminium", amount=12},
		},
		results=
		{
			{type="item", name="casting-powder-depleted-uranium", amount=36},
		},
		icon_size = 32,
		order = "e-c",
    },]]
	--SINTERING
	{
		type = "recipe",
		name = "clowns-plate-depleted-uranium",
		category = "sintering",
		subgroup = "clowns-depleted-uranium-casting",
		normal =
		{
			enabled = false,
			energy_required = 4,
			ingredients ={{type="item", name="casting-powder-depleted-uranium", amount=12}},
			results={{type="item", name="clowns-plate-depleted-uranium", amount=12}},
		},
		expensive =
		{
			enabled = false,
			energy_required = 4,
			ingredients ={{type="item", name="casting-powder-depleted-uranium", amount=15 * intermediatemulti}},
			results={{type="item", name="clowns-plate-depleted-uranium", amount=12}},
		},
		icon_size = 32,
		order = "f",
    },
}
)