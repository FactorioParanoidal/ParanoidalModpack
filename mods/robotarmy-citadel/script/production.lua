-- Droid production. Every foundry (and the core) makes one droid per cycle by script: no unit
-- spawner prototype, so the engine runs no spawner logic and the citadel controls the kinds, the
-- armour mark, the speed and the limit exactly. The heartbeat looks at a few foundries per second;
-- a droid joins the squad that is gathering, or stays near its foundry as the garrison.
local S = require("lib.shared")
local U = require("script.util")
local L = require("script.layout")
local bus = require("script.bus")
local forces = require("script.forces")

local P = {}

--- Droid kinds of each foundry ({kind, weight}) and its cycle in ticks at speed 1.
P.KINDS = {
  core = {cycle = 1800, kinds = {{"droid-rifle", 3}, {"droid-scout", 1}}},
  light = {cycle = 900, kinds = {{"droid-rifle", 4}, {"droid-scout", 1}, {"droid-laser", 1}}},
  assault = {cycle = 1200, kinds = {{"droid-smg", 3}, {"droid-heavy", 1}}},
  fire = {cycle = 1500, kinds = {{"droid-flame", 2}, {"droid-rocket", 2}, {"droid-poison", 1}}},
  sniper = {cycle = 1500, kinds = {{"droid-sniper", 3}, {"droid-scout", 1}}},
  energy = {cycle = 1500, kinds = {{"droid-laser", 2}, {"droid-tesla", 2}}},
  air = {cycle = 1800, kinds = {{"defender-unit", 2}, {"distractor-unit", 1}, {"destroyer-unit", 1}}},
  terminator = {cycle = 3600, kinds = {{"terminator", 2}, {"terminator-plasma", 1}}},
}
local MIN_CYCLE = 120
local PER_BEAT = 30          -- foundries looked at per heartbeat
local DEPOT_BONUS = 0.08     -- production speed per supply depot
local RECYCLE_SHARE = 0.05   -- salvage per droid lost, per recycler
local RECYCLE_MAX = 0.5      -- salvage per droid lost at most

---------------------------------------------------------------------------------------------------
-- Living droids: array of {e = entity, n = unit_number} + index (removal by swap; a cursor walks
-- the array). The unit number is kept because a destroyed entity cannot tell it any more.
---------------------------------------------------------------------------------------------------
local function swap_remove(list, index, i)
  local last = #list
  local moved = list[last]
  index[list[i].n] = nil
  list[i] = moved
  list[last] = nil
  if i ~= last then index[moved.n] = i end
end

function P.add_unit(c, e)
  local u = c.units
  if u.index[e.unit_number] then return end
  u.list[#u.list + 1] = {e = e, n = e.unit_number}
  u.index[e.unit_number] = #u.list
end

function P.remove_unit(c, unit_number)
  local u = c.units
  local i = u.index[unit_number]
  if not i then return false end
  swap_remove(u.list, u.index, i)
  return true
end

function P.unit_count(c)
  return #c.units.list
end

--- Checks `n` droids: forgets destroyed ones (removed by other scripts without a death event) and
--- calls fn(entity) for the others.
function P.sweep_units(c, n, fn)
  local u = c.units
  local i = c.unit_cursor or 1
  for _ = 1, n do
    local count = #u.list
    if count == 0 then break end
    if i > count then i = 1 end
    local r = u.list[i]
    if r.e.valid then
      fn(r.e)
      i = i + 1
    else
      swap_remove(u.list, u.index, i) -- the moved entry is checked next
    end
  end
  c.unit_cursor = i
end

---------------------------------------------------------------------------------------------------
-- Foundries: array of {e, n, m = chunk key, kind, next} + index.
---------------------------------------------------------------------------------------------------
function P.add_foundry(c, e, module_key, kind)
  if c.foundry_index[e.unit_number] then return end
  c.foundries[#c.foundries + 1] = {e = e, n = e.unit_number, m = module_key, kind = kind,
    next = game.tick + 60 + U.random_int(c, 600)}
  c.foundry_index[e.unit_number] = #c.foundries
end

function P.remove_foundry(c, unit_number)
  local i = c.foundry_index[unit_number]
  if i then swap_remove(c.foundries, c.foundry_index, i) end
end

--- Foundries that still stand (the core does not count: it is not a production building).
function P.foundry_count(c)
  local n = 0
  for _, f in pairs(c.foundries) do
    if f.kind ~= "core" and f.e.valid then n = n + 1 end
  end
  return n
end

--- Production speed: supply depots and, after the acceleration threshold, +x per hour.
function P.speed(c, cfg)
  local speed = 1 + DEPOT_BONUS * (c.alive["supply-depot"] or 0)
  if c.accel_since then
    speed = speed * (1 + cfg.accel_per_hour * (game.tick - c.accel_since) / 216000)
  end
  return speed
end

local unit_exists = {}
local function exists(name)
  local v = unit_exists[name]
  if v == nil then
    v = prototypes.entity[name] ~= nil
    unit_exists[name] = v
  end
  return v
end

--- Name of the droid a foundry makes now (armour mark and focus of the citadel).
local function droid_name(c, kind)
  local mark = math.min(c.upgrades.armor or 0, S.marks)
  local name = S.unit_name(kind, mark, c.focus)
  if exists(name) then return name end
  name = S.unit_name(kind, 0)
  return exists(name) and name or nil
end

local function make(c, f, surface)
  local spec = P.KINDS[f.kind]
  local kind = spec and U.pick(c, spec.kinds)
  local name = kind and droid_name(c, kind)
  if not name then return nil end
  local p = f.e.position
  local position = surface.find_non_colliding_position(name, {p.x, p.y + 4}, 10, 0.5)
  if not position then return nil end
  local e = surface.create_entity({name = name, position = position, force = forces.get()})
  if not e then return nil end
  P.add_unit(c, e)
  c.stats.produced = c.stats.produced + 1
  bus.emit("droid_made", c, e)
  return e
end

--- One heartbeat of production.
function P.step(c, cfg, surface)
  local list = c.foundries
  local n = #list
  if n == 0 then return end
  local now = game.tick
  local speed = P.speed(c, cfg)
  local room = cfg.unit_limit - P.unit_count(c)
  local i = c.foundry_cursor or 1
  for _ = 1, math.min(PER_BEAT, n) do
    if #list == 0 then break end
    if i > #list then i = 1 end
    local f = list[i]
    if not f.e.valid then
      swap_remove(list, c.foundry_index, i) -- the moved foundry is looked at next
    else
      if f.next <= now and room > 0 then
        if make(c, f, surface) then room = room - 1 end
        f.next = now + math.max(MIN_CYCLE, math.floor((P.KINDS[f.kind] or P.KINDS.core).cycle / speed))
      end
      i = i + 1
    end
  end
  c.foundry_cursor = i
  -- recycled parts: a free droid from a random foundry
  while c.salvage >= 1 and room > 0 and #list > 0 do
    c.salvage = c.salvage - 1
    local f = list[U.random_int(c, #list)]
    if f.e.valid and make(c, f, surface) then room = room - 1 end
  end
end

--- A droid of the citadel was lost: salvage for the recyclers.
function P.on_lost(c)
  local recyclers = c.alive.recycler or 0
  if recyclers > 0 then c.salvage = c.salvage + math.min(RECYCLE_MAX, RECYCLE_SHARE * recyclers) end
end

--- Where a module's droids gather (the plaza).
function P.muster_of(m)
  return {x = m.x * 32 + L.MUSTER.x, y = m.y * 32 + L.MUSTER.y}
end

return P
