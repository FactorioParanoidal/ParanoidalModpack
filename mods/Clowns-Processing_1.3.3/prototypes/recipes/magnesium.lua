local intermediatemulti = angelsmods.marathon.intermediatemulti

data:extend(
{
	--INTERMEDIATE
	{
		type = "recipe",
		name = "magnesium-ore-processing",
		category = "ore-processing",
		subgroup = "clowns-magnesium",
		energy_required = 2,
		enabled = false,
		ingredients ={{"magnesium-ore", 4}},
		results=
		{
			{type="item", name="processed-magnesium", amount=2},
		},
		order = "a",
    },
    {
		type = "recipe",
		name = "magnesium-processed-processing",
		category = "pellet-pressing",
		subgroup = "clowns-magnesium",
		energy_required = 2,
		enabled = false,
		ingredients ={{"processed-magnesium", 3}},
		results=
		{
			{type="item", name="pellet-magnesium", amount=4},
		},
		order = "b",
    },
	--INGOT
	{
		type = "recipe",
		name = "magnesium-pellet-smelting",
		category = "blast-smelting",
		subgroup = "clowns-magnesium",
		energy_required = 4,
		enabled = false,
		ingredients =
		{
			{type="item", name="pellet-magnesium", amount=8},
			{type="item", name="solid-coke", amount=2},
			{type="item", name="solid-limestone", amount=2},
			{type="fluid",name="liquid-hydrochloric-acid",amount=30}
		},
		results=
		{
			{type="item", name="ingot-magnesium", amount=24},
			{type="item",name="solid-calcium-chloride",amount=2},
		},
		icon = "__Clowns-Processing__/graphics/icons/ingot-magnesium.png",
		icon_size = 32,
		order = "d",
    },
	--SMELTING
	{
		type = "recipe",
		name = "molten-magnesium-smelting",
		category = "induction-smelting",
		subgroup = "clowns-magnesium-casting",
		energy_required = 4,
		enabled = false,
		ingredients =
		{
		  {type="item", name="ingot-magnesium", amount=12},
		},
		results=
		{
		  {type="fluid", name="liquid-molten-magnesium", amount=120},
		},
		icon_size = 32,
		order = "i",
    },
	
	--CASTING
	{
		type = "recipe",
		name = "clowns-plate-magnesium",
		category = "casting",
		subgroup = "clowns-magnesium-casting",
		normal =
		{
			enabled = false,
			energy_required = 4,
			ingredients ={{type="fluid", name="liquid-molten-magnesium", amount=40}},
			results={{type="item", name="clowns-plate-magnesium", amount=4}},
		},
		expensive =
		{
			enabled = false,
			energy_required = 4,
			ingredients ={{type="fluid", name="liquid-molten-magnesium", amount=50 * intermediatemulti}},
			results={{type="item", name="clowns-plate-magnesium", amount=4}},
		},
		icon_size = 32,
		order = "j",
    },
}
)