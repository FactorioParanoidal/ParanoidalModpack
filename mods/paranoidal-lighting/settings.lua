-- Setting names are kept from the merged mods so the values in mod-settings.dat stay.
data:extend({
  {
    -- BIG LIGHT: status light of electric mining drills
    type = "int-setting",
    name = "ritnmods-bl-01",
    setting_type = "startup",
    default_value = 3,
    minimum_value = 1,
    maximum_value = 5,
    order = "a"
  },
  {
    -- BIG LIGHT: green instead of yellow train stop lights
    type = "bool-setting",
    name = "ritnmods-bl-02",
    setting_type = "startup",
    default_value = false,
    order = "b"
  },
  {
    -- BIG LIGHT: glow of train stop lights
    type = "int-setting",
    name = "ritnmods-bl-03",
    setting_type = "startup",
    default_value = 4,
    minimum_value = 0,
    maximum_value = 5,
    order = "c"
  },
  {
    -- BIG LIGHT: glow of power switch lights
    type = "int-setting",
    name = "ritnmods-bl-04",
    setting_type = "startup",
    default_value = 3,
    minimum_value = 0,
    maximum_value = 5,
    order = "d"
  },
  {
    -- Lighted poles: light radius factor on top of the wire reach scaling
    type = "double-setting",
    name = "lepp_light_size_factor",
    setting_type = "startup",
    default_value = 1,
    minimum_value = 0,
    maximum_value = 100,
    order = "e"
  },
  {
    -- Inlaid lamps: size of the white light (the 2x2 lamp gets twice as much)
    type = "int-setting",
    name = "inlaid-lamps-extended-light_size",
    setting_type = "startup",
    default_value = 40,
    minimum_value = 1,
    maximum_value = 100,
    order = "f"
  },
})
