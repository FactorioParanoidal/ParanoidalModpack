data:extend({
--###############################################################################################
-- Seed
  {
    type = "item",
    name = "bi-seed",
    icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/tree_seed.png",
    icon_size = 64,  icon_mipmaps = 4,
    pictures = 
    {
      {size = 64, filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/mips/bio_seed_1.png", scale = 0.25, mipmap_count = 4},
      {size = 64, filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/mips/bio_seed_2.png", scale = 0.25, mipmap_count = 4},
      {size = 64, filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/mips/bio_seed_3.png", scale = 0.25, mipmap_count = 4},
      {size = 64, filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/mips/bio_seed_4.png", scale = 0.25, mipmap_count = 4},
    },
    category = "biofarm-mod-greenhouse",
    subgroup = "bio-bio-farm-fluid-1",
    order = "a",
    stack_size= 800
  },
--###############################################################################################
-- Seedling
  {
    type = "item",
    name = "seedling",
    icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/seedling.png",
    icon_size = 64,  icon_mipmaps = 4,
    pictures = 
    {
      {size = 64, filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/mips/seedling_1.png", scale = 0.25, mipmap_count = 4},
      {size = 64, filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/mips/seedling_2.png", scale = 0.25, mipmap_count = 4},
      {size = 64, filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/mips/seedling_3.png", scale = 0.25, mipmap_count = 4},
      {size = 64, filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/mips/seedling_4.png", scale = 0.25, mipmap_count = 4},
      {size = 64, filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/mips/seedling_5.png", scale = 0.25, mipmap_count = 4},
      {size = 64, filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/mips/seedling_6.png", scale = 0.25, mipmap_count = 4},
      {size = 64, filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/mips/seedling_7.png", scale = 0.25, mipmap_count = 4},
      {size = 64, filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/mips/seedling_8.png", scale = 0.25, mipmap_count = 4},
      {size = 64, filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/mips/seedling_9.png", scale = 0.25, mipmap_count = 4},
    },
    subgroup = "bio-bio-farm-fluid-2",
    order = "a",
    place_result = "seedling",
    stack_size= 400
  },
--###############################################################################################
--Bio Farm
  {
    type= "item",
    name= "bi-bio-farm",
    icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/entity/biofarm.png",
    icon_size = 64,  icon_mipmaps = 4,
    subgroup = "bio-bio-farm-fluid-entity",
    order = "b[bi]",
    place_result = "bi-bio-farm",
    stack_size= 10,
  },
--###############################################################################################
--Bio Greenhouse
  {
    type= "item",
    name= "bi-bio-greenhouse",
    icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/entity/greenhouse.png",
    icon_size = 64, icon_mipmaps = 4,
    subgroup = "bio-bio-farm-fluid-entity",
    order = "a[bi]",
    place_result = "bi-bio-greenhouse",
    stack_size= 10,
  },
--###############################################################################################
-- Cokery
  {
    type = "item",
    name = "bi-cokery",
    icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/entity/cokery.png",
    icon_size = 64, icon_mipmaps = 4,
    subgroup = "bio-bio-farm-raw-entity",
    order = "a[bi]",
    place_result = "bi-cokery",
    stack_size = 10
  },
--###############################################################################################
-- Stone Crusher
  {
    type = "item",
    name = "bi-stone-crusher",
    icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/entity/stone_crusher.png",
    icon_size = 64, icon_mipmaps = 4,
    subgroup = "bio-bio-farm-raw-entity",
    order = "b[bi]",
    place_result = "bi-stone-crusher",
    stack_size = 10
  },
--###############################################################################################
-- Wood Pulp
  {
    type = "item",
    name = "bi-woodpulp",
    icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/woodpulp.png",
    icon_size = 64, icon_mipmaps = 4,
    pictures = 
    {
      {size = 64, filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/mips/woodpulp_1.png", scale = 0.25, mipmap_count = 4},
      {size = 64, filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/mips/woodpulp_2.png", scale = 0.25, mipmap_count = 4},
      {size = 64, filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/mips/woodpulp_3.png", scale = 0.25, mipmap_count = 4},
      {size = 64, filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/mips/woodpulp_4.png", scale = 0.25, mipmap_count = 4},
    },
    fuel_value = "1MJ",
    fuel_category = "chemical",
    subgroup = "bio-bio-farm-raw",
    order = "a-b[bi-woodpulp]",
    stack_size = 800
  },
--###############################################################################################
-- Wood Bricks
  {
    type = "item",
    name = "wood-bricks",
    icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/Fuel_Brick.png",
    icon_size = 64, icon_mipmaps = 4,
    subgroup = "bio-bio-farm-raw",
    order = "a[bi]-a-bx[bi-woodbrick]",
    fuel_category = "chemical",
    fuel_value = "20MJ",
    stack_size = 200
  },
--###############################################################################################
-- Ash
  {
    type = "item",
    name = "bi-ash",
    icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/ash.png",
    icon_size = 64, icon_mipmaps = 4,
    pictures = 
    {
      {size = 64, filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/mips/ash_1.png", scale = 0.25, mipmap_count = 4},
      {size = 64, filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/mips/ash_2.png", scale = 0.25, mipmap_count = 4},
      {size = 64, filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/mips/ash_3.png", scale = 0.25, mipmap_count = 4},
      {size = 64, filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/mips/ash_4.png", scale = 0.25, mipmap_count = 4},
    },
    subgroup = "bio-bio-farm-raw",
    order = "a[bi]-a-b[bi-ash]",
    stack_size = 400
  },
--###############################################################################################
-- Charcoal
  {
    type = "item",
    name = "wood-charcoal",
    icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/charcoal.png",
    icon_size = 64, icon_mipmaps = 4,
    pictures = 
    {
      {size = 64, filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/mips/charcoal_1.png", scale = 0.25, mipmap_count = 4},
      {size = 64, filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/mips/charcoal_2.png", scale = 0.25, mipmap_count = 4},
      {size = 64, filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/mips/charcoal_3.png", scale = 0.25, mipmap_count = 4},
      {size = 64, filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/mips/charcoal_4.png", scale = 0.25, mipmap_count = 4},
    },
    fuel_value = "6MJ",
    fuel_category = "chemical",
    subgroup = "bio-bio-farm-raw",
    order = "a[bi]-a-c[charcoal]",
    stack_size = 400
  },
--###############################################################################################
-- Coke Coal / Pellet Coke for Angels
  {
    type = "item",
    name = "pellet-coke",
    icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/pellet_coke.png",
    icon_size = 64, icon_mipmaps = 4,
    fuel_value = "28MJ",
    fuel_category = "chemical",
    fuel_acceleration_multiplier = 1.2,
    fuel_top_speed_multiplier = 1.1,
    subgroup = "bio-bio-farm-raw",
    order = "a[bi]-a-g[bi-coke-coal]",
    stack_size = 400
  },
--###############################################################################################
-- Crushed Stone
  {
    type = "item",
    name = "stone-crushed",
    icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/crushed-stone.png",
    icon_size = 64, icon_mipmaps = 4,
    pictures = 
    {
      {size = 64, filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/mips/crush_1.png", scale = 0.25, mipmap_count = 4},
      {size = 64, filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/mips/crush_2.png", scale = 0.25, mipmap_count = 4},
      {size = 64, filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/mips/crush_3.png", scale = 0.25, mipmap_count = 4},
      {size = 64, filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/mips/crush_4.png", scale = 0.25, mipmap_count = 4},
    },
    subgroup = "bio-bio-farm-raw",
    order = "a[bi]-a-z[stone-crushed]",
    stack_size = 400
  },
--###############################################################################################
-- fertilizer
    {
      type = "item",
      name = "fertilizer",
      icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/fertilizer.png",
      icon_size = 64, icon_mipmaps = 4,
      subgroup = "bio-bio-farm-intermediate-product",
      order = "b[bi-fertilizer]",
      stack_size = 200,
    },
--###############################################################################################
-- Adv fertilizer
    {
      type = "item",
      name = "bi-adv-fertilizer",
      icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/fertilizer_advanced.png",
      icon_size = 64, icon_mipmaps = 4,
      subgroup = "bio-bio-farm-intermediate-product",
      order = "c[bi-fertilizer]",
      stack_size = 200,
    },
})