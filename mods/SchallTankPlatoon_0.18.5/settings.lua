local grid_t0_vehicle_sizes = {
  "0x0",
  "5x4",
  "5x5",
  "6x6",
  "7x7",
}

local grid_t1_vehicle_sizes = {
  "5x4",
  "5x5",
  "6x6",
  "7x7",
  "7x8",
  "8x8",
  "10x8",
}

local grid_t2_vehicle_sizes = {
  "7x7",
  "7x8",
  "8x8",
  "10x8",
  "10x10",
  "10x12",
}

local force_condition_values = {
  "all",
  "not-same",
  "not-friend",
}


data:extend
{
  -- Tank Platoon
  {
    type = "bool-setting",
    name = "tankplatoon-tank-to-recipe-force-enable",
    order = "p-z",
    setting_type = "runtime-global",
    default_value = false
  },
  {
    type = "bool-setting",
    name = "tankplatoon-tank-to-recipe-keep",
    order = "p-b-a-0",
    setting_type = "startup",
    default_value = false
  },
  {
    type = "bool-setting",
    name = "tankplatoon-tank-t1-enable",
    order = "p-b-a-1",
    setting_type = "startup",
    default_value = true
  },
  {
    type = "bool-setting",
    name = "tankplatoon-tank-t2-enable",
    order = "p-b-a-2",
    setting_type = "startup",
    default_value = true
  },
  {
    type = "bool-setting",
    name = "tankplatoon-ht-RA-enable",
    order = "p-b-b-2",
    setting_type = "startup",
    default_value = true
  },
  {
    type = "string-setting",
    name = "tankplatoon-tank-t0-grid",
    order = "p-g-0",
    setting_type = "startup",
    allowed_values = grid_t0_vehicle_sizes,
    default_value = "5x4"
  },
  {
    type = "string-setting",
    name = "tankplatoon-tank-t1-grid",
    order = "p-g-1",
    setting_type = "startup",
    allowed_values = grid_t1_vehicle_sizes,
    default_value = "7x7"
  },
  {
    type = "string-setting",
    name = "tankplatoon-tank-t2-grid",
    order = "p-g-2",
    setting_type = "startup",
    allowed_values = grid_t2_vehicle_sizes,
    default_value = "10x10"
  },
  -- {
  --   type = "bool-setting",
  --   name = "tankplatoon-tank-cannon-collision",
  --   order = "p-n-0",
  --   setting_type = "startup",
  --   default_value = true
  -- },
  -- {
  --   type = "bool-setting",
  --   name = "tankplatoon-tank-autocannon-collision",
  --   order = "p-n-1",
  --   setting_type = "startup",
  --   default_value = false
  -- },
  {
    type = "string-setting",
    name = "tankplatoon-tank-cannon-force-condition",
    order = "p-n-4",
    setting_type = "startup",
    allowed_values = force_condition_values,
    default_value = "all"
  },
  {
    type = "string-setting",
    name = "tankplatoon-tank-autocannon-force-condition",
    order = "p-n-5",
    setting_type = "startup",
    allowed_values = force_condition_values,
    default_value = "not-friend"
  },
  {
    type = "bool-setting",
    name = "tankplatoon-vehicle-energy-shield-enable",
    order = "p-b-v-1",
    setting_type = "startup",
    default_value = true
  },
  {
    type = "bool-setting",
    name = "tankplatoon-vehicle-battery-enable",
    order = "p-b-v-2",
    setting_type = "startup",
    default_value = true
  },
  {
    type = "bool-setting",
    name = "tankplatoon-vehicle-fuel-cell-enable",
    order = "p-b-v-3",
    setting_type = "startup",
    default_value = true
  },
  {
    type = "bool-setting",
    name = "tankplatoon-vehicle-nuclear-reactor-enable",
    order = "p-b-v-4",
    setting_type = "startup",
    default_value = true
  },
  {
    type = "bool-setting",
    name = "tankplatoon-night-vision-enable",
    order = "p-b-w-1",
    setting_type = "startup",
    default_value = false
  },
  {
    type = "bool-setting",
    name = "tankplatoon-concrete-walls-enable",
    order = "p-b-s-1",
    setting_type = "startup",
    default_value = false
  },
  {
    type = "bool-setting",
    name = "tankplatoon-repair-pack-enable",
    order = "p-b-r-1",
    setting_type = "startup",
    default_value = false
  },
  -- {
  --   type = "string-setting",
  --   name = "tankplatoon-personal-laser-defense-equipment-ammo-category",
  --   order = "p-e-1",
  --   setting_type = "startup",
  --   allowed_values = {"electric", "laser-turret"},
  --   default_value = "electric"
  -- },
  {
    type = "string-setting",
    name = "tankplatoon-personal-laser-defense-equipment-energy-consumption",
    order = "p-e-2",
    setting_type = "startup",
    allowed_values = {"50kJ", "100kJ", "150kJ", "200kJ", "250kJ", "300kJ"},
    default_value = "200kJ"
  },
  {
    type = "bool-setting",
    name = "tankplatoon-discharge-defense-equipment-automatic",
    order = "p-e-3",
    setting_type = "startup",
    default_value = true
  },
  {
    type = "bool-setting",
    name = "tankplatoon-tank-flamethrower-fire-stream-incendiary",
    order = "p-f-1",
    setting_type = "startup",
    default_value = false
  },
  {
    type = "bool-setting",
    name = "tankplatoon-ammo-colour-rearrange",
    order = "p-f-2",
    setting_type = "startup",
    default_value = true
  },
  {
    type = "bool-setting",
    name = "tankplatoon-chemical-weapon-chemical-recipes",
    order = "p-f-3",
    setting_type = "startup",
    default_value = true
  },
  {
    type = "bool-setting",
    name = "tankplatoon-vehicle-hide-resistances",
    order = "p-p-1",
    setting_type = "startup",
    default_value = true
  },
  {
    type = "bool-setting",
    name = "tankplatoon-tiered-military-vehicles-subgroups",
    order = "p-r-1",
    setting_type = "startup",
    default_value = false
  },
}
