-- Load other libraries
local constants = require("constants")
local core_utils = require("__core__/lualib/util")

--- Cache for some functions below
local cache = {}

---@type boolean
local debug_utils = settings ~= nil and settings.global[constants.ENABLE_DEBUG_UTILS_KEY].value or false

-- Initialize "class"/library
local utilities = {}

utilities.debugprint = __DebugAdapter and __DebugAdapter.print or function() end

---@param chunk_position ChunkPosition
---@return MapPosition
utilities.get_center_of_chunk = function(chunk_position)
  return {x = chunk_position.x * 32 + 16, y = chunk_position.y * 32 + 16}
end

---@param half_size number
---@param center MapPosition
---@return BoundingBox
utilities.area_from_center_and_half_size = function(half_size, center)
  return {{center.x - half_size, center.y - half_size}, {center.x + half_size, center.y + half_size}}
end

---@param needle string Search this string for all below haystack
---@param haystack table<string, boolean> The boolean should always be true, it is ignored.
---@return boolean @True if the needle is found in the haystack
utilities.str_contains_any_from_table = function(needle, haystack)
  if debug_utils then log(string.format("[str_contains_any_from_table]: needle='%s',haystack[]='%s' - CALLED!", needle, type(haystack))) end
  if type(needle) ~= "string" then
    error(string.format("needle[]='%s' is not expected type 'string'", type(needle)))
  elseif #needle == 0 then
    error("Parameter 'needle' cannot be an empty string")
  elseif type(haystack) ~= "table" then
    error(string.format("haystack[]='%s' is not expected type 'table'", type(haystack)))
  elseif table_size(haystack) == 0 then
    log("[str_contains_any_from_table]: No haystack to search for, returing false - EXIT!")
    return false
  elseif cache["str_contains_any_from_table"] ~= nil and cache["str_contains_any_from_table"][needle] ~= nil then
    if debug_utils then log(string.format("[str_contains_any_from_table]: Found cache[%s]='%s' - EXIT!", needle, cache["str_contains_any_from_table"][needle])) end
    return cache["str_contains_any_from_table"][needle]
  elseif cache["str_contains_any_from_table"] == nil then
    -- Initialize own cache
    cache["str_contains_any_from_table"] = {}
  end

  -- Default is not found
  cache["str_contains_any_from_table"][needle] = false

  for key in pairs(haystack) do
    if debug_utils then log(string.format("[str_contains_any_from_table]: key='%s',needle[%s]='%s'", key, type(needle), needle)) end
    if key:find(needle, 1, true) then -- plain find, no pattern
      if debug_utils then log(string.format("[str_contains_any_from_table]: Found needle='%s' in key='%s' - BREAK!", needle, key)) end
      cache["str_contains_any_from_table"][needle] = true
      break
    end
  end

  if debug_utils then log(string.format("[str_contains_any_from_table]: cache[%s]='%s' EXIT!", needle, cache["str_contains_any_from_table"][needle])) end
  return cache["str_contains_any_from_table"][needle]
end

-- TODO Bilka: this doesn't show in intellisense
---@param entity LuaEntity
---@param item_dict table<string, uint> Dictionary of item names to counts
utilities.safe_insert = core_utils.insert_safe

---@param entity LuaEntity
---@param fluid_dict table<string, number> Dictionary of fluid names to amounts
utilities.safe_insert_fluid = function(entity, fluid_dict)
  if debug_utils then log(string.format("[safe_insert_fluid]: entity[]='%s',fluid_dict[]='%s' - CALLED!", type(entity), type(fluid_dict))) end
  if not (entity and entity.valid) then
    log(string.format("[safe_insert_fluid]: entity[]='%s' is not valid!", type(entity)))
    return
  elseif not fluid_dict then
    log(string.format("[safe_insert_fluid']: fluid_dict[]='%s' is not valid!", type(fluid_dict)))
    return
  end

  for name, amount in pairs (fluid_dict) do
    if debug_utils then log(string.format("[safe_insert_fluid]: name[%s]='%s',amount[%s]=%d", type(name), name, type(amount), amount)) end
    if prototypes.fluid[name] ~= nil and prototypes.fluid[name].valid then
      entity.insert_fluid({
        name   = name,
        amount = amount
      })
    else
      log(string.format("[safe_insert_fluid]: name='%s' is not a valid fluid to insert into entity.name='%s'", name, entity.name))
    end
  end

  if debug_utils then log("[safe_insert_fluid]: EXIT!") end
end

---@param entity LuaEntity
---@param damage_info Damage
----@param amount number Amount of damage being applied to the entity
utilities.safe_damage = function(entity, damage_info, amount)
  if debug_utils then log(string.format("[safe_damage]: entity[]='%s',damage_info[]='%s',amount=%d' - CALLED!", type(entity), type(damage_info), amount)) end
  if not (entity and entity.valid) then
    log(string.format("[safe_damage]: entity[]='%s' is not valid!", type(entity)))
    return
  elseif type(amount) ~= "number" then
    error(string.format("Parameter amount[]='%s' is not expected type 'number'", type(amount)))
  elseif amount < 0 then
    error(string.format("Parameter amount=%.2f is below zero.", amount))
  end

  if amount > 0 then
    if debug_utils then log(string.format("[safe_damage]: Applying damage amount=%.2f to entity.name='%s' ...", amount, entity.name)) end
    entity.damage(amount, damage_info.force or "neutral", damage_info.type or "physical")
  elseif debug_utils then
    log(string.format("[safe_damage]: entity.name='%s' is no damage applied to.", entity.name))
  end

  if debug_utils then log("[safe_damage]: EXIT!") end
end

---@param entity LuaEntity
---@param chance number
utilities.safe_die = function(entity, chance)
  if debug_utils then log(string.format("[safe_die]: entity[]='%s',chance=%d - CALLED!", type(entity), chance)) end
  if not (entity and entity.valid) then
    log(string.format("[safe_die]: entity[]='%s' is not valid!", type(entity)))
    return
  elseif type(chance) ~= "number" then
    error(string.format("chance[]='%s' is not expected type 'number'", type(chance)))
  elseif chance <= 0 then
    error(string.format("Parameter chance=%.2f cannot be zero or below", chance))
  end

  if math.random() <= chance then
    entity.die()
  end

  if debug_utils then log("[safe_die]: EXIT!") end
end

-- Set cease_fire status for all forces.
---@param enemy_force LuaForce
---@param cease_fire boolean
utilities.set_enemy_force_cease_fire = function(enemy_force, cease_fire)
  if debug_utils then log(string.format("[set_enemy_force_cease_fire]: enemy_force[]='%s',cease_fire='%s'", type(enemy_force), cease_fire)) end
  if type(cease_fire) ~= "boolean" then
    error(string.format("cease_fire[]='%s' is not of expected type 'boolean'", type(cease_fire)))
  end

  for _, force in pairs(game.forces) do
    if debug_utils then log(string.format("[set_enemy_force_cease_fire]: force[]='%s'", type(force))) end
    if force ~= enemy_force then
      force.set_cease_fire(enemy_force, cease_fire)
      enemy_force.set_cease_fire(force, cease_fire)
    end
  end

  if debug_utils then log("[set_enemy_force_cease_fire]: EXIT!") end
end

-- Set cease_fire status for all forces and friend = true for all biter forces.
---@param enemy_force LuaForce
---@param cease_fire boolean
utilities.set_enemy_force_diplomacy = function(enemy_force, cease_fire)
  if debug_utils then log(string.format("[set_enemy_force_diplomacy]: enemy_force[]='%s',cease_fire='%s'", type(enemy_force), cease_fire)) end
  if type(cease_fire) ~= "boolean" then
    error(string.format("cease_fire[]='%s' is not of expected type 'boolean'", type(cease_fire)))
  end

  for _, force in pairs(game.forces) do
    if debug_utils then log(string.format("[set_enemy_force_diplomacy]: force[]='%s'", type(force))) end
    if force.ai_controllable then
      force.set_friend(enemy_force, true)
      enemy_force.set_friend(force, true)
    end
  end

  utilities.set_enemy_force_cease_fire(enemy_force, cease_fire)

  if debug_utils then log("[set_enemy_force_diplomacy]: EXIT!") end
end

-- Setups configured enemy force and returns it
---@return LuaForce
local function setup_enemy_force()
  ---@type LuaForce
  if debug_utils then log("[setup_enemy_force]: CALLED!") end
  local enemy_force = game.forces["AbandonedRuins:enemy"] or game.create_force("AbandonedRuins:enemy")

  if debug_utils then log(string.format("[setup_enemy_force]: Setting enemy_force='%s' ...", enemy_force)) end
  utilities.set_enemy_force_diplomacy(enemy_force, false)
  storage.enemy_force = enemy_force

  if debug_utils then log(string.format("[setup_enemy_force]: enemy_force[]='%s' - EXIT!", type(enemy_force))) end
  return enemy_force
end

-- Safely returns "cached" enemy force or sets it up if not present
---@return LuaForce
utilities.get_enemy_force = function()
  if debug_utils then log("[get_enemy_force]: CALLED!") end
  if (storage.enemy_force and storage.enemy_force.valid) then
    if debug_utils then log(string.format("[get_enemy_force]: storage.enemy_force='%s' - EXIT!", storage.enemy_force)) end
    return storage.enemy_force
  end

  if debug_utils then log("[get_enemy_force]: Invoking setup_enemy_force() - EXIT!") end
  return setup_enemy_force()
end

-- "Registers" this ruin set's name to the selection box
---@param name string
---@param is_default boolean
utilities.register_ruin_set = function(name, is_default)
  if debug_utils then log(string.format("[register_ruin_set]: name='%s',is_default='%s' - CALLED!", name, is_default)) end
  if type(name) ~= "string" then
    error(string.format("name[]='%s' is not expected type 'string'", type(name)))
  elseif #name == 0 then
    error("Parameter 'name' cannot be an empty string")
  elseif type(is_default) ~= "boolean" then
    error(string.format("is_default[]='%s' is not expected type 'boolean'", type(is_default)))
  end

  -- First get settings
  local set = data.raw["string-setting"][constants.CURRENT_RUIN_SET_KEY]

  -- Add this ruin set's name to it
  table.insert(set.allowed_values, name)

  -- Set it as default
  if is_default then
    set.default_value = name
  end

  if debug_utils then log("[register_ruin_set]: EXIT!") end
end

-- Returns "unknown" if optional (but recommended) table key `name` isn't found or otherwise it returns that key's value
---@param ruin Ruin
---@return string
utilities.get_ruin_name = function(ruin)
  if debug_utils then log(string.format("[get_ruin_name]: ruin[]='%s' - CALLED!", type(ruin))) end
  if type(ruin) ~= "table" then
    error(string.format("ruin[]='%s' is not of expected type 'table'", type(ruin)))
  end

  local name = "unknown"

  if type(ruin.name) == "string" and ruin.name ~= "" then
    if debug_utils then log(string.format("[get_ruin_name]: Setting ruin.name='%s' ...", ruin.name)) end
    name = ruin.name
  end

  if debug_utils then log(string.format("[get_ruin_name]: name='%s' - EXIT!", type(name))) end
  return name
end

-- Outputs game message, if `game` is populated, otherwise it will be logged
---@param message string Message to be printed out or logged
utilities.output_message = function(message)
  if debug_utils then log(string.format("[output_message]: message='%s' - CALLED!", message)) end
  if type(message) ~= "string" then
    error(string.format("message[]='%s' is not of expected type 'string'", type(message)))
  end

  if game then
    game.print(message)
  else
    log(message)
  end

  if debug_utils then log("[output_message]: EXIT!") end
end

-- Checks if given value is found in list
---@param list {} A list of values
---@param value any Any value to be found in list
---@return found boolean
utilities.list_contains = function (list, value)
  if debug_utils then log(string.format("[list_contains]: list[]='%s',value[]='%s' - CALLED!", type(list), type(value))) end
  local found = false

  for i=1, #list do
    if list[i] == value then
      if debug_utils then log(string.format("[list_contains]: value[]='%s' was found at i=%d - BREAK!", type(value), i)) end
      found = true
      break
    end
  end

  if debug_utils then log(string.format("[list_contains]: found=%s - EXIT!", found)) end
  return found
end

return utilities
