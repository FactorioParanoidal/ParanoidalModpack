-- Upgrades of the citadel from its standing modules (a ruined module stops giving its bonus):
--   armoury        armour mark of the new droids (1 per armoury, at most S.marks)
--   arsenal        +10 % damage of the droid weapons and towers (no limit)
--   targeting      +8 % rate of fire (no limit)
--   computing core intelligence level (at most 6, script/intel.lua)
--   shield modules levels of the shield research of Defence Tower Reforged for the citadel force
-- Damage and rate are force bonuses on the own ammo categories of the citadel (copies of the droid
-- categories, S.own_ammo): no cost in a fight. The armour
-- focus follows the killing blows of the lost droids (adaptive armour).
local S = require("lib.shared")
local forces = require("script.forces")

local UP = {}

UP.DAMAGE_PER_ARSENAL = 0.1
UP.RATE_PER_TARGETING = 0.08
UP.MAX_INTEL = 6
local ADAPT_MIN_DEATHS = 15

local SHIELD_BASE = "turret-shields-base"
local SHIELD_SIZE = "turret-shields-size"
local SHIELD_RATE = "turret-shields-speed"
local SHIELD_TECH = {["shield-amplifier"] = SHIELD_SIZE, ["shield-regenerator"] = SHIELD_RATE}
--- Range levels of the defence tower: with all ten its square (+-17 tiles) covers the whole module.
local TOWER_RANGE = "repair-turret-range-"
local TOWER_RANGE_LEVELS = 10

local applying = false

local function set_level(tech, done)
  if not tech then return end
  local max = tech.prototype.max_level
  if done <= 0 then
    if tech.researched then tech.researched = false end
    if tech.level ~= tech.prototype.level then tech.level = tech.prototype.level end
  elseif max and done >= max then
    tech.level = max
    tech.researched = true
  else
    if tech.researched then tech.researched = false end
    tech.level = tech.prototype.level + done
  end
end

--- Shields need Defence Tower Reforged (its tower and, with its research setting on, its research).
function UP.shields_available()
  if not script.active_mods["defence-tower-reforged"] or not prototypes.entity[S.entity.shield_tower] then return false end
  local research = settings.startup["kts-research"]
  return research ~= nil and (not research.value or prototypes.technology[SHIELD_BASE] ~= nil)
end

--- Research-off towers still provide base shields. Only offered upgrades require these levels.
function UP.shield_limit(kind)
  if not UP.shields_available() or not settings.startup["kts-research"].value then return 0 end
  local tech = prototypes.technology[SHIELD_TECH[kind]]
  return tech and tech.max_level or 0
end

local function apply_force(c, force)
  local u = c.upgrades
  for _, from in pairs(S.damage_categories) do
    local cat = S.own_ammo(from)
    if prototypes.ammo_category[cat] then force.set_ammo_damage_modifier(cat, UP.DAMAGE_PER_ARSENAL * u.damage) end
  end
  for _, from in pairs(S.ammo_categories) do
    local cat = S.own_ammo(from)
    if prototypes.ammo_category[cat] then force.set_gun_speed_modifier(cat, UP.RATE_PER_TARGETING * u.rate) end
  end
end

--- Recomputes the upgrades from the standing modules and applies them to the force.
function UP.apply(c)
  if applying then return end
  applying = true
  local force = forces.get()
  local a = c.alive
  local u = c.upgrades
  u.armor = math.min(S.marks, a.armory or 0)
  u.damage = a.arsenal or 0
  u.rate = a.targeting or 0
  u.intel = math.min(UP.MAX_INTEL, a["ai-core"] or 0)
  if c.shields and not UP.shields_available() then c.shields = false end
  local size, rate, mode = 0, 0, nil
  if c.shields then
    size = math.min(a["shield-amplifier"] or 0, UP.shield_limit("shield-amplifier"))
    rate = math.min(a["shield-regenerator"] or 0, UP.shield_limit("shield-regenerator"))
    mode = settings.startup["kts-research"].value and "research" or "base"
  else
    u.shield_on, u.shield_mode, u.shield_size, u.shield_rate = nil, nil, 0, 0
  end
  if mode and (mode ~= u.shield_mode or size ~= u.shield_size or rate ~= u.shield_rate) then
    u.shield_size, u.shield_rate, u.shield_on, u.shield_mode = size, rate, true, mode
    local techs = force.technologies
    if mode == "research" then techs[SHIELD_BASE].researched = true end
    for i = 1, TOWER_RANGE_LEVELS do
      local t = techs[TOWER_RANGE .. i]
      if t and not t.researched then t.researched = true end
    end
    if mode == "research" then
      set_level(techs[SHIELD_SIZE], size)
      set_level(techs[SHIELD_RATE], rate)
    end
    -- Defence Tower Reforged reads the levels again on this event; it also resets the force bonuses,
    -- which are set again below.
    force.reset_technology_effects()
  end
  apply_force(c, force)
  applying = false
end

--- Another script reset the technology effects of the citadel force: set the bonuses again.
function UP.on_effects_reset(c, force)
  if applying or not c then return end
  apply_force(c, force)
end

--- Adaptive armour: the focus of the new droids follows the damage that killed most of them.
function UP.adapt(c)
  if (c.upgrades.armor or 0) <= 0 then return end
  local d = c.deaths
  local total = d.kinetic + d.energy + d.chemical
  if total < ADAPT_MIN_DEATHS then return end
  local best, best_n = "balanced", 0
  for _, focus in ipairs({"kinetic", "energy", "chemical"}) do
    if d[focus] > best_n then best, best_n = focus, d[focus] end
  end
  if best_n < total * 0.45 then best = "balanced" end
  c.focus = best
  for k, v in pairs(d) do d[k] = math.floor(v / 2) end
end

function UP.on_death(c, damage_type)
  local group = damage_type and S.focus_of_damage[damage_type]
  if group then c.deaths[group] = c.deaths[group] + 1 end
end

return UP
