local TPlib = require("lib.TPlib")



local veh_energy_shield_1_icon_layer = {icon = "__base__/graphics/icons/energy-shield-equipment.png", icon_size = 64, icon_mipmaps = 4}
local veh_energy_shield_2_icon_layer = {icon = "__base__/graphics/icons/energy-shield-mk2-equipment.png", icon_size = 64, icon_mipmaps = 4}
local veh_battery_1_icon_layer = {icon = "__SchallTankPlatoon__/graphics/icons/vehicle-battery-equipment.png", icon_size = 64, icon_mipmaps = 4}
local veh_battery_2_icon_layer = {icon = "__SchallTankPlatoon__/graphics/icons/vehicle-battery-mk2-equipment.png", icon_size = 64, icon_mipmaps = 4}
local night_vision_icon_layer = {icon = "__base__/graphics/icons/night-vision-equipment.png", icon_size = 64, icon_mipmaps = 4}
local concrete_wall_icon_layer = {icon = "__SchallTankPlatoon__/graphics/icons/concrete-wall.png", icon_size = 64, icon_mipmaps = 4}
local concrete_gate_icon_layer = {icon = "__SchallTankPlatoon__/graphics/icons/concrete-gate.png", icon_size = 64, icon_mipmaps = 4}
local repair_pack_icon_layer = {icon = "__base__/graphics/icons/repair-pack.png", icon_size = 64, icon_mipmaps = 4}


local function fusion_reactor_icon_layer(tint)
  return {icon = "__base__/graphics/icons/fusion-reactor-equipment.png", icon_size = 64, icon_mipmaps = 4, tint = tint}
end

local function fuel_cell_icon_layer(tint)
  return {icon = "__SchallTankPlatoon__/graphics/icons/vehicle-fuel-cell.png", icon_size = 128, icon_mipmaps = 3, tint = tint}
end
local veh_fuel_cell_2_icon_layer = fuel_cell_icon_layer({r=0.4, g=0.4, b=0.4, a=1})
local veh_fuel_cell_3_icon_layer = fuel_cell_icon_layer({r=0.7, g=0.7, b=0.7, a=1})
local veh_fuel_cell_4_icon_layer = fuel_cell_icon_layer()

local function nuclear_reactor_icon_layer(tint)
  return {icon = "__base__/graphics/icons/nuclear-reactor.png", icon_size = 64, icon_mipmaps = 4, tint = tint}
end
local veh_nuclear_reactor_icon_layer = nuclear_reactor_icon_layer({r=0.7, g=0.7, b=0.7, a=1})


local subgroup_veheqp = {
  [0] = "equipment",
  M   = "military-equipment",
  R   = "equipment",
}

if mods["SchallTransportGroup"] then
  subgroup_veheqp = {
    [0] = "vehicle-equipment",
    M   = "vehicle-equipment-military",
    R   = "vehicle-equipment-defense"
  }
end



data:extend
{
  -- Equipment
  {
    type = "item",
    name = "fusion-reactor-2-equipment",
    icons = { fusion_reactor_icon_layer({r=0.4, g=0.4, b=0.4, a=1}) },
    placed_as_equipment_result = "fusion-reactor-2-equipment",
    subgroup = "equipment",
    order = "a[energy-source]-b[fusion-reactor]",
    stack_size = 20
  },
  {
    type = "item",
    name = "fusion-reactor-3-equipment",
    icons = { fusion_reactor_icon_layer({r=0.7, g=0.7, b=0.7, a=1}) },
    placed_as_equipment_result = "fusion-reactor-3-equipment",
    subgroup = "equipment",
    order = "a[energy-source]-b[fusion-reactor]",
    stack_size = 20
  },
  {
    type = "item",
    name = "vehicle-energy-shield-equipment",
    icons = { veh_energy_shield_1_icon_layer,
              TPlib.tankeqp_icon_layer },
    placed_as_equipment_result = "vehicle-energy-shield-equipment",
    subgroup = subgroup_veheqp["M"],
    order = "a[shield]-v[vehicle]-a[energy-shield-equipment]",
    default_request_amount = 5,
    stack_size = 20
  },
  {
    type = "item",
    name = "vehicle-energy-shield-mk2-equipment",
    icons = { veh_energy_shield_2_icon_layer,
              TPlib.tankeqp_icon_layer },
    placed_as_equipment_result = "vehicle-energy-shield-mk2-equipment",
    subgroup = subgroup_veheqp["M"],
    order = "a[shield]-v[vehicle]-b[energy-shield-equipment-mk2]",
    default_request_amount = 5,
    stack_size = 20
  },
  {
    type = "item",
    name = "vehicle-battery-equipment",
    icons = { veh_battery_1_icon_layer,
              TPlib.tankeqp_icon_layer },
    placed_as_equipment_result = "vehicle-battery-equipment",
    subgroup = subgroup_veheqp[0],
    order = "b[battery]-v[vehicle]-a[battery-equipment]",
    default_request_amount = 5,
    stack_size = 20
  },
  {
    type = "item",
    name = "vehicle-battery-mk2-equipment",
    icons = { veh_battery_2_icon_layer,
              TPlib.tankeqp_icon_layer },
    placed_as_equipment_result = "vehicle-battery-mk2-equipment",
    subgroup = subgroup_veheqp[0],
    order = "b[battery]-v[vehicle]-b[battery-equipment-mk2]",
    default_request_amount = 5,
    stack_size = 20
  },
  {
    type = "item",
    name = "vehicle-fuel-cell-2-equipment",
    icons = { veh_fuel_cell_2_icon_layer,
              TPlib.tankeqp_icon_layer },
    placed_as_equipment_result = "vehicle-fuel-cell-2-equipment",
    subgroup = subgroup_veheqp[0],
    order = "a[energy-source]-v[vehicle]-b[fuel-cell]-2",
    default_request_amount = 1,
    stack_size = 10
  },
  {
    type = "item",
    name = "vehicle-fuel-cell-3-equipment",
    icons = { veh_fuel_cell_3_icon_layer,
              TPlib.tankeqp_icon_layer },
    placed_as_equipment_result = "vehicle-fuel-cell-3-equipment",
    subgroup = subgroup_veheqp[0],
    order = "a[energy-source]-v[vehicle]-b[fuel-cell]-3",
    default_request_amount = 1,
    stack_size = 10
  },
  {
    type = "item",
    name = "vehicle-fuel-cell-4-equipment",
    icons = { veh_fuel_cell_4_icon_layer,
              TPlib.tankeqp_icon_layer },
    placed_as_equipment_result = "vehicle-fuel-cell-4-equipment",
    subgroup = subgroup_veheqp[0],
    order = "a[energy-source]-v[vehicle]-b[fuel-cell]-4",
    default_request_amount = 1,
    stack_size = 10
  },
  {
    type = "item",
    name = "vehicle-nuclear-reactor-equipment",
    icons = { veh_nuclear_reactor_icon_layer,
              TPlib.tankeqp_icon_layer },
    placed_as_equipment_result = "vehicle-nuclear-reactor-equipment",
    subgroup = subgroup_veheqp[0],
    order = "a[energy-source]-v[vehicle]-e[nuclear-reactor]",
    default_request_amount = 1,
    stack_size = 10
  },
  {
    type = "item",
    name = "Schall-night-vision-mk1-equipment",
    localised_description = {"item-description.night-vision-equipment"},
    icons = { night_vision_icon_layer,
              TPlib.tier_icon_layer(1) },
    placed_as_equipment_result = "Schall-night-vision-mk1-equipment",
    subgroup = "equipment",
    order = "f[night-vision]-a[night-vision-equipment]-1",
    default_request_amount = 1,
    stack_size = 20
  },
  {
    type = "item",
    name = "Schall-night-vision-mk2-equipment",
    localised_description = {"item-description.night-vision-equipment"},
    icons = { night_vision_icon_layer,
              TPlib.tier_icon_layer(2) },
    placed_as_equipment_result = "Schall-night-vision-mk2-equipment",
    subgroup = "equipment",
    order = "f[night-vision]-a[night-vision-equipment]-2",
    default_request_amount = 1,
    stack_size = 20
  },
  -- Concrete walls
  {
    type = "item",
    name = "Schall-concrete-wall",
    icons = { concrete_wall_icon_layer },
    subgroup = "defensive-structure",
    order = "a[wall]-a[wall]-2",
    place_result = "Schall-concrete-wall",
    stack_size = 100
  },
  {
    type = "item",
    name = "Schall-concrete-gate",
    icons = { concrete_gate_icon_layer },
    subgroup = "defensive-structure",
    order = "a[wall]-b[gate]-2",
    place_result = "Schall-concrete-gate",
    stack_size = 50
  },
  -- Repair Packs
  {
    type = "repair-tool",
    name = "Schall-repair-pack-mk1",
    localised_description = {"item-description.repair-pack"},
    icons = { repair_pack_icon_layer,
              TPlib.tier_icon_layer(1) },
    icon_size = 32,
    subgroup = "tool",
    order = "b[repair]-a[repair-pack]-1",
    speed = 4,
    durability = 300,
    stack_size = 100
  },
  {
    type = "repair-tool",
    name = "Schall-repair-pack-mk2",
    localised_description = {"item-description.repair-pack"},
    icons = { repair_pack_icon_layer,
              TPlib.tier_icon_layer(2) },
    icon_size = 32,
    subgroup = "tool",
    order = "b[repair]-a[repair-pack]-2",
    speed = 6,
    durability = 300,
    stack_size = 100
  },
}
