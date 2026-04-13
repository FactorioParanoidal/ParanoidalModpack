local constants = require("lua/constants")
local utils = require("lua/utilities")
local ruinsets = require("lua/ruinsets")
local spawning = require("lua/spawning")
local surfaces = require("lua/surfaces")

---@type boolean
debug_log = settings.global[constants.ENABLE_DEBUG_LOG_KEY].value
---@type boolean
debug_utils = settings.global[constants.ENABLE_DEBUG_UTILS_KEY].value
---@type boolean
debug_on_tick = settings.global[constants.ENABLE_DEBUG_ON_TICK_KEY].value

-- Load events
require("lua/events")

remote.add_interface("AbandonedRuins",
{
  -- The event contains:
  ---@class on_entity_force_changed_event_data:EventData
  ---@field entity LuaEntity The entity that had its force changed.
  ---@field force LuaForce The entity that had its force changed.
  -- The current force can be gotten from event.entity.
  -- This is raised after the force is changed.
  -- Mod event subscription explanation can be found lower in this file.
  get_on_entity_force_changed_event = function() return on_entity_force_changed_event end,

  -- Set whether ruins should be spawned at all
  ---@param spawn_ruins boolean
  set_spawn_ruins = function(spawn_ruins)
    if debug_log then log(string.format("[set_spawn_ruins]: spawn_ruins[]=%s - CALLED!", type(spawn_ruins))) end
    if type(spawn_ruins) ~= "boolean" then
      error(string.format("spawn_ruins[]='%s' is not expected type 'boolean'", type(spawn_ruins)))
    end

    if debug_log then log(string.format("[set_spawn_ruins]: Setting spawn_ruins=%s", spawn_ruins)) end
    storage.spawn_ruins = spawn_ruins

    if debug_log then log("[set_spawn_ruins]: EXIT!") end
  end,

  -- Get whether ruins should be spawned at all
  ---@return boolean
  get_spawn_ruins = function() return storage.spawn_ruins end,

  -- Add ruin size and its halfed size
  ---@param size string
  ---@param half_size number
  add_ruin_size = function(size, half_size)
    if debug_log then log(string.format("[add_ruin_size]: size[]='%s',half_size[]='%s' - CALLED!", type(size), type(half_size))) end
    if type(size) ~= "string" then
      error(string.format("size[]='%s' is not expected type 'string'", type(size)))
    elseif utils.list_contains(spawning.ruin_sizes, size) then
      error(string.format("size='%s' is already added as ruin size", size))
    elseif type(half_size) ~= "number" then
      error(string.format("half_size[]='%s' is not expected type 'number'", type(half_size)))
    end

    if debug_log then log(string.format("[add_ruin_size]: Adding ruin size='%s',half_size=%d ...", size, half_size)) end
    table.insert(spawning.ruin_sizes, size)
    table.insert(utils.ruin_half_sizes, half_size)

    if debug_log then log("[add_ruin_size]: EXIT!") end
  end,

  -- Get all ruin sizes
  ---@return table
  get_ruin_sizes = function() return spawning.ruin_sizes end,

  -- Get all ruin-sets
  ---@return table<string, RuinSet>
  get_ruin_sets = function() return ruinsets.all() end,

  -- Any surface whose name contains this string will not have any ruins from any ruin-set mod spawned on it.
  -- Please note, that this feature is intended for "internal" or "hidden" surfaces, such as `NiceFill` uses
  -- and not for having an entire planet not having any ruins spawned.
  ---@param name string
  exclude_surface = function(name)
    if debug_log then log(string.format("[exclude_surface]: name[]='%s' - CALLED!", type(name))) end
    if type(name) ~= "string" then
      error(string.format("name[]='%s' is not expected type 'string'", type(name)))
    elseif game.surfaces[name] ~= nil and game.surfaces[name].planet ~= nil then
      error(string.format("Surface name='%s' is a planet surface. This function is for internal or underground surfaces only. If you want your ruins not spawning on a certain planet, use `no_spawning` for individual ruins or invoke the remote-call function `no_spawning_on` to exclude your ruin-set from a planet entirely.", name))
    end

    if not surfaces.is_excluded(name) then
      if debug_log then log(string.format("[exclude_surface]: Excluding surface name='%s' ...", name)) end
      surfaces.exclude(name)
    end

    if debug_log then log("[exclude_surface]: EXIT!") end
  end,

  -- You excluded a surface at some earlier point but you don't want it excluded anymore.
  ---@param name string
  reinclude_surface = function(name)
    if debug_log then log(string.format("[reinclude_surface]: name[]='%s' - CALLED!", type(name))) end
    if type(name) ~= "string" then
      error(string.format("name[]='%s' is not expected type 'string'", type(name)))
    elseif game.surfaces[name] ~= nil and game.surfaces[name].planet ~= nil then
      error(string.format("Surface name='%s' is a planet surface. This function is for internal or underground surfaces only. If you want your ruins not spawning on a certain planet, use `no_spawning` for individual ruins or invoke the remote-call function `no_spawning_on` to exclude your ruin-set from a planet entirely.", name))
    end

    if surfaces.is_excluded(name) then
      if debug_log then log(string.format("[reinclude_surface]: Reincluding surface name='%s' ...", name)) end
      surfaces.reinclude(name)
    end

    if debug_log then log("[reinclude_surface]: EXIT!") end
  end,

  -- !! ALWAYS call this in on_load and on_init. !!
  -- !! The ruins sets are not saved or loaded. !!
  -- The ruins should have the sizes given in utils.ruin_half_sizes, e.g. ruins in the small_ruins array should be 8x8 tiles.
  -- See also: docs/ruin_sets.md
  ---@param name string
  ---@param ruin_sets table<string, Ruins[]>
  add_ruin_sets = function(name, ruin_sets)
    if debug_log then log(string.format("[add_ruin_sets]: name[]='%s',ruin_sets[]='%s' - CALLED!", type(name), type(ruin_sets))) end
    if type(name) ~= "string" then
      error(string.format("name[]='%s' is not expected type 'string'", type(name)))
    elseif type(ruin_sets) ~= "table" then
      error(string.format("ruin_sets[]='%s' is not expected type 'table'", type(ruin_sets)))
    end

    if debug_log then log(string.format("[add_ruin_sets]: Setting name='%s' ruin sets ...", name)) end
    ruinsets.add(name, ruin_sets)

    if debug_log then log("[add_ruin_sets]: EXIT!") end
  end,

  -- !! The ruins sets are not saved or loaded. !!
  -- returns {small = {<array of ruins>}, medium = {<array of ruins>}, large = {<array of ruins>}}
  ---@param name string
  ---@return RuinSet
  get_ruin_set = function(name)
    if debug_log then log(string.format("[get_ruin_set]: name[]='%s' - CALLED!", type(name))) end
    if type(name) ~= "string" then
      error(string.format("name[]='%s' is not expected type 'string'", type(name)))
    elseif not ruinsets.isset(name) then
      if debug_log then log(string.format("[get_ruin_set]: name='%s' isn't a valid ruin-set name, returning nil ... - EXIT!", name)) end
      return nil
    end

    local sets = ruinsets.get(name)

    if debug_log then log(string.format("[get_ruin_set]: sets[%s][]='%s' - EXIT!", name, type(sets))) end
    return sets
  end,

  -- Returns a table with: {<size> = {<array of ruins>}, <size-n> = {<array of ruins>}}}
  ---@return RuinSet
  get_current_ruin_set = function()
    if debug_log then log(string.format("[get_current_ruin_set]: current-ruin-set='%s'", settings.global[constants.CURRENT_RUIN_SET_KEY].value)) end
    return ruinsets.get(settings.global[constants.CURRENT_RUIN_SET_KEY].value)
  end,

  -- Registers ruin-set name as exclusive to a surface
  ---@param surface_name string Surface's name to the ruin-set should be exclusive to
  ---@param ruinset_name string Name of the ruin-set that is exclusive to given surface (aka. planet/moon)
  spawn_exclusively_on = function(surface_name, ruinset_name)
    if debug_log then log(string.format("[spawn_exclusively_on]: surface_name[]='%s',ruinset_name[]='%s' - CALLED!", type(surface_name), type(ruinset_name))) end
    if type(surface_name) ~= "string" then
      error(string.format("surface_name[]='%s' is not expected type 'string'", type(surface_name)))
    elseif type(ruinset_name) ~= "string" then
      error(string.format("ruinset_name[]='%s' is not expected type 'string'", type(ruinset_name)))
    elseif spawning.no_spawning[surface_name] ~= nil and ruinset_name == spawning.no_spawning[surface_name] then
      error(string.format("ruinset_name='%s' is marked for 'no-spawning' at surface_name='%s' which is the opposite of exclusive", ruinset_name, surface_name))
    end

    if debug_log then log(string.format("[spawn_exclusively_on]: Registering surface_name='%s',ruinset_name='%s' as exclusive ...", surface_name, ruinset_name)) end
    spawning.exclusive_ruinset[surface_name] = ruinset_name

    if debug_log then log("[spawn_exclusively_on]: EXIT!") end
  end,

  -- Registers ruin-set name as "no-spawning" to a surface. This means that ruins from given set will not spawn on given surface.
  ---@param surface_name string Surface's name to the ruin-set should be exclusive to
  ---@param ruinset_name string Name of the ruin-set that is exclusive to given surface (aka. planet/moon)
  no_spawning_on = function(surface_name, ruinset_name)
    if debug_log then log(string.format("[no_spawning_on]: surface_name[]='%s',ruinset_name[]='%s' - CALLED!", type(surface_name), type(ruinset_name))) end
    if type(surface_name) ~= "string" then
      error(string.format("surface_name[]='%s' is not expected type 'string'", type(surface_name)))
    elseif type(ruinset_name) ~= "string" then
      error(string.format("ruinset_name[]='%s' is not expected type 'string'", type(ruinset_name)))
    elseif spawning.exclusive_ruinset[surface_name] ~= nil and ruinset_name == spawning.exclusive_ruinset[surface_name] then
      error(string.format("ruinset_name='%s' is marked for exclusive spawning at surface_name='%s' which is the opposite of 'no-spawning'", ruinset_name, surface_name))
    end

    if debug_log then log(string.format("[no_spawning_on]: Registering surface_name='%s',ruinset_name='%s' as 'no-spawning' ...", surface_name, ruinset_name)) end
    spawning.no_spawning[surface_name] = ruinset_name

    if debug_log then log("[no_spawning_on]: EXIT!") end
  end,
})

--[[ How to: Subscribe to mod events
  Basics: Get the event id from a remote interface. Subscribe to the event in on_init and on_load.

  Example:

  local init = function ()
    if script.active_mods["AbandonedRuins_updated_fork"] then
      script.on_event(remote.call("AbandonedRuins", "get_on_entity_force_changed_event"),
      ---@param event on_entity_force_changed_event_data
      function(event)
        -- An entity changed force, let's handle that
        local entity = event.entity
        local old_force = event.force
        local new_force = entity.force
        -- handle the force change
        utils.output_message("old: " .. old_force.name .. " new: " .. new_force.name)
      end)
    end
  end

  script.on_load(init)
  script.on_init(init)

--]]
