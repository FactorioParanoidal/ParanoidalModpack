-- Robot Army: control stage entry point. Event wiring and lifecycle only;
-- the logic lives in script/*.lua.
local shared = require("lib.shared")
local config = require("script.config")
local cache = require("script.settings_cache")
local state = require("script.state")
local Squad = require("script.squad")
local ai = require("script.ai")
local spawners = require("script.spawners")
local circuit = require("script.circuit")
local tools = require("script.tools")
local qrf = require("script.qrf")
local gui = require("script.gui")
local compat = require("script.compat")

local B = shared.buildings
local is_droid = shared.is_droid

local BUILDING_KIND = {
  [B.assembler] = "assemblers",
  [B.station] = "stations",
  [B.counter] = "counters",
  [B.loot] = "loot",
}
local SINGLE_FIELD = {loot = "loot_chest"}

------------------------------------------------------------------------------------------
-- Buildings

--- Only one loot chest per force: return the extra one to its builder.
local function refuse(entity, event)
  local force = entity.force
  force.print({"robotarmy-message.only-one", entity.localised_name})
  local stack = {name = entity.name, count = 1, quality = entity.quality.name}
  local returned = false
  local player = event and event.player_index and game.get_player(event.player_index)
  if player then
    returned = player.insert(stack) > 0
  end
  if not returned and event and (player or event.robot or event.platform) then
    entity.surface.spill_item_stack({position = entity.position, stack = stack, enable_looted = true, allow_belts = false})
  end
  entity.destroy()
end

--- Registers a building of the mod. `event` is nil during a rescan.
local function register_building(entity, kind, event)
  local fd = state.force_data(entity.force)
  local field = SINGLE_FIELD[kind]
  if field then
    local existing = fd[field]
    -- a clone of the current one (moved by another mod) takes over; the source goes away
    if existing and existing.valid and existing ~= entity and not (event and event.source == existing) then
      if event then refuse(entity, event) end
      return
    end
    fd[field] = entity
    state.track_structure(entity, kind)
    return
  end
  fd[kind][entity.unit_number] = entity
  state.track_structure(entity, kind)
  if kind == "counters" then fd.counters_dirty = true end
end

local function on_built(event)
  local entity = event.entity or event.destination
  if not (entity and entity.valid) then return end
  local name = entity.name
  if is_droid[name] then
    spawners.adopt(entity, nil, event.name == defines.events.on_built_entity)
    return
  end
  local kind = BUILDING_KIND[name]
  if kind then
    register_building(entity, kind, event)
  end
end

local function forget_structure(unit_number)
  local record, spawner = state.untrack_structure(unit_number)
  if not record then return end
  spawners.removed(spawner)
  local fd = storage.forces[record.force]
  if not fd then return end
  local kind = record.kind
  local field = SINGLE_FIELD[kind]
  if field then
    local current = fd[field]
    if current and not current.valid then
      fd[field] = nil
    end
    return
  end
  fd[kind][unit_number] = nil
  if kind == "assemblers" then
    fd.retreats[unit_number] = nil
    fd.threats[unit_number] = nil
  elseif kind == "stations" then
    fd.station_squad[unit_number] = nil
  end
end

local function on_object_destroyed(event)
  local unit_number = event.useful_id
  if not unit_number or unit_number == 0 then return end
  if storage.units[unit_number] then
    storage.units[unit_number] = nil
    local id = storage.unit_squad[unit_number]
    if id then
      local squad = storage.squads[id]
      if squad then
        Squad.remove(squad, unit_number)
      else
        storage.unit_squad[unit_number] = nil
      end
    end
    return
  end
  forget_structure(unit_number)
end

------------------------------------------------------------------------------------------
-- Ticks

local scratch = {} -- reused id list (never stored)

local function on_tick(event)
  if not compat.unit_control then
    local bucket = storage.buckets[event.tick % config.BUCKETS + 1]
    if next(bucket) ~= nil then
      -- copy first: updates may create and delete squads
      local n = 0
      for id in pairs(bucket) do
        n = n + 1
        scratch[n] = id
      end
      local squads = storage.squads
      for i = 1, n do
        local squad = squads[scratch[i]]
        scratch[i] = nil
        if squad then ai.update(squad) end
      end
    end
  end
  spawners.on_tick()
end

local function on_ai_command_completed(event)
  local unit_number = event.unit_number
  local unit = storage.units[unit_number]
  if unit then
    if event.was_distracted and unit.valid then ai.retarget(unit) end
    return
  end
  -- a squad finished its order: look for the next one on its next update
  local id = storage.groups[unit_number]
  if id and event.result == defines.behavior_result.success then
    local squad = storage.squads[id]
    if squad and not squad.qrf then squad.order.dirty = true end
  end
end

------------------------------------------------------------------------------------------
-- Lifecycle

--- Finds the mod's buildings and droids on every surface (new game, mod added, or a
--- fresh storage schema).
local function rescan()
  local names = {}
  for name in pairs(BUILDING_KIND) do
    if prototypes.entity[name] then names[#names + 1] = name end
  end
  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({name = names})) do
      register_building(entity, BUILDING_KIND[entity.name], nil)
    end
    for _, droid in pairs(surface.find_entities_filtered({name = shared.unit_names})) do
      spawners.adopt(droid, nil, false)
    end
  end
end

--- Drops references to entities that disappeared without an event (removed prototypes).
local function cleanup()
  for unit_number, unit in pairs(storage.units) do
    if not unit.valid then on_object_destroyed({useful_id = unit_number}) end
  end
  for unit_number, record in pairs(storage.structures) do
    local fd = storage.forces[record.force]
    local entity
    if fd then
      local field = SINGLE_FIELD[record.kind]
      if field then
        entity = fd[field]
      else
        entity = fd[record.kind][unit_number]
      end
    end
    if not (entity and entity.valid and entity.unit_number == unit_number) then
      forget_structure(unit_number)
    end
  end
  for player_index in pairs(storage.selection) do
    if not game.get_player(player_index) then tools.deselect(player_index) end
  end
end

local function on_init()
  cache.refresh()
  state.init()
  rescan()
end

local function on_configuration_changed()
  cache.refresh()
  if storage.schema ~= state.SCHEMA then
    -- no migrations: start over and pick up what is on the map
    state.init()
    rescan()
  else
    cleanup()
  end
end

local function on_forces_merging(event)
  local source = storage.forces[event.source.index]
  if not source then return end
  local destination = state.force_data(event.destination)
  local index = event.destination.index
  for id, squad in pairs(source.squads) do
    squad.force = event.destination
    squad.force_index = index
    squad.order.dirty = true
    destination.squads[id] = squad
  end
  for _, kind in pairs({"assemblers", "stations", "counters", "station_squad", "retreats", "threats"}) do
    for key, value in pairs(source[kind]) do
      destination[kind][key] = value
    end
  end
  for _, field in pairs(SINGLE_FIELD) do
    if not (destination[field] and destination[field].valid) then
      destination[field] = source[field]
    end
  end
  for _, record in pairs(storage.structures) do
    if record.force == event.source.index then record.force = index end
  end
  destination.counters_dirty = true
  storage.forces[event.source.index] = nil
end

local function on_gui_closed(event)
  gui.on_closed(event)
  local entity = event.entity
  if not (entity and entity.valid) or entity.name ~= B.counter then return end
  local fd = storage.forces[entity.force.index]
  if fd then fd.counters_dirty = true end -- a player may have edited the counter
end

local function on_settings_pasted(event)
  gui.on_settings_pasted(event)
  on_gui_closed({entity = event.destination, player_index = event.player_index})
end

local function on_player_left(event)
  tools.deselect(event.player_index)
  local player = game.get_player(event.player_index)
  if player then gui.close_window(player) else storage.windows[event.player_index] = nil end
end

------------------------------------------------------------------------------------------
-- Read-only remote interface (inspection by other mods, scenarios and tests)

local MODE_NAME = {}
for name, value in pairs(Squad.MODE) do MODE_NAME[value] = name end

local function force_data_of(force)
  local f = game.forces[force]
  return f and storage.forces[f.index]
end

remote.add_interface("robotarmy-reforged", {
  --- Squads of a force: array of {id, size, mode, status, qrf, surface, position, station}.
  squads = function(force)
    local list = {}
    local fd = force_data_of(force)
    if not fd then return list end
    for id, squad in pairs(fd.squads) do
      list[#list + 1] = {
        id = id,
        size = squad.size,
        mode = MODE_NAME[squad.mode],
        status = Squad.status(squad),
        qrf = squad.qrf and (squad.qrf.returning and "returning" or "attacking") or nil,
        surface = squad.surface.valid and squad.surface.name or nil,
        position = {x = squad.pos.x, y = squad.pos.y},
        station = squad.station,
      }
    end
    return list
  end,
  --- Squad thresholds of a force.
  thresholds = function(force)
    local fd = force_data_of(force)
    local t = fd and fd.thresholds or {}
    local out = {}
    for key, spec in pairs(shared.thresholds) do out[key] = t[key] or spec.default end
    return out
  end,
  --- Sets a squad threshold of a force (same rules as the army window).
  set_threshold = function(force, key, value)
    local f = game.forces[force]
    if f then gui.set_threshold(state.force_data(f), key, value) end
  end,
  --- Droid assembler / guard station state: {pending, garrison, paused}.
  spawner = function(unit_number)
    local record = storage.spawners[unit_number]
    if not record then return nil end
    return {pending = #record.pending, garrison = record.garrison, paused = record.entity.valid and record.entity.disabled_by_script}
  end,
  --- Sets the garrison size of a guard station.
  set_garrison = function(unit_number, value)
    local record = storage.spawners[unit_number]
    if record and record.station then
      record.garrison = math.max(shared.garrison.min, math.min(shared.garrison.max, math.floor(value)))
    end
  end,
  --- Number of droids the mod tracks.
  tracked_units = function()
    return table_size(storage.units)
  end,
  --- Squad id of a droid, or nil.
  squad_of = function(unit_number)
    return storage.unit_squad[unit_number]
  end,
})

------------------------------------------------------------------------------------------
-- Registration

local built_filter = {}
for name in pairs(BUILDING_KIND) do
  -- the loot chest prototype only exists with its startup setting on
  if name ~= B.loot or settings.startup[shared.setting.loot_chest].value then
    built_filter[#built_filter + 1] = {filter = "name", name = name}
  end
end
for _, name in pairs(shared.unit_names) do
  built_filter[#built_filter + 1] = {filter = "name", name = name}
end

script.on_init(on_init)
script.on_load(cache.refresh)
script.on_configuration_changed(on_configuration_changed)

script.on_event(defines.events.on_built_entity, on_built, built_filter)
script.on_event(defines.events.on_robot_built_entity, on_built, built_filter)
script.on_event(defines.events.on_space_platform_built_entity, on_built, built_filter)
script.on_event(defines.events.script_raised_built, on_built, built_filter)
script.on_event(defines.events.script_raised_revive, on_built, built_filter)
script.on_event(defines.events.on_entity_cloned, on_built, built_filter)
script.on_event(defines.events.on_object_destroyed, on_object_destroyed)

script.on_event(defines.events.on_tick, on_tick)
script.on_nth_tick(config.CIRCUIT_PERIOD, circuit.on_nth_tick)
script.on_nth_tick(config.GUI_PERIOD, function()
  if next(storage.selection) then tools.refresh() end
  gui.refresh()
end)
script.on_event(defines.events.on_ai_command_completed, on_ai_command_completed)
script.on_event(defines.events.on_entity_died, qrf.on_entity_died, qrf.event_filter)

script.on_event(defines.events.on_player_selected_area, tools.on_selected_area)
script.on_event(defines.events.on_player_alt_selected_area, tools.on_alt_selected_area)
script.on_event(defines.events.on_player_reverse_selected_area, tools.on_reverse_selected_area)
script.on_event(defines.events.on_player_alt_reverse_selected_area, tools.on_reverse_selected_area)

script.on_event(defines.events.on_gui_opened, gui.on_opened)
script.on_event(defines.events.on_gui_closed, on_gui_closed)
script.on_event(defines.events.on_gui_click, gui.on_click)
script.on_event(defines.events.on_gui_value_changed, gui.on_value_changed)
script.on_event(defines.events.on_gui_confirmed, gui.on_confirmed)
script.on_event(defines.events.on_entity_settings_pasted, on_settings_pasted)
script.on_event(defines.events.on_lua_shortcut, function(event)
  if event.prototype_name ~= shared.army_shortcut then return end
  local player = game.get_player(event.player_index)
  if player then gui.toggle_window(player) end
end)
script.on_event(shared.army_shortcut, function(event)
  local player = game.get_player(event.player_index)
  if player then gui.toggle_window(player) end
end)

script.on_event(defines.events.on_forces_merging, on_forces_merging)
script.on_event(defines.events.on_player_removed, on_player_left)
script.on_event(defines.events.on_player_changed_force, on_player_left)
script.on_event(defines.events.on_runtime_mod_setting_changed, cache.refresh)
