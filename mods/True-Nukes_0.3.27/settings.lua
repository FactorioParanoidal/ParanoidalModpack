data:extend({
  {
    type = "bool-setting",
    name = "nuke-random-fires",
    setting_type = "runtime-global",
    default_value = true,
    order = "a1"
  },
  {
    type = "bool-setting",
    name = "nuke-crater-noise",
    setting_type = "runtime-global",
    default_value = true,
    order = "a2"
  },
  {
    type = "bool-setting",
    name = "destroy-resources-in-crater",
    setting_type = "runtime-global",
    default_value = true,
    order = "a4"
  },
  {
    type = "bool-setting",
    name = "nukes-cause-pollution",
    setting_type = "runtime-global",
    default_value = true,
    order = "a5"
  },
  {
    type = "bool-setting",
    name = "retain-death-statistics",
    setting_type = "runtime-global",
    default_value = false,
    order = "a6"
  },
  {
    type = "bool-setting",
    name = "retain-death-statistics-small",
    setting_type = "runtime-global",
    default_value = true,
    order = "a7"
  },
  { 
    type = "bool-setting",
    name = "retain-death-statistics-for-trees",
    setting_type = "runtime-global",
    default_value = false,
    order = "a8"
  },
  { 
    type = "bool-setting",
    name = "retain-death-statistics-for-trees-small",
    setting_type = "runtime-global",
    default_value = true,
    order = "a9"
  },
  {
    type = "double-setting",
    name = "large-nuke-fire-scaledown",
    setting_type = "runtime-global",
    minimum_value = 1,
    maximum_value = 50,
    default_value = 1,
    order = "b0"
  },
  {
    type = "double-setting",
    name = "huge-nuke-fire-scaledown",
    setting_type = "runtime-global",
    minimum_value = 1,
    maximum_value = 100,
    default_value = 2,
    order = "b1"
  },
  {
    type = "double-setting",
    name = "really-huge-nuke-fire-scaledown",
    setting_type = "runtime-global",
    minimum_value = 1,
    maximum_value = 200,
    default_value = 5,
    order = "b2"
  },
  {
    type = "double-setting",
    name = "general-nuke-range-scaledown",
    setting_type = "runtime-global",
    minimum_value = 0.5,
    maximum_value = 40,
    default_value = 1,
    order = "c+"
  },
  {
    type = "double-setting",
    name = "large-nuke-range-scaledown",
    setting_type = "runtime-global",
    minimum_value = 1,
    maximum_value = 40,
    default_value = 1.5,
    order = "c0"
  },
  {
    type = "double-setting",
    name = "huge-nuke-range-scaledown",
    setting_type = "runtime-global",
    minimum_value = 1,
    maximum_value = 4,
    default_value = 1.5,
    order = "c1"
  },
  {
    type = "double-setting",
    name = "really-huge-nuke-range-scaledown",
    setting_type = "runtime-global",
    minimum_value = 1,
    maximum_value = 40,
    default_value = 1.5,
    order = "c2"
  },
  {
    type = "bool-setting",
    name = "optimise-100kt",
    setting_type = "runtime-global",
    default_value = true,
    order = "c4"
  },
  {
    type = "bool-setting",
    name = "actually-generate-crater",
    setting_type = "runtime-global",
    default_value = true,
    order = "c5"
  },
  
  
  {
    type = "string-setting",
    name = "small-boom-material",
    setting_type = "startup",
    default_value = "mod-dependant",
    allowed_values = {"same-as-boom","true-nukes-default", "mod-dependant", "custom"},
    order = "b0"
  },
  {
    type = "string-setting",
    name = "small-boom-material-name",
    setting_type = "startup",
    default_value = "californium",
    order = "b1"
  },
  {
    type = "string-setting",
    name = "boom-material",
    setting_type = "startup",
    default_value = "mod-dependant",
    allowed_values = { "true-nukes-default", "mod-dependant", "custom"},
    order = "b2"
  },
  {
    type = "string-setting",
    name = "boom-material-name",
    setting_type = "startup",
    default_value = "uranium-235",
    order = "b3"
  },
  {
    type = "string-setting",
    name = "dead-material",
    setting_type = "startup",
    default_value = "mod-dependant",
    allowed_values = { "default", "mod-dependant", "custom"},
    order = "b4"
  },
  {
    type = "string-setting",
    name = "dead-material-name",
    setting_type = "startup",
    default_value = "uranium-238",
    order = "b5"
  },
  {
    type = "string-setting",
    name = "computer-material",
    setting_type = "startup",
    default_value = "mod-dependant",
    allowed_values = {"true-nukes-default", "mod-dependant", "custom"},
    order = "b6"
  },
  {
    type = "string-setting",
    name = "computer-material-name",
    setting_type = "startup",
    default_value = "processing-unit",
    order = "b7"
  },
  {
    type = "string-setting",
    name = "light-material",
    setting_type = "startup",
    default_value = "mod-dependant",
    allowed_values = {"true-nukes-default", "mod-dependant", "custom"},
    order = "b8"
  },
  {
    type = "string-setting",
    name = "light-material-name",
    setting_type = "startup",
    default_value = "low-density-structure",
    order = "b9"
  },

  {
    type = "bool-setting",
    name = "enable-menu-backgrounds",
    setting_type = "startup",
    default_value = true,
    order = "e0"
  },

  {
    type = "bool-setting",
    name = "enable-small-thermobarics",
    setting_type = "startup",
    default_value = true,
    order = "f0"
  },
  {
    type = "bool-setting",
    name = "enable-medium-thermobarics",
    setting_type = "startup",
    default_value = true,
    order = "f1"
  },
  {
    type = "bool-setting",
    name = "enable-large-thermobarics",
    setting_type = "startup",
    default_value = true,
    order = "f2"
  },

  {
    type = "bool-setting",
    name = "enable-small-atomics",
    setting_type = "startup",
    default_value = true,
    order = "f3"
  },
  {
    type = "bool-setting",
    name = "enable-compact-small-atomics",
    setting_type = "startup",
    default_value = true,
    order = "f4"
  },

  {
    type = "bool-setting",
    name = "enable-medium-atomics",
    setting_type = "startup",
    default_value = true,
    order = "f5"
  },
  {
    type = "bool-setting",
    name = "enable-compact-medium-atomics",
    setting_type = "startup",
    default_value = true,
    order = "f6"
  },

  {
    type = "bool-setting",
    name = "enable-large-atomics",
    setting_type = "startup",
    default_value = true,
    order = "f7"
  },

  {
    type = "bool-setting",
    name = "enable-compact-large-atomics",
    setting_type = "startup",
    default_value = true,
    order = "f8"
  },
  {
    type = "bool-setting",
    name = "enable-15kt",
    setting_type = "startup",
    default_value = true,
    order = "f9"
  },
  {
    type = "bool-setting",
    name = "enable-compact-15kt",
    setting_type = "startup",
    default_value = true,
    order = "fa"
  },
  {
    type = "bool-setting",
    name = "enable-fusion",
    setting_type = "startup",
    default_value = true,
    order = "fc"
  },

  {
    type = "bool-setting",
    name = "enable-compact-fusion",
    setting_type = "startup",
    default_value = true,
    order = "fd"
  },
  {
    type = "bool-setting",
    name = "enable-big-fusion-weapons",
    setting_type = "startup",
    default_value = true,
    order = "fh"
  },
  {
    type = "bool-setting",
    name = "enable-nuclear-tests",
    setting_type = "startup",
    default_value = true,
    order = "fg"
  },
  {
    type = "bool-setting",
    name = "enable-fusion-building",
    setting_type = "startup",
    default_value = true,
    order = "fk"
  },

  {
    type = "bool-setting",
    name = "enable-fire-shield",
    setting_type = "startup",
    default_value = true,
    order = "fm"
  },

  {
    type = "bool-setting",
    name = "keep-atomic-bomb-without-changes",
    setting_type = "startup",
    default_value = false,
    order = "fo"
  },

  {
    type = "bool-setting",
    name = "TN-mushroom-cloud-style-nuclear-flash",
    setting_type = "runtime-per-user",
    default_value = true,
    order = "a0",
  }
})
