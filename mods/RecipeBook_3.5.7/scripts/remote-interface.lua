local constants = require("constants")

local database = require("scripts.database")

local remote_interface = {}

--- Returns a copy of the given object's information in the Recipe Book database.
--- @param class string One of `crafter`, `entity`, `equipment_category`, `equipment`, `fluid`, `fuel_category`, `group`, `item`, `lab`, `mining_drill`, `offshore_pump`, `recipe_category`, `recipe`, `resource_category`, `resource`, or `technology`.
--- @param name string The name of the object to get data for.
--- @return table? The object's data, or `nil` if the object was not found.
function remote_interface.get_object_data(class, name)
  if not class then
    error("Remote interface caller did not provide an object class.")
  end
  if not constants.pages[class] then
    error("Remote interface caller provided an invalid class: `" .. class .. "`")
  end
  if not name then
    error("Remote interface caller did not provide an object name.")
  end

  return database[class][name]
end

--- Opens the given info page in a Recipe Book window.
--- @param player_index uint
--- @param class string One of `crafter`, `entity`, `equipment_category`, `equipment`, `fluid`, `fuel_category`, `group`, `item`, `lab`, `mining_drill`, `offshore_pump`, `recipe_category`, `recipe`, `resource_category`, `resource`, or `technology`.
--- @param name string The name of the object to open.
--- @return boolean did_open Whether or not the page was opened.
function remote_interface.open_page(player_index, class, name)
  if not class then
    error("Remote interface caller did not provide an object class.")
  end
  if not constants.pages[class] then
    error("Remote interface caller provided an invalid class: `" .. class .. "`")
  end
  if not name then
    error("Remote interface caller did not provide an object name.")
  end

  local data = database[class][name]
  if not data then
    return false
  end

  local player = game.get_player(player_index)
  local player_table = global.players[player_index]

  if player_table.flags.can_open_gui then
    OPEN_PAGE(player, player_table, { class = class, name = name })
    return true
  else
    return false
  end
end

--- Returns the current interface version.
---
--- This version will be incremented if breaking changes are made to the interface. Check against this version before calling interface functions to avoid crashing.
---
--- The current interface version is `4`.
--- @return number
function remote_interface.version()
  return constants.interface_version
end

return remote_interface
