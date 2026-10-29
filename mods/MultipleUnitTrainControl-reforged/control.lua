-- Multiple Unit Train Control Reforged: runtime.
--
-- Flow: a train is created (built, coupled, uncoupled, research, setting) -> queued -> on the next
-- ticks planner.plan decides the pairs -> if locomotives must change and the train may be touched
-- now, replace.batch swaps them, otherwise the train waits in storage.pending for a safe state ->
-- labels and the fuel link are updated for the resulting train.
local shared = require("shared")
local planner = require("script.planner")
local replace = require("script.replace")
local labels = require("script.labels")
local fuel = require("script.fuel")
local blueprint = require("script.blueprint")

local TRAINS_PER_TICK = 5
local CLEANUP_PERIOD = 3600
local CYBERSYN_DEPOT = 0 -- STATUS_D of Cybersyn: the train waits in its depot without a delivery

-- Train states in which a standing train may be rebuilt.
local SAFE_STATES = {
  [defines.train_state.wait_station] = true,
  [defines.train_state.wait_signal] = true,
  [defines.train_state.no_path] = true,
  [defines.train_state.no_schedule] = true,
  [defines.train_state.manual_control] = true,
  [defines.train_state.destination_full] = true,
}

-- Rails of both layers in reach of a locomotive: the engine would choose the layer of a created
-- carriage by itself, so such places are skipped until the train stands elsewhere.
local GROUND_RAILS = {"straight-rail", "half-diagonal-rail", "curved-rail-a", "curved-rail-b",
                      "legacy-straight-rail", "legacy-curved-rail"}
local UPPER_RAILS = {"elevated-straight-rail", "elevated-half-diagonal-rail", "elevated-curved-rail-a",
                     "elevated-curved-rail-b", "rail-ramp"}
local LAYER_RADIUS = 2.5 -- about half a locomotive; a parallel track 4 tiles away is not counted

local ticking = false

---------------------------------------------------------------------------------------------------
-- Mode

local function mode_of(force)
  local mode = settings.global[shared.setting_mode].value
  if mode == "off" then return "off" end
  if mode == "always" then return "advanced" end
  local technologies = force.technologies
  local wireless, basic = technologies[shared.tech_wireless], technologies[shared.tech_basic]
  if wireless and wireless.researched then return "advanced" end
  if basic and basic.researched then return "basic" end
  return "off"
end

local function update_technologies(force)
  local enabled = settings.global[shared.setting_mode].value == "research"
  for _, target in pairs(force and {force} or game.forces) do
    for _, name in ipairs({shared.tech_basic, shared.tech_wireless}) do
      local technology = target.technologies[name]
      if technology then technology.enabled = enabled end
    end
  end
end

---------------------------------------------------------------------------------------------------
-- Safety

local function cybersyn_busy(train)
  if not remote.interfaces["cybersyn"] then return false end
  local status = remote.call("cybersyn", "read_global", "trains", train.id, "status")
  return status ~= nil and status ~= CYBERSYN_DEPOT
end

local function ambiguous_layer(entity)
  local surface, position = entity.surface, entity.position
  return surface.count_entities_filtered({type = GROUND_RAILS, position = position, radius = LAYER_RADIUS, limit = 1}) > 0
     and surface.count_entities_filtered({type = UPPER_RAILS, position = position, radius = LAYER_RADIUS, limit = 1}) > 0
end

local function can_replace(train, list)
  if train.speed ~= 0 or not SAFE_STATES[train.state] then return false end
  for _, entry in ipairs(list) do
    local entity = entry.entity
    if entity.to_be_deconstructed() or entity.to_be_upgraded() or ambiguous_layer(entity) then return false end
  end
  return not cybersyn_busy(train)
end

---------------------------------------------------------------------------------------------------
-- Train processing

local function process(train)
  if not (train and train.valid) then return end
  local mode = mode_of(train.carriages[1].force)
  local plan = planner.plan(train, mode)
  if #plan.replace > 0 then
    if not can_replace(train, plan.replace) then
      storage.pending[train.id] = train
      return
    end
    -- Trains created meanwhile (the result too) are queued by on_train_created: intermediate ones are
    -- invalid by then, a neighbour that a new carriage touched gets its own pass, the result a cheap one.
    local result = replace.batch(train, plan.replace)
    if not (result and result.valid) then return end
    train = result
    plan = planner.plan(train, mode)
  end
  labels.apply(train, plan.labels)
  if plan.linked then fuel.link(train) else fuel.unlink(train.id) end
end

local on_tick

local function sync_ticking()
  local wanted = next(storage.queue) ~= nil
  if wanted ~= ticking then
    ticking = wanted
    script.on_event(defines.events.on_tick, wanted and on_tick or nil)
  end
end

on_tick = function()
  for _ = 1, TRAINS_PER_TICK do
    local id, train = next(storage.queue)
    if not id then break end
    storage.queue[id] = nil
    process(train)
  end
  sync_ticking()
end

local function enqueue(train)
  if train and train.valid then
    storage.queue[train.id] = train
    storage.pending[train.id] = nil
  end
end

local function enqueue_all(force)
  for _, train in pairs(game.train_manager.get_trains(force and {force = force} or {})) do enqueue(train) end
  sync_ticking()
end

local function forget(id)
  if not id then return end
  storage.queue[id] = nil
  storage.pending[id] = nil
  fuel.unlink(id)
end

local function cleanup()
  for _, list in pairs({storage.queue, storage.pending, storage.linked}) do
    for id, train in pairs(list) do
      if not train.valid then forget(id) end
    end
  end
  labels.cleanup()
end

---------------------------------------------------------------------------------------------------
-- Registration

local function fuel_tick()
  fuel.tick(mode_of)
end

local function register_dynamic()
  ticking = false
  sync_ticking()
  script.on_nth_tick(fuel.PERIOD, settings.global[shared.setting_fuel].value and fuel_tick or nil)
end

local function init_storage()
  storage.queue = storage.queue or {}      -- train id -> LuaTrain, processed on the next ticks
  storage.pending = storage.pending or {}  -- train id -> LuaTrain, waits for a safe state
  storage.linked = storage.linked or {}    -- train id -> LuaTrain with an MU pair (shared fuel)
  storage.labels = storage.labels or {}    -- locomotive unit_number -> render object id
end

script.on_init(function()
  init_storage()
  update_technologies()
  register_dynamic()
  enqueue_all()
end)

script.on_load(register_dynamic)

script.on_configuration_changed(function()
  init_storage()
  update_technologies()
  register_dynamic()
  enqueue_all()
end)

script.on_event(defines.events.on_train_created, function(event)
  forget(event.old_train_id_1)
  forget(event.old_train_id_2)
  enqueue(event.train)
  sync_ticking()
end)

script.on_event(defines.events.on_train_changed_state, function(event)
  local train = event.train
  if storage.pending[train.id] and train.speed == 0 and SAFE_STATES[train.state] then
    enqueue(train)
    sync_ticking()
  end
end)

local function on_research(event)
  local name = event.research.name
  if name == shared.tech_basic or name == shared.tech_wireless then enqueue_all(event.research.force) end
end
script.on_event(defines.events.on_research_finished, on_research)
script.on_event(defines.events.on_research_reversed, on_research)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  if event.setting == shared.setting_mode then
    update_technologies()
    enqueue_all()
  elseif event.setting == shared.setting_fuel then
    register_dynamic()
  elseif event.setting == shared.setting_labels then
    labels.refresh_audience()
  end
end)

script.on_event(defines.events.on_force_created, function(event) update_technologies(event.force) end)
script.on_event(defines.events.on_player_joined_game, labels.refresh_audience)
script.on_event(defines.events.on_player_changed_force, labels.refresh_audience)

script.on_event(defines.events.on_object_destroyed, function(event)
  if event.type == defines.target_type.entity and event.useful_id then labels.forget(event.useful_id) end
end)

script.on_event(defines.events.on_player_setup_blueprint, blueprint.on_setup)
script.on_event(defines.events.on_player_configured_blueprint, blueprint.on_configured)

script.on_nth_tick(CLEANUP_PERIOD, cleanup)
