-- Droid counter: a constant combinator that outputs the number of droids of the force.
local shared = require("lib.shared")

local circuit = {}

local SIGNAL_TYPE = "virtual"

------------------------------------------------------------------------------------------
-- Droid counters

local function write_counter(counter, filters)
  local behavior = counter.get_or_create_control_behavior()
  if not behavior then return end
  local section = behavior.sections_count > 0 and behavior.get_section(1) or behavior.add_section()
  if section and section.is_manual then
    section.filters = filters
  end
end

--- Counts the force's droids; writes the counters only when a number changed
--- (each written slot raises an event for every mod listening to logistic slot changes).
function circuit.update_counters(fd)
  if next(fd.counters) == nil then return end
  local force = fd.force
  local values = fd.counter_values
  local changed = fd.counters_dirty
  local alive = 0
  for _, droid in pairs(shared.droids) do
    local n = force.get_entity_count(droid.unit)
    alive = alive + n
    local signal = droid.signal
    if signal and values[signal] ~= n then
      values[signal] = n
      changed = true
    end
  end
  if values[shared.alive_signal] ~= alive then
    values[shared.alive_signal] = alive
    changed = true
  end
  if not changed then return end
  fd.counters_dirty = false

  local filters = {{value = {type = SIGNAL_TYPE, name = shared.alive_signal, quality = "normal"}, min = alive}}
  for _, droid in pairs(shared.droids) do
    local signal = droid.signal
    if signal then
      filters[#filters + 1] = {value = {type = SIGNAL_TYPE, name = signal, quality = "normal"}, min = values[signal]}
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
