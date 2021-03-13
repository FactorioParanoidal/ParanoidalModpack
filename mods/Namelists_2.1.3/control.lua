local events = {
  -- Custom event fired to request all name lists register themselves
  on_list_rebuild = script.generate_event_name()
}

local MOD_SETTINGS = {
  ["namelists-backer-roboports"] = true,
  ["namelists-backer-labs"] = true,
  ["namelists-backer-stations"] = true,
  ["namelists-backer-locomotives"] = true,
  ["namelists-backer-radars"] = true,
  ["namelists-backer-default"] = true
}

function rebuild_lists()
  global.names = {}
  global.types = {}
  global.defaults = {weight = 0, lists = {}}
  if settings.global["namelists-backer-roboports"].value then
    register_list({interface = "base", func = "backer_name", category = "type", target = "roboport", weight = #game.backer_names, backer = true})
  end
  if settings.global["namelists-backer-labs"].value then
    register_list({interface = "base", func = "backer_name", category = "type", target = "lab", weight = #game.backer_names, backer = true})
  end
  if settings.global["namelists-backer-stations"].value then
    register_list({interface = "base", func = "backer_name", category = "type", target = "train-stop", weight = #game.backer_names, backer = true})
  end
  if settings.global["namelists-backer-locomotives"].value then
    register_list({interface = "base", func = "backer_name", category = "type", target = "locomotive", weight = #game.backer_names, backer = true})
  end
  if settings.global["namelists-backer-radars"].value then
    register_list({interface = "base", func = "backer_name", category = "type", target = "radar", weight = #game.backer_names, backer = true})
  end
  if settings.global["namelists-backer-default"].value then
    register_list({interface = "base", func = "backer_name", weight = #game.backer_names, backer = true})
  end
  script.raise_event(events.on_list_rebuild, {})
  log("Interface lists rebuilt")
end

script.on_init(rebuild_lists)
script.on_configuration_changed(rebuild_lists)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  if MOD_SETTINGS[event.setting] then
    rebuild_lists()
  end
end)

-- Registers a name list for the specified name/type
-- If name or type isn't specified, register as generic
-- parameters is a table of {interface = "", func = "", category = "", target = "", weight = ""}
function register_list(parameters)
  global.names = global.names or {}
  global.types = global.types or {}
  if not (parameters.interface and parameters.func and parameters.weight) then
    log("Error registering: missing parameters")
    return
  end
  if parameters.category and not parameters.target then
    log("Error registering: category specified but no target")
    return
  end
  local id = parameters.interface .. "." .. parameters.func
  if parameters.category == "name" then
    global.names[parameters.target] = global.names[parameters.target] or {weight = 0, lists = {}}
    if not global.names[parameters.target].lists[id] then
      log("Registering interface " .. id .. " for name " .. parameters.target)
      global.names[parameters.target].lists[id] =
      {
        interface = parameters.interface,
        func = parameters.func,
        weight = parameters.weight,
        backer = parameters.backer
      }
      global.names[parameters.target].weight = global.names[parameters.target].weight + parameters.weight
    else
      log("Eror registering interface " .. id .. ": already registered for name " .. parameters.target)
    end
  elseif parameters.category == "type" then
    global.types[parameters.target] = global.types[parameters.target] or {weight = 0, lists = {}}
    if not global.types[parameters.target].lists[id] then
      log("Registering interface " .. id .. " for type " .. parameters.target)
      global.types[parameters.target].lists[id] =
      {
        interface = parameters.interface,
        func = parameters.func,
        weight = parameters.weight,
        backer = parameters.backer
      }
      global.types[parameters.target].weight = global.types[parameters.target].weight + parameters.weight
    else
      log("Eror registering interface " .. id .. ": already registered for type " .. parameters.target)
    end
  else
    if not global.defaults.lists[id] then
      log("Registering interface " .. id .. " as a default")
      global.defaults.lists[id] =
      {
        interface = parameters.interface,
        func = parameters.func,
        weight = parameters.weight,
        backer = parameters.backer
      }
      global.defaults.weight = global.defaults.weight + parameters.weight
    else
      log("Eror registering interface " .. id .. ": already registered as default")
    end
  end
end

-- remove list with id from category, because we've tried to use it and it wasn't there
function remove_list(category, id)
  category.lists[id] = nil
  category.weight = 0
  for i,list in pairs(category.lists) do
    category.weight = category.weight + list.weight
  end
end

-- Keybind
script.on_event("random-name", function(event)
  local selection = game.players[event.player_index].selected
  if selection and selection.valid and
  selection.supports_backer_name() then
    selection.backer_name = pick_name(selection)
  end
end)

-- Entity built
-- We don't catch the robot_built event because the ghost will already have a name chosen
-- in the player event
script.on_event(defines.events.on_built_entity, function(event)
  if event.created_entity.supports_backer_name() then
    auto_name(event.created_entity)
  end
end)

-- Pick a name unless this is a station built without a ghost
-- Don't pick a name for hand-built stations, in case they were built over a ghost
function auto_name(entity)
  if entity.type == "entity-ghost" then
    if entity.backer_name == "" then
      entity.backer_name = pick_name(entity)
    end
  elseif entity.type ~= "train-stop" then
    entity.backer_name = pick_name(entity)
  end
end

-- Get a pick a name list at random from the given category using the weighting
-- Request a name from that list
-- If a list is broken, deregister is and try again
function get_weighted_name(category, entity)
  ::roll::
  if category.weight > 0 then
    local dice_roll = math.random(category.weight) - 1
    for id,list in pairs(category.lists) do
      dice_roll = dice_roll - list.weight
      if dice_roll < 0 then
        if list.backer then
          return game.backer_names[math.random(#game.backer_names)]
        elseif remote.interfaces[list.interface] and remote.interfaces[list.interface][list.func] then
          return remote.call(list.interface, list.func, entity)
        else
          -- if this list has stopped working, remove it and try again
          log("Removing non-functioning interface " .. id)
          remove_list(category, id)
          goto roll
        end
      end
    end
  end
end

-- Make a call to a registered list, preferably by name but otherwise by type
-- Picks a generic name if no more specific list is available, falls back to a backer name
function pick_name(entity)
  if not (entity and entity.valid) then
    -- ABORT
    return
  end
  local ent_name = entity.name
  local ent_type = entity.type
  -- is this a ghost? get the inner type
  if entity.type == "entity-ghost" then
    ent_name = entity.ghost_name
    ent_type = entity.ghost_type
  end
  local new_name = nil
  -- try to get a name based on entity name
  if global.names[ent_name] and global.names[ent_name].weight > 0 then
    new_name = get_weighted_name(global.names[ent_name], entity)
    if new_name then
      return new_name
    end
  end
  -- try to get a name based on entity type
  if global.types[ent_type] and global.types[ent_type].weight > 0 then
    new_name = get_weighted_name(global.types[ent_type], entity)
    if new_name then
      return new_name
    end
  end
  -- try to get a name from a default list
  if global.defaults and global.defaults.weight > 0 then
    new_name = get_weighted_name(global.defaults, entity)
    if new_name then
      return new_name
    end
  end
  -- fallback: return a built-in backer name
  return game.backer_names[math.random(#game.backer_names)]
end

-- Does a list exist for this entity, either by name or by type?
-- Deprecated, Namelists now always returns a name if the entity is valid
function has_name_list(entity)
  return true
end

-- Add interfaces
remote.add_interface("Namelists", {
  pick_name = pick_name,
  has_list = has_name_list,
  rebuild = rebuild_lists,
  register = register_list,
  get_events = function()
    return events
  end
})