-- Defaults are the values of the Paranoidal Beta 8 profile (SchallTankPlatoon 1.1.2 + zzzparanoidal).
-- Setting names are kept from Beta 8 so that profiles can be compared directly.

local force_conditions = {"all", "not-same", "not-friend"}

data:extend({
  {
    type = "bool-setting",
    name = "tankplatoon-tank-to-recipe-keep",
    setting_type = "startup",
    default_value = true,
    order = "tp-a[tanks]-a[vanilla]"
  },
  {
    type = "bool-setting",
    name = "tankplatoon-tank-t1-enable",
    setting_type = "startup",
    default_value = true,
    order = "tp-a[tanks]-b[mk1]"
  },
  {
    type = "bool-setting",
    name = "tankplatoon-tank-t2-enable",
    setting_type = "startup",
    default_value = true,
    order = "tp-a[tanks]-c[mk2]"
  },
  {
    type = "string-setting",
    name = "tankplatoon-tank-t0-grid",
    setting_type = "startup",
    default_value = "5x4",
    allowed_values = {"0x0", "5x4", "5x5", "6x6", "7x7"},
    order = "tp-b[grid]-a"
  },
  {
    type = "string-setting",
    name = "tankplatoon-tank-t1-grid",
    setting_type = "startup",
    default_value = "7x7",
    allowed_values = {"5x4", "5x5", "6x6", "7x7", "7x8", "8x8", "10x8"},
    order = "tp-b[grid]-b"
  },
  {
    type = "string-setting",
    name = "tankplatoon-tank-t2-grid",
    setting_type = "startup",
    default_value = "10x10",
    allowed_values = {"7x7", "7x8", "8x8", "10x8", "10x10", "10x12"},
    order = "tp-b[grid]-c"
  },
  {
    type = "string-setting",
    name = "tankplatoon-tank-cannon-force-condition",
    setting_type = "startup",
    default_value = "all",
    allowed_values = force_conditions,
    order = "tp-c[shells]-a"
  },
  {
    type = "string-setting",
    name = "tankplatoon-tank-autocannon-force-condition",
    setting_type = "startup",
    default_value = "not-friend",
    allowed_values = force_conditions,
    order = "tp-c[shells]-b"
  },
  {
    type = "bool-setting",
    name = "tankplatoon-vehicle-energy-shield-enable",
    setting_type = "startup",
    default_value = true,
    order = "tp-d[equipment]-a"
  },
  {
    type = "bool-setting",
    name = "tankplatoon-vehicle-battery-enable",
    setting_type = "startup",
    default_value = true,
    order = "tp-d[equipment]-b"
  },
  {
    type = "bool-setting",
    name = "tankplatoon-vehicle-fuel-cell-enable",
    setting_type = "startup",
    default_value = true,
    order = "tp-d[equipment]-c"
  },
  {
    type = "bool-setting",
    name = "tankplatoon-vehicle-nuclear-reactor-enable",
    setting_type = "startup",
    default_value = true,
    order = "tp-d[equipment]-d"
  },
  {
    type = "string-setting",
    name = "tankplatoon-personal-laser-defense-equipment-energy-consumption",
    setting_type = "startup",
    default_value = "800kJ",
    allowed_values = {"50kJ", "100kJ", "150kJ", "200kJ", "250kJ", "300kJ", "400kJ", "500kJ", "600kJ", "700kJ", "800kJ"},
    order = "tp-e[vanilla]-a"
  },
  {
    type = "bool-setting",
    name = "tankplatoon-discharge-defense-equipment-automatic",
    setting_type = "startup",
    default_value = true,
    order = "tp-e[vanilla]-b"
  },
  {
    type = "bool-setting",
    name = "tankplatoon-tank-flamethrower-fire-stream-incendiary",
    setting_type = "startup",
    default_value = false,
    order = "tp-e[vanilla]-c"
  },
  {
    type = "bool-setting",
    name = "tankplatoon-vehicle-hide-resistances",
    setting_type = "startup",
    default_value = true,
    order = "tp-f[display]-a"
  },
  {
    type = "string-setting",
    name = "tankplatoon-minimap-representation",
    setting_type = "startup",
    default_value = "tank",
    allowed_values = {"unchanged", "generic", "tank"},
    order = "tp-f[display]-b"
  },
  {
    type = "bool-setting",
    name = "tankplatoon-vehicle-clone-placement-built-enable",
    setting_type = "runtime-per-user",
    default_value = true,
    order = "tp-x-a"
  },
  {
    type = "bool-setting",
    name = "tankplatoon-vehicle-clone-placement-pasted-enable",
    setting_type = "runtime-per-user",
    default_value = true,
    order = "tp-x-b"
  }
})
