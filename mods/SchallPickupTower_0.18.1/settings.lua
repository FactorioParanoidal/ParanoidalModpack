data:extend{
  -- Pickup Tower
  {
    type = "int-setting",
    name = "Schall-pickup-tower-tier-max",
    order = "pt-t",
    setting_type = "startup",
    default_value = 2,
    allowed_values = { 1, 2, 3, 4 }
  },
  {
    type = "bool-setting",
    name = "Schall-pickup-tower-range-force-disable",
    order = "pt-b-a",
    setting_type = "runtime-global",
    default_value = false
  },
  {
    type = "bool-setting",
    name = "Schall-pickup-tower-range-show",
    order = "pt-b-b",
    setting_type = "runtime-per-user",
    default_value = true
  },
}
