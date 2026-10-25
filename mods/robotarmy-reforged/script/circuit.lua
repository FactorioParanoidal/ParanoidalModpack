-- Droid counter: a constant combinator that outputs (written only when a number changes):
--   the item signal of every droid kind      droids of that kind (all ranks)
--   "Droids alive"                           all droids of the force
--   "Squads hunting / fighting / gathering / recalled / patrolling"   squads in that state
--   "Droids waiting to deploy"               finished deploy crafts waiting for room
--   "Alarm"                                  1 while squads respond to a destroyed building
-- Garrisons are counted in "Droids alive" only.
local shared = require("lib.shared")
local Squad = require("script.squad")
local droids = require("script.droids")

local circuit = {}

local HUNTING, FIGHTING, GATHERING, RECALLED, PATROLLING, PENDING, ALARM =
  "signal-droid-squads-hunting", "signal-droid-squads-fighting", "signal-droid-squads-gathering",
  "signal-droid-squads-recalled", "signal-droid-squads-patrolling", "signal-droid-pending", "signal-droid-alarm"

-- squad status -> signal
local STATUS_SIGNAL = {
  hunt = HUNTING, ["qrf-return"] = HUNTING,
  fight = FIGHTING, qrf = FIGHTING,
  gather = GATHERING, retreat = GATHERING,
  hold = RECALLED,
  patrol = PATROLLING,
}

local function write_counter(counter, filters)
  local behavior = counter.get_or_create_control_behavior()
  if not behavior then return end
  local section = behavior.sections_count > 0 and behavior.get_section(1) or behavior.add_section()
  if section and section.is_manual then
    section.filters = filters
  end
end

--- Current values of the counter signals of a force: name -> number.
function circuit.values(fd)
  local force = fd.force
  local values = {}
  local alive = 0
  for _, kind in pairs(droids.kinds) do
    local n = 0
    for _, name in pairs(droids.names_of_kind[kind.unit]) do
      n = n + force.get_entity_count(name)
    end
    values[kind.unit] = n
    alive = alive + n
  end
  values[shared.alive_signal] = alive
  for _, signal in pairs({HUNTING, FIGHTING, GATHERING, RECALLED, PATROLLING, PENDING, ALARM}) do
    values[signal] = 0
  end
  for _, squad in pairs(fd.squads) do
    local status = Squad.status(squad)
    local signal = STATUS_SIGNAL[status]
    if signal then values[signal] = values[signal] + 1 end
    if status == "qrf" then values[ALARM] = 1 end
  end
  local index = force.index
  for _, record in pairs(storage.spawners) do
    if record.entity.valid and record.entity.force.index == index then
      values[PENDING] = values[PENDING] + #record.pending
    end
  end
  return values
end

--- Writes the counters of a force when a number changed (each written slot raises an event for
--- every mod listening to logistic slot changes).
function circuit.update_counters(fd)
  if next(fd.counters) == nil then return end
  local values = circuit.values(fd)
  local old = fd.counter_values
  local changed = fd.counters_dirty
  for name, n in pairs(values) do
    if old[name] ~= n then
      changed = true
      break
    end
  end
  fd.counter_values = values
  if not changed then return end
  fd.counters_dirty = false

  local filters = {}
  for _, s in pairs(shared.signals) do
    filters[#filters + 1] = {value = {type = "virtual", name = s.name, quality = "normal"}, min = values[s.name]}
  end
  for _, kind in pairs(droids.kinds) do
    local n = values[kind.unit]
    if n > 0 then
      filters[#filters + 1] = {value = {type = "item", name = kind.unit, quality = "normal"}, min = n}
    end
  end
  for unit_number, counter in pairs(fd.counters) do
    if counter.valid then
      write_counter(counter, filters)
    else
      fd.counters[unit_number] = nil
    end
  end
end

--- Periodic pass over the forces that use the mod.
function circuit.on_nth_tick()
  for _, fd in pairs(storage.forces) do
    circuit.update_counters(fd)
  end
end

return circuit
