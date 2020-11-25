if mods["angelsbioprocessing"] then
  data:extend(
{
  -----------
  -- Algae --
  -----------
  --Orange
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
  --Violet
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
		  {type="item", name="algae-violet", amount=40},
		},
		icon = "__angelsbioprocessing__/graphics/icons/algae-green.png",
		icon_size = 32,
		order = "a",
  },
  --Mercury from Violet
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
		  {type="fluid", name="liquid-dimethylmercury", amount=2},
		},
		icon = "__angelsbioprocessing__/graphics/icons/cellulose-fiber-algae.png",
		icon_size = 32,
		order = "b [cellulose-fiber-algae]",
  },
  -------------
  -- Gardens --
  -------------
  --swamp from soil
	{
		type = "recipe",
		name = "swamp-garden-generation",
		icon = "__angelsbioprocessing__/graphics/icons/swamp-garden.png",
    	icon_size = 32,
    	category = "swamp-farming",
    	subgroup = "farming-swamp-seed",
		order = "g[temperate-garden-generation]-c",
		energy_required = 600,
		enabled = false,
		ingredients =
		{
			{type = "item", name = "solid-soil", amount = 1000},
			{type = "fluid", name = "water-viscous-mud", amount = 1000},
			{type = "item", name = "solid-fertilizer", amount = 200}
		},
		results =
		{
		{type = "item", name = "swamp-garden", amount = 1}
		},
	},

	--temperate from soil
	{
		type = "recipe",
		name = "temperate-garden-generation",
		category = "temperate-farming",
		subgroup = "farming-temperate-seed",
		enabled = false,
		energy_required = 1000,
		ingredients =
		{
			{type = "item", name = "solid-compost", amount = 500},
			{type = "fluid", name = "water", amount = 1000},
			{type = "item", name = "solid-fertilizer", amount = 500}
		},
		results=
		{
			{type = "item", name = "temperate-garden", amount = 1}
		},
		icon = "__angelsbioprocessing__/graphics/icons/temperate-garden.png",
		icon_size = 32,
		order = "g[temperate-garden-generation]-c",
  },
  --desert from soil
	{
		type = "recipe",
		name = "desert-garden-generation",
		category = "desert-farming",
		subgroup = "farming-desert-seed",
		enabled = false,
		energy_required = 1000,
		ingredients =
		{
			{type = "item", name = "solid-sand", amount = 500},
			{type = "fluid", name = "water-saline", amount = 1000},
			{type = "item", name = "solid-fertilizer", amount = 500}
		},
		results=
		{
			{type = "item", name = "desert-garden", amount = 1}
		},
		icon = "__angelsbioprocessing__/graphics/icons/desert-garden.png",
		icon_size = 32,
		order = "g[temperate-garden-generation]-c",
  },
  --temperate mutation
	{
		type = "recipe",
		name = "temperate-garden-mutation",
		category = "seed-extractor",
		subgroup = "farming-temperate-seed",
		enabled = false,
		energy_required = 600,
		ingredients =
		{
			{type = "item", name = "desert-garden", amount = 1},
			{type = "item", name = "swamp-garden", amount = 1},
			{type = "item", name = "uranium-235", amount = 1},
		},
		results=
		{
			{type = "item", name = "temperate-garden", amount = 1}
		},
		icon = "__angelsbioprocessing__/graphics/icons/temperate-garden.png",
		icon_size = 32,
		order = "mc",
  },
  --desert mutation
	{
		type = "recipe",
		name = "desert-garden-mutation",
		category = "seed-extractor",
		subgroup = "farming-desert-seed",
		enabled = false,
		energy_required = 600,
		ingredients =
		{
			{type = "item", name = "temperate-garden", amount = 1},
			{type = "item", name = "swamp-garden", amount = 1},
			{type = "item", name = "uranium-235", amount = 1},
		},
		results=
		{
			{type = "item", name = "desert-garden", amount = 1}
		},
		icon = "__angelsbioprocessing__/graphics/icons/desert-garden.png",
		icon_size = 32,
		order = "mc",
  },
  --swamp mutation
	{
		type = "recipe",
		name = "swamp-garden-mutation",
		category = "seed-extractor",
		subgroup = "farming-swamp-seed",
		enabled = false,
		energy_required = 600,
		ingredients =
		{
			{type = "item", name = "desert-garden", amount = 1},
			{type = "item", name = "temperate-garden", amount = 1},
			{type = "item", name = "uranium-235", amount = 1},
		},
		results=
		{
			{type = "item", name = "swamp-garden", amount = 1}
		},
		icon = "__angelsbioprocessing__/graphics/icons/swamp-garden.png",
		icon_size = 32,
		order = "mc",
  },
  --alternative fertilizer
	{
		type = "recipe",
		name = "diammonium-phosphate-fertilizer",
		icon = "__angelsbioprocessing__/graphics/icons/solid-fertilizer.png",
		icon_size = 32,
		category = "chemistry",
		subgroup = "clowns-phosphorus",
		order = "c",
		energy_required = 10,
		enabled = false,
		allow_decomposition = false,
		ingredients =
		{
			{type="fluid", name="liquid-phosphoric-acid", amount=10},
			{type="fluid", name="gas-ammonia", amount=10},
		},
		results =
		{
			{type="item", name="solid-fertilizer", amount=1}
		},
	},
})
end
