------------------------------------------------------------------------
-- Manage blueprint related state
------------------------------------------------------------------------
assert(script)

local Event = require('stdlib.event.event')
local Is = require('stdlib.utils.is')
local Player = require('stdlib.event.player')
local table = require('stdlib.utils.table')

local tools = require('framework.tools')

---@class framework.blueprint.Callbacks
---@field for_name table<string, any>
---@field for_type table<string, any>

---@alias framework.blueprint.PrepareCallback fun(blueprint: LuaItemStack): BlueprintEntity[]?
---@alias framework.blueprint.MapCallback fun(entity: LuaEntity, idx: integer, context: table<string, any>)
---@alias framework.blueprint.Callback fun(entity: LuaEntity, context: table<string, any>): table<string, any>?
---@alias framework.blueprint.Context table<string, any?>
---@alias framework.blueprint.EntityMap table<string, LuaEntity>

---@class framework.blueprint.Manager
---@field map_callbacks framework.blueprint.Callbacks
---@field callbacks framework.blueprint.Callbacks
---@field prepare_blueprint_callback framework.blueprint.PrepareCallback?
local FrameworkBlueprintManager = {
    map_callbacks = {
        for_name = {},
        for_type = {},
    },
    callbacks = {
        for_name = {},
        for_type = {},
    },
    prepare_blueprint_callback = nil,
}

------------------------------------------------------------------------
-- Blueprint management
------------------------------------------------------------------------

---@param entity LuaEntity
---@param matchers framework.blueprint.Callbacks
---@return any?
local function match_entity(entity, matchers)
    if not (entity and entity.valid) then return nil end
    local res = matchers.for_name[entity.name]
    if res then return res end
    return matchers.for_type[entity.type]
end

---@param player LuaPlayer
---@return boolean
local function can_access_blueprint(player)
    if not Is.Valid(player) then return false end
    if not player.cursor_stack then return false end

    return (player.cursor_stack.valid_for_read and player.cursor_stack.name == 'blueprint')
end

---@param blueprint (LuaItemStack | LuaRecord)?
---@param entity_map framework.blueprint.EntityMap
---@param context framework.blueprint.Context
function FrameworkBlueprintManager:augmentBlueprint(blueprint, entity_map, context)
    if not entity_map or (table_size(entity_map) < 1) then return end
    if not (blueprint and blueprint.is_blueprint_setup()) then return end

    local blueprint_entities = self.prepare_blueprint_callback and self.prepare_blueprint_callback(blueprint) or blueprint.get_blueprint_entities()
    if not blueprint_entities then return end

    -- at this point, the entity_map contains all entities that were captured in the
    -- initial blueprint but the final list (which is part of the blueprint itself) may
    -- have changed as the player can manipulate the blueprint.

    for idx, entity in pairs(blueprint_entities) do
        local key = tools:createEntityKeyFromBlueprintEntity(entity) -- override surface index to 0
        if entity_map[key] then
            ---@type framework.blueprint.Callback
            local callback = match_entity(entity_map[key], FrameworkBlueprintManager.callbacks)
            if callback then
                local tags = callback(entity_map[key], context)
                if tags then
                    for k, v in pairs(tags) do
                        blueprint.set_blueprint_entity_tag(idx, k, v)
                    end
                end
            end
        end
    end
end

---@param entities LuaEntity[]
---@param context framework.blueprint.Context
---@return framework.blueprint.EntityMap entity_map
function FrameworkBlueprintManager:createEntityMap(entities, context)
    if not entities then return {} end

    local entity_map = {}
    for idx, entity in pairs(entities) do
        ---@type framework.blueprint.MapCallback
        local map_callback = match_entity(entity, FrameworkBlueprintManager.map_callbacks)
        if map_callback then -- there is a callback for this entity
            map_callback(entity, idx, context)
        end

        local key = tools:createEntityKeyFromEntity(entity, 0) -- override surface index to 0
        assert(key)

        if entity_map[key] then
            Framework.logger:logf('Duplicate entity found at %s: %s', entity.gps_tag, entity.name)
        else
            entity_map[key] = entity
        end
    end

    return entity_map
end

------------------------------------------------------------------------
-- Event code
------------------------------------------------------------------------

---@param event EventData.on_player_setup_blueprint
local function on_player_setup_blueprint(event)
    local player, player_data = Player.get(event.player_index)
    if not (player or player_data) then return end

    local self = assert(Framework.blueprint)

    local selected_entities = event.mapping.get()
    -- for large blueprints, the event mapping might come up empty
    -- which seems to be a limitation of the game. Fall back to an
    -- area scan
    if table_size(selected_entities) < 1 then
        if not event.area then return end
        selected_entities = player.surface.find_entities_filtered {
            area = event.area,
            force = player.force,
            name = table.keys(self.callbacks.for_name),
        }
        selected_entities = table.array_combine(selected_entities, player.surface.find_entities_filtered {
            area = event.area,
            force = player.force,
            type = table.keys(self.callbacks.for_type),
        })
    end

    local context = {}
    local entity_map = self:createEntityMap(selected_entities, context)

    -- See https://forums.factorio.com/viewtopic.php?p=661598#p661598 for the event.record / event.stack selection
    ---@type (LuaItemStack | LuaRecord)?
    local blueprint_item_stack = event.record or event.stack or (can_access_blueprint(player) and player.cursor_stack)

    if blueprint_item_stack then
        self:augmentBlueprint(blueprint_item_stack, entity_map, context)
    else
        -- Player is editing the blueprint, no access for us yet.
        -- onPlayerConfiguredBlueprint picks this up and stores it.
        player_data.current_blueprint = {
            entity_map = entity_map,
            context = context,
        }
    end
end

---@param event EventData.on_player_configured_blueprint
local function on_player_configured_blueprint(event)
    local player, player_data = Player.get(event.player_index)
    if not (player or player_data) then return end

    local self = assert(Framework.blueprint)

    local current_blueprint = player_data.current_blueprint

    if current_blueprint and can_access_blueprint(player) then
        -- could not augment at setup, augment now
        self:augmentBlueprint(player.cursor_stack, current_blueprint.entity_map, current_blueprint.context)
    end

    player_data.current_blueprint = nil
end

------------------------------------------------------------------------
-- Public API
------------------------------------------------------------------------

--- Registers blueprint callbacks for a set of entities of the same type with different names. The
--- callback is called every time an entity is added to a blueprint. The optional map_callback is called
--- when the entity is added to the blueprint map, which maps the blueprinted entities to the actual entities
--- on the surface.
---
---@param entity_names string|string[]
---@param callback framework.blueprint.Callback
---@param map_callback framework.blueprint.MapCallback?
function FrameworkBlueprintManager:registerCallbackForNames(entity_names, callback, map_callback)
    assert(entity_names)
    if type(entity_names) ~= 'table' then entity_names = { entity_names } end

    for _, entity_name in pairs(entity_names) do
        self.callbacks.for_name[entity_name] = callback
        if map_callback then self.map_callbacks.for_name[entity_name] = map_callback end
    end
end

--- Registers blueprint callbacks for one or more entity types. Any entity of that type will be matched.
--- The callback is called every time an entity  is added to a blueprint. The optional map_callback is
--- called when the entity is added to the blueprint map, which maps the blueprinted entities to the
--- actual entities on the surface.
---
---@param entity_types string|string[]
---@param callback framework.blueprint.Callback
---@param map_callback framework.blueprint.MapCallback?
function FrameworkBlueprintManager:registerCallbackForTypes(entity_types, callback, map_callback)
    assert(entity_types)
    if type(entity_types) ~= 'table' then entity_types = { entity_types } end

    for _, entity_type in pairs(entity_types) do
        self.callbacks.for_type[entity_type] = callback
        if map_callback then self.map_callbacks.for_type[entity_type] = map_callback end
    end
end

--- Registers a callback with the blueprint manager that will be called when it tries
--- to retrieve the blueprint entities from the blueprint. This allows a mod to modify
--- the blueprint before it gets saved by the game.
---
---@param callback framework.blueprint.PrepareCallback
function FrameworkBlueprintManager:registerPreprocessor(callback)
    self.prepare_blueprint_callback = callback
end

--------------------------------------------------------------------------------
-- event registration
--------------------------------------------------------------------------------

local function register_events()
    -- Blueprint management
    Event.register(defines.events.on_player_setup_blueprint, on_player_setup_blueprint)
    Event.register(defines.events.on_player_configured_blueprint, on_player_configured_blueprint)
end

Event.on_init(register_events)
Event.on_load(register_events)

return FrameworkBlueprintManager
