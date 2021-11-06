data:extend({
-- Big Wooden Electric Pole
  {
    type = "item",
    name = "bi-wooden-pole-big",
    localised_name = {"entity-name.bi-wooden-pole-big"},
    localised_description = {"entity-description.bi-wooden-pole-big"},
    icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/entity/wood_pole_big.png",
    icon_size = 64, icon_mipmaps = 3,
    subgroup = "energy-pipe-distribution",
    order = "a[energy]-b[small-electric-pole]",
    place_result = "bi-wooden-pole-big",
    fuel_value = "14MJ",
    fuel_category = "chemical",
    stack_size = 50
  },
--###############################################################################################
-- Huge Wooden Pole
  {
    type = "item",
    name = "bi-wooden-pole-huge",
    localised_name = {"entity-name.bi-wooden-pole-huge"},
    localised_description = {"entity-description.bi-wooden-pole-huge"},
    icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/entity/wood_pole_huge.png",
    icon_size = 64, icon_mipmaps = 3,
    subgroup = "energy-pipe-distribution",
    order = "a[energy]-d[big-electric-pole]",
    place_result = "bi-wooden-pole-huge",
    fuel_value = "90MJ",
    fuel_category = "chemical",
    stack_size = 50
  },
--###############################################################################################
-- Wooden Fence
  {
    type = "item",
    name = "bi-wooden-fence",
    localised_name = {"entity-name.bi-wooden-fence"},
    localised_description = {"entity-description.bi-wooden-fence"},
    icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/entity/wooden-fence.png",
    icon_size = 64, icon_mipmaps = 4,
    subgroup = "defensive-structure",
    order = "a-a[stone-wall]-a[wooden-fence]",
    place_result = "bi-wooden-fence",
    fuel_value = "4MJ",
    fuel_category = "chemical",
    stack_size = 50
  },
--###############################################################################################
-- Wood Pipe
  {
    type = "item",
    name = "bi-wood-pipe",
    localised_name = {"entity-name.bi-wood-pipe"},
    localised_description = {"entity-description.bi-wood-pipe"},
    icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/entity/wood_pipe.png",
    icon_size = 64, icon_mipmaps = 4,
    subgroup = "energy-pipe-distribution",
    order = "a[pipe]-1a[pipe]",
    place_result = "bi-wood-pipe",
    fuel_value = "4MJ",
    fuel_category = "chemical",
    stack_size = 100
  },
--###############################################################################################
--- Wood Pipe to Ground
  {
    type = "item",
    name = "bi-wood-pipe-to-ground",
    localised_name = {"entity-name.bi-wood-pipe-to-ground"},
    localised_description = {"entity-description.bi-wood-pipe-to-ground"},
    icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/entity/wood_pipe_to_ground.png",
    icon_size = 64, icon_mipmaps = 4,
    subgroup = "energy-pipe-distribution",
    order = "a[pipe]-1b[pipe-to-ground]",
    place_result = "bi-wood-pipe-to-ground",
    fuel_value = "20MJ",
    fuel_category = "chemical",
    stack_size = 50
  },
})