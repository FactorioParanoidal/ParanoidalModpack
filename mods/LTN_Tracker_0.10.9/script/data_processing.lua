--[[
-- STRUCTURE --
* whenever data is received from LTN events, data_processor() is called
* data_processor registers for on_tick and deals with a chunk of the available data on each tick
* the amount of data handled per tick is set in ltnt/const.lua
* any additional updates from LTN are ignored while this happens
  (I would expect data handling to be faster than LTN's once-per-second updates, but it might not be for a very large base)
* when processing is finished:
    - all data is pushed to the global.data table
    - data_processor() unregisters from on_tick
    - on_data_updated is raised to let the UI know that new data is available

-- GLOBAL OVERVIEW --
global.raw   >> contains data currently being processed, not ready for display yet
global.data  >> contains processed data and can be used by UI
global.proc  >> stores the current state of processing

--> UI should never access global.raw
--> global.data has to be complete at all times, otherwise UI accessing data will cause errors


--tables stored in global.raw: -----------------------------------------------------------------------------------

-- LTN DATA
.stops  >> table as received from on_stops_updated, modified during processing
  key = stop_id,     value = table with all available data for each non-error stop
  [stop_id] = {
    entity: LuaEntity,
    input: LuaEntity,
    output: LuaEntity,
    lampControl: LuaEntity,
    isDepot: bool,
    network_id: int,
    trainLimit: int,
    activeDeliveries: table,
    errorCode: int,
    parkedTrain: LuaTrain,
    parkedTrainID: int,
   -- up to here as received from LTN, following entries created during processing
    name: string,
    provided: table,
    requested: table,
    incoming: table,
    outgoing: table,
    signals: table,
  }
.dispatch >> table as received from on_dispatcher_updated

-- LOOKUP TABLES --
.name2id        >> key = stop_name,   value = stop_id (if multiple stops share a name: one of their IDs)
.item2stop      >> key = item,        value = table with stop IDs providing/requesting the item
.item2delivery  >> key = item,        value = table with delivery IDs currently transporting that item

-- DATA TABLES --
.depots         >> key = depot_name,  value = table with stopsdata for each depot stop
.provided       >> keys= network_id>item,  value = total amount provided of item in network_id
.deliveries     >> key = train_id,    value = table listing delviery data
.trains_error   >> key = train_id,    value = table with trains ins error state
.requested      >> same as above, but for requested items
.in_transit     >> key = item,        value = amount of item currently transported by trains

after processing finishes, all global.raw tables are moved to global.data, with the exception of global.raw.dispatch
------------------------------------------------------------------------------------------------------------------

-- additional tables in global.data --
.delivery_hist  >> lsits finished deliveries, received from LTN's on_delivery_completed event

--]]

--local references to functions
local pairs, next = pairs, next

-- local references to globals, set during on_load
local raw
local data
local events -- custom event ids

-- constants
--local HISTORY_LIMIT = require("script.constants").proc.history_limit
local STOPS_PER_TICK = require("script.constants").proc.stops_per_tick
local DELIVERIES_PER_TICK = require("script.constants").proc.deliveries_per_tick
local TRAINS_PER_TICK = require("script.constants").proc.trains_per_tick
local ITEMS_PER_TICK = require("script.constants").proc.items_per_tick
local LTN_CONSTANTS = require("script.constants").ltn
local HISTORY_LIMIT = settings.global["ltnt-history-limit"].value
local FILENAME = "data.log"

local out = out
---------------------
-- DATA PROCESSING --
---------------------
-- functions here are called from data_processor, defined below

local ctrl_signal_var_name_bool = require("script.constants").ltn.ctrl_signal_var_name_bool
local ctrl_signal_var_name_num = require("script.constants").ltn.ctrl_signal_var_name_num
local function get_lamp_color(stop) -- helper functions for state 1
  --local color_signal = stop.lampControl.get_control_behavior().get_signal(1)
  --return color_signal and color_signal.signal.name
  return stop.lampControl.get_control_behavior().get_signal(1).signal.name
end
local function get_control_signals(stop)
  local color_signal = stop.lampControl.get_control_behavior().get_signal(1)
  --local status = color_signal and {color_signal.signal.name,  color_signal.count}
  local signals = {}
  for sig_name,v in pairs(ctrl_signal_var_name_bool) do
     signals[sig_name] = stop[v] and 1 or nil
  end
  for sig_name,v in pairs(ctrl_signal_var_name_num) do
     signals[sig_name] = stop[v] > 0 and stop[v] or nil
  end
  return {{color_signal.signal.name,  color_signal.count}, signals}
end

local function update_stops(stop_id) -- state 1
  local stops = raw.stops
  --local counter = 0
  --while counter < STOPS_PER_TICK do -- process only a limited amount of stops per tick
    --counter = counter + 1
    --local stop
  for stop_id, stop in pairs(stops) do
    --stop_id, stop = next(stops, stop_id)
    --if stop then
    if stop.entity.valid and stop.lampControl.valid then
      local name = stop.entity.backer_name
      if stop.isDepot then
        if raw.depots[name] then
          local depot = raw.depots[name]
          -- add stop to depot
          depot.network_ids[#depot.network_ids+1] = stop.network_id
          depot.signals[get_lamp_color(stop)] = (depot.signals[get_lamp_color(stop)] or 0) + 1
        else
          --create new depot
          raw.depots[name] = {
            parked_trains = {},
            signals = {[get_lamp_color(stop)] = 1},
            network_ids = {stop.network_id},
            all_trains = stop.entity.get_train_stop_trains(),
            n_parked = 0,
            n_all_trains = 0,
            cap = 0,
            fcap = 0,
          }
        end
      else  -- non-depot stop
        raw.name2id[name] = stop_id  -- list in name lookup table
        stop.name = name
        stop.signals = get_control_signals(stop)
        stop.incoming = {}
        stop.outgoing = {}
        raw.stop_ids[#raw.stop_ids+1] = stop_id
      end
    end   -- if stop.valid
   -- else
    --  return nil -- all stops done
    --end --if stop_id then
  end
  return nil --stop_id
end

local function check_for_new_stops()
  for _, stop_id in pairs(data.stop_ids or {}) do
    if not raw.stops[stop_id] then
      ui.clear_station_filter()
      break
    end
  end
end

local function update_depots(raw, depot_name) -- state 3
  local av_trains = raw.available_trains
  local counter = 0
  while counter < TRAINS_PER_TICK do -- for depot_name, depot in pairs(raw.depots) do
    local depot
    depot_name, depot = next(raw.depots, depot_name)
    if depot then
      --while counter < TRAINS_PER_TICK do
      for train_index, train in pairs(depot.all_trains) do
        if train.valid then
          depot.n_all_trains = depot.n_all_trains + 1
          local train_id = train.id
          if av_trains[train_id] then
            depot.parked_trains[train_id] = av_trains[train_id]
            depot.n_parked = depot.n_parked + 1
            depot.cap = depot.cap + av_trains[train_id].capacity
            depot.fcap = depot.fcap + av_trains[train_id].fluid_capacity
          end
        end
      end  -- inner while
    else
      return nil
    end -- if depot
    counter = counter + depot.n_all_trains
  end -- outer while
  return depot_name
end

local function update_provided(raw) -- state 4
  -- sort provided items by network id
  local i2s = raw.item2stop
  for stop_id, provided in pairs(raw.provided_by_stop) do
    local stop = raw.stops[stop_id]
    if stop then
      for item, count in pairs(provided) do
        -- list stop as provider for item
        i2s[item] = i2s[item] or {}
        i2s[item][#i2s[item]+1] = stop_id
        local networkID = stop.network_id
        -- store provided amount for each network id and item
        raw.provided[networkID] = raw.provided[networkID] or {}
        raw.provided[networkID][item] = (raw.provided[networkID][item] or 0) + count
      end
    end
  end
end

local function update_requested(raw) -- state 5
    -- sort requested items by network id
  local i2s = raw.item2stop
  local requests = raw.requests_by_stop
  for stop_id, request in pairs(requests) do
    if raw.stops[stop_id] then
      local networkID = raw.stops[stop_id].network_id
      for item, count in pairs(request) do
        -- list stop as requester for item
        i2s[item] = i2s[item] or {}
        i2s[item][#i2s[item]+1] = stop_id
        -- store requested amount for each network id and item
        raw.requested[networkID] = raw.requested[networkID] or {}
        raw.requested[networkID][item] = (raw.requested[networkID][item] or 0) - count
      end
    end
  end
  return nil
end

local function update_in_transit(delivery_id, delivery, raw) -- helper function for state 7
  if raw.stops[delivery.to_id] and raw.stops[delivery.from_id] then
    local network_id = delivery.networkID or -1
    raw.in_transit[network_id] = raw.in_transit[network_id] or {}
    local inc = raw.stops[delivery.to_id] and raw.stops[delivery.to_id].incoming or {}
    -- only add to outgoing if pickup is not done yet
    local og = not delivery.pickupDone and raw.stops[delivery.from_id] and raw.stops[delivery.from_id].outgoing
    for item, amount in pairs(delivery.shipment) do
      raw.in_transit[network_id][item] = (raw.in_transit[network_id][item] or 0) + amount
      raw.item2delivery[item] = raw.item2delivery[item] or {}
      raw.item2delivery[item][#raw.item2delivery[item]+1] = delivery_id
      inc[item] = (inc[item] or 0) + amount
      if og then og[item] = (og[item] or 0) - amount end
    end
  end
end

local function add_new_deliveries(raw, delivery_id) -- state 7
  local counter = 0
  while counter < DELIVERIES_PER_TICK do
    counter = counter + 1
    local delivery
    delivery_id, delivery = next(raw.deliveries, delivery_id)
    if delivery then
      delivery.from_id = raw.name2id[delivery.from]
      delivery.to_id = raw.name2id[delivery.to]
      -- add items to in_transit list and incoming/outgoing
      update_in_transit(delivery_id, delivery, raw)
    else
      return nil
    end
  end
  return delivery_id
end

--------------------
-- EVENT HANDLERS --
--------------------
local data_processor -- defined later

-- on_dispatcher_updated is always triggered right after on_stops_updated
local function on_stops_updated(event)
  raw.stops = event.logistic_train_stops
end
local function on_dispatcher_updated(event)
  raw.deliveries = event.deliveries
  raw.available_trains =  event.available_trains
  raw.requests_by_stop = event.requests_by_stop
  raw.provided_by_stop = event.provided_by_stop
  data_processor()
end

-- data_processor starts running on_tick when new data arrives and stops when processing is finished
data_processor = function(event)
  local proc = global.proc
  if proc.state == 0 then -- new data arrived, init processing
    script.on_event(defines.events.on_tick, data_processor)
    -- suspend LTN interface during data processing
    script.on_event(events.on_stops_updated_event, nil)
    script.on_event(events.on_dispatcher_updated_event, nil)

    -- reset raw data
    raw.depots = {}
    raw.provided = {}
    raw.requested = {}
    raw.in_transit = {}
    raw.name2id = {}
    raw.item2stop = {}
    raw.item2delivery = {}
    raw.stop_ids = {}

    -- reset state
    -- could be condensed down to just one variable, but it's more readable this way
    proc.next_stop_id = nil
    proc.next_depot_name = nil
    proc.next_delivery_id = nil

    proc.state = 1 -- set next state

  -- processing functions for each state can take multiple ticks to complete
  -- if those functions return a value, they will be called again next tick, with that value as input
  -- the returned value should allow the function to continue from where it stopped
  -- they must return nil when their job is done, in which case proc.state is incremented

  ---- state 6 unused ------
  elseif proc.state == 1 then
  -- processing stops first, information gathered here is required for other steps
    local stop_id = update_stops(raw, proc.next_stop_id)
    if stop_id then
      proc.next_stop_id = stop_id -- store last processed id, so we know where to continue next tick
    else
      proc.state = 2 -- go to next state
    end
  elseif proc.state == 2 then
    check_for_new_stops()
    proc.state = 3
  elseif proc.state == 3 then
    -- sorting available trains by depot
    local depot_name = update_depots(raw, proc.next_depot_name)
    if depot_name then
      proc.next_depot_name = depot_name
    else
      proc.state = 4
    end

  elseif proc.state == 4 then
    -- sorting provided items by network id and stop
    update_provided(raw)
    proc.state = 5

  elseif proc.state == 5 then
    -- sorting requested items by network id and stop
    update_requested(raw)
    proc.state = 7

  elseif proc.state == 7 then
    -- add new deliveries and update items in transit
    local next_delivery_id = add_new_deliveries(raw, proc.next_delivery_id)
    if next_delivery_id then
      proc.next_delivery_id = next_delivery_id
    else
      proc.state = 100
    end

  elseif proc.state == 100 then -- update finished
    -- update globals
    data.stops =  raw.stops
    data.depots = raw.depots
    data.provided =  raw.provided
    data.requested = raw.requested
    data.in_transit = raw.in_transit
    data.deliveries = raw.deliveries
    data.name2id =  raw.name2id
    data.item2stop =  raw.item2stop
    data.item2delivery = raw.item2delivery
    data.provided_by_stop = raw.provided_by_stop
    data.requested_by_stop = raw.requests_by_stop
    data.stop_ids = raw.stop_ids

    -- stop on_tick updates, start listening for LTN interface
    script.on_event(events.on_stops_updated_event, on_stops_updated)
    script.on_event(events.on_dispatcher_updated_event, on_dispatcher_updated)
    script.on_event(defines.events.on_tick, nil)
    script.raise_event(events.on_data_updated, {})

    proc.state = 0
  end
end

-- delivery tracking  local get_main_loco
local get_main_loco
do
  require("__OpteraLib__.script.train")
  get_main_loco = get_main_locomotive
end
local FLUID_TOL = require("script.constants").proc.fluid_tolerance
local abs = math.abs
local function item_match(strg)
  return string.match(strg, "%w+,([%w_%-]+)")
end

local function store_history(history)
  if debug_log then
    log2("New history record:\n", history)
  end
  history.runtime = game.tick - history.started
  history.networkID = history.networkID and history.networkID > 2147483648 and history.networkID - 4294967296 or history.networkID -- convert from uint32 to int32
  data.delivery_hist[data.newest_history_index] = history
  data.newest_history_index = (data.newest_history_index % HISTORY_LIMIT) + 1
end

local function raise_alert(delivery, train, alert_type, actual_cargo)
  local loco = get_main_loco(train)
  delivery.to_id = delivery.to_id or data.name2id[delivery.to] or 0
  delivery.from_id = delivery.from_id or data.name2id[delivery.from] or 0
  data.trains_error[data.train_error_count] = {
    type = alert_type,
    loco = loco,
    delivery = delivery,
    cargo = actual_cargo,
  }
  if debug_log then
    log2("Train error state detected:\n", data.trains_error[data.train_error_count])
  end
  script.raise_event(events.on_train_alert, data.trains_error[data.train_error_count])
  data.train_error_count = data.train_error_count + 1
end

local function on_pickup_completed(event)
  -- compare train content to planned shipment
  local delivery = event.delivery
  local train = delivery.train
  local item_cargo = train.get_contents() -- does return empty table when train is empty, not nil
  local fluid_cargo = train.get_fluid_contents()
  local old_delivery = data.deliveries[train.id]
  local actual_cargo = {}
  if debug_log then
    log2("Pickup complete event received.\nEvent data:\n", event, "\nItem cargo:", item_cargo, "\nFluid cargo:", fluid_cargo, "\nOld delivery:\n", old_delivery)
  end
  local keys = {}
  local alert = false
  if old_delivery and global.proc.underload_is_alert then
    for item, new_amount in pairs(delivery.shipment) do
      local old_amount = old_delivery.shipment[item]
      if new_amount < old_amount  then
        alert = true
      end
      actual_cargo[item] = new_amount
      keys[item_match(item) or ""] = true
    end
  else
    for item, new_amount in pairs(delivery.shipment) do
      keys[item_match(item) or ""] = true
    end
    actual_cargo = delivery.shipment
  end
  for item_name, amount in pairs(item_cargo) do
    if not keys[item_name] then
      actual_cargo["item,"..item_name] = amount
      alert = true
    end
  end
  for fluid_name, amount in pairs(fluid_cargo) do
    if not keys[fluid_name] then
      actual_cargo["fluid,"..fluid_name] = amount
      alert = true
    end
  end

  if alert then
    if old_delivery then
      old_delivery.depot = train.schedule and train.schedule.records[1] and train.schedule.records[1].station or "unknown"
      raise_alert(old_delivery, train, "incorrect_cargo", actual_cargo)
    else
      delivery.depot = train.schedule and train.schedule.records[1] and train.schedule.records[1].station or "unknown"
      raise_alert(delivery, train, "incorrect_cargo", actual_cargo)
    end
  end
end

local function on_delivery_completed(event)
  if debug_log then
    log2("Delivery complete event received.\nEvent data:\n", event)
  end
  -- check train for residual content
  -- if a train has fluid and items, only item residue is logged
  local delivery = event.delivery
  local train = delivery.train
  delivery.depot = train.schedule and train.schedule.records[1] and train.schedule.records[1].station or "unknown"
  local res = train.get_contents() -- does return empty table when train is empty, not nil
  local fres = train.get_fluid_contents()
  if next(res) or next(fres) then
    if next(res) then
      delivery.residuals = {"item", res}
    else
      delivery.residuals = {"fluid", fres}
    end
    raise_alert(delivery, train, "residuals", delivery.residuals)
  end
  store_history(delivery)
end

local function on_delivery_failed(event)
  if debug_log then
    log2("Delivery failed event received.\nEvent data:\n", event)
  end
  local delivery = event.delivery
  local train = delivery.train
  if train.valid then
    -- train still valid -> delivery timed out
    delivery.timed_out = true
    delivery.depot = train.schedule and train.schedule.records[1] and train.schedule.records[1].station
    raise_alert(delivery, train, "timeout")
  else
    -- train became invalid during delivery
    raise_alert(delivery, train, "train_invalid")
  end
  store_history(delivery)
end

----------------------
-- PUBLIC FUNCTIONS --
----------------------
local function on_load()
  -- cache globals
  raw = global.raw
  data = global.data

  -- cache event IDs
  events = custom_events
  events.on_stops_updated_event = remote.call("logistic-train-network", "on_stops_updated")
  events.on_dispatcher_updated_event = remote.call("logistic-train-network", "on_dispatcher_updated")
  events.on_delivery_completed_event = remote.call("logistic-train-network", "on_delivery_completed")
  events.on_delivery_failed_event = remote.call("logistic-train-network", "on_delivery_failed")
  events.on_pickup_completed = remote.call("logistic-train-network", "on_delivery_pickup_complete")

  -- register for conditional events
  if global.proc.state == 0 then
    script.on_event(events.on_stops_updated_event, on_stops_updated)
    script.on_event(events.on_dispatcher_updated_event, on_dispatcher_updated)
  else
    script.on_event(defines.events.on_tick, data_processor)
  end
  script.on_event(events.on_delivery_completed_event, on_delivery_completed)
  script.on_event(events.on_delivery_failed_event, on_delivery_failed)
  script.on_event(events.on_pickup_completed, on_pickup_completed)
  if debug_log then
    log2("data processor status after on_load:", global.proc)
  end
end

local function on_init()
  global.raw = global.raw or {}
  global.proc = global.proc or {state = 0, underload_is_alert = settings.global["ltnt-disable-underload-alert"].value}

  global.data = global.data or {} -- storage for processed data, ready to be used by UI
  global.data.stops = global.data.stops or {}
  global.data.depots = global.data.depots or {}
  global.data.trains_error = global.data.trains_error or {}
  global.data.train_error_count = 1
  global.data.provided = global.data.provided or {}
  global.data.requested = global.data.requested or {}
  global.data.in_transit = global.data.in_transit or {}
  global.data.deliveries = global.data.deliveries or {}
  global.data.delivery_hist = global.data.delivery_hist or {}
  global.data.newest_history_index = 1
  global.data.name2id = global.data.name2id or {}
  global.data.item2stop = global.data.item2stop or {}
  global.data.item2delivery = global.data.item2delivery or {}
  global.data.history_limit = HISTORY_LIMIT
  global.data.stop_ids = global.data.stop_ids or {}
  on_load()
end

local function on_settings_changed(event)
  if event.setting == "ltnt-history-limit" then
    HISTORY_LIMIT = settings.global["ltnt-history-limit"].value
    global.data.history_limit = HISTORY_LIMIT
    global.data.newest_history_index = 1
    global.data.delivery_hist = {}
  end
  if event.setting == "ltnt-disable-underload-alert" then
    global.proc.underload_is_alert = not settings.global["ltnt-disable-underload-alert"].value
  end
end

return {
  on_init = on_init,
  on_load = on_load,
  on_settings_changed = on_settings_changed,
}
