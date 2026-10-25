-- Persistent state (storage) layout and per-force data.
--
-- storage.schema         schema version; a different version means a fresh start (no migrations)
-- storage.forces         force index -> force data (created lazily, only for forces that use the mod)
-- storage.squads         squad id -> squad (see script/squad.lua)
-- storage.next_squad_id
-- storage.buckets        [1..BUCKETS] -> set of squad ids updated on that tick of the cycle
-- storage.bucket_sizes   [1..BUCKETS] -> number of squads in the bucket
-- storage.units          unit_number -> droid LuaEntity (every droid the mod knows about)
-- storage.unit_squad     unit_number -> squad id
-- storage.groups         unit group unique_id -> squad id
-- storage.structures     unit_number -> {kind = "assemblers"|"stations"|"counters"|"loot", force = index}
-- storage.spawners       unit_number -> spawner record (round robin, see script/spawners.lua)
-- storage.spawner_count, storage.spawner_cursor, storage.spawner_budget
-- storage.selection      player index -> {squad = id, objects = {LuaRenderObject}}
-- storage.windows        player index -> true while the army window is open
local shared = require("lib.shared")
local config = require("script.config")

local state = {}

state.SCHEMA = 2

--- Fresh state. Anything left from another schema (or the original mod) is dropped.
function state.init()
  for key in pairs(storage) do
    storage[key] = nil
  end
  rendering.clear(script.mod_name) -- selection marks of the dropped state
  storage.schema = state.SCHEMA
  storage.forces = {}
  storage.squads = {}
  storage.next_squad_id = 1
  storage.buckets = {}
  storage.bucket_sizes = {}
  for i = 1, config.BUCKETS do
    storage.buckets[i] = {}
    storage.bucket_sizes[i] = 0
  end
  storage.units = {}
  storage.unit_squad = {}
  storage.groups = {}
  storage.structures = {}
  storage.spawners = {}
  storage.spawner_count = 0
  storage.spawner_cursor = nil
  storage.spawner_budget = 0
  storage.selection = {}
  storage.windows = {}
end

--- Force data, created on first use.
--- squads          squad id -> squad
--- assemblers      unit_number -> droid assembler
--- stations        unit_number -> guard station
--- station_squad   station unit_number -> squad id of its garrison
--- counters        unit_number -> droid counter
--- loot_chest      (one per force)
--- thresholds      hunt_size / retreat_size / hunt_range set in the army window
--- counter_values  last values written to the droid counters
--- retreats        assembler unit_number -> set of squad ids retreating there
--- threats         assembler unit_number -> {tick, enemy, distance} (keep-radius-clear targeting)
function state.force_data(force)
  local data = storage.forces[force.index]
  if not data then
    local thresholds = {}
    for key, spec in pairs(shared.thresholds) do
      thresholds[key] = spec.default
    end
    data = {
      force = force,
      squads = {},
      assemblers = {},
      stations = {},
      station_squad = {},
      counters = {},
      loot_chest = nil,
      thresholds = thresholds,
      counter_values = {},
      counters_dirty = true,
      retreats = {},
      threats = {},
      qrf_alert_tick = nil,
    }
    storage.forces[force.index] = data
  end
  return data
end

--- Registers a building of the mod.
function state.track_structure(entity, kind)
  local unit_number = entity.unit_number
  script.register_on_object_destroyed(entity)
  storage.structures[unit_number] = {kind = kind, force = entity.force.index}
  if kind == "assemblers" or kind == "stations" then
    storage.spawners[unit_number] = {
      entity = entity,
      station = (kind == "stations"),
      surface = entity.surface,
      position = entity.position,
      finished = entity.products_finished,
      pending = {},
      garrison = (kind == "stations") and shared.garrison.default or nil,
    }
    storage.spawner_count = storage.spawner_count + 1
  end
end

--- Forgets a building (on destruction). Returns its structure record and spawner record.
function state.untrack_structure(unit_number)
  local record = storage.structures[unit_number]
  if not record then return nil end
  storage.structures[unit_number] = nil
  local spawner = storage.spawners[unit_number]
  if spawner then
    -- keep the round robin cursor on a live key
    if storage.spawner_cursor == unit_number then
      storage.spawner_cursor = next(storage.spawners, unit_number)
    end
    storage.spawners[unit_number] = nil
    storage.spawner_count = storage.spawner_count - 1
  end
  return record, spawner
end

--- Registers a droid entity.
function state.track_unit(entity)
  local unit_number = entity.unit_number
  if storage.units[unit_number] then return false end
  script.register_on_object_destroyed(entity)
  storage.units[unit_number] = entity
  return true
end

return state
