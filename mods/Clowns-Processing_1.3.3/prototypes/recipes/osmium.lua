local intermediatemulti = angelsmods.marathon.intermediatemulti

data:extend(
{
	--INTERMEDIATE
	{
		type = "recipe",
		name = "osmium-ore-processing",
		category = "ore-processing",
		subgroup = "clowns-osmium",
		energy_required = 2,
		enabled = false,
		ingredients ={{"osmium-ore", 4}},
		results=
		{
			{type="item", name="processed-osmium", amount=2},
		},
		order = "a",
    },
    {
		type = "recipe",
		name = "osmium-processed-processing",
		category = "pellet-pressing",
		subgroup = "clowns-osmium",
		energy_required = 2,
		enabled = false,
		ingredients ={{"processed-osmium", 3}},
		results=
		{
			{type="item", name="pellet-osmium", amount=4},
		},
		order = "b",
    },
	--INGOT
	{
		type = "recipe",
		name = "osmium-pellet-smelting",
		category = "blast-smelting",
		subgroup = "clowns-osmium",
		energy_required = 4,
		enabled = false,
		ingredients =
		{
			{type="item", name="pellet-osmium", amount=8},
		},
		results=
		{
			{type="item", name="powder-osmium", amount=24},
		},
		order = "d",
    },
	--ALLOYING
	{
		type = "recipe",
		name = "casting-powder-osmium",
		category = "powder-mixing",
		subgroup = "clowns-osmium-casting",
		energy_required = 4,
		enabled = false,
		ingredients =
		{
			{type="item", name="powder-osmium", amount=12},
			--{type="item", name="powder-platinum", amount=12},
		},
		results=
		{
			{type="item", name="casting-powder-osmium", amount=12},
		},
		icon_size = 32,
		order = "a",
    },
	--SINTERING
	{
		type = "recipe",
		name = "clowns-plate-osmium",
		category = "sintering",
		subgroup = "clowns-osmium-casting",
		normal =
		{
			enabled = false,
			energy_required = 4,
			ingredients ={{type="item", name="casting-powder-osmium", amount=12}},
			results={{type="item", name="clowns-plate-osmium", amount=12}},
		},
		expensive =
		{
			enabled = false,
			energy_required = 4,
			ingredients ={{type="item", name="casting-powder-osmium", amount=15 * intermediatemulti}},
			results={{type="item", name="clowns-plate-osmium", amount=12}},
		},
		icon_size = 32,
		order = "b",
    },
}
)