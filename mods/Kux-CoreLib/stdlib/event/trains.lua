--- Tools for working with trains.
-- When this module is loaded into a mod, it automatically registers a number of new events in order to keep track of
-- the trains as their locomotives and wagons are moved around.
-- <p>To handle the events, you should use the @{Event} module.
--- @class StdLib.Event.Trains
local Trains = {
    __class = 'Trains',
    __index = require('__Kux-CoreLib__/stdlib/core')
}
setmetatable(Trains, Trains)

local Event = require('__Kux-CoreLib__/stdlib/event/event')
local Surface = require('__Kux-CoreLib__/stdlib/area/surface')--[[@as StdLib.Area.Surface]]
local Entity = require('__Kux-CoreLib__/stdlib/entity/entity')
local table = require('__Kux-CoreLib__/stdlib/utils/table') --[[@as StdLib.Utils.Table]]

--- This event fires when a train's ID changes.
-- <p>The train ID is a property of the main locomotive,
-- which means that when locomotives are attached or detached from their wagons or from other locomotives, the ID of the train changes.
-- <p>For example: A train with a front and rear locomotives will get its ID
-- from the front locomotive. If the front locomotive gets disconnected, the rear locomotive becomes the main one and the train's ID changes.
-- @event on_train_id_changed
-- @param old_id uint the ID of the train before the change
-- @param new_id uint the ID of the train after the change
-- @usage
-- Event.register(Trains.on_train_id_changed, my_handler)
Trains.on_train_id_changed = Event.generate_event_name()

--- Given a @{criteria|search criteria}, search for trains that match the criteria.
-- If ***criteria.surface*** is not supplied, this function searches through all existing surfaces.
-- If ***criteria.force*** is not supplied, this function searches through all existing forces.
-- If ***criteria.state*** is not supplied, this function gets trains in any @{defines.train_state|state}.
--- @param criteria StdLib.Event.Trains.criteria? a table used to search for trains
-- @return (<span class="types">{@{train_details},...}</span>) an array of train IDs and LuaTrain instances
-- @usage
-- Trains.find_filtered({ surface = "nauvis", state = defines.train_state.wait_station })
function Trains.find_filtered(criteria) --Factorio 2.0 compatible
	criteria = criteria or {}
    local filter = table.deepcopy(criteria)
	filter.state = nil

    local results = {}
	local trains = game.train_manager.get_trains(filter)
	for _, train in pairs(trains) do
		table.insert(results, train)
	end

    -- Apply state filters
    if criteria.state then
        results =
        table.filter(
            results,
			---@param train LuaTrain
			---@return boolean
            function(train)
                return train.state == criteria.state
            end
        )
    end

    -- Lastly, look up the train ids
    results =
    table.map(
        results,
        function(train)
            return { train = train, id = Trains.get_main_locomotive(train).unit_number }
        end
    )

    return results
end

---
-- This table should be passed into @{find_filtered} to find trains that match the criteria.
--- @class StdLib.Event.Trains.criteria : TrainFilter
--- @field state nil|defines.train_state  [opt] the state of the trains to search


--- {find_filtered} returns an array with one or more of ***this*** table based on the @{criteria|search criteria}.
--- @class StdLib.Event.Trains.train_details
--- @field train LuaTrain an instance of the train
--- @field id uint the ID of the train


--- Find the ID of a LuaTrain instance.
--- @param train LuaTrain
--- @return uint? #the ID of the train
function Trains.get_train_id(train)
    local loco = Trains.get_main_locomotive(train)
    return loco and loco.unit_number
end

--- Event fired when some change happens to a locomotive.
-- @lfunction
function Trains._on_locomotive_changed()
    -- For all the known trains
    local renames = {}
    for id, train in pairs(storage._train_registry) do
        -- Check if their known ID is the same as the LuaTrain's dervied id
        local derived_id = Trains.get_train_id(train)
        -- If it's not
        if (id ~= derived_id) then
            -- Capture the rename
            table.insert(renames, { old_id = id, new_id = derived_id, train = train })
        end
    end

    -- Go over the captured renaming operations
    for _, renaming in pairs(renames) do
        -- Rename it in the registry
        -- and dispatch a renamed event
        storage._train_registry[renaming.new_id] = renaming.train
        storage._train_registry[renaming.old_id] = nil

        local event_data = {
            old_id = renaming.old_id,
            new_id = renaming.new_id,
            name = Trains.on_train_id_changed
        }
        Event.dispatch(event_data)
    end
end

--- Get the main locomotive of a train.
--- @param train LuaTrain
--- @return LuaEntity? #the main locomotive
function Trains.get_main_locomotive(train)
    if train and train.valid and train.locomotives and (#train.locomotives.front_movers > 0 or #train.locomotives.back_movers > 0) then
        return train.locomotives.front_movers and train.locomotives.front_movers[1] or train.locomotives.back_movers[1]
    end
end

--- Creates an entity from a train that is compatible with the @{Entity.Entity} module.
--- @param train LuaTrain
-- @return (<span class="types">@{train_entity}</span>)
function Trains.to_entity(train)
    local name = 'train-' .. Trains.get_train_id(train)
    return {
        name = name,
        valid = train.valid,
        equals = function(entity)
            return name == entity.name
        end
    }
end

------
-- @{to_entity} returns ***this*** table.
-- @tfield string name the name of the train entity with the train ID as its suffix
-- @tfield boolean valid whether or not if the train is in a valid state in the game
-- @tfield function equals &mdash; *function(entity)* &mdash; a function to check if another entity is equal to the train that ***this*** table represents
-- @table train_entity

--- Associates the user data to a train.
-- This is a helper around @{Entity.Entity.set_data}.
-- <p>The user data will be stored in the storage object and it will persist between loads.
--> The user data will be removed from a train when the train becomes invalid.
--- @param train LuaTrain the train to set the user data for
--- @param data any? the user data to set, or nil to delete the user data associated with the train
--- @return any? #the previous user data or nil if the train had no previous user data
function Trains.set_data(train, data)
    return Entity.set_data(Trains.to_entity(train), data)
end

--- Gets the user data that is associated with a train.
-- This is a helper around @{Entity.Entity.get_data}.
-- <p>The user data is stored in the storage object and it persists between loads.
--> The user data will be removed from a train when the train becomes invalid.
--- @param train LuaTrain the train to look up user data for
--- @return any? #the user data, or nil if no user data exists for the train
function Trains.get_data(train)
    return Entity.get_data(Trains.to_entity(train))
end

-- Creates a registry of known trains.
-- @return table a mapping of train id to LuaTrain object
function Trains.create_train_registry()
    storage._train_registry = storage._train_registry or {}

    local all_trains = Trains.find_filtered()
    for _, trainInfo in pairs(all_trains) do
        storage._train_registry[tonumber(trainInfo.id)] = trainInfo.train
    end

    return storage._train_registry
end

function Trains.on_train_created(event)
    local train_id = Trains.get_train_id(event.train) or error("unexpected")
    storage._train_registry[train_id] = event.train
end

--- This needs to be called to register events for this module
--- @return StdLib.Event.Trains
function Trains.register_events()
    -- When a locomotive is removed ...
    local train_remove_events = { defines.events.on_entity_died, defines.events.on_pre_player_mined_item, defines.events.on_robot_pre_mined }
    Event.register(train_remove_events, Trains._on_locomotive_changed, Event.Filters.entity.type, 'locomotive')

    -- When a locomotive is added ...
    Event.register(defines.events.on_train_created, Trains.on_train_created)

    -- When the mod is initialized the first time
    Event.register(Event.core_events.init_and_config, Trains.create_train_registry)
    return Trains
end

return Trains
