util = require("util")

-- Paranoidal Flammable Fluids: Flammable Oils (Paranoidal fork) and the Paranoidal fire safety turrets.
-- Modules (scripts/):
--   scheduler    delayed tasks, on_tick only while something burns, per-tick budgets
--   core         explosions (upstream formulas), deaths, heat damage, chemical accidents
--   fx           pollution, blast tiers (shake, sound, shock wave, scorch), fire rings
--   fuse         fire crawling through connected pipes
--   tanks        overheating storage tanks: burn, black smoke, catastrophe
--   cookoff      ammunition stores popping slower, then faster
--   alerts       map alerts and chat messages (setting flo-map-alerts)
--   traps        oil ruin traps of paranoidal-ruins
--   fire-safety  water turrets: put out fires, protect their zone (protection = direct check)
--   weather      rain of paranoidal-rain slows tanks, fuses and cook-off down (remote hazard_slowdown)
--   demo         test scene: /c remote.call("flammable_oils", "demo", game.player)
-- All game state lives in storage; module tables only cache prototype-derived data.

local FO = require("scripts.registry")
local C = require("scripts.config")
require("scripts.scheduler")
require("scripts.weather")
require("scripts.fire-safety")
require("scripts.protection")
require("scripts.fluids")
require("scripts.fx")
require("scripts.core")
require("scripts.fuse")
require("scripts.tanks")
require("scripts.cookoff")
require("scripts.alerts")
require("scripts.achievements")
require("scripts.traps")
require("scripts.demo")

-- Deaths that can matter: entities that may hold fluid, ammunition stores, tanks. Pumps excluded
-- (upstream 0.2.19). Built from prototypes, so it is the same on every peer.
local function death_filters()
  local types, list = {}, {}
  local function add(entity_type)
    if entity_type ~= "pump" and not types[entity_type] then
      types[entity_type] = true
      list[#list + 1] = entity_type
    end
  end
  add("fluid-wagon")
  add("storage-tank")
  for entity_type in pairs(C.CONTAINER_INVENTORIES) do add(entity_type) end
  for _, proto in pairs(prototypes.entity) do
    local entity_type = proto.type
    if not types[entity_type] and (#proto.fluidbox_prototypes > 0 or proto.fluid_energy_source_prototype) then
      add(entity_type)
    end
  end
  table.sort(list)
  local filters = {}
  for _, entity_type in ipairs(list) do
    filters[#filters + 1] = { filter = "type", type = entity_type, mode = "or" }
  end
  return filters
end

local function type_filters(types)
  local filters = {}
  for _, entity_type in ipairs(types) do
    filters[#filters + 1] = { filter = "type", type = entity_type, mode = "or" }
  end
  return filters
end

local function name_filters(names)
  local filters = {}
  for _, name in ipairs(names) do
    filters[#filters + 1] = { filter = "name", name = name, mode = "or" }
  end
  return filters
end

local E = defines.events
local BUILT_EVENTS = { E.on_built_entity, E.on_robot_built_entity, E.script_raised_built, E.script_raised_revive }

-- Event handlers are not saved: register in on_init and on_load (filters come from prototypes).
local function register()
  script.on_event(E.on_entity_died, FO.core.on_entity_died, death_filters())
  script.on_event(E.on_entity_damaged, FO.core.on_entity_damaged, type_filters(C.DAMAGE_EVENT_TYPES))

  local turrets = FO.safety.names()
  if #turrets > 0 then
    local filters = name_filters(turrets)
    for _, event in ipairs(BUILT_EVENTS) do script.on_event(event, FO.safety.on_built, filters) end
    script.on_event(E.on_entity_cloned, FO.safety.on_built, filters)
    script.on_event(E.script_raised_teleported, FO.safety.on_reoriented, filters)
    script.on_event({ E.on_player_rotated_entity, E.on_player_flipped_entity }, FO.safety.on_reoriented)
    script.on_event(E.on_object_destroyed, FO.safety.on_object_destroyed)
    script.on_event(E.on_script_trigger_effect, FO.safety.on_hit)
    script.on_nth_tick(FO.safety.STEP, FO.safety.update)
  end

  FO.sched.sync()
  FO.traps.sync()
  FO.traps.subscribe()
end

script.on_init(function()
  register()
  FO.safety.sync()
end)

script.on_load(function()
  register()
  FO.safety.on_load()
end)

script.on_configuration_changed(function()
  FO.fluids.reset()
  FO.sched.sync()
  FO.safety.sync()
end)

remote.add_interface("flammable_oils", {
  get_flammable_types = function()
    return util.table.deepcopy(FO.fluids.flammable_types())
  end,
  -- Start the overheating of a storage tank (e.g. scenarios, other mods).
  ignite_tank = function(entity, cause)
    if entity and entity.valid then FO.tanks.ignite(entity, cause or { "flo-cause.unknown" }) end
  end,
  -- Start the cook-off of a store with ammunition as fire next to it would (chests, wagons, vehicles, gun and
  -- artillery turrets); e.g. a lightning strike (paranoidal-rain).
  cook_off = function(entity)
    if entity and entity.valid then FO.cook.start(entity) end
  end,
  -- Water (zzzparanoidal-start-bnl barrel): stop the overheating of a tank or the cook-off of a store.
  extinguish = function(entity)
    if not (entity and entity.valid) then return false end
    local tank = FO.tanks.extinguish(entity)
    local cook = FO.cook.stop(entity)
    return tank or cook
  end,
  -- Water poured on a spot: every burning tank and cooking store reaching into radius; returns their number.
  extinguish_area = function(surface_index, position, radius)
    if type(surface_index) ~= "number" or not position or type(radius) ~= "number" then return 0 end
    local p = { x = position.x or position[1], y = position.y or position[2] }
    return FO.tanks.extinguish_area(surface_index, p, radius) + FO.cook.stop_area(surface_index, p, radius)
  end,
  -- Test scene east of the player.
  demo = function(player)
    FO.demo.start(player)
  end,
})
