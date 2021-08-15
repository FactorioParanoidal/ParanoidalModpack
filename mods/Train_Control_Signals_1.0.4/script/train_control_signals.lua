local util = require("util")

local fuel_signal = "%[virtual%-signal=refuel%-signal]"
local fuel_signal_disabled = "%[virtual%-signal=refuel%-signal%-disabled]"

local depot_signal = "%[virtual%-signal=depot%-signal]"
local depot_signal_disabled = "%[virtual%-signal=depot%-signal%-disabled]"

local skip_signal = "%[virtual%-signal=skip%-signal]"

local train_needs_refueling = function(train)
  local locomotives = train.locomotives
  for k, movers in pairs (locomotives) do
    for k, locomotive in pairs (movers) do
      local fuel_inventory = locomotive.get_fuel_inventory()
      fuel_inventory.sort_and_merge()
      if #fuel_inventory > 1 then
        if not fuel_inventory[2].valid_for_read then
          return true
        end
      else
        --Locomotive with only 1 fuel stack... idk, lets just guess
        local stack = fuel_inventory[1]
        if not stack.valid_for_read then
          --Nothing in the stack, needs refueling.
          return true
        end
        if stack.count < math.ceil(stack.prototype.stack_size / 4) then
          return true
        end
      end
    end
  end
  return false
end

local station_is_disabled = function(station)
  return station:find(skip_signal)
end

local station_is_open_depot = function(station)
  if not station then return false end
  return station:find(depot_signal) and not station_is_disabled(station)
end

local train_needs_depot = function(train, old_state)

  local schedule = train.schedule
  if not schedule then return end

  if train.state == defines.train_state.wait_station then
    -- We just arrived at a station, if its a depot station keep it open
    return station_is_open_depot(schedule.records[schedule.current].station)
  end

  if old_state == defines.train_state.no_path then
    --We had no path, now we do
    --We only keep depots open if we are going to a depot
    return station_is_open_depot(schedule.records[schedule.current].station)
  end

  if old_state == defines.train_state.destination_full then
    --We had no path, now we do
    --We only keep depots open if we are going to a depot
    return station_is_open_depot(schedule.records[schedule.current].station)
  end

  if old_state == defines.train_state.wait_station then
    --We just left a station
    if train.has_path then
      --We have a path, if we're going to a depot, we keep it open.
      return station_is_open_depot(schedule.records[schedule.current].station)
    end
    return true
  end

end

local care_about =
{
  [defines.train_state.wait_station] = true,
  [defines.train_state.no_path] = true,
  [defines.train_state.destination_full] = true,
}

local on_train_changed_state = function(event)

  local train = event.train
  if not (train and train.valid) then return end

  if not (care_about[train.state] or care_about[event.old_state]) then
    -- Some state that we don't care about
    return
  end

  local schedule = train.schedule
  if not schedule then return end

  local needs_refuel = train_needs_refueling(train)
  local needs_depot = train_needs_depot(train, event.old_state)
  local changed = false
  for k, record in pairs (schedule.records) do
    local station = record.station
    if station then
      local enable = false
      local disable = false
      if station:find(fuel_signal) then
        enable = needs_refuel
        disable = not enable
      end
      if station:find(depot_signal) then
        enable = enable or needs_depot
        disable = not enable
      end
      if enable and station:find(skip_signal) then
        record.station = station:gsub(skip_signal, "")
        changed = true
      end
      if disable and not station:find(skip_signal) then
        record.station = skip_signal:gsub("%%", "") .. station
        changed = true
      end
    end
  end

  if changed then
    if needs_depot then

      -- We are able to go to a depot, but we only want to do that if it is in the schedule in the correct order
      -- What that means, is we just check if the previous station in the schedule is a depot, if so, go there, if not, we stay with destination full.

      local current = schedule.current
      local previous_index = current - 1
      if previous_index <= 0 then
        previous_index = #schedule.records
      end

      if station_is_open_depot(schedule.records[previous_index].station) then
        schedule.current = previous_index
      end

    end
    train.schedule = schedule
  end

end

local check_rename_signal = function(entity, old_name, enabled_name)

  local new_name = entity.backer_name

  if new_name:find(skip_signal) then
    --naughty...
    entity.backer_name = new_name:gsub(skip_signal, "")
    return
  end

  if not old_name:find(enabled_name) then
    return
  end

  --old name had a control signal, lets emulate the base game thing where it fixes the schedules

  local stops = entity.force.get_train_stops({surface = entity.surface, name = old_name})
  if next(stops) then
    --there are still some with the old name, do nothing
    return
  end

  local old_disabled_name = skip_signal:gsub("%%", "") .. old_name
  local new_disabled_name = skip_signal:gsub("%%", "") .. new_name

  local trains = entity.force.get_trains(entity.surface)

  for k, train in pairs (trains) do
    local schedule = train.schedule
    if schedule then
      local changed = false
      for k, record in pairs(schedule.records) do
        if record.station then
          if record.station == old_disabled_name then
            changed = true
            record.station = new_disabled_name
          end
        end
      end
      if changed then
        train.schedule = schedule
      end
    end
  end

end

local on_entity_renamed = function(event)
  local entity = event.entity
  if not (entity and entity.valid and entity.type == "train-stop") then
    return
  end

  check_rename_signal(entity, event.old_name, fuel_signal)
  check_rename_signal(entity, event.old_name, depot_signal)

end

local on_train_schedule_changed = function(event)
  if event.player_index then
    on_train_changed_state(event)
  end
end

local lib = {}

lib.events =
{
  [defines.events.on_train_changed_state] = on_train_changed_state,
  [defines.events.on_entity_renamed] = on_entity_renamed,
  [defines.events.on_train_schedule_changed] = on_train_schedule_changed,
}

lib.on_init = function()
end

lib.on_configuration_changed = function()
end

return lib
