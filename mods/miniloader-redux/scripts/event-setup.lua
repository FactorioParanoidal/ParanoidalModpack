--------------------------------------------------------------------------------
-- event setup for the mod
--------------------------------------------------------------------------------
assert(script)

local Direction = require('stdlib.area.direction')
local Event = require('stdlib.event.event')
local Position = require('stdlib.area.position')
local Player = require('stdlib.event.player')
local table = require('stdlib.utils.table')

local Matchers = require('framework.matchers')

local const = require('lib.constants')

local migration = require('scripts.migration')

--------------------------------------------------------------------------------
-- entity create / delete
--------------------------------------------------------------------------------

---@param event EventData.on_pre_build
local function on_pre_build(event)
    local pdata = Player.pdata(event.player_index)
    ---@type miniloader.PreBuild
    pdata.pre_build = pdata.pre_build or {}

    pdata.pre_build.direction = event.direction
    pdata.pre_build.flip_horizontal = event.flip_horizontal
    pdata.pre_build.flip_vertical = event.flip_vertical
end

---@param attached_entity framework.ghost_manager.AttachedEntity
local function ghost_callback(attached_entity)
    local pdata = Player.pdata(attached_entity.player_index)
    ---@type miniloader.PreBuild?
    local pre_build = pdata and pdata.pre_build

    local config = attached_entity.tags and attached_entity.tags[const.config_tag_name] --[[@as miniloader.Config]]

    -- correct config direction in the ml_config tag
    if config and config.direction then
        config.direction = This.Snapping:correct_direction(config.direction, pre_build)
        -- reassign tags to entity
        attached_entity.entity.tags = attached_entity.tags
    end
end

---@param event EventData.on_built_entity | EventData.on_robot_built_entity | EventData.on_space_platform_built_entity | EventData.script_raised_revive | EventData.script_raised_built
local function on_entity_created(event)
    local entity = event and event.entity
    if not entity then return end

    local pdata = event.player_index and Player.pdata(event.player_index)
    ---@type miniloader.PreBuild?
    local pre_build = pdata and pdata.pre_build

    local tags = event.tags
    local config = tags and tags[const.config_tag_name] --[[@as miniloader.Config]]
    -- correct config direction in the ml_config tag
    if config and config.direction then
        config.direction = This.Snapping:correct_direction(config.direction, pre_build)
    end

    local entity_ghost = Framework.ghost_manager:findGhostForEntity(entity)
    if entity_ghost then
        tags = tags or entity_ghost.tags
    end

    config = tags and tags[const.config_tag_name] --[[@as miniloader.Config]]
    local no_snapping = tags and tags[const.no_snapping_tag_name] or false

    This.MiniLoader:create(entity, config, no_snapping)
end

---@param event EventData.on_player_mined_entity | EventData.on_robot_mined_entity | EventData.on_space_platform_mined_entity | EventData.script_raised_destroy
local function on_entity_deleted(event)
    local entity = event and event.entity
    if not (entity and entity.valid) then return end
    assert(entity.unit_number)

    This.MiniLoader:destroy(entity.unit_number)
end

---@param event EventData.on_post_entity_died
local function on_entity_died(event)
    if not (event.unit_number) then return end

    This.MiniLoader:destroy(event.unit_number)
end

--------------------------------------------------------------------------------
-- Entity destruction
--------------------------------------------------------------------------------

---@param event EventData.on_object_destroyed
local function on_object_destroyed(event)
    -- main entity destroyed
    This.MiniLoader:destroy(event.useful_id)
end

--------------------------------------------------------------------------------
-- Entity cloning
--------------------------------------------------------------------------------

---@param event EventData.on_entity_cloned
local function on_entity_cloned(event)
    if not (event and event.source and event.source.valid and event.destination and event.destination.valid) then return end

    local src_data = This.MiniLoader:getEntity(event.source.unit_number)
    if not src_data then return end

    local cloned_entities = event.destination.surface.find_entities(Position(event.destination.position):expand_to_area(0.5))
    for _, cloned_entity in pairs(cloned_entities) do
        if const.supported_inserters[cloned_entity.name] then
            cloned_entity.destroy()
        elseif const.supported_loaders[cloned_entity.name] then
            cloned_entity.destroy()
        end
    end

    This.MiniLoader:create(event.destination, src_data.config)
end

---@param event EventData.on_entity_cloned
local function on_internal_entity_cloned(event)
    if not (event.source and event.source.valid and event.destination and event.destination.valid) then return end

    -- delete the destination entity, it is not needed as the internal structure of the
    -- miniloader is recreated when the main entity is cloned
    event.destination.destroy()
end

--------------------------------------------------------------------------------
-- Entity settings pasting
--------------------------------------------------------------------------------

---@param event EventData.on_entity_settings_pasted
local function on_entity_settings_pasted(event)
    if not (event and event.source and event.source.valid and event.destination and event.destination.valid) then return end

    local player = Player.get(event.player_index)
    if not (player and player.valid and player.force == event.source.force and player.force == event.destination.force) then return end

    local src_entity = This.MiniLoader:getEntity(event.source.unit_number)
    local dst_entity = This.MiniLoader:getEntity(event.destination.unit_number)

    if not (src_entity and dst_entity) then return end

    This.MiniLoader:reconfigure(dst_entity, src_entity.config)
end

--------------------------------------------------------------------------------
-- serialization for Blueprinting and Tombstones
--------------------------------------------------------------------------------

---@param entity LuaEntity
---@return table<string, any>?
local function serialize_config(entity)
    if not entity and entity.valid then return end

    return This.MiniLoader:serializeConfiguration(entity)
end

---@param entity LuaEntity
---@return table<string, any>?
local function add_snapping_tag(entity)
    if not entity and entity.valid then return end

    return This.MiniLoader:addSnappingTag(entity)
end

--------------------------------------------------------------------------------
-- Configuration changes (startup)
--------------------------------------------------------------------------------

local function on_configuration_changed()
    This.MiniLoader:init()

    -- enable recipes if researched
    for _, force in pairs(game.forces) do
        for _, name in pairs(const.supported_type_names) do
            if force.recipes[name] and force.technologies[name] then
                force.recipes[name].enabled = force.technologies[name].researched
            end
        end
    end

    if Framework.settings:startup_setting(const.settings_names.migrate_loaders) then
        assert(migration)
        migration:migrateMiniloaders()
        migration:migrateBlueprints()
        migration:migrateTechnologies()
    end

    for _, ml_entity in pairs(This.MiniLoader:entities()) do
        This.MiniLoader:sanitizeConfiguration(ml_entity)
    end
end

--------------------------------------------------------------------------------
-- Entity snapping
--------------------------------------------------------------------------------

---@param event EventData.on_built_entity | EventData.on_robot_built_entity | EventData.script_raised_revive | EventData.script_raised_built
local function on_snappable_entity_created(event)
    if not Framework.settings:runtime_setting(const.settings_names.loader_snapping) then return end

    local entity = event and event.entity
    if not (entity and entity.valid) then return end

    -- if this is an actual miniloader, don't snap it
    if const.supported_types[entity.name] then return end

    -- if the entity is marked as non-snapping, don't update loaders
    if event.tags and event.tags[const.no_snapping_tag_name] then return end

    This.Snapping:updateLoaders(entity)
end

local function on_snappable_entity_rotated(event)
    if not Framework.settings:runtime_setting(const.settings_names.loader_snapping) then return end

    local entity = event and event.entity
    if not (entity and entity.valid) then return end


    -- if this is an actual miniloader, don't snap it
    if const.supported_types[entity.name] then return end

    This.Snapping:updateLoaders(entity)
end

--------------------------------------------------------------------------------
-- Entity rotation
--------------------------------------------------------------------------------

---@param event EventData.on_player_rotated_entity
local function on_entity_rotated(event)
    local entity = event.entity
    if not (entity and entity.valid) then return end

    -- main entity rotated?
    local ml_entity = This.MiniLoader:getEntity(entity.unit_number)
    if not ml_entity then return end

    local reverse = Direction.next(event.previous_direction) ~= entity.direction

    This.MiniLoader:rotate(ml_entity, reverse)
end

--------------------------------------------------------------------------------
-- event registration and management
--------------------------------------------------------------------------------

local function register_events()
    local match_all_main_entities = Matchers:matchEventEntityName(const.supported_type_names)

    local match_internal_entities = Matchers:matchEventEntityName(table.array_combine(const.supported_inserter_names, const.supported_loader_names))
    local match_snap_entities = Matchers:matchEventEntity('type', const.snapping_type_names)
    local match_forward_snap_entities = Matchers:matchEventEntity('type', const.forward_snapping_type_names)


    Event.register(defines.events.on_pre_build, on_pre_build)
    -- entity create / delete
    Event.register(Matchers.CREATION_EVENTS, on_entity_created, match_all_main_entities)
    -- deletion events can not include on_entity_died because then the tombstone manager would not work.
    Event.register(Matchers.DELETION_EVENTS, on_entity_deleted, match_all_main_entities)
    -- register post_died to deal with dead entities
    Event.register(defines.events.on_post_entity_died, on_entity_died)

    -- other entities
    Event.register(Matchers.CREATION_EVENTS, on_snappable_entity_created, match_snap_entities)

    -- manage ghost building (robot building)
    Framework.ghost_manager:registerForName(const.supported_type_names)
    Framework.ghost_manager:addGhostCallback(ghost_callback)

    -- entity destroy (can't filter on that)
    Event.register(defines.events.on_object_destroyed, on_object_destroyed)

    -- Configuration changes (startup)
    Event.on_configuration_changed(on_configuration_changed)

    -- manage blueprinting and copy/paste
    Framework.blueprint:registerCallbackForNames(const.supported_type_names, serialize_config)
    Framework.blueprint:registerCallbackForTypes(const.snapping_type_names, add_snapping_tag)

    -- manage tombstones for undo/redo and dead entities
    Framework.tombstone:registerCallback(const.supported_type_names, {
        create_tombstone = serialize_config,
        apply_tombstone = Framework.ghost_manager.mapTombstoneToGhostTags,
    })

    -- Entity cloning
    Event.register(defines.events.on_entity_cloned, on_entity_cloned, match_all_main_entities)
    Event.register(defines.events.on_entity_cloned, on_internal_entity_cloned, match_internal_entities)

    -- Entity settings pasting
    Event.register(defines.events.on_entity_settings_pasted, on_entity_settings_pasted, match_all_main_entities)


    -- entity rotation
    Event.register(defines.events.on_player_rotated_entity, on_entity_rotated, match_all_main_entities)
    Event.register(defines.events.on_player_rotated_entity, on_snappable_entity_rotated, match_forward_snap_entities)
end

--------------------------------------------------------------------------------
-- mod init/load code
--------------------------------------------------------------------------------

local function on_init()
    This.MiniLoader:init()
    register_events()
end

local function on_load()
    register_events()
end

-- setup player management
Player.register_events(true)

Event.on_init(on_init)
Event.on_load(on_load)
