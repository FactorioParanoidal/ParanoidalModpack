------------------------------------------------------------------------
-- Manage all ghost state for robot building
------------------------------------------------------------------------
assert(script)

local Event = require('stdlib.event.event')
local Is = require('stdlib.utils.is')
local Position = require('stdlib.area.position')

local Matchers = require('framework.matchers')
local tools = require('framework.tools')

local TICK_INTERVAL = 61 -- run all 61 ticks
local ATTACHED_GHOST_LINGER_TIME = 600

---@alias framework.ghost_manager.RefreshCallback fun(entity: framework.ghost_manager.AttachedEntity, all_entities: framework.ghost_manager.AttachedEntity[]): framework.ghost_manager.AttachedEntity[]
---@alias framework.ghost_manager.GhostCallback fun(entity: framework.ghost_manager.AttachedEntity)

---@class framework.ghost_manager
---@field refresh_callbacks framework.ghost_manager.RefreshCallback[]
---@field ghost_callback framework.ghost_manager.GhostCallback?
local FrameworkGhostManager = {
    refresh_callbacks = {},
    ghost_callback = nil,
}

---@return framework.ghost_manager.State state Manages ghost state
function FrameworkGhostManager:state()
    local state = Framework.runtime:storage()

    ---@type framework.ghost_manager.State
    state.ghost_manager = state.ghost_manager or {
        ghost_entities = {},
    }

    return state.ghost_manager
end

---@param entity LuaEntity
---@param player_index integer?
function FrameworkGhostManager:registerGhost(entity, player_index)
    -- if an entity ghost was placed, register information to configure
    -- an entity if it is placed over the ghost

    local state = self:state()

    local attached_entity = {
        entity = entity,
        key = tools:createEntityKeyFromEntity(entity),
        tags = entity.tags,
        player_index = player_index,
        -- allow 10 seconds of lingering time until a refresh must have happened
        tick = game.tick + ATTACHED_GHOST_LINGER_TIME,
    }

    if self.ghost_callback then
        self.ghost_callback(attached_entity)
    end

    state.ghost_entities[entity.unit_number] = attached_entity
end

---@param unit_number integer
function FrameworkGhostManager:deleteGhost(unit_number)
    local state = self:state()
    state.ghost_entities[unit_number] = nil
end

---@param key framework.tools.EntityKey?
---@return framework.ghost_manager.AttachedEntity? ghost
function FrameworkGhostManager:findGhostForKey(key)
    if not key then return end

    local state = self:state()

    -- find a ghost that matches the entity
    for _, ghost in pairs(state.ghost_entities) do
        -- it provides the tags and player_index for robot builds
        if ghost.key == key then return ghost end
    end

    return nil
end

---@param entity LuaEntity
---@return framework.ghost_manager.AttachedEntity? ghost_entities
function FrameworkGhostManager:findGhostForEntity(entity)
    return self:findGhostForKey(tools:createEntityKeyFromEntity(entity))
end

---@param blueprint_entity BlueprintEntity
---@param surface_index number
---@return framework.ghost_manager.AttachedEntity? ghost_entities
function FrameworkGhostManager:findGhostForBlueprintEntity(blueprint_entity, surface_index)
    return self:findGhostForKey(tools:createEntityKeyFromBlueprintEntity(blueprint_entity, surface_index))
end

--- Find all ghosts within a given area. If a ghost is found, pass
--- it to the callback. If the callback returns a key, move the ghost
--- into the ghost_entities return array under the given key and remove
--- it from storage.
---
---@param area BoundingBox
---@param callback fun(ghost: framework.ghost_manager.AttachedEntity) : any?
---@return table<any, framework.ghost_manager.AttachedEntity> ghost_entities
function FrameworkGhostManager:findGhostsInArea(area, callback)
    local state = self:state()

    local ghosts = {}
    for idx, ghost in pairs(state.ghost_entities) do
        if ghost.entity and ghost.entity.valid then
            local pos = Position.new(ghost.entity.position)
            if pos:inside(area) then
                local key = callback(ghost)
                if key then
                    ghosts[key] = ghost
                    state.ghost_entities[idx] = nil
                end
            end
        end
    end

    return ghosts
end

--------------------------------------------------------------------------------
-- event callbacks
--------------------------------------------------------------------------------

---@param event EventData.on_built_entity | EventData.on_robot_built_entity | EventData.on_space_platform_built_entity | EventData.script_raised_revive | EventData.script_raised_built
local function on_ghost_entity_created(event)
    local entity = event and event.entity
    if not Is.Valid(entity) then return end

    script.register_on_object_destroyed(entity)

    Framework.ghost_manager:registerGhost(entity, event.player_index)
end

---@param event EventData.on_post_entity_died
local function on_post_entity_died(event)
    local entity = event and event.ghost
    if not Is.Valid(entity) then return end

    script.register_on_object_destroyed(entity)

    Framework.ghost_manager:registerGhost(entity)
end

---@param event EventData.on_object_destroyed
local function on_object_destroyed(event)
    Framework.ghost_manager:deleteGhost(event.useful_id)
end

--------------------------------------------------------------------------------
-- ticker
--------------------------------------------------------------------------------

local function tick()
    local self = Framework.ghost_manager
    assert(self)

    local state = self:state()

    local all_ghosts = state.ghost_entities --[[@as framework.ghost_manager.AttachedEntity[] ]]

    if table_size(all_ghosts) == 0 then return end

    for id, ghost_entity in pairs(all_ghosts) do
        if ghost_entity.entity and ghost_entity.entity.valid then
            local callback = self.refresh_callbacks[ghost_entity.entity.ghost_name]
            if callback then
                local entities = callback(ghost_entity, all_ghosts)
                for _, entity in pairs(entities) do
                    entity.tick = game.tick + ATTACHED_GHOST_LINGER_TIME -- refresh
                end
            end
        else
            self:deleteGhost(id)
        end
    end

    -- remove stale ghost entities
    for id, ghost_entity in pairs(all_ghosts) do
        if ghost_entity.tick < game.tick then
            self:deleteGhost(id)
        end
    end
end

--------------------------------------------------------------------------------
-- public API
--------------------------------------------------------------------------------

--- Registers a name as a managed ghost. Those are available e.g. for construction to
--- retrieve tags. This also supports undo/redo passing tags to ghosts.
---
--- Normal entities (main entities) should register without a callback as they are managed
--- by the game and the manager only takes care of tag data and player_index.
---
--- When adding a callback, the callback will be called periodically to "refresh" the ghost
--- list. Any ghost that was registered *without* a callback will be removed when the linger
--- period expires and it had not been refreshed.
---
--- When creating a multi-ghost entity (e.g. for connection pins), register the main entity
--- with a callback and all other entities without. When the all the entities are placed down,
--- the callback will be called for the main entity which in turn must find its associated
--- entity ghosts and refresh them as well (return on the refresh list). If the main ghost is
--- replaced but the others are not, they will be removed when the linger period expires.
---
---@param names string|string[] One or more names to match to the ghost_name field.
---@param refresh_callback framework.ghost_manager.RefreshCallback? Optional callback to refresh entities
function FrameworkGhostManager:registerForName(names, refresh_callback)
    assert(names)
    local event_matcher = Matchers:matchEventEntityGhostName(names)
    Event.register(Matchers.CREATION_EVENTS, on_ghost_entity_created, event_matcher)
    Event.register(defines.events.on_post_entity_died, on_post_entity_died)

    -- if a callback was provided, register callback and turn on the ticker
    if refresh_callback then
        if type(names) ~= 'table' then names = { names } end

        Event.register_if(table_size(self.refresh_callbacks) == 0, -TICK_INTERVAL, tick)

        for _, name in pairs(names) do
            self.refresh_callbacks[name] = refresh_callback
        end
    end
end

---@param attribute string The entity attribute to match.
---@param values string|string[] One or more values to match.
function FrameworkGhostManager:registerForAttribute(attribute, values)
    local event_matcher = Matchers:matchEventEntityAsGhost(attribute, values)
    Event.register(Matchers.CREATION_EVENTS, on_ghost_entity_created, event_matcher)
    Event.register(defines.events.on_post_entity_died, on_post_entity_died)
end

--- Registers a callback with the ghost manager. Every ghost that is registered by the game
--- with the ghost manager will be passed through this callback. This allows a mod to modify
--- the information provided by the ghost. Any field in the AttachedEntity can be modified.
--- When modifying the tags, they need to be explicitly written back to the ghost entity.
---@param ghost_callback framework.ghost_manager.GhostCallback
function FrameworkGhostManager:addGhostCallback(ghost_callback)
    self.ghost_callback = ghost_callback
end

--- Can be called by the tombstone manager. Will pass in all the information necessary to find
--- a ghost that matches a blueprint entity to build and apply a possible tombstone as tags to the
--- ghost.
---@param data table<string, any>
---@param position MapPosition
---@param surface_index number
---@param name string
function FrameworkGhostManager.mapTombstoneToGhostTags(data, position, surface_index, name)
    local ghost = Framework.ghost_manager:findGhostForKey(tools:createEntityKey(position, surface_index, name))
    if ghost then ghost.tags = data end
end

--------------------------------------------------------------------------------
-- event registration
--------------------------------------------------------------------------------

local function register_events()
    Event.register(defines.events.on_object_destroyed, on_object_destroyed)
end

Event.on_init(register_events)
Event.on_load(register_events)

return FrameworkGhostManager
