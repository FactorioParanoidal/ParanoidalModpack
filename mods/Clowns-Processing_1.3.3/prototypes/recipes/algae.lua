data:extend(
{
	{
		type = "recipe",
		name = "algae-orange",
		category = "bio-processing",
		subgroup = "bio-processing-green",
		enabled = false,
		energy_required = 20,
		ingredients =
		{
		  {type="fluid", name="water-mineralized", amount=100},
		  {type="fluid", name="gas-carbon-dioxide", amount=100}
		},
		results=
		{
		  {type="item", name="algae-orange", amount=40},
		},
		icon = "__angelsbioprocessing__/graphics/icons/algae-green.png",
		icon_size = 32,
		order = "a",
	},
	{
		type = "recipe",
		name = "algae-violet",
		category = "bio-processing",
		subgroup = "bio-processing-green",
		enabled = false,
		energy_required = 20,
		ingredients =
		{
		  {type="fluid", name="water-mineralized", amount=100},
		  {type="fluid", name="gas-carbon-dioxide", amount=100}
		},
		results=
		{
		  {type="item", name="algae-orange", amount=40},
		},
		icon = "__angelsbioprocessing__/graphics/icons/algae-green.png",
		icon_size = 32,
		order = "a",
	},
	{
		type = "recipe",
		name = "methylmercury-algae",
		category = "liquifying",
		subgroup = "bio-processing-green",
		enabled = false,
		energy_required = 3,
		ingredients ={
		{type="item", name="algae-violet", amount=10},
		},
		results=
		{
		  {type="fluid", name="gas-methylmercury", amount=5},
		},
		icon = "__angelsbioprocessing__/graphics/icons/cellulose-fiber-algae.png",
		icon_size = 32,
		order = "b [cellulose-fiber-algae]",
	},
}
)