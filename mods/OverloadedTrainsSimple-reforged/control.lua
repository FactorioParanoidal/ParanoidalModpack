-- Overloaded Trains Simple Reforged.
--
-- The engine accelerates a train as if it were empty: traction minus resistance divided by the
-- weight of its rolling stock. This mod rescales every positive speed increment by
--   k = W / (W + M),   k >= minimum
-- where W is LuaTrain.weight and M is the cargo mass: item stacks as fractions of a full slot
-- times the full-slot weight, plus fluid amount times the per-unit fluid weight. With k applied,
-- the train accelerates as if its inertia were W + M. Braking and top speed are never touched:
-- the mod only ever lowers a speed the engine has just raised.
--
-- Work is limited to trains that can actually gain speed:
--   * hot  - checked every tick: just departed, re-armed by a state change, or driven by a player;
--   * cold - sampled round-robin, ceil(count / COLD_PERIOD) per tick, so each at least once per
--            COLD_PERIOD ticks: loaded trains cruising, coasting or braking,
--            and manual trains without a driver. An unexpected speed gain (fuel change, recovery
--            after hitting something, remote driving) is corrected retroactively and the train
--            goes hot again;
--   * none - waiting automatic trains and empty automatic trains cost nothing; they are
--            re-evaluated by on_train_changed_state / on_train_created.

local HOT, COLD = 1, 2
local HOT_PATIENCE = 10       -- ticks without a real speed gain before a hot train goes cold
local COLD_PERIOD = 30        -- every cold train is sampled at least once per this many ticks
-- Speed gain per tick (tiles/tick, about 0.13 km/h per second) below which a train counts as
-- cruising: near the air-resistance limit the engine keeps adding ever smaller gains.
local GROWTH_EPSILON = 1e-5
local COLD_WAKE_GAIN = GROWTH_EPSILON * COLD_PERIOD -- gain over one cold sampling period

local train_state = defines.train_state
local CARGO_INVENTORY = defines.inventory.cargo_wagon

-- Automatic trains in these states stand still and can only move after a state change event.
local WAITING = {
  [train_state.wait_station] = true,
  [train_state.wait_signal] = true,
  [train_state.no_path] = true,
  [train_state.no_schedule] = true,
  [train_state.destination_full] = true,
}
local MANUAL_STATE = {
  [train_state.manual_control] = true,
  [train_state.manual_control_stop] = true,
}

local ceil = math.ceil

-- Settings cache: read on init/load/setting change, never per train per tick.
local slot_weight, fluid_weight, minimum_factor
local function read_settings()
  local global_settings = settings.global
  slot_weight = global_settings["otsr-slot-weight"].value
  fluid_weight = global_settings["otsr-fluid-weight"].value
  minimum_factor = global_settings["otsr-minimum-acceleration"].value
end

-- 1 / stack_size per item name. Derived purely from prototypes, so a non-persistent cache is safe.
local slot_share_cache = {}
local function slot_share(name)
  local share = slot_share_cache[name]
  if not share then
    local prototype = prototypes.item[name]
    share = prototype and 1 / prototype.stack_size or 1
    slot_share_cache[name] = share
  end
  return share
end

-- Cargo as full-slot equivalents (quality does not change stack size) and total fluid amount.
local function measure(train)
  local slots = 0
  for _, wagon in pairs(train.cargo_wagons) do
    local inventory = wagon.get_inventory(CARGO_INVENTORY)
    if inventory and not inventory.is_empty() then
      for _, stack in pairs(inventory.get_contents()) do
        slots = slots + stack.count * slot_share(stack.name)
      end
    end
  end
  local fluid = 0
  for _, amount in pairs(train.get_fluid_contents()) do
    fluid = fluid + amount
  end
  return slots, fluid
end

local function factor_for(weight, slots, fluid)
  local mass = slots * slot_weight + fluid * fluid_weight
  if mass <= 0 or weight <= 0 then
    return 1, mass
  end
  local factor = weight / (weight + mass)
  if factor < minimum_factor then
    factor = minimum_factor
  end
  return factor, mass
end

local function train_factor(train)
  local slots, fluid = measure(train)
  return (factor_for(train.weight, slots, fluid))
end

-- State ----------------------------------------------------------------------------------------
-- storage.otsr = {
--   records = { [train_id] = { id, train, k, speed, streak, manual, list = HOT|COLD, index } },
--   hot = { train_id, ... }, cold = { train_id, ... }, cursor = next cold index to sample,
-- }
-- Lists hold ids, records hold their own position, so add/remove are O(1) swap operations.

local function new_state()
  return { records = {}, hot = {}, cold = {}, cursor = 1 }
end

local function attach(state, record, list_id)
  local list = list_id == HOT and state.hot or state.cold
  local index = #list + 1
  list[index] = record.id
  record.list = list_id
  record.index = index
end

local function detach(state, record)
  local list = record.list == HOT and state.hot or state.cold
  local index = record.index
  local last = #list
  if index ~= last then
    local moved_id = list[last]
    list[index] = moved_id
    state.records[moved_id].index = index
  end
  list[last] = nil
end

local function move(state, record, list_id)
  if record.list ~= list_id then
    detach(state, record)
    attach(state, record, list_id)
  end
end

local function forget(state, id)
  local record = state.records[id]
  if record then
    detach(state, record)
    state.records[id] = nil
  end
end

-- on_tick is subscribed only while some train is tracked.
local ticking = false
local on_tick

local function set_ticking(enabled)
  if enabled ~= ticking then
    ticking = enabled
    script.on_event(defines.events.on_tick, enabled and on_tick or nil)
  end
end

local function sync_ticking(state)
  set_ticking(#state.hot > 0 or #state.cold > 0)
end

-- Re-evaluates a valid train from scratch and arms it as hot when it should be tracked.
local function track(state, train)
  local id = train.id
  local manual = train.manual_mode
  if not manual and WAITING[train.state] then
    forget(state, id)
    return
  end
  local k = train_factor(train)
  if not manual and k >= 1 then
    forget(state, id)
    return
  end
  local record = state.records[id]
  if record then
    record.train = train
    record.k = k
    record.manual = manual
    record.speed = train.speed
    record.streak = 0
    move(state, record, HOT)
  else
    record = { id = id, train = train, k = k, manual = manual, speed = train.speed, streak = 0 }
    state.records[id] = record
    attach(state, record, HOT)
  end
end

local function rebuild()
  local state = new_state()
  storage.otsr = state
  for _, train in pairs(game.train_manager.get_trains({})) do
    track(state, train)
  end
  sync_ticking(state)
end

-- Per-tick processing ----------------------------------------------------------------------------

-- Applies the factor to a speed gain since `previous`. Returns the (possibly lowered) speed and
-- the unscaled gain in tiles/tick; the gain is 0 when the train did not speed up.
local function apply(record, train, speed, previous)
  if speed == 0 or previous * speed < 0 then
    return speed, 0
  end
  local current_abs = speed < 0 and -speed or speed
  local previous_abs = previous < 0 and -previous or previous
  local gain = current_abs - previous_abs
  if gain <= 0 then
    return speed, 0
  end
  if record.manual and previous == 0 then
    -- A parked manual train may have been loaded by hand: measure it again on departure.
    record.k = train_factor(train)
  end
  local k = record.k
  if k < 1 then
    local adjusted = previous_abs + gain * k
    speed = speed < 0 and -adjusted or adjusted
    train.speed = speed
  end
  return speed, gain
end

local function process_hot(state)
  local hot = state.hot
  local records = state.records
  -- Backwards: a removal swaps an already processed entry into the current slot.
  for index = #hot, 1, -1 do
    local id = hot[index]
    local record = records[id]
    local train = record.train
    if not train.valid then
      forget(state, id)
    else
      local speed, gain = apply(record, train, train.speed, record.speed)
      record.speed = speed
      if gain > GROWTH_EPSILON then
        record.streak = 0
      else
        local streak = record.streak + 1
        if streak >= HOT_PATIENCE then
          streak = 0
          -- A player at the controls may accelerate at any moment without a state change.
          if not (record.manual and #train.passengers > 0) then
            move(state, record, COLD)
          end
        end
        record.streak = streak
      end
    end
  end
end

local function process_cold(state)
  local cold = state.cold
  local records = state.records
  local budget = ceil(#cold / COLD_PERIOD)
  local index = state.cursor
  while budget > 0 do
    local count = #cold
    if count == 0 then
      break
    end
    if index > count then
      index = 1
    end
    budget = budget - 1
    local id = cold[index]
    local record = records[id]
    local train = record.train
    if not train.valid then
      -- The last entry was swapped into this slot; sample it on the next step.
      forget(state, id)
    else
      local speed, gain = apply(record, train, train.speed, record.speed)
      record.speed = speed
      if gain > COLD_WAKE_GAIN then
        record.streak = 0
        move(state, record, HOT)
      else
        index = index + 1
      end
    end
  end
  state.cursor = index
end

on_tick = function()
  local state = storage.otsr
  if #state.hot > 0 then
    process_hot(state)
  end
  if #state.cold > 0 then
    process_cold(state)
  end
  if #state.hot == 0 and #state.cold == 0 then
    set_ticking(false)
  end
end

-- Events -----------------------------------------------------------------------------------------

local function on_train_changed_state(event)
  local train = event.train
  if not (train and train.valid) then
    return
  end
  local state = storage.otsr
  local id = train.id
  local record = state.records[id]
  local old_state = event.old_state
  local was_stopped = WAITING[old_state] or MANUAL_STATE[old_state]

  if not was_stopped then
    -- Moving automatic train: its cargo cannot have changed since it was last measured.
    if record then
      if not train.manual_mode and WAITING[train.state] then
        forget(state, id)
        sync_ticking(state)
      else
        record.manual = train.manual_mode
        record.streak = 0
        move(state, record, HOT)
        set_ticking(true)
      end
      return
    end
    if not train.manual_mode then
      return
    end
  end

  -- Leaving a stop or manual control (cargo may have changed), or entering manual control.
  track(state, train)
  sync_ticking(state)
end

local function on_train_created(event)
  local state = storage.otsr
  if event.old_train_id_1 then
    forget(state, event.old_train_id_1)
  end
  if event.old_train_id_2 then
    forget(state, event.old_train_id_2)
  end
  local train = event.train
  if train and train.valid then
    track(state, train)
  end
  sync_ticking(state)
end

local function on_player_driving_changed_state(event)
  local entity = event.entity
  if not (entity and entity.valid) then
    return
  end
  local train = entity.train
  if not (train and train.valid and train.manual_mode) then
    return
  end
  local state = storage.otsr
  local record = state.records[train.id]
  if record then
    record.streak = 0
    move(state, record, HOT)
    set_ticking(true)
  else
    track(state, train)
    sync_ticking(state)
  end
end

local function on_runtime_mod_setting_changed(event)
  if event.setting and event.setting:sub(1, 5) == "otsr-" then
    read_settings()
    rebuild()
  end
end

-- Inspection -------------------------------------------------------------------------------------

local function describe(train)
  local slots, fluid = measure(train)
  local weight = train.weight
  local k, mass = factor_for(weight, slots, fluid)
  local record = storage.otsr.records[train.id]
  local status = record and (record.list == HOT and "hot" or "cold") or "idle"
  return {
    train_id = train.id,
    weight = weight,
    slots = slots,
    fluid = fluid,
    mass = mass,
    factor = k,
    tracked_factor = record and record.k or nil,
    status = status,
  }
end

remote.add_interface("OverloadedTrainsSimple-reforged", {
  -- Returns the current load estimate and tracking status of a train, or nil.
  describe_train = function(train_id)
    local train = game.train_manager.get_train_by_id(train_id)
    if train and train.valid then
      return describe(train)
    end
  end,
})

commands.add_command("otsr", { "otsr.command-help" }, function(command)
  local player = command.player_index and game.get_player(command.player_index)
  if not player then
    return
  end
  local entity = player.selected
  local train = entity and entity.valid and entity.train
  if not train then
    entity = player.vehicle
    train = entity and entity.valid and entity.train
  end
  if not (train and train.valid) then
    player.print({ "otsr.no-train" })
    return
  end
  local info = describe(train)
  player.print({
    "otsr.info",
    info.train_id,
    string.format("%.0f", info.weight),
    string.format("%.1f", info.slots),
    string.format("%.0f", info.fluid),
    string.format("%.0f", info.mass),
    string.format("%.3f", info.factor),
    { "otsr.status-" .. info.status },
  })
end)

-- Lifecycle --------------------------------------------------------------------------------------

script.on_init(function()
  read_settings()
  rebuild()
end)

script.on_load(function()
  read_settings()
  local state = storage.otsr
  if state and (#state.hot > 0 or #state.cold > 0) then
    set_ticking(true)
  end
end)

script.on_configuration_changed(function()
  read_settings()
  rebuild()
end)

script.on_event(defines.events.on_train_changed_state, on_train_changed_state)
script.on_event(defines.events.on_train_created, on_train_created)
script.on_event(defines.events.on_player_driving_changed_state, on_player_driving_changed_state)
script.on_event(defines.events.on_runtime_mod_setting_changed, on_runtime_mod_setting_changed)
