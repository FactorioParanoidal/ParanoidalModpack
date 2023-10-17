data:extend({
  {
    type = "bool-setting",
    name = "fmf-enable-duct-auto-join",
    order = "aa",
    setting_type = "startup",
    default_value = true,
  },
  {
    type = "int-setting",
    name = "fmf-underground-duct-max-length",
    order = "ab",
    setting_type = "startup",
    minimum_value = 10,
    maximum_value = 100,
    default_value = 30,
  },
})
