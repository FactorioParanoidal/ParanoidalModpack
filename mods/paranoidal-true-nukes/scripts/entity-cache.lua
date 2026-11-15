-- Per-prototype caches and a filtered area search for the blast loops (Paranoidal, 9.0.0).
-- The cached values come from prototypes and never change during a game, so the lazily filled
-- module tables give the same answers on every peer (no desync, nothing to save).
local M = {}

-- Entity types without health. Skipping them in the engine saves one LuaEntity wrapper and several
-- API calls per entity; ore patches (one resource entity per tile in Angels fields) were the bulk.
M.no_health_types = {
  "resource", "corpse", "rail-remnants", "character-corpse", "item-entity", "entity-ghost", "tile-ghost",
  "item-request-proxy", "deconstructible-tile-proxy", "explosion", "fire", "sticker", "projectile",
  "artillery-projectile", "smoke-with-trigger", "particle-source", "stream", "beam", "arrow",
  "highlight-box", "speech-bubble", "cliff", "spider-leg"
}

function M.find_with_health(surface, area)
  return surface.find_entities_filtered{area = area, type = M.no_health_types, invert = true}
end

local health = {}
-- true if the entity's prototype has health (quality only scales it, never makes it zero)
function M.has_health(entity)
  local n = entity.name
  local v = health[n]
  if v == nil then
    v = entity.prototype.get_max_health() > 0
    health[n] = v
  end
  return v
end

local resist = {}
-- {decrease, percent} of the prototype's resistance to damage_type, or nil
function M.resistance(entity, damage_type)
  local n = entity.name
  local r = resist[n]
  if r == nil then
    r = {}
    local res = entity.prototype.resistances
    if res then
      for k, v in pairs(res) do
        r[k] = {v.decrease or 0, v.percent or 0}
      end
    end
    resist[n] = r
  end
  return r[damage_type]
end

-- damage left after a resistance, the way the original True Nukes code computed it
function M.after_resistance(entity, damage_type, damage)
  local r = M.resistance(entity, damage_type)
  if r then
    return (damage - r[1]) * (1 - r[2])
  end
  return damage
end

local flying = {}
-- cars/spider vehicles with an empty collision mask are aircraft (half blast damage, as in 1.1)
function M.is_flying(entity)
  local n = entity.name
  local v = flying[n]
  if v == nil then
    local mask = entity.prototype.collision_mask
    v = (mask == nil) or (mask.layers == nil) or (next(mask.layers) == nil)
    flying[n] = v
  end
  return v
end

-- LuaEntity.damage in 2.x is damage(amount, force, type, source, cause); True Nukes passed the cause
-- as the 4th argument (the source), so kills had no cause.
function M.hurt(entity, amount, force, damage_type, cause)
  if cause and cause.valid then
    return entity.damage(amount, force, damage_type, nil, cause)
  end
  return entity.damage(amount, force, damage_type)
end

-- Factorio's math.random(m, n) needs integer-sized bounds; damage next to the centre can be huge.
M.max_damage = 1e7

return M
