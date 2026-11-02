-- Rain weakens fire and acid in combat while it rains on the surface of the damaged entity:
--   * fire and acid damage dealt by enemies (the "enemy" force or any AI-controlled force: biters, spitters, worms,
--     Rampant factions, their acid and burning puddles) is scaled by prain-enemy-fire-acid-damage (0 % by default);
--   * fire damage dealt by everyone else except "neutral" (flamethrowers of players, turrets, the flamethrower wagon
--     and the ground fire they leave) is scaled by prain-player-fire-damage (50 %).
-- Neutral fire (burning fluids of paranoidal-flammable-fluids, lightning fires, ammunition cook-off) is not touched.
-- The damage is given back as health right after it is dealt (on_entity_damaged, filtered by damage type). The
-- handler is registered only while it rains somewhere (storage.combat_on), so dry weather costs nothing.
local R = require("scripts.registry")

local M = {}
R.combat = M

local FILTERS = {
  { filter = "damage-type", type = "fire" },
  { filter = "damage-type", type = "acid", mode = "or" },
}

local registered = false

local function on_damaged(event)
  local force = event.force
  if not force or force.name == "neutral" then return end
  local entity = event.entity
  if not entity.valid then return end
  if not R.weather.is_raining(entity.surface_index) then return end
  local c = storage.cfg
  local keep
  if force.name == "enemy" or force.ai_controllable then
    keep = c.enemy_damage
  elseif event.damage_type.name == "fire" then
    keep = c.player_fire_damage
  else
    return
  end
  local back = event.final_damage_amount * (1 - keep)
  if back > 0 and entity.health then entity.health = entity.health + back end
end

local function wanted()
  local c = storage.cfg
  if not (c and c.enabled) then return false end
  if c.enemy_damage >= 1 and c.player_fire_damage >= 1 then return false end
  local weather = storage.weather
  if not weather then return false end
  for _, index in ipairs(R.surfaces.rain_indices()) do
    local w = weather[index]
    if w and w.phase == "wet" then return true end
  end
  return false
end

local function apply(on)
  if on == registered then return end
  registered = on
  script.on_event(defines.events.on_entity_damaged, on and on_damaged or nil, on and FILTERS or nil)
end

-- Recompute from storage (on_tick on a phase change, settings change). Deterministic on every peer.
function M.sync()
  local on = wanted()
  storage.combat_on = on or nil
  apply(on)
end

-- on_load: restore the registration without touching storage.
function M.on_load()
  apply(storage.combat_on == true)
end

return M
