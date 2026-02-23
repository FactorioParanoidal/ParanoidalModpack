data:extend{
  -- Pickup Tower
  {
    type = "int-setting",
    name = "Schall-PT-tier-max",
    order = "pt-t",
    setting_type = "startup",
    allowed_values = { 1, 2, 3, 4 },
    default_value = 2
  },
  {
    type = "bool-setting",
    name = "Schall-PT-range-force-disable",
    order = "pt-b-a",
    setting_type = "runtime-global",
    default_value = false
  },
  {
    type = "bool-setting",
    name = "Schall-PT-range-show",
    order = "pt-b-b",
    setting_type = "runtime-per-user",
    default_value = true
  },
  {
    type = "color-setting",
    name = "Schall-PT-range-colour",
    order = "pt-b-c",
    setting_type = "startup",
    default_value = {r=0.5, g=0.2, b=0.2, a=1}
  },
}
