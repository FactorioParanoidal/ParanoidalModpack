local BioInd = require('common')('Bio_Industries')

local ICONPATH = BioInd.modRoot .. "/graphics/icons/"

data:extend({
  {
    type = "fluid",
    name = "bi-Bio_Fuel",
    icon = ICONPATH .. "bio-fuel.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "bio_boiler.png",
        icon_size = 64,
      }
    },
    default_temperature = 25,
    max_temperature = 100,
    heat_capacity = "1KJ",
    base_color = {r = 1.00, g = 0.35, b = 0.35},
    flow_color = {r = 1.00, g = 0.35, b = 0.35},
    pressure_to_speed_ratio = 0.4,
    flow_to_energy_ratio = 0.59,
  },


})
