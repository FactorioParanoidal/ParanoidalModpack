local BioInd = require('common')('Bio_Industries_2')

local ICONPATH = BioInd.modRoot .. "/graphics/icons/"
local ICONPATH_W = BioInd.modRoot .. "/graphics/icons/weapons/"
local ICONPATH_E = BioInd.modRoot .. "/graphics/icons/entity/"
local ICONPATHMIPS = BioInd.modRoot .. "/graphics/icons/mips/"

data:extend(
{
  ---- Seed
  {
    type = "item",
    name = "bi-seed",
    icons = { {icon = ICONPATH .. "bio_seed.png", icon_size = 64, }},
    pictures = {
      { size = 64, filename = ICONPATHMIPS.."bio_seed_1.png", scale = 0.48, mipmap_count = 4 },
      { size = 64, filename = ICONPATHMIPS.."bio_seed_2.png", scale = 0.46, mipmap_count = 4 },
      { size = 64, filename = ICONPATHMIPS.."bio_seed_3.png", scale = 0.45, mipmap_count = 4 },
      { size = 64, filename = ICONPATHMIPS.."bio_seed_4.png", scale = 0.43, mipmap_count = 4 }
    },
    category = "biofarm-mod-greenhouse",
    subgroup = "bio-bio-farm",
    order = "x[bi]-a[bi-seed]",
    fuel_value = "0.5MJ",
    fuel_category = "chemical",
    stack_size= 800,
	weight = 10 * kg,
  },

  ---- Seedling
  {
    type = "item",
    name = "seedling",
    localised_name = {"entity-name.seedling"},
    localised_description = {"entity-description.seedling"},
	icons = { {icon = ICONPATH .. "Seedling.png", icon_size = 64, }},
    pictures = {
      { size = 64, filename = ICONPATHMIPS.."seedling_1.png", scale = 0.57, mipmap_count = 9 },
      { size = 64, filename = ICONPATHMIPS.."seedling_2.png", scale = 0.52, mipmap_count = 9 },
      { size = 64, filename = ICONPATHMIPS.."seedling_3.png", scale = 0.47, mipmap_count = 9 },
      { size = 64, filename = ICONPATHMIPS.."seedling_4.png", scale = 0.52, mipmap_count = 9 },
      { size = 64, filename = ICONPATHMIPS.."seedling_5.png", scale = 0.62, mipmap_count = 9 },
      { size = 64, filename = ICONPATHMIPS.."seedling_6.png", scale = 0.52, mipmap_count = 9 },
      { size = 64, filename = ICONPATHMIPS.."seedling_7.png", scale = 0.72, mipmap_count = 9 },
      { size = 64, filename = ICONPATHMIPS.."seedling_8.png", scale = 0.52, mipmap_count = 9 },
      { size = 64, filename = ICONPATHMIPS.."seedling_9.png", scale = 0.47, mipmap_count = 9 }
    },
    subgroup = "bio-bio-farm",
    order = "x[bi]-b[bi-seedling]",
    place_result = "seedling",
    fuel_value = "0.5MJ",
    fuel_category = "chemical",
    stack_size= 400,
	weight = 20 * kg,
  },

  ----Bio Farm
  {
    type= "item",
    name= "bi-bio-farm",
    localised_name = {"entity-name.bi-bio-farm"},
    localised_description = {"entity-description.bi-bio-farm"},
	icons = { {icon = ICONPATH_E .. "bio_Farm_Icon.png", icon_size = 64, }},
    subgroup = "production-machine",
    order = "x[bi]-ab[bi-bio-farm]",
    place_result = "bi-bio-farm",
    stack_size= 10,
	weight = 400 * kg,
  },

  ----Bio Greenhouse (Nursery)
  {
    type= "item",
    name= "bi-bio-greenhouse",
    localised_name = {"entity-name.bi-bio-greenhouse"},
    localised_description = {"entity-description.bi-bio-greenhouse"},
	icons = { {icon = ICONPATH_E .. "bio_greenhouse.png", icon_size = 64, }},
    subgroup = "production-machine",
    order = "x[bi]-aa[bi-bio-greenhouse]",
    place_result = "bi-bio-greenhouse",
    stack_size= 10,
    weight = 250 * kg,
  },

  --- Cokery
  {
    type = "item",
    name = "bi-cokery",
	icons = { {icon = ICONPATH_E .. "cokery.png", icon_size = 64, }},
    subgroup = "production-machine",
    order = "x[bi]-b[bi-cokery]",
    place_result = "bi-cokery",
    stack_size = 10,
    weight = 100 * kg,	
  },

  --- Stone Crusher
  {
    type = "item",
    name = "bi-stone-crusher",
    localised_name = {"entity-name.bi-stone-crusher"},
    localised_description = {"entity-description.bi-stone-crusher"},
	icons = { {icon = ICONPATH_E .. "stone_crusher.png", icon_size = 64, }},
    subgroup = "production-machine",
    order = "x[bi]-c[bi-stone-crusher]",
    place_result = "bi-stone-crusher",
    stack_size = 10,
    weight = 400 * kg,
  },

  --- Wood Pulp
  {
    type = "item",
    name = "bi-woodpulp",
	icons = { {icon = ICONPATH .. "woodpulp_64.png", icon_size = 64, }},
    pictures = {
      { size = 64, filename = ICONPATHMIPS.."woodpulp_1.png", scale = 0.55, mipmap_count = 4 },
      { size = 64, filename = ICONPATHMIPS.."woodpulp_2.png", scale = 0.53, mipmap_count = 4 },
      { size = 64, filename = ICONPATHMIPS.."woodpulp_3.png", scale = 0.51, mipmap_count = 4 },
      { size = 64, filename = ICONPATHMIPS.."woodpulp_4.png", scale = 0.49, mipmap_count = 4 }
    },
    fuel_value = "1MJ",
    fuel_category = "chemical",
    subgroup = "raw-material",
    order = "a-b[bi-woodpulp]",
    stack_size = 800,
    weight = 15 * kg,
  },

  --- Wood Bricks
  {
    type = "item",
    name = "wood-bricks",
	icons = { {icon = ICONPATH .. "Fuel_Brick.png", icon_size = 64, }},
    subgroup = "bio-bio-farm-raw",
    order = "a[bi]-a-bx[bi-woodbrick]",
    fuel_category = "chemical",
    fuel_value = "160MJ",
    stack_size = 200,
    weight = 40 * kg,
  },


  --- Ash
  {
    type = "item",
    name = "bi-ash",
	icons = { {icon = ICONPATH .. "ash.png", icon_size = 64, }},
    pictures = {
      { size = 64, filename = ICONPATHMIPS.."ash_1.png", scale = 0.42, mipmap_count = 4 },
      { size = 64, filename = ICONPATHMIPS.."ash_2.png", scale = 0.42, mipmap_count = 4 },
      { size = 64, filename = ICONPATHMIPS.."ash_3.png", scale = 0.42, mipmap_count = 4 },
      { size = 64, filename = ICONPATHMIPS.."ash_4.png", scale = 0.42, mipmap_count = 4 }
    },
    subgroup = "raw-material",
    order = "a[bi]-a-b[bi-ash]",
    stack_size = 400,
    weight = 12 * kg,
  },

  --- Charcoal
  {
    type = "item",
    name = "wood-charcoal",
	icons = { {icon = ICONPATH .. "charcoal.png", icon_size = 64, }},
    pictures = {
      { size = 64, filename = ICONPATHMIPS.."charcoal_1.png", scale = 0.49, mipmap_count = 4 },
      { size = 64, filename = ICONPATHMIPS.."charcoal_2.png", scale = 0.5, mipmap_count = 4 },
      { size = 64, filename = ICONPATHMIPS.."charcoal_3.png", scale = 0.5, mipmap_count = 4 },
      { size = 64, filename = ICONPATHMIPS.."charcoal_4.png", scale = 0.51, mipmap_count = 4 }
    },
    fuel_value = "6MJ",
    fuel_category = "chemical",
    subgroup = "raw-material",
    order = "a[bi]-a-c[charcoal]",
    stack_size = 400,
    weight = 10 * kg,
  },

  --- Coke Coal / Pellet Coke for Angels
  {
    type = "item",
    name = "pellet-coke",
	icons = { {icon = ICONPATH .. "coke-coal.png", icon_size = 64, }},
    fuel_value = "28MJ",
    fuel_category = "chemical",
    fuel_acceleration_multiplier = 1.2,
    fuel_top_speed_multiplier = 1.1,
    subgroup = "raw-material",
    order = "a[bi]-a-g[bi-coke-coal]",
    stack_size = 400,
    weight = 25 * kg,
  },


  --- Crushed Stone
  {
    type = "item",
    name = "stone-crushed",
	icons = { {icon = ICONPATH .. "crushed-stone.png", icon_size = 64, }},
    pictures = {
      { size = 64, filename = ICONPATHMIPS.."crush_1.png", scale = 0.44, mipmap_count = 4 },
      { size = 64, filename = ICONPATHMIPS.."crush_2.png", scale = 0.45, mipmap_count = 4 },
      { size = 64, filename = ICONPATHMIPS.."crush_3.png", scale = 0.45, mipmap_count = 4 },
      { size = 64, filename = ICONPATHMIPS.."crush_4.png", scale = 0.46, mipmap_count = 4 }
    },
    subgroup = "raw-material",
    order = "a[bi]-a-z[stone-crushed]",
    stack_size = 400,
    weight = 20 * kg,
  },


  --- Seeb Bomb - Basic
  {
    type = "ammo",
    name = "bi-seed-bomb-basic",
	icons = { {icon = ICONPATH_W .. "seed_bomb_icon_b.png", icon_size = 64, }},
    ammo_category = "rocket",
    ammo_type = {
    range_modifier = 3,
    cooldown_modifier = 3,
    target_type = "position",
    category = "rocket",
    action = {
        type = "direct",
        action_delivery = {
          type = "projectile",
          projectile = "seed-bomb-projectile-1",
          starting_speed = 0.05,
        }
      }
    },
    subgroup = "ammo",
    order = "a[rocket-launcher]-x[seed-bomb]-a",
    stack_size = 10,
    weight = 50 * kg,
  },


  --- Seeb Bomb - Standard
  {
    type = "ammo",
    name = "bi-seed-bomb-standard",
	icons = { {icon = ICONPATH_W .. "seed_bomb_icon_s.png", icon_size = 64, }},
    ammo_category = "rocket",
    ammo_type = {
    range_modifier = 4,
    cooldown_modifier = 3,
    target_type = "position",
    category = "rocket",
    action = {
        type = "direct",
        action_delivery = {
          type = "projectile",
          projectile = "seed-bomb-projectile-2",
          starting_speed = 0.05,
        }
      }
    },
    subgroup = "ammo",
    order = "a[rocket-launcher]-x[seed-bomb]-b",
    stack_size = 10,
    weight = 50 * kg,
  },


  --- Seeb Bomb - Advanced
  {
    type = "ammo",
    name = "bi-seed-bomb-advanced",
	icons = { {icon = ICONPATH_W .. "seed_bomb_icon_a.png", icon_size = 64, }},
    ammo_category = "rocket",
    ammo_type = {
    range_modifier = 5,
    cooldown_modifier = 3,
    target_type = "position",
    category = "rocket",
    action = {
        type = "direct",
        action_delivery = {
          type = "projectile",
          projectile = "seed-bomb-projectile-3",
          starting_speed = 0.05,
        }
      }
    },
    subgroup = "ammo",
    order = "a[rocket-launcher]-x[seed-bomb]-c",
    stack_size = 10,
    weight = 50 * kg,
  },

   --- Arboretum (Entity)
  {
    type= "item",
    name= "bi-arboretum-area",
	icons = { {icon = ICONPATH_E .. "arboretum_Icon.png", icon_size = 64, }},
    subgroup = "production-machine",
    order = "x[bi]-a[bi-arboretum]",
    place_result = "bi-arboretum-area",
    stack_size= 10,
    weight = 500 * kg,
  },

   --- Arboretum Hidden Recipe
  {
    type = "item",
    name = "bi-arboretum-r1",
	icons = { {icon = ICONPATH .. "Seedling_b.png", icon_size = 64, }},
    hidden = true,
    subgroup = "terrain",
    order = "bi-arboretum-r1",
    stack_size = 1
  },

  --- Arboretum Hidden Recipe
  {
    type = "item",
    name = "bi-arboretum-r2",
	icons = { {icon = ICONPATH .. "bi_change_1.png", icon_size = 64, }},
    hidden = true,
    subgroup = "terrain",
    order = "bi-arboretum-r2",
    stack_size = 1
  },

   --- Arboretum Hidden Recipe
  {
    type = "item",
    name = "bi-arboretum-r3",
	icons = { {icon = ICONPATH .. "bi_change_2.png", icon_size = 64, }},
    hidden = true,
    subgroup = "terrain",
    order = "bi-arboretum-r3",
    stack_size = 1
  },

  --- Arboretum Hidden Recipe
  {
    type = "item",
    name = "bi-arboretum-r4",
	icons = { {icon = ICONPATH .. "bi_change_plant_1.png", icon_size = 64, }},
    hidden = true,
    subgroup = "terrain",
    order = "bi-arboretum-r4",
    stack_size = 1
  },

  --- Arboretum Hidden Recipe
  {
    type = "item",
    name = "bi-arboretum-r5",
	icons = { {icon = ICONPATH .. "bi_change_plant_2.png", icon_size = 64, }},
    hidden = true,
    subgroup = "terrain",
    order = "bi-arboretum-r5",
    stack_size = 1
  },

})

--- Fertilizer can change terrain to better terrain
  data:extend({
    --- fertilizer
    {
      type = "item",
      name = "fertilizer",
	  icons = { {icon = ICONPATH .. "fertilizer.png", icon_size = 64, }},
      subgroup = "intermediate-product",
      order = "b[fertilizer]",
      stack_size = 200,
      weight = 40 * kg,
    },

    --- Adv fertilizer
    {
      type = "item",
      name = "bi-adv-fertilizer",
	  icons = { {icon = ICONPATH .. "fertilizer_advanced.png", icon_size = 64, }},
      subgroup = "intermediate-product",
      order = "b[fertilizer]-b[bi-adv-fertilizer]",
      stack_size = 200,
      weight = 40 * kg,
    },
  })

