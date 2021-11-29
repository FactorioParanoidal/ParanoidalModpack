local config = require("config")
local utils = require("utils")
local trains = require("trains")
local format = require("format")
local train_stops = require("train_stops")
local ltn = require("ltn")

local scheduler = {}

function scheduler.build_record(stop, wait)
    local record = {
        station = stop.name,
        wait_conditions = {}
    }

    for _, item in pairs(wait.items) do
        table.insert(record.wait_conditions, {
            type = "item_count",
            condition = {
                first_signal = {
                    type = "item",
                    name = item
                },
                comparator = "=",
                constant = 0
            },
            compare_type = "and"
        })
    end

    for _, fluid in pairs(wait.fluids) do
        table.insert(record.wait_conditions, {
            type = "fluid_count",
            condition = {
                first_signal = {
                    type = "fluid",
                    name = fluid
                },
                comparator = "=",
                constant = 0
            },
            compare_type = "and"
        })
    end

    local timeout = config.stop_timeout()
    if timeout ~= nil and timeout ~= 0 then
        table.insert(record.wait_conditions, {
            type = "time",
            compare_type = "or",
            ticks = timeout
        })
    end
    return record
end

function scheduler.build_temp_record(stop_id)
    local rail = ltn.get_rail(stop_id)
    if rail ~= nil then
        return {
            rail = rail,
            wait_conditions = {{
                type = "time",
                compare_type = "or",
                ticks = 0
            }},
            temporary = true
        }
    end
end

function scheduler.process_any(processes, values)
    local index = utils.build_reverse_index(values)
    local wait = {}

    for _, val in pairs(processes) do
        local ind = index[val]
        if ind ~= nil then
            table.insert(wait, val)
            table.remove(values, ind)
            index = utils.build_reverse_index(values)
        end
    end

    return {
        wait = wait,
        values = values
    }
end

function scheduler.process_stop(trash, stop)
    if stop == nil then
        return
    end

    local wait = {
        items = {},
        fluids = {}
    }

    local items_resp = scheduler.process_any(stop.process.items, trash.items)
    trash.items = items_resp.values
    wait.items = items_resp.wait

    local fluids_resp = scheduler.process_any(stop.process.fluids, trash.fluids)
    trash.fluids = fluids_resp.values
    wait.fluids = fluids_resp.wait

    return {
        wait = wait,
        trash = trash
    }
end

function scheduler.build(train, request_stop_id)
    local trash = trains.get_all_trash(train)

    local surface = trains.get_surface(train)
    if surface == nil then
        format.warning("Failed to determine train's surface")
        return
    end

    if request_stop_id == nil then
        local depot_record = train.schedule.records[1]
        local depot_name = depot_record.station
        if depot_name ~= nil then
            local depot_stop = train_stops.find_depot(depot_name, surface)
            if depot_stop ~= nil then
                request_stop_id = depot_stop.unit_number
            end
        end
    end

    local stops = train_stops.get_all_cleanup(ltn.get_network(request_stop_id), trains.count_carriages(train), surface)

    if not train_stops.found_any_stops(stops) then
        format.warning("No cleanup stops found")
        format.train_depot_alert(train)
        return
    end

    local schedule = {}
    local needs_generic = {}

    while #trash.items > 0 do
        local item_stop = train_stops.find_item(stops, trash.items[1])
        if item_stop == nil then
            table.insert(needs_generic, trash.items[1])
            table.remove(trash.items, 1)
        else
            local item_resp = scheduler.process_stop(trash, item_stop.stop)
            trash = item_resp.trash
            local temp = scheduler.build_temp_record(item_stop.id)
            if temp ~= nil then
                table.insert(schedule, temp)
            end
            table.insert(schedule, scheduler.build_record(item_stop.stop, item_resp.wait))
        end
    end

    while #trash.fluids > 0 do
        local fluid_stop = train_stops.find_fluid(stops, trash.fluids[1])
        if fluid_stop == nil then
            format.warning("No cleanup stops to process " .. format.fluid(trash.fluids[1]) .. " found")
            format.train_depot_alert(train)
            return
        else
            local fluid_resp = scheduler.process_stop(trash, fluid_stop.stop)
            trash = fluid_resp.trash
            local temp = scheduler.build_temp_record(fluid_stop.id)
            if temp ~= nil then
                table.insert(schedule, temp)
            end
            table.insert(schedule, scheduler.build_record(fluid_stop.stop, fluid_resp.wait))
        end
    end

    if #needs_generic > 0 then
        local generic_stop = train_stops.find_generic_item(stops)

        if generic_stop == nil then
            local items = ""
            for _, item in pairs(needs_generic) do
                items = items .. " " .. format.item(item)
            end
            format.warning("No generic cleanup stops found to process " .. items)
            format.train_depot_alert(train)
            return
        end
        local temp = scheduler.build_temp_record(generic_stop.id)
        if temp ~= nil then
            table.insert(schedule, temp)
        end
        table.insert(schedule, scheduler.build_record(generic_stop.stop, {
            items = needs_generic,
            fluids = {}
        }))
    end

    return schedule
end

function scheduler.train_left_stop(train)
    if trains.finished_cleaning(train) and trains.has_trash(train) then
        format.train_depot_alert(train)
    end
end

return scheduler
