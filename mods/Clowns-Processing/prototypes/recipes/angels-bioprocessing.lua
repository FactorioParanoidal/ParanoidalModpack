if mods["angelsbioprocessing"] then
  data:extend(
{
  -----------
  -- Algae --
  -----------
  --Orange
	--[[{
		type = "recipe",
		name = "algae-orange",
		category = "bio-processing",
		subgroup = "bio-processing-green",
		enabled = false,
		energy_required = 20,
		ingredients =
		{
		  {type="fluid", name="angels-water-mineralized", amount=100},
		  {type="fluid", name="angels-gas-carbon-dioxide", amount=100}
		},
		results=
		{
		  {type="item", name="algae-orange", amount=40},
		},
		icon = "__angelsbioprocessinggraphics__/graphics/icons/algae-green.png",
		icon_size = 32,
		order = "a",
  },]]
  --Violet
	{
		type = "recipe",
		name = "clowns-algae-violet",
		category = "angels-bio-processing-4",
		subgroup = "bio-processing-violet",
		enabled = false,
		energy_required = 20,
		ingredients =
		{
		  {type="fluid", name="angels-water-mineralized", amount=100},
		  {type="fluid", name="angels-gas-carbon-dioxide", amount=100}
		},
		results=
		{
		  {type="item", name="clowns-algae-violet", amount=40},
		},
		order = "b",
  },
  --Mercury from Violet
	{
		type = "recipe",
		name = "clowns-methylmercury-algae",
		category = "angels-liquifying",
		subgroup = "bio-processing-violet",
		enabled = false,
		energy_required = 3,
		ingredients ={
		{type="item", name="clowns-algae-violet", amount=10},
		},
		results=
		{
		  {type="fluid", name="clowns-liquid-dimethylmercury", amount=2},
		},
		icons = angelsmods.functions.create_viscous_liquid_recipe_icon(
		nil,
		{{ 118, 141, 138 },{ 94, 113, 110 },{ 94, 113, 110 }},
		{"clowns-algae-violet"}
		),
	order = "c [cellulose-fiber-algae]",
  },
  -------------
  -- Gardens --
  -------------
  --swamp from soil
	{
		type = "recipe",
		name = "swamp-garden-generation",
		icon = "__angelsbioprocessinggraphics__/graphics/icons/swamp-garden.png",
    	icon_size = 32,
    	category = "angels-swamp-farming",
    	subgroup = "angels-farming-swamp-seed",
		order = "g[temperate-garden-generation]-c",
		energy_required = 600,
		enabled = false,
		ingredients =
		{
			{type = "item", name = "angels-solid-soil", amount = 1000},
			{type = "fluid", name = "angels-water-viscous-mud", amount = 1000},
			{type = "item", name = "angels-solid-fertilizer", amount = 200}
		},
		results =
		{
			{type = "item", name = "angels-swamp-garden", amount = 1}
		},
		main_product = "angels-swamp-garden",
	},

	--temperate from soil
	{
		type = "recipe",
		name = "temperate-garden-generation",
		category = "angels-temperate-farming",
		subgroup = "angels-farming-temperate-seed",
		enabled = false,
		energy_required = 1000,
		ingredients =
		{
			{type = "item", name = "angels-solid-compost", amount = 500},
			{type = "fluid", name = "water", amount = 1000},
			{type = "item", name = "angels-solid-fertilizer", amount = 500}
		},
		results=
		{
			{type = "item", name = "angels-temperate-garden", amount = 1}
		},
		main_product = "angels-temperate-garden",
		icon = "__angelsbioprocessinggraphics__/graphics/icons/temperate-garden.png",
		icon_size = 32,
		order = "g[temperate-garden-generation]-c",
  },
  --desert from soil
	{
		type = "recipe",
		name = "desert-garden-generation",
		category = "angels-desert-farming",
		subgroup = "angels-farming-desert-seed",
		enabled = false,
		energy_required = 1000,
		ingredients =
		{
			{type = "item", name = "angels-solid-sand", amount = 500},
			{type = "fluid", name = "angels-water-saline", amount = 1000},
			{type = "item", name = "angels-solid-fertilizer", amount = 500}
		},
		results=
		{
			{type = "item", name = "angels-desert-garden", amount = 1}
		},
		main_product = "angels-desert-garden",
		icon = "__angelsbioprocessinggraphics__/graphics/icons/desert-garden.png",
		icon_size = 32,
		order = "g[temperate-garden-generation]-c",
  },
  --temperate mutation
	{
		type = "recipe",
		name = "temperate-garden-mutation",
		category = "angels-seed-extractor",
		subgroup = "angels-farming-temperate-seed",
		enabled = false,
		energy_required = 600,
		ingredients =
		{
			{type = "item", name = "angels-desert-garden", amount = 1},
			{type = "item", name = "angels-swamp-garden", amount = 1},
			{type = "item", name = "uranium-235", amount = 1},
		},
		results=
		{
			{type = "item", name = "angels-temperate-garden", amount = 1}
		},
		icon = "__angelsbioprocessinggraphics__/graphics/icons/temperate-garden.png",
		icon_size = 32,
		order = "mc",
  },
  --desert mutation
	{
		type = "recipe",
		name = "desert-garden-mutation",
		category = "angels-seed-extractor",
		subgroup = "angels-farming-desert-seed",
		enabled = false,
		energy_required = 600,
		ingredients =
		{
			{type = "item", name = "angels-temperate-garden", amount = 1},
			{type = "item", name = "angels-swamp-garden", amount = 1},
			{type = "item", name = "uranium-235", amount = 1},
		},
		results=
		{
			{type = "item", name = "angels-desert-garden", amount = 1}
		},
		icon = "__angelsbioprocessinggraphics__/graphics/icons/desert-garden.png",
		icon_size = 32,
		order = "mc",
  },
  --swamp mutation
	{
		type = "recipe",
		name = "swamp-garden-mutation",
		category = "angels-seed-extractor",
		subgroup = "angels-farming-swamp-seed",
		enabled = false,
		energy_required = 600,
		ingredients =
		{
			{type = "item", name = "angels-desert-garden", amount = 1},
			{type = "item", name = "angels-temperate-garden", amount = 1},
			{type = "item", name = "uranium-235", amount = 1},
		},
		results=
		{
			{type = "item", name = "angels-swamp-garden", amount = 1}
		},
		icon = "__angelsbioprocessinggraphics__/graphics/icons/swamp-garden.png",
		icon_size = 32,
		order = "mc",
  },
  --alternative fertilizer
	{
		type = "recipe",
		name = "clowns-diammonium-phosphate-fertilizer",
		icons = {
			{
				icon = "__angelsbioprocessinggraphics__/graphics/icons/solid-fertilizer.png",
				icon_size = 32, icon_mipmaps = 1
			},
			{
				icon = "__Clowns-Processing__/graphics/icons/advsorting-overlay.png",
				icon_size = 32, icon_mipmaps = 1
			},
		},
		category = "chemistry",
		subgroup = "clowns-phosphorus",
		order = "c",
		energy_required = 10,
		enabled = false,
		allow_decomposition = false,
		ingredients =
		{
			{type="fluid", name="clowns-liquid-phosphoric-acid", amount=10},
			{type="fluid", name="angels-gas-ammonia", amount=10},
		},
		results =
		{
			{type="item", name="angels-solid-fertilizer", amount=1}
		},
	},
})
end
