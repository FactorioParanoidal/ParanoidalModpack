local format = require("format")
local scheduler = require("scheduler")
local trains = require("trains")
local ltn = require("ltn")
local config = require("config")

local handler = {}

function handler.is_train_valid(train)
    if train == nil or not train.valid then
        return false
    end

    if train.state == defines.train_state.manual_control or train.state == defines.train_state.manual_control_stop then
        format.warning("Ignoring manually controlled train " .. format.train(train))
        return false
    end

    if train.schedule == nil then
        format.warning("Train " .. format.train(train) .. " has empty schedule. Skipping...")
        return false
    end
    return true
end

function handler.on_requester_remaining_cargo(event)
    local train = event.train

    if not handler.is_train_valid(train) then
        return
    end

    if train.schedule ~= nil and train.schedule.current ~= 1 then
        format.warning("Ignoring train " .. format.train(train) .. " after unexpected schedule alteration")
        return false
    end

    if not trains.has_trash(train) then
        format.info("LTN marked empty train " .. format.train(train) .. " with remaining cargo. Skipping...")
        return
    end

    local records = scheduler.build(train, event.station.unit_number)
    if records == nil or #records == 0 then
        return
    end

    format.info("Cleaning train " .. format.train(train))

    trains.update_schedule(train, records)
end

function handler.on_delivery_failed(event)
    if not config.failed_trains() then
        return
    end

    local train = trains.find_train(event.train_id)

    if train == nil or not trains.has_trash(train) then
        return
    end

    if not handler.is_train_valid(train) then
        return
    end

    local records = scheduler.build(train)
    if records == nil or #records == 0 then
        return
    end

    format.info("Cleaning failed train " .. format.train(train))

    trains.update_schedule(train, records)
end

function handler.on_stops_updated(event)
    ltn.save_stop_update(event.logistic_train_stops)
end

function handler.on_train_changed_state(event)
    if event.old_state == defines.train_state.wait_station then
        scheduler.train_left_stop(event.train)
    end
end

function handler.register_callbacks()
    if remote.interfaces["logistic-train-network"] then
        script.on_event(remote.call("logistic-train-network", "on_requester_remaining_cargo"),
            handler.on_requester_remaining_cargo)
        script.on_event(remote.call("logistic-train-network", "on_delivery_failed"), handler.on_delivery_failed)
        script.on_event(remote.call("logistic-train-network", "on_stops_updated"), handler.on_stops_updated)
        script.on_event(defines.events.on_train_changed_state, handler.on_train_changed_state)
    end
end

return handler
