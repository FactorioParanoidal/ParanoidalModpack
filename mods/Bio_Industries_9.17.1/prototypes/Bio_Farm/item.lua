data:extend({

	---- Seed
	{
		type = "item",
		name = "bi-seed",
		icon = "__Bio_Industries__/graphics/icons/bio_seed.png",
		icon_size = 32,
		category = "biofarm-mod-greenhouse",
		subgroup = "bio-bio-farm",
		order = "x[bi]-a[bi-seed]",
		fuel_value = "0.5MJ",
		fuel_category = "chemical",
		stack_size= 800
	},


	---- Seedling
	{
		type = "item",
		name = "seedling",
		icon = "__Bio_Industries__/graphics/icons/Seedling.png",
		icon_size = 32,
		subgroup = "bio-bio-farm",
		order = "x[bi]-b[bi-seedling]",
		place_result="seedling",
		fuel_value = "1MJ",
		fuel_category = "chemical",
		stack_size= 400
	},

  ----Bio Farm
	{
		type= "item",
		name= "bi-bio-farm",
		icon = "__Bio_Industries__/graphics/icons/Bio_Farm_Icon.png",
		icon_size = 32,
		subgroup = "production-machine",
		order = "x[bi]-ab[bi-bio-farm]",
		place_result = "bi-bio-farm",
		stack_size= 10,
	},
   
  ----Bio Greenhouse (Nursery)
	{
		type= "item",
		name= "bi-bio-greenhouse",
		icon = "__Bio_Industries__/graphics/icons/bio_greenhouse.png",
		icon_size = 32,
		subgroup = "production-machine",
		order = "x[bi]-aa[bi_bio_greenhouse]",
		place_result = "bi-bio-greenhouse",
		stack_size= 10,
	},
  
 	--- Cokery
	{
		type = "item",
		name = "bi-cokery",
		icon = "__Bio_Industries__/graphics/icons/cokery.png",
		icon_size = 32,
		subgroup = "production-machine",
		order = "x[bi]-b[bi-cokery]",
		place_result = "bi-cokery",
		stack_size = 10
	},

	--- Stone Crusher
	{
		type = "item",
		name = "bi-stone-crusher",
		icon = "__Bio_Industries__/graphics/icons/stone_crusher.png",
		icon_size = 32,
		subgroup = "production-machine",
		order = "x[bi]-c[bi-stone-crusher]",
		place_result = "bi-stone-crusher",
		stack_size = 10
	},

  --- Wood Pulp
	{
		type = "item",
		name = "bi-woodpulp",
		icon = "__Bio_Industries__/graphics/icons/Woodpulp_32.png",
		icon_size = 32,
		fuel_value = "2MJ",
		fuel_category = "chemical",
		fuel_emissions_multiplier = 1.15,
		subgroup = "raw-material",	
		order = "b[woodpulp]",			
		order = "a-b[bi-woodpulp]",
		stack_size = 800
	},  

		--- Ash 
	{
		type = "item",
		name = "bi-ash",
		icon = "__Bio_Industries__/graphics/icons/ash.png",
		icon_size = 32,
		fuel_value = "1MJ",
		fuel_category = "chemical",
		fuel_emissions_multiplier = 1.1,
		subgroup = "raw-material",
		order = "a[bi]-a-b[bi-ash]",
		stack_size = 400
	},
	
	--- Charcoal
	{
		type = "item",
		name = "bi-charcoal",
		icon = "__Bio_Industries__/graphics/icons/charcoal.png",
		icon_size = 32,
		fuel_value = "5MJ", --DrD 6
		fuel_category = "chemical",
		subgroup = "raw-material",
		fuel_emissions_multiplier = 1.05,
		order = "a[bi]-a-c[charcoal]",
		stack_size = 400
	},  

	--- Coke Coal / Pellet Coke for Angels
	{
		type = "item",
		name = "pellet-coke",
		icon = "__Bio_Industries__/graphics/icons/coke-coal.png",
		icon_size = 32,
		fuel_value = "19MJ", --DrD 30
		fuel_category = "chemical",
		fuel_emissions_multiplier = 0.85,
		fuel_acceleration_multiplier = 1.1,
		fuel_top_speed_multiplier = 1.025,
		subgroup = "raw-material",
		order = "a[bi]-a-e[bi-coke-coal]",	
		stack_size = 400
	},


	--- Crushed Stone
	{
		type = "item",
		name = "stone-crushed",
		icon = "__Bio_Industries__/graphics/icons/crushed-stone.png",
		icon_size = 32,
		subgroup = "raw-material",
		order = "a[bi]-a-z[stone-crushed]",
		stack_size = 800
	},
	
	
	--- Seeb Bomb - Basic	
  {
    type = "ammo",
    name = "bi-seed-bomb-basic",
    icon = "__Bio_Industries__/graphics/icons/Seed_bomb_icon_b.png",
    icon_size = 32,
    ammo_type =
    {
      range_modifier = 3,
      cooldown_modifier = 3,
      target_type = "position",
      category = "rocket",
      action =
      {
        type = "direct",
        action_delivery =
        {
          type = "projectile",
          projectile = "seed-bomb-projectile-1",
          starting_speed = 0.05,
        }
      }
    },
    subgroup = "ammo",
    order = "a[rocket-launcher]-x[seed-bomb]-a",
    stack_size = 10
  },

  
  	--- Seeb Bomb - Standard
  {
    type = "ammo",
    name = "bi-seed-bomb-standard",
    icon = "__Bio_Industries__/graphics/icons/Seed_bomb_icon_s.png",
    icon_size = 32,
    ammo_type =
    {
      range_modifier = 3,
      cooldown_modifier = 3,
      target_type = "position",
      category = "rocket",
      action =
      {
        type = "direct",
        action_delivery =
        {
          type = "projectile",
          projectile = "seed-bomb-projectile-2",
          starting_speed = 0.05,
        }
      }
    },
    subgroup = "ammo",
    order = "a[rocket-launcher]-x[seed-bomb]-b",
    stack_size = 10
  },

  
  	--- Seeb Bomb - Advanced	
  {
    type = "ammo",
    name = "bi-seed-bomb-advanced",
    icon = "__Bio_Industries__/graphics/icons/Seed_bomb_icon_a.png",
    icon_size = 32,
    ammo_type =
    {
      range_modifier = 3,
      cooldown_modifier = 3,
      target_type = "position",
      category = "rocket",
      action =
      {
        type = "direct",
        action_delivery =
        {
          type = "projectile",
          projectile = "seed-bomb-projectile-3",
          starting_speed = 0.05,
        }
      }
    },
    subgroup = "ammo",
    order = "a[rocket-launcher]-x[seed-bomb]-c",
    stack_size = 10
  },
  
	 --- Arboretum (Entity)
	{
		type= "item",
		name= "bi-arboretum-area",
		icon = "__Bio_Industries__/graphics/icons/Arboretum_Icon.png",
		icon_size = 32,

		subgroup = "production-machine",
		order = "x[bi]-a[bi-arboretum]",
		place_result = "bi-arboretum-area",
		stack_size= 10,
	},
  
	 --- Arboretum Hidden Recipe
    {
		type = "item",
		name = "bi-arboretum-r1",
		icon = "__Bio_Industries__/graphics/icons/Seedling_b.png",
		icon_size = 32,
		flags = {"hidden"},
		subgroup = "terrain",
		order = "bi-arboretum-r1",
		stack_size = 1
	},
  
   	 --- Arboretum Hidden Recipe
    {
		type = "item",
		name = "bi-arboretum-r2",
		icon = "__Bio_Industries__/graphics/icons/bi_change_1.png",
		icon_size = 32,
		flags = {"hidden"},
		subgroup = "terrain",
		order = "bi-arboretum-r2",
		stack_size = 1
	},
   
   	 --- Arboretum Hidden Recipe
   {
		type = "item",
		name = "bi-arboretum-r3",
		icon = "__Bio_Industries__/graphics/icons/bi_change_2.png",
		icon_size = 32,
		flags = {"hidden"},
		subgroup = "terrain",
		order = "bi-arboretum-r3",
		stack_size = 1
	},
	
	 --- Arboretum Hidden Recipe	
     {
		type = "item",
		name = "bi-arboretum-r4",
		icon = "__Bio_Industries__/graphics/icons/bi_change_plant_1.png",
		icon_size = 32,
		flags = {"hidden"},
		subgroup = "terrain",
		order = "bi-arboretum-r4",
		stack_size = 1
	},
  
	 --- Arboretum Hidden Recipe  
     {
		type = "item",
		name = "bi-arboretum-r5",
		icon = "__Bio_Industries__/graphics/icons/bi_change_plant_2.png",
		icon_size = 32,
		flags = {"hidden"},
		subgroup = "terrain",
		order = "bi-arboretum-r5",
		stack_size = 1
	},
  
})


--- Fertilizer can change terrain to better terrain
if mods["alien-biomes"] then

	data:extend({
		--- Fertiliser
		{
			type = "item",
			name = "fertiliser",
			icon = "__Bio_Industries__/graphics/icons/fertiliser_32.png",
			icon_size = 32,
			subgroup = "intermediate-product",
			order = "b[fertiliser]",
			stack_size = 200,
			place_as_tile =
			{
				result = "vegetation-green-grass-3",
				condition_size = 1,
				condition = { "water-tile" }
			},	
		},
		
		--- Adv Fertiliser
		{
			type = "item",
			name = "bi-adv-fertiliser",
			icon = "__Bio_Industries__/graphics/icons/advanced_fertiliser_32.png",
			icon_size = 32,
			subgroup = "intermediate-product",
			order = "b[fertiliser]-b[bi-adv-fertiliser]",
			stack_size = 200,
			place_as_tile =
			{
				result = "vegetation-green-grass-1",
				condition_size = 1,
				condition = { "water-tile" }
			},	
		},	

		
	})

else

	data:extend({
		--- Fertiliser
		{
			type = "item",
			name = "fertiliser",
			icon = "__Bio_Industries__/graphics/icons/fertiliser_32.png",
			icon_size = 32,
			subgroup = "intermediate-product",
			order = "b[fertiliser]",
			stack_size = 200,
			place_as_tile =
			{
				result = "grass-3",
				condition_size = 1,
				condition = { "water-tile" }
			},	
		},
		
		--- Adv Fertiliser
		{
			type = "item",
			name = "bi-adv-fertiliser",
			icon = "__Bio_Industries__/graphics/icons/advanced_fertiliser_32.png",
			icon_size = 32,
			subgroup = "intermediate-product",
			order = "b[fertiliser]-b[bi-adv-fertiliser]",
			stack_size = 200,
			place_as_tile =
			{
				result = "grass-1",
				condition_size = 1,
				condition = { "water-tile" }
			},	
		},	

		
	})

end

