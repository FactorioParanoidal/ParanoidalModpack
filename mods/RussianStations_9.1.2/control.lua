-- stations.lua contains a simple list of names
-- This does not have to be a separate file
require("stations")

-- This does not have to be mod_name, but it's simple and likely to be unique
local LIST_INTERFACE = script.mod_name
-- The name of the function we're registering with the interface above
local LIST_FUNC = "pick_name"
-- Weight is used when multiple lists exist for the same name/type
-- It does not have to be the number of names but that's a good default
local LIST_WEIGHT = #stations

-- Get a name and return it as a string. Thies does not have to be random, and you
-- could have more logic in here, such as modifying name based on station direction
function pick_name(entity)
  return stations[math.random(#stations)]
end

-- Add the interface(s) here, whether or not they will actually be used is determined by
-- whether or not they are registered with Namelists
remote.add_interface(LIST_INTERFACE, {pick_name = pick_name})

-- Example of an alternative function for train stops that adds a prefix to the name based
-- on station direction
-- local DIRECTION_PREFIX = {
  -- [defines.direction.north] = "Kita-",
  -- [defines.direction.east] = "Higashi-",
  -- [defines.direction.south] = "Minami-",
  -- [defines.direction.west] = "Nishi-"
-- }
-- function pick_station_name(entity)
  -- return DIRECTION_PREFIX[entity.direction] .. stations[math.random(#stations)]
-- end
-- remote.add_interface("russianStationNameWithPrefix", {pick_name = pick_station_name})

-- Register this list for each type chosen in the mod settings
function register_interfaces()
  if settings.global["russian-stations-roboports"].value then
    remote.call("Namelists", "register",
      {interface = LIST_INTERFACE, func = LIST_FUNC, category = "type", target = "roboport", weight = LIST_WEIGHT})
  end
  if settings.global["russian-stations-labs"].value then
    remote.call("Namelists", "register",
      {interface = LIST_INTERFACE, func = LIST_FUNC, category = "type", target = "lab", weight = LIST_WEIGHT})
  end
  if settings.global["russian-stations-stations"].value then
    remote.call("Namelists", "register",
      {interface = LIST_INTERFACE, func = LIST_FUNC, category = "type", target = "train-stop", weight = LIST_WEIGHT})
    -- The alternative function example from above
    -- remote.call("Namelists", "register",
      -- "russianStationNameWithPrefix", "type", "train-stop", LIST_WEIGHT)
    -- Both lists would have the same weight, so 50% chance of getting a name with prefix
  end
  if settings.global["russian-stations-locomotives"].value then
    remote.call("Namelists", "register",
      {interface = LIST_INTERFACE, func = LIST_FUNC, category = "type", target = "locomotive", weight = LIST_WEIGHT})
  end
  if settings.global["russian-stations-radars"].value then
    remote.call("Namelists", "register",
      {interface = LIST_INTERFACE, func = LIST_FUNC, category = "type", target = "radar", weight = LIST_WEIGHT})
  end
  if settings.global["russian-stations-default"].value then
    remote.call("Namelists", "register",
      {interface = LIST_INTERFACE, func = LIST_FUNC, weight = LIST_WEIGHT})
  end
end


-- Get ID for Namelists' custom event that tells this mod when to register its lists and
-- register a handler for that event
function set_handlers()
  if remote.interfaces["Namelists"] then
    namelist = remote.call("Namelists", "get_events")
    script.on_event(namelist.on_list_rebuild, function(event)
      register_interfaces()
    end)
    register_interfaces()
  end
end

script.on_init(function()
  set_handlers()
end)
script.on_load(function()
  set_handlers()
end)

-- This is just a dumb list of setting names so I can be lazy in coding the event handler
-- for on_runtime_mod_setting_changed
local MOD_SETTINGS = {
  ["russian-stations-roboports"] = true,
  ["russian-stations-labs"] = true,
  ["russian-stations-stations"] = true,
  ["russian-stations-locomotives"] = true,
  ["russian-stations-radars"] = true,
  ["russian-stations-default"] = true
}

-- If the name of the changed setting is one of the above, then the lists we want to use
-- have changed, so tell Namelists to rebuild its list
script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  if MOD_SETTINGS[event.setting] then
    remote.call("Namelists", "rebuild")
  end
end)