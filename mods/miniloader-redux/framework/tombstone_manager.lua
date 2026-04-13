------------------------------------------------------------------------
-- Manages tombstone (configuration data after an entity has been removed)
--
-- Deals with:
--   - undo/redo
--      - undo construction will save config/tombstone information for redo
--      - redo destruction will save config/tombstone for undo
--   - entities dying
------------------------------------------------------------------------
assert(script)

local Is = require('stdlib.utils.is')
local Event = require('stdlib.event.event')

local Matchers = require('framework.matchers')
local tools = require('framework.tools')

local TICK_INTERVAL = 59             -- ~ tick about once  per second
local TOMBSTONES_PER_TICK = 60       -- max number of tombstones to process in a single tick
local LIFETIME_IN_TICKS = 60 * 86400 -- 24 hours

---@class framework.tombstone.State
---@field tombstones table<string, framework.tombstone.Tombstone>
---@field last_tick_index string?

---@alias framework.tombstone.UndoRedoAction fun(self: framework.tombstone_manager, action: UndoRedoAction.base)
---@alias framework.tombstone.CreateTombstoneCallback fun(entity: LuaEntity): table<string, any>, number?
---@alias framework.tombstone.ApplyTombstoneCallback fun(entity_data: table<string, any>, position: MapPosition, surface_index: number, name: string)

---@class framework.tombstone.TombstoneCallback
---@field create_tombstone framework.tombstone.CreateTombstoneCallback
---@field apply_tombstone framework.tombstone.ApplyTombstoneCallback

---@class framework.tombstone.Tombstone
---@field data table<string, any>
---@field tick number

---@class framework.tombstone_manager
---@field known_actions table<string, framework.tombstone.UndoRedoAction>
---@field callbacks table<string, framework.tombstone.TombstoneCallback>
local FrameworkTombstoneManager = {
    known_actions = {},
    callbacks = {}
}

---@return framework.tombstone.State state Manages undo/redo state
function FrameworkTombstoneManager:state()
    local state = Framework.runtime:storage()

    ---@type framework.tombstone.State
    state.tombstone_manager = state.tombstone_manager or {
        tombstones = {},
    }

    return state.tombstone_manager
end

------------------------------------------------------------------------

---@param entity LuaEntity?
function FrameworkTombstoneManager:createTombstoneFromEntity(entity)
    if not Is.Valid(entity) then return end
    assert(entity)

    local state = self:state()
    local key = tools:createEntityKeyFromEntity(entity)
    assert(key)

    local callback = self.callbacks[entity.name] or self.callbacks['*']
    if not callback then return end

    local entity_data = callback.create_tombstone(entity)
    if not entity_data then return end

    state.tombstones[key] = {
        data = entity_data,
        tick = game.tick
    }
end

---@param entity LuaEntity?
function FrameworkTombstoneManager:removeTombstoneForEntity(entity)
    if not (entity and entity.valid) then return end
    assert(entity)

    local state = self:state()
    local key = tools:createEntityKeyFromEntity(entity)
    if key then
        state.tombstones[key] = nil
        state.last_tick_index = nil -- reset the ticker
    end
end

--- Retrieves a tombstone based on a blueprint entity and surface index.
---@param blueprint_entity BlueprintEntity
---@param surface_index number
function FrameworkTombstoneManager:retrieveTombstoneFromBlueprintEntity(blueprint_entity, surface_index)
    local callback = self.callbacks[blueprint_entity.name] or self.callbacks['*']
    if not callback then return end

    local state = self:state()

    local key = tools:createEntityKeyFromBlueprintEntity(blueprint_entity, surface_index)
    if not state.tombstones[key] then return end

    local data = state.tombstones[key].data
    callback.apply_tombstone(data, blueprint_entity.position, surface_index, blueprint_entity.name)
end

--- Retrieves a tombstone based on an entity or ghost
---@param entity LuaEntity?
function FrameworkTombstoneManager:retrieveTombstoneFromEntity(entity)
    local name = tools:getName(entity)
    if not name then return end
    assert(entity)

    local callback = self.callbacks[name] or self.callbacks['*']
    if not callback then return end

    local state = self:state()

    local key = tools:createEntityKeyFromEntity(entity)
    assert(key)

    if not state.tombstones[key] then return end

    local data = state.tombstones[key].data
    callback.apply_tombstone(data, entity.position, entity.surface_index, name)
end

------------------------------------------------------------------------
-- Processed undo/redo actions
------------------------------------------------------------------------

function FrameworkTombstoneManager:removed_entity_action(action)
    self:retrieveTombstoneFromBlueprintEntity(action.target, action.surface_index)
end

FrameworkTombstoneManager.known_actions['removed-entity'] = FrameworkTombstoneManager.removed_entity_action

------------------------------------------------------------------------
-- Event callbacks
------------------------------------------------------------------------

---@param event EventData.on_undo_applied | EventData.on_redo_applied
local function process_undo_redo_event(event)
    local self = Framework.tombstone
    assert(self)

    for _, action in pairs(event.actions) do
        local method = self.known_actions[action.type]
        if method then method(self, action) end
    end
end

---@param event EventData.on_pre_player_mined_item | EventData.on_robot_pre_mined | EventData.on_space_platform_pre_mined | EventData.on_entity_died
local function register_tombstone(event)
    if not (event and event.entity) then return end

    Framework.tombstone:createTombstoneFromEntity(event.entity)
end

---@param event EventData.on_built_entity | EventData.on_robot_built_entity | EventData.on_space_platform_built_entity | EventData.script_raised_revive | EventData.script_raised_built
local function remove_tombstone(event)
    if not (event and event.entity) then return end

    Framework.tombstone:removeTombstoneForEntity(event.entity)
end

---@param event EventData.on_post_entity_died
local function find_tombstone(event)
    if not (event and event.ghost) then return end

    Framework.tombstone:retrieveTombstoneFromEntity(event.ghost)
end

--------------------------------------------------------------------------------
-- Registration API
--------------------------------------------------------------------------------

---@param matcher_function framework.event_matcher.MatcherFunction
---@return framework.event_matcher.MatchEventFunction
local function create_event_ghost_matcher(matcher_function)
    return function(event, context)
        if not event then return false end
        -- move / clone events
        return matcher_function(event.ghost, context) ---@diagnostic disable-line undefined-field
    end
end

---@param names string|string[]
---@param callback framework.tombstone.TombstoneCallback
function FrameworkTombstoneManager:registerCallback(names, callback)
    assert(names)
    if type(names) ~= 'table' then names = { names } end

    for _, name in pairs(names) do
        self.callbacks[name] = callback
    end

    local entity_filter = Matchers:matchEventEntityName(names)
    local ghost_filter = create_event_ghost_matcher(Matchers:createMatcherFunction(names, Matchers.GHOST_NAME_EXTRACTOR))

    Event.register(Matchers.CREATION_EVENTS, remove_tombstone, entity_filter)

    Event.register(Matchers.PRE_DELETION_EVENTS, register_tombstone, entity_filter)
    Event.register(defines.events.on_entity_died, register_tombstone, entity_filter)

    Event.register(defines.events.on_post_entity_died, find_tombstone, ghost_filter)
end

--------------------------------------------------------------------------------
-- ticker
--------------------------------------------------------------------------------

local function tick()
    local state = Framework.tombstone:state()
    local index = state.last_tick_index

    local process_count = math.min(table_size(state.tombstones), TOMBSTONES_PER_TICK)
    local expiration = game.tick - LIFETIME_IN_TICKS

    if process_count > 0 then
        local destroy_list = {}
        local tombstone
        repeat
            index, tombstone = next(state.tombstones, index)
            if tombstone and (tombstone.tick < expiration) then table.insert(destroy_list, index) end
            process_count = process_count - 1
        until process_count == 0 or not index

        if table_size(destroy_list) > 0 then
            for _, destroy_index in pairs(destroy_list) do
                state.tombstones[destroy_index] = nil
                -- if the last index was destroyed, reset the scan loop index
                if destroy_index == index then index = nil end
            end
        end
    else
        index = nil
    end

    state.last_tick_index = index
end

--------------------------------------------------------------------------------
-- event registration
--------------------------------------------------------------------------------

local function register_events()
    Event.register(defines.events.on_undo_applied, process_undo_redo_event)
    Event.register(defines.events.on_redo_applied, process_undo_redo_event)

    Event.register(-TICK_INTERVAL, tick)
end

Event.on_init(register_events)
Event.on_load(register_events)

return FrameworkTombstoneManager
