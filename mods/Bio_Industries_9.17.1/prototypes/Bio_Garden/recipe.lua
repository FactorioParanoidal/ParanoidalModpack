
--- Bio Gardens
data:extend({


  --- Garden (ENTITY)
	{
		type = "recipe",
		name = "bi_recipe_bio_garden",
		icon = "__Bio_Industries__/graphics/icons/bio_garden_icon.png",
		icon_size = 32,
		enabled = false,
		energy_required = 10,
		ingredients =
		{
		  {"stone-wall", 12},
		  {"stone-crushed", 50},
		  {"seedling", 50}
		},
		result = "bi-bio-garden",
		subgroup = "bio-bio-gardens-fluid",
		order = "a[bi]",	
	},
 
 
 --- Clean Air 1
	{
		type = "recipe",
		name = "bi_recipe_clean_air_1",
		icon = "__Bio_Industries__/graphics/icons/clean-air_mk1.png",
		icon_size = 32,
		order = "zzz-clean-air",
		category = "clean-air",
		subgroup = "bio-bio-gardens-fluid",
		enabled = false,
		always_show_made_in = true,
		allow_decomposition = false,
		energy_required = 40,
		ingredients =
		{
		  {type="fluid", name="water", amount=50},
		  {type="item", name="fertiliser", amount=1}  
		},
		results=
		{
		  {type="item", name="bi-purified-air", amount=1, probability=0},
		},
	},

	
 --- Clean Air 2
	{
		type = "recipe",
		name = "bi_recipe_clean_air_2",
		icon = "__Bio_Industries__/graphics/icons/clean-air_mk2.png",
		icon_size = 32,
		order = "zzz-clean-air2",
		category = "clean-air",
		subgroup = "bio-bio-gardens-fluid",
		enabled = false, 
		always_show_made_in = true,	
		allow_decomposition = false,
		energy_required = 100,
		ingredients =
		{
		  {type="fluid", name="water", amount=50},
		  {type="item", name="bi-adv-fertiliser", amount=1},     
		},
		results=
		{
		  {type="item", name="bi-purified-air", amount=1, probability=0},
		},     
	},
	
  }
)

