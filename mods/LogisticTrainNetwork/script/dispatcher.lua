--[[ Copyright (c) 2017 Optera
 * Part of Logistics Train Network
 *
 * See LICENSE.md in the project directory for license information.
--]]

local tools = require('script.tools')
local schedule = require('script.schedule')
local SurfaceInterface = require('script.surface-interface')

-- amount of time a "knownTrain" record is retained even though the
-- train has gone away. This allows reassigning information e.g. when
-- traveling through a space elevator even though the train was destroyed
local DEAD_TRAIN_LINGER_TIME = 240

-- update dispatcher Deliveries.force when forces are removed/merged
script.on_event(defines.events.on_forces_merging, function(event)
    local dispatcher = tools.getDispatcher()

    for _, delivery in pairs(dispatcher.Deliveries) do
        if delivery.force == event.source then
            delivery.force = event.destination
        end
    end
end)

---@param id integer
function DispatcherOnObjectDestroyed(id)
    local dispatcher = tools.getDispatcher()

    -- the destroyed object may have been a surface connection object.
    -- This is expensive but the objects should not be deleted that often
    -- if you build a mod that creates and deletes surface connections, please
    -- remove them before destroying the objects
    for _, delivery in pairs(dispatcher.Deliveries) do
        for idx, surface_connection in pairs(delivery.surface_connections) do
            if not ((surface_connection.entity1 and surface_connection.entity1.valid) and
                (surface_connection.entity2 and surface_connection.entity2.valid)) then
                    delivery.surface_connections[idx] = nil
            end
        end
    end
end

---------------------------------- MAIN LOOP STAGES ----------------------------------

---@param event EventData.on_tick
---@return ltn.TickState?
local function DispatcherReset(event)
    local dispatcher = tools.getDispatcher()

    -- update stops
    storage.tick_stop_index = nil

    -- update deliveries
    storage.tick_request_index = nil

    storage.tick_interval_start = event.tick

    -- clear Dispatcher.Storage
    dispatcher.Provided = {}
    dispatcher.Requests = {}
    dispatcher.Provided_by_Stop = {}
    dispatcher.Requests_by_Stop = {}
    dispatcher.new_Deliveries = {}

    return nil
end

----------------------------------------------------------------------------------------

---@param event EventData.on_tick
---@return ltn.TickState?
local function DispatcherUpdateStops(event)
    ---@type integer?
    local stopID = storage.tick_stop_index

    if stopID and not storage.LogisticTrainStops[stopID] then
        tools.printmsg(2, function()
            return { 'ltn-message.error-invalid-stop-index', storage.tick_stop_index }
        end)

        tools.log(6, 'OnTick', 'Invalid storage.tick_stop_index %d in storage.LogisticTrainStops. Removing stop and starting over.', function()
            return storage.tick_stop_index
        end)

        RemoveStop(stopID)
        return ltn_tick_state.reset
    end

    local stop_count = LtnSettings:getUpdatesPerTick()

    if stop_count > 0 then
        ---@type ltn.TrainStop
        local stop
        repeat
            stopID, stop = next(storage.LogisticTrainStops, storage.tick_stop_index)
            if stopID then
                tools.log(6, 'OnTick', '%d updating stopID %d', function()
                    return event.tick, stopID
                end)
                UpdateStop(stopID, stop)
            end
            stop_count = stop_count - 1
        until stop_count == 0 or not stopID

        storage.tick_stop_index = stopID
    end

    -- if there are more stops, stay in the current state, otherwise switch to next state
    return stopID and ltn_tick_state.update_stops or nil
end

----------------------------------------------------------------------------------------

---@param event EventData.on_tick
---@return ltn.TickState?
local function DispatcherUpdateDeliveries(event)
    local dispatcher = tools.getDispatcher()

    -- clean up deliveries in case train was destroyed or removed
    local activeDeliveryTrains = ''

    for trainID, delivery in pairs(dispatcher.Deliveries) do
        if not (delivery.train and delivery.train.valid) then
            local from_entity = storage.LogisticTrainStops[delivery.from_id] and storage.LogisticTrainStops[delivery.from_id].entity
            local to_entity = storage.LogisticTrainStops[delivery.to_id] and storage.LogisticTrainStops[delivery.to_id].entity

            tools.printmsg(1, function()
                return { 'ltn-message.delivery-removed-train-invalid', tools.richTextForStop(from_entity) or delivery.from, tools.richTextForStop(to_entity) or delivery.to }
            end, delivery.force)

            tools.log(6, 'OnTick', 'Delivery from %s to %s removed. Train no longer valid.', function()
                return delivery.from, delivery.to
            end)

            ---@type ltn.EventData.on_delivery_failed
            local data = {
                train_id = trainID,
                shipment = delivery.shipment
            }
            script.raise_event(on_delivery_failed_event, data)

            RemoveDelivery(trainID)
        elseif event.tick - delivery.started > LtnSettings.delivery_timeout then
            local from_entity = storage.LogisticTrainStops[delivery.from_id] and storage.LogisticTrainStops[delivery.from_id].entity
            local to_entity = storage.LogisticTrainStops[delivery.to_id] and storage.LogisticTrainStops[delivery.to_id].entity

            tools.printmsg(1, function()
                return { 'ltn-message.delivery-removed-timeout', tools.richTextForStop(from_entity) or delivery.from, tools.richTextForStop(to_entity) or delivery.to, event.tick - delivery.started }
            end, delivery.force)

            tools.log(6, 'OnTick', 'Delivery from %s to %s removed. Timed out after %d/%d ticks.', function()
                return delivery.from, delivery.to, event.tick - delivery.started, LtnSettings.delivery_timeout
            end)

            ---@type ltn.EventData.on_delivery_failed
            local data = {
                train_id = trainID,
                shipment = delivery.shipment
            }
            script.raise_event(on_delivery_failed_event, data)

            RemoveDelivery(trainID)
        else
            activeDeliveryTrains = activeDeliveryTrains .. ' ' .. trainID
        end
    end

    tools.log(6, 'OnTick', 'Trains on deliveries: %s', function()
        return activeDeliveryTrains
    end)

    -- remove no longer active requests from dispatcher RequestAge[stopID]
    local newRequestAge = {}
    for _, request in pairs(dispatcher.Requests) do
        local ageIndex = request.item .. ',' .. request.stopID
        local age = dispatcher.RequestAge[ageIndex]
        if age then
            newRequestAge[ageIndex] = age
        end
    end
    dispatcher.RequestAge = newRequestAge

    -- sort requests by priority and age
    table.sort(dispatcher.Requests, function(a, b)
        if a.priority ~= b.priority then
            return a.priority > b.priority
        else
            return a.age < b.age
        end
    end)

    return nil
end

----------------------------------------------------------------------------------------

---@param event EventData.on_tick
---@return ltn.TickState?
local function DispatcherDispatchTrains(event)
    local dispatcher = tools.getDispatcher()

    ---@type integer?
    local request_index = storage.tick_request_index

    if LtnSettings.dispatcher_enabled then
        tools.log(6, 'OnTick', 'Available train capacity: %d item stacks, %d fluid capacity.', function()
            return dispatcher.availableTrains_total_capacity, dispatcher.availableTrains_total_fluid_capacity
        end)

        -- reset on invalid index
        if request_index and not dispatcher.Requests[request_index] then
            tools.printmsg(1, function()
                return { 'ltn-message.error-invalid-request-index', storage.tick_request_index }
            end)

            tools.log(6, 'OnTick', 'Invalid storage.tick_request_index %s in dispatcher Requests. Starting over.', function()
                return tostring(storage.tick_request_index)
            end)

            return ltn_tick_state.reset
        end

        local request_count = LtnSettings:getUpdatesPerTick()

        if request_count > 0 then
            ---@type ltn.Request
            local request
            repeat
                request_index, request = next(dispatcher.Requests, request_index)
                if request_index and request then
                    tools.log(6, 'OnTick', '%d parsing request %d/%d', function()
                        return event.tick, request_index, #dispatcher.Requests
                    end)
                    ProcessRequest(request_index, request)
                end
                request_count = request_count - 1
            until request_count == 0 or not request_index

            storage.tick_request_index = request_index
        end
    else
        tools.printmsg(1, function()
            return { 'ltn-message.warning-dispatcher-disabled' }
        end)

        tools.log(6, 'OnTick', 'Dispatcher disabled.')

        storage.tick_request_index = nil
    end

    -- if there are more requests, stay in the current state, otherwise switch to next state
    return request_index and ltn_tick_state.dispatch_trains or nil
end

----------------------------------------------------------------------------------------

--- raise events for mod API
---@param event EventData.on_tick
---@return ltn.TickState?
local function DispatcherApiEvents(event)
    local dispatcher = tools.getDispatcher()

    ---@type ltn.EventData.on_stops_updated
    local stops_data = {
        logistic_train_stops = storage.LogisticTrainStops,
    }
    script.raise_event(on_stops_updated_event, stops_data)

    ---@type ltn.EventData.on_dispatcher_updated
    local dispatcher_data = {
        update_interval = event.tick - storage.tick_interval_start,
        provided_by_stop = dispatcher.Provided_by_Stop,
        requests_by_stop = dispatcher.Requests_by_Stop,
        new_deliveries = dispatcher.new_Deliveries,
        deliveries = dispatcher.Deliveries,
        available_trains = dispatcher.availableTrains,
    }
    script.raise_event(on_dispatcher_updated_event, dispatcher_data)

    return nil
end

----------------------------------------------------------------------------------------

---@return ltn.TickState?
local function DispatcherCleanup()
    local dispatcher = tools.getDispatcher()

    for index, knownTrain in pairs(dispatcher.knownTrains) do
        if knownTrain.invalid_tick then
            if knownTrain.invalid_tick < game.tick then
                dispatcher.knownTrains[index] = nil
            end
        elseif not (knownTrain.train and knownTrain.train.valid) then
            knownTrain.invalid_tick = game.tick + DEAD_TRAIN_LINGER_TIME
        end
    end

    return nil
end

---------------------------------- MAIN LOOP ----------------------------------

--- @type table<ltn.TickState, fun(event: EventData.on_tick): ltn.TickState?>
local dispatcher_stages = {
    [ltn_tick_state.reset] = DispatcherReset,
    [ltn_tick_state.update_stops] = DispatcherUpdateStops,
    [ltn_tick_state.update_deliveries] = DispatcherUpdateDeliveries,
    [ltn_tick_state.dispatch_trains] = DispatcherDispatchTrains,
    [ltn_tick_state.api_events] = DispatcherApiEvents,
    [ltn_tick_state.cleanup] = DispatcherCleanup,
}

---@param event EventData.on_tick
function OnTick(event)
    tools.log(9, 'OnTick', 'Tick: %d, storage.tick_state: %s, storage.tick_stop_index: %s, storage.tick_request_index: %s', function()
        return event.tick, tostring(storage.tick_state), tostring(storage.tick_stop_index), tostring(storage.tick_request_index)
    end)

    local current_tick_state = storage.tick_state or ltn_tick_state.reset

    storage.tick_state = assert(dispatcher_stages[current_tick_state])(event) or storage.tick_state + 1
    if dispatcher_stages[storage.tick_state] then return end

    -- no next stage, go back to reset
    storage.tick_state = ltn_tick_state.reset
end

---------------------------------- DISPATCHER FUNCTIONS ----------------------------------

-- ensures removal of trainID from dispatcher Deliveries and stop.active_deliveries

---@param trainID number
function RemoveDelivery(trainID)
    local dispatcher = tools.getDispatcher()

    for stopID, stop in pairs(storage.LogisticTrainStops) do
        if not tools.isStopConsistent(stop) then
            RemoveStop(stopID)
        else
            for i = #stop.active_deliveries, 1, -1 do --trainID should be unique => checking matching stop name not required
                if stop.active_deliveries[i] == trainID then
                    table.remove(stop.active_deliveries, i)
                    if #stop.active_deliveries > 0 then
                        setLamp(stop, 'yellow', #stop.active_deliveries)
                    else
                        setLamp(stop, 'green', 1)
                    end
                end
            end
        end
    end
    dispatcher.Deliveries[trainID] = nil
end

---- ProcessRequest ----

-- return a list ordered priority > #active_deliveries > item-count of {entity, network_id, priority, activeDeliveryCount, item, count, providing_threshold, providing_threshold_stacks, min_carriages, max_carriages, locked_slots, surface_connections}
---@param requestStation ltn.TrainStop
---@param item ltn.ItemIdentifier
---@param req_count number
---@param min_length number
---@param max_length number
---@return ltn.Provider[]?
local function getProviders(requestStation, item, req_count, min_length, max_length)
    local dispatcher = tools.getDispatcher()

    ---@type ltn.Provider[]?
    local stations = {}
    local providers = dispatcher.Provided[item] --[[@as table<number, number>? ]]
    if not providers then return nil end

    local force = requestStation.entity.force
    local surface = requestStation.entity.surface

    for stopID, count in pairs(providers) do
        local stop = storage.LogisticTrainStops[stopID]
        if tools.isStopValid(stop) then
            local matched_networks = bit32.band(requestStation.network_id, stop.network_id)

            tools.log(7, 'getProviders', 'comparing 0x%x & 0x%x = 0x%x', function()
                return bit32.band(requestStation.network_id), bit32.band(stop.network_id), bit32.band(matched_networks)
            end)

            if stop.entity.force == force
                and matched_networks ~= 0
                -- and count >= stop.providing_threshold
                and (stop.min_carriages == 0 or max_length == 0 or stop.min_carriages <= max_length)
                and (stop.max_carriages == 0 or min_length == 0 or stop.max_carriages >= min_length) then
                --check if provider can accept more trains
                local activeDeliveryCount = #stop.active_deliveries
                if activeDeliveryCount and (stop.max_trains == 0 or activeDeliveryCount < stop.max_trains) then
                    -- check if surface transition is possible
                    local surface_connections = SurfaceInterface.FindSurfaceConnections(surface, stop.entity.surface, force, matched_networks)
                    if surface_connections then -- for same surfaces surface_connections = {}
                        local from_network_id_string = string.format('0x%x', bit32.band(stop.network_id))
                        tools.log(5, 'GetProviders', 'found %d(%d)/%d %s at %s {%s}, priority: %s, active Deliveries: %d, min_carriages: %d, max_carriages: %d, locked Slots: %d, #surface_connections: %d', function()
                            return count, stop.providing_threshold, req_count, item, stop.entity.backer_name, from_network_id_string, stop.provider_priority, activeDeliveryCount, stop.min_carriages, stop.max_carriages, stop.locked_slots, #surface_connections
                        end)

                        table.insert(stations, {
                            stop = stop,
                            network_id = matched_networks,
                            priority = stop.provider_priority,
                            activeDeliveryCount = activeDeliveryCount,
                            item = item,
                            count = count,
                            providing_threshold = stop.providing_threshold,
                            providing_threshold_stacks = stop.providing_threshold_stacks,
                            min_carriages = stop.min_carriages,
                            max_carriages = stop.max_carriages,
                            locked_slots = stop.locked_slots,
                            surface_connections = surface_connections,
                            surface_connections_count = #surface_connections,
                        })
                    end
                end
            end
        end
    end

    -- sort best matching station to the top
    table.sort(stations, function(a, b)
        if a.priority ~= b.priority then                                       --sort by priority, will result in train queues if trainlimit is not set
            return a.priority > b.priority
        elseif a.surface_connections_count ~= b.surface_connections_count then --sort providers without surface transition to top
            return math.min(a.surface_connections_count, 1) < math.min(b.surface_connections_count, 1)
        elseif a.activeDeliveryCount ~= b.activeDeliveryCount then             --sort by #deliveries
            return a.activeDeliveryCount < b.activeDeliveryCount
        else
            return a.count > b.count --finally sort by item count
        end
    end)

    tools.log(5, 'GetProviders', 'sorted providers: %s', function()
        return serpent.block(stations)
    end)

    return stations
end

local DISTANCE_CACHE_LIFETIME = 60 * 60 * 2 -- 2 minutes

---@param train LuaTrain
---@param next_station ltn.TrainStop
---@return number?
local function get_station_distance(train, next_station)
    if not (train.valid and tools.isStopValid(train.station) and tools.isStopValid(next_station)) then
        return nil
    end

    local current_station = assert(train.station)

    if current_station.surface_index ~= next_station.entity.surface_index then return nil end

    local needs_front_path = (#train.locomotives.front_movers > 0)
    local needs_back_path = (#train.locomotives.back_movers > 0)

    if not (needs_front_path or needs_back_path) then return nil end

    local stationPair = current_station.unit_number .. ',' .. next_station.entity.unit_number
    ---@type ltn.StopDistance?
    local stop_distance = storage.StopDistances[stationPair]

    if type(stop_distance) ~= 'table' then stop_distance = nil end

    if stop_distance and stop_distance.tick > game.tick then
        return stop_distance.distance
    end

    local front_result = needs_front_path and game.train_manager.request_train_path {
        type = 'path',
        starts = {
            {
                rail = current_station.connected_rail,
                direction = current_station.connected_rail_direction,
            }
        },
        goals = { next_station.entity, },
    } or nil

    local back_result = needs_back_path and game.train_manager.request_train_path {
        type = 'path',
        starts = {
            {
                rail = current_station.connected_rail,
                -- opposite direction for back path
                direction = (current_station.connected_rail_direction == defines.rail_direction.front) and defines.rail_direction.back or defines.rail_direction.front,
            }
        },
        goals = { next_station.entity, },
    } or nil

    local distance = nil
    if front_result and front_result.found_path then
        distance = (front_result.total_length or 0) + (front_result.penalty or 0)
    end

    if back_result and back_result.found_path then
        local back_distance = (back_result.total_length or 0) + (back_result.penalty or 0)
        if (not distance) or back_distance < distance then distance = back_distance end
    end

    if not distance then return nil end

    storage.StopDistances[stationPair] = {
        distance = distance,
        tick = game.tick + DISTANCE_CACHE_LIFETIME,
    }

    return distance
end

--- returns: available trains in depots or nil
---          filtered by NetworkID, carriages and surface
---          sorted by priority, capacity - locked slots and distance to provider
---@param nextStop ltn.Provider
---@param min_carriages number
---@param max_carriages number
---@param type ltn.ItemFluid
---@param size number
---@return ltn.FreeTrain[]?
local function getFreeTrains(nextStop, min_carriages, max_carriages, type, size)
    local dispatcher = tools.getDispatcher()

    ---@type ltn.FreeTrain[]
    local filtered_trains = {}

    for trainID, trainData in pairs(dispatcher.availableTrains) do
        if trainData.train.valid and trainData.train.station and trainData.train.station.valid then
            local inventorySize
            if type == 'item' then
                -- subtract locked slots from every cargo wagon
                inventorySize = trainData.capacity - (nextStop.locked_slots * #trainData.train.cargo_wagons)
            else
                inventorySize = trainData.fluid_capacity
            end

            tools.log(5, 'getFreeTrains', 'checking train %s, force %s/%s, network %s/%s, priority: %d, length: %d<=%d<=%d, inventory size: %d/%d, distance: %s', function()
                local depot_network_id_string = string.format('0x%x', bit32.band(trainData.network_id))
                local dest_network_id_string = string.format('0x%x', bit32.band(nextStop.network_id))

                return tools.getTrainName(trainData.train), trainData.force.name, nextStop.stop.entity.force.name, depot_network_id_string, dest_network_id_string, trainData.depot_priority, min_carriages, #trainData.train.carriages, max_carriages, inventorySize, size,
                    get_station_distance(trainData.train, nextStop.stop) or '<no path found>'
            end)

            -- preselection based on train properties
            if inventorySize > 0                                                                                                                                -- sending trains without inventory on deliveries would be pointless
                and trainData.force == nextStop.stop.entity.force                                                                                               -- forces match
                and bit32.btest(trainData.network_id, nextStop.network_id)                                                                                      -- depot is in the same network as requester and provider
                and (min_carriages == 0 or #trainData.train.carriages >= min_carriages) and (max_carriages == 0 or #trainData.train.carriages <= max_carriages) -- train length fits requester and provider limitations
            then
                -- train is on the same surface as the next stop
                if trainData.surface == nextStop.stop.entity.surface then
                    local distance = get_station_distance(trainData.train, nextStop.stop)
                    -- if distance is nil but the surface is the same, there is no path for the train.
                    if distance then
                        ---@type ltn.FreeTrain
                        local free_train = {
                            train = trainData.train,
                            surface = trainData.surface,
                            inventory_size = inventorySize,
                            depot_priority = trainData.depot_priority,
                            provider_distance = distance,
                            select_count = trainData.select_count or 0,
                        }
                        table.insert(filtered_trains, free_train)
                    end
                elseif LtnSettings.advanced_cross_surface_delivery then
                    local matched_networks = bit32.band(trainData.network_id, nextStop.network_id)
                    -- check if surface transition is possible
                    local surface_connections = SurfaceInterface.FindSurfaceConnections(trainData.train.station.surface, nextStop.stop.entity.surface, trainData.force, matched_networks)

                    -- train can switch to the other surface to reach the provider
                    if surface_connections then
                        ---@type ltn.FreeTrain
                        local free_train = {
                            train = trainData.train,
                            surface = trainData.surface,
                            inventory_size = inventorySize,
                            depot_priority = trainData.depot_priority,
                            surface_connections = surface_connections,
                            select_count = trainData.select_count or 0,
                        }
                        -- switching surface
                        table.insert(filtered_trains, free_train)
                    end
                end
            end
        else
            -- remove invalid train from dispatcher availableTrains
            tools.reduceAvailableCapacity(trainID)
        end
    end

    -- return nil instead of empty table
    if next(filtered_trains) == nil then return nil end

    local stop_surface_index = nextStop.stop.entity.surface.index
    local fudge_factor = LtnSettings.depot_fudge_factor or 0

    -- sort best matching train to top
    table.sort(filtered_trains, function(a, b)
        -- if A is on the same surface as the stop and B is not, return true
        if a.surface.index == stop_surface_index and b.surface.index ~= stop_surface_index then
            return true
            -- if B is on the same surface as the stop and A is not, return false
        elseif b.surface.index == stop_surface_index and a.surface.index ~= stop_surface_index then
            return false
            -- else do normal checks (either both stops are on the same or on a different surface)
        elseif a.depot_priority ~= b.depot_priority then
            --sort by priority
            return a.depot_priority > b.depot_priority
        elseif a.inventory_size ~= b.inventory_size and a.inventory_size >= size then
            --sort inventories capable of whole deliveries
            -- return not(b.inventory_size => size and a.inventory_size > b.inventory_size)
            return b.inventory_size < size or a.inventory_size < b.inventory_size
        elseif a.inventory_size ~= b.inventory_size and a.inventory_size < size then
            --sort inventories for partial deliveries
            -- return not(b.inventory_size >= size or b.inventory_size > a.inventory_size)
            return b.inventory_size < size and b.inventory_size < a.inventory_size
        else
            -- if one stop is on the same surface and the other is not, return
            if not a.provider_distance then return false end
            if not b.provider_distance then return true end

            if math.abs(a.provider_distance - b.provider_distance) >= fudge_factor then
                return a.provider_distance < b.provider_distance
            end

            return a.select_count < b.select_count
        end
    end)

    tools.log(5, 'getFreeTrains', 'sorted trains: %s', function()
        return serpent.block(filtered_trains)
    end)

    return filtered_trains
end

-- parse single request from dispatcher Request={stopID, item, age, count}
-- returns created delivery ID or nil
---@param reqIndex number
---@param request ltn.Request
---@return number?
function ProcessRequest(reqIndex, request)
    local dispatcher = tools.getDispatcher()

    -- ensure validity of request stop
    local toID = request.stopID
    local requestStation = storage.LogisticTrainStops[toID]

    if not tools.isStopValid(requestStation) then return nil end

    local surface_name = requestStation.entity.surface.name
    local to = requestStation.entity.backer_name
    local to_gps = tools.richTextForStop(requestStation.entity) or to
    local to_network_id_string = string.format('0x%x', bit32.band(requestStation.network_id))
    local item = request.item
    local count = request.count

    local max_carriages = requestStation.max_carriages
    local min_carriages = requestStation.min_carriages
    local requestForce = requestStation.entity.force

    tools.log(5, 'ProcessRequest', 'request %d/%d: %d(%d) %s to %s {%s} priority: %d min length: %d max length: %d', function()
        return reqIndex, #dispatcher.Requests, count, requestStation.requesting_threshold, item, requestStation.entity.backer_name, to_network_id_string, request.priority, min_carriages, max_carriages
    end)

    if not (dispatcher.Requests_by_Stop[toID] and dispatcher.Requests_by_Stop[toID][item]) then
        tools.log(5, 'ProcessRequest', 'Skipping request %s: %s. Item has already been processed.', function()
            return requestStation.entity.backer_name, item
        end)
        return nil
    end

    if requestStation.max_trains > 0 and #requestStation.active_deliveries >= requestStation.max_trains then
        tools.log(5, 'ProcessRequest', '%s Request station train limit reached: %d(%d)', function()
            return requestStation.entity.backer_name, #requestStation.active_deliveries, requestStation.max_trains
        end)
        return nil
    end

    -- find providers for requested item
    local item_info = tools.parseItemIdentifier(item)
    if not item_info then
        tools.printmsg(1, function()
            return { 'ltn-message.error-parse-item', item }
        end, requestForce)

        tools.log(5, 'ProcessRequest', ' could not parse %s', function()
            return item
        end)

        return nil
    end

    local localname
    if item_info.type == 'fluid' then
        assert(prototypes.fluid[item_info.name], 'fluid prototype undefined!', item_info)
        localname = prototypes.fluid[item_info.name].localised_name
        -- skip if no trains are available
        if (dispatcher.availableTrains_total_fluid_capacity or 0) == 0 then
            create_alert(requestStation.entity, 'depot-empty', { 'ltn-message.empty-depot-fluid' }, requestForce)

            tools.printmsg(1, function()
                return { 'ltn-message.empty-depot-fluid' }
            end, requestForce)

            tools.log(5, 'ProcessRequest', 'Skipping request %s {%s}: %s. No trains available.', function()
                return to, to_network_id_string, item
            end)

            ---@type ltn.EventData.no_train_found_item
            local data = {
                to = to,
                to_id = toID,
                network_id = requestStation.network_id,
                item = item
            }
            script.raise_event(on_dispatcher_no_train_found_event, data)
            return nil
        end
    else
        assert(prototypes.item[item_info.name], 'item prototype undefined!', item_info)
        localname = prototypes.item[item_info.name].localised_name
        -- skip if no trains are available
        if (dispatcher.availableTrains_total_capacity or 0) == 0 then
            create_alert(requestStation.entity, 'depot-empty', { 'ltn-message.empty-depot-item' }, requestForce)

            tools.printmsg(1, function()
                return { 'ltn-message.empty-depot-item' }
            end, requestForce)

            tools.log(5, 'ProcessRequest', 'Skipping request %s {%s}: %s. No trains available.', function()
                return to, to_network_id_string, item
            end)

            ---@type ltn.EventData.no_train_found_item

            local data = {
                to = to,
                to_id = toID,
                network_id = requestStation.network_id,
                item = item
            }

            script.raise_event(on_dispatcher_no_train_found_event, data)

            return nil
        end
    end

    -- get providers ordered by priority
    local providers = getProviders(requestStation, item, count, min_carriages, max_carriages)
    if not providers or #providers < 1 then
        if not requestStation.no_warnings then
            tools.printmsg(1, function()
                return { 'ltn-message.no-provider-found', to_gps, tools.prettyPrint(item_info), to_network_id_string }
            end, requestForce)
        end

        tools.log(5, 'ProcessRequest', 'No supply of %s found for Requester %s: surface: %s min length: %s, max length: %s, network-ID: %s', function()
            return item, to, surface_name, min_carriages, max_carriages, to_network_id_string
        end)

        return nil
    end

    local providerData = providers[1] -- only one delivery/request is created so use only the best provider

    -- getProviders only returns valid stops with connected rails
    local fromID = assert(providerData.stop.entity).unit_number
    assert(fromID)

    local from = providerData.stop.entity.backer_name
    local from_gps = tools.richTextForStop(providerData.stop.entity) or from
    local matched_network_id_string = string.format('0x%x', bit32.band(providerData.network_id))

    tools.printmsg(3, function()
        return { 'ltn-message.provider-found', from_gps, tostring(providerData.priority), tostring(providerData.activeDeliveryCount), providerData.count, tools.prettyPrint(item_info) }
    end, requestForce)

    -- limit deliverySize to count at provider
    local deliverySize = count
    if count > providerData.count then
        deliverySize = providerData.count
    end

    local stacks = deliverySize -- for fluids stack = tanker capacity
    if item_info.type == 'item' then
        assert(prototypes.item[item_info.name], 'item prototype undefined!', item_info)
        stacks = math.ceil(deliverySize / prototypes.item[item_info.name].stack_size) -- calculate amount of stacks item count will occupy
    end

    -- max_carriages = shortest set max-train-length
    if providerData.max_carriages > 0 and (providerData.max_carriages < requestStation.max_carriages or requestStation.max_carriages == 0) then
        max_carriages = providerData.max_carriages
    end
    -- min_carriages = longest set min-train-length
    if providerData.min_carriages > 0 and (providerData.min_carriages > requestStation.min_carriages or requestStation.min_carriages == 0) then
        min_carriages = providerData.min_carriages
    end

    dispatcher.Requests_by_Stop[toID][item] = nil -- remove before merge so it's not added twice

    ---@type ltn.ItemLoadingElement[]
    local loadingList = {
        {
            item = item_info,
            localname = localname,
            count = deliverySize,
            stacks = stacks
        }
    }

    local totalStacks = stacks
    tools.log(5, 'ProcessRequest', 'created new order %s >> %s: %d %s in %d/%d stacks, min length: %d max length: %d', function()
        return from, to, deliverySize, item, stacks, totalStacks, min_carriages, max_carriages
    end)

    -- find possible mergeable items, fluids can't be merged in a sane way
    if item_info.type == 'item' then
        for merge_item, merge_count_req in pairs(dispatcher.Requests_by_Stop[toID]) do
            local merge_item_info = tools.parseItemIdentifier(merge_item)
            if merge_item_info and merge_item_info.type == 'item' then
                assert(prototypes.item[merge_item_info.name], 'item prototype undefined!', merge_item_info)
                local merge_localname = prototypes.item[merge_item_info.name].localised_name
                -- get current provider for requested item
                if dispatcher.Provided[merge_item] and dispatcher.Provided[merge_item][fromID] then
                    -- set delivery Size and stacks
                    local merge_count_prov = dispatcher.Provided[merge_item][fromID]
                    local merge_deliverySize = merge_count_req
                    if merge_count_req > merge_count_prov then
                        merge_deliverySize = merge_count_prov
                    end
                    local merge_stacks = math.ceil(merge_deliverySize / prototypes.item[merge_item_info.name].stack_size) -- calculate amount of stacks item count will occupy

                    -- add to loading list
                    table.insert(loadingList, {
                        item = merge_item_info,
                        localname = merge_localname,
                        count = merge_deliverySize,
                        stacks = merge_stacks
                    } --[[@as ltn.ItemLoadingElement ]])

                    totalStacks = totalStacks + merge_stacks

                    tools.log(5, 'ProcessRequest', 'inserted into order %s >> %s: %d %s in %d/%d stacks.', function()
                        return from, to, merge_deliverySize, merge_item, merge_stacks, totalStacks
                    end)
                end
            end
        end
    end

    local free_trains = getFreeTrains(providerData, min_carriages, max_carriages, item_info.type, totalStacks)
    if not free_trains then
        create_alert(requestStation.entity, 'depot-empty', { 'ltn-message.no-train-found', from, to, matched_network_id_string, tostring(min_carriages), tostring(max_carriages) }, requestForce)

        tools.printmsg(1, function()
            return { 'ltn-message.no-train-found', from_gps, to_gps, matched_network_id_string, tostring(min_carriages), tostring(max_carriages) }
        end, requestForce)

        tools.log(5, 'ProcessRequest', 'No train with %d <= length <= %d to transport %d stacks from %s to %s in network %s found in Depot.', function()
            return min_carriages, max_carriages, totalStacks, from, to, matched_network_id_string
        end)

        ---@type ltn.EventData.no_train_found_shipment
        local data = {
            to = to,
            to_id = toID,
            from = from,
            from_id = fromID,
            network_id = requestStation.network_id,
            min_carriages = min_carriages,
            max_carriages = max_carriages,
            shipment = tools.createLoadingList(loadingList),
        }

        script.raise_event(on_dispatcher_no_train_found_event, data)

        dispatcher.Requests_by_Stop[toID][item] = count -- add removed item back to list of requested items.
        return nil
    end

    local freeTrain = free_trains[1]

    if freeTrain.surface_connections then
        local known_connections = {}
        local result = {}
        for _, surface_connection in pairs(providerData.surface_connections) do
            local entity_key = SurfaceInterface.SortedPair(surface_connection.entity1.unit_number, surface_connection.entity2.unit_number)
            if not known_connections[entity_key] then
                known_connections[entity_key] = surface_connection
                result[#result + 1] = surface_connection
            end
        end

        for _, surface_connection in pairs(free_trains[1].surface_connections) do
            local entity_key = SurfaceInterface.SortedPair(surface_connection.entity1.unit_number, surface_connection.entity2.unit_number)
            if not known_connections[entity_key] then
                known_connections[entity_key] = surface_connection
                result[#result + 1] = surface_connection
            end
        end

        providerData.surface_connections = result
        providerData.surface_connections_count = #result
    end

    local selectedTrain = freeTrain.train
    local trainInventorySize = freeTrain.inventory_size

    tools.printmsg(3, function()
        return { 'ltn-message.train-found', from_gps, to_gps, matched_network_id_string, tostring(trainInventorySize), tostring(totalStacks) }
    end, requestForce)

    tools.log(5, 'ProcessRequest', 'Train to transport %d/%d stacks from %s to %s in network %s found in Depot.', function()
        return trainInventorySize, totalStacks, from, to, matched_network_id_string
    end)

    -- recalculate delivery amount to fit in train
    if trainInventorySize < totalStacks then
        -- recalculate partial shipment
        if item_info.type == 'fluid' then
            -- fluids are simple
            loadingList[1].count = trainInventorySize
        else
            -- items need a bit more math
            for i = #loadingList, 1, -1 do
                if totalStacks - loadingList[i].stacks < trainInventorySize then
                    assert(prototypes.item[loadingList[i].item.name])
                    -- remove stacks until it fits in train
                    loadingList[i].stacks = loadingList[i].stacks - (totalStacks - trainInventorySize)
                    totalStacks = trainInventorySize
                    local newcount = loadingList[i].stacks * prototypes.item[loadingList[i].item.name].stack_size
                    loadingList[i].count = math.min(newcount, loadingList[i].count)
                    break
                else
                    -- remove item and try again
                    totalStacks = totalStacks - loadingList[i].stacks
                    table.remove(loadingList, i)
                end
            end
        end
    end

    -- create delivery
    if #loadingList == 1 then
        tools.printmsg(2, function()
            return { 'ltn-message.creating-delivery', from_gps, to_gps, loadingList[1].count, tools.prettyPrint(loadingList[1].item), tools.richTextForTrain(selectedTrain) }
        end, requestForce)
    else
        tools.printmsg(2, function()
            return { 'ltn-message.creating-delivery-merged', from_gps, to_gps, totalStacks, tools.richTextForTrain(selectedTrain) }
        end, requestForce)
    end

    -- create schedule
    local depot = storage.LogisticTrainStops[selectedTrain.station.unit_number]

    schedule:resetSchedule(selectedTrain, depot)

    -- rail entities have been validated with IsValidStop before
    local from_rail = assert(providerData.stop.entity.connected_rail)
    local from_rail_direction = providerData.stop.entity.connected_rail_direction
    local to_rail = assert(requestStation.entity.connected_rail)
    local to_rail_direction = requestStation.entity.connected_rail_direction
    local current_train_surface = depot.entity.surface

    -- make train go to specific stations by setting a temporary waypoint on the rail the station is connected to
    --
    -- schedules cannot have temporary stops on a different surface, those need to be added when the delivery is updated with a train on a different surface
    if current_train_surface == from_rail.surface then
        schedule:temporaryStop(selectedTrain, from_rail, from_rail_direction)
    else
        tools.log(5, 'ProcessRequest', ' Warning: creating schedule without temporary stop for provider.')
    end

    schedule:providerStop(selectedTrain, providerData.stop, loadingList)

    if (current_train_surface == to_rail.surface) and (to_rail.surface == from_rail.surface) then
        schedule:temporaryStop(selectedTrain, to_rail, to_rail_direction)
    else
        tools.log(5, 'ProcessRequest', ' Warning: creating schedule without temporary stop for requester.')
    end

    schedule:requesterStop(selectedTrain, requestStation, loadingList)

    local shipment = {}
    tools.log(5, 'ProcessRequest', 'Creating Delivery: %d stacks, %s >> %s', function()
        return totalStacks, from, to
    end)
    for i = 1, #loadingList do
        local loadingListItem = tools.createItemIdentifier(loadingList[i].item)
        -- store Delivery
        shipment[loadingListItem] = loadingList[i].count

        -- subtract Delivery from Provided items and check thresholds
        dispatcher.Provided[loadingListItem][fromID] = dispatcher.Provided[loadingListItem][fromID] - loadingList[i].count
        local new_provided = dispatcher.Provided[loadingListItem][fromID]
        local new_provided_stacks = 0
        local useProvideStackThreshold = false
        if loadingList[i].item.type == 'item' then
            if prototypes.item[loadingList[i].item.name] then
                new_provided_stacks = new_provided / prototypes.item[loadingList[i].item.name].stack_size
            end
            useProvideStackThreshold = providerData.providing_threshold_stacks > 0
        end

        if (useProvideStackThreshold and new_provided_stacks >= providerData.providing_threshold_stacks) or
            (not useProvideStackThreshold and new_provided >= providerData.providing_threshold) then
            dispatcher.Provided[loadingListItem][fromID] = new_provided
            dispatcher.Provided_by_Stop[fromID][loadingListItem] = new_provided
        else
            dispatcher.Provided[loadingListItem][fromID] = nil
            dispatcher.Provided_by_Stop[fromID][loadingListItem] = nil
        end

        -- remove Request and reset age
        dispatcher.Requests_by_Stop[toID][loadingListItem] = nil
        dispatcher.RequestAge[loadingListItem .. ',' .. toID] = nil

        tools.log(5, 'ProcessRequest', '  %s, %d in %d stacks', function()
            return loadingListItem, loadingList[i].count, loadingList[i].stacks
        end)
    end

    table.insert(dispatcher.new_Deliveries, selectedTrain.id)
    dispatcher.Deliveries[selectedTrain.id] = {
        force = requestForce,
        train = selectedTrain,
        from = from,
        from_id = fromID,
        to = to,
        to_id = toID,
        network_id = providerData.network_id,
        started = game.tick,
        surface_connections = providerData.surface_connections,
        shipment = shipment,
    }

    tools.reduceAvailableCapacity(selectedTrain.id)

    -- select the current train
    dispatcher.knownTrains[selectedTrain.id].select_count = (dispatcher.knownTrains[selectedTrain.id].select_count or 0) + 1

    -- train is no longer available => set depot to yellow
    setLamp(depot, 'yellow', 1)

    -- update delivery count and lamps on provider and requester
    for _, stopID in pairs { fromID, toID } do
        local stop = storage.LogisticTrainStops[stopID]
        assert(stop)
        if stop.entity.valid and (stop.entity.unit_number == fromID or stop.entity.unit_number == toID) then
            table.insert(stop.active_deliveries, selectedTrain.id)

            local lamp_control = stop.lamp_control.get_or_create_control_behavior() --[[@as LuaConstantCombinatorControlBehavior ]]
            assert(lamp_control)

            if lamp_control.sections_count == 0 then
                assert(lamp_control.add_section())
            end

            local section = lamp_control.sections[1]
            assert(section)
            assert(section.filters_count == 1)

            -- only update blue signal count; change to yellow if it wasn't blue
            local current_signal = section.filters[1]
            if current_signal and current_signal.value.name == 'signal-blue' then
                setLamp(stop, 'blue', #stop.active_deliveries)
            else
                setLamp(stop, 'yellow', #stop.active_deliveries)
            end
        end
    end

    return selectedTrain.id -- deliveries are indexed by train.id
end
