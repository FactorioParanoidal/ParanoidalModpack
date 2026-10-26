-- Build queue of the citadel: every change of the city is a list of jobs worked off in small
-- portions every PERIOD ticks, so a new module "grows" for a few seconds instead of costing one
-- long tick. The handler is registered only while the queue has jobs (also after a load).
--
-- Jobs (storage.citadel.work, first in first out):
--   clear     strips of 8 rows: trees, rocks, cliffs, ruins and the biters' buildings go
--   tiles     strips of 8 rows: floor plating, the road cross and the plaza
--   place     the buildings of the plan, PLACE_PER_STEP at a time (occupied places are skipped)
--   walls     walls and gates of the given modules matched to their neighbours, one module per step
--   finish    the module works (bus "module_built")
--   demolish  removes the citadel buildings of a module except its walls (relocation of the core)
--   towers    shield towers in the given modules (after the shield threshold)
--   cascade   the defeated citadel blows up, module by module
local S = require("lib.shared")
local U = require("script.util")
local L = require("script.layout")
local M = require("script.modules")
local bus = require("script.bus")
local state = require("script.state")
local forces = require("script.forces")
local E = S.entity

local B = {}
B.PERIOD = 4
local PLACE_PER_STEP = 3
local CASCADE_PER_STEP = 10
local STRIP = 8

local registered = false
local step -- forward

local function set_handler(on)
  if on == registered then return end
  registered = on
  script.on_nth_tick(B.PERIOD, on and step or nil)
end

function B.queue(c, job)
  c.work[#c.work + 1] = job
  set_handler(true)
end

--- After a load: the handler follows the queue (storage is read-only here).
function B.on_load(c)
  registered = false
  if c and c.work and c.work[1] then
    registered = true
    script.on_nth_tick(B.PERIOD, step)
  end
end

function B.busy(c)
  return c.work[1] ~= nil
end

local RAISE = {[E.shield_tower] = true}
for _, t in pairs(M.towers) do RAISE[t] = true end
local QUIET = {[E.wall] = true, [E.gate] = true, [E.land_mine] = true, [E.crate] = true, [E.lamp] = true}

local function effect(surface, position)
  surface.create_entity({name = "big-explosion", position = position})
end

---------------------------------------------------------------------------------------------------
-- Job steps: return true when the job is done.
---------------------------------------------------------------------------------------------------
local run = {}

run.clear = function(c, job, surface)
  local m = c.modules[job.k]
  if not m then return true end
  local row = job.row or 0
  if row == 0 then surface.destroy_decoratives({area = U.area(m.x, m.y)}) end
  local x0, y0 = m.x * 32, m.y * 32
  local area = {{x0, y0 + row}, {x0 + 32, y0 + row + STRIP}}
  local list = {"neutral"}
  for _, name in pairs(forces.truce_names()) do list[#list + 1] = name end
  for _, e in pairs(surface.find_entities_filtered({area = area, force = list})) do
    if e.valid and e.type ~= "resource" and e.type ~= "character" then
      if e.type == "cliff" then
        e.destroy({do_cliff_correction = true})
      else
        local nest = e.type == "unit-spawner" or e.type == "turret"
        if nest then effect(surface, e.position) end
        -- other mods (Rampant) follow nests and units; trees, rocks and remnants need no event
        e.destroy({raise_destroy = nest or e.type == "unit"})
      end
    end
  end
  job.row = row + STRIP
  return job.row >= 32
end

run.tiles = function(c, job, surface)
  local m = c.modules[job.k]
  if not m then return true end
  local row = job.row or 0
  local tiles = {}
  local x0, y0 = m.x * 32, m.y * 32
  for y = row, row + STRIP - 1 do
    for x = 0, 31 do
      tiles[#tiles + 1] = {name = L.is_road(x, y) and S.tile_road or S.tile_floor, position = {x0 + x, y0 + y}}
    end
  end
  surface.set_tiles(tiles, true, false)
  job.row = row + STRIP
  return job.row >= 32
end

--- Moves loose things out of the footprint of a building to be placed: items on the ground (the
--- loot of a destroyed building lies where it stood, and a script placement does not pick it up)
--- and the citadel's own droids. Returns true if something was moved.
local function make_room(surface, name, position, force)
  local size = S.size[name] or {1, 1}
  local hw, hh = size[1] / 2, size[2] / 2
  local box = {{position.x - hw, position.y - hh}, {position.x + hw, position.y + hh}}
  local moved = false
  for _, e in pairs(surface.find_entities_filtered({area = box, type = {"item-entity", "unit"}})) do
    if e.valid and (e.type == "item-entity" or e.force == force) then
      local p = surface.find_non_colliding_position(e.name, {position.x, position.y + hh + 1.5}, 12, 0.5)
      if p and e.teleport(p) then moved = true end
    end
  end
  return moved
end

--- Places one building of a module and registers it (key buildings, hub).
local function place(c, m, surface, force, entry, keys)
  local name = entry[1]
  if not prototypes.entity[name] then return nil end
  local position = L.position(entry, m.x, m.y)
  local spec = {name = name, position = position, force = force}
  if not surface.can_place_entity(spec) then
    if not (make_room(surface, name, position, force) and surface.can_place_entity(spec)) then return nil end
  end
  local params = {
    name = name, position = position, force = force,
    raise_built = RAISE[name] or false,
    create_build_effect_smoke = not QUIET[name],
    spawn_decorations = false,
    move_stuck_players = true,
  }
  if name == E.pylon then params.auto_connect = false end -- the hubs are wired by script/citadel.lua
  local e = surface.create_entity(params)
  if not (e and e.valid) then return nil end
  if keys[name] then
    m.keys[e.unit_number] = e
    m.nkeys = m.nkeys + 1
    c.key_of[e.unit_number] = m.key
  end
  if name == E.pylon then m.hub = e end
  if name == E.shield_tower then
    m.tower = e
    if prototypes.item["repair-pack"] then e.insert({name = "repair-pack", count = 50}) end
  end
  return e
end

run.place = function(c, job, surface)
  local m = c.modules[job.k]
  if not m then return true end
  local force = forces.get()
  if not job.list then
    job.list = L.entries(m.type)
    if c.shields and prototypes.entity[E.shield_tower] then job.list[#job.list + 1] = L.TOWER end
    job.i = 1
    job.keys = {}
    for _, name in pairs(M.types[m.type].keys) do job.keys[name] = true end
  end
  for _ = 1, PLACE_PER_STEP do
    local entry = job.list[job.i]
    if not entry then break end
    job.i = job.i + 1
    if place(c, m, surface, force, entry, job.keys) then
      job.placed = (job.placed or 0) + 1
    elseif #(job.missed or {}) < 8 then
      job.missed = job.missed or {}
      job.missed[#job.missed + 1] = entry[1]
    end
  end
  if job.list[job.i] ~= nil then return false end
  -- what the last placement achieved (inspection, remote modules())
  m.planned, m.placed, m.missed = #job.list, job.placed or 0, job.missed
  return true
end

local GATE_DIR = {["gate-h"] = defines.direction.east, ["gate-v"] = defines.direction.north}

local function sync_walls(c, m, surface, force)
  local want = L.walls(function(dx, dy) return c.modules[U.key(m.x + dx, m.y + dy)] ~= nil end)
  local x0, y0 = m.x * 32, m.y * 32
  local have = {}
  for _, e in pairs(surface.find_entities_filtered({area = U.area(m.x, m.y), name = {E.wall, E.gate}, force = force})) do
    local rx, ry = math.floor(e.position.x) - x0, math.floor(e.position.y) - y0
    local k = rx * 32 + ry
    local what = want[k]
    local kind = e.name == E.wall and "wall" or (e.direction == defines.direction.north and "gate-v" or "gate-h")
    if what == kind and not have[k] then
      have[k] = true
    else
      e.destroy()
    end
  end
  for k, what in pairs(want) do
    if not have[k] then
      local rx, ry = math.floor(k / 32), k % 32
      local name = what == "wall" and E.wall or E.gate
      local position = {x0 + rx + 0.5, y0 + ry + 0.5}
      local direction = GATE_DIR[what]
      if surface.can_place_entity({name = name, position = position, direction = direction, force = force}) then
        surface.create_entity({name = name, position = position, direction = direction, force = force,
          spawn_decorations = false, move_stuck_players = true})
      end
    end
  end
end

run.walls = function(c, job, surface)
  job.i = job.i or 1
  local k = job.keys[job.i]
  if not k then return true end
  job.i = job.i + 1
  local m = c.modules[k]
  if m then sync_walls(c, m, surface, forces.get()) end
  return job.keys[job.i] == nil
end

run.finish = function(c, job)
  if c.modules[job.k] then bus.emit("module_built", c, job.k) end
  return true
end

run.rewire = function(c, job)
  if c.modules[job.k] then bus.emit("module_restored", c, job.k) end
  return true
end

run.demolish = function(c, job, surface)
  local m = c.modules[job.k]
  if not m then return true end
  local force = forces.get()
  local n = 0
  for _, e in pairs(surface.find_entities_filtered({area = U.area(m.x, m.y), force = force})) do
    if e.valid and e.name ~= E.wall and e.name ~= E.gate and e.type ~= "unit" then
      c.key_of[e.unit_number or 0] = nil
      e.destroy({raise_destroy = true})
      n = n + 1
    end
  end
  m.keys, m.nkeys, m.hub, m.tower = {}, 0, nil, nil
  return true
end

run.towers = function(c, job, surface)
  job.i = job.i or 1
  local force = forces.get()
  for _ = 1, PLACE_PER_STEP do
    local k = job.keys[job.i]
    if not k then return true end
    job.i = job.i + 1
    local m = c.modules[k]
    if m and m.built and not (m.tower and m.tower.valid) then place(c, m, surface, force, L.TOWER, {}) end
  end
  return job.keys[job.i] == nil
end

run.cascade = function(c, job, surface)
  local force = forces.get()
  if not job.list then
    job.i, job.list = 1, nil
    local k = job.keys[job.ki or 1]
    if not k then return true end
    job.ki = (job.ki or 1) + 1
    local x, y = U.unkey(k)
    job.list = surface.find_entities_filtered({area = U.area(x, y), force = force})
  end
  for _ = 1, CASCADE_PER_STEP do
    local e = job.list[job.i]
    if not e then
      job.list = nil
      return job.keys[job.ki] == nil
    end
    job.i = job.i + 1
    if e.valid then
      if e.type == "unit" or e.name == E.wall or e.name == E.gate or e.name == E.crate then e.destroy() else e.die() end
    end
  end
  return false
end

step = function()
  local c = state.get()
  if not c or not c.work[1] then
    set_handler(false)
    return
  end
  local job = c.work[1]
  local surface = state.surface(c)
  local done = (not surface) or run[job.t](c, job, surface)
  if done then
    table.remove(c.work, 1)
    if not c.work[1] then set_handler(false) end
  end
end

--- Puts back the missing buildings of a standing module (its hub first) and wires it again.
function B.restore_module(c, k)
  B.queue(c, {t = "place", k = k})
  B.queue(c, {t = "rewire", k = k})
end

--- Queues the whole construction of a module (also a rebuild of a ruined one).
function B.build_module(c, k, fresh)
  if fresh then
    B.queue(c, {t = "clear", k = k})
    B.queue(c, {t = "tiles", k = k})
  end
  local keys = {k}
  local m = c.modules[k]
  for _, d in pairs(U.NEIGHBOURS8) do
    local nk = U.key(m.x + d[1], m.y + d[2])
    if c.modules[nk] then keys[#keys + 1] = nk end
  end
  B.queue(c, {t = "walls", keys = keys})
  B.queue(c, {t = "place", k = k})
  B.queue(c, {t = "finish", k = k})
end

return B
