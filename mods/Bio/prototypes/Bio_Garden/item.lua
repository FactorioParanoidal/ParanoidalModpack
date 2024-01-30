data:extend({
  -- костыль для очистки воздуха
  {
    type = "item",
    name = "bi-purified-air",
    icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/clean-air.png",
    icon_size = 128, icon_mipmaps = 4,
    flags = {"hidden"},
    subgroup = "bio-bio-gardens-fluid",
    order = "bi-purified-air",
    stack_size = 100
  },
--###############################################################################################
-- Bio Garden
{
    type = "item",
    name = "bi-bio-garden",
    icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/entity/garden_3x3.png",
    icon_size = 64, icon_mipmaps = 4,
    subgroup = "bio-bio-gardens-fluid",
    order = "x[bi]-b[bi-bio-garden1]",
    place_result = "bi-bio-garden",
    stack_size = 10
},
--###############################################################################################
-- Large bio garden
{
  type = "item",
  name = "bi-bio-garden-large",
  icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/entity/garden_9x9.png",
  icon_size = 64, icon_mipmaps = 4,
  subgroup = "bio-bio-gardens-fluid",
  order = "x[bi]-b[bi-bio-garden2]",
  place_result = "bi-bio-garden-large",
  stack_size = 10
},
--###############################################################################################
-- Huge bio garden
{
  type = "item",
  name = "bi-bio-garden-huge",
  icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/entity/garden_27x27.png",
  icon_size = 64, icon_mipmaps = 4,
  subgroup = "bio-bio-gardens-fluid",
  order = "x[bi]-b[bi-bio-garden3]",
  place_result = "bi-bio-garden-huge",
  stack_size = 10
}

})