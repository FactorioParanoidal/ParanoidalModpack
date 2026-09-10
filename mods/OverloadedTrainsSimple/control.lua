local TRAINS_PER_TICK = 6
local LOAD_REFRESH_INTERVAL = 60

local function ensure_state()
  storage.overloaded_trains_simple = storage.overloaded_trains_simple or {
    trains = {},
    cursor = nil,
  }
  return storage.overloaded_trains_simple
end

local function calculate_load(train)
  local occupied_slots = 0
  local fluid_amount = 0

  for _, wagon in pairs(train.cargo_wagons) do
    local inventory = wagon.get_inventory(defines.inventory.cargo_wagon)
    if inventory then
      for slot = 1, #inventory do
        if inventory[slot].valid_for_read then
          occupied_slots = occupied_slots + 1
        end
      end
    end
  end

  for _, amount in pairs(train.get_fluid_contents()) do
    fluid_amount = fluid_amount + amount
  end

  return occupied_slots, fluid_amount
end

local function register_train(train)
  if not (train and train.valid) then
    return
  end

  local state = ensure_state()
  local occupied_slots, fluid_amount = calculate_load(train)
  local entry = state.trains[train.id]
  if entry then
    entry.train = train
    entry.occupied_slots = occupied_slots
    entry.fluid_amount = fluid_amount
    entry.load_tick = game.tick
    entry.speed = train.speed
  else
    state.trains[train.id] = {
      train = train,
      occupied_slots = occupied_slots,
      fluid_amount = fluid_amount,
      load_tick = game.tick,
      speed = train.speed,
    }
  end
end

local function remove_train(id)
  if not id then
    return
  end

  local state = ensure_state()
  state.trains[id] = nil
  if state.cursor == id then
    state.cursor = nil
  end
end

local function rebuild_trains()
  storage.overloaded_trains_simple = {
    trains = {},
    cursor = nil,
  }

  for _, train in pairs(game.train_manager.get_trains({})) do
    register_train(train)
  end
end

local function discover_trains()
  local state = ensure_state()
  for _, train in pairs(game.train_manager.get_trains({})) do
    if not state.trains[train.id] then
      register_train(train)
    end
  end
end

local function on_train_created(event)
  remove_train(event.old_train_id_1)
  remove_train(event.old_train_id_2)
  register_train(event.train)
end

local function on_train_changed_state(event)
  register_train(event.train)
end

local function next_train(state)
  local id = next(state.trains, state.cursor)
  if not id then
    id = next(state.trains)
  end
  state.cursor = id
  return id, id and state.trains[id] or nil
end

local function slow_acceleration(entry)
  local train = entry.train
  if not (train and train.valid) then
    return false
  end

  if entry.occupied_slots == nil or entry.fluid_amount == nil or game.tick - entry.load_tick >= LOAD_REFRESH_INTERVAL then
    entry.occupied_slots, entry.fluid_amount = calculate_load(train)
    entry.load_tick = game.tick
  end

  local current_speed = train.speed
  local previous_speed = entry.speed or current_speed
  local current_absolute = math.abs(current_speed)
  local previous_absolute = math.abs(previous_speed)

  if current_speed ~= 0
    and previous_speed * current_speed >= 0
    and current_absolute > previous_absolute
    and (entry.occupied_slots > 0 or entry.fluid_amount > 0)
  then
    local slots_for_minimum = settings.global["ots-slots-for-minimum-acceleration"].value
    local fluid_for_minimum = settings.global["ots-fluid-for-minimum-acceleration"].value
    local minimum_acceleration = settings.global["ots-minimum-acceleration"].value
    local load_fraction = entry.occupied_slots / slots_for_minimum + entry.fluid_amount / fluid_for_minimum
    local acceleration_factor = 1 - math.min(load_fraction, 1) * (1 - minimum_acceleration)
    local adjusted_absolute = previous_absolute + (current_absolute - previous_absolute) * acceleration_factor
    train.speed = current_speed < 0 and -adjusted_absolute or adjusted_absolute
    current_speed = train.speed
  end

  entry.speed = current_speed
  return true
end

local function on_tick()
  local state = ensure_state()
  local visited = {}

  for _ = 1, TRAINS_PER_TICK do
    local id, entry = next_train(state)
    if not id or visited[id] then
      break
    end
    visited[id] = true

    if not slow_acceleration(entry) then
      remove_train(id)
    end
  end
end

script.on_init(rebuild_trains)
script.on_configuration_changed(rebuild_trains)
script.on_event(defines.events.on_train_created, on_train_created)
script.on_event(defines.events.on_train_changed_state, on_train_changed_state)
script.on_event(defines.events.on_tick, on_tick)
script.on_nth_tick(60, discover_trains)
