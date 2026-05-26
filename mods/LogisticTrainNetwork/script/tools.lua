-----------------------------------------------------------------------
-- tools
-----------------------------------------------------------------------

---@class ltn.Tools
local Tools = {}

---@enum ltn.TickState
ltn_tick_state = {
    reset = 0,
    update_stops = 1,
    update_deliveries = 2,
    dispatch_trains = 3,
    api_events = 4,
    cleanup = 5,
}

-----------------------------------------------------------------------
-- typed accessors to storage
-----------------------------------------------------------------------

--- Typed access to the dispatcher instance from storage.
---
---@return ltn.Dispatcher
function Tools.getDispatcher()
    return assert(storage.Dispatcher)
end

--- Typed access to the stopped trains from storage.
---
---@return table<integer, ltn.StoppedTrain>
function Tools.getStoppedTrains()
    return assert(storage.StoppedTrains)
end

--- Typed access to all stops
---
---@return table<integer, ltn.TrainStop>
function Tools.getAllStops()
    return assert(storage.LogisticTrainStops)
end

--- Typed access to the fuel stops.
---@return ltn.TrainStop[][]
function Tools.getFuelStations()
    return assert(storage.FuelStations)
end

--- Typed access to the depots.
---@return ltn.TrainStop[][]
function Tools.getDepots()
    return assert(storage.Depots)
end

-----------------------------------------------------------------------
-- print messages
-----------------------------------------------------------------------

---@type PrintSettings
local settings = {
    sound = defines.print_sound.use_player_settings,
    skip = defines.print_skip.if_visible,
}

---@alias msg_func fun():LocalisedString

--- write msg to console for all member of force or all players
---@param level number
---@param msg_func msg_func
---@param force LuaForce?
function Tools.printmsg(level, msg_func, force)
    if LtnSettings and ((not LtnSettings.message_level) or (LtnSettings.message_level < level)) then return end

    if force and force.valid then
        force.print(msg_func(), settings)
    else
        game.print(msg_func(), settings)
    end
end

-----------------------------------------------------------------------
-- logging
-----------------------------------------------------------------------

---@alias log_func fun():...

---@param level number
---@param name string
---@param msg string
---@param log_func log_func?
function Tools.log(level, name, msg, log_func)
    if LtnSettings and ((not LtnSettings.debug_log) or (LtnSettings.debug_log < level)) then return end
    log(('[LTN] (%s) [%d] - %s'):format(name, level, log_func and msg:format(log_func()) or msg))
end

-----------------------------------------------------------------------
-- Item Identifier management
-----------------------------------------------------------------------

--- Convert a Signal into a typed item string. If the quality is 'normal',
--- omit quality information
---@param signal SignalID
---@return ltn.ItemIdentifier
function Tools.createItemIdentifier(signal)
    assert(signal)
    return table.concat({
        signal.type or 'item',
        signal.name,
        signal.quality and signal.quality ~= 'normal' and signal.quality or nil
    }, ',')
end

--- Convert a ItemWithQualityCount into a typed item string
---@param item ItemWithQualityCount|SignalID
---@return ltn.ItemIdentifier
function Tools.createItemIdentifierFromItemWithQualityCount(item)
    assert(item)
    return Tools.createItemIdentifier {
        type = 'item',
        name = item.name,
        quality = item.quality
    }
end

--- Convert a fluid name into a typed item string
---@param fluid_name string
---@return ltn.ItemIdentifier
function Tools.createItemIdentifierFluidName(fluid_name)
    assert(fluid_name)
    return Tools.createItemIdentifier {
        type = 'fluid',
        name = fluid_name,
    }
end

---@param identifier ltn.ItemIdentifier
---@return SignalID? Guaranteed to have all fields filled.
function Tools.parseItemIdentifier(identifier)
    if not identifier then return nil end
    local type, name, quality = identifier:match('^([^,]+),([^,]+),?([^,]*)')

    if not name or #name == 0 then return nil end
    if not (prototypes.item[name] or prototypes.fluid[name]) then return nil end

    return {
        type = type or 'item',
        name = name,
        quality = (quality and #quality > 0) and quality or 'normal',
    }
end

---@param item_info SignalID
---@return string result
function Tools.prettyPrint(item_info)
    if item_info.type == 'item' then
        return string.format('[item=%s,quality=%s]', item_info.name, item_info.quality)
    else
        return string.format('[fluid=%s]', item_info.name, item_info.quality)
    end
end

--- Create backwards compatible loading list for API use.
---@param loadingList ltn.ItemLoadingElement[]
---@return ltn.LoadingList
function Tools.createLoadingList(loadingList)
    ---@type ltn.ItemLoadingElement[]
    local result = {}

    for _, element in pairs(loadingList) do
        table.insert(result, {
            name = element.item.name,
            type = element.item.type,
            quality = element.item.quality,
            count = element.count,
            localname = element.localname,
            stacks = element.stacks,
        })
    end
    return result
end

-----------------------------------------------------------------------
-- Locomotives and Wagons
-----------------------------------------------------------------------

--- Get the main locomotive in a given train. -- from flib
--- @param train LuaTrain
--- @return LuaEntity? locomotive The primary locomotive entity or `nil` when no locomotive was found
function Tools.getMainLocomotive(train)
    if not (train and train.valid) then return end
    return train.locomotives.front_movers and train.locomotives.front_movers[1] or train.locomotives.back_movers[1]
end

--- Get the backer_name of the main locomotive in a given train (which is the main train name). -- from flib
--- @param train LuaTrain
--- @return string? backer_name The backer_name of the primary locomotive or `nil` when no locomotive was found
function Tools.getTrainName(train)
    local loco = Tools.getMainLocomotive(train)
    return loco and loco.backer_name
end

--- Calculate the distance between two positions. -- from flib
--- @param pos1 MapPosition
--- @param pos2 MapPosition
--- @return number
function Tools.getDistance(pos1, pos2)
    local x1 = pos1.x or pos1[1]
    local y1 = pos1.y or pos1[2]
    local x2 = pos2.x or pos2[1]
    local y2 = pos2.y or pos2[2]
    return math.sqrt((x1 - x2) ^ 2 + (y1 - y2) ^ 2)
end

---@param wagon LuaEntity
---@param cap_function fun(): number?
local function get_wagon_capacity(wagon, cap_function)
    local name = wagon.name
    local quality = wagon.quality.name
    storage.WagonCapacity[name] = storage.WagonCapacity[name] or {}
    local capacity = storage.WagonCapacity[name][quality] or cap_function() or 0

    storage.WagonCapacity[name][quality] = capacity

    return capacity
end

---@param wagon LuaEntity
---@return number
function Tools.getCargoWagonCapacity(wagon)
    return get_wagon_capacity(wagon, function()
        return wagon.prototype.get_inventory_size(defines.inventory.cargo_wagon, wagon.quality)
    end)
end

---@param wagon LuaEntity
---@return number
function Tools.getFluidWagonCapacity(wagon)
    return get_wagon_capacity(wagon, function()
        local capacity = wagon.prototype.fluid_capacity
        return math.floor(capacity * (1 + 0.3 * wagon.quality.level))
    end)
end

-- returns inventory and fluid capacity of a given train
---@param train LuaTrain
---@return number inventorySize
---@return number fluidCapacity
function Tools.getTrainCapacity(train)
    local inventorySize = 0
    local fluidCapacity = 0
    if train and train.valid then
        for _, wagon in pairs(train.cargo_wagons) do
            local capacity = Tools.getCargoWagonCapacity(wagon)
            inventorySize = inventorySize + capacity
        end
        for _, wagon in pairs(train.fluid_wagons) do
            local capacity = Tools.getFluidWagonCapacity(wagon)
            fluidCapacity = fluidCapacity + capacity
        end
    end
    return inventorySize, fluidCapacity
end

-- returns rich text string for train stops, or nil if entity is invalid
---@param entity LuaEntity
---@return string?
function Tools.richTextForStop(entity)
    if not (entity and entity.valid) then return nil end

    if LtnSettings.message_include_gps then
        return string.format('[train-stop=%d] [gps=%s,%s,%s]', entity.unit_number, entity.position['x'], entity.position['y'], entity.surface.name)
    else
        return string.format('[train-stop=%d]', entity.unit_number)
    end
end

---@param train LuaTrain
---@param train_name string?
function Tools.richTextForTrain(train, train_name)
    local loco = Tools.getMainLocomotive(train)
    if loco and loco.valid then
        return string.format('[train=%d] %s', train.id, train_name or loco.backer_name)
    else
        return string.format('[train=%d] %s', train.id, train_name)
    end
end

-----------------------------------------------------------------------
-- Validation
-----------------------------------------------------------------------

--- Returns True if the stop exists, its main entity is valid and has a rail connected.
--- This is good enough to e.g. determine whether a stop can be used in schedule (delivery, fuel station, depot)
---@param stop (ltn.TrainStop|LuaEntity)?
---@return boolean is_valid
function Tools.isStopValid(stop)
    if not stop then return false end
    local entity = type(stop) == 'userdata' and stop or stop.entity
    return entity.valid and entity.connected_rail and entity.connected_rail.valid and true or false
end

--- Returns True if the internal state of the train stop is consistent. Checks that all internal entities are
--- valid and functioning.
---@param stop ltn.TrainStop
---@return boolean is_consistent
function Tools.isStopConsistent(stop)
    assert(stop)
    return (stop.entity and stop.entity.valid)
        and (stop.input and stop.input.valid)
        and (stop.output and stop.output.valid)
        and (stop.lamp_control and stop.lamp_control.valid)
end

-----------------------------------------------------------------------
-- Train capacity management
-----------------------------------------------------------------------

---@param trainId number?
---@return boolean True if capacity was really reduced
function Tools.reduceAvailableCapacity(trainId)
    if not trainId then return false end

    local dispatcher = Tools.getDispatcher()

    if not dispatcher.availableTrains[trainId] then return false end

    dispatcher.knownTrains[trainId] = dispatcher.knownTrains[trainId] or {
        train = dispatcher.availableTrains[trainId].train,
        select_count = 0,
    }

    dispatcher.availableTrains_total_capacity = dispatcher.availableTrains_total_capacity - dispatcher.availableTrains[trainId].capacity
    dispatcher.availableTrains_total_fluid_capacity = dispatcher.availableTrains_total_fluid_capacity - dispatcher.availableTrains[trainId].fluid_capacity
    dispatcher.availableTrains[trainId] = nil

    return true
end

---@param train LuaTrain
---@param stop ltn.TrainStop
---@return boolean True if capacity was really increased
function Tools.increaseAvailableCapacity(train, stop)
    local dispatcher = Tools.getDispatcher()

    if dispatcher.availableTrains[train.id] then return false end

    ---@type LuaEntity?
    local loco = Tools.getMainLocomotive(train)
    ---@type LuaForce?
    local trainForce = loco and loco.force
    assert(trainForce)

    local capacity, fluid_capacity = Tools.getTrainCapacity(train)

    dispatcher.knownTrains[train.id] = dispatcher.knownTrains[train.id] or {
        train = train,
        select_count = 0,
    }

    dispatcher.availableTrains[train.id] = {
        train = train,
        surface = stop.entity.surface,
        force = trainForce,
        depot_priority = stop.depot_priority,
        network_id = stop.network_id,
        capacity = capacity,
        fluid_capacity = fluid_capacity,
        select_count = dispatcher.knownTrains[train.id].select_count,
    }

    dispatcher.availableTrains_total_capacity = dispatcher.availableTrains_total_capacity + capacity
    dispatcher.availableTrains_total_fluid_capacity = dispatcher.availableTrains_total_fluid_capacity + fluid_capacity

    return true
end

---@param train_id integer
---@return ltn.Train? The train information if the train is available
function Tools.isTrainAvailable(train_id)
    local dispatcher = Tools.getDispatcher()
    return dispatcher.availableTrains[train_id]
end

--- @param old_train_id integer? old train id
--- @param new_train LuaTrain? new train object
--- @return boolean success
function Tools.reassignTrainRecord(old_train_id, new_train)
    local dispatcher = Tools.getDispatcher()

    if not old_train_id or not (new_train and new_train.valid) then return false end

    dispatcher.knownTrains[new_train.id] = dispatcher.knownTrains[new_train.id] or {
        train = new_train,
        select_count = 0
    }

    if dispatcher.knownTrains[old_train_id] and dispatcher.knownTrains[old_train_id].select_count then
        dispatcher.knownTrains[new_train.id].select_count = dispatcher.knownTrains[new_train.id]. select_count + dispatcher.knownTrains[old_train_id].select_count
    end

    return true
end

-----------------------------------------------------------------------
-- Stop List management
-----------------------------------------------------------------------

---@param stop ltn.TrainStop
---@param stop_list ltn.TrainStop[]
---@param network_id integer
function Tools.updateStopList(stop, stop_list, network_id)
    for i = 1, 32 do
        local stops = stop_list[i] or {}
        local in_network = bit32.btest(network_id, bit32.lshift(1, i - 1))
        stops[stop.entity.unit_number] = in_network and stop or nil
        stop_list[i] = stops
    end
end

--- Find all stations in the stop list that are a match for the given network id.
---@param stop_list ltn.TrainStop[]
---@param network_id integer
---@param available boolean? If true, only available stops are returned
---@return ltn.TrainStop[] train_stops Available train stops
function Tools.findMatchingStops(stop_list, network_id, available)
    local all_stops = Tools.getAllStops()
    local result = {}

    for i = 1, 32 do
        if stop_list[i] and bit32.btest(network_id, bit32.lshift(1, i - 1)) then
            for stop_id in pairs(stop_list[i]) do
                -- check if the station id is still valid
                local stop = all_stops[stop_id]
                if Tools.isStopValid(stop) then
                    result[stop_id] = stop
                else
                    stop_list[i][stop_id] = nil
                end
            end
        end
    end

    return result
end

---@param stop_list ltn.TrainStop[][]
---@param stop_id integer
function Tools.removeStop(stop_list, stop_id)
    for i = 1, 32 do
        if stop_list[i] then stop_list[i][stop_id] = nil end
    end
end

-----------------------------------------------------------------------
-- Train Stop management
-----------------------------------------------------------------------

---@param stop ltn.TrainStop
---@return boolean disabled True if the stop is disabled
function Tools.updateTrainStopSettings(stop)
    assert(stop)
    if not (stop.entity and stop.entity.valid) then return true end

    local trainstop_control = assert(stop.entity.get_or_create_control_behavior()) --[[@as LuaTrainStopControlBehavior]]

    local state = GetStationType(stop)

    if state ~= station_type.depot or LtnSettings.depot_limit_trains ~= ltn_depot_train_limit.unchanged then
        -- enable reading contents and sending signals to trains
        trainstop_control.send_to_train = true
        trainstop_control.read_from_train = true

        trainstop_control.set_trains_limit = false
        trainstop_control.trains_limit_signal = nil
    end

    if state ~= station_type.depot or LtnSettings.depot_limit_trains == ltn_depot_train_limit.reset then
        stop.entity.trains_limit = nil
    elseif LtnSettings.depot_limit_trains == ltn_depot_train_limit.set_one then
        stop.entity.trains_limit = 1
    end

    return trainstop_control.disabled
end

-----------------------------------------------------------------------
-- Manage dispatcher ticker events
-----------------------------------------------------------------------

function Tools.updateDispatchTicker()
    local stops = Tools.getAllStops()
    if next(stops) then
        -- bring up dispatcher and Train State ticker
        script.on_nth_tick(LtnSettings.dispatcher_nth_tick, OnTick)
        script.on_event(defines.events.on_train_changed_state, OnTrainStateChanged)
        script.on_event(defines.events.on_train_created, OnTrainCreated)
    else
        script.on_nth_tick(nil)
        script.on_event(defines.events.on_train_changed_state, nil)
        script.on_event(defines.events.on_train_created, nil)
    end
end

return Tools
