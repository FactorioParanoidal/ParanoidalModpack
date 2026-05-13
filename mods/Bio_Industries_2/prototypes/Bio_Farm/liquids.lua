local BioInd = require('common')('Bio_Industries_2')

local ICONPATH = BioInd.modRoot .. "/graphics/icons/"

data:extend({
  ----- Bio-Mass
  {
    type = "fluid",
    name = "bi-biomass",
    icon = ICONPATH .. "biomass.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "biomass.png",
        icon_size = 64,
      }
    },
    default_temperature = 25,
    max_temperature = 100,
    heat_capacity = "1kJ",
    base_color = {r = 0, g = 0, b = 0},
    flow_color = {r = 0.1, g = 1.0, b = 0.0},
    pressure_to_speed_ratio = 0.4,
    flow_to_energy_ratio = 0.59,
    subgroup = "bio-bio-fuel-fluid",
    order = "a[fluid]-b[biomass]"
  },
})
