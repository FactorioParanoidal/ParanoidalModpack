--[[ Copyright (c) 2017 Optera
 * Part of Logistics Train Network
 *
 * See LICENSE.md in the project directory for license information.
--]]

---- INITIALIZATION ----

local tools = require('script.tools')

local function initialize(oldVersion, newVersion)
    tools.log(0, 'initialize', 'oldVersion: %s, newVersion: %s', function()
        return tostring(oldVersion), tostring(newVersion)
    end)

    ---- always start with stop updated after a config change, ensure consistent data and filled tables
    storage.tick_state = 0 -- index determining on_tick update mode 0: init, 1: stop update, 2: sort requests, 3: parse requests, 4: raise API update events
    storage.tick_stop_index = nil
    storage.tick_request_index = nil
    storage.tick_interval_start = nil -- stores tick of last state 0 for on_dispatcher_updated_event.update_interval

    ---- initialize Dispatcher
    storage.Dispatcher = storage.Dispatcher or {}

    -- set in UpdateAllTrains
    storage.Dispatcher.availableTrains = storage.Dispatcher.availableTrains or {}
    storage.Dispatcher.availableTrains_total_capacity = storage.Dispatcher.availableTrains_total_capacity or 0
    storage.Dispatcher.availableTrains_total_fluid_capacity = storage.Dispatcher.availableTrains_total_fluid_capacity or 0
    storage.Dispatcher.knownTrains = storage.Dispatcher.knownTrains or {}
    storage.Dispatcher.Provided = storage.Dispatcher.Provided or {}                 -- dictionary [type,name] used to quickly find available items
    storage.Dispatcher.Provided_by_Stop = storage.Dispatcher.Provided_by_Stop or {} -- dictionary [stopID]; used only by interface
    storage.Dispatcher.Requests = storage.Dispatcher.Requests or {}                 -- array of requests sorted by priority and age; used to loop over all requests
    storage.Dispatcher.Requests_by_Stop = storage.Dispatcher.Requests_by_Stop or {} -- dictionary [stopID]; used to keep track of already handled requests
    storage.Dispatcher.RequestAge = storage.Dispatcher.RequestAge or {}
    storage.Dispatcher.Deliveries = storage.Dispatcher.Deliveries or {}

    ---- initialize stops
    storage.LogisticTrainStops = storage.LogisticTrainStops or {}
    storage.FuelStations = storage.FuelStations or {}
    storage.Depots = storage.Depots or {}

    -- table of connections per surface used to decide if providers from another surface are valid sources
    -- { [surface1.index|surface2.index] = { [entity1.unit_number|entity2.unit_number] = { entity1, entity2, network_id } }
    -- entity_key_pairs are automatically removed during delivery processing if at least one of the referenced entities becomes invalid
    storage.ConnectedSurfaces = storage.ConnectedSurfaces or {}

    -- clean obsolete global
    storage.Dispatcher.Requested = nil
    storage.Dispatcher.Orders = nil
    storage.Dispatcher.OrderAge = nil
    storage.Dispatcher.Storage = nil
    storage.useRailTanker = nil
    storage.tickCount = nil
    storage.stopIdStartIndex = nil
    storage.Dispatcher.UpdateInterval = nil
    storage.Dispatcher.UpdateStopsPerTick = nil
    storage.TrainStopNames = nil

    -- update to 1.3.0
    if oldVersion and oldVersion < '01.03.00' then
        for stopID, stop in pairs(storage.LogisticTrainStops) do
            stop.minDelivery = nil ---@diagnostic disable-line: inject-field
            stop.ignoreMinDeliverySize = nil ---@diagnostic disable-line: inject-field
        end
    end

    -- update to 1.5.0 renamed priority to provider_priority
    if oldVersion and oldVersion < '01.05.00' then
        for stopID, stop in pairs(storage.LogisticTrainStops) do
            stop.provider_priority = stop.priority or 0
            stop.priority = nil ---@diagnostic disable-line: inject-field
        end
        storage.Dispatcher.Requests = {}
        storage.Dispatcher.RequestAge = {}
    end

    -- update to 1.6.1 migrate locomotiveID to trainID
    if oldVersion and oldVersion < '01.06.01' then
        local locoID_to_trainID = {} -- id dictionary
        local new_Deliveries = {}

        local train_manager = game.train_manager
        for _, surface in pairs(game.surfaces) do
            local trains = train_manager.get_trains { surface = surface }
            for _, train in pairs(trains) do
                -- build dictionary
                local loco = tools.getMainLocomotive(train)
                if loco then
                    locoID_to_trainID[loco.unit_number] = train.id
                end
            end
        end

        tools.log(0, '1.6.1', 'locoID_to_trainID: %s', function()
            return serpent.block(locoID_to_trainID)
        end)

        for locoID, delivery in pairs(storage.Dispatcher.Deliveries) do
            local trainID = locoID_to_trainID[locoID]
            if trainID then
                tools.log(0, 'initialize', 'Migrating storage.Dispatcher.Deliveries from [%s] to [%s]', function()
                    return tostring(locoID), tostring(trainID)
                end)
                new_Deliveries[trainID] = delivery
            end
        end
        storage.Dispatcher.Deliveries = new_Deliveries
    end

    -- update to 1.8.0
    if oldVersion and oldVersion < '01.08.00' then
        for _, stop in pairs(storage.LogisticTrainStops) do
            local control = stop.entity.get_or_create_control_behavior --[[@as LuaTrainStopControlBehavior]]
            control.send_to_train = true
            control.read_from_train = true
        end
    end

    -- update to 1.12.3 migrate networkID to network_id
    if oldVersion and oldVersion < '01.12.03' then
        for _, delivery in pairs(storage.Dispatcher.Deliveries) do
            delivery.network_id = delivery.networkID
            delivery.networkID = nil
        end
    end

    -- update to 1.13.1 renamed almost all stop properties
    if oldVersion and oldVersion < '01.13.01' and next(storage.LogisticTrainStops) then
        for _, stop in pairs(storage.LogisticTrainStops) do
            stop.lamp_control = stop.lamp_control or stop.lampControl
            stop.lampControl = nil ---@diagnostic disable-line: inject-field
            stop.error_code = stop.error_code or stop.errorCode or -1
            stop.errorCode = nil ---@diagnostic disable-line: inject-field
            stop.active_deliveries = stop.active_deliveries or stop.activeDeliveries or {}
            stop.activeDeliveries = nil ---@diagnostic disable-line: inject-field
            -- control signals
            stop.is_depot = stop.is_depot or stop.isDepot or false
            stop.isDepot = nil ---@diagnostic disable-line: inject-field
            stop.depot_priority = stop.depot_priority or 0
            stop.max_carriages = stop.max_carriages or stop.maxTraincars or 0
            stop.maxTraincars = nil ---@diagnostic disable-line: inject-field
            stop.min_carriages = stop.min_carriages or stop.minTraincars or 0
            stop.minTraincars = nil ---@diagnostic disable-line: inject-field
            stop.max_trains = stop.max_trains or stop.trainLimit or 0
            stop.trainLimit = nil ---@diagnostic disable-line: inject-field
            stop.providing_threshold = stop.providing_threshold or stop.provideThreshold or LtnSettings.min_provided
            stop.provideThreshold = nil ---@diagnostic disable-line: inject-field
            stop.providing_threshold_stacks = stop.providing_threshold_stacks or stop.provideStackThreshold or 0
            stop.provideStackThreshold = nil ---@diagnostic disable-line: inject-field
            stop.provider_priority = stop.provider_priority or stop.providePriority or 0
            stop.providePriority = nil ---@diagnostic disable-line: inject-field
            stop.requesting_threshold = stop.requesting_threshold or stop.requestThreshold or LtnSettings.min_requested
            stop.requestThreshold = nil ---@diagnostic disable-line: inject-field
            stop.requesting_threshold_stacks = stop.requesting_threshold_stacks or stop.requestStackThreshold or 0
            stop.requestStackThreshold = nil ---@diagnostic disable-line: inject-field
            stop.requester_priority = stop.requester_priority or stop.requestPriority or 0
            stop.requestPriority = nil ---@diagnostic disable-line: inject-field
            stop.locked_slots = stop.locked_slots or stop.lockedSlots or 0
            stop.lockedSlots = nil ---@diagnostic disable-line: inject-field
            stop.no_warnings = stop.no_warnings or stop.noWarnings or false
            stop.noWarnings = nil ---@diagnostic disable-line: inject-field
            -- parked train data will be set during initializeTrainStops() and updateAllTrains()
            stop.parkedTrain = nil ---@diagnostic disable-line: inject-field
            stop.parkedTrainID = nil ---@diagnostic disable-line: inject-field
            stop.parkedTrainFacesStop = nil ---@diagnostic disable-line: inject-field
        end
    end

    -- update to 1.9.4
    if oldVersion and oldVersion < '01.09.04' then
        for _, stop in pairs(storage.LogisticTrainStops) do
            stop.lamp_control.teleport { stop.input.position.x, stop.input.position.y } -- move control under lamp

            local input_connectors = stop.input.get_wire_connectors(true)
            local control_connectors = stop.lamp_control.get_wire_connectors(true)

            for connector_id, connector in pairs(input_connectors) do
                connector.disconnect_all(defines.wire_origin.script)
                connector.connect_to(control_connectors[connector_id], false, defines.wire_origin.script)
            end
        end
    end
end

-- run every time the mod configuration is changed to catch stops from other mods
-- ensures storage.LogisticTrainStops contains valid entities
local function initializeTrainStops()
    ---@type table<number, ltn.TrainStop>
    storage.LogisticTrainStops = storage.LogisticTrainStops or {}
    -- remove invalidated stops
    for stopID, stop in pairs(storage.LogisticTrainStops) do
        if not stop then
            tools.log(0, 'initializeTrainStops', 'removing empty stop entry %s', function()
                return tostring(stopID)
            end)
            storage.LogisticTrainStops[stopID] = nil
        elseif not (stop.entity and stop.entity.valid) then
            -- stop entity is corrupt/missing remove I/O entities
            tools.log(0, 'initializeTrainStops', 'removing corrupt stop %s', function()
                return tostring(stopID)
            end)
            if stop.input and stop.input.valid then stop.input.destroy() end
            if stop.output and stop.output.valid then stop.output.destroy() end
            if stop.lamp_control and stop.lamp_control.valid then stop.lamp_control.destroy() end
            storage.LogisticTrainStops[stopID] = nil
        end
    end

    -- add missing ltn stops
    for _, surface in pairs(game.surfaces) do
        local foundStops = surface.find_entities_filtered { type = 'train-stop' }
        if foundStops then
            for k, stop in pairs(foundStops) do
                -- validate storage.LogisticTrainStops
                if ltn_stop_entity_names[stop.name] then
                    local ltn_stop = storage.LogisticTrainStops[stop.unit_number]
                    if ltn_stop then
                        if not tools.isStopConsistent(ltn_stop) then
                            -- I/O entities are corrupted
                            tools.log(0, 'initializeTrainStops', 'recreating corrupt stop %s', function()
                                return stop.backer_name
                            end)
                            storage.LogisticTrainStops[stop.unit_number] = nil
                            CreateStop(stop) -- recreate to spawn missing I/O entities
                        end
                    else
                        tools.log(0, 'initializeTrainStops', 'recreating stop missing from storage.LogisticTrainStops - %s', function()
                            return tostring(stop.backer_name)
                        end)
                        CreateStop(stop) -- recreate LTN stops missing from storage.LogisticTrainStops
                    end
                end
            end
        end
    end
end

-- run every time the mod configuration is changed to catch changes to wagon capacities by other mods
local function updateAllTrains()
    -- reset global lookup tables
    storage.StoppedTrains = {} -- trains stopped at LTN stops
    storage.StopDistances = {} -- reset station distance lookup table
    storage.WagonCapacity = {}

    storage.Dispatcher.availableTrains_total_capacity = 0
    storage.Dispatcher.availableTrains_total_fluid_capacity = 0
    storage.Dispatcher.availableTrains = {}
    storage.Dispatcher.knownTrains = {}

    -- remove all parked train from logistic stops
    for _, stop in pairs(storage.LogisticTrainStops) do
        stop.parked_train = nil
        stop.parked_train_id = nil
        UpdateStopOutput(stop)
    end

    -- add still valid trains back to stops
    local train_manager = game.train_manager
    for _, force in pairs(game.forces) do
        local trains = train_manager.get_trains { force = force }
        if trains then
            for _, train in pairs(trains) do
                if train.station and ltn_stop_entity_names[train.station.name] then
                    TrainArrives(train)
                end
            end
        end
    end
end

-- check all deliveries for potentially invalidated entities in surface connections
local function updateAllDeliveries()
    for _, delivery in pairs(storage.Dispatcher.Deliveries) do
        local surface_connections = {}
        for idx, surface_connection in pairs(delivery.surface_connections) do
            if (surface_connection.entity1 and surface_connection.entity1.valid)
                and (surface_connection.entity2 and surface_connection.entity2.valid) then
                    surface_connections[#surface_connections + 1] = surface_connection
            end
        end
        delivery.surface_connections = surface_connections
        delivery.surface_connections_count = #surface_connections
    end
end

---@param event EventData.on_object_destroyed
local function onObjectDestroyed(event)
    if SurfaceInterfaceOnObjectDestroyed(event.useful_id) then
        DispatcherOnObjectDestroyed(event.useful_id)
    end
end

-- register events
local function registerEvents()
    local filters_on_built = { { filter = 'type', type = 'train-stop' } }
    local filters_on_mined = { { filter = 'type', type = 'train-stop' }, { filter = 'rolling-stock' } }

    -- always track built/removed train stops for duplicate name list
    script.on_event(defines.events.on_built_entity, OnEntityCreated, filters_on_built)
    script.on_event(defines.events.on_robot_built_entity, OnEntityCreated, filters_on_built)
    script.on_event({ defines.events.script_raised_built, defines.events.script_raised_revive, defines.events.on_entity_cloned }, OnEntityCreated)

    script.on_event(defines.events.on_pre_player_mined_item, OnEntityRemoved, filters_on_mined)
    script.on_event(defines.events.on_robot_pre_mined, OnEntityRemoved, filters_on_mined)
    script.on_event(defines.events.on_entity_died, function(event) OnEntityRemoved(event, true) end, filters_on_mined)
    script.on_event(defines.events.script_raised_destroy, OnEntityRemoved)

    script.on_event(defines.events.on_object_destroyed, onObjectDestroyed)

    script.on_event({ defines.events.on_pre_surface_deleted, defines.events.on_pre_surface_cleared }, OnSurfaceRemoved)
    script.on_event(defines.events.on_runtime_mod_setting_changed, LtnSettings.on_config_changed)

    tools.updateDispatchTicker()

    -- disable instant blueprint in creative mode
    if remote.interfaces['creative-mode'] and remote.interfaces['creative-mode']['exclude_from_instant_blueprint'] then
        remote.call('creative-mode', 'exclude_from_instant_blueprint', ltn_stop_input)
        remote.call('creative-mode', 'exclude_from_instant_blueprint', ltn_stop_output)
        remote.call('creative-mode', 'exclude_from_instant_blueprint', ltn_stop_output_controller)
    end

    -- blacklist LTN entities from picker dollies
    if remote.interfaces['PickerDollies'] and remote.interfaces['PickerDollies']['add_blacklist_name'] then
        for name, _ in pairs(ltn_stop_entity_names) do
            remote.call('PickerDollies', 'add_blacklist_name', name, true)
        end
        remote.call('PickerDollies', 'add_blacklist_name', ltn_stop_input, true)
        remote.call('PickerDollies', 'add_blacklist_name', ltn_stop_output, true)
        remote.call('PickerDollies', 'add_blacklist_name', ltn_stop_output_controller, true)
    end
end

script.on_load(function()
    LtnSettings:init()

    registerEvents()
end)

script.on_init(function()
    LtnSettings:init()

    -- format version string to "00.00.00"
    local oldVersion, newVersion = nil, nil
    local newVersionString = script.active_mods[MOD_NAME]
    if newVersionString then
        newVersion = string.format('%02d.%02d.%02d', string.match(newVersionString, '(%d+).(%d+).(%d+)'))
    end
    initialize(oldVersion, newVersion)
    initializeTrainStops()
    updateAllTrains()
    registerEvents()

    tools.log(0, 'on_init', '%s %s initialized.', function()
        return MOD_NAME, newVersionString
    end)
end)

script.on_configuration_changed(function(data)
    if data and data.mod_changes[MOD_NAME] then
        -- format version string to "00.00.00"
        local oldVersion, newVersion = nil, nil
        local oldVersionString = data.mod_changes[MOD_NAME].old_version
        if oldVersionString then
            oldVersion = string.format('%02d.%02d.%02d', string.match(oldVersionString, '(%d+).(%d+).(%d+)'))
        end
        local newVersionString = data.mod_changes[MOD_NAME].new_version
        if newVersionString then
            newVersion = string.format('%02d.%02d.%02d', string.match(newVersionString, '(%d+).(%d+).(%d+)'))
        end

        if oldVersion and oldVersion < '01.01.01' then
            tools.log(0, 'on_init', 'Migration failed. Migrating from %s to %s not supported.', function()
                return oldVersionString, newVersionString
            end)

            tools.printmsg(0, function()
                return string.format('[LTN] Error: Direct migration from %s to %s is not supported. Oldest supported version: 1.1.1', oldVersionString, newVersionString)
            end)

            return
        else
            initialize(oldVersion, newVersion)

            tools.log(0, 'on_init', 'Migrating from %s to %s complete.', function()
                return oldVersionString, newVersionString
            end)

            tools.printmsg(0, function()
                return string.format('[LTN] Migration from %s to %s complete.', oldVersionString, newVersionString)
            end)
        end
    end
    initializeTrainStops()
    updateAllTrains()
    updateAllDeliveries()

    tools.log(0, 'on_configuration_changed', '%s %s configuration updated.', function()
        return MOD_NAME, script.active_mods[MOD_NAME]
    end)
end)
