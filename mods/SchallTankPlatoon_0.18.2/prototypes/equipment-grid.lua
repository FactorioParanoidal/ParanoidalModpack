local modw = {
  L  = -1,
  M  =  0,
  H  =  1,
  SH =  1,
  F  =  0,
  RA =  0,
}
local modh = {
  L  = -1,
  M  =  0,
  H  =  0,
  SH =  1,
  F  =  0,
  RA =  0,
}

local function get_tank_gridw(gridori, tankcls)
  local rgridw = math.max(gridori[1] + modw[tankcls], 0)
  return rgridw
end

local function get_tank_gridh(gridori, tankcls)
  local rgridh = math.max(gridori[2] + modh[tankcls], 0)
  return rgridh
end


-- Vehicle Grid
local tankT0_gridw, tankT0_gridh = string.match(settings.startup["tankplatoon-tank-t0-grid"].value, "(%d+)x(%d+)")
local tankT1_gridw, tankT1_gridh = string.match(settings.startup["tankplatoon-tank-t1-grid"].value, "(%d+)x(%d+)")
local tankT2_gridw, tankT2_gridh = string.match(settings.startup["tankplatoon-tank-t2-grid"].value, "(%d+)x(%d+)")
tankT0_gridw = tankT0_gridw or 5
tankT0_gridh = tankT0_gridh or 4
tankT1_gridw = tankT1_gridw or 7
tankT1_gridh = tankT1_gridh or 7
tankT2_gridw = tankT2_gridw or 10
tankT2_gridh = tankT2_gridh or 10
local tank_grid = {
  [0] = {tankT0_gridw, tankT0_gridh},
  [1] = {tankT1_gridw, tankT1_gridh},
  [2] = {tankT2_gridw, tankT2_gridh},
}


data:extend(
{
  {
    type = "equipment-grid",
    name = "Schall-tank-L-equipment-grid",
    width = get_tank_gridw(tank_grid[0], "L"),
    height = get_tank_gridh(tank_grid[0], "L"),
    equipment_categories = {"armor", "vehicle", "armoured-vehicle", "tank"}
  },
  {
    type = "equipment-grid",
    name = "Schall-tank-M-equipment-grid",
    width = get_tank_gridw(tank_grid[0], "M"),
    height = get_tank_gridh(tank_grid[0], "M"),
    equipment_categories = {"armor", "vehicle", "armoured-vehicle", "tank", "tank-M"}
  },
  {
    type = "equipment-grid",
    name = "Schall-tank-H-equipment-grid",
    width = get_tank_gridw(tank_grid[0], "H"),
    height = get_tank_gridh(tank_grid[0], "H"),
    equipment_categories = {"armor", "vehicle", "armoured-vehicle", "tank", "tank-M", "tank-H"}
  },
  {
    type = "equipment-grid",
    name = "Schall-tank-SH-equipment-grid",
    width = get_tank_gridw(tank_grid[0], "SH"),
    height = get_tank_gridh(tank_grid[0], "SH"),
    equipment_categories = {"armor", "vehicle", "armoured-vehicle", "tank", "tank-M", "tank-H", "tank-SH"}
  },
  {
    type = "equipment-grid",
    name = "Schall-tank-L-mk1-equipment-grid",
    width = get_tank_gridw(tank_grid[1], "L"),
    height = get_tank_gridh(tank_grid[1], "L"),
    equipment_categories = {"armor", "vehicle", "armoured-vehicle", "tank"}
  },
  {
    type = "equipment-grid",
    name = "Schall-tank-M-mk1-equipment-grid",
    width = get_tank_gridw(tank_grid[1], "M"),
    height = get_tank_gridh(tank_grid[1], "M"),
    equipment_categories = {"armor", "vehicle", "armoured-vehicle", "tank", "tank-M"}
  },
  {
    type = "equipment-grid",
    name = "Schall-tank-H-mk1-equipment-grid",
    width = get_tank_gridw(tank_grid[1], "H"),
    height = get_tank_gridh(tank_grid[1], "H"),
    equipment_categories = {"armor", "vehicle", "armoured-vehicle", "tank", "tank-M", "tank-H"}
  },
  {
    type = "equipment-grid",
    name = "Schall-tank-SH-mk1-equipment-grid",
    width = get_tank_gridw(tank_grid[1], "SH"),
    height = get_tank_gridh(tank_grid[1], "SH"),
    equipment_categories = {"armor", "vehicle", "armoured-vehicle", "tank", "tank-M", "tank-H", "tank-SH"}
  },
  {
    type = "equipment-grid",
    name = "Schall-tank-L-mk2-equipment-grid",
    width = get_tank_gridw(tank_grid[2], "L"),
    height = get_tank_gridh(tank_grid[2], "L"),
    equipment_categories = {"armor", "vehicle", "armoured-vehicle", "tank"}
  },
  {
    type = "equipment-grid",
    name = "Schall-tank-M-mk2-equipment-grid",
    width = get_tank_gridw(tank_grid[2], "M"),
    height = get_tank_gridh(tank_grid[2], "M"),
    equipment_categories = {"armor", "vehicle", "armoured-vehicle", "tank", "tank-M"}
  },
  {
    type = "equipment-grid",
    name = "Schall-tank-H-mk2-equipment-grid",
    width = get_tank_gridw(tank_grid[2], "H"),
    height = get_tank_gridh(tank_grid[2], "H"),
    equipment_categories = {"armor", "vehicle", "armoured-vehicle", "tank", "tank-M", "tank-H"}
  },
  {
    type = "equipment-grid",
    name = "Schall-tank-SH-mk2-equipment-grid",
    width = get_tank_gridw(tank_grid[2], "SH"),
    height = get_tank_gridh(tank_grid[2], "SH"),
    equipment_categories = {"armor", "vehicle", "armoured-vehicle", "tank", "tank-M", "tank-H", "tank-SH"}
  },
  {
    type = "equipment-grid",
    name = "Schall-tank-F-equipment-grid",
    width = get_tank_gridw(tank_grid[0], "F"),
    height = get_tank_gridh(tank_grid[0], "F"),
    equipment_categories = {"armor", "vehicle", "armoured-vehicle", "tank", "tank-F"}
  },
  {
    type = "equipment-grid",
    name = "Schall-tank-F-mk1-equipment-grid",
    width = get_tank_gridw(tank_grid[1], "F"),
    height = get_tank_gridh(tank_grid[1], "F"),
    equipment_categories = {"armor", "vehicle", "armoured-vehicle", "tank", "tank-F"}
  },
  {
    type = "equipment-grid",
    name = "Schall-tank-F-mk2-equipment-grid",
    width = get_tank_gridw(tank_grid[2], "F"),
    height = get_tank_gridh(tank_grid[2], "F"),
    equipment_categories = {"armor", "vehicle", "armoured-vehicle", "tank", "tank-F"}
  },
  {
    type = "equipment-grid",
    name = "Schall-ht-RA-equipment-grid",
    width = get_tank_gridw(tank_grid[0], "RA"),
    height = get_tank_gridh(tank_grid[0], "RA"),
    equipment_categories = {"armor", "vehicle", "armoured-vehicle", "tank", "artillery-rocket"}
  },
  {
    type = "equipment-grid",
    name = "Schall-ht-RA-mk1-equipment-grid",
    width = get_tank_gridw(tank_grid[1], "RA"),
    height = get_tank_gridh(tank_grid[1], "RA"),
    equipment_categories = {"armor", "vehicle", "armoured-vehicle", "tank", "artillery-rocket"}
  },
  {
    type = "equipment-grid",
    name = "Schall-ht-RA-mk2-equipment-grid",
    width = get_tank_gridw(tank_grid[2], "RA"),
    height = get_tank_gridh(tank_grid[2], "RA"),
    equipment_categories = {"armor", "vehicle", "armoured-vehicle", "tank", "artillery-rocket"}
  },
})
