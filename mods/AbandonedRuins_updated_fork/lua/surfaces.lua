--- "Class/library" for surface handling
local surfaces = {}

-- Initializes persisted table `excluded` if not found
local function init_excluded ()
  if debug_log then log("[init_excluded]: CALLED!") end

  -- Has the storage been initialized?
  if debug_log then log(string.format("[init_excluded]: storage.excluded[]='%s'", type(storage.excluded))) end
  if storage.excluded == nil then
    -- Always-excluded surfaces (intended for "internal" surfaces, DO NOT add your planet here)
    -- Surfaces listed (and later added by invoking remote-call function `exclude_surface`) here
    -- will have NO ruins at spawned on. If you want to have some ruin-sets not being spawned
    -- on your planet DO NOT add it here, use remote-call function `no_spawning_on` instead.
    --
    -- I will refuse ALL requests of planets or any other further surface being added here. Your
    -- mod can simply invoke any of both mentioned remote-call function of having your surface
    -- excluded.
    ---@type table<string, boolean>
    -- @todo Move this all to the corresponding mods, as they can invoke
    -- @todo remote-interface function `exclude_surface` instead of this list is
    -- @todo getting longer and longer over the time.
    if debug_log then log("[init_excluded]: Initializing storage.excluded table ...") end
    storage.excluded = {
      ["beltlayer"]     = true,
      ["pipelayer"]     = true,
      ["Factory floor"] = true, -- factorissimo2
      ["factory-floor"] = true, -- factorissimo3
      ["NiceFill"]      = true, -- NiceFill's hidden surface
      ["aai-signals"]   = true  -- AAI Signals' hidden surface
    }
  end

  if debug_log then log("[init_excluded]: EXIT!") end
end

-- Returns all excluded surfaces
---@return table<string, boolean>
function surfaces.get_all_excluded()
  if debug_log then log("[get_all_excluded]: CALLED!") end

  -- Init table (if not found)
  init_excluded()

  if debug_log then log(string.format("[get_all_excluded]: storage.excluded[]='%s' - EXIT!", type(storage.excluded))) end
  return storage.excluded
end

-- Any surface whose name contains this string will not have ruins generated on it.
---@param name string
function surfaces.exclude(name)
  if debug_log then log(string.format("[exclude]: name[]='%s' - CALLED!", type(name))) end
  if type(name) ~= "string" then
    error(string.format("name[]='%s' is not expected type 'string'", type(name)))
  elseif game.surfaces[name] ~= nil and game.surfaces[name].planet ~= nil then
    error(string.format("Surface name='%s' is a planet surface. This function is for internal or underground surfaces only. If you want your ruins not spawning on a certain planet, use `no_spawning` for individual ruins or invoke the remote-call function `no_spawning_on` to exclude your ruin-set from a planet entirely.", name))
  elseif storage.excluded[name] ~= nil then
    error(string.format("name='%s' is already added to storage.excluded table", name))
  end

  -- Init table (if not found)
  init_excluded()

  if debug_log then log(string.format("[exclude]: Excluding surface name='%s' ...", name)) end
  storage.excluded[name] = true

  if debug_log then log("[exclude]: EXIT!") end
end

-- You excluded a surface at some earlier point but you don't want it excluded anymore.
---@param name string
function surfaces.reinclude(name)
  if debug_log then log(string.format("[reinclude]: name[]='%s' - CALLED!", type(name))) end
  if type(name) ~= "string" then
    error(string.format("name[]='%s' is not expected type 'string'", type(name)))
  elseif game.surfaces[name] ~= nil and game.surfaces[name].planet ~= nil then
    error(string.format("Surface name='%s' is a planet surface. This function is for internal or underground surfaces only. If you want your ruins not spawning on a certain planet, use `no_spawning` for individual ruins or invoke the remote-call function `no_spawning_on` to exclude your ruin-set from a planet entirely.", name))
  elseif storage.excluded[name] == nil then
    error(string.format("name='%s' is already removed from storage.excluded table", name))
  end

  -- Init table (if not found)
  init_excluded()

  if debug_log then log(string.format("[reinclude]: Reincluding surface name='%s' ...", name)) end
  storage.excluded[name] = nil

  if debug_log then log("[reinclude]: EXIT!") end
end

-- Checks whether given surface name is i exclusion table
---@param name string
---@return boolean Whether surface is in exclusion list
function surfaces.is_excluded(name)
  if debug_log then log(string.format("[is_excluded]: name[]='%s' - CALLED!", type(name))) end
  if type(name) ~= "string" then
    error(string.format("name[]='%s' is not expected type 'string'", type(name)))
  end

  -- Init table (if not found)
  init_excluded()

  local is_excluded = (storage.excluded[name] ~= nil and storage.excluded[name])

  if debug_log then log(string.format("[is_excluded]: is_excluded='%s' - EXIT!", is_excluded)) end
  return is_excluded
end

return surfaces
