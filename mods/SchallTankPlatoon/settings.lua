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

local minimap_rep_values = {
  "unchanged",
  "generic",
  "tank",
}


data:extend
{
  -- Tank Platoon
  {
    type = "bool-setting",
    name = "tankplatoon-tank-to-recipe-force-enable",
    order = "tp-z",
    setting_type = "runtime-global",
    default_value = false
  },
  {
    type = "bool-setting",
    name = "tankplatoon-tank-to-recipe-keep",
    order = "tp-b-a-0",
    setting_type = "startup",
    default_value = true
  },
  {
    type = "bool-setting",
    name = "tankplatoon-tank-t1-enable",
    order = "tp-b-a-1",
    setting_type = "startup",
    default_value = true
  },
  {
    type = "bool-setting",
    name = "tankplatoon-tank-t2-enable",
    order = "tp-b-a-2",
    setting_type = "startup",
    default_value = true
  },
  {
    type = "bool-setting",
    name = "tankplatoon-ht-RA-enable",
    order = "tp-b-b-2",
    setting_type = "startup",
    default_value = true
  },
  {
    type = "string-setting",
    name = "tankplatoon-tank-t0-grid",
    order = "tp-g-0",
    setting_type = "startup",
    allowed_values = grid_t0_vehicle_sizes,
    default_value = "5x4"
  },
  {
    type = "string-setting",
    name = "tankplatoon-tank-t1-grid",
    order = "tp-g-1",
    setting_type = "startup",
    allowed_values = grid_t1_vehicle_sizes,
    default_value = "7x7"
  },
  {
    type = "string-setting",
    name = "tankplatoon-tank-t2-grid",
    order = "tp-g-2",
    setting_type = "startup",
    allowed_values = grid_t2_vehicle_sizes,
    default_value = "10x10"
  },
  {
    type = "string-setting",
    name = "tankplatoon-tank-cannon-force-condition",
    order = "tp-n-4",
    setting_type = "startup",
    allowed_values = force_condition_values,
    default_value = "all"
  },
  {
    type = "string-setting",
    name = "tankplatoon-tank-autocannon-force-condition",
    order = "tp-n-5",
    setting_type = "startup",
    allowed_values = force_condition_values,
    default_value = "not-friend"
  },
  {
    type = "bool-setting",
    name = "tankplatoon-vehicle-energy-shield-enable",
    order = "tp-b-v-1",
    setting_type = "startup",
    default_value = true
  },
  {
    type = "bool-setting",
    name = "tankplatoon-vehicle-battery-enable",
    order = "tp-b-v-2",
    setting_type = "startup",
    default_value = true
  },
  {
    type = "bool-setting",
    name = "tankplatoon-vehicle-fuel-cell-enable",
    order = "tp-b-v-3",
    setting_type = "startup",
    default_value = true
  },
  {
    type = "bool-setting",
    name = "tankplatoon-vehicle-nuclear-reactor-enable",
    order = "tp-b-v-4",
    setting_type = "startup",
    default_value = true
  },
  {
    type = "bool-setting",
    name = "tankplatoon-night-vision-enable",
    order = "tp-b-w-1",
    setting_type = "startup",
    default_value = false
  },
  {
    type = "bool-setting",
    name = "tankplatoon-concrete-walls-enable",
    order = "tp-b-s-1",
    setting_type = "startup",
    default_value = false
  },
  {
    type = "bool-setting",
    name = "tankplatoon-repair-pack-enable",
    order = "tp-b-r-1",
    setting_type = "startup",
    default_value = false
  },
  -- {
  --   type = "string-setting",
  --   name = "tankplatoon-personal-laser-defense-equipment-ammo-category",
  --   order = "tp-e-1",
  --   setting_type = "startup",
  --   allowed_values = {"electric", "laser-turret"},
  --   default_value = "electric"
  -- },
  {
    type = "string-setting",
    name = "tankplatoon-personal-laser-defense-equipment-energy-consumption",
    order = "tp-e-2",
    setting_type = "startup",
    allowed_values = {"50kJ", "100kJ", "150kJ", "200kJ", "250kJ", "300kJ", "400kJ", "500kJ", "600kJ", "700kJ", "800kJ"},
    default_value = "500kJ"
  },
  {
    type = "bool-setting",
    name = "tankplatoon-discharge-defense-equipment-automatic",
    order = "tp-e-3",
    setting_type = "startup",
    default_value = true
  },
  {
    type = "bool-setting",
    name = "tankplatoon-tank-flamethrower-fire-stream-incendiary",
    order = "tp-f-1",
    setting_type = "startup",
    default_value = false
  },
  {
    type = "bool-setting",
    name = "tankplatoon-ammo-colour-rearrange",
    order = "tp-f-2",
    setting_type = "startup",
    default_value = true
  },
  {
    type = "bool-setting",
    name = "tankplatoon-chemical-weapon-chemical-recipes",
    order = "tp-f-3",
    setting_type = "startup",
    default_value = true
  },
  {
    type = "bool-setting",
    name = "tankplatoon-vehicle-hide-resistances",
    order = "tp-p-1",
    setting_type = "startup",
    default_value = true
  },
  {
    type = "bool-setting",
    name = "tankplatoon-tiered-military-vehicles-subgroups",
    order = "tp-r-1",
    setting_type = "startup",
    default_value = false
  },
  {
    type = "bool-setting",
    name = "tankplatoon-vehicle-clone-placement-built-enable",
    order = "tp-x-1",
    setting_type = "runtime-per-user",
    default_value = true
  },
  {
    type = "bool-setting",
    name = "tankplatoon-vehicle-clone-placement-pasted-enable",
    order = "tp-x-2",
    setting_type = "runtime-per-user",
    default_value = true
  },
  {
    type = "bool-setting",
    name = "tankplatoon-bullet-projectile-enable",
    order = "tp-f-4",
    setting_type = "startup",
    default_value = false
  },
  {
    type = "string-setting",
    name = "tankplatoon-bullet-force-condition",
    order = "tp-n-0",
    setting_type = "startup",
    allowed_values = force_condition_values,
    default_value = "not-same"
  },
  {
    type = "string-setting",
    name = "tankplatoon-minimap-representation",
    order = "tp-r-2",
    setting_type = "startup",
    allowed_values = minimap_rep_values,
    default_value = "tank"
  },
}
