local mul_T1_max_health = 1.5
local mul_T2_max_health = 2

local base_L_braking_power = 200 --kW
local base_L_consumption = 320
local base_M_braking_power = 400
local base_M_consumption = 600
local base_H_braking_power = 660
local base_H_consumption = 1000
local base_SH_braking_power = 660
local base_SH_consumption = 1000
local mul_T1_power = 1.2
local mul_T2_power = 1.5

local T0_inventory_size = 20
local T1_inventory_size = 30
local T2_inventory_size = 40



-- Tanks
local tankL_entity = table.deepcopy(data.raw.car.tank)
tankL_entity.name = "Schall-tank-L"
tankL_entity.icons = data.raw["item-with-entity-data"]["Schall-tank-L"].icons --tankL_item.icons
tankL_entity.minable = {mining_time = 0.5, result = "Schall-tank-L"}
tankL_entity.max_health = 1000
tankL_entity.resistances =
    {
      { type = "fire",      decrease = 10,  percent = 50 },
      { type = "physical",  decrease = 10,  percent = 40 },
      { type = "impact",    decrease = 40,  percent = 70 },
      { type = "explosion", decrease = 10,  percent = 60 },
      { type = "acid",      decrease =  0,  percent = 60 }
    }
tankL_entity.collision_box = {{-0.9*0.8, -1.3*0.8}, {0.9*0.8, 1.3*0.8}}
tankL_entity.selection_box = {{-0.9*0.8, -1.3*0.8}, {0.9*0.8, 1.3*0.8}}
tankL_entity.drawing_box = {{-1.8*0.8, -1.8*0.8}, {1.8*0.8, 1.5*0.8}}
tankL_entity.effectivity = 0.95 --0.7
tankL_entity.braking_power = base_L_braking_power.."kW"
tankL_entity.burner.effectivity = 1 --0.8
tankL_entity.burner.fuel_inventory_size = 1 --2
tankL_entity.consumption = base_L_consumption.."kW"
-- tankL_entity.terrain_friction_modifier = 0.2 -- 0.2, Increased for SH Tanks
tankL_entity.weight = 8000
tankL_entity.turret_rotation_speed = 0.4 / 60
tankL_entity.rotation_speed = 0.004
tankL_entity.inventory_size = T0_inventory_size
tankL_entity.guns = { "tank-autocannon", "tank-machine-gun-single" }
tankL_entity.equipment_grid = "Schall-tank-L-equipment-grid"
data.raw["item-with-entity-data"]["Schall-tank-L"].equipment_grid = tankL_entity.equipment_grid
for _, layer in pairs(tankL_entity.animation.layers) do
  layer.tint = {r=0.7, g=0.7, b=0.7, a=1}
  layer.scale = 0.8
  if (layer.hr_version) then
    layer.hr_version.tint = {r=0.7, g=0.7, b=0.7, a=1}
    layer.hr_version.scale = 0.5*0.8
  end
end
for _, layer in pairs(tankL_entity.turret_animation.layers) do
  layer.scale = 0.8
  if (layer.hr_version) then
    layer.hr_version.scale = 0.5*0.8
  end
end


local tankM_entity = table.deepcopy(data.raw.car.tank)
tankM_entity.name = "Schall-tank-M"
tankM_entity.icons = data.raw["item-with-entity-data"]["Schall-tank-M"].icons --tankM_item.icons
tankM_entity.minable = {mining_time = 0.5, result = "Schall-tank-M"}
tankM_entity.max_health = 2000
tankM_entity.resistances =
    {
      { type = "fire",      decrease = 15,  percent = 60 },
      { type = "physical",  decrease = 15,  percent = 50 },
      { type = "impact",    decrease = 50,  percent = 80 },
      { type = "explosion", decrease = 15,  percent = 70 },
      { type = "acid",      decrease =  0,  percent = 70 }
    }
tankM_entity.collision_box = {{-0.9, -1.3}, {0.9, 1.3}}
tankM_entity.selection_box = {{-0.9, -1.3}, {0.9, 1.3}}
tankM_entity.drawing_box = {{-1.8, -1.8}, {1.8, 1.5}}
tankM_entity.effectivity = 0.9 --0.6
tankM_entity.braking_power = base_M_braking_power.."kW"
tankM_entity.burner.effectivity = 1 --0.75
tankM_entity.consumption = base_M_consumption.."kW"
-- tankM_entity.terrain_friction_modifier = 0.2 -- 0.2, Increased for SH Tanks
tankM_entity.weight = 20000
tankM_entity.turret_rotation_speed = 0.35 / 60
tankM_entity.rotation_speed = 0.0035
tankM_entity.inventory_size = T0_inventory_size
tankM_entity.guns = { "tank-cannon", "tank-machine-gun" }
tankM_entity.equipment_grid = "Schall-tank-M-equipment-grid"
data.raw["item-with-entity-data"]["Schall-tank-M"].equipment_grid = tankM_entity.equipment_grid
for _, layer in pairs(tankM_entity.animation.layers) do
  layer.tint = {r=0.6, g=0.6, b=0.6, a=1}
  -- layer.scale = 1
  if (layer.hr_version) then
    layer.hr_version.tint = {r=0.6, g=0.6, b=0.6, a=1}
    layer.hr_version.scale = 0.5*1
  end
end
-- for _, layer in pairs(tankM_entity.turret_animation.layers) do
--   layer.scale = 1
--   if (layer.hr_version) then
--     layer.hr_version.scale = 0.5*1
--   end
-- end


local tankH_entity = table.deepcopy(data.raw.car.tank)
tankH_entity.name = "Schall-tank-H"
tankH_entity.icons = data.raw["item-with-entity-data"]["Schall-tank-H"].icons --tankH_item.icons
tankH_entity.minable = {mining_time = 0.5, result = "Schall-tank-H"}
tankH_entity.max_health = 3000
tankH_entity.resistances =
    {
      { type = "fire",      decrease = 15,  percent = 60 },
      { type = "physical",  decrease = 18,  percent = 55 },
      { type = "impact",    decrease = 55,  percent = 80 },
      { type = "explosion", decrease = 18,  percent = 75 },
      { type = "acid",      decrease =  3,  percent = 70 }
    }
tankH_entity.collision_box = {{-0.9*1.5, -1.3*1.5}, {0.9*1.5, 1.3*1.5}}
tankH_entity.selection_box = {{-0.9*1.5, -1.3*1.5}, {0.9*1.5, 1.3*1.5}}
tankH_entity.drawing_box = {{-1.8*1.5, -1.8*1.5}, {1.8*1.5, 1.5*1.5}}
tankH_entity.effectivity = 0.75 --0.5
tankH_entity.braking_power = base_H_braking_power.."kW"
tankH_entity.burner.effectivity = 0.875 --0.65
tankH_entity.consumption = base_H_consumption.."kW"
tankH_entity.terrain_friction_modifier = 0.22 -- 0.2, Increased for H Tanks
tankH_entity.weight = 50000
tankH_entity.turret_rotation_speed = 0.1 / 60
tankH_entity.rotation_speed = 0.002
tankH_entity.inventory_size = T0_inventory_size
tankH_entity.guns = { "tank-cannon-H1", "tank-machine-gun" }
tankH_entity.equipment_grid = "Schall-tank-H-equipment-grid"
data.raw["item-with-entity-data"]["Schall-tank-H"].equipment_grid = tankH_entity.equipment_grid
for _, layer in pairs(tankH_entity.animation.layers) do
  layer.tint = {r=0.5, g=0.5, b=0.5, a=1}
  layer.scale = 1.5
  if (layer.hr_version) then
    layer.hr_version.tint = {r=0.5, g=0.5, b=0.5, a=1}
    layer.hr_version.scale = 0.5*1.5
  end
end
for _, layer in pairs(tankH_entity.turret_animation.layers) do
  layer.scale = 1.5
  if (layer.hr_version) then
    layer.hr_version.scale = 0.5*1.5
  end
end


local tankSH_entity = table.deepcopy(data.raw.car.tank)
tankSH_entity.name = "Schall-tank-SH"
tankSH_entity.icons = data.raw["item-with-entity-data"]["Schall-tank-SH"].icons --tankSH_item.icons
tankSH_entity.minable = {mining_time = 0.5, result = "Schall-tank-SH"}
tankSH_entity.max_health = 4000
tankSH_entity.resistances =
    {
      { type = "fire",      decrease = 15,  percent = 60 },
      { type = "physical",  decrease = 20,  percent = 60 },
      { type = "impact",    decrease = 60,  percent = 80 },
      { type = "explosion", decrease = 20,  percent = 80 },
      { type = "acid",      decrease =  5,  percent = 70 }
    }
tankSH_entity.collision_box = {{-0.9*2, -1.3*2}, {0.9*2, 1.3*2}}
tankSH_entity.selection_box = {{-0.9*2, -1.3*2}, {0.9*2, 1.3*2}}
tankSH_entity.drawing_box = {{-1.8*2, -1.8*2}, {1.8*2, 1.5*2}}
tankSH_entity.effectivity = 0.6 --0.4
tankSH_entity.braking_power = base_SH_braking_power.."kW"
tankSH_entity.burner.effectivity = 0.666 --0.5
tankSH_entity.consumption = base_SH_consumption.."kW"
tankSH_entity.terrain_friction_modifier = 0.25 -- 0.2, Increased for SH Tanks
tankSH_entity.weight = 100000
tankSH_entity.turret_rotation_speed = 0.025 / 60
tankSH_entity.rotation_speed = 0.001
tankSH_entity.inventory_size = T0_inventory_size
tankSH_entity.guns = { "tank-cannon-H2", "tank-cannon-H2", "tank-machine-gun" }
tankSH_entity.equipment_grid = "Schall-tank-SH-equipment-grid"
data.raw["item-with-entity-data"]["Schall-tank-SH"].equipment_grid = tankSH_entity.equipment_grid
for _, layer in pairs(tankSH_entity.animation.layers) do
  layer.tint = {r=0.4, g=0.4, b=0.4, a=1}
  layer.scale = 2
  if (layer.hr_version) then
    layer.hr_version.tint = {r=0.4, g=0.4, b=0.4, a=1}
    layer.hr_version.scale = 0.5*2
  end
end
for _, layer in pairs(tankSH_entity.turret_animation.layers) do
  layer.scale = 2
  if (layer.hr_version) then
    layer.hr_version.scale = 0.5*2
  end
end


local tankF_entity = table.deepcopy(tankM_entity)
tankF_entity.name = "Schall-tank-F"
tankF_entity.icons = data.raw["item-with-entity-data"]["Schall-tank-F"].icons --tankM_item.icons
tankF_entity.minable = {mining_time = 0.5, result = "Schall-tank-F"}
tankF_entity.resistances =
    {
      { type = "fire",      decrease = 50,  percent = 100 },
      { type = "physical",  decrease = 10,  percent = 50 },
      { type = "impact",    decrease = 45,  percent = 80 },
      { type = "explosion", decrease = 10,  percent = 60 },
      { type = "acid",      decrease =  0,  percent = 70 }
    }
tankF_entity.guns = { "tank-flamethrower", "tank-machine-gun" }
tankF_entity.equipment_grid = "Schall-tank-F-equipment-grid"
data.raw["item-with-entity-data"]["Schall-tank-F"].equipment_grid = tankF_entity.equipment_grid
for _, layer in pairs(tankF_entity.animation.layers) do
  layer.tint = {r=1.0, g=0.4, b=0.0, a=1}
  -- layer.tint = {r=1.0, g=0.6, b=0.6, a=1}
  if (layer.hr_version) then
    layer.hr_version.tint = {r=1.0, g=0.4, b=0.0, a=1}
    -- layer.hr_version.tint = {r=1.0, g=0.6, b=0.6, a=1}
  end
end


local htRA_entity = table.deepcopy(tankM_entity)
htRA_entity.name = "Schall-ht-RA"
htRA_entity.icons = data.raw["item-with-entity-data"]["Schall-ht-RA"].icons --tankM_item.icons
htRA_entity.minable = {mining_time = 0.5, result = "Schall-ht-RA"}
htRA_entity.resistances =
    {
      { type = "fire",      decrease = 10,  percent = 40 },
      { type = "physical",  decrease =  0,  percent = 40 },
      { type = "impact",    decrease = 30,  percent = 60 },
      { type = "explosion", decrease = 10,  percent = 50 },
      { type = "acid",      decrease =  0,  percent = 60 }
    }
htRA_entity.weight = tankM_entity.weight * 2
htRA_entity.guns = { "Schall-tactical-missile-launcher", "Schall-multiple-rocket-launcher", "tank-machine-gun-single" }
htRA_entity.equipment_grid = "Schall-ht-RA-equipment-grid"
data.raw["item-with-entity-data"]["Schall-ht-RA"].equipment_grid = htRA_entity.equipment_grid
for _, layer in pairs(htRA_entity.animation.layers) do
  layer.tint = {r=0.8, g=0.0, b=0.0, a=1}
  -- layer.tint = {r=0.4, g=1.0, b=0.4, a=1}
  if (layer.hr_version) then
    layer.hr_version.tint = {r=0.8, g=0.0, b=0.0, a=1}
    -- layer.hr_version.tint = {r=0.4, g=1.0, b=0.4, a=1}
  end
end



-- Tanks MK1 series
local tankL1_entity = table.deepcopy(tankL_entity) --table.deepcopy(data.raw.car.tank)
tankL1_entity.name = "Schall-tank-L-mk1"
tankL1_entity.icons = data.raw["item-with-entity-data"]["Schall-tank-L-mk1"].icons --tankL_item.icons
tankL1_entity.minable = {mining_time = 0.5, result = "Schall-tank-L-mk1"}
tankL1_entity.max_health = tankL_entity.max_health * mul_T1_max_health
tankL1_entity.resistances =
    {
      { type = "fire",      decrease = 10,  percent = 55 },
      { type = "physical",  decrease = 10,  percent = 45 },
      { type = "impact",    decrease = 42,  percent = 70 },
      { type = "explosion", decrease = 12,  percent = 68 },
      { type = "acid",      decrease =  2,  percent = 60 },
      { type = "laser",     decrease =  5,  percent = 20 },
      { type = "electric",  decrease =  5,  percent = 20 }
    }
tankL1_entity.braking_power = base_L_braking_power*mul_T1_power.."kW"
tankL1_entity.consumption = base_L_consumption*mul_T1_power.."kW"
tankL1_entity.inventory_size = T1_inventory_size
-- tankL1_entity.guns = { "tank-autocannon", "tank-machine-gun-single" }
tankL1_entity.equipment_grid = "Schall-tank-L-mk1-equipment-grid"
data.raw["item-with-entity-data"]["Schall-tank-L-mk1"].equipment_grid = tankL1_entity.equipment_grid


local tankM1_entity = table.deepcopy(tankM_entity)
tankM1_entity.name = "Schall-tank-M-mk1"
tankM1_entity.icons = data.raw["item-with-entity-data"]["Schall-tank-M-mk1"].icons --tankM_item.icons
tankM1_entity.minable = {mining_time = 0.5, result = "Schall-tank-M-mk1"}
tankM1_entity.max_health = tankM_entity.max_health * mul_T1_max_health
tankM1_entity.resistances =
    {
      { type = "fire",      decrease = 15,  percent = 65 },
      { type = "physical",  decrease = 15,  percent = 55 },
      { type = "impact",    decrease = 52,  percent = 80 },
      { type = "explosion", decrease = 17,  percent = 78 },
      { type = "acid",      decrease =  2,  percent = 70 },
      { type = "laser",     decrease =  5,  percent = 20 },
      { type = "electric",  decrease =  5,  percent = 20 }
    }
tankM1_entity.braking_power = base_M_braking_power*mul_T1_power.."kW"
tankM1_entity.consumption = base_M_consumption*mul_T1_power.."kW"
tankM1_entity.inventory_size = T1_inventory_size
-- tankM1_entity.guns = { "tank-cannon", "tank-machine-gun" }
tankM1_entity.equipment_grid = "Schall-tank-M-mk1-equipment-grid"
data.raw["item-with-entity-data"]["Schall-tank-M-mk1"].equipment_grid = tankM1_entity.equipment_grid


local tankH1_entity = table.deepcopy(tankH_entity)
tankH1_entity.name = "Schall-tank-H-mk1"
tankH1_entity.icons = data.raw["item-with-entity-data"]["Schall-tank-H-mk1"].icons --tankH_item.icons
tankH1_entity.minable = {mining_time = 0.5, result = "Schall-tank-H-mk1"}
tankH1_entity.max_health = tankH_entity.max_health * mul_T1_max_health
tankH1_entity.resistances =
    {
      { type = "fire",      decrease = 15,  percent = 65 },
      { type = "physical",  decrease = 18,  percent = 60 },
      { type = "impact",    decrease = 57,  percent = 80 },
      { type = "explosion", decrease = 20,  percent = 83 },
      { type = "acid",      decrease =  5,  percent = 70 },
      { type = "laser",     decrease =  5,  percent = 20 },
      { type = "electric",  decrease =  5,  percent = 20 }
    }
tankH1_entity.braking_power = base_H_braking_power*mul_T1_power.."kW"
tankH1_entity.consumption = base_H_consumption*mul_T1_power.."kW"
tankH1_entity.inventory_size = T1_inventory_size
-- tankH1_entity.guns = { "tank-cannon-barrel1", "tank-machine-gun" }
tankH1_entity.equipment_grid = "Schall-tank-H-mk1-equipment-grid"
data.raw["item-with-entity-data"]["Schall-tank-H-mk1"].equipment_grid = tankH1_entity.equipment_grid


local tankSH1_entity = table.deepcopy(tankSH_entity)
tankSH1_entity.name = "Schall-tank-SH-mk1"
tankSH1_entity.icons = data.raw["item-with-entity-data"]["Schall-tank-SH-mk1"].icons --tankSH_item.icons
tankSH1_entity.minable = {mining_time = 0.5, result = "Schall-tank-SH-mk1"}
tankSH1_entity.max_health = tankSH_entity.max_health * mul_T1_max_health
tankSH1_entity.resistances =
    {
      { type = "fire",      decrease = 15,  percent = 65 },
      { type = "physical",  decrease = 20,  percent = 65 },
      { type = "impact",    decrease = 62,  percent = 80 },
      { type = "explosion", decrease = 22,  percent = 88 },
      { type = "acid",      decrease =  7,  percent = 70 },
      { type = "laser",     decrease =  5,  percent = 20 },
      { type = "electric",  decrease =  5,  percent = 20 }
    }
tankSH1_entity.braking_power = base_SH_braking_power*mul_T1_power.."kW"
tankSH1_entity.consumption = base_SH_consumption*mul_T1_power.."kW"
tankSH1_entity.inventory_size = T1_inventory_size
-- tankSH1_entity.guns = { "tank-cannon-barrel2", "tank-machine-gun" }
tankSH1_entity.equipment_grid = "Schall-tank-SH-mk1-equipment-grid"
data.raw["item-with-entity-data"]["Schall-tank-SH-mk1"].equipment_grid = tankSH1_entity.equipment_grid


local tankF1_entity = table.deepcopy(tankM1_entity)
tankF1_entity.name = "Schall-tank-F-mk1"
tankF1_entity.icons = data.raw["item-with-entity-data"]["Schall-tank-F-mk1"].icons --tankM_item.icons
tankF1_entity.minable = {mining_time = 0.5, result = "Schall-tank-F-mk1"}
tankF1_entity.resistances =
    {
      { type = "fire",      decrease = 50,  percent = 100 },
      { type = "physical",  decrease = 10,  percent = 55 },
      { type = "impact",    decrease = 47,  percent = 80 },
      { type = "explosion", decrease = 12,  percent = 68 },
      { type = "acid",      decrease =  2,  percent = 70 },
      { type = "laser",     decrease =  5,  percent = 20 },
      { type = "electric",  decrease =  5,  percent = 20 }
    }
tankF1_entity.guns = { "tank-flamethrower", "tank-machine-gun" }
tankF1_entity.equipment_grid = "Schall-tank-F-mk1-equipment-grid"
data.raw["item-with-entity-data"]["Schall-tank-F-mk1"].equipment_grid = tankF1_entity.equipment_grid
for _, layer in pairs(tankF1_entity.animation.layers) do
  layer.tint = {r=1.0, g=0.4, b=0.0, a=1}
  -- layer.tint = {r=1.0, g=0.6, b=0.6, a=1}
  if (layer.hr_version) then
    layer.hr_version.tint = {r=1.0, g=0.4, b=0.0, a=1}
    -- layer.hr_version.tint = {r=1.0, g=0.6, b=0.6, a=1}
  end
end


local htRA1_entity = table.deepcopy(tankM1_entity)
htRA1_entity.name = "Schall-ht-RA-mk1"
htRA1_entity.icons = data.raw["item-with-entity-data"]["Schall-ht-RA-mk1"].icons
htRA1_entity.minable = {mining_time = 0.5, result = "Schall-ht-RA-mk1"}
htRA1_entity.resistances =
    {
      { type = "fire",      decrease = 10,  percent = 45 },
      { type = "physical",  decrease =  0,  percent = 45 },
      { type = "impact",    decrease = 32,  percent = 60 },
      { type = "explosion", decrease = 12,  percent = 58 },
      { type = "acid",      decrease =  2,  percent = 60 },
      { type = "laser",     decrease =  5,  percent = 20 },
      { type = "electric",  decrease =  5,  percent = 20 }
    }
htRA1_entity.weight = 40000 --20000
htRA1_entity.guns = { "Schall-tactical-missile-launcher", "Schall-multiple-rocket-launcher", "tank-machine-gun-single" }
htRA1_entity.equipment_grid = "Schall-ht-RA-mk1-equipment-grid"
data.raw["item-with-entity-data"]["Schall-ht-RA-mk1"].equipment_grid = htRA1_entity.equipment_grid
for _, layer in pairs(htRA1_entity.animation.layers) do
  layer.tint = {r=0.8, g=0.0, b=0.0, a=1}
  -- layer.tint = {r=0.4, g=1.0, b=0.4, a=1}
  if (layer.hr_version) then
    layer.hr_version.tint = {r=0.8, g=0.0, b=0.0, a=1}
    -- layer.hr_version.tint = {r=0.4, g=1.0, b=0.4, a=1}
  end
end



-- Tanks MK2 series
local tankL2_entity = table.deepcopy(tankL_entity) --table.deepcopy(data.raw.car.tank)
tankL2_entity.name = "Schall-tank-L-mk2"
tankL2_entity.icons = data.raw["item-with-entity-data"]["Schall-tank-L-mk2"].icons --tankL_item.icons
tankL2_entity.minable = {mining_time = 0.5, result = "Schall-tank-L-mk2"}
tankL2_entity.max_health = tankL_entity.max_health * mul_T2_max_health
tankL2_entity.resistances =
    {
      { type = "fire",      decrease = 10,  percent = 60 },
      { type = "physical",  decrease = 10,  percent = 50 },
      { type = "impact",    decrease = 45,  percent = 70 },
      { type = "explosion", decrease = 15,  percent = 76 },
      { type = "acid",      decrease =  5,  percent = 60 },
      { type = "laser",     decrease = 10,  percent = 40 },
      { type = "electric",  decrease = 10,  percent = 40 }
    }
tankL2_entity.braking_power = base_L_braking_power*mul_T2_power.."kW"
tankL2_entity.consumption = base_L_consumption*mul_T2_power.."kW"
tankL2_entity.inventory_size = T2_inventory_size
-- tankL2_entity.guns = { "tank-autocannon", "tank-machine-gun-single" }
tankL2_entity.equipment_grid = "Schall-tank-L-mk2-equipment-grid"
data.raw["item-with-entity-data"]["Schall-tank-L-mk2"].equipment_grid = tankL2_entity.equipment_grid


local tankM2_entity = table.deepcopy(tankM_entity)
tankM2_entity.name = "Schall-tank-M-mk2"
tankM2_entity.icons = data.raw["item-with-entity-data"]["Schall-tank-M-mk2"].icons --tankM_item.icons
tankM2_entity.minable = {mining_time = 0.5, result = "Schall-tank-M-mk2"}
tankM2_entity.max_health = tankM_entity.max_health * mul_T2_max_health
tankM2_entity.resistances =
    {
      { type = "fire",      decrease = 15,  percent = 70 },
      { type = "physical",  decrease = 15,  percent = 60 },
      { type = "impact",    decrease = 55,  percent = 80 },
      { type = "explosion", decrease = 20,  percent = 86 },
      { type = "acid",      decrease =  5,  percent = 70 },
      { type = "laser",     decrease = 10,  percent = 40 },
      { type = "electric",  decrease = 10,  percent = 40 }
    }
tankM2_entity.braking_power = base_M_braking_power*mul_T2_power.."kW"
tankM2_entity.consumption = base_M_consumption*mul_T2_power.."kW"
tankM2_entity.inventory_size = T2_inventory_size
-- tankM2_entity.guns = { "tank-cannon", "tank-machine-gun" }
tankM2_entity.equipment_grid = "Schall-tank-M-mk2-equipment-grid"
data.raw["item-with-entity-data"]["Schall-tank-M-mk2"].equipment_grid = tankM2_entity.equipment_grid


local tankH2_entity = table.deepcopy(tankH_entity)
tankH2_entity.name = "Schall-tank-H-mk2"
tankH2_entity.icons = data.raw["item-with-entity-data"]["Schall-tank-H-mk2"].icons --tankH_item.icons
tankH2_entity.minable = {mining_time = 0.5, result = "Schall-tank-H-mk2"}
tankH2_entity.max_health = tankH_entity.max_health * mul_T2_max_health
tankH2_entity.resistances =
    {
      { type = "fire",      decrease = 15,  percent = 70 },
      { type = "physical",  decrease = 18,  percent = 65 },
      { type = "impact",    decrease = 60,  percent = 80 },
      { type = "explosion", decrease = 23,  percent = 91 },
      { type = "acid",      decrease =  8,  percent = 70 },
      { type = "laser",     decrease = 10,  percent = 40 },
      { type = "electric",  decrease = 10,  percent = 40 }
    }
tankH2_entity.braking_power = base_H_braking_power*mul_T2_power.."kW"
tankH2_entity.consumption = base_H_consumption*mul_T2_power.."kW"
tankH2_entity.inventory_size = T2_inventory_size
-- tankH2_entity.guns = { "tank-cannon-barrel1", "tank-machine-gun" }
tankH2_entity.equipment_grid = "Schall-tank-H-mk2-equipment-grid"
data.raw["item-with-entity-data"]["Schall-tank-H-mk2"].equipment_grid = tankH2_entity.equipment_grid


local tankSH2_entity = table.deepcopy(tankSH_entity)
tankSH2_entity.name = "Schall-tank-SH-mk2"
tankSH2_entity.icons = data.raw["item-with-entity-data"]["Schall-tank-SH-mk2"].icons --tankSH_item.icons
tankSH2_entity.minable = {mining_time = 0.5, result = "Schall-tank-SH-mk2"}
tankSH2_entity.max_health = tankSH_entity.max_health * mul_T2_max_health
tankSH2_entity.resistances =
    {
      { type = "fire",      decrease = 15,  percent = 70 },
      { type = "physical",  decrease = 20,  percent = 70 },
      { type = "impact",    decrease = 65,  percent = 80 },
      { type = "explosion", decrease = 25,  percent = 95 },
      { type = "acid",      decrease = 10,  percent = 70 },
      { type = "laser",     decrease = 10,  percent = 40 },
      { type = "electric",  decrease = 10,  percent = 40 }
    }
tankSH2_entity.braking_power = base_SH_braking_power*mul_T2_power.."kW"
tankSH2_entity.consumption = base_SH_consumption*mul_T2_power.."kW"
tankSH2_entity.inventory_size = T2_inventory_size
-- tankSH2_entity.guns = { "tank-cannon-barrel2", "tank-machine-gun" }
tankSH2_entity.equipment_grid = "Schall-tank-SH-mk2-equipment-grid"
data.raw["item-with-entity-data"]["Schall-tank-SH-mk2"].equipment_grid = tankSH2_entity.equipment_grid


local tankF2_entity = table.deepcopy(tankM2_entity)
tankF2_entity.name = "Schall-tank-F-mk2"
tankF2_entity.icons = data.raw["item-with-entity-data"]["Schall-tank-F-mk2"].icons --tankM_item.icons
tankF2_entity.minable = {mining_time = 0.5, result = "Schall-tank-F-mk2"}
tankF2_entity.resistances =
    {
      { type = "fire",      decrease = 50,  percent = 100 },
      { type = "physical",  decrease = 10,  percent = 60 },
      { type = "impact",    decrease = 50,  percent = 80 },
      { type = "explosion", decrease = 15,  percent = 76 },
      { type = "acid",      decrease =  5,  percent = 70 },
      { type = "laser",     decrease = 10,  percent = 40 },
      { type = "electric",  decrease = 10,  percent = 40 }
    }
tankF2_entity.guns = { "tank-flamethrower", "tank-machine-gun" }
tankF2_entity.equipment_grid = "Schall-tank-F-mk2-equipment-grid"
data.raw["item-with-entity-data"]["Schall-tank-F-mk2"].equipment_grid = tankF2_entity.equipment_grid
for _, layer in pairs(tankF2_entity.animation.layers) do
  layer.tint = {r=1.0, g=0.4, b=0.0, a=1}
  -- layer.tint = {r=1.0, g=0.6, b=0.6, a=1}
  if (layer.hr_version) then
    layer.hr_version.tint = {r=1.0, g=0.4, b=0.0, a=1}
    -- layer.hr_version.tint = {r=1.0, g=0.6, b=0.6, a=1}
  end
end


local htRA2_entity = table.deepcopy(tankM2_entity)
htRA2_entity.name = "Schall-ht-RA-mk2"
htRA2_entity.icons = data.raw["item-with-entity-data"]["Schall-ht-RA-mk2"].icons
htRA2_entity.minable = {mining_time = 0.5, result = "Schall-ht-RA-mk2"}
htRA2_entity.resistances =
    {
      { type = "fire",      decrease = 10,  percent = 50 },
      { type = "physical",  decrease =  0,  percent = 50 },
      { type = "impact",    decrease = 35,  percent = 60 },
      { type = "explosion", decrease = 15,  percent = 66 },
      { type = "acid",      decrease =  5,  percent = 60 },
      { type = "laser",     decrease = 10,  percent = 40 },
      { type = "electric",  decrease = 10,  percent = 40 }
    }
htRA2_entity.weight = 40000 --20000
htRA2_entity.guns = { "Schall-tactical-missile-launcher", "Schall-multiple-rocket-launcher", "tank-machine-gun-single" }
htRA2_entity.equipment_grid = "Schall-ht-RA-mk2-equipment-grid"
data.raw["item-with-entity-data"]["Schall-ht-RA-mk2"].equipment_grid = htRA2_entity.equipment_grid
for _, layer in pairs(htRA2_entity.animation.layers) do
  layer.tint = {r=0.8, g=0.0, b=0.0, a=1}
  -- layer.tint = {r=0.4, g=1.0, b=0.4, a=1}
  if (layer.hr_version) then
    layer.hr_version.tint = {r=0.8, g=0.0, b=0.0, a=1}
    -- layer.hr_version.tint = {r=0.4, g=1.0, b=0.4, a=1}
  end
end



data:extend{
  tankL_entity,
  tankM_entity,
  tankH_entity,
  tankSH_entity,
  tankF_entity,
  htRA_entity,
  tankL1_entity,
  tankM1_entity,
  tankH1_entity,
  tankSH1_entity,
  tankF1_entity,
  htRA1_entity,
  tankL2_entity,
  tankM2_entity,
  tankH2_entity,
  tankSH2_entity,
  tankF2_entity,
  htRA2_entity,
}
