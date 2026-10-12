util = require("util")

-- Paranoidal fork, see PARANOIDAL-CHANGES.md. Modules (scripts/):
--   scheduler  delayed tasks, on_tick only while something burns, per-tick budgets
--   core       explosions (upstream formulas), deaths, heat damage, chemical accidents
--   fx         pollution, blast tiers (shake, sound, shock wave, scorch), fire rings
--   fuse       fire crawling through connected pipes
--   tanks      overheating storage tanks: burn, black smoke, catastrophe
--   cookoff    ammunition stores popping slower, then faster
--   alerts     map alerts and chat messages (setting flo-map-alerts)
--   traps      oil ruin traps of AbandonedRuins-paranoidal
--   demo       test scene: /c remote.call("flammable_oils", "demo", game.player)
-- All game state lives in storage; module tables only cache prototype-derived data.

local FO = require("scripts.registry")
local C = require("scripts.config")
require("scripts.scheduler")
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

local function damage_filters()
  local filters = {}
  for _, entity_type in ipairs(C.DAMAGE_EVENT_TYPES) do
    filters[#filters + 1] = { filter = "type", type = entity_type, mode = "or" }
  end
  return filters
end

local function register()
  script.on_event(defines.events.on_entity_died, FO.core.on_entity_died, death_filters())
  script.on_event(defines.events.on_entity_damaged, FO.core.on_entity_damaged, damage_filters())
  FO.sched.sync()
  FO.traps.sync()
  FO.traps.subscribe()
end

script.on_init(register)
script.on_load(register)

script.on_configuration_changed(function()
  FO.fluids.reset()
  FO.sched.migrate()
  FO.sched.sync()
end)

remote.add_interface("flammable_oils", {
  add_flammable_type = function(name)
    FO.fluids.set_override(name, true)
  end,
  remove_flammable_type = function(name)
    FO.fluids.set_override(name, false)
  end,
  get_flammable_types = function()
    return util.table.deepcopy(FO.fluids.flammable_types())
  end,
  -- Start the overheating of a storage tank (e.g. scenarios, other mods).
  ignite_tank = function(entity)
    if entity and entity.valid then FO.tanks.ignite(entity, { "flo-cause.unknown" }) end
  end,
  -- Test scene east of the player.
  demo = function(player)
    FO.demo.start(player)
  end,
})
