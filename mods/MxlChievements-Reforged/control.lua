-- Scripted achievements (prototypes/scripted.lua, trackers in scripts/trackers.lua).
-- Achievements are an addition to the game, so this script must never disturb it:
--   * every tracker runs inside pcall; a failing tracker is switched off with a log line until the
--     next configuration change, the others keep working;
--   * a tracker is active only when its achievement prototypes exist (the data stage skips them when
--     a mod, an entity or an item is missing) and a remote interface is called only when it exists;
--   * the map setting "mxlr-scripted-achievements" stops all tracking;
--   * any error while setting up leaves the script without handlers instead of stopping the load.
-- Unlocks: player progress unlocks for that player, force progress for all players of the force,
-- world progress for everyone. Force and world unlocks are repeated for players who join later.

local LOG = "MxlChievements-Reforged: "
local SETTING = "mxlr-scripted-achievements"

local naming = require("prototypes.naming")
local trackers = require("scripts.trackers")

local core = {}
local active = {}   -- tracker name -> runtime entries {id, params, amounts, names[tier]}
local enabled = true

local function read_setting()
  local setting = settings.global[SETTING]
  enabled = setting == nil or setting.value ~= false
end

local function ensure_storage()
  storage.mxlr = storage.mxlr or {}
  local s = storage.mxlr
  s.broken = s.broken or {}
  s.players = s.players or {}
  s.forces = s.forces or {}
  s.world = s.world or {}
  s.unlocked = s.unlocked or {}
  s.unlocked.players = s.unlocked.players or {}
  s.unlocked.forces = s.unlocked.forces or {}
  s.unlocked.world = s.unlocked.world or {}
end

-- Runs a tracker function; an error switches the tracker off instead of stopping the game.
local function run(tracker_name, fn, ...)
  local s = storage.mxlr
  if not (enabled and s) or s.broken[tracker_name] then return end
  local ok, err = pcall(fn, ...)
  if not ok then
    s.broken[tracker_name] = true
    log(LOG .. "tracker " .. tracker_name .. " stopped until the next configuration change: " .. tostring(err))
  end
end

---------------------------------------------------------------------------------------------------
-- Core API for trackers

function core.player_data(player_index)
  local players = storage.mxlr.players
  local data = players[player_index]
  if not data then
    data = {}
    players[player_index] = data
  end
  return data
end

function core.force_data(force_index)
  local forces = storage.mxlr.forces
  local data = forces[force_index]
  if not data then
    data = {}
    forces[force_index] = data
  end
  return data
end

function core.world()
  return storage.mxlr.world
end

---------------------------------------------------------------------------------------------------
-- Blueprint Sandboxes: nothing done in a lab counts. Its forces ("bpsb-sb-...") get no progress or
-- unlocks, and tracker events of a player, entity, train, research or surface in a lab are ignored.

local SANDBOX_FORCE_PATTERN = "^bpsb%-sb%-"
local SANDBOX_SURFACE_PATTERN = "^bpsb%-lab%-"
local sandboxes = script.active_mods["blueprint-sandboxes"] ~= nil

function core.is_sandbox_force(force)
  return sandboxes and force ~= nil and force.valid and force.name:find(SANDBOX_FORCE_PATTERN) ~= nil
end

function core.is_sandbox_surface(surface)
  return sandboxes and surface ~= nil and surface.valid and surface.name:find(SANDBOX_SURFACE_PATTERN) ~= nil
end

function core.player_in_sandbox(player)
  return player ~= nil and player.valid
    and (core.is_sandbox_force(player.force) or core.is_sandbox_surface(player.surface))
end

local function entity_in_sandbox(entity)
  return entity ~= nil and entity.valid
    and (core.is_sandbox_surface(entity.surface) or core.is_sandbox_force(entity.force))
end

local EVENT_ENTITIES = {"entity", "rocket_silo", "rocket", "cause"}

local function event_in_sandbox(event)
  if not (sandboxes and type(event) == "table") then return false end
  if event.player_index and core.player_in_sandbox(game.get_player(event.player_index)) then return true end
  for _, key in ipairs(EVENT_ENTITIES) do
    local entity = event[key]
    if entity and entity.object_name == "LuaEntity" and entity_in_sandbox(entity) then return true end
  end
  local train = event.train
  if train and train.valid then
    local carriage = train.carriages[1]
    if carriage and entity_in_sandbox(carriage) then return true end
  end
  local research = event.research
  if research and research.valid and core.is_sandbox_force(research.force) then return true end
  local force = event.force
  if force and force.object_name == "LuaForce" and core.is_sandbox_force(force) then return true end
  if event.surface_index and core.is_sandbox_surface(game.get_surface(event.surface_index)) then return true end
  return false
end

-- Wraps a tracker handler fn(event, ...) so that it skips events in a lab.
local function outside_sandbox(fn)
  return function(event, ...)
    if not event_in_sandbox(event) then return fn(event, ...) end
  end
end

-- Forces that have players, in index order (Blueprint Sandboxes forces excluded).
function core.player_forces()
  local list = {}
  for _, force in pairs(game.forces) do
    if #force.players > 0 and not core.is_sandbox_force(force) then table.insert(list, force) end
  end
  table.sort(list, function(a, b) return a.index < b.index end)
  return list
end

local function unlock_player(player, name)
  if not (player and player.valid) then return end
  local unlocked = storage.mxlr.unlocked.players
  local done = unlocked[player.index]
  if not done then
    done = {}
    unlocked[player.index] = done
  end
  if done[name] then return end
  player.unlock_achievement(name)
  -- Only the local player's client unlocks; an offline player gets it again when joining.
  if player.connected then done[name] = true end
end

local function is_force(scope)
  return type(scope) ~= "string" and scope.object_name == "LuaForce"
end

function core.is_done(scope, runtime, tier)
  local name = runtime.names[tier or 1]
  if not name then return true end
  local unlocked = storage.mxlr.unlocked
  if scope == "world" then return unlocked.world[name] == true end
  if is_force(scope) then
    local list = unlocked.forces[scope.index]
    return list ~= nil and list[name] == true
  end
  local list = unlocked.players[scope.index]
  return list ~= nil and list[name] == true
end

-- scope: a LuaPlayer, a LuaForce or "world".
function core.unlock(scope, runtime, tier)
  local name = runtime.names[tier or 1]
  if not name or scope == nil then return end
  local unlocked = storage.mxlr.unlocked
  if scope == "world" then
    if unlocked.world[name] then return end
    unlocked.world[name] = true
    for _, player in pairs(game.players) do unlock_player(player, name) end
  elseif is_force(scope) then
    if core.is_sandbox_force(scope) then return end
    local list = unlocked.forces[scope.index]
    if not list then
      list = {}
      unlocked.forces[scope.index] = list
    end
    if list[name] then return end
    list[name] = true
    for _, player in pairs(scope.players) do unlock_player(player, name) end
  else
    if core.player_in_sandbox(scope) then return end
    unlock_player(scope, name)
  end
end

-- Unlocks every tier whose amount is reached by value.
function core.progress(scope, runtime, value)
  if type(value) ~= "number" then return end
  for tier, amount in ipairs(runtime.amounts) do
    if value >= amount then core.unlock(scope, runtime, tier) end
  end
end

local function replay(player)
  if not (player and player.valid) then return end
  local unlocked = storage.mxlr.unlocked
  for name in pairs(unlocked.world) do unlock_player(player, name) end
  local list = unlocked.forces[player.force.index]
  if list then
    for name in pairs(list) do unlock_player(player, name) end
  end
end

---------------------------------------------------------------------------------------------------
-- Core events: unlock replays and the death counter used by several trackers.

local core_events = {
  on_player_created = function(event)
    local data = core.player_data(event.player_index)
    data.deaths, data.deaths_known = 0, true
    replay(game.get_player(event.player_index))
  end,
  on_player_joined_game = function(event) replay(game.get_player(event.player_index)) end,
  on_player_changed_force = function(event) replay(game.get_player(event.player_index)) end,
  on_player_removed = function(event)
    storage.mxlr.players[event.player_index] = nil
    storage.mxlr.unlocked.players[event.player_index] = nil
  end,
  on_pre_player_died = function(event)
    local data = core.player_data(event.player_index)
    data.deaths = (data.deaths or 0) + 1
  end,
}

---------------------------------------------------------------------------------------------------
-- Registration

local handlers, filters, polls, inputs = {}, {}, {}, {}

local function add_handler(event_name, tracker_name, fn, filter)
  handlers[event_name] = handlers[event_name] or {}
  table.insert(handlers[event_name], {tracker_name, fn})
  if filter == nil then
    filters[event_name] = false
  elseif filters[event_name] ~= false then
    filters[event_name] = filters[event_name] or {}
    for _, item in ipairs(filter) do table.insert(filters[event_name], item) end
  end
end

local function prepare_entries()
  for _, entry in ipairs(require("prototypes.scripted")) do
    local tracker = trackers[entry.tracker]
    if tracker then
      local amounts = naming.amounts(entry)
      local names, any = {}, false
      for tier = 1, #amounts do
        local name = naming.name(entry, tier)
        if prototypes.achievement[name] then
          names[tier] = name
          any = true
        end
      end
      local runtime = {id = entry.id, params = entry.params or {}, amounts = amounts, names = names}
      if any and (not tracker.prepare or tracker.prepare(runtime) ~= false) then
        active[entry.tracker] = active[entry.tracker] or {}
        table.insert(active[entry.tracker], runtime)
      end
    end
  end
end

local function register_static()
  for event_name, fn in pairs(core_events) do add_handler(event_name, "core", fn) end

  local names = {}
  for tracker_name in pairs(active) do table.insert(names, tracker_name) end
  table.sort(names)
  for _, tracker_name in ipairs(names) do
    local tracker, entries = trackers[tracker_name], active[tracker_name]
    for event_name, fn in pairs(tracker.events or {}) do
      local filter = tracker.filters and tracker.filters[event_name] and tracker.filters[event_name](entries)
      local guarded = outside_sandbox(fn)
      add_handler(event_name, tracker_name, function(event) guarded(event, entries, core) end, filter)
    end
    if tracker.poll then
      table.insert(polls, {tracker_name, tracker.poll.every, function() tracker.poll.run(entries, core) end})
    end
    for input_name, fn in pairs(tracker.inputs or {}) do
      if prototypes.custom_input[input_name] then
        inputs[input_name] = function(event) run(tracker_name, outside_sandbox(fn), event, entries, core) end
      end
    end
  end

  for event_name, list in pairs(handlers) do
    local id = defines.events[event_name]
    if id then
      local filter = filters[event_name]
      script.on_event(id, function(event)
        for _, handler in ipairs(list) do run(handler[1], handler[2], event) end
      end, filter and #filter > 0 and filter or nil)
    else
      log(LOG .. "unknown event " .. event_name)
    end
  end

  if #polls > 0 then
    for index, poll in ipairs(polls) do poll[4] = (index * 60) % poll[2] end
    script.on_nth_tick(60, function(event)
      for _, poll in ipairs(polls) do
        if event.tick % poll[2] == poll[4] then run(poll[1], poll[3]) end
      end
    end)
  end

  for input_name, fn in pairs(inputs) do script.on_event(input_name, fn) end
end

-- Custom events of other mods: their ids come from remote interfaces, so they are registered in
-- on_init and on_load.
local function register_custom()
  for tracker_name, entries in pairs(active) do
    local tracker = trackers[tracker_name]
    if tracker.custom then
      local ok, map = pcall(tracker.custom)
      if ok and type(map) == "table" then
        for id, fn in pairs(map) do
          script.on_event(id, function(event) run(tracker_name, outside_sandbox(fn), event, entries, core) end)
        end
      elseif not ok then
        log(LOG .. "events of tracker " .. tracker_name .. " not registered: " .. tostring(map))
      end
    end
  end
end

local function setup_trackers()
  local names = {}
  for tracker_name, entries in pairs(active) do
    table.insert(names, tracker_name)
    local tracker = trackers[tracker_name]
    if tracker.setup then run(tracker_name, tracker.setup, entries, core) end
  end
  table.sort(names)
  log(LOG .. #names .. " trackers active: " .. table.concat(names, ", "))
end

local ok, err = pcall(function()
  prepare_entries()
  register_static()
end)
if not ok then
  log(LOG .. "scripted achievements disabled: " .. tostring(err))
  active = {}
end

script.on_init(function()
  ensure_storage()
  read_setting()
  -- In a save that existed before this mod, earlier deaths are unknown.
  for _, player in pairs(game.players) do
    local data = core.player_data(player.index)
    data.deaths = data.deaths or 0
    data.deaths_known = game.tick == 0
  end
  setup_trackers()
  pcall(register_custom)
end)

script.on_load(function()
  read_setting()
  pcall(register_custom)
end)

script.on_configuration_changed(function()
  ensure_storage()
  read_setting()
  storage.mxlr.broken = {}
  setup_trackers()
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  if event.setting == SETTING then read_setting() end
end)
