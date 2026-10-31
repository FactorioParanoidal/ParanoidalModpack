-- Names of the former "Abandoned Ruins - Updated" settings are kept (values of existing settings
-- stay). Defaults are the Paranoidal ones that zzzparanoidal used to set.
data:extend({
  {
    type = "bool-setting",
    name = "ruins-enemy-not-cease-fire",
    setting_type = "runtime-global",
    default_value = true,
    order = "ab"
  }, {
    type = "bool-setting",
    name = "ruins-avoid-repeats",
    setting_type = "runtime-global",
    default_value = true,
    order = "bc"
  }, {
    -- "paranoidal" holds every ruin (its own and, with pd-ruins-include-base, the "base" set)
    type = "string-setting",
    name = "current-ruin-set",
    setting_type = "runtime-global",
    allowed_values = { "__none__", "paranoidal" },
    default_value = "paranoidal",
    order = "c"
  }, {
    type = "int-setting",
    name = "ruins-min-distance-from-spawn",
    setting_type = "runtime-global",
    default_value = 400,
    minimum_value = 50,
    maximum_value = 1000000,
    order = "ca"
  }, {
    type = "bool-setting",
    name = "ruins-ignore-distance",
    setting_type = "runtime-global",
    default_value = true,
    order = "caa"
  }, {
    -- ticks, the name says "seconds" for historical reasons
    type = "int-setting",
    name = "ruins-spawn-tick-seconds",
    setting_type = "runtime-global",
    default_value = 10,
    minimum_value = 1,
    maximum_value = 20,
    order = "cb"
  }, {
    type = "double-setting",
    name = "ruins-small-ruin-chance",
    setting_type = "runtime-global",
    default_value = 0.01875,
    minimum_value = 0.0,
    maximum_value = 1.0,
    order = "d"
  }, {
    type = "double-setting",
    name = "ruins-medium-ruin-chance",
    setting_type = "runtime-global",
    default_value = 0.0075,
    minimum_value = 0.0,
    maximum_value = 1.0,
    order = "da"
  }, {
    type = "double-setting",
    name = "ruins-large-ruin-chance",
    setting_type = "runtime-global",
    default_value = 0.001875,
    minimum_value = 0.0,
    maximum_value = 1.0,
    order = "db"
  },
  -- Paranoidal ruin set and journal
  {
    type = "bool-setting",
    name = "pd-ruins-include-base",
    setting_type = "runtime-global",
    default_value = true,
    order = "pd-a"
  }, {
    type = "bool-setting",
    name = "pd-ruins-discovery-messages",
    setting_type = "runtime-global",
    default_value = true,
    order = "pd-b"
  }, {
    type = "bool-setting",
    name = "pd-ruins-map-tags",
    setting_type = "runtime-global",
    default_value = true,
    order = "pd-c"
  },
  -- Legendary ruins
  {
    type = "bool-setting",
    name = "pd-legendary-ruins",
    setting_type = "runtime-global",
    default_value = true,
    order = "pd-l-a"
  }, {
    -- How dangerous the legendary ruins are; independent of "hostile ruin defences".
    type = "string-setting",
    name = "pd-legendary-ferocity",
    setting_type = "runtime-global",
    default_value = "legendary",
    allowed_values = { "legendary", "harsh", "truce" },
    order = "pd-l-b"
  }, {
    type = "double-setting",
    name = "pd-legendary-chance",
    setting_type = "runtime-global",
    default_value = 0.001,
    minimum_value = 0,
    maximum_value = 0.1,
    order = "pd-l-c"
  }, {
    type = "int-setting",
    name = "pd-legendary-distance-chunks",
    setting_type = "runtime-global",
    default_value = 100,
    minimum_value = 0,
    maximum_value = 5000,
    order = "pd-l-d"
  }, {
    type = "int-setting",
    name = "pd-legendary-spacing-chunks",
    setting_type = "runtime-global",
    default_value = 32,
    minimum_value = 24,
    maximum_value = 1000,
    order = "pd-l-e"
  }, {
    type = "bool-setting",
    name = "pd-legendary-repeat",
    setting_type = "runtime-global",
    default_value = false,
    order = "pd-l-f"
  },
})
