local mod_name = "__RITEG__"
data:extend({
  {
    type = "int-setting",
    name = mod_name .. "autodeconstruct-health-threshold",
    setting_type = "runtime-global",
  --default_value = 50, -- about 12.83 hours
    default_value = 25, -- about 25 hours
    minimum_value = 0,
    maximum_value = 90,
    order = "ab",
  }
})