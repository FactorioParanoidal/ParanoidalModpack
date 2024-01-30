data:extend({
-- BioReactor
  {
    type = "item",
    name = "bi-bio-reactor",
    icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/entity/bioreactor.png",
    icon_size = 64,  icon_mipmaps = 4,
    subgroup = "bio-bio-fuel-fluid",
    order = "a",
    place_result = "bi-bio-reactor",
    stack_size = 10
  },
})
--###############################################################################################
if BI.Settings.BI_Bio_Fuel then
  data:extend({
-- Cellulose
    {
      type = "item",
      name = "bi-cellulose",
      icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/cellulose.png",
      icon_size = 64,  icon_mipmaps = 4,
      subgroup = "bio-bio-fuel-other",
      order = "b[cellulose]",
      stack_size = 200
    },
--###############################################################################################
-- Bio Boiler
    {
      type = "item",
      name = "bi-bio-boiler",
      icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/entity/bio_boiler.png",
      icon_size = 64,  icon_mipmaps = 4,
      subgroup = "bob-energy-boiler",
      order = "a",
      place_result = "bi-bio-boiler",
      stack_size = 50
    },
  })
end