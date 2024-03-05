-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RAILUALIB EVENT MODULE
-- Event registration, conditional event management, GUI event filtering.

-- dependencies
local migration = require("__RaiLuaLib__.lualib.migration")

-- locals
local string_find = string.find
local table_insert = table.insert
local table_remove = table.remove

-- object
local event = {}

-- -----------------------------------------------------------------------------
-- DISPATCHING

-- holds registered events for dispatch
local events = {}
-- holds conditional event data
local conditional_events = {}
-- conditional events by group
local conditional_event_groups = {}

-- calls handler functions tied to an event
-- all non-bootstrap events go through this function
local function dispatch_event(e)
  local global_data = global.__lualib.event
  local con_registry = global_data.conditional_events
  local player_lookup = global_data.players
  local id = e.name
  -- set ID for special events
  if e.nth_tick then
    id = -e.nth_tick
  end
  if e.input_name then
    id = e.input_name
  end
  -- error checking
  if not events[id] then
    error("Event is registered but has no handlers!")
  end
  -- for later use
  local elem = e.element

  -- for every handler registered to this event
  for _,t in ipairs(events[id]) do
    local has_name = false
    local options = t.options
    -- check if any userdata has gone invalid since last iteration
    if not options.skip_validation then
      for _,v in pairs(e) do
        if type(v) == "table" and v.__self and not v.valid then
          return
        end
      end
    end
    -- check static GUI filters, if any
    local filters = t.gui_filters
    if filters then
      if not elem then
        log("Static event "..id.." has GUI filters but no GUI element, skipping!")
        goto continue
      end
      if filters[elem.index] or filters[elem.name] then
        goto call_handler
      elseif options.match_filter_strings then
        local name = elem.name
        for _,filter in pairs(filters) do
          -- check all string GUI filters to see if they partially match
          if type(filter) == "string" and string_find(name, filter) then
            goto call_handler
          end
        end
      end
      goto continue -- none of them matched
    end
    -- check conditional events
    for name,_ in pairs(t.conditional_names) do
      has_name = true
      local con_data = con_registry[name]
      if not con_data then error("Conditional event ["..name.."] has been raised, but has no data!") end
      -- if con_data is true, then skip all checks and just call the handler
      if con_data == true then
        goto call_handler
      else
        local players = con_data.players
        -- add registered players to the event
        e.registered_players = players
        if e.player_index then
          local player_events = player_lookup[e.player_index]
          -- check if this player is registered
          if player_events and player_events[name] then
            -- check GUI filters
            local player_filters = con_data.gui_filters[e.player_index]
            if player_filters then
              if e.element then
                if player_filters[elem.index] or player_filters[elem.name] then
                  goto call_handler
                elseif options.match_filter_strings then
                  local elem_name = elem.name
                  for _,filter in pairs(player_filters) do
                    -- check all string GUI filters to see if they partially match
                    if type(filter) == "string" and string_find(elem_name, filter) then
                      goto call_handler
                    end
                  end
                end
              else
                log("Conditional event "..name.." has GUI filters but no GUI element, skipping!")
              end
            else
              goto call_handler
            end
          end
        else
          goto call_handler
        end
      end
    end

    -- if we're here and there was at least one conditional name, nothing caused the handler to trigger, so skip it
    if has_name then goto continue end
    ::call_handler::
    -- call the handler
    t.handler(e)
    ::continue::
    if options.force_crc then
      game.force_crc()
    end
  end
  return
end

-- BOOTSTRAP EVENTS
-- these events are handled specially and do not go through dispatch_event

script.on_init(function()
  global.__lualib = {
    __version = script.active_mods["RaiLuaLib"], -- current version
    event = {conditional_events={}, players={}}
  }
  -- dispatch events
  for _,t in ipairs(events.on_init or {}) do
    t.handler()
  end
  -- dispatch postprocess events
  for _,t in ipairs(events.on_init_postprocess or {}) do
    t.handler()
  end
end)

script.on_load(function()
  -- dispatch events
  for _,t in ipairs(events.on_load or {}) do
    t.handler()
  end
  -- dispatch postprocess events
  for _,t in ipairs(events.on_load_postprocess or {}) do
    t.handler()
  end
  -- re-register conditional events
  local registered = global.__lualib.event.conditional_events
  for n,_ in pairs(registered) do
    if conditional_events[n] then
      event.enable(n, nil, nil, true)
    end
  end
end)

script.on_configuration_changed(function(e)
  -- module migrations
  if script.active_mods["RaiLuaLib"] ~= global.__lualib.__version then
    migration.run(global.__lualib.__version or "0.1.0", {
      ["0.2.0"] = function()
        -- convert all GUI filters to like-key -> value
        for _,con_data in pairs(global.__lualib.event.conditional_events) do
          for i,filters in pairs(con_data.gui_filters) do
            local new = {}
            for fi=1,#filters do
              new[filters[fi]] = filters[fi]
            end
            con_data.gui_filters[i] = new
          end
        end
      end
    })
  end
  -- dispatch events
  for _,t in ipairs(events.on_configuration_changed or {}) do
    t.handler(e)
  end
  -- update lualib version
  global.__lualib.__version = script.active_mods["RaiLuaLib"]
end)

-- -----------------------------------------------------------------------------
-- REGISTRATION

local bootstrap_events = {on_init=true, on_init_postprocess=true, on_load=true, on_load_postprocess=true, on_configuration_changed=true}

-- register static (non-conditional) events
-- used by register_conditional to insert the handler
-- conditional name is not to be used by the modder - it is internal only!
function event.register(id, handler, gui_filters, options, conditional_name)
  options = options or {}
  -- register handler
  if type(id) ~= "table" then id = {id} end
  for _,n in pairs(id) do
    -- create event registry if it doesn't exist
    if not events[n] then
      events[n] = {}
    end
    local registry = events[n]
    -- create master handler if not already created
    if not bootstrap_events[n] then
      if #registry == 0 then
        if type(n) == "number" and n < 0 then
          script.on_nth_tick(-n, dispatch_event)
        else
          script.on_event(n, dispatch_event)
        end
      end
    end
    -- make sure the handler has not already been registered
    for _,t in ipairs(registry) do
      if t.handler == handler then
        -- add conditional name to the list if it's not already there
        if conditional_name and not t.conditional_names[conditional_name] then
          t.conditional_names[conditional_name] = true
        end
        -- do nothing else
        return
      end
    end
    -- format gui filters
    local filters
    if gui_filters then
      if type(gui_filters) ~= "table" then
        gui_filters = {gui_filters}
      end
      filters = {}
      for _,filter in pairs(gui_filters) do
        filters[filter] = filter
      end
    end
    -- insert handler
    local data = {handler=handler, gui_filters=filters, options=options, conditional_names={}}
    if conditional_name then
      data.conditional_names[conditional_name] = true
    end
    if options.insert_at then
      table_insert(registry, options.insert_at, data)
    else
      table_insert(registry, data)
    end
  end
  return
end

-- register conditional (non-static) events
-- called in on_init and on_load ONLY
function event.register_conditional(data)
  for n,t in pairs(data) do
    if conditional_events[n] then
      error("Duplicate conditional event: "..n)
    end
    t.options = t.options or {}
    -- add to conditional events table
    conditional_events[n] = t
    -- add to group lookup
    local groups = t.group
    if groups then
      if type(groups) ~= "table" then groups = {groups} end
      for i=1,#groups do
        local group = conditional_event_groups[groups[i]]
        if group then
          group[#group+1] = n
        else
          conditional_event_groups[groups[i]] = {n}
        end
      end
    end
  end
end

-- enables a conditional event
function event.enable(name, player_index, gui_filters, reregister)
  local data = conditional_events[name]
  if not data then
    error("Conditional event ["..name.."] was not registered and has no data!")
  end
  local global_data = global.__lualib.event
  local saved_data = global_data.conditional_events[name]
  local add_player_data = false
  if saved_data then
    -- update existing data / add this player
    if player_index then
      if saved_data == true then error("Tried to add a player to a global conditional event!") end
      local player_lookup = global_data.players[player_index]
      -- check if they're already registered
      if player_lookup and player_lookup[name] then
        -- don't do anything
        if not data.options.suppress_logging then
          log("Tried to re-register conditional event ["..name.."] for player "..player_index..", skipping!")
        end
        return
      else
        add_player_data = true
      end
    elseif not reregister then
      if not data.options.suppress_logging then
        log("Conditional event ["..name.."] was already registered, skipping!")
      end
      return
    end
  else
    -- add to global
    if player_index then
      global_data.conditional_events[name] = {gui_filters={}, players={}}
      add_player_data = true
    else
      global_data.conditional_events[name] = true
    end
    saved_data = global_data.conditional_events[name]
  end
  -- nest GUI filters into an array if they're not already
  if gui_filters then
    if type(gui_filters) ~= "table" then
      gui_filters = {gui_filters}
    end
  end
  -- add to player lookup table
  if add_player_data then
    local player_lookup = global_data.players[player_index]
    -- add the player to the event
    if gui_filters then
      local new_filters = {}
      for _,filter in pairs(gui_filters) do
        new_filters[filter] = filter
      end
      saved_data.gui_filters[player_index] = new_filters
    end
    table_insert(saved_data.players, player_index)
    -- add to player lookup table
    if not player_lookup then
      global_data.players[player_index] = {[name]=true}
    else
      player_lookup[name] = true
    end
  end
  -- register handler
  event.register(data.id, data.handler, data.gui_filters, data.options, name)
end

-- disables a conditional event
function event.disable(name, player_index)
  local data = conditional_events[name]
  if not data then
    error("Tried to disable conditional event ["..name.."], which does not exist!")
  end
  local global_data = global.__lualib.event
  local saved_data = global_data.conditional_events[name]
  if not saved_data then
    if not data.options.suppress_logging then
      log("Tried to disable conditional event ["..name.."], which is not enabled!")
    end
    return
  end
  -- remove player from / manipulate global data
  if player_index then
    -- check if the player is actually registered to this event
    if global_data.players[player_index][name] then
      -- remove from players subtable
      for i,pi in ipairs(saved_data.players) do
        if pi == player_index then
          table_remove(saved_data.players, i)
          break
        end
      end
      -- remove GUI filters
      saved_data.gui_filters[player_index] = nil
      -- remove from lookup table
      global_data.players[player_index][name] = nil
      -- remove lookup table if it's empty
      if table_size(global_data.players[player_index]) == 0 then
        global_data.players[player_index] = nil
      end
    else
      if not data.options.suppress_logging then
        log("Tried to disable conditional event ["..name.."] from player "..player_index.." when it wasn't enabled for them!")
      end
      return
    end
    if #saved_data.players == 0 then
      global_data.conditional_events[name] = nil
    else
      -- don't do anything else
      return
    end
  else
    if type(saved_data) == "table" then
      -- remove from all player lookup tables
      local players = global_data.players
      for i=1,#saved_data.players do
        players[saved_data.players[i]][name] = nil
      end
    end
    global_data.conditional_events[name] = nil
  end
  -- deregister handler
  local id = data.id
  if type(id) ~= "table" then id = {id} end
  for _,n in pairs(id) do
    local registry = events[n]
    -- error checking
    if not registry or #registry == 0 then
      log("Tried to deregister an unregistered event of id: "..n)
      return
    end
    for i,t in ipairs(registry) do
      if t.handler == data.handler then
        -- remove conditional name from table
        t.conditional_names[name] = nil
        if table_size(t.conditional_names) > 0 then
          -- don't actually remove or deregister the handler
          return
        end
        -- remove the handler from the events tables
        table_remove(registry, i)
      end
    end
    -- de-register the master handler if it's no longer needed
    if #registry == 0 then
      if type(n) == "number" and n < 0 then
        script.on_nth_tick(math.abs(n), nil)
      else
        script.on_event(n, nil)
      end
      events[n] = nil
    end
  end
end

-- enables a group of conditional events
function event.enable_group(group, player_index, gui_filters)
  local group_events = conditional_event_groups[group]
  if not group_events then error("Group ["..group.."] has no handlers!") end
  for i=1,#group_events do
    event.enable(group_events[i], player_index, gui_filters)
  end
end

-- disables a group of conditional events
function event.disable_group(group, player_index)
  local group_events = conditional_event_groups[group]
  if not group_events then error("Group ["..group.."] has no handlers!") end
  for i=1,#group_events do
    event.disable(group_events[i], player_index)
  end
end

-- -------------------------------------
-- SHORTCUT FUNCTIONS

-- bootstrap events
function event.on_init(handler, options)
  return event.register("on_init", handler, nil, options)
end

function event.on_load(handler, options)
  return event.register("on_load", handler, nil, options)
end

function event.on_configuration_changed(handler, options)
  return event.register("on_configuration_changed", handler, nil, options)
end

function event.on_nth_tick(nthTick, handler, options)
  return event.register(-nthTick, handler, nil, options)
end

-- defines.events
for n,id in pairs(defines.events) do
  event[n] = function(handler, options)
    event.register(id, handler, options)
  end
end

-- -----------------------------------------------------------------------------
-- EVENT MANIPULATION

-- raises an event as if it were actually called
function event.raise(id, table)
  script.raise_event(id, table)
  return
end

-- set or remove event filters
function event.set_filters(id, filters)
  if type(id) ~= "table" then id = {id} end
  for _,n in pairs(id) do
    script.set_event_filter(n, filters)
  end
  return
end

-- holds custom event IDs
local custom_id_registry = {}

-- generates or retrieves a custom event ID
function event.get_id(name)
  if not custom_id_registry[name] then
    custom_id_registry[name] = script.generate_event_name()
  end
  return custom_id_registry[name]
end

-- saves a custom event ID
function event.save_id(name, id)
  if custom_id_registry[name] then
    log("Overwriting entry in custom event registry: "..name)
  end
  custom_id_registry[name] = id
end

-- updates the GUI filters for the given conditional event
function event.update_gui_filters(name, player_index, filters, mode)
  mode = mode or "overwrite"
  if type(filters) ~= "table" then
    filters = {filters}
  end
  local con_data = global.__lualib.event.conditional_events[name]
  if not con_data then
    error("Tried to update GUI filters for event ["..name.."], which is not enabled!")
  end

  local filters_table = con_data.gui_filters

  if mode == "overwrite" then
    local t = {}
    for _,filter in pairs(filters) do
      t[filter] = filter
    end
    filters_table[player_index] = t
  else
    -- retrieve or create player GUI filters table
    local player_filters = filters_table[player_index]
    if not player_filters then
      filters_table[player_index] = {}
      player_filters = filters_table[player_index]
    end
    -- modify filters
    if mode == "add" then -- add each one
      for _,filter in pairs(filters) do
        player_filters[filter] = filter
      end
    elseif mode == "remove" then -- remove each one
      for _,filter in pairs(filters) do
        player_filters[filter] = nil
      end
      -- remove filters table if it is empty
      if table_size(player_filters) == 0 then
        filters_table[player_index] = nil
      end
    end
  end

  -- return the filters
  return filters_table[player_index]
end

-- retrieves and returns GUI filters for the given conditional event and player
function event.get_gui_filters(name, player_index)
  local con_data = global.__lualib.event.conditional_events[name]
  if not con_data then
    error("Tried to retrieve GUI filters for conditional event ["..name.."], which is not enabled!")
  end
  return con_data.gui_filters[player_index]
end

-- retrieves and returns the global data for the given conditional event
function event.get_event_data(name)
  return global.__lualib.event.conditional_events[name]
end

-- returns true if the conditional event is registered
function event.is_enabled(name, player_index)
  local global_data = global.__lualib.event
  local registry = global_data.conditional_events[name]
  if registry then
    if player_index then
      for _,i in ipairs(registry.players) do
        if i == player_index then
          return true
        end
      end
      return false
    end
    return true
  end
  return false
end

-- -----------------------------------------------------------------------------

event.events = events
event.conditional_events = conditional_events
event.conditional_event_groups = conditional_event_groups

return event