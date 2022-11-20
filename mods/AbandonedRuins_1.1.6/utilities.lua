local base_util = require("__core__/lualib/util")

local util = {}

util.ruin_half_sizes =
{
  small = 8 / 2,
  medium = 16 / 2,
  large = 32 / 2
}

util.ruin_min_distance_multiplier =
{
  small = 1,
  medium = 2.5,
  large = 5
}

util.debugprint = __DebugAdapter and __DebugAdapter.print or function() end

---@param chunk_position ChunkPosition
---@return MapPosition
util.get_center_of_chunk = function(chunk_position)
  return {x = chunk_position.x * 32 + 16, y = chunk_position.y * 32 + 16}
end

---@param half_size number
---@param center MapPosition
---@return BoundingBox
util.area_from_center_and_half_size = function(half_size, center)
  return {{center.x - half_size, center.y - half_size}, {center.x + half_size, center.y + half_size}}
end

---@param haystack string
---@param needles table<string, boolean> The boolean should always be true, it is ignored.
---@return boolean @True if the haystack contains at least one of the needles from the table
util.str_contains_any_from_table = function(haystack, needles)
  for needle in pairs(needles) do
    if haystack:find(needle, 1, true) then -- plain find, no pattern
      return true
    end
  end
  return false
end

-- TODO Bilka: this doesn't show in intellisense
---@param entity LuaEntity
---@param item_dict table<string, uint> Dictionary of item names to counts
util.safe_insert = base_util.insert_safe

---@param entity LuaEntity
---@param fluid_dict table<string, number> Dictionary of fluid names to amounts
util.safe_insert_fluid = function(entity, fluid_dict)
  if not (entity and entity.valid and fluid_dict) then return end
  local fluids = game.fluid_prototypes
  local insert = entity.insert_fluid
  for name, amount in pairs (fluid_dict) do
    if fluids[name] then
      insert{name = name, amount = amount}
    else
      log("Fluid to insert not valid: " .. name)
    end
  end
end

---@param entity LuaEntity
---@param damage_info Damage
---@param damage_amount number
util.safe_damage = function(entity, damage_info, damage_amount)
  if not (entity and entity.valid) then return end
  entity.damage(damage_amount, damage_info.force or "neutral", damage_info.type or "physical")
end

---@param entity LuaEntity
---@param chance number
util.safe_die = function(entity, chance)
  if not (entity and entity.valid) then return end
  if math.random() <= chance then entity.die() end
end

-- Set cease_fire status for all forces.
util.set_enemy_force_cease_fire = function(enemy_force, cease_fire)
  for _, force in pairs(game.forces) do
    if force ~= enemy_force then
      force.set_cease_fire(enemy_force, cease_fire)
      enemy_force.set_cease_fire(force, cease_fire)
    end
  end
end

-- Set cease_fire status for all forces and friend = true for all biter forces.
util.set_enemy_force_diplomacy = function(enemy_force, cease_fire)
  for _, force in pairs(game.forces) do
    if force.ai_controllable then
      force.set_friend(enemy_force, true)
      enemy_force.set_friend(force, true)
    end
  end
  util.set_enemy_force_cease_fire(enemy_force, cease_fire)
end

local function setup_enemy_force()
  local enemy_force = game.forces["AbandonedRuins:enemy"] or game.create_force("AbandonedRuins:enemy")

  util.set_enemy_force_diplomacy(enemy_force, false)

  global.enemy_force = enemy_force
  return enemy_force
end

util.get_enemy_force = function()
  if (global.enemy_force and global.enemy_force.valid) then
    return global.enemy_force
  end
  return setup_enemy_force()
end

return util
