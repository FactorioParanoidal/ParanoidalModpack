local train_stops = require("train_stops")

local trains = {}

function trains.find_train(train_id)
    for _, surface in pairs(game.surfaces) do
        for _, train in pairs(surface.get_trains()) do
            if train.id == train_id then
                return train
            end
        end
    end
end

function trains.get_all_trash(train)
    local trash = {items = {}, fluids = {}}

    for item, ammount in pairs(train.get_contents()) do
        table.insert(trash.items, item)
    end

    for fluid, ammount in pairs(train.get_fluid_contents()) do
        table.insert(trash.fluids, fluid)
    end

    return trash
end

function trains.update_schedule(train, records, change_target)

    local schedule = train.schedule
    local last = #train.schedule.records + 1

    for _, record in pairs(records) do
        table.insert(schedule.records, record)
    end

    if change_target then
        schedule.current = last
    end
    train.schedule = schedule
end

function trains.finished_cleaning(train)
    if train.state ~= defines.train_state.manual_control and
        train.state ~= defines.train_state.manual_control_stop then
        local schedule = train.schedule
        if schedule == nil or #schedule.records == 0 then
            return false
        end

        if schedule.current == 1 then
            local last_record = schedule.records[#schedule.records]
            if train_stops.is_cleanup(last_record.station) then
                return true
            end
        end
    end
    return false
end

function trains.has_trash(train)
    return next(train.get_contents()) ~= nil or next(train.get_fluid_contents()) ~= nil
end

function trains.count_carriages(train)
    return #train.carriages
end

function trains.get_surface(train)
    if #train.carriages ~= 0 then
        return train.carriages[1].surface
    end
end

function trains.go_to_depot(train)
    local schedule = train.schedule
    schedule.current = 1
    train.schedule = schedule
end

function trains.was_at_requester(train)
    return train.schedule.current == 1
end

return trains
