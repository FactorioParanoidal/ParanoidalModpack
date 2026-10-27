-- Overloaded Trains Simple Reforged.
--
-- Cargo inertia. The engine accelerates a train with a speed-independent tractive force against
-- the weight of its rolling stock only. Every positive speed increment is rescaled by
--   k = W / (W + M),   k >= minimum
-- where W is LuaTrain.weight and M is the cargo mass: item stacks as fractions of a full slot
-- times the full-slot weight, plus fluid amount times the per-unit fluid weight. The train then
-- accelerates as if its inertia were W + M; more locomotives raise both the force and W, so the
-- start of a heavy train is already limited by its locomotives - no separate adhesion term.
--
-- Curves. A train may pass curved rails at no more than a share of its own current top speed.
-- Automatic trains read the curves ahead from their path (scanned incrementally, only as far as
-- needed); manual and path-less trains look ahead along the rails every WALK_PERIOD ticks. The
-- train slows down before the curve with a share of its own braking ability and keeps the limit
-- until its last carriage has left the curve.
--
-- Both effects only ever lower a speed the engine has just produced, and are combined into a
-- single write per train and tick. Engine braking and top speed are never touched.
--
-- Scheduling. Every tracked train has one due tick in a timing wheel: accelerating loaded trains
-- and trains inside or close to a curve are processed every tick; other moving trains sleep as
-- long as the next curve and the cargo correction allow (at most MAX_SLEEP / COLD_PERIOD ticks).
-- Waiting automatic trains cost nothing and are re-armed by on_train_changed_state.

local HOT_PATIENCE = 10       -- ticks without a real speed gain before a loaded train is sampled
local COLD_PERIOD = 30        -- loaded or manual trains are checked at least this often
local MAX_SLEEP = 60          -- moving trains are checked at least this often (path changes)
local DEPART_PERIOD = 5       -- automatic train standing on its path, about to depart
local WALK_PERIOD = 10        -- path-less trains look along the rails this often
local MAX_WALK_STEPS = 400    -- rails per look-ahead walk
local MARGIN = 8              -- tiles: rail granularity and the curve geometry beyond rail centres
local CURVE_BRAKING = 0.5     -- share of the train's full braking used to slow down for a curve
local ACCEL_BOUND = 0.005     -- generous bound of the engine speed gain per tick (tiles/tick^2)
local CLOSE_SHARE = 0.97      -- above this share of the allowed speed a train is checked each tick
-- Speed gain per tick (tiles/tick, about 0.13 km/h per second) below which a train counts as
-- cruising: near the air-resistance limit the engine keeps adding ever smaller gains.
local GROWTH_EPSILON = 1e-5
local KMH = 216               -- tiles/tick -> km/h
local ALERT_ICON = { type = "virtual", name = "signal-alert" }
local PANEL = "otsr_panel"

local train_state = defines.train_state
local CARGO_INVENTORY = defines.inventory.cargo_wagon
local FRONT = defines.rail_direction.front
local BACK = defines.rail_direction.back

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
local CURVE_TYPES = {
  ["curved-rail-a"] = true,
  ["curved-rail-b"] = true,
  ["elevated-curved-rail-a"] = true,
  ["elevated-curved-rail-b"] = true,
  ["legacy-curved-rail"] = true,
}

local floor, sqrt, huge = math.floor, math.sqrt, math.huge
local PATH_MODE, WALK_MODE = 1, 2

-- Settings cache: read on init/load/setting change, never per train per tick.
local slot_weight, fluid_weight, minimum_factor, curve_share, curves_on
local function read_settings()
  local global_settings = settings.global
  slot_weight = global_settings["otsr-slot-weight"].value
  fluid_weight = global_settings["otsr-fluid-weight"].value
  minimum_factor = global_settings["otsr-minimum-acceleration"].value
  curve_share = global_settings["otsr-curve-speed"].value
  curves_on = curve_share < 1
end

-- Prototype-derived caches (deterministic, rebuilt on demand, never stored).
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

local carriage_cache = {}
local function carriage_info(name)
  local info = carriage_cache[name]
  if not info then
    local prototype = prototypes.entity[name]
    info = {
      brake = prototype.braking_force or 0,
      length = (prototype.joint_distance or 4) + (prototype.connection_distance or 3),
    }
    carriage_cache[name] = info
  end
  return info
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

-- Returns the applied factor, the unclamped factor and the cargo mass.
local function factor_for(weight, slots, fluid)
  local mass = slots * slot_weight + fluid * fluid_weight
  if mass <= 0 or weight <= 0 then
    return 1, 1, mass
  end
  local raw = weight / (weight + mass)
  return raw < minimum_factor and minimum_factor or raw, raw, mass
end

local function train_factor(train)
  local slots, fluid = measure(train)
  return factor_for(train.weight, slots, fluid)
end

-- Full braking deceleration (tiles/tick^2, without friction) and length of the train.
local function train_physics(train)
  local brake, length = 0, 0
  local carriages = train.carriages
  for i = 1, #carriages do
    local info = carriage_info(carriages[i].name)
    brake = brake + info.brake
    length = length + info.length
  end
  local first = carriages[1]
  local bonus = first and first.force.train_braking_force_bonus or 0
  local weight = train.weight
  return weight > 0 and brake * (1 + bonus) / weight or 0, length
end

local function top_speed(train, speed)
  if speed < 0 then
    return train.max_backward_speed
  end
  return train.max_forward_speed
end

-- State ----------------------------------------------------------------------------------------
-- storage.otsr = {
--   records = { [train_id] = record }, wheel = { [tick] = { train_id, ... } },
--   scheduled = number of records with a due tick, alerts = { [train_id] = alerted entity },
-- }
-- record = { id, train, k, manual, speed, tick, streak, odo, brake, len, due,
--            curve tracking: cmode, psize, ptotal, cum, lo, si, ss, sx, sy, sc, segs, sf, walk_due,
--            known, last_s }
-- Wheel entries are not removed when a record is rescheduled or forgotten; an entry only counts
-- when the record still exists and its due tick equals the bucket tick.

local function new_state(alerts)
  return { records = {}, wheel = {}, scheduled = 0, alerts = alerts or {} }
end

local ticking = false
local on_tick

local function set_ticking(enabled)
  if enabled ~= ticking then
    ticking = enabled
    script.on_event(defines.events.on_tick, enabled and on_tick or nil)
  end
end

local function sync_ticking(state)
  if state.scheduled > 0 then
    set_ticking(true)
  else
    state.wheel = {} -- every remaining entry is stale
    set_ticking(false)
  end
end

local function schedule(state, record, tick)
  if not record.due then
    state.scheduled = state.scheduled + 1
  end
  record.due = tick
  local bucket = state.wheel[tick]
  if bucket then
    bucket[#bucket + 1] = record.id
  else
    state.wheel[tick] = { record.id }
  end
end

local function forget(state, id)
  local record = state.records[id]
  if record then
    if record.due then
      state.scheduled = state.scheduled - 1
    end
    state.records[id] = nil
  end
end

local function reset_curves(record)
  record.cmode = nil
  record.psize = nil
  record.ptotal = nil
  record.cum = {}
  record.lo = nil
  record.si = nil
  record.ss = nil
  record.sx = nil
  record.sy = nil
  record.sc = false
  record.segs = {}
  record.sf = 1
  record.walk_due = 0
  record.known = 0
  record.ps = nil
  record.podo = nil
end

-- Alerts -----------------------------------------------------------------------------------------

local function clear_alert(state, id)
  local entity = state.alerts[id]
  if entity == nil then
    return
  end
  state.alerts[id] = nil
  if entity.valid then
    for _, player in pairs(entity.force.connected_players) do
      player.remove_alert({ entity = entity, icon = ALERT_ICON })
    end
  end
end

local function raise_alert(state, train, raw)
  local stock = train.front_stock or train.carriages[1]
  if not stock then
    return
  end
  local message = { "otsr.alert-overloaded", string.format("%.0f", raw * 100), string.format("%.0f", minimum_factor * 100) }
  for _, player in pairs(stock.force.connected_players) do
    if player.mod_settings["otsr-overload-alert"].value then
      player.add_custom_alert(stock, ALERT_ICON, message, true)
    end
  end
  state.alerts[train.id] = stock
end

-- Tracking ---------------------------------------------------------------------------------------

-- Re-evaluates a valid train from scratch (cargo, physics, curve data) and schedules it for the
-- next tick when it should be tracked. Returns the unclamped factor of a tracked train.
local function track(state, train)
  local id = train.id
  local manual = train.manual_mode
  if not manual and WAITING[train.state] then
    forget(state, id)
    return nil
  end
  local k, raw = train_factor(train)
  if not manual and k >= 1 and not curves_on then
    forget(state, id)
    return nil
  end
  local record = state.records[id]
  if not record then
    record = { id = id, odo = 0 }
    state.records[id] = record
  end
  record.train = train
  record.k = k
  record.manual = manual
  record.speed = train.speed
  record.tick = game.tick
  record.streak = 0
  record.brake, record.len = train_physics(train)
  reset_curves(record)
  schedule(state, record, game.tick + 1)
  return raw
end

local function rebuild()
  local old = storage.otsr
  local state = new_state(old and old.alerts)
  storage.otsr = state
  for _, train in pairs(game.train_manager.get_trains({})) do
    track(state, train)
  end
  sync_ticking(state)
end

-- Curve look-ahead -------------------------------------------------------------------------------
-- Curves ahead are kept as a flat list of segments {s0, s1, ...} in a distance coordinate along the
-- train's way: the path coordinate (cumulative distance between rail centres from the rail where
-- scanning started) for automatic trains, the odometer for path-less trains.

-- Extends the scan of the path rails until index `min_index` and distance `target` are covered.
local function scan_path(record, rails, size, min_index, target)
  local cum, segs = record.cum, record.segs
  local i, s, x, y, inside = record.si, record.ss, record.sx, record.sy, record.sc
  while i < size and (i < min_index or s == nil or s < target) do
    local rail = rails[i + 1]
    if not (rail and rail.valid) then
      break
    end
    i = i + 1
    local position = rail.position
    local px, py = position.x, position.y
    if s == nil then
      s = 0
    else
      local dx, dy = px - x, py - y
      s = s + sqrt(dx * dx + dy * dy)
    end
    x, y = px, py
    cum[i] = s
    local curved = CURVE_TYPES[rail.type] or false
    if curved then
      if inside then
        segs[#segs] = s
      else
        segs[#segs + 1] = s
        segs[#segs + 1] = s
      end
    end
    inside = curved
  end
  record.si, record.ss, record.sx, record.sy, record.sc = i, s, x, y, inside
  record.known = i >= size and huge or (s or 0)
end

-- Position of the front of an automatic train on its path, or nil without a usable path.
local function path_position(record, train, horizon)
  local path = train.path
  if not (path and path.valid) then
    return nil
  end
  local size, total, current = path.size, path.total_distance, path.current
  if current < 1 or current > size then
    return nil
  end
  if record.cmode ~= PATH_MODE or record.psize ~= size or record.ptotal ~= total or current < record.lo then
    reset_curves(record)
    record.cmode = PATH_MODE
    record.psize = size
    record.ptotal = total
    record.si = current - 1
    record.lo = current
  end
  local cum = record.cum
  for i = record.lo, current - 1 do
    cum[i] = nil
  end
  record.lo = current
  local s = cum[current]
  local rails, last
  if s == nil then
    -- Reach the current rail first; the horizon is measured from it.
    rails = path.rails
    last = #rails
    scan_path(record, rails, last < size and last or size, current, -huge)
    s = cum[current]
    if s == nil then
      reset_curves(record)
      return nil
    end
  end
  if record.known < s + horizon then
    if not rails then
      rails = path.rails
      last = #rails
    end
    scan_path(record, rails, last < size and last or size, current, s + horizon)
  end
  -- The rail index moves in steps of a whole rail. The estimate advances with the odometer and is
  -- only kept between the current and the next rail centre, so the allowed speed falls smoothly.
  local estimate = s
  if record.ps then
    estimate = record.ps + (record.odo - record.podo)
    if estimate < s then
      estimate = s
    end
    local next_s = cum[current + 1]
    if next_s and estimate > next_s then
      estimate = next_s
    end
  end
  record.ps = estimate
  record.podo = record.odo
  return estimate
end

local function add_segment(list, s0, s1)
  local n = #list
  if n >= 2 and s0 <= list[n] + MARGIN then
    if s1 > list[n] then
      list[n] = s1
    end
  else
    list[n + 1] = s0
    list[n + 2] = s1
  end
end

-- Odometer position of a path-less train; looks along the rails every WALK_PERIOD ticks.
local function walk_position(record, train, speed, horizon, tick)
  if record.cmode ~= WALK_MODE then
    reset_curves(record)
    record.cmode = WALK_MODE
  end
  local s = record.odo
  if tick < record.walk_due then
    return s
  end
  record.walk_due = tick + WALK_PERIOD
  -- Keep the segments the front has already entered: the rest of the train may still be on them.
  -- Segments ahead are found again; a start seen before keeps its old value, so the measured
  -- distance does not jitter with the position of the front within its rail.
  local segs, kept, ahead = record.segs, {}, {}
  for j = record.sf, #segs - 1, 2 do
    if segs[j] <= s + MARGIN then
      kept[#kept + 1] = segs[j]
      kept[#kept + 1] = segs[j + 1]
    else
      ahead[#ahead + 1] = segs[j]
    end
  end
  local function stable(s0)
    for i = 1, #ahead do
      local old = ahead[i]
      if old - s0 <= MARGIN and s0 - old <= MARGIN then
        return old
      end
    end
    return s0
  end
  local known = s
  local rail_end = train.get_rail_end(speed < 0 and BACK or FRONT)
  local rail = rail_end and rail_end.rail
  if rail then
    local position = rail.position
    local x, y = position.x, position.y
    local d = 0
    local inside = CURVE_TYPES[rail.type] or false
    local start = 0
    local steps = 0
    local ended = false
    while d < horizon do
      if steps >= MAX_WALK_STEPS then
        break
      end
      if not rail_end.move_natural() then
        ended = true
        break
      end
      steps = steps + 1
      rail = rail_end.rail
      position = rail.position
      local dx, dy = position.x - x, position.y - y
      local next_d = d + sqrt(dx * dx + dy * dy)
      x, y = position.x, position.y
      local curved = CURVE_TYPES[rail.type] or false
      if curved and not inside then
        start = next_d
      elseif inside and not curved then
        add_segment(kept, stable(s + start), s + d)
      end
      inside = curved
      d = next_d
    end
    if inside then
      add_segment(kept, stable(s + start), s + d)
    end
    known = ended and huge or s + d
  end
  record.segs = kept
  record.sf = 1
  record.known = known
  return s
end

-- Returns the highest speed allowed now (tiles/tick, absolute) and the ticks the train may sleep.
local function curve_limit(record, train, speed, abs, tick)
  local vmax = top_speed(train, speed)
  local brake = record.brake
  if vmax <= 0 or brake <= 0 then
    return huge, MAX_SLEEP
  end
  local vlim = vmax * curve_share
  local decel = brake * CURVE_BRAKING
  local reach = (vmax * vmax - vlim * vlim) / (2 * decel) -- braking distance from top speed
  local s
  if not train.manual_mode then
    s = path_position(record, train, reach + 2 * MARGIN + vmax * MAX_SLEEP)
  end
  local sleep_cap = MAX_SLEEP
  if not s then
    s = walk_position(record, train, speed, reach + 2 * MARGIN + vmax * WALK_PERIOD, tick)
    sleep_cap = record.walk_due - tick
    if sleep_cap < 1 then
      sleep_cap = 1
    end
  end
  record.last_s = s

  local segs, j = record.segs, record.sf
  local hold = record.len + MARGIN
  while segs[j] and segs[j + 1] + hold < s do
    j = j + 2
  end
  record.sf = j
  local s0 = segs[j]
  if not s0 then
    local free = record.known - s - reach - MARGIN
    local sleep = free >= vmax * sleep_cap and sleep_cap or floor(free / vmax)
    return huge, sleep < 1 and 1 or sleep
  end

  local distance = s0 - MARGIN - s
  local allowed = vlim
  if distance > 0 then
    allowed = sqrt(vlim * vlim + 2 * decel * distance)
    local free = distance - reach
    if free > 0 then
      -- Even at top speed no braking is needed before the train has covered `free`.
      local sleep = free >= vmax * sleep_cap and sleep_cap or floor(free / vmax)
      return allowed, sleep < 1 and 1 or sleep
    end
  end
  local gap = allowed - abs
  if gap <= allowed * (1 - CLOSE_SHARE) then
    return allowed, 1
  end
  -- The allowed speed falls by at most `decel` per tick of approach, the train gains at most
  -- ACCEL_BOUND per tick.
  local sleep = floor(gap / (ACCEL_BOUND + decel))
  if sleep > WALK_PERIOD then
    sleep = WALK_PERIOD
  end
  if sleep > sleep_cap then
    sleep = sleep_cap
  end
  return allowed, sleep < 1 and 1 or sleep
end

-- Per-tick processing ----------------------------------------------------------------------------

local function wake(state, record, tick)
  local train = record.train
  if not train.valid then
    forget(state, record.id)
    return
  end
  local speed = train.speed
  local previous = record.speed
  local abs = speed < 0 and -speed or speed
  local previous_abs = previous < 0 and -previous or previous
  local elapsed = tick - record.tick
  if elapsed < 1 then
    elapsed = 1
  end
  record.tick = tick
  record.odo = record.odo + (abs + previous_abs) * 0.5 * elapsed

  -- Cargo inertia: scale the gain since the last check.
  local target = abs
  local gain = 0
  if speed ~= 0 and previous * speed >= 0 and abs > previous_abs then
    gain = abs - previous_abs
    if record.manual and previous == 0 then
      -- A parked manual train may have been loaded by hand: measure it again on departure.
      record.k = train_factor(train)
    end
    if record.k < 1 then
      target = previous_abs + gain * record.k
    end
  end

  local delay
  if record.k < 1 or record.manual then
    if gain > GROWTH_EPSILON * elapsed then
      record.streak = 0
      delay = 1
    elseif record.manual and #train.passengers > 0 then
      delay = 1 -- a player at the controls may accelerate at any moment
    elseif record.streak < HOT_PATIENCE then
      record.streak = record.streak + 1
      delay = record.streak < HOT_PATIENCE and 1 or COLD_PERIOD
    else
      delay = COLD_PERIOD
    end
  end

  -- Curves: lower the speed further if needed, never faster than full braking.
  if curves_on then
    local curve_delay
    if target > 0 then
      local allowed
      allowed, curve_delay = curve_limit(record, train, speed, target, tick)
      if target > allowed then
        local lowered = target - record.brake
        target = lowered > allowed and lowered or allowed
        curve_delay = 1
      end
    elseif not record.manual then
      curve_delay = DEPART_PERIOD
    end
    if curve_delay and (not delay or curve_delay < delay) then
      delay = curve_delay
    end
  end

  if target ~= abs then
    speed = speed < 0 and -target or target
    train.speed = speed
  end
  record.speed = speed

  if delay then
    schedule(state, record, tick + delay)
  else
    forget(state, record.id)
  end
end

on_tick = function(event)
  local state = storage.otsr
  local tick = event.tick
  local wheel = state.wheel
  local bucket = wheel[tick]
  if bucket then
    wheel[tick] = nil
    local records = state.records
    for i = 1, #bucket do
      local record = records[bucket[i]]
      if record and record.due == tick then
        record.due = nil
        state.scheduled = state.scheduled - 1
        wake(state, record, tick)
      end
    end
  end
  if state.scheduled == 0 then
    sync_ticking(state)
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
    -- Moving automatic train: its cargo cannot have changed since it was last measured. A changed
    -- path is detected by the curve look-ahead itself.
    if record then
      if not train.manual_mode and WAITING[train.state] then
        forget(state, id)
      else
        record.manual = train.manual_mode
        record.streak = 0
        schedule(state, record, game.tick + 1)
      end
      sync_ticking(state)
      return
    end
    if not train.manual_mode then
      return
    end
  end

  -- Leaving a stop or manual control (cargo may have changed), or entering manual control.
  local raw = track(state, train)
  if raw and not train.manual_mode and WAITING[old_state] then
    clear_alert(state, id)
    if raw < minimum_factor then
      raise_alert(state, train, raw)
    end
  end
  sync_ticking(state)
end

local function on_train_created(event)
  local state = storage.otsr
  local old_1, old_2 = event.old_train_id_1, event.old_train_id_2
  if old_1 then
    forget(state, old_1)
    clear_alert(state, old_1)
  end
  if old_2 then
    forget(state, old_2)
    clear_alert(state, old_2)
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
    schedule(state, record, game.tick + 1)
  else
    track(state, train)
  end
  sync_ticking(state)
end

local function on_runtime_mod_setting_changed(event)
  if event.setting and event.setting:sub(1, 5) == "otsr-" and event.setting_type == "runtime-global" then
    read_settings()
    rebuild()
  end
end

-- Inspection -------------------------------------------------------------------------------------

local function describe(train)
  -- Callable from other mods at any time, also from their on_init on load, which runs before this
  -- mod's on_load / on_configuration_changed: settings may be unread and storage of an old version.
  if not slot_weight then
    read_settings()
  end
  local slots, fluid = measure(train)
  local weight = train.weight
  local k, raw, mass = factor_for(weight, slots, fluid)
  local state = storage.otsr
  local record = state and state.records and state.records[train.id]
  local curve_limit_kmh
  if curves_on then
    curve_limit_kmh = train.max_forward_speed * curve_share * KMH
  end
  local next_curve
  if record and record.segs and record.sf and record.last_s then
    local s0 = record.segs[record.sf]
    if s0 then
      next_curve = s0 - record.last_s
    end
  end
  return {
    train_id = train.id,
    weight = weight,
    slots = slots,
    fluid = fluid,
    mass = mass,
    factor = k,
    raw_factor = raw,
    overloaded = raw < minimum_factor,
    tracked_factor = record and type(record.k) == "number" and record.k or nil,
    curve_limit_kmh = curve_limit_kmh,
    next_curve = next_curve,
    next_check = record and record.due or nil,
    status = record and "tracked" or "idle",
  }
end

remote.add_interface("OverloadedTrainsSimple-reforged", {
  -- Returns the current load estimate, curve limit and tracking status of a train, or nil.
  describe_train = function(train_id)
    local train = game.train_manager.get_train_by_id(train_id)
    if train and train.valid then
      return describe(train)
    end
  end,
})

local function curve_text(info)
  if info.curve_limit_kmh then
    return { "otsr.curve-limit", string.format("%.0f", info.curve_limit_kmh) }
  end
  return { "otsr.curve-off" }
end

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
  player.print(curve_text(info))
end)

-- Panel next to the train window; filled when the window is opened.
local function on_gui_opened(event)
  local entity = event.entity
  if not (entity and entity.valid) then
    return
  end
  local train = entity.train
  if not (train and train.valid) then
    return
  end
  local player = game.get_player(event.player_index)
  if not player then
    return
  end
  local relative = player.gui.relative
  local frame = relative[PANEL]
  if not frame then
    frame = relative.add({
      type = "frame",
      name = PANEL,
      caption = { "otsr.panel-title" },
      direction = "vertical",
      anchor = { gui = defines.relative_gui_type.train_gui, position = defines.relative_gui_position.right },
    })
  end
  frame.clear()
  local info = describe(train)
  frame.add({ type = "label", caption = { "otsr.panel-cargo", string.format("%.1f", info.slots), string.format("%.0f", info.fluid) } })
  frame.add({ type = "label", caption = { "otsr.panel-mass", string.format("%.0f", info.mass), string.format("%.0f", info.weight) } })
  frame.add({ type = "label", caption = { "otsr.panel-factor", string.format("%.0f", info.factor * 100) } })
  if info.overloaded then
    frame.add({ type = "label", caption = { "otsr.panel-overloaded" }, style = "bold_red_label" })
  end
  frame.add({ type = "label", caption = curve_text(info) })
end

-- Lifecycle --------------------------------------------------------------------------------------

script.on_init(function()
  read_settings()
  rebuild()
end)

script.on_load(function()
  read_settings()
  local state = storage.otsr
  if state and state.scheduled and state.scheduled > 0 then
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
script.on_event(defines.events.on_gui_opened, on_gui_opened)
