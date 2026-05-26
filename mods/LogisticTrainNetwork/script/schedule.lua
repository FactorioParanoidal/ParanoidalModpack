-----------------------------------------------------------------------
-- Manage all schedule related things
-----------------------------------------------------------------------

local util = require('util')
local tools = require('script.tools')

---@class ltn.ScheduleManager
local ScheduleManager = {}

---@class ltn.Record : SignalID
---@field provider boolean
---@field requester boolean
---@field count number

---@param wait_conditions WaitCondition[]
---@return table<string, ltn.Record>
function ScheduleManager:analyzeRecord(wait_conditions)
    local result = {}
    for _, wait_condition in pairs(wait_conditions) do
        if (wait_condition.type == 'item_count' or wait_condition.type == 'fluid_count') and wait_condition.condition and wait_condition.condition.first_signal then
            local record = {
                name = wait_condition.condition.first_signal.name,
                type = wait_condition.condition.first_signal.type or 'item',
                quality = wait_condition.condition.first_signal.quality or 'normal',
                provider = wait_condition.condition.comparator == '≥',
                requester = (wait_condition.condition.comparator == '=' and wait_condition.condition.constant == 0),
                count = (wait_condition.condition.constant or 0)
            }
            assert(record.name)

            if record.provider or record.requester then
                local key = tools.createItemIdentifier(record)
                result[key] = record
            else
                tools.printmsg(1, function()
                    return { 'ltn-message.error-invalid-schedule-record', record.name, record.type, record.count }
                end)

                tools.log(1, 'analyzeRecord', 'Invalid Schedule Record: %s / %s / %d', function()
                    return record.name, record.type, record.count
                end)
            end
        end
    end
    return result
end

---@param train LuaTrain
---@param inventory ltn.InventoryType
---@param fluidInventory ltn.FluidInventoryType
function ScheduleManager:updateFromSchedule(train, inventory, fluidInventory)
    local train_schedule = train.get_schedule()
    local wait_conditions = train_schedule.get_wait_conditions { schedule_index = train_schedule.current }
    if not wait_conditions then return end

    local results = self:analyzeRecord(wait_conditions)

    for _, result in pairs(results) do
        if result.type == 'item' then
            if result.provider then
                inventory[result.name] = inventory[result.name] or {
                    name = result.name,
                    quality = result.quality,
                    count = 0,
                }

                inventory[result.name].count = (inventory[result.name].count or 0) + result.count
            else
                inventory[result.name] = nil
            end
        elseif result.type == 'fluid' then
            if result.provider then
                fluidInventory[result.name] = (fluidInventory[result.name] or 0) + (result.count or 0)
            else
                fluidInventory[result.name] = -1 -- this makes no sense. This should be nil but it is -1 ever since 1.10.x
            end
        end
    end
end

---@param train_schedule LuaSchedule
---@return ScheduleRecord? depot_record
---@return integer? depot_record_index
local function find_depot_record(train_schedule)
    for i = 1, train_schedule.get_record_count(), 1 do
        local record = train_schedule.get_record { schedule_index = i }
        assert(record)
        -- return first non-temporary stop.
        if not record.temporary then return record, i end

        tools.log(1, 'find_depot_record', 'Skipping temporary stop %s when selecting depot for train %s (%d)', function()
            return record.station, tools.getTrainName(train_schedule.owner), train_schedule.owner.id
        end)
    end

    tools.log(1, 'find_depot_record', 'Could not locate a depot stop in schedule (stops: %s) for train %s (%d)', function()
        return serpent.line(train_schedule.get_records()), tools.getTrainName(train_schedule.owner), train_schedule.owner.id
    end)

    return nil, nil
end


--- Selects a depot to send the train to.
---@param train LuaTrain
---@param network_id integer
---@return ltn.TrainStop? train_stop A depot train stop
function ScheduleManager:selectDepot(train, network_id)
    local all_depots = tools.findMatchingStops(tools.getDepots(), network_id)
    if table_size(all_depots) == 0 then return nil end

    if not LtnSettings.reselect_depot then
        local depot_record = find_depot_record(train.get_schedule())
        if depot_record and depot_record.station then
            for _, depot in pairs(all_depots) do
                if depot.entity.backer_name == depot_record.station then return depot end
            end
        end
    end

    tools.log(1, 'ScheduleManager:selectDepot', 'Reselecting depot for train %s (%d)', function()
        return tools.getTrainName(train), train.id
    end)

    -- no depot found / reselection requested

    ---@type LuaEntity[]
    local depots = {}
    for _, depot in pairs(all_depots) do
        table.insert(depots, depot.entity)
    end

    if table_size(depots) == 0 then
        tools.log(1, 'ScheduleManager:selectDepot', 'No valid depot for train %s (%d) found!', function()
            return tools.getTrainName(train), train.id
        end)
        return nil
    end

    local path_results = game.train_manager.request_train_path {
        type = 'all-goals-accessible',
        train = train,
        goals = depots,
    }

    if path_results.amount_accessible == 0 then
        tools.log(1, 'ScheduleManager:selectDepot', 'No accessible depot for train %s (%d) found!', function()
            return tools.getTrainName(train), train.id
        end)
        return nil
    end

    local all_stops = tools.getAllStops()

    ---@type ltn.TrainStop[]
    local accessible_stations = {}

    for idx, accessible in pairs(path_results.accessible) do
        if accessible and tools.isStopValid(all_stops[depots[idx].unit_number]) then
            table.insert(accessible_stations, all_stops[depots[idx].unit_number])
        end
    end

    local depot = accessible_stations[math.random(#accessible_stations)]
    tools.log(1, 'ScheduleManager:selectDepot', 'Selected %s as depot for train %s (%d)', function()
        return depot.entity.backer_name, tools.getTrainName(train), train.id
    end)

    return depot
end

--- Selects a fuel station that is appropriate to refuel this train.
---@param train LuaTrain
---@param network_id integer
---@return ltn.TrainStop? train_stop A fuel station train stop
function ScheduleManager:selectFuelStation(train, network_id)
    local all_fuel_stations = tools.findMatchingStops(tools.getFuelStations(), network_id)
    if table_size(all_fuel_stations) == 0 then return nil end

    ---@type LuaEntity[]
    local stations = {}
    for _, station in pairs(all_fuel_stations) do
        assert(station.fuel_signals)
        if #station.fuel_signals > 0 then -- must provide some threshold signal
            table.insert(stations, station.entity)
        end
    end

    if #stations == 0 then return nil end

    ---@type TrainPathFinderOneGoalResult
    local path_results = game.train_manager.request_train_path {
        type = 'any-goal-accessible',
        train = train,
        goals = stations,
    }

    if not path_results.found_path then return nil end

    local all_stops = tools.getAllStops()
    local fuel_station = all_stops[stations[path_results.goal_index].unit_number]
    return tools.isStopValid(fuel_station) and fuel_station or nil
end

---@param train LuaTrain
function ScheduleManager:resetInterrupts(train)
    if not LtnSettings.reset_interrupts then return end

    local train_schedule = train.get_schedule()

    if not (LtnSettings.enable_fuel_stations and LtnSettings.use_fuel_station_interrupt) then
        train_schedule.clear_interrupts()
    else
        for i = train_schedule.interrupt_count, 1, -1 do
            local interrupt = train_schedule.get_interrupt(i)
            if interrupt and interrupt.name ~= LTN_INTERRUPT_NAME then
                train_schedule.remove_interrupt(i)
            end
        end
    end
end

---@param train_schedule LuaSchedule
---@param name string
---@return integer?
local function find_interrupt_index(train_schedule, name)
    for i = 1, train_schedule.interrupt_count do
        local interrupt = train_schedule.get_interrupt(i)
        if interrupt and interrupt.name == name then return i end
    end
    return nil
end

---@param train LuaTrain
function ScheduleManager:removeFuelInterrupt(train)
    assert(train and train.valid)

    -- unconditionally remove fuel interrupt. Do not add a check for use_fuel_interrupt,
    -- otherwise the interrupt will never get removed when switching to dynamic refueling
    local train_schedule = train.get_schedule()
    local interrupt_index = find_interrupt_index(train_schedule, LTN_INTERRUPT_NAME)
    if interrupt_index then train_schedule.remove_interrupt(interrupt_index) end
end

--- Checks whether any of the movers needs refueling based on the fuel provided by the
--- fuel station.
---@param train LuaTrain
---@param fuel_signals CircuitCondition[]
---@return boolean
local function must_refuel(train, fuel_signals)
    ---@type table<string, LuaEntity[]>
    local locomotives = train.locomotives
    for _, movers in pairs(locomotives) do
        for _, locomotive in pairs(movers) do
            ---@type table<string, number>
            local fuel = {}
            local fuelInventory = locomotive.get_fuel_inventory()
            if fuelInventory then
                for _, item in pairs(fuelInventory.get_contents()) do
                    local key = tools.createItemIdentifierFromItemWithQualityCount(item)
                    fuel[key] = (fuel[key] or 0) + item.count
                end
            end
            for _, fuel_signal in pairs(fuel_signals) do
                assert(fuel_signal.constant)
                local key = tools.createItemIdentifierFromItemWithQualityCount(fuel_signal.first_signal)
                if fuel[key] and fuel[key] < fuel_signal.constant then return true end
            end
        end
    end

    return false
end

---@param train LuaTrain
---@param fuel_station ltn.TrainStop
---@return boolean
local function check_for_stop_in_schedule(train, fuel_station)
    local schedule = train.get_schedule()
    local records = schedule.get_records()

    if not records then return false end

    for _, record in pairs(records) do
        if record.station == fuel_station.entity.backer_name then return true end
    end

    return false
end

--- Check if the train needs to be refueled and if necessary, create a dynamic refuel stop
--- in the schedule.
---@param train LuaTrain
---@param fuel_station ltn.TrainStop
function ScheduleManager:scheduleDynamicRefueling(train, fuel_station)
    if LtnSettings.use_fuel_station_interrupt then return end
    assert(fuel_station.fuel_signals)

    if (must_refuel(train, fuel_station.fuel_signals)) then
        local schedule = train.get_schedule()
        local records = schedule.get_records()
        -- need a schedule
        if not records then return end
        -- already in the schedule
        if check_for_stop_in_schedule(train, fuel_station) then return end

        local current_stop = records[schedule.current]
        -- do not schedule right after a temp stop
        if current_stop.temporary then return end
        schedule.add_record {
            station = fuel_station.entity.backer_name,
            wait_conditions = {
                {
                    type = 'inactivity',
                    ticks = 120,
                },
                {
                    type = 'fuel_full',
                    compare_type = 'or',
                },

            },
            temporary = true,
            allows_unloading = false,
            index = {
                schedule_index = schedule.current + 1,
            }
        }
    end
end

---@param train LuaTrain
---@param network_id integer
function ScheduleManager:updateRefuelSchedule(train, network_id)
    local fuel_station = self:selectFuelStation(train, network_id)

    if not (LtnSettings.enable_fuel_stations and fuel_station) then
        -- no fuel station in the network
        self:removeFuelInterrupt(train)
        return
    end

    assert(fuel_station.fuel_signals)

    if not LtnSettings.use_fuel_station_interrupt then
        -- Do not use interrupt, use dynamic fuel scheduling
        self:removeFuelInterrupt(train)
        self:scheduleDynamicRefueling(train, fuel_station)
        return
    end

    ---@type WaitCondition[]
    local interrupt_conditions = {}

    for _, circuit_condition in pairs(fuel_station.fuel_signals) do
        table.insert(interrupt_conditions, {
            type = 'fuel_item_count_any',
            condition = util.copy(circuit_condition),
            compare_type = 'or',
        })
        table.insert(interrupt_conditions, {
            type = 'fuel_item_count_any',
            condition = {
                comparator = '>',
                first_signal = util.copy(circuit_condition.first_signal),
                constant = 0,
            },
            compare_type = 'and',
        })
    end

    ---@type ScheduleInterrupt
    local schedule_interrupt = {
        name = LTN_INTERRUPT_NAME,
        inside_interrupt = false,
        conditions = interrupt_conditions,
        targets = {
            {
                station = fuel_station.entity.backer_name,
                wait_conditions = {
                    {
                        type = 'inactivity',
                        ticks = 120,
                    },
                    {
                        type = 'fuel_full',
                        compare_type = 'or',
                    },

                },
                temporary = true,
                allows_unloading = false,
            }
        }
    }

    local train_schedule = train.get_schedule()
    local interrupt_index = find_interrupt_index(train_schedule, LTN_INTERRUPT_NAME)

    if interrupt_index then
        train_schedule.change_interrupt(interrupt_index, schedule_interrupt)
    else
        train_schedule.add_interrupt(schedule_interrupt)
    end
end

--- Reset the train schedule to get ready for the next delivery.
--- This moves the depot into the first position, retains potential temporary stops
--- and reorganizes the schedule to be depot - (temp) - provider - (temp) - requester
---@param train LuaTrain
---@param depot_stop ltn.TrainStop?
---@param force_reset boolean? If false, only reset schedule when the current schedule is empty
function ScheduleManager:resetSchedule(train, depot_stop, force_reset)
    local train_schedule = train.get_schedule()
    local records = train_schedule.get_records() or {}

    -- if the schedule should not be reset and there are stops on the schedule, do nothing
    if not force_reset and #records > 0 then return end

    -- remove train from train group before modifying the schedule
    train.group = ''

    if not depot_stop then
        tools.log(1, 'ScheduleManager:resetSchedule', 'Schedule reset without a depot for train %s (%d)', function()
            return tools.getTrainName(train), train.id
        end)

        train_schedule.clear_records()
        train_schedule.clear_interrupts()

        local loco = tools.getMainLocomotive(train)

        if loco then create_alert(loco, 'depot-warning', { 'ltn-message.warning-no-depot-found', loco.backer_name }, loco.force) end
        return
    end

    if #records > 0 then
        for index = #records, 1, -1 do
            -- remove all stops that are not the depot stop or any temporary stops
            if not (records[index].temporary or records[index].station == depot_stop.entity.backer_name) then
                train_schedule.remove_record { schedule_index = index }
            end
        end

        -- find the depot stop in the new schedule
        local depot_record, depot_record_index = find_depot_record(train_schedule)

        -- If the stop is the expected depot, do not modify the schedule further
        -- otherwise, the schedule is invalid enough that other mods will not receive a
        -- on_train_state_changed with train.state == wait_station event which may throw
        -- other mods off -- see https://forums.factorio.com/viewtopic.php?t=130803
        if depot_record and depot_record.station == depot_stop.entity.backer_name then
            if #depot_record.wait_conditions > 0 then return end
            -- the train was just sent into the depot and the schedule record does not yet have the right wait condition.
            -- use the worst API on LuaSchedule to add one
            train_schedule.add_wait_condition({ schedule_index = depot_record_index }, 1, 'inactivity')
            train_schedule.change_wait_condition({ schedule_index = depot_record_index }, 1, {
                type = 'inactivity',
                ticks = LtnSettings.depot_inactivity,
            })
            return
        end

        tools.log(1, 'ScheduleManager:resetSchedule', 'Unexpected depot stop %s (expected %s) for train %s (%d)', function()
            return depot_record and depot_record.station or '<unknown>', depot_stop.entity.backer_name, tools.getTrainName(train), train.id
        end)

        train_schedule.clear_records()
    end

    -- schedule was either empty or the depot stop was not the right stop: add a new depot stop
    train_schedule.add_record {
        station = depot_stop.entity.backer_name,
        temporary = false,
        allows_unloading = true,
        wait_conditions = {
            {
                type = 'inactivity',
                ticks = LtnSettings.depot_inactivity,
            },
        },
        index = {
            schedule_index = 1,
        },
    }

    tools.log(1, 'ScheduleManager:resetSchedule', 'Added depot stop %s for train %s (%d)', function()
        return depot_stop.entity.backer_name, tools.getTrainName(train), train.id
    end)
end

---@param train LuaTrain
---@param rail LuaEntity
---@param rail_direction defines.rail_direction
---@param stop_schedule_index integer?
function ScheduleManager:temporaryStop(train, rail, rail_direction, stop_schedule_index)

    if not (train.carriages[1] and train.carriages[1].valid) then return nil end
    if train.carriages[1].surface_index ~= rail.surface_index then return nil end

    local train_schedule = train.get_schedule()

    train_schedule.add_record {
        index = stop_schedule_index and { schedule_index = stop_schedule_index, },
        temporary = true,
        rail = rail,
        rail_direction = rail_direction,
        allows_unloading = false,
        wait_conditions = {
            {
                type = 'time',
                ticks = 0,
            }
        },
    }
end

---@type WaitCondition
local RED_SIGNAL_CONDITION = {
    compare_type = 'and',
    type = 'circuit',
    condition = {
        comparator = '=',
        first_signal = {
            type = 'virtual',
            name = 'signal-red',
            quality = 'normal',
        },
        constant = 0,
    }
}

local GREEN_SIGNAL_CONDITION = {
    compare_type = 'or',
    type = 'circuit',
    condition = {
        comparator = '>=',
        first_signal = {
            type = 'virtual',
            name = 'signal-green',
            quality = 'normal',
        },
        constant = 1,
    }
}

local INACTIVITY_CONDITION = {
    compare_type = 'and',
    type = 'inactivity',
    ticks = 120,
}

---@param wait_conditions WaitCondition[]
function ScheduleManager:addControlSignals(wait_conditions)
    if LtnSettings.finish_loading then
        table.insert(wait_conditions, INACTIVITY_CONDITION)
    end

    -- with circuit control enabled keep trains waiting until red = 0 and force them out with green ≥ 1
    if LtnSettings.schedule_cc then
        table.insert(wait_conditions, RED_SIGNAL_CONDITION)
        table.insert(wait_conditions, GREEN_SIGNAL_CONDITION)
    end

    if LtnSettings.stop_timeout > 0 then -- send stuck trains away when stop_timeout is set
        table.insert(wait_conditions, { compare_type = 'or', type = 'time', ticks = LtnSettings.stop_timeout })
        -- should it also wait for red = 0?
        if LtnSettings.schedule_cc then
            table.insert(wait_conditions, RED_SIGNAL_CONDITION)
        end
    end
end

---@param train LuaTrain
---@param stop ltn.TrainStop
---@param loadingList ltn.ItemLoadingElement[]
function ScheduleManager:providerStop(train, stop, loadingList)
    local wait_conditions = {}

    for _, loadingElement in pairs(loadingList) do
        table.insert(wait_conditions, {
            compare_type = 'and',
            type = loadingElement.item.type == 'item' and 'item_count' or 'fluid_count',
            condition = {
                comparator = '>=',
                first_signal = loadingElement.item,
                constant = loadingElement.count,
            }
        })
    end

    self:addControlSignals(wait_conditions)

    local train_schedule = train.get_schedule()
    train_schedule.add_record {
        station = stop.entity.backer_name,
        temporary = false,
        allows_unloading = false,
        wait_conditions = wait_conditions,
    }
end

---@param train LuaTrain
---@param stop ltn.TrainStop
---@param loadingList ltn.ItemLoadingElement[]
function ScheduleManager:requesterStop(train, stop, loadingList)
    local wait_conditions = {}

    for _, loadingElement in pairs(loadingList) do
        table.insert(wait_conditions, {
            compare_type = 'and',
            type = loadingElement.item.type == 'item' and 'item_count' or 'fluid_count',
            condition = {
                comparator = '=',
                first_signal = loadingElement.item,
                constant = 0, -- since 1.1.0, fluids will only be 0 if empty (see https://wiki.factorio.com/Train_stop)
            }
        })
    end

    self:addControlSignals(wait_conditions)

    local train_schedule = train.get_schedule()
    train_schedule.add_record {
        station = stop.entity.backer_name,
        temporary = false,
        allows_unloading = true,
        wait_conditions = wait_conditions,
    }
end

---@param train LuaTrain
---@param index number
---@return string? stop_name
function ScheduleManager:getStopName(train, index)
    local train_schedule = train.get_schedule()
    local record = train_schedule.get_record { schedule_index = index }
    if not record then return nil end
    return record.station
end

---@param train LuaTrain
---@return boolean True if train has a schedule
function ScheduleManager:hasSchedule(train)
    local train_schedule = train.get_schedule()
    local record_count = train_schedule.get_record_count()
    return record_count and record_count > 0 or false
end

---@param train LuaTrain
---@return ScheduleRecord[] train_schedule Schedule records
---@return integer current
function ScheduleManager:getSchedule(train)
    local train_schedule = train.get_schedule()
    local records = train_schedule.get_records() or {}
    return records, train_schedule.current
end

return ScheduleManager
