-- settings.lua (Factorio 2.0)
data:extend({
  {
    type = "int-setting",
    name = "zcs_trash_period_seconds",
    setting_type = "runtime-global",
    default_value = 60,     -- 1 minuto
    minimum_value = 1,
    maximum_value = 3600,
    order = "a"
  },
  {
    type = "double-setting",
    name = "zcs_trash_pollution_per_item",
    setting_type = "runtime-global",
    default_value = 0.02,   -- polución base por ítem
    minimum_value = 0,
    maximum_value = 100,
    order = "b"
  },
  {
    type = "double-setting",
    name = "zcs_trash_pollution_exponent",
    setting_type = "runtime-global",
    default_value = 1.35,   -- >1 => crece más con stacks grandes
    minimum_value = 1.0,
    maximum_value = 3.0,
    order = "c"
  },
  {
    type = "double-setting",
    name = "zcs_trash_pollution_cap",
    setting_type = "runtime-global",
    default_value = 100.0,  -- tope por slot (0 = sin tope)
    minimum_value = 0.0,
    maximum_value = 1000000.0,
    order = "d"
  }
})
