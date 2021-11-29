local config = require("config")

local ltn = {}

function ltn.save_stop_update(logistic_train_stops)
    global.last_ltn_update = logistic_train_stops
end

function ltn.get_network(stop_id)
    if ltn.is_ltn_stop(stop_id) then
        return global.last_ltn_update[stop_id].network_id
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
