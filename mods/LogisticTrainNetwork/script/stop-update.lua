--[[ Copyright (c) 2017 Optera
 * Part of Logistics Train Network
 *
 * See LICENSE.md in the project directory for license information.
--]]

local util = require('util')

local tools = require('script.tools')

local schedule = require('script.schedule')

---@type table<string, fun(signal: Signal, state: ltn.SignalState)>
local ltn_signals = {
    [ISDEPOT] = function(signal, state) if signal.count > 0 then state.is_depot = true end end,
    [DEPOT_PRIORITY] = function(signal, state) state.depot_priority = signal.count end,
    [ISFUEL_STATION] = function(signal, state) if signal.count > 0 then state.is_fuel_station = true end end,
    [NETWORKID] = function(signal, state) state.network_id = signal.count end,
    [MINTRAINLENGTH] = function(signal, state) if signal.count > 0 then state.min_carriages = signal.count end end,
    [MAXTRAINLENGTH] = function(signal, state) if signal.count > 0 then state.max_carriages = signal.count end end,
    [MAXTRAINS] = function(signal, state) if signal.count then state.max_trains = signal.count end end,
    [REQUESTED_THRESHOLD] = function(signal, state) state.requesting_threshold = math.abs(signal.count) end,
    [REQUESTED_STACK_THRESHOLD] = function(signal, state) state.requesting_threshold_stacks = math.abs(signal.count) end,
    [REQUESTED_PRIORITY] = function(signal, state) state.requester_priority = signal.count end,
    [NOWARN] = function(signal, state) if signal.count > 0 then state.no_warnings = true end end,
    [PROVIDED_THRESHOLD] = function(signal, state) state.providing_threshold = math.abs(signal.count) end,
    [PROVIDED_STACK_THRESHOLD] = function(signal, state) state.providing_threshold_stacks = math.abs(signal.count) end,
    [PROVIDED_PRIORITY] = function(signal, state) state.provider_priority = signal.count end,
    [LOCKEDSLOTS] = function(signal, state) if signal.count > 0 then state.locked_slots = signal.count end end,
}

---@enum ltn.StationType
station_type = {
    station = 1,
    depot = 2,
    fuel_stop = 3,
}

---@param station ltn.TrainStop|ltn.SignalState
---@return ltn.StationType station_type The station type
function GetStationType(station)
    if station.is_depot then return station_type.depot end
    if station.is_fuel_station then return station_type.fuel_stop end
    return station_type.station
end

--- return true if stop, output, lamp are on same logic network
---@param checkStop ltn.TrainStop
---@return boolean True if short circuit detected
local function detectShortCircuit(checkStop)
    local networks = {}

    for _, entity in pairs { checkStop.entity, checkStop.output, checkStop.input } do
        local entity_wires = entity.get_wire_connectors(false)
        for _, wire_connector in pairs(entity_wires) do
            if wire_connector.connection_count > 0 then
                if networks[wire_connector.network_id] then return true end
                networks[wire_connector.network_id] = entity.unit_number
            end
        end
    end

    return false
end

-- update stop input signals
---@param stopID integer
---@param stop ltn.TrainStop
function UpdateStop(stopID, stop)
    local dispatcher = tools.getDispatcher()

    dispatcher.Requests_by_Stop[stopID] = nil

    -- remove invalid stops
    if not (stop and tools.isStopConsistent(stop)) then
        tools.printmsg(1, function()
            return { 'ltn-message.error-invalid-stop', stopID }
        end)

        tools.log(5, 'UpdateStop', 'Removing invalid stop: [%d]', function()
            return stopID
        end)

        RemoveStop(stopID)
        return
    end

    -- remove invalid trains
    if stop.parked_train and not stop.parked_train.valid then
        storage.LogisticTrainStops[stopID].parked_train = nil
        storage.LogisticTrainStops[stopID].parked_train_id = nil
    end

    -- remove invalid active_deliveries
    -- shouldn't be necessary
    for i = #stop.active_deliveries, 1, -1 do
        if not dispatcher.Deliveries[stop.active_deliveries[i]] then
            table.remove(stop.active_deliveries, i)

            tools.printmsg(1, function()
                return { 'ltn-message.error-invalid-delivery', stop.entity.backer_name }
            end)

            tools.log(5, 'UpdateStop', "(UpdateStop) Removing invalid delivery from stop '%s': %s", function()
                return stop.entity.backer_name, tostring(stop.active_deliveries[i])
            end)
        end
    end

    -- reset stop parameters in case something goes wrong
    stop.min_carriages = 0
    stop.max_carriages = 0
    stop.max_trains = 0
    stop.requesting_threshold = LtnSettings.min_requested
    stop.requester_priority = 0
    stop.no_warnings = false
    stop.providing_threshold = LtnSettings.min_provided
    stop.provider_priority = 0
    stop.locked_slots = 0
    stop.depot_priority = 0
    stop.fuel_signals = stop.fuel_signals or {}

    -- skip short circuited stops
    if detectShortCircuit(stop) then
        stop.error_code = 1
        tools.reduceAvailableCapacity(stop.parked_train_id)

        setLamp(stop, ErrorCodes[stop.error_code], 1)

        tools.log(5, 'UpdateStop', 'Short circuit error: %s', function()
            return stop.entity.backer_name
        end)

        return
    end

    -- also fix up the stop entity itself, in case someone meddled with it
    local disabled = tools.updateTrainStopSettings(stop)

    -- skip deactivated stops
    if disabled then
        stop.error_code = 1
        tools.reduceAvailableCapacity(stop.parked_train_id)

        setLamp(stop, ErrorCodes[stop.error_code], 1)

        tools.log(5, 'UpdateStop', 'Circuit deactivated stop: %s', function()
            return stop.entity.backer_name
        end)

        return
    end

    local signals = stop.input.get_signals(defines.wire_connector_id.circuit_red, defines.wire_connector_id.circuit_green)
    if not signals then return end -- either lamp and lampctrl are not connected or lampctrl has no output signal

    -- initialize control signal values to defaults
    ---@type ltn.SignalState
    local ltn_state = {
        is_depot = false,
        is_fuel_station = false,
        depot_priority = 0,
        ---@diagnostic disable-next-line: assign-type-mismatch
        network_id = nil, -- marker that network was not set by virtual signal
        min_carriages = 0,
        max_carriages = 0,
        max_trains = 0,
        requesting_threshold = LtnSettings.min_requested,
        requesting_threshold_stacks = 0,
        requester_priority = 0,
        no_warnings = false,
        providing_threshold = LtnSettings.min_provided,
        providing_threshold_stacks = 0,
        provider_priority = 0,
        locked_slots = 0,
        fuel_signals = {},
    }

    ---@type table<SignalID, number>
    local signals_filtered = {}

    for _, v in pairs(signals) do
        local signal_name = v.signal.name
        local signal_type = v.signal.type or 'item'
        if signal_type == 'virtual' and ltn_signals[signal_name] then
            ltn_signals[signal_name](v, ltn_state)
        elseif (signal_type == 'item' or signal_type == 'fluid') then
            signals_filtered[v.signal] = v.count
        end
    end

    if not ltn_state.network_id then
        ltn_state.network_id = LtnSettings.default_network

        tools.printmsg(3, function()
            return { 'ltn-message.stop-uses-default-network', tools.richTextForStop(stop.entity) or stop.entity.backer_name }
        end)
    end

    local network_id_string = string.format('0x%x', bit32.band(ltn_state.network_id))

    local new_state = GetStationType(ltn_state)
    local current_state = GetStationType(stop)

    --update lamp colors when error_code or is_depot changed state
    if stop.error_code ~= 0 or new_state ~= current_state then
        stop.error_code = 0 -- we are error free here

        if new_state == station_type.station then
            if #stop.active_deliveries > 0 then
                if stop.parked_train_id and stop.parked_train.valid then
                    setLamp(stop, 'blue', #stop.active_deliveries)
                else
                    setLamp(stop, 'yellow', #stop.active_deliveries)
                end
            else
                setLamp(stop, 'green', 1)
            end
        elseif new_state == station_type.depot then
            if stop.parked_train_id and stop.parked_train.valid then
                if dispatcher.Deliveries[stop.parked_train_id] then
                    setLamp(stop, 'yellow', 1)
                else
                    setLamp(stop, 'blue', 1)
                end
            else
                setLamp(stop, 'green', 1)
            end
        elseif new_state == station_type.fuel_stop then
            if stop.parked_train_id and stop.parked_train.valid then
                setLamp(stop, 'blue', 1)
            elseif #stop.fuel_signals > 0 then
                setLamp(stop, 'cyan', 1)
            else
                stop.error_code = 3
                setLamp(stop, ErrorCodes[stop.error_code], 3)
            end
        else
            -- unknown station type
            setLamp(stop, 'red', 1)
        end
    end

    -- Clean up old state, as the actual state has changed
    if new_state ~= current_state then
        if current_state == station_type.depot then
            tools.removeStop(tools.getDepots(), stopID)
        elseif current_state == station_type.fuel_stop then
            tools.removeStop(tools.getFuelStations(), stopID)
        end
    end

    -- check if it's a depot
    if new_state == station_type.depot then
        -- ----------------------------------------------------------------------------------------
        -- Depot Operations
        -- ----------------------------------------------------------------------------------------

        stop.depot_priority = ltn_state.depot_priority

        tools.updateStopList(stop, tools.getDepots(), ltn_state.network_id)

        -- add parked train to available trains
        if stop.parked_train_id and stop.parked_train.valid then
            if dispatcher.Deliveries[stop.parked_train_id] then
                tools.log(5, 'UpdateStop', '%s {%s}, depot priority: %d, assigned train.id: %d', function()
                    return stop.entity.backer_name, network_id_string, ltn_state.depot_priority, stop.parked_train_id
                end)
            else
                local train_info = tools.isTrainAvailable(stop.parked_train_id)
                if not train_info then
                    -- full arrival handling in case ltn-depot signal was turned on with an already parked train
                    TrainArrives(stop.parked_train)
                else
                    -- update properties from depot
                    train_info.network_id = ltn_state.network_id
                    train_info.depot_priority = ltn_state.depot_priority
                end
                tools.log(5, 'UpdateStop', '%s {%s}, depot priority: %d, available train.id: %d', function()
                    return stop.entity.backer_name, network_id_string, ltn_state.depot_priority, stop.parked_train_id
                end)
            end
        else
            tools.log(5, 'UpdateStop', '%s {%s}, depot priority: %d, no available train', function()
                return stop.entity.backer_name, network_id_string, ltn_state.depot_priority
            end)
        end
    elseif new_state == station_type.fuel_stop then
        -- ----------------------------------------------------------------------------------------
        -- Refuel operations
        -- ----------------------------------------------------------------------------------------

        local fuel_prototypes = prototypes.get_item_filtered {
            { filter = 'fuel', },
        }

        ---@type CircuitCondition[]
        local fuel_signals = {}

        for signal, count in pairs(signals_filtered) do
            if (signal.type or 'item') == 'item' and fuel_prototypes[signal.name] then
                table.insert(fuel_signals, {
                    first_signal = {
                        name = signal.name,
                        type = 'item',
                        quality = signal.quality or 'normal',
                    },
                    comparator = '<=',
                    constant = math.abs(count)
                })
            end
        end

        stop.fuel_signals = fuel_signals

        if #fuel_signals == 0 then
            stop.error_code = 3
            setLamp(stop, ErrorCodes[stop.error_code], 3)
        end

        tools.updateStopList(stop, tools.getFuelStations(), ltn_state.network_id)
    elseif new_state == station_type.station then
        -- ----------------------------------------------------------------------------------------
        -- Provider / Requester operations
        -- ----------------------------------------------------------------------------------------

        -- check if the name is unique
        tools.reduceAvailableCapacity(stop.parked_train_id)

        for signal, count in pairs(signals_filtered) do
            local signal_type = signal.type or 'item'
            local signal_name = signal.name
            local item = tools.createItemIdentifier(signal)

            for trainID, delivery in pairs(dispatcher.Deliveries) do
                local deliverycount = delivery.shipment[item]
                if deliverycount then
                    if stop.parked_train and stop.parked_train_id == trainID then
                        -- calculate items +- train inventory
                        local traincount = 0

                        if not LtnSettings.requester_ignores_trains then
                            if signal_type == 'fluid' then
                                traincount = math.floor(stop.parked_train.get_fluid_count(signal_name))
                            else
                                traincount = stop.parked_train.get_item_count(signal_name)
                            end
                        end

                        if delivery.to_id == stop.entity.unit_number then
                            local newcount = count + traincount
                            if newcount > 0 then newcount = 0 end --make sure we don't turn it into a provider
                            tools.log(5, 'UpdateStop', '%s {%s} updating requested count with train %d inventory: %s %d+%d=%d', function()
                                return stop.entity.backer_name, network_id_string, trainID, item, count, traincount, newcount
                            end)
                            count = newcount
                        elseif delivery.from_id == stop.entity.unit_number then
                            if traincount <= deliverycount then
                                local newcount = count - (deliverycount - traincount)
                                if newcount < 0 then newcount = 0 end --make sure we don't turn it into a request

                                tools.log(5, 'UpdateStop', '%s {%s} updating provided count with train %d inventory: %s %d-%d=%d', function()
                                    return stop.entity.backer_name, network_id_string, trainID, item, count, deliverycount - traincount, newcount
                                end)

                                count = newcount
                            else --train loaded more than delivery
                                tools.log(5, 'UpdateStop', '%s {%s} updating delivery count with overloaded train %d inventory: %s %d', function()
                                    return stop.entity.backer_name, network_id_string, trainID, item, traincount
                                end)

                                -- update delivery to new size
                                dispatcher.Deliveries[trainID].shipment[item] = traincount
                            end
                        end
                    else
                        -- calculate items +- deliveries
                        if delivery.to_id == stop.entity.unit_number then
                            local newcount = count + deliverycount
                            if newcount > 0 then newcount = 0 end --make sure we don't turn it into a provider

                            tools.log(5, 'UpdateStop', '%s {%s} updating requested count with delivery: %s %d+%d=%d', function()
                                return stop.entity.backer_name, network_id_string, item, count, deliverycount, newcount
                            end)

                            count = newcount
                        elseif delivery.from_id == stop.entity.unit_number and not delivery.pickupDone then
                            local newcount = count - deliverycount
                            if newcount < 0 then newcount = 0 end --make sure we don't turn it into a request
                            tools.log(5, 'UpdateStop', '%s {%s} updating provided count with delivery: %s %d-%d=%d', function()
                                return stop.entity.backer_name, network_id_string, item, count, deliverycount, newcount
                            end)
                            count = newcount
                        end
                    end
                end
            end -- for delivery

            local useProvideStackThreshold = false
            local useRequestStackThreshold = false
            local stack_count = 0

            if signal_type == 'item' then
                useProvideStackThreshold = ltn_state.providing_threshold_stacks > 0
                useRequestStackThreshold = ltn_state.requesting_threshold_stacks > 0
                assert(prototypes.item[signal_name], 'item prototype undefined!', signal_name)
                if prototypes.item[signal_name] then
                    stack_count = count / prototypes.item[signal_name].stack_size
                end
            end

            -- update Dispatcher Storage
            -- Providers are used when above Provider Threshold
            -- Requests are handled when above Requester Threshold
            if (useProvideStackThreshold and stack_count >= ltn_state.providing_threshold_stacks) or
                (not useProvideStackThreshold and count >= ltn_state.providing_threshold) then
                dispatcher.Provided[item] = dispatcher.Provided[item] or {}
                dispatcher.Provided[item][stopID] = count
                dispatcher.Provided_by_Stop[stopID] = dispatcher.Provided_by_Stop[stopID] or {}
                dispatcher.Provided_by_Stop[stopID][item] = count
                tools.log(5, 'UpdateStop', '%s {%s} provides %s %d(%d) stacks: %d(%d), priority: %d, min length: %d, max length: %d, trains en route: %s', function()
                    local trainsEnRoute = table.concat(stop.active_deliveries, ', ')
                    return stop.entity.backer_name, network_id_string, item, count, ltn_state.providing_threshold, stack_count, ltn_state.providing_threshold_stacks, ltn_state.provider_priority, ltn_state.min_carriages, ltn_state.max_carriages, trainsEnRoute
                end)
            elseif (useRequestStackThreshold and stack_count * -1 >= ltn_state.requesting_threshold_stacks) or
                (not useRequestStackThreshold and count * -1 >= ltn_state.requesting_threshold) then
                count = count * -1
                local ageIndex = item .. ',' .. stopID
                dispatcher.RequestAge[ageIndex] = dispatcher.RequestAge[ageIndex] or game.tick
                table.insert(dispatcher.Requests, {
                    age = dispatcher.RequestAge[ageIndex],
                    stopID = stopID,
                    priority = ltn_state.requester_priority,
                    item = item,
                    count = count
                })

                dispatcher.Requests_by_Stop[stopID] = dispatcher.Requests_by_Stop[stopID] or {}
                dispatcher.Requests_by_Stop[stopID][item] = count
                tools.log(5, 'UpdateStop', '%s {%s} requests %s %d(%d) stacks: %d(%d), priority: %d, min length: %d, max length: %d, age: %d/%d, trains en route: %s', function()
                    local trainsEnRoute = table.concat(stop.active_deliveries, ', ')
                    return stop.entity.backer_name, network_id_string, item, count, ltn_state.requesting_threshold, stack_count * -1, ltn_state.requesting_threshold_stacks, ltn_state.requester_priority, ltn_state.min_carriages, ltn_state.max_carriages, dispatcher.RequestAge[ageIndex], game.tick,
                        trainsEnRoute
                end)
            end
        end -- for circuitValues

        stop.providing_threshold = ltn_state.providing_threshold
        stop.providing_threshold_stacks = ltn_state.providing_threshold_stacks
        stop.provider_priority = ltn_state.provider_priority
        stop.requesting_threshold = ltn_state.requesting_threshold
        stop.requesting_threshold_stacks = ltn_state.requesting_threshold_stacks
        stop.requester_priority = ltn_state.requester_priority
        stop.locked_slots = ltn_state.locked_slots
        stop.no_warnings = ltn_state.no_warnings
    end

    stop.is_depot = ltn_state.is_depot
    stop.is_fuel_station = ltn_state.is_fuel_station
    stop.network_id = ltn_state.network_id
    stop.min_carriages = ltn_state.min_carriages
    stop.max_carriages = ltn_state.max_carriages
    stop.max_trains = ltn_state.max_trains
end

---@param trainStop ltn.TrainStop
---@param color string
---@param count number
function setLamp(trainStop, color, count)
    -- skip invalid stops and colors
    if not (trainStop and trainStop.lamp_control.valid and ColorLookup[color]) then return false end

    local lampctrl_control = trainStop.lamp_control.get_or_create_control_behavior() --[[@as LuaConstantCombinatorControlBehavior ]]
    assert(lampctrl_control)
    if lampctrl_control.sections_count == 0 then
        assert(lampctrl_control.add_section())
    end

    lampctrl_control.sections[1].set_slot(1, {
        value = {
            type = 'virtual',
            name = ColorLookup[color],
            quality = 'normal',
        },
        min = count,
    })

    return true
end

---@param trainStop ltn.TrainStop
---@param ignore_existing_cargo boolean?
function UpdateStopOutput(trainStop, ignore_existing_cargo)
    -- skip invalid stop outputs
    if not trainStop.output.valid then
        return
    end

    ---@type LogisticFilter[]
    local signals = {}

    ---@type ltn.StationType
    local stop_type = GetStationType(trainStop)

    if trainStop.parked_train and trainStop.parked_train.valid then
        -- get train composition
        local carriages = trainStop.parked_train.carriages
        local encoded_positions_by_name = {}
        local encoded_positions_by_type = {}

        ---@type ltn.InventoryType
        local inventory = {}
        ---@type ltn.FluidInventoryType
        local fluidInventory = {}

        if not (ignore_existing_cargo) then
            for _, item in pairs(trainStop.parked_train.get_contents()) do
                inventory[item.name] = item
            end
            for name, amount in pairs(trainStop.parked_train.get_fluid_contents()) do
                fluidInventory[name] = math.floor(amount)
            end
        end

        if #carriages < 32 then                       --prevent circuit network integer overflow error
            if trainStop.parked_train_faces_stop then --train faces forwards >> iterate normal
                for i = 1, #carriages do
                    local signal_type = string.format('ltn-position-any-%s', carriages[i].type)
                    if prototypes.virtual_signal[signal_type] then
                        if encoded_positions_by_type[signal_type] then
                            encoded_positions_by_type[signal_type] = encoded_positions_by_type[signal_type] + 2 ^ (i - 1)
                        else
                            encoded_positions_by_type[signal_type] = 2 ^ (i - 1)
                        end
                    else
                        tools.printmsg(1, function()
                            return { 'ltn-message.error-invalid-position-signal', signal_type }
                        end)

                        tools.log(5, 'UpdateStopOutput', 'Error: signal "%s" not found!', function()
                            return signal_type
                        end)
                    end
                    local signal_name = string.format('ltn-position-%s', carriages[i].name)
                    if prototypes.virtual_signal[signal_name] then
                        if encoded_positions_by_name[signal_name] then
                            encoded_positions_by_name[signal_name] = encoded_positions_by_name[signal_name] + 2 ^ (i - 1)
                        else
                            encoded_positions_by_name[signal_name] = 2 ^ (i - 1)
                        end
                    else
                        tools.printmsg(1, function()
                            return { 'ltn-message.error-invalid-position-signal', signal_name }
                        end)

                        tools.log(5, 'UpdateStopOutput', 'Error: signal "%s" not found!', function()
                            return signal_name
                        end)
                    end
                end
            else --train faces backwards >> iterate backwards
                n = 0
                for i = #carriages, 1, -1 do
                    local signal_type = string.format('ltn-position-any-%s', carriages[i].type)
                    if prototypes.virtual_signal[signal_type] then
                        if encoded_positions_by_type[signal_type] then
                            encoded_positions_by_type[signal_type] = encoded_positions_by_type[signal_type] + 2 ^ n
                        else
                            encoded_positions_by_type[signal_type] = 2 ^ n
                        end
                    else
                        tools.printmsg(1, function()
                            return { 'ltn-message.error-invalid-position-signal', signal_type }
                        end)

                        tools.log(5, 'UpdateStopOutput', 'Error: signal "%s" not found!', function()
                            return signal_type
                        end)
                    end
                    local signal_name = string.format('ltn-position-%s', carriages[i].name)
                    if prototypes.virtual_signal[signal_name] then
                        if encoded_positions_by_name[signal_name] then
                            encoded_positions_by_name[signal_name] = encoded_positions_by_name[signal_name] + 2 ^ n
                        else
                            encoded_positions_by_name[signal_name] = 2 ^ n
                        end
                    else
                        tools.printmsg(1, function()
                            return { 'ltn-message.error-invalid-position-signal', signal_name }
                        end)

                        tools.log(5, 'UpdateStopOutput', 'Error: signal "%s" not found!', function()
                            return signal_name
                        end)
                    end
                    n = n + 1
                end
            end

            for k, v in pairs(encoded_positions_by_type) do
                table.insert(signals, { value = { type = 'virtual', name = k, quality = 'normal', }, min = v, })
            end
            for k, v in pairs(encoded_positions_by_name) do
                table.insert(signals, { value = { type = 'virtual', name = k, quality = 'normal', }, min = v, })
            end
        end

        if stop_type == station_type.station then
            schedule:updateFromSchedule(trainStop.parked_train, inventory, fluidInventory)

            -- output expected inventory contents
            for k, v in pairs(inventory) do
                table.insert(signals, { value = { type = 'item', name = v.name, quality = v.quality, }, min = v.count, })
            end
            for k, v in pairs(fluidInventory) do
                table.insert(signals, { value = { type = 'fluid', name = k, quality = 'normal', }, min = v, })
            end
        end -- station
    end

    local outputControl = trainStop.output.get_or_create_control_behavior() --[[@as LuaConstantCombinatorControlBehavior ]]
    assert(outputControl)

    if outputControl.sections_count == 0 then
        assert(outputControl.add_section())
    end
    local section = outputControl.sections[1]
    section.filters = {}

    for idx, signal in pairs(signals) do
        section.set_slot(idx, signal)
    end
end
