-- What the outbreak attacks with, on top of outbreak.lua: its artillery and the spidertrons it has taken.
--
-- Artillery. Every artillery turret it holds, set down in its lair or infected where it stands, is fired by this script
-- rather than by the engine, so it needs no ammunition and no charted map. From research stage 4 it fires the base
-- game's shell at the player's turrets and radars in range, a shell's worth of mass at a time; from the last stage it
-- fires spore shells (prototypes/arrival.lua) at any of the player's buildings instead, which open a zone where they land
-- and infect what's there (outbreak.lua, beast-spore-hit). An artillery wagon is lifted like any wagon.
--
-- Spidertrons. One it infects throws out whoever is inside, turns its guns on anything of the player's in reach and is
-- walked by its autopilot: home, and to every raid, where it sets down a few walking inserters it carries, for mass.
-- Its ammunition comes from the lair's mass. Cars and tanks only throw their driver out: inserters lift them (crawler).
--
-- 2.1: autopilot_destination, vehicle_automatic_targeting_parameters, indexed_guns, set_driver/get_driver and
-- create_entity of an artillery projectile with target and speed are the same in 2.1.24.
local shared = require("shared")
local config = require("script.config")
local infection = require("script.infection")
local outbreak = require("script.outbreak")

local lair_arms = {}

local force_name = "the-beast"
local target_force = "player"
local update_interval = 60
local shell_name = "artillery-projectile"
local spore_shell_name = "beast-spore-shell"
local shell_mass = 1
local shell_interval = 20 * 60
local spore_interval = 30 * 60
local idle_interval = 10 * 60
local fallback_range = 224
local fallback_min_range = 32
local shell_targets = {"ammo-turret", "electric-turret", "fluid-turret", "artillery-turret", "radar"}
-- Artillery this close together shares one search for targets.
local shared_search = 32
local spider_reach = 14
local spider_inserters = 3
local spider_arm_interval = 30 * 60
local spider_ammo = 10

local function data()
  local state = outbreak.state()
  if not state then return nil end
  state.artillery = state.artillery or {}
  state.spiders = state.spiders or {}
  return state
end

-- Whoever's in it gets out.
local function eject(vehicle)
  for _, get in pairs{"get_driver", "get_passenger"} do
    local ok, occupant = pcall(vehicle[get])
    if ok and occupant then
      local player = occupant.object_name == "LuaPlayer" and occupant or occupant.player
      if player and player.valid then
        player.driving = false
      else
        pcall(vehicle[get == "get_driver" and "set_driver" or "set_passenger"], nil)
      end
    end
  end
end

local function gun_parameters(entity)
  local ok, parameters = pcall(function()
    local guns = entity.prototype.indexed_guns
    return guns and guns[1] and guns[1].attack_parameters
  end)
  return ok and parameters or nil
end

local function watch_artillery(entity)
  local state = data()
  if not (state and outbreak.active()) then return end
  local parameters = gun_parameters(entity)
  state.artillery[entity.unit_number] =
  {
    entity = entity, next_shot = game.tick + shell_interval,
    range = parameters and parameters.range or fallback_range, min_range = parameters and parameters.min_range or fallback_min_range
  }
end

infection.on_infected["artillery-turret"] = watch_artillery
infection.on_infected["car"] = eject

-- How it was set to target, kept to give it back that way.
infection.on_infected["spider-vehicle"] = function(entity)
  eject(entity)
  local before = entity.vehicle_automatic_targeting_parameters
  entity.vehicle_automatic_targeting_parameters = {auto_target_with_gunner = true, auto_target_without_gunner = true}
  local state = data()
  if state and outbreak.active() then state.spiders[entity.unit_number] = {entity = entity, targeting = before} end
end

-- No longer its own: it stops walking off and targets as it did.
local function let_spider_go(entry)
  local entity = entry.entity
  if not entity.valid then return end
  entity.autopilot_destination = nil
  if entry.targeting then entity.vehicle_automatic_targeting_parameters = entry.targeting end
end

-- An artillery turret set down in the lair, stolen or cloned.
outbreak.on_building = function(building, sign)
  if building.type == "artillery-turret" and sign > 0 then watch_artillery(building.entity) end
end

-- What's in range of artillery here: one search for all of the lair's at once, kept for a volley (in storage, as it
-- decides what's hit).
local function targets_near(state, entry, spores)
  local entity = entry.entity
  local position = entity.position
  local cache = state.shell_targets
  if cache and cache.spores == spores and cache.surface == entity.surface.index and game.tick - cache.tick < shell_interval
    and outbreak.distance_squared(cache.position, position) <= shared_search * shared_search then
    return cache.list
  end
  local list = entity.surface.find_entities_filtered{position = position, radius = entry.range, force = target_force, type = spores and infection.infectable_types or shell_targets, limit = 40}
  state.shell_targets = {tick = game.tick, position = position, surface = entity.surface.index, spores = spores, list = list}
  return list
end

-- Something of the player's in range and not too close: their turrets and radars, or with spores anything it can infect.
local function pick_target(state, entry, spores)
  local position = entry.entity.position
  local choices = {}
  local nearest = entry.min_range * entry.min_range
  for _, target in pairs(targets_near(state, entry, spores)) do
    if target.valid and target.force.name == target_force and outbreak.distance_squared(target.position, position) >= nearest then choices[#choices + 1] = target end
  end
  if #choices == 0 then return nil end
  return choices[math.random(#choices)]
end

local function fire(state, entry)
  local entity = entry.entity
  local effects = state.effects
  local spores = effects.spores and config.get("spore-artillery") and prototypes.entity[spore_shell_name]
  local shells = effects.artillery and config.get("lair-artillery") and prototypes.entity[shell_name]
  if not (spores or shells) then
    entry.next_shot = game.tick + idle_interval
    return false
  end
  local target = pick_target(state, entry, spores)
  if not target or not outbreak.spend_mass(shell_mass) then
    entry.next_shot = game.tick + idle_interval
    return false
  end
  entity.surface.create_entity{name = spores and spore_shell_name or shell_name, position = entity.position, target = target, source = entity, force = force_name, speed = 1}
  entry.next_shot = game.tick + (spores and spore_interval or shell_interval)
  state.shells_fired = (state.shells_fired or 0) + 1
  return true
end

local function update_artillery(state, now)
  for unit_number, entry in pairs(state.artillery) do
    local entity = entry.entity
    if not (entity.valid and entity.force.name == force_name) then
      state.artillery[unit_number] = nil
    elseif now or game.tick >= entry.next_shot then
      fire(state, entry)
    end
  end
end

-- Ammunition for its guns, for mass.
local function arm_spider(entity)
  local ammo = outbreak.ammo_of(entity)
  local inventory = ammo and entity.get_inventory(defines.inventory.spider_ammo)
  if inventory and inventory.get_item_count() < spider_ammo and outbreak.spend_mass(1) then
    inventory.insert{name = ammo, count = spider_ammo}
  end
end

-- Lone walking inserters it carries, set down at a raid.
local function plant(entry, raid)
  local entity = entry.entity
  local name = shared.lone_name("inserter")
  if not (prototypes.entity[name] and outbreak.spawn_unit) then return end
  for i = 1, spider_inserters do
    if not outbreak.spend_mass(1) then break end
    local angle = i / spider_inserters * 2 * math.pi
    local spot = entity.surface.find_non_colliding_position(name, {x = entity.position.x + math.cos(angle) * 3, y = entity.position.y + math.sin(angle) * 3}, 6, 0.5)
    if spot then outbreak.spawn_unit(entity.surface, name, spot) end
  end
  entry.planted = raid.id
end

local function update_spiders(state)
  local raid = state.raid
  local home = outbreak.home()
  for unit_number, entry in pairs(state.spiders) do
    local entity = entry.entity
    if not (entity.valid and entity.force.name == force_name) then
      let_spider_go(entry)
      state.spiders[unit_number] = nil
    else
      local position = entity.position
      local goal = raid and raid.position or home
      if goal then
        local close = outbreak.distance_squared(position, goal) <= spider_reach * spider_reach
        if not close and not (entry.goal and entry.goal.x == goal.x and entry.goal.y == goal.y and entity.autopilot_destination) then
          entity.autopilot_destination = goal
          entry.goal = {x = goal.x, y = goal.y}
        end
        if close and raid and raid.arrived and entry.planted ~= raid.id then plant(entry, raid) end
        if close and not raid and not entry.sampled and outbreak.has_core() then
          outbreak.add_samples{place = entity.name, quality = entity.quality.name}
          entry.sampled = true
        end
      end
      if game.tick >= (entry.next_arm or 0) then
        entry.next_arm = game.tick + spider_arm_interval
        arm_spider(entity)
      end
    end
  end
end

table.insert(outbreak.on_update, function(state)
  data()
  update_artillery(state)
  update_spiders(state)
end)

-- Over: the artillery falls silent and the spidertrons stop where they are, targeting as they did (they're given back as
-- infected buildings).
table.insert(outbreak.on_end, function(state)
  for _, entry in pairs(state.spiders or {}) do let_spider_go(entry) end
  state.spiders = {}
  state.artillery = {}
end)

outbreak.hurry_hooks["fire"] = function(state)
  data()
  -- Looking again, for whatever has been built since the last volley.
  state.shell_targets = nil
  local fired = 0
  for _, entry in pairs(state.artillery) do
    if entry.entity.valid and fire(state, entry) then fired = fired + 1 end
  end
  return fired
end

table.insert(outbreak.status_hooks, function(state, status)
  local artillery, spiders = 0, 0
  for _ in pairs(state.artillery or {}) do artillery = artillery + 1 end
  for _ in pairs(state.spiders or {}) do spiders = spiders + 1 end
  status.artillery, status.spiders, status.shells_fired = artillery, spiders, state.shells_fired or 0
end)

return lair_arms
