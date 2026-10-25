-- Bases for patrolling squads. Per force and surface: the set of chunks with buildings of the force
-- (anything built: machines, walls, rails, poles, pipes, belts ...; not units, vehicles, robots,
-- land mines, ghosts or effects). The set grows from the patrolling squads outwards (breadth first
-- over the 8 neighbours of every chunk with buildings) and is kept up to date afterwards: one chunk
-- is checked every TERRITORY_PERIOD ticks, round robin over the territories that have a patrol.
--
-- A patrol only steps to a neighbouring chunk of the base, so it stays in the part of the base it
-- is in and never crosses chunks without buildings to another colony.
--
-- storage.territories[force_index][surface_index] = {
--   force, surface,
--   occupied = {key -> true}   chunks with buildings
--   seen = {key -> true}       chunks checked at least once or queued (base + the ring around it)
--   queue = {key, ...}, head, tail   chunks to check first (new ones)
--   verify                     last chunk of the round robin re-check
--   visits = {key -> tick}     last time a patrol was sent to the chunk (least visited goes first)
-- }
-- storage.territory_turn        round robin counter over the active territories
local config = require("script.config")
local Squad = require("script.squad")

local floor, random = math.floor, math.random

local territory = {}

local OFFSET = 32768
local function key_of(cx, cy) return (cx + OFFSET) * 65536 + (cy + OFFSET) end
local function chunk_of(key)
  local x = floor(key / 65536)
  return x - OFFSET, key - x * 65536 - OFFSET
end
local function chunk_at(position) return floor(position.x / 32), floor(position.y / 32) end

-- Entity types that are not buildings of the base.
local NOT_BUILDING = {}
for _, t in pairs({
  "unit", "character", "car", "spider-vehicle", "spider-leg", "spider-unit", "segmented-unit", "segment",
  "combat-robot", "construction-robot", "logistic-robot", "capture-robot",
  "locomotive", "cargo-wagon", "fluid-wagon", "artillery-wagon", "land-mine",
  "entity-ghost", "tile-ghost", "item-request-proxy", "item-entity", "deconstructible-tile-proxy",
  "fire", "stream", "smoke-with-trigger", "sticker", "projectile", "artillery-projectile", "beam",
  "explosion", "corpse", "character-corpse", "highlight-box", "speech-bubble", "particle-source",
  "arrow", "artillery-flare", "rocket-silo-rocket", "rocket-silo-rocket-shadow", "cargo-pod",
  "asteroid", "lightning", "temporary-container", "tree", "fish", "resource", "cliff", "simple-entity",
  "plant", "unit-spawner", "spider-leg",
}) do NOT_BUILDING[t] = true end

local BUILDING_TYPES = {}
for type_name in pairs(defines.prototypes.entity) do
  if not NOT_BUILDING[type_name] then BUILDING_TYPES[#BUILDING_TYPES + 1] = type_name end
end
table.sort(BUILDING_TYPES)

local function get(force, surface, create)
  local by_force = storage.territories[force.index]
  local t = by_force and by_force[surface.index]
  if t or not create then return t end
  if not by_force then
    by_force = {}
    storage.territories[force.index] = by_force
  end
  t = {force = force, surface = surface, occupied = {}, seen = {}, queue = {}, head = 1, tail = 0, visits = {}}
  by_force[surface.index] = t
  return t
end

local function push(t, key)
  if t.seen[key] then return end
  t.seen[key] = true
  t.tail = t.tail + 1
  t.queue[t.tail] = key
end

--- Queues the chunk of `position` and the 8 around it (checked before the round robin).
local function seed(t, position)
  local cx, cy = chunk_at(position)
  for dx = -1, 1 do
    for dy = -1, 1 do push(t, key_of(cx + dx, cy + dy)) end
  end
end

local function has_buildings(t, key)
  local cx, cy = chunk_of(key)
  local x, y = cx * 32, cy * 32
  return t.surface.count_entities_filtered({
    area = {{x, y}, {x + 32, y + 32}},
    force = t.force,
    type = BUILDING_TYPES,
    limit = 1,
  }) > 0
end

local function step(t)
  local key
  if t.head <= t.tail then
    key = t.queue[t.head]
    t.queue[t.head] = nil
    t.head = t.head + 1
  else
    key = next(t.seen, t.verify) -- `seen` only grows, so `verify` is always a key of it
    if key == nil then key = next(t.seen) end
    t.verify = key
    if key == nil then return end
  end
  if has_buildings(t, key) then
    if not t.occupied[key] then
      t.occupied[key] = true
      local cx, cy = chunk_of(key)
      for dx = -1, 1 do
        for dy = -1, 1 do
          if dx ~= 0 or dy ~= 0 then push(t, key_of(cx + dx, cy + dy)) end
        end
      end
    end
  else
    t.occupied[key] = nil
  end
end

local function has_patrol(force_index, surface_index)
  local fd = storage.forces[force_index]
  if not fd then return false end
  local patrol = Squad.MODE.patrol
  for _, squad in pairs(fd.squads) do
    if squad.surface_index == surface_index
      and (squad.mode == patrol or (squad.qrf and squad.qrf.mode == patrol)) then
      return true
    end
  end
  return false
end

--- Every TERRITORY_PERIOD ticks: one chunk of the next territory that has a patrol.
function territory.on_nth_tick()
  local active = {}
  for force_index, by_force in pairs(storage.territories) do
    for surface_index, t in pairs(by_force) do
      if not (t.force.valid and t.surface.valid) then
        by_force[surface_index] = nil
      elseif has_patrol(force_index, surface_index) then
        active[#active + 1] = t
      end
    end
    if next(by_force) == nil then storage.territories[force_index] = nil end
  end
  if #active == 0 then return end
  local turn = (storage.territory_turn or 0) + 1
  storage.territory_turn = turn
  step(active[(turn - 1) % #active + 1])
end

--- A squad starts patrolling: scan the base around it first.
function territory.start(squad)
  if not squad.surface.valid then return end
  seed(get(squad.force, squad.surface, true), squad.pos)
end

local function chunk_center(t, key, squad)
  local cx, cy = chunk_of(key)
  local position = {x = cx * 32 + 16 + random(-8, 8), y = cy * 32 + 16 + random(-8, 8)}
  local leader
  for _, member in pairs(squad.members) do
    if member.valid then
      leader = member
      break
    end
  end
  if leader then
    position = t.surface.find_non_colliding_position(leader.name, position, 12, 1) or position
  end
  return position
end

--- Where a patrolling squad goes next: the least recently visited neighbouring chunk of the base
--- (a diagonal step only past a base chunk); outside the base, the nearest base chunk at most
--- PATROL_RETURN_CHUNKS away. nil while the base around the squad is not known yet.
function territory.next_position(force, squad)
  if not squad.surface.valid then return nil end
  local t = get(force, squad.surface, true)
  local occupied = t.occupied
  local cx, cy = chunk_at(squad.pos)
  local here = key_of(cx, cy)
  if not occupied[here] then
    if not t.seen[here] then seed(t, squad.pos) end
    local best, best_d
    local r = config.PATROL_RETURN_CHUNKS
    for dx = -r, r do
      for dy = -r, r do
        local key = key_of(cx + dx, cy + dy)
        local d = dx * dx + dy * dy
        if occupied[key] and (not best_d or d < best_d) then best, best_d = key, d end
      end
    end
    return best and chunk_center(t, best, squad)
  end
  local choices, oldest = {}, nil
  for dx = -1, 1 do
    for dy = -1, 1 do
      if dx ~= 0 or dy ~= 0 then
        local key = key_of(cx + dx, cy + dy)
        if occupied[key] and (dx == 0 or dy == 0 or occupied[key_of(cx + dx, cy)] or occupied[key_of(cx, cy + dy)]) then
          local visited = t.visits[key] or 0
          if not oldest or visited < oldest then
            choices, oldest = {key}, visited
          elseif visited == oldest then
            choices[#choices + 1] = key
          end
        end
      end
    end
  end
  local key = #choices > 0 and choices[random(#choices)] or here -- a one-chunk base: walk around in it
  t.visits[key] = game.tick
  return chunk_center(t, key, squad)
end

--- Chunk key of a position and whether it is a base chunk (remote interface, tests).
function territory.info(force, surface)
  local t = get(force, surface, false)
  if not t then return nil end
  local chunks = {}
  for key in pairs(t.occupied) do
    local cx, cy = chunk_of(key)
    chunks[#chunks + 1] = {x = cx, y = cy}
  end
  return {chunks = chunks, seen = table_size(t.seen), queued = t.tail - t.head + 1}
end

return territory
