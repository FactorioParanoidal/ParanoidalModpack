-- Robot Army: Replicator Citadel. Event wiring; the logic is in script/*.lua.
--
-- Cost while waiting for the evolution: one heartbeat per second that returns at once, a look at
-- the evolution once a minute. While the citadel lives: the heartbeat (a few foundries, the
-- gathering squad, one look at each attacking squad every two seconds, radar and repair looks),
-- the build queue only while something is being built, and the death event filtered to the
-- citadel's own droids and buildings. Nothing runs per droid per tick.
local S = require("lib.shared")
local state = require("script.state")
local forces = require("script.forces")
local B = require("script.builder")
local M = require("script.modules")
local UP = require("script.upgrades")
local C = require("script.citadel")

local HEARTBEAT = 60

--- Death filter: the replicator droids and the buildings that matter (keys, towers, walls, pylons).
--- One "name" filter per prototype (the filter takes a single name; the filters are joined by "or").
local function died_filter()
  local filters, seen = {}, {}
  local function add(name)
    if not seen[name] and prototypes.entity[name] then
      seen[name] = true
      filters[#filters + 1] = {filter = "name", name = name}
    end
  end
  for _, name in pairs(S.all_unit_names()) do add(name) end
  for _, name in pairs(M.key_names) do add(name) end
  for _, name in pairs(S.turrets) do add(name) end
  add(S.entity.wall)
  add(S.entity.gate)
  add(S.entity.pylon)
  return filters
end

local function on_init()
  C.init()
end

local function on_configuration_changed()
  state.read_settings()
  local c = state.get()
  if not c or c.schema ~= state.SCHEMA then
    -- no migrations: an unknown state starts over (the city of an old state stays as ruins)
    c = C.init()
  end
  forces.ensure()
  UP.apply(c)
  C.unlock_recipes(c)
end

local function on_load()
  state.read_settings()
  B.on_load(state.get())
end

script.on_init(on_init)
script.on_configuration_changed(on_configuration_changed)
script.on_load(on_load)
script.on_nth_tick(HEARTBEAT, C.heartbeat)

script.on_event(defines.events.on_entity_died, C.on_entity_died, died_filter())

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  if event.setting_type == "runtime-global" and string.sub(event.setting, 1, #S.mod) == S.mod then
    state.read_settings()
  end
end)

-- New forces: truce with the biters, war with the players; players get the decryption recipe.
local function on_forces_changed()
  forces.ensure()
  C.unlock_recipes(state.get())
end
script.on_event(defines.events.on_force_created, on_forces_changed)
script.on_event(defines.events.on_forces_merged, on_forces_changed)
script.on_event(defines.events.on_player_changed_force, on_forces_changed)
script.on_event(defines.events.on_player_created, on_forces_changed)

script.on_event(defines.events.on_technology_effects_reset, function(event)
  local c = state.get()
  if not c then return end
  if event.force.name == S.force then
    UP.on_effects_reset(c, event.force)
  else
    C.unlock_recipes(c)
  end
end)

---------------------------------------------------------------------------------------------------
-- Remote interface and command (tests and admins).
---------------------------------------------------------------------------------------------------
remote.add_interface(S.mod, {
  --- Phase, modules, droids, squads, upgrades ... (a copy).
  status = function() return C.status() end,
  --- Places the citadel now: at (x, y), or by the normal search when no position is given.
  spawn = function(x, y) return C.force_spawn(x, y) end,
  --- Adds n modules now (optional module type); returns how many were queued.
  grow = function(n, module_type) return C.force_grow(n, module_type) end,
  --- Every module (position, type, state, keys, last placement) and the squads (inspection).
  modules = function() return C.modules() end,
  squads = function() return C.squads() end,
  --- Overrides of the map settings for this save (tests, admins); configure(nil) clears them.
  configure = function(overrides) return C.configure(overrides) end,
  --- Destroys the citadel (as if its last foundry fell with the core down).
  defeat = function()
    local c = state.get()
    if c and c.phase == "active" then C.defeat(c, state.cfg) end
  end,
})

commands.add_command("citadel", {"replicator-message.command-help"}, function(command)
  local player = command.player_index and game.get_player(command.player_index)
  local status = C.status()
  local print = player and player.print or game.print
  if not status then return end
  print({"replicator-message.status", {"replicator-phase." .. status.phase}, status.modules, status.ruined,
    status.droids, status.squads, status.foundries, status.upgrades.intel, status.upgrades.armor,
    {"replicator.focus-" .. status.focus}, status.upgrades.damage * 10, status.known_chunks})
end)
