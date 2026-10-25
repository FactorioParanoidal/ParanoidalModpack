-- Unit Control (mod "Unit_Controll") integration: when it is active it drives the droids,
-- the squad AI is off and spawned droids are handed over through its spawn event.
local compat = {}

-- active mods cannot change while a save is running; read once instead of on every use
compat.unit_control = script.active_mods["Unit_Controll"] ~= nil

function compat.unit_spawned(droid, spawner)
  if not remote.interfaces["unit_control"] then return end
  local events = remote.call("unit_control", "get_events")
  local id = events and events.on_unit_spawned
  if id then
    script.raise_event(id, {entity = droid, spawner = spawner})
  end
end

return compat
