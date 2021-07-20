local config = require("config")

local ltn = {}

function ltn.save_stop_update(logistic_train_stops)
    global.last_ltn_update = logistic_train_stops

    if config.calculate_delta() then
        ltn.calculate_stop_delta()
    end
end

function ltn.calculate_stop_delta()
    local at_limit = {}
    local below_limit = {}

    for id, data in pairs(global.last_ltn_update) do
        if data.is_depot == false and data.input.valid then
            local last_update = global.delta_below_limit[id]
            if last_update == nil then
                last_update = {}
            end

            local at_limit_local = {}
            local below_limit_local = {}

            for _, val in pairs(data.input.get_merged_signals()) do
                if val.signal.type ~= "virtual" and val.count > 0 then
                    if data.providing_threshold_stacks ~= nil and val.signal.type == "item" then
                        if val.count >= data.providing_threshold_stacks * game.item_prototypes[val.signal.name].stack_size then
                            at_limit_local[val.signal.name] = {
                                count = val.count,
                                type = val.signal.type
                            }
                        else
                            local last = last_update[val.signal.name]
                            local delta = 0
                            if last == nil then
                                delta = val.count
                            else
                                delta = val.count - last.count
                            end
                            below_limit_local[val.signal.name] = {
                                count = val.count,
                                delta = delta,
                                type = val.signal.type
                            }
                        end
                    else
                        if val.count >= data.providing_threshold then
                            at_limit_local[val.signal.name] = {
                                count = val.count,
                                type = val.signal.type
                            }
                        else
                            local last = last_update[val.signal.name]
                            local delta = 0
                            if last == nil then
                                delta = val.count
                            else
                                delta = val.count - last.count
                            end
                            below_limit_local[val.signal.name] = {
                                count = val.count,
                                delta = delta,
                                type = val.signal.type
                            }
                        end
                    end
                end
            end
            if next(at_limit_local) ~= nil then
                at_limit[id] = at_limit_local
            end
            if next(below_limit_local) ~= nil then
                below_limit[id] = below_limit_local
            end
        end
    end
    global.delta_at_limit = at_limit
    global.delta_below_limit = below_limit
end

function ltn.get_network(stop_id)
    if ltn.is_ltn_stop(stop_id) then
        return global.last_ltn_update[stop_id].network_id
    end
end

function ltn.get_stop_name(stop_id)
    if ltn.is_ltn_stop(stop_id) then
        local entity = global.last_ltn_update[stop_id].entity
        if entity.valid then
            return entity.backer_name
        end
    end
end

function ltn.is_ltn_stop(stop_id)
    return global.last_ltn_update[stop_id] ~= nil
end

function ltn.get_rail(stop_id)
    if ltn.is_ltn_stop(stop_id) then
        local entity = global.last_ltn_update[stop_id].entity
        if entity.valid then
            return entity.connected_rail
        end
    end
end

function ltn.is_carriage_in_limit(stop_id, carriages)
    if ltn.is_ltn_stop(stop_id) then
        local stop = global.last_ltn_update[stop_id]
        if stop.max_carriages == 0 then
            return carriages >= stop.min_carriages
        else
            return carriages <= stop.max_carriages and carriages >= stop.min_carriages
        end
    end
    return true
end

return ltn
