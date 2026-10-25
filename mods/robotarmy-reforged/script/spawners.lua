-- Droid assemblers and guard stations deploy droids: the deploy recipe consumes a droid item
-- and produces nothing; every finished craft (LuaEntity::products_finished) becomes a unit
-- with the quality of the recipe, i.e. of the consumed droid item. Quality modules have no
-- product to roll on, so they cannot raise the quality of droids.
--
-- When there is no room for more droids (assembler: too many droids around; guard station:
-- garrison full) the finished crafts wait and the machine is paused (disabled_by_script) until
-- they are deployed. Waiting droids of a machine that is removed are spilled as items.
--
-- spawner record (storage.spawners[unit_number]):
--   entity, station (bool), surface, position, finished (last products_finished),
--   unit / quality (deploy recipe at the last check), pending = {{unit, quality}, ...},
--   garrison (guard stations: wanted garrison size)
local shared = require("lib.shared")
local config = require("script.config")
local state = require("script.state")
local Squad = require("script.squad")
local compat = require("script.compat")

local random, floor, min = math.random, math.floor, math.min
local direction = defines.direction
local deploy_to_unit = shared.deploy_to_unit
local unit_names = shared.unit_names

local spawners = {}

--- Puts a droid into a squad (or only tracks it while Unit Control drives the units).
--- `station` is the guard station that spawned it; `manual` marks droids placed by a player.
function spawners.adopt(droid, station, manual)
  local unit_number = droid.unit_number
  if not state.track_unit(droid) and storage.unit_squad[unit_number] then return end
  if compat.unit_control then return end
  local fd = state.force_data(droid.force)
  local squad
  if station then
    local id = fd.station_squad[station.unit_number]
    squad = id and storage.squads[id]
    if squad and squad.surface_index ~= droid.surface_index then squad = nil end
    if not squad then
      squad = Squad.create(fd, droid, Squad.MODE.guard, station.position)
      squad.station = station.unit_number
      fd.station_squad[station.unit_number] = squad.id
    end
  else
    squad = Squad.find_near(fd, droid.surface_index, droid.position, config.SQUAD_CHECK_RANGE)
      or Squad.create(fd, droid)
  end
  Squad.add(squad, droid)
  if manual then
    squad.order.dirty = true
  end
end

--- Spawn point on the output side of an assembler, with the original random spread.
local function assembler_spawn_position(assembler, unit_name)
  local p = assembler.position
  local x, y = p.x, p.y
  local d = assembler.direction
  local offset = config.SPAWN_OFFSET
  if d == direction.east then x = x - offset
  elseif d == direction.north then y = y + offset
  elseif d == direction.south then y = y - offset
  elseif d == direction.west then x = x + offset
  end
  if d == direction.east then
    x = x + random() - random(0, 4)
  else
    x = x + random() + random(0, 4)
  end
  if d == direction.north then
    y = y + random() + random(0, 4)
  else
    y = y + random() - random(0, 4)
  end
  return assembler.surface.find_non_colliding_position(unit_name, {x, y}, 10, 0.5)
end

local function station_spawn_position(station, unit_name)
  return station.surface.find_non_colliding_position(unit_name, station.position, 20, 1)
end

--- How many more droids this spawner may deploy now.
local function room(record, fd)
  local entity = record.entity
  if record.station then
    local id = fd.station_squad[entity.unit_number]
    local squad = id and storage.squads[id]
    return record.garrison - (squad and squad.size or 0)
  end
  local p = entity.position
  local h = config.NEARBY_DROIDS_HALF_SIZE
  local nearby = entity.surface.count_entities_filtered({
    area = {{p.x - h, p.y - h}, {p.x + h, p.y + h}},
    name = unit_names,
    force = entity.force,
  })
  return floor(fd.thresholds.hunt_size * config.ASSEMBLER_SPAWN_LIMIT_FACTOR) - nearby + 1
end

local function deploy(record, unit_name, quality)
  local entity = record.entity
  local position = record.station and station_spawn_position(entity, unit_name)
    or assembler_spawn_position(entity, unit_name)
  if not position then return false end
  local droid = entity.surface.create_entity({
    name = unit_name,
    position = position,
    direction = direction.east,
    force = entity.force,
    quality = quality,
  })
  if not droid then return false end
  if compat.unit_control then
    state.track_unit(droid)
    compat.unit_spawned(droid, entity)
  else
    spawners.adopt(droid, record.station and entity or nil, false)
  end
  script.raise_script_built({entity = droid})
  return true
end

local function process(record)
  local entity = record.entity
  if not entity.valid then return end
  local pending = record.pending

  -- finished deploy crafts since the last check
  local finished = entity.products_finished
  local done = finished - record.finished
  record.finished = finished
  local recipe, quality = entity.get_recipe()
  local unit = recipe and deploy_to_unit[recipe.name]
  local quality_name = quality and quality.name or "normal"
  if done > 0 then
    -- crafts finished since the last check used the recipe seen then (or the current one)
    local done_unit = record.unit or unit
    local done_quality = record.unit and record.quality or quality_name
    if done_unit then
      for _ = 1, min(done, config.MAX_PENDING - #pending) do
        pending[#pending + 1] = {done_unit, done_quality}
      end
    end
  end
  record.unit, record.quality = unit, quality_name

  if #pending > 0 then
    local fd = state.force_data(entity.force)
    local free = min(room(record, fd), config.MAX_SPAWNS_PER_CHECK)
    while free > 0 and #pending > 0 do
      local next_droid = pending[1]
      if not deploy(record, next_droid[1], next_droid[2]) then break end
      table.remove(pending, 1)
      free = free - 1
    end
  end
  local hold = #pending > 0
  if entity.disabled_by_script ~= hold then
    entity.disabled_by_script = hold
  end
end
spawners.process = process

--- Round robin: every spawner is looked at once per SPAWNER_PERIOD ticks, spread evenly
--- over the ticks (fractional budget), instead of all of them on the same tick.
function spawners.on_tick()
  local count = storage.spawner_count
  if count <= 0 then return end
  local budget = (storage.spawner_budget or 0) + count / config.SPAWNER_PERIOD
  if budget < 1 then
    storage.spawner_budget = budget
    return
  end
  local list = storage.spawners
  local key = storage.spawner_cursor
  local steps = floor(budget)
  storage.spawner_budget = budget - steps
  for _ = 1, min(steps, count) do
    key = next(list, key)
    if key == nil then
      key = next(list)
      if key == nil then break end
    end
    process(list[key])
  end
  storage.spawner_cursor = key
end

--- A spawner was removed: its waiting droids drop as items where it stood.
function spawners.removed(record)
  if not record or #record.pending == 0 then return end
  local surface = record.surface
  if not (surface and surface.valid) then return end
  for _, waiting in pairs(record.pending) do
    surface.spill_item_stack({
      position = record.position,
      stack = {name = waiting[1], count = 1, quality = waiting[2]},
      enable_looted = true,
      allow_belts = false,
    })
  end
  record.pending = {}
end

return spawners
