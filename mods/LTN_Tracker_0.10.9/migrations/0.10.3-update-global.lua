local log2 = require("script.logger")
log2("Starting update of LTN-Tracker global table.")

-- check global table for obsolete data
local valid_var_names = {
  gui = {
    is_gui_open = true,
    active_tab = true,
    last_refresh_tick = true,
    refresh_interval = true,
    ltnc_is_active = true,
    is_ltnc_open = true,
  },
 data = {
    stops = true,
    deliveries = true,
    available_trains = true,
    requests_by_stop = true,
    provided_by_stop = true,
    depots = true,
    provided = true,
    requested = true,
    in_transit = true,
    name2id = true,
    item2stop = true,
    item2delivery = true,
    stop_ids = true,
    newest_history_index = true,
    delivery_hist = true,
    trains_error = true,
    train_error_count = true,
  },
 raw = {
    stops = true,
    deliveries = true,
    available_trains = true,
    requests_by_stop = true,
    provided_by_stop = true,
    depots = true,
    provided = true,
    requested = true,
    in_transit = true,
    name2id = true,
    item2stop = true,
    item2delivery = true,
    stop_ids = true,
  },
 proc = {
   state = true,
   next_stop_id = true,
   next_depot_name = true,
   next_delivery_id = true,
 },
}

for var_name, value in pairs(global) do
  if valid_var_names[var_name] then
    local valid_inner_var_names = valid_var_names[var_name]
    for inner_var_name, inner_value in pairs(value) do
      if not valid_inner_var_names[inner_var_name] and type(inner_value) =="table" and not inner_value.root then
        log2("Deleting obsolete data:", var_name.."."..inner_var_name, inner_value)
        global[var_name][inner_var_name] = nil
      end
    end
  else
    log2("Deleting obsolete data:", var_name, value)
    global[var_name] = nil
  end
end

--[[
migrate old train error data to new format:
  - route has been removed
  - delivery has been added
  - delivery to/from/depot has to be built from former route entries
--]]
local count = 1
local migrated_data = {}
for train_id, error_data in pairs(global.data.trains_error) do
  local delivery, cargo = {}, {}
  if error_data.route then
    -- pre 0.10.0 data
    delivery = {
      depot = error_data.route[1] or "unknown",
      from = error_data.route[2] or "unknown",
      to = error_data.route[3] or "unknown",
      from_id = global.data.name2id[error_data.route[2]] or 0,
      to_id = global.data.name2id[error_data.route[3]] or 0,
      shipment = {}
    }
    local cargo = {}
    if error_data.type == "residuals" then
      cargo = error_data.cargo
    end
  elseif error_data.delivery then
    -- 0.10.0 data, potentially invalid when created with 0.10.0
    delivery = {
      to = error_data.delivery.to or "unknown",
      from = error_data.delivery.from or "unknown",
      depot = error_data.delivery.depot or "unknown",
      from_id = error_data.delivery.from_id or 0,
      to_id = error_data.delivery.to_id or 0,
      shipment = error_data.delivery.shipment or {},
    }
  end
  if error_data.route or  error_data.delivery then
    migrated_data[count] = {
      type = error_data.type,
      loco = error_data.loco,
      delivery = delivery,
      cargo = cargo,
    }
    count = count + 1
  else
    log2("Invalid train error data deleted:", error_data)
  end
end
log2("Migrated train error data to version 0.10.3.\nOld data:",  global.data.trains_error, "\nNew data:", migrated_data)
global.data.train_error_count = count
global.data.trains_error = migrated_data


-- new entry added to global.gui in 0.10.3
-- create and populate with default value
log2("Adding new global variables.")
global.gui.station_select_mode = global.gui.station_select_mode or {}
for pind, p in pairs(game.players) do
  global.gui.station_select_mode[pind] = 2
end

log2("Global table check finished.")