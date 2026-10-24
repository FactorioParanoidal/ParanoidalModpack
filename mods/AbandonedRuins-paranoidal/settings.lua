data:extend({
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
    -- How dangerous the legendary ruins are; independent of the core's "hostile ruin defences".
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
