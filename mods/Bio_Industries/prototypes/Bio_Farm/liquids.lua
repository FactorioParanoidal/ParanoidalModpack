data:extend({
-- Bio-Mass
  {
    type = "fluid",
    name = "bi-biomass",
    icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/fluid_biomass.png",
    icon_size = 64, icon_mipmaps = 4,
    default_temperature = 25,
    max_temperature = 100,
    heat_capacity = "1KJ",
    base_color = util.color("3a9844"),
    flow_color = util.color("3a9844"),
    pressure_to_speed_ratio = 0.4,
    flow_to_energy_ratio = 0.59,
    order = "a[fluid]-b[biomass]"
  },
})