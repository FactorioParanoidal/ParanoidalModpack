--[[ Copyright (c) 2017 Optera
 * Part of Logistics Train Network
 *
 * See LICENSE.md in the project directory for license information.
--]]

local tools = require('script.tools')

--create stop
---@param entity LuaEntity
function CreateStop(entity)
    if storage.LogisticTrainStops[entity.unit_number] then
        tools.printmsg(1, function()
            return { 'ltn-message.error-duplicated-unit_number', entity.unit_number }
        end, entity.force)

        tools.log(5, 'CreateStop', 'duplicate stop unit number %d', function()
            return entity.unit_number
        end)

        return
    end

    local stop_offset = ltn_stop_entity_names[entity.name]
    local posIn, posOut, search_area

    tools.log(7, 'CreateStop', 'Stop created at %d/%d, orientation %d', function()
        return entity.position.x, entity.position.y, entity.direction
    end)

    if entity.direction == defines.direction.north then --SN
        posIn = { entity.position.x + stop_offset, entity.position.y - 1 }
        posOut = { entity.position.x - 1 + stop_offset, entity.position.y - 1 }
        search_area = {
            { entity.position.x + 0.001 - 1 + stop_offset, entity.position.y + 0.001 - 1 },
            { entity.position.x - 0.001 + 1 + stop_offset, entity.position.y - 0.001 }
        }
    elseif entity.direction == defines.direction.east then --WE
        posIn = { entity.position.x, entity.position.y + stop_offset }
        posOut = { entity.position.x, entity.position.y - 1 + stop_offset }
        search_area = {
            { entity.position.x + 0.001,     entity.position.y + 0.001 - 1 + stop_offset },
            { entity.position.x - 0.001 + 1, entity.position.y - 0.001 + 1 + stop_offset }
        }
    elseif entity.direction == defines.direction.south then --NS
        posIn = { entity.position.x - 1 - stop_offset, entity.position.y }
        posOut = { entity.position.x - stop_offset, entity.position.y }
        search_area = {
            { entity.position.x + 0.001 - 1 - stop_offset, entity.position.y + 0.001 },
            { entity.position.x - 0.001 + 1 - stop_offset, entity.position.y - 0.001 + 1 }
        }
    elseif entity.direction == defines.direction.west then --EW
        posIn = { entity.position.x - 1, entity.position.y - 1 - stop_offset }
        posOut = { entity.position.x - 1, entity.position.y - stop_offset }
        search_area = {
            { entity.position.x + 0.001 - 1, entity.position.y + 0.001 - 1 - stop_offset },
            { entity.position.x - 0.001,     entity.position.y - 0.001 + 1 - stop_offset }
        }
    else --invalid orientation
        tools.printmsg(1, function()
            return { 'ltn-message.error-stop-orientation', tostring(entity.direction) }
        end, entity.force)

        tools.log(5, 'CreateStop', 'invalid train stop orientation %d', function()
            return entity.direction
        end)
        entity.destroy()
        return
    end

    local input, output, lampctrl
    -- handle blueprint ghosts and existing IO entities preserving circuit connections
    local ghosts = entity.surface.find_entities(search_area)
    for _, ghost in pairs(ghosts) do
        if ghost.valid then
            if ghost.name == 'entity-ghost' then
                if ghost.ghost_name == ltn_stop_input then
                    tools.log(5, 'CreateStop', 'reviving ghost input at %d/%d', function()
                        return ghost.position.x, ghost.position.y
                    end)
                    _, input = ghost.revive()
                elseif ghost.ghost_name == ltn_stop_output then
                    tools.log(5, 'CreateStop', 'reviving ghost output at %d/%d', function()
                        return ghost.position.x, ghost.position.y
                    end)
                    _, output = ghost.revive()
                elseif ghost.ghost_name == ltn_stop_output_controller then
                    tools.log(5, 'CreateStop', 'reviving ghost lamp-control at %d/%d', function()
                        return ghost.position.x, ghost.position.y
                    end)
                    _, lampctrl = ghost.revive()
                end
            elseif ghost.name == ltn_stop_input then
                input = ghost
                tools.log(5, 'CreateStop', 'found existing input at %d/%d', function()
                    return ghost.position.x, ghost.position.y
                end)
            elseif ghost.name == ltn_stop_output then
                output = ghost
                tools.log(5, 'CreateStop', 'found existing output at %d/%d', function()
                    return ghost.position.x, ghost.position.y
                end)
            elseif ghost.name == ltn_stop_output_controller then
                lampctrl = ghost
                tools.log(5, 'CreateStop', 'found existing lamp-control at %d/%d', function()
                    return ghost.position.x, ghost.position.y
                end)
            end
        end
    end

    if input == nil then -- create new
        input = entity.surface.create_entity {
            name = ltn_stop_input,

            position = posIn,
            force = entity.force
        }
    end

    assert(input)
    input.operable = false     -- disable gui
    input.minable = false
    input.destructible = false -- don't bother checking if alive
    input.always_on = true

    if lampctrl == nil then
        lampctrl = entity.surface.create_entity {
            name = ltn_stop_output_controller,
            position = { input.position.x + 0.45, input.position.y + 0.45 }, -- slight offset so adjacent lamps won't connect
            force = entity.force
        }
    end

    assert(lampctrl)
    lampctrl.operable = false     -- disable gui
    lampctrl.minable = false
    lampctrl.destructible = false -- don't bother checking if alive

    -- connect lamp and control

    local lampctrl_control = lampctrl.get_or_create_control_behavior() --[[@as LuaConstantCombinatorControlBehavior ]]
    assert(lampctrl_control)
    if lampctrl_control.sections_count == 0 then
        assert(lampctrl_control.add_section())
    end

    lampctrl_control.sections[1].set_slot(1, {
        value = {
            type = 'virtual',
            name = 'signal-white',
            quality = 'normal',
        },
        min = 1,
    })

    local input_wire_connectors = input.get_wire_connectors(true)
    local lampctrl_wire_connectors = lampctrl.get_wire_connectors(true)

    input_wire_connectors[defines.wire_connector_id.circuit_green].connect_to(lampctrl_wire_connectors[defines.wire_connector_id.circuit_green], false, defines.wire_origin.script)

    local input_control = input.get_or_create_control_behavior() --[[@as LuaLampControlBehavior ]]
    assert(input_control)
    input_control.use_colors = true

    ---@diagnostic disable: missing-fields
    input_control.circuit_condition = {
        comparator = '>',
        first_signal = { type = 'virtual', name = 'signal-anything', quality = 'normal' },
        constant = 0,
    }
    ---@diagnostic enable: missing-fields

    if output == nil then -- create new
        output = entity.surface.create_entity {
            name = ltn_stop_output,
            position = posOut,
            direction = entity.direction,
            force = entity.force
        }
    end
    assert(output)

    output.operable = false     -- disable gui
    output.minable = false
    output.destructible = false -- don't bother checking if alive

    local stop = {
        entity = entity,
        input = input,
        output = output,
        lamp_control = lampctrl,
        parked_train = nil,
        parked_train_id = nil,
        active_deliveries = {}, --delivery IDs to/from stop
        error_code = -1,        --key to error_codes table
        is_depot = false,
        is_fuel_station = false,
        depot_priority = 0,
        network_id = LtnSettings.default_network,
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

    -- also fix up the stop entity itself, in case someone meddled with it
    tools.updateTrainStopSettings(stop)

    storage.LogisticTrainStops[entity.unit_number] = stop

    UpdateStopOutput(stop)

    -- register events
    tools.updateDispatchTicker()

    tools.log(5, 'CreateStop', 'on_nth_tick(%d), on_train_changed_state, on_train_created registered', function()
        return LtnSettings.dispatcher_nth_tick
    end)
end

---@param event EventData.on_built_entity | EventData.on_robot_built_entity | EventData.on_entity_cloned
function OnEntityCreated(event)
    local entity = event.entity or event.destination
    if not entity or not entity.valid then return end

    if ltn_stop_entity_names[entity.name] then
        CreateStop(entity)
    end
end

-- stop removed
---@param stopID number
---@param create_ghosts boolean?
function RemoveStop(stopID, create_ghosts)
    -- clean lookup tables
    for k in pairs(storage.StopDistances) do
        if k:find(stopID) then
            storage.StopDistances[k] = nil
        end
    end

    local stop = storage.LogisticTrainStops[stopID]

    if stop then
        -- remove available train
        if GetStationType(stop) ~= station_type.station then
            tools.removeStop(tools.getDepots(), stopID)
            tools.removeStop(tools.getFuelStations(), stopID)

            tools.reduceAvailableCapacity(stop.parked_train_id)
        end

        -- destroy IO entities, broken IO entities should be sufficiently handled in initializeTrainStops()
        if stop.input and stop.input.valid then
            if create_ghosts then
                stop.input.destructible = true
                stop.input.die()
            else
                stop.input.destroy()
            end
        end
        if stop.output and stop.output.valid then
            if create_ghosts then
                stop.output.destructible = true
                stop.output.die()
            else
                stop.output.destroy()
            end
        end
        if stop.lamp_control and stop.lamp_control.valid then stop.lamp_control.destroy() end

        storage.LogisticTrainStops[stopID] = nil
    end

    if not next(storage.LogisticTrainStops) then
        -- reset tick indexes
        storage.tick_state = 0
        storage.tick_stop_index = nil
        storage.tick_request_index = nil

        -- unregister events
        tools.updateDispatchTicker()
        tools.log(5, 'RemoveStop', 'Removed last LTN Stop: on_nth_tick, on_train_changed_state, on_train_created unregistered.')
    end
end

---@param event EventData.on_pre_player_mined_item | EventData.on_robot_pre_mined | EventData.on_entity_died | EventData.script_raised_destroy
---@param create_ghosts boolean?
function OnEntityRemoved(event, create_ghosts)
    local dispatcher = tools.getDispatcher()
    local stopped_trains = tools.getStoppedTrains()

    local entity = event.entity
    if not entity or not entity.valid then return end

    if entity.train then
        local trainID = entity.train.id
        -- remove from stop if parked
        if stopped_trains[trainID] then
            TrainLeaves(trainID)
        end
        -- removing any carriage fails a delivery
        -- otherwise I'd have to handle splitting and merging a delivery across train parts
        local delivery = dispatcher.Deliveries[trainID]
        if delivery then
            ---@type ltn.EventData.on_delivery_failed
            local data = {
                train_id = trainID,
                shipment = delivery.shipment
            }
            script.raise_event(on_delivery_failed_event, data)
            RemoveDelivery(trainID)
        end
    elseif ltn_stop_entity_names[entity.name] then
        RemoveStop(entity.unit_number, create_ghosts)
    end
end

--rename stop
---@param targetID number
---@param old_name string
---@param new_name string
local function renamedStop(targetID, old_name, new_name)
    local dispatcher = tools.getDispatcher()

    -- find identical stop names
    local duplicateName = false
    local renameDeliveries = true
    for stopID, stop in pairs(storage.LogisticTrainStops) do
        if not tools.isStopConsistent(stop) then
            RemoveStop(stopID)
        elseif stop.entity.unit_number ~= targetID and stop.entity.backer_name == old_name then
            -- another stop exists with the same name as the renamed stop
            -- deliveries can go to that stop, no need to rename
            renameDeliveries = false
        end
    end
    -- rename deliveries only if no other LTN stop old_name exists
    if not renameDeliveries then return end

    tools.log(5, 'renamedStop', 'last LTN stop %s renamed, updating deliveries to %s.', function()
        return old_name, new_name
    end)

    for _, delivery in pairs(dispatcher.Deliveries) do
        if delivery.to == old_name then
            delivery.to = new_name
        end
        if delivery.from == old_name then
            delivery.from = new_name
        end
    end
end

script.on_event(defines.events.on_entity_renamed, function(event)
    if not (event and event.entity and event.entity.valid) then return end
    local entity = event.entity
    if not (entity.type == 'train-stop' and ltn_stop_entity_names[entity.name]) then return end

    local uid = event.entity.unit_number
    local oldName = event.old_name
    local newName = event.entity.backer_name
    assert(newName)
    renamedStop(uid, oldName, newName)
end)
