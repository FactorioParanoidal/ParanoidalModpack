---@meta
--------------------------------------------------------------------------------
-- loader migration
--------------------------------------------------------------------------------
assert(script)

local util = require('util')

local Position = require('stdlib.area.position')
local Is = require('stdlib.utils.is')
local table = require('stdlib.utils.table')

local const = require('lib.constants')

if not Framework.settings:startup_setting(const.settings_names.migrate_loaders) then return nil end

---@class miniloader.Migration
---@field ml_entities LuaEntityPrototype[]
---@field migrations table<string, string>
---@field stats table<string, number>
local Migration = {
    ml_entities = {},
    migrations = {},
    stats = {},
}

for prefix, migration in pairs(const:migrations()) do
    local name = prefix .. 'miniloader-inserter'
    local entity = prototypes.entity[name]
    if entity then
        table.insert(Migration.ml_entities, entity)
        Migration.migrations[name] = migration
    end
end

---@param src LuaEntity
---@param dst LuaEntity
---@return boolean A wire connection was found
local function copy_wire_connections(src, dst)
    local has_wire = false
    for wire_connector_id, wire_connector in pairs(src.get_wire_connectors(true)) do
        local dst_connector = dst.get_wire_connector(wire_connector_id, true)
        for _, connection in pairs(wire_connector.connections) do
            if connection.origin == defines.wire_origin.player then
                has_wire = true
                dst_connector.connect_to(connection.target, false, connection.origin)
            end
        end
    end
    return has_wire
end

---@param surface LuaSurface
---@param loader LuaEntity
function Migration:migrateLoader(surface, loader)
    if not Is.Valid(loader) then return end
    local entities_to_delete = surface.find_entities(Position(loader.position):expand_to_area(0.5))

    ---@type miniloader.LoaderDirection
    local loader_type = const.loader_direction.input

    for _, entity_to_delete in pairs(entities_to_delete) do
        -- remove anything that can not migrated. This kills the loader and the container
        if not self.migrations[entity_to_delete.name] then
            if entity_to_delete.type == 'loader-1x1' then loader_type = const.loader_direction[entity_to_delete.loader_type] end
            entity_to_delete.destroy()
        end
    end

    -- create new main entity in the same spot
    local main = surface.create_entity {
        name = self.migrations[loader.name],
        position = loader.position,
        direction = loader.direction,
        quality = loader.quality,
        force = loader.force,
        create_build_effect_smoke = false,
        move_stuck_players = true,
    }

    assert(main)

    -- add the loader and additional inserters. The loader will be fine as the old
    -- loader has already been deleted
    local ml_entity = This.MiniLoader:setup(main)

    -- pull the config out of the loader that is migrating
    This.MiniLoader:readConfigFromEntity(loader, ml_entity)

    local has_wires = copy_wire_connections(loader, main)
    -- fix up config
    if not has_wires then ml_entity.config.inserter_config.circuit_enable_disable = false end
    if loader_type then ml_entity.config.loader_type = loader_type end

    -- reconfigure the loader. This syncs the configuration across all the
    -- inserters and reorients loader and inserters
    This.MiniLoader:reconfigure(ml_entity)

    self.stats[loader.name] = (self.stats[loader.name] or 0) + 1

    -- kill everything else that was found in this spot. This removes
    -- all of the old inserters
    for _, entity_to_delete in pairs(entities_to_delete) do
        if Is.Valid(entity_to_delete) then
            entity_to_delete.destroy()
        end
    end
end

function Migration:migrateMiniloaders()
    for _, surface in pairs(game.surfaces) do
        self.stats = {}

        local loaders = surface.find_entities_filtered {
            name = self.ml_entities,
        }

        for _, loader in pairs(loaders) do
            self:migrateLoader(surface, loader)
        end

        local stats = ''
        local total = 0
        for name, count in pairs(self.stats) do
            stats = stats .. ('%s: %s'):format(name, count)
            total = total + count
            if next(self.stats, name) then
                stats = stats .. ', '
            end
        end
        if total > 0 then
            game.print { const:locale('migration'), total, surface.name, stats }
        end
    end
end

---------------------------------------------------------------------------

---@param blueprint_entity BlueprintEntity
---@return BlueprintEntity?
local function create_entity(blueprint_entity)
    local new_entity = util.copy(blueprint_entity)
    new_entity.name = Migration.migrations[blueprint_entity.name]
    return new_entity
end

---------------------------------------------------------------------------

local BlueprintMigrator = {}

---------------------------------------------------------------------------

---@param blueprint_entity BlueprintEntity
---@return BlueprintEntity?
function BlueprintMigrator:migrateBlueprintEntity(blueprint_entity)
    if not Migration.migrations[blueprint_entity.name] then return nil end

    return create_entity(blueprint_entity)
end

---@param blueprint_entities (BlueprintEntity[])?
---@return boolean modified
function BlueprintMigrator:migrateBlueprintEntities(blueprint_entities)
    local dirty = false

    if not blueprint_entities then return dirty end

    for i = 1, #blueprint_entities, 1 do
        local blueprint_entity = blueprint_entities[i]

        if Migration.migrations[blueprint_entity.name] then
            local new_entity = self:migrateBlueprintEntity(blueprint_entity)
            if new_entity then
                blueprint_entities[i] = new_entity
                dirty = true
            end
        end
    end

    return dirty
end

---@param migration_object (LuaItemStack|LuaRecord)?
---@return boolean
function BlueprintMigrator:executeMigration(migration_object)
    if not (migration_object and migration_object.valid) then return false end

    local blueprint_entities = util.copy(migration_object.get_blueprint_entities())
    if (self:migrateBlueprintEntities(blueprint_entities)) then
        migration_object.set_blueprint_entities(blueprint_entities)
        return true
    end

    return false
end

---@param inventory LuaInventory?
function BlueprintMigrator:processInventory(inventory)
    if not (inventory and inventory.valid) then return end
    for i = 1, #inventory, 1 do
        if inventory[i] then
            if inventory[i].is_blueprint then
                self:executeMigration(inventory[i])
            elseif inventory[i].is_blueprint_book then
                local nested_inventory = inventory[i].get_inventory(defines.inventory.item_main)
                self:processInventory(nested_inventory)
            end
        end
    end
end

---@param record LuaRecord
function BlueprintMigrator:processRecord(record)
    if not (record.valid and record.valid_for_write) then return end

    if record.type == 'blueprint' then
        self:executeMigration(record)
    elseif record.type == 'blueprint-book' then
        for _, nested_record in pairs(record.contents) do
            self:processRecord(nested_record)
        end
    end
end

---------------------------------------------------------------------------

function Migration:migrateBlueprints()
    -- migrate game blueprints
    for _, record in pairs(game.blueprints) do
        BlueprintMigrator:processRecord(record)
    end

    -- migrate blueprints players have in their inventory
    for _, player in pairs(game.players) do
        local inventory = player.get_main_inventory()
        BlueprintMigrator:processInventory(inventory)
    end
end

function Migration:migrateTechnologies()
    for _, force in pairs(game.forces) do
        for prefix, migration in pairs(const:migrations()) do
            local technology_name = prefix .. 'miniloader'
            if force.technologies[technology_name] then
                force.technologies[migration].researched = force.technologies[technology_name].researched
            end
        end
    end
end

return Migration
