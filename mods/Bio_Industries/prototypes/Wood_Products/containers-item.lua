data:extend({
-- Large wooden chest 2 x 2
  {
    type = "item",
    name = "bi-wooden-chest-large",
    localised_name = {"entity-name.bi-wooden-chest-large"},
    localised_description = {"entity-description.bi-wooden-chest-large"},
    icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/entity/wood_chest_large.png",
    icon_size = 64, icon_mipmaps = 4,
    --fuel_category = "chemical",
    --fuel_value = "32MJ",
    subgroup = "storage",
    order = "a[items]-aa[wooden-chest]",
    place_result = "bi-wooden-chest-large",
    stack_size = 48
  },
--###############################################################################################
-- Huge wooden chest 3 x 3
  {
    type = "item",
    name = "bi-wooden-chest-huge",
    localised_name = {"entity-name.bi-wooden-chest-huge"},
    localised_description = {"entity-description.bi-wooden-chest-huge"},
    icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/entity/wood_chest_huge.png",
    icon_size = 64, icon_mipmaps = 4,
    --fuel_category = "chemical",
    --fuel_value = "200MJ",
    subgroup = "storage",
    order = "a[items]-ab[wooden-chest]",
    place_result = "bi-wooden-chest-huge",
    stack_size = 32
  },
--###############################################################################################
-- Giga wooden chest 6 x 6
  {
    type = "item",
    name = "bi-wooden-chest-giga",
    localised_name = {"entity-name.bi-wooden-chest-giga"},
    localised_description = {"entity-description.bi-wooden-chest-giga"},
    icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/entity/wood_chest_giga.png",
    icon_size = 64, icon_mipmaps = 4,
    --fuel_category = "chemical",
    --fuel_value = "400MJ",
    subgroup = "storage",
    order = "a[items]-ac[wooden-chest]",
    place_result = "bi-wooden-chest-giga",
    stack_size = 16
  },
})