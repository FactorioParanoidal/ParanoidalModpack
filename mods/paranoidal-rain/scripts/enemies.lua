-- Enemies are bolder in the rain (while it rains on any rain surface):
--   * damage: the "enemy" force gets +prain-enemy-day-percent (day) or +prain-enemy-night-percent (night) on its ammo
--     damage modifiers of CATEGORIES (bites, spits). Only the difference is added and later taken back, so modifiers
--     set by other mods stay. Enemy fire and acid stay at prain-enemy-fire-acid-damage (scripts/combat.lua).
--   * attacks (prain-enemy-more-attacks): map_settings.pollution.enemy_attack_pollution_consumption_modifier is divided
--     by 1 + the same percent (less pollution per attacker -> more attacks). Applied as a factor over the current value
--     and divided back after the rain; if the mod is removed while it rains the factor stays (known risk).
-- Night: darkness of the raining surface >= NIGHT_DARKNESS. Checked every CHECK ticks; changes only on a difference.
local R = require("scripts.registry")

local M = {}
R.enemies = M

M.CHECK = 600
local CATEGORIES = { "melee", "biological" }
local NIGHT_DARKNESS = 0.4

local function apply(boost, attack_factor)
  local s = storage.enemy_boost or { boost = 0, factor = 1 }
  local force = game.forces.enemy
  if force and s.boost ~= boost then
    for _, category in ipairs(CATEGORIES) do
      if prototypes.ammo_category[category] then
        force.set_ammo_damage_modifier(category, force.get_ammo_damage_modifier(category) - s.boost + boost)
      end
    end
    s.boost = boost
  end
  if s.factor ~= attack_factor then
    local pollution = game.map_settings.pollution
    local base = pollution.enemy_attack_pollution_consumption_modifier / s.factor
    pollution.enemy_attack_pollution_consumption_modifier = base * attack_factor
    s.factor = attack_factor
  end
  if s.boost == 0 and s.factor == 1 then
    storage.enemy_boost = nil
  else
    storage.enemy_boost = s
  end
end

-- on_nth_tick(CHECK), phase changes and setting changes.
function M.sync()
  local c = storage.cfg
  local boost = 0
  if c and c.enabled and (c.enemy_day > 0 or c.enemy_night > 0) then
    local weather = storage.weather
    for _, index in ipairs(R.surfaces.rain_indices()) do
      local w = weather and weather[index]
      if w and w.phase == "wet" then
        local surface = R.surfaces.get(index)
        local night = surface and surface.darkness >= NIGHT_DARKNESS
        local b = night and c.enemy_night or c.enemy_day
        if b > boost then boost = b end
      end
    end
  end
  if not storage.enemy_boost and boost == 0 then return end
  local factor = 1
  if boost > 0 and c.enemy_attacks then factor = 1 / (1 + boost) end
  apply(boost, factor)
end

return M
