if BI.Settings.BI_Solar_Additions then
data:extend({
--###############################################################################################
-- Solar Farm
{
      type = "recipe",
      name = "bi-bio-solar-farm",
      localised_name = {"entity-name.bi-bio-solar-farm"},
      localised_description = {"entity-description.bi-bio-solar-farm"},
      enabled = false,
      energy_required = 60,
      ingredients = 
      {
        {"solar-panel", 50},
        {"medium-electric-pole", 25},
        {"concrete", 400},
      },
      result = "bi-bio-solar-farm",
      subgroup = "bob-energy-solar-panel",
      order = "a",
      allow_as_intermediate = false,  
      always_show_made_in = false,
      allow_decomposition = true,
},
--###############################################################################################
-- solar boiler
{
      type = "recipe",
      name = "bi-solar-boiler-hidden-panel",
      localised_name = {"entity-name.bi-solar-boiler"},
      localised_description = {"entity-description.bi-solar-boiler"},
      enabled = false,
      energy_required = 15,
      ingredients = 
      {
        {"solar-panel", 30},
        {"storage-tank", 4},
        {"boiler", 1},
      },
      result = "bi-solar-boiler",
      subgroup = "energy",
      order = "b[steam-power]-c[steam-engine]",
      allow_as_intermediate = false,
      always_show_made_in = false,
      allow_decomposition = true,
},
--###############################################################################################
-- BI Accumulator
    {
      type = "recipe",
      name = "bi-bio-accumulator",
      localised_name = {"entity-name.bi-bio-accumulator"},
      localised_description = {"entity-description.bi-bio-accumulator"},
      energy_required = 60,
      enabled = false,
      ingredients = 
      {
        {"accumulator", 50},
        {"copper-cable", 50},
        {"concrete", 200},
      },
      result = "bi-bio-accumulator",
      subgroup = "bob-energy-accumulator",
      order = "a",
      allow_as_intermediate = false,
      always_show_made_in = false,
      allow_decomposition = true, 
    },
--###############################################################################################
-- Large Substation
{
      type = "recipe",
      name = "bi-large-substation",
      localised_name = {"entity-name.bi-large-substation"},
      localised_description = {"entity-description.bi-large-substation"},
      enabled = false,
      ingredients = 
      {
        {"steel-plate", 10},
        {"concrete", 200},
		    {"copper-plate", 800}, --DrD
        {"substation", 4}
      },
      result = "bi-large-substation",
      subgroup = "substation",
      order = "z",
      allow_as_intermediate = false,
      always_show_made_in = false,
      allow_decomposition = true,
}

})
end