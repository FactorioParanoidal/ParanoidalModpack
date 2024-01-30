local format = require("format")
local utils = require("utils")
local ltn = require("ltn")
local train_stops = {}

function train_stops.is_cleanup(name)
    return name ~= nil and (string.find(name, "%[virtual%-signal=ltn%-cleanup%-station%]")
                                or string.find(name, "%[img=virtual%-signal/ltn%-cleanup%-station%]"))
end

function train_stops.found_any_stops(stops)
    return next(stops.stops) ~= nil and next(stops.reverse_lookup) ~= nil
end

function train_stops.get_all_cleanup(network, carriages, surface)
    local stops = {}

    local reverse_lookup = {
        generic_item = {},
        items = {},
        fluids = {}
    }

    for _, stop in pairs(game.get_train_stops({surface=surface})) do
        if stop.valid and train_stops.is_cleanup(stop.backer_name) then
            if network == nil or not ltn.is_ltn_stop(stop.unit_number) or
                (bit32.band(ltn.get_network(stop.unit_number), network) ~= 0 and ltn.is_carriage_in_limit(stop.unit_number, carriages)) then

                local processes = {
                    generic_item = false,
                    items = {},
                    fluids = {}
                }

                for word in string.gmatch(stop.backer_name, "%b[]") do
                    if word == "[virtual-signal=ltn-item-cleanup-station]" then
                        processes.generic_item = true
                        table.insert(reverse_lookup.generic_item, stop.unit_number)
                    else
                        local item = string.match(word, "item=(.+)]")
                        if item ~= nil then
                            table.insert(processes.items, item)
                            if reverse_lookup.items[item] == nil then
                                reverse_lookup.items[item] = {}
                            end
                            table.insert(reverse_lookup.items[item], stop.unit_number)
                        else
                            local fluid = string.match(word, "fluid=(.+)]")
                            if fluid ~= nil then
                                table.insert(processes.fluids, fluid)
                                if reverse_lookup.fluids[fluid] == nil then
                                    reverse_lookup.fluids[fluid] = {}
                                end
                                table.insert(reverse_lookup.fluids[fluid], stop.unit_number)
                            end
                        end
                    end
                end

                stops[stop.unit_number] = {
                    name = stop.backer_name,
                    process = processes
                }
            end
        end
    end

    return {
        stops = stops,
        reverse_lookup = reverse_lookup
    }
end

function train_stops.find_depot(name, surface)
    for _, stop in pairs(game.get_train_stops({name=name, surface=surface})) do
        if stop.valid and ltn.is_ltn_stop(stop.unit_number) then
            return stop
        end
    end
end

function train_stops.find_generic_item(stops)
    if #stops.reverse_lookup.generic_item ~= 0 then
        local id = utils.get_first_or_random(stops.reverse_lookup.generic_item)
        return {
            stop = stops.stops[id],
            id = id
        }
    end
end

function train_stops.find_item(stops, item)
    if stops.reverse_lookup.items[item] ~= nil then
        local id = utils.get_first_or_random(stops.reverse_lookup.items[item])
        return {
            stop = stops.stops[id],
            id = id
        }
    end
end

function train_stops.find_fluid(stops, fluid)
    if stops.reverse_lookup.fluids[fluid] ~= nil then
        local id = utils.get_first_or_random(stops.reverse_lookup.fluids[fluid])
        return {
            stop = stops.stops[id],
            id = id
        }
    end
end

return train_stops
