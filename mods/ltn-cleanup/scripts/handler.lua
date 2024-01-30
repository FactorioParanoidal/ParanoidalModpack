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

    trains.update_schedule(train, records, true)
end

function handler.on_delivery_failed(event)
    if not config.failed_trains() then
        return
    end

    local train = trains.find_train(event.train_id)

    if not handler.is_train_valid(train) then
        return
    end

    if train == nil or not trains.has_trash(train) then
        trains.go_to_depot(train)
        format.info("Sending empty failed train " .. format.train(train) .. " to depot")
    end

    local records = scheduler.build(train)
    if records == nil or #records == 0 then
        return
    end

    if trains.was_at_requester(train) then
        trains.update_schedule(train, records, true)
        format.info("Cleaning failed train " .. format.train(train))
    else
        trains.update_schedule(train, records, false)
        format.info("Adding mandatory cleanup to failed train " .. format.train(train))
    end
end

function handler.on_stops_updated(event)
    ltn.save_stop_update(event.logistic_train_stops)
end

function handler.on_train_changed_state(event)
    if event.old_state == defines.train_state.wait_station then
        scheduler.train_left_stop(event.train)
    end
end

function handler.traceback(err)
    local message = "LTN Cleanup traceback (" .. game.tick .. ")\n\nerror:\n" .. serpent.line(err) .. "\n\nmultiplayer: " .. tostring(game.is_multiplayer()) .. "\nsurface count: " .. table_size(game.surfaces)

    message = message .. "\n\nactive mods:\n"
    for name, version in pairs(game.active_mods) do
        message = message .. "  " .. name .. " v" .. version .. "\n"
    end
    message = message .. "\n" .. debug.traceback(nil, 2)
    -- message = message .. "\n\nltn status:\n" .. serpent.block(global.last_ltn_update)
    game.write_file("ltn-cleanup-debug-" .. game.tick .. ".log", message)

    format.fatal(err, "Debug info written to [font=default-bold]'./script-output/ltn-cleanup-debug.log'[/font].\n\nPlease post contents of this file to the mod portal.\nThank you ☺️\n")
end

function handler.error_handler(callable, event)
    local status = xpcall(callable, handler.traceback, event)
    if not status then
    end
end

function handler.register_callbacks_init()
    if global.last_ltn_update == nil then
        global.last_ltn_update = {}
    end

    handler.register_callbacks()
end

function handler.register_callbacks()
    if remote.interfaces["logistic-train-network"] then
        script.on_event(remote.call("logistic-train-network", "on_requester_remaining_cargo"), function (event) handler.error_handler(handler.on_requester_remaining_cargo, event) end)
        script.on_event(remote.call("logistic-train-network", "on_delivery_failed"), function (event) handler.error_handler(handler.on_delivery_failed, event) end)
        script.on_event(remote.call("logistic-train-network", "on_stops_updated"), function (event) handler.error_handler(handler.on_stops_updated, event) end)
        script.on_event(defines.events.on_train_changed_state, function (event) handler.error_handler(handler.on_train_changed_state, event) end)
    end
end

return handler
