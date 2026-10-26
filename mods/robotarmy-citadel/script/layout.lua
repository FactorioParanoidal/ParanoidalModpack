-- Plans of the module types inside one chunk (tiles 0..31 from the chunk's top-left corner).
--
-- Every module: walls and gates on its outer edges (computed from the neighbours, script/builder.lua),
-- a road cross (tiles 15-16 both ways) that continues through the neighbour modules, a plaza
-- (12..19) with the hub pylon, four lamps and the place of the shield tower; four quadrants
-- (2..11 / 20..29) for the buildings; the ring 1 / 30 and the strips beside the roads stay free
-- for the droids to walk. Entries are {name, x, y}: the top-left tile of the building.
local S = require("lib.shared")
local E = S.entity

local L = {}

L.ROAD1, L.ROAD2 = 15, 16
L.PLAZA1, L.PLAZA2 = 12, 19
L.GATE1, L.GATE2 = 14, 17
L.HUB = {E.pylon, 15, 15}
L.TOWER = {E.shield_tower, 13, 13}
L.LAMPS = {{E.lamp, 12, 12}, {E.lamp, 19, 12}, {E.lamp, 12, 19}, {E.lamp, 19, 19}}
--- Where the squads gather (relative position) and where the foundries put their droids.
L.MUSTER = {x = 18, y = 18}

local function crates(list, x, y, w, h)
  for i = 0, w - 1 do
    for j = 0, h - 1 do list[#list + 1] = {E.crate, x + i, y + j} end
  end
end

--- Towers in the four corners: `a` north-west and south-east, `b` north-east and south-west.
local function corners(list, a, b)
  list[#list + 1] = {a, 2, 2}
  list[#list + 1] = {a, 28, 28}
  list[#list + 1] = {b, 28, 2}
  list[#list + 1] = {b, 2, 28}
end

local function add(list, entries)
  for _, e in pairs(entries) do list[#list + 1] = e end
  return list
end

local plans = {}

plans.core = function(l)
  add(l, {{E.core, 4, 4}, {E.reactor, 21, 4}, {E.accumulator, 25, 4}, {E.accumulator, 25, 7},
    {E.laser_tower, 22, 9}, {E.assembler, 4, 24}, {E.assembler, 8, 24}, {E.assembler, 21, 21},
    {E.assembler, 25, 21}, {E.gun_tower, 22, 25}})
  crates(l, 3, 21, 6, 2)
  corners(l, E.gun_tower, E.laser_tower)
end

local function foundry(name)
  return function(l)
    add(l, {{name, 4, 4}, {E.assembler, 21, 4}, {E.assembler, 25, 4}, {E.assembler, 4, 21},
      {E.assembler, 8, 21}, {E.assembler, 21, 21}, {E.assembler, 25, 21}, {E.gun_tower, 23, 25}})
    crates(l, 21, 8, 7, 2)
    crates(l, 4, 25, 7, 2)
    corners(l, E.gun_tower, E.laser_tower)
  end
end
for _, f in pairs(S.foundries) do plans["foundry-" .. f] = foundry(E["foundry_" .. f]) end

plans["power-plant"] = function(l)
  add(l, {{E.reactor, 3, 4}, {E.reactor, 7, 4}, {E.turbine, 21, 4}, {E.turbine, 21, 8}})
  for _, x in pairs({3, 6, 9}) do
    add(l, {{E.accumulator, x, 21}, {E.accumulator, x, 24}})
  end
  for _, p in pairs({{21, 21}, {24, 21}, {21, 24}, {24, 24}}) do add(l, {{E.accumulator, p[1], p[2]}}) end
  corners(l, E.gun_tower, E.laser_tower)
end

plans.bastion = function(l)
  for _, p in pairs({{2, 2}, {6, 2}, {2, 6}, {28, 2}, {24, 2}, {28, 6}, {2, 28}, {2, 24}, {6, 28},
    {28, 28}, {24, 28}, {28, 24}}) do
    add(l, {{E.gun_tower, p[1], p[2]}})
  end
  for _, p in pairs({{8, 8}, {22, 8}, {8, 22}, {22, 22}}) do add(l, {{E.laser_tower, p[1], p[2]}}) end
  crates(l, 9, 3, 2, 2)
  crates(l, 21, 26, 2, 2)
end

plans["turret-nest"] = function(l)
  for _, p in pairs({{4, 4}, {8, 4}, {4, 8}, {8, 8}, {21, 21}, {25, 21}, {21, 25}, {25, 25}}) do
    add(l, {{E.laser_tower, p[1], p[2]}})
  end
  for _, p in pairs({{22, 4}, {26, 8}, {4, 22}, {8, 26}}) do add(l, {{E.tesla_tower, p[1], p[2]}}) end
  corners(l, E.gun_tower, E.gun_tower)
end

plans["mortar-battery"] = function(l)
  for _, p in pairs({{4, 4}, {8, 8}, {22, 4}, {26, 8}, {4, 22}, {8, 26}, {22, 22}, {25, 25}}) do
    add(l, {{E.mortar_tower, p[1], p[2]}})
  end
  corners(l, E.gun_tower, E.laser_tower)
  crates(l, 8, 3, 3, 2)
end

plans.minefield = function(l)
  add(l, {{E.mine_control, 5, 5}})
  for _, x in pairs({21, 23, 25}) do
    for _, y in pairs({5, 7, 9}) do add(l, {{E.land_mine, x, y}}) end
  end
  for _, x in pairs({4, 6, 8, 10}) do
    for _, y in pairs({21, 23, 25}) do add(l, {{E.land_mine, x, y}}) end
  end
  for _, x in pairs({21, 23, 25}) do
    for _, y in pairs({21, 23, 25}) do add(l, {{E.land_mine, x, y}}) end
  end
  for _, p in pairs({{9, 13}, {11, 9}, {13, 22}, {22, 13}, {13, 26}, {26, 13}}) do add(l, {{E.land_mine, p[1], p[2]}}) end
  corners(l, E.gun_tower, E.gun_tower)
end

plans["repair-dock"] = function(l)
  add(l, {{E.repair_bay, 4, 4}, {E.repair_bay, 8, 4}, {E.repair_bay, 4, 8}, {E.assembler, 21, 8},
    {E.assembler, 25, 8}, {E.accumulator, 4, 22}, {E.accumulator, 7, 22}})
  crates(l, 21, 4, 7, 2)
  crates(l, 21, 22, 6, 3)
  corners(l, E.gun_tower, E.laser_tower)
end

plans["supply-depot"] = function(l)
  add(l, {{E.depot, 4, 4}, {E.depot, 21, 21}})
  crates(l, 21, 4, 7, 3)
  crates(l, 4, 21, 7, 3)
  corners(l, E.gun_tower, E.laser_tower)
end

plans.recycler = function(l)
  add(l, {{E.recycler, 4, 4}, {E.recycler, 8, 8}, {E.assembler, 21, 21}, {E.assembler, 25, 21}})
  crates(l, 21, 4, 7, 4)
  crates(l, 4, 22, 6, 2)
  corners(l, E.gun_tower, E.laser_tower)
end

plans.radar = function(l)
  add(l, {{E.radar, 5, 5}, {E.accumulator, 22, 4}, {E.accumulator, 25, 4}})
  crates(l, 21, 22, 6, 2)
  corners(l, E.gun_tower, E.laser_tower)
end

plans.jammer = function(l)
  add(l, {{E.jammer, 4, 4}, {E.accumulator, 22, 22}, {E.accumulator, 25, 22}})
  crates(l, 4, 22, 5, 2)
  corners(l, E.gun_tower, E.laser_tower)
end

plans.relay = function(l)
  add(l, {{E.relay, 5, 5}, {E.relay, 24, 24}, {E.accumulator, 22, 5}})
  crates(l, 4, 22, 5, 2)
  corners(l, E.gun_tower, E.laser_tower)
end

plans.armory = function(l)
  add(l, {{E.armory, 4, 4}, {E.assembler, 21, 4}, {E.assembler, 25, 4}, {E.assembler, 21, 21}})
  crates(l, 4, 21, 7, 2)
  corners(l, E.gun_tower, E.laser_tower)
end

plans.arsenal = function(l)
  add(l, {{E.arsenal, 4, 4}, {E.arsenal, 8, 4}, {E.assembler, 4, 21}, {E.assembler, 8, 21}})
  crates(l, 21, 4, 7, 2)
  corners(l, E.gun_tower, E.laser_tower)
end

plans.targeting = function(l)
  add(l, {{E.targeting, 4, 4}, {E.targeting, 8, 8}, {E.accumulator, 22, 22}})
  crates(l, 21, 4, 6, 2)
  corners(l, E.gun_tower, E.laser_tower)
end

plans["ai-core"] = function(l)
  add(l, {{E.ai_core, 4, 4}, {E.accumulator, 22, 4}, {E.accumulator, 25, 4}, {E.accumulator, 22, 7},
    {E.accumulator, 25, 7}})
  crates(l, 21, 22, 6, 2)
  corners(l, E.gun_tower, E.laser_tower)
end

plans["shield-amplifier"] = function(l)
  for _, p in pairs({{4, 4}, {7, 4}, {4, 7}, {7, 7}}) do add(l, {{E.shield_node, p[1], p[2]}}) end
  add(l, {{E.accumulator, 22, 22}, {E.accumulator, 25, 22}})
  corners(l, E.gun_tower, E.laser_tower)
end

plans["shield-regenerator"] = function(l)
  for _, p in pairs({{21, 21}, {24, 21}, {21, 24}, {24, 24}}) do add(l, {{E.shield_node, p[1], p[2]}}) end
  add(l, {{E.accumulator, 4, 4}, {E.accumulator, 7, 4}})
  corners(l, E.gun_tower, E.laser_tower)
end

L.plans = plans

--- Buildings of a module type (without walls and the shield tower), hub and lamps first.
function L.entries(module_type)
  local l = {L.HUB}
  add(l, L.LAMPS)
  local plan = plans[module_type]
  if plan then plan(l) end
  return l
end

--- Centre of an entry in map coordinates for a chunk.
function L.position(entry, cx, cy)
  local size = S.size[entry[1]] or {1, 1}
  return {x = cx * 32 + entry[2] + size[1] / 2, y = cy * 32 + entry[3] + size[2] / 2}
end

function L.is_road(x, y)
  return (x >= L.ROAD1 and x <= L.ROAD2) or (y >= L.ROAD1 and y <= L.ROAD2)
    or (x >= L.PLAZA1 and x <= L.PLAZA2 and y >= L.PLAZA1 and y <= L.PLAZA2)
end

--- Walls and gates a module needs: map tile key "x,y" (relative) -> "wall" | "gate-h" | "gate-v".
--- `has(dx, dy)` tells whether the neighbour chunk is a module. Outer edges get a wall with a gate
--- span where the road leaves; an inner corner (two module neighbours, the diagonal one missing) gets
--- one wall tile so the city has no diagonal gap.
function L.walls(has)
  local out = {}
  local function put(x, y, what) out[x * 32 + y] = what end
  local n, e, s, w = has(0, -1), has(1, 0), has(0, 1), has(-1, 0)
  for i = 0, 31 do
    local gate = i >= L.GATE1 and i <= L.GATE2
    if not n then put(i, 0, gate and "gate-h" or "wall") end
    if not s then put(i, 31, gate and "gate-h" or "wall") end
    if not w then put(0, i, gate and "gate-v" or "wall") end
    if not e then put(31, i, gate and "gate-v" or "wall") end
  end
  -- corners shared by two outer edges belong to a wall line, never a gate
  if n and e and not has(1, -1) then put(31, 0, "wall") end
  if s and e and not has(1, 1) then put(31, 31, "wall") end
  if s and w and not has(-1, 1) then put(0, 31, "wall") end
  if n and w and not has(-1, -1) then put(0, 0, "wall") end
  return out
end

return L
