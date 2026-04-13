--- Tools for working with entities.
--- @class Entity.Entity
--- @usage local Entity = require('__Kux-CoreLib__/stdlib/entity/entity')
local Entity = {
    __class = 'Entity',
    __index = require('__Kux-CoreLib__/stdlib/core')
}
setmetatable(Entity, Entity)

--- Tests whether an entity has access to a given field.
--- @param entity LuaEntity the entity to test the access to a field
--- @param field_name string the field name
--- @return boolean true if the entity has access to the field, false if the entity threw an exception when trying to access the field
function Entity.has(entity, field_name)
    assert(entity, 'missing entity argument')
    assert(field_name, 'missing field name argument')

    local status =
    pcall(
        function()
            return entity[field_name]
        end
    )
    return status
end

--- Gets the user data that is associated with an entity.
-- The user data is stored in the storage object and it persists between loads.
--> The user data will be removed from an entity when the entity becomes invalid.
--- @param entity LuaEntity the entity to look up
--- @return any? #the user data, or nil if no data exists for the entity
function Entity.get_data(entity)
    assert(entity, 'missing entity argument')
    if not storage._entity_data then
        return nil
    end

    local unit_number = entity.unit_number
    if unit_number then
        return storage._entity_data[unit_number]
    else
        local entity_name = entity.name
        if not storage._entity_data[entity_name] then
            return nil
        end

        local entity_category = storage._entity_data[entity_name]
        for _, entity_data in pairs(entity_category) do
            if Entity._are_equal(entity_data.entity, entity) then
                return entity_data.data
            end
        end
        return nil
    end
end

--- Associates the user data to an entity.
-- The user data will be stored in the storage object and it will persist between loads.
--> The user data will be removed from an entity when the entity becomes invalid.
--- @param entity LuaEntity the entity with which to associate the user data
--- @param data any? the data to set, or nil to delete the data associated with the entity
--- @return any? #the previous data associated with the entity, or nil if the entity had no previous data
function Entity.set_data(entity, data)
    assert(entity, 'missing entity argument')

    if not storage._entity_data then
        storage._entity_data = {}
    end

    local unit_number = entity.unit_number
    if unit_number then
        local prev = storage._entity_data[unit_number]
        storage._entity_data[unit_number] = data
        return prev
    else
        local entity_name = entity.name
        if not storage._entity_data[entity_name] then
            storage._entity_data[entity_name] = {}
        end

        local entity_category = storage._entity_data[entity_name]

        for i = #entity_category, 1, -1 do
            local entity_data = entity_category[i]
            if not entity_data.entity.valid then
                table.remove(entity_category, i)
            end
            if Entity._are_equal(entity_data.entity, entity) then
                local prev = entity_data.data
                if data then
                    entity_data.data = data
                else
                    table.remove(entity_category, i)
                end
                return prev
            end
        end
        table.insert(entity_category, { entity = entity, data = data })
    end
    return nil
end

--- Freezes an entity, by making it inactive, inoperable, and non-rotatable, or unfreezes by doing the reverse.
--- @param entity LuaEntity the entity to freeze or unfreeze
--- @param mode boolean? [opt=true] if true, freezes the entity, if false, unfreezes the entity. If not specified, it is set to true
--- @return LuaEntity the entity that has been frozen or unfrozen
function Entity.set_frozen(entity, mode)
    assert(entity, 'missing entity argument')
    mode = mode == false and true or false
    entity.active = mode
    entity.operable = mode
    entity.rotatable = mode
    return entity
end

--- Makes an entity indestructible so that it cannot be damaged or mined neither by the player nor by their enemy factions.
--- @param entity LuaEntity the entity to make indestructable
--- @param mode boolean? [opt=true] if true, makes the entity indestructible, if false, makes the entity destructable
--- @return LuaEntity the entity that has been made indestructable or destructable
function Entity.set_indestructible(entity, mode)
    assert(entity, 'missing entity argument')
    mode = mode == false and true or false
    entity.minable = mode
    entity.destructible = mode
    return entity
end

--- Tests if two entities are equal.
-- If they don't have a reference equality and ***entity\_a*** has ***equals*** function, it will be called with ***entity\_b*** as its first argument.
--- @param entity_a LuaEntity
--- @param entity_b LuaEntity
--- @return boolean
function Entity._are_equal(entity_a, entity_b)
    if entity_a == nil then
        return entity_a == entity_b
    elseif entity_a == entity_b then
        return true
    elseif Entity.has(entity_a, 'equals') and entity_a.equals ~= nil then
        return entity_a.equals(entity_b)
    else
        return false
    end
end

function Entity.find_resources(entity, all)
    if entity.type == 'mining-drill' then
        local radius = entity.prototype.mining_drill_radius
        local name = (not all and (entity.mining_target and entity.mining_target.name)) or nil
        return entity.surface.count_entities_filtered {
            type = 'resource',
            name = name,
            position = entity.position,
            radius = radius,
        }
    end
    return 0
end

function Entity.is_damaged(entity)
    return entity.get_health_ratio() < 1
end
Entity.damaged = Entity.is_damaged

function Entity.is_circuit_connected(entity)
    local list = entity.circuit_connected_entities
    return list and (next(list.red) or next(list.green))
end

function Entity.count_circuit_connections(entity)
    local list = entity.circuit_connected_entities
    return list and #list.red + #list.green
end

function Entity.has_fluidbox(entity)
    local box = entity.fluidbox
    return box and #box > 0
end

function Entity.can_deconstruct(entity)
    return entity.minable and entity.prototype.selectable_in_game and not entity.has_flag('not-deconstructable')
end

return Entity
