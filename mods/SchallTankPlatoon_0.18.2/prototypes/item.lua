local tank_icon_path = "__base__/graphics/icons/tank.png" --data.raw["item-with-entity-data"].tank.icon
local tank_tint_icon_path = "__SchallTankPlatoon__/graphics/icons/tank-to-tint.png"
local mk1_icon_layer = {icon = "__SchallTankPlatoon__/graphics/icons/mk1.png", icon_size = 128, icon_mipmaps = 3}
local mk2_icon_layer = {icon = "__SchallTankPlatoon__/graphics/icons/mk2.png", icon_size = 128, icon_mipmaps = 3}
local tankeqp_icon_layer = {icon = "__SchallTankPlatoon__/graphics/icons/tank-equipment.png", icon_size = 128, icon_mipmaps = 3}

local veh_energy_shield_1_icon_layer = {icon = "__SchallTankPlatoon__/graphics/icons/vehicle-energy-shield-equipment.png", icon_size = 128, icon_mipmaps = 3}
local veh_energy_shield_2_icon_layer = {icon = "__SchallTankPlatoon__/graphics/icons/vehicle-energy-shield-mk2-equipment.png", icon_size = 128, icon_mipmaps = 3}
local veh_battery_1_icon_layer = {icon = "__SchallTankPlatoon__/graphics/icons/vehicle-battery-equipment.png", icon_size = 64, icon_mipmaps = 4}
local veh_battery_2_icon_layer = {icon = "__SchallTankPlatoon__/graphics/icons/vehicle-battery-mk2-equipment.png", icon_size = 64, icon_mipmaps = 4}
local night_vision_icon_layer = {icon = "__base__/graphics/icons/night-vision-equipment.png", icon_size = 64, icon_mipmaps = 4}
local concrete_wall_icon_layer = {icon = "__SchallTankPlatoon__/graphics/icons/concrete-wall.png", icon_size = 64, icon_mipmaps = 4}
local concrete_gate_icon_layer = {icon = "__SchallTankPlatoon__/graphics/icons/concrete-gate.png", icon_size = 64, icon_mipmaps = 4}
local repair_pack_icon_layer = {icon = "__base__/graphics/icons/repair-pack.png", icon_size = 64, icon_mipmaps = 4}



local function tank_original_icon_layer(tint)
  return {icon = tank_icon_path, icon_size = 64, icon_mipmaps = 4, tint = tint}
end
local tank_L_icon_layer = tank_original_icon_layer({r=0.7, g=0.7, b=0.7, a=1})
local tank_M_icon_layer = tank_original_icon_layer({r=0.6, g=0.6, b=0.6, a=1})
local tank_H_icon_layer = tank_original_icon_layer({r=0.5, g=0.5, b=0.5, a=1})
local tank_SH_icon_layer = tank_original_icon_layer({r=0.4, g=0.4, b=0.4, a=1})

local function tank_tint_icon_layer(tint)
  return {icon = tank_tint_icon_path, icon_size = 64, icon_mipmaps = 4, tint = tint}
end
local tank_F_icon_layer = tank_tint_icon_layer({r=1.0, g=0.4, b=0.0, a=1})
local ht_RA_icon_layer = tank_tint_icon_layer({r=0.8, g=0.0, b=0.0, a=1})

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



local subgroup_vehmil = {
  [0] = "transport",
  [1] = "transport",
  [2] = "transport"
}
local subgroup_veheqp = "equipment"

if mods["SchallTransportGroup"] then
  subgroup_vehmil = {
    [0] = "vehicles-military",
    [1] = "vehicles-military",
    [2] = "vehicles-military"
  }
  subgroup_veheqp = "vehicle-equipment"
  if settings.startup["tankplatoon-tiered-military-vehicles-subgroups"].value then
    for k,v in pairs(subgroup_vehmil) do
      if k>0 then subgroup_vehmil[k] = v.."-"..k end
    end
  end
end



data:extend
{
  -- Tanks series
  {
    type = "item-with-entity-data",
    name = "Schall-tank-L",
    icons = { tank_L_icon_layer },
    icon_size = 32,
    subgroup = subgroup_vehmil[0],
    order = "b[personal-transport]-b[tank]-1-0",
    place_result = "Schall-tank-L",
    equipment_grid = "tank-L-equipment-grid",
    stack_size = 1
  },
  {
    type = "item-with-entity-data",
    name = "Schall-tank-M",
    icons = { tank_M_icon_layer },
    icon_size = 32,
    subgroup = subgroup_vehmil[0],
    order = "b[personal-transport]-b[tank]-2-0",
    place_result = "Schall-tank-M",
    equipment_grid = "tank-M-equipment-grid",
    stack_size = 1
  },
  {
    type = "item-with-entity-data",
    name = "Schall-tank-H",
    icons = { tank_H_icon_layer },
    icon_size = 32,
    subgroup = subgroup_vehmil[0],
    order = "b[personal-transport]-b[tank]-3-0",
    place_result = "Schall-tank-H",
    equipment_grid = "tank-H-equipment-grid",
    stack_size = 1
  },
  {
    type = "item-with-entity-data",
    name = "Schall-tank-SH",
    icons = { tank_SH_icon_layer },
    icon_size = 32,
    subgroup = subgroup_vehmil[0],
    order = "b[personal-transport]-b[tank]-4-0",
    place_result = "Schall-tank-SH",
    equipment_grid = "tank-SH-equipment-grid",
    stack_size = 1
  },
  {
    type = "item-with-entity-data",
    name = "Schall-tank-F",
    icons = { tank_F_icon_layer },
    icon_size = 32,
    subgroup = subgroup_vehmil[0],
    order = "b[personal-transport]-b[tank]-5-0",
    place_result = "Schall-tank-F",
    equipment_grid = "tank-F-equipment-grid",
    stack_size = 1
  },
  {
    type = "item-with-entity-data",
    name = "Schall-ht-RA",
    icons = { ht_RA_icon_layer },
    icon_size = 32,
    subgroup = subgroup_vehmil[0],
    order = "b[personal-transport]-b[tank]-6-0",
    place_result = "Schall-ht-RA",
    equipment_grid = "ht-RA-equipment-grid",
    stack_size = 1
  },
  -- Tanks MK1 series
  {
    type = "item-with-entity-data",
    name = "Schall-tank-L-mk1",
    icons = { tank_L_icon_layer,
              mk1_icon_layer },
    icon_size = 32,
    subgroup = subgroup_vehmil[1],
    order = "b[personal-transport]-b[tank]-1-1",
    place_result = "Schall-tank-L-mk1",
    equipment_grid = "tank-L-mk1-equipment-grid",
    stack_size = 1
  },
  {
    type = "item-with-entity-data",
    name = "Schall-tank-M-mk1",
    icons = { tank_M_icon_layer,
              mk1_icon_layer },
    icon_size = 32,
    subgroup = subgroup_vehmil[1],
    order = "b[personal-transport]-b[tank]-2-1",
    place_result = "Schall-tank-M-mk1",
    equipment_grid = "tank-M-mk1-equipment-grid",
    stack_size = 1
  },
  {
    type = "item-with-entity-data",
    name = "Schall-tank-H-mk1",
    icons = { tank_H_icon_layer,
              mk1_icon_layer },
    icon_size = 32,
    subgroup = subgroup_vehmil[1],
    order = "b[personal-transport]-b[tank]-3-1",
    place_result = "Schall-tank-H-mk1",
    equipment_grid = "tank-H-mk1-equipment-grid",
    stack_size = 1
  },
  {
    type = "item-with-entity-data",
    name = "Schall-tank-SH-mk1",
    icons = { tank_SH_icon_layer,
              mk1_icon_layer },
    icon_size = 32,
    subgroup = subgroup_vehmil[1],
    order = "b[personal-transport]-b[tank]-4-1",
    place_result = "Schall-tank-SH-mk1",
    equipment_grid = "tank-SH-mk1-equipment-grid",
    stack_size = 1
  },
  {
    type = "item-with-entity-data",
    name = "Schall-tank-F-mk1",
    icons = { tank_F_icon_layer,
              mk1_icon_layer },
    icon_size = 32,
    subgroup = subgroup_vehmil[1],
    order = "b[personal-transport]-b[tank]-5-1",
    place_result = "Schall-tank-F-mk1",
    equipment_grid = "tank-F-mk1-equipment-grid",
    stack_size = 1
  },
  {
    type = "item-with-entity-data",
    name = "Schall-ht-RA-mk1",
    icons = { ht_RA_icon_layer,
              mk1_icon_layer },
    icon_size = 32,
    subgroup = subgroup_vehmil[1],
    order = "b[personal-transport]-b[tank]-6-1",
    place_result = "Schall-ht-RA-mk1",
    equipment_grid = "ht-RA-mk1-equipment-grid",
    stack_size = 1
  },
  -- Tanks MK2 series
  {
    type = "item-with-entity-data",
    name = "Schall-tank-L-mk2",
    icons = { tank_L_icon_layer,
              mk2_icon_layer },
    icon_size = 32,
    subgroup = subgroup_vehmil[2],
    order = "b[personal-transport]-b[tank]-1-2",
    place_result = "Schall-tank-L-mk2",
    equipment_grid = "tank-L-mk2-equipment-grid",
    stack_size = 1
  },
  {
    type = "item-with-entity-data",
    name = "Schall-tank-M-mk2",
    icons = { tank_M_icon_layer,
              mk2_icon_layer },
    icon_size = 32,
    subgroup = subgroup_vehmil[2],
    order = "b[personal-transport]-b[tank]-2-2",
    place_result = "Schall-tank-M-mk2",
    equipment_grid = "tank-M-mk2-equipment-grid",
    stack_size = 1
  },
  {
    type = "item-with-entity-data",
    name = "Schall-tank-H-mk2",
    icons = { tank_H_icon_layer,
              mk2_icon_layer },
    icon_size = 32,
    subgroup = subgroup_vehmil[2],
    order = "b[personal-transport]-b[tank]-3-2",
    place_result = "Schall-tank-H-mk2",
    equipment_grid = "tank-H-mk2-equipment-grid",
    stack_size = 1
  },
  {
    type = "item-with-entity-data",
    name = "Schall-tank-SH-mk2",
    icons = { tank_SH_icon_layer,
              mk2_icon_layer },
    icon_size = 32,
    subgroup = subgroup_vehmil[2],
    order = "b[personal-transport]-b[tank]-4-2",
    place_result = "Schall-tank-SH-mk2",
    equipment_grid = "tank-SH-mk2-equipment-grid",
    stack_size = 1
  },
  {
    type = "item-with-entity-data",
    name = "Schall-tank-F-mk2",
    icons = { tank_F_icon_layer,
              mk2_icon_layer },
    icon_size = 32,
    subgroup = subgroup_vehmil[2],
    order = "b[personal-transport]-b[tank]-5-2",
    place_result = "Schall-tank-F-mk2",
    equipment_grid = "tank-F-mk2-equipment-grid",
    stack_size = 1
  },
  {
    type = "item-with-entity-data",
    name = "Schall-ht-RA-mk2",
    icons = { ht_RA_icon_layer,
              mk2_icon_layer },
    icon_size = 32,
    subgroup = subgroup_vehmil[2],
    order = "b[personal-transport]-b[tank]-6-2",
    place_result = "Schall-ht-RA-mk2",
    equipment_grid = "ht-RA-mk2-equipment-grid",
    stack_size = 1
  },
  --  Equipment
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
              tankeqp_icon_layer },
    placed_as_equipment_result = "vehicle-energy-shield-equipment",
    subgroup = subgroup_veheqp,
    order = "b[shield]-v[vehicle]-a[energy-shield-equipment]",
    stack_size = 50,
    default_request_amount = 10
  },
  {
    type = "item",
    name = "vehicle-energy-shield-mk2-equipment",
    icons = { veh_energy_shield_2_icon_layer,
              tankeqp_icon_layer },
    placed_as_equipment_result = "vehicle-energy-shield-mk2-equipment",
    subgroup = subgroup_veheqp,
    order = "b[shield]-v[vehicle]-b[energy-shield-equipment-mk2]",
    stack_size = 50,
    default_request_amount = 10
  },
  {
    type = "item",
    name = "vehicle-battery-equipment",
    icons = { veh_battery_1_icon_layer,
              tankeqp_icon_layer },
    placed_as_equipment_result = "vehicle-battery-equipment",
    subgroup = subgroup_veheqp,
    order = "c[battery]-v[vehicle]-a[battery-equipment]",
    stack_size = 50,
    default_request_amount = 10
  },
  {
    type = "item",
    name = "vehicle-battery-mk2-equipment",
    icons = { veh_battery_2_icon_layer,
              tankeqp_icon_layer },
    placed_as_equipment_result = "vehicle-battery-mk2-equipment",
    subgroup = subgroup_veheqp,
    order = "c[battery]-v[vehicle]-b[battery-equipment-mk2]",
    stack_size = 50,
    default_request_amount = 10
  },
  {
    type = "item",
    name = "vehicle-fuel-cell-2-equipment",
    icons = { veh_fuel_cell_2_icon_layer,
              tankeqp_icon_layer },
    placed_as_equipment_result = "vehicle-fuel-cell-2-equipment",
    subgroup = subgroup_veheqp,
    order = "a[energy-source]-v[vehicle]-b[fuel-cell-2]",
    stack_size = 10,
    default_request_amount = 1
  },
  {
    type = "item",
    name = "vehicle-fuel-cell-3-equipment",
    icons = { veh_fuel_cell_3_icon_layer,
              tankeqp_icon_layer },
    placed_as_equipment_result = "vehicle-fuel-cell-3-equipment",
    subgroup = subgroup_veheqp,
    order = "a[energy-source]-v[vehicle]-c[fuel-cell-3]",
    stack_size = 10,
    default_request_amount = 1
  },
  {
    type = "item",
    name = "vehicle-fuel-cell-4-equipment",
    icons = { veh_fuel_cell_4_icon_layer,
              tankeqp_icon_layer },
    placed_as_equipment_result = "vehicle-fuel-cell-4-equipment",
    subgroup = subgroup_veheqp,
    order = "a[energy-source]-v[vehicle]-d[fuel-cell-4]",
    stack_size = 10,
    default_request_amount = 1
  },
  {
    type = "item",
    name = "vehicle-nuclear-reactor-equipment",
    icons = { veh_nuclear_reactor_icon_layer,
              tankeqp_icon_layer },
    placed_as_equipment_result = "vehicle-nuclear-reactor-equipment",
    subgroup = subgroup_veheqp,
    order = "a[energy-source]-v[vehicle]-e[nuclear-reactor]",
    stack_size = 10,
    default_request_amount = 1
  },
  {
    type = "item",
    name = "Schall-night-vision-mk1-equipment",
    localised_description = {"item-description.night-vision-equipment"},
    icons = { night_vision_icon_layer,
              mk1_icon_layer },
    placed_as_equipment_result = "Schall-night-vision-mk1-equipment",
    subgroup = "equipment",
    order = "f[night-vision]-a[night-vision-equipment]-1",
    stack_size = 20,
    default_request_amount = 1
  },
  {
    type = "item",
    name = "Schall-night-vision-mk2-equipment",
    localised_description = {"item-description.night-vision-equipment"},
    icons = { night_vision_icon_layer,
              mk2_icon_layer },
    placed_as_equipment_result = "Schall-night-vision-mk2-equipment",
    subgroup = "equipment",
    order = "f[night-vision]-a[night-vision-equipment]-2",
    stack_size = 20,
    default_request_amount = 1
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
              mk1_icon_layer },
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
              mk2_icon_layer },
    icon_size = 32,
    subgroup = "tool",
    order = "b[repair]-a[repair-pack]-2",
    speed = 6,
    durability = 300,
    stack_size = 100
  },
}



if settings.startup["tankplatoon-vehicle-battery-enable"].value then
  dri = data.raw.item
  if dri["battery-equipment"] then
    dri["battery-equipment"].icons = { {icon = "__SchallTankPlatoon__/graphics/icons/battery-equipment.png", icon_size = 64, icon_mipmaps = 4} }
  end
  if dri["battery-mk2-equipment"] then
    dri["battery-mk2-equipment"].icons = { {icon = "__SchallTankPlatoon__/graphics/icons/battery-mk2-equipment.png", icon_size = 64, icon_mipmaps = 4} }
  end
end
