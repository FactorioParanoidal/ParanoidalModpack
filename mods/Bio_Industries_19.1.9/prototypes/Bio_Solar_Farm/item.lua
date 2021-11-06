if BI.Settings.BI_Solar_Additions then
data:extend({
--###############################################################################################
-- Solar Farm
{
      type = "item",
      name = "bi-bio-solar-farm",
      localised_name = {"entity-name.bi-bio-solar-farm"},
      localised_description = {"entity-description.bi-bio-solar-farm"},
      icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/entity/solar-panel-large.png",
      icon_size = 64, icon_mipmaps = 4,
      subgroup = "bob-energy-solar-panel",
      order = "a",
      place_result = "bi-bio-solar-farm",
      stack_size = 10,
},
--###############################################################################################
-- BI Accumulator
    {
      type = "item",
      name = "bi-bio-accumulator",
      localised_name = {"entity-name.bi-bio-accumulator"},
      localised_description = {"entity-description.bi-bio-accumulator"},
      icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/entity/accumulator_large.png",
      icon_size = 64, icon_mipmaps = 4,
      subgroup = "bob-energy-accumulator",
      order = "a",
      place_result = "bi-bio-accumulator",
      stack_size = 5
    },
--###############################################################################################
-- Large Substation
    {
      type = "item",
      name = "bi-large-substation",
      localised_name = {"entity-name.bi-large-substation"},
      localised_description = {"entity-description.bi-large-substation"},
      icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/entity/substation_large.png",
      icon_size = 64, icon_mipmaps = 4,
      subgroup = "substation",
      order = "z",
      place_result = "bi-large-substation",
      stack_size = 10
    },
--###############################################################################################
-- Solar Boiler - Boiler
{
      type = "item",
      name = "bi-solar-boiler",
      localised_name = {"entity-name.bi-solar-boiler"},
      localised_description = {"entity-description.bi-solar-boiler"},
      icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/entity/solar-boiler.png",
      icon_size = 64, icon_mipmaps = 4,
      subgroup = "energy",
      order = "b[steam-power]-c[steam-engine]",
      place_result = "bi-solar-boiler",
      stack_size = 20,
},

})
end