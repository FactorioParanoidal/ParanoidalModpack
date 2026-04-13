---@meta
------------------------------------------------------------------------
-- snapping logic
------------------------------------------------------------------------
assert(script)

local Is = require('stdlib.utils.is')
local Area = require('stdlib.area.area')
local Position = require('stdlib.area.position')
local Direction = require('stdlib.area.direction')

local const = require('lib.constants')

local DIRECTION_SIZE = table_size(defines.direction)

---@class miniloader.Snapping
local Snapping = {}

---@type table<string, fun(entity: LuaEntity): ('input'|'output')>
local loader_types = {
    ['loader'] = function(entity) return entity.loader_type end,
    ['loader-1x1'] = function(entity) return entity.loader_type end,
    ['underground-belt'] = function(entity) return entity.belt_to_ground_type end,
    ['linked-belt'] = function(entity) return entity.linked_belt_type end,
}

---@param entity LuaEntity
---@return miniloader.LoaderDirection?
local function get_loader_type(entity)
    if not Is.Valid(entity) then return end
    assert(entity)
    if loader_types[entity.type] then return loader_types[entity.type](entity) --[[@as miniloader.LoaderDirection ]] end
    return nil
end

---@param direction defines.direction
---@return boolean
function Snapping:is_vertical(direction)
    return direction == defines.direction.north or direction == defines.direction.south
end

---@param direction defines.direction
---@return boolean
function Snapping:is_horizontal(direction)
    return direction == defines.direction.west or direction == defines.direction.east
end

---@param entity1 LuaEntity
---@param entity2 LuaEntity
---@return boolean
function Snapping:are_aligned(entity1, entity2)
    return self:is_vertical(entity1.direction) ~= self:is_horizontal(entity2.direction)
end

---@param ml_entity miniloader.Data
---@param loader_type miniloader.LoaderDirection
function Snapping:to_loader_type(ml_entity, loader_type)
    if ml_entity.config.loader_type ~= loader_type then
        ml_entity.config.loader_type = loader_type
    end
end

---@param loader_type miniloader.LoaderDirection
---@return miniloader.LoaderDirection reverse_direction
function Snapping:reverse_loader_type(loader_type)
    return loader_type == const.loader_direction.input and const.loader_direction.output or const.loader_direction.input
end

---@param config miniloader.Config
---@return defines.direction
function Snapping:compute_loader_direction(config)
    -- output loader points in the same direction as the miniloader, input loader points in opposite direction
    return config.loader_type == const.loader_direction.output and config.direction or Direction.opposite(config.direction)
end

---@param config miniloader.Config
---@return defines.direction
function Snapping:compute_inserter_direction(config)
    -- for input loaders, the inserter points in the same direction as the miniloader, for output loaders it points in opposite direction
    return config.loader_type == const.loader_direction.input and config.direction or Direction.opposite(config.direction)
end

---@param direction defines.direction
---@param loader_type miniloader.LoaderDirection
function Snapping:direction_from_inserter(direction, loader_type)
    return loader_type == const.loader_direction.input and direction or Direction.opposite(direction)
end

--- Corrects a given direction based on the prebuild information about rotation and flipping.
--- This is most useful when building entities from a blueprint.
---@param direction defines.direction
---@param pre_build miniloader.PreBuild?
---@return defines.direction corrected_direction
function Snapping:correct_direction(direction, pre_build)
    if not pre_build then return direction end

    -- correct blueprint flipping
    local corrected_direction = direction
    if pre_build.flip_horizontal and This.Snapping:is_horizontal(direction) then
        corrected_direction = Direction.opposite(corrected_direction)
    end

    if pre_build.flip_vertical and This.Snapping:is_vertical(direction) then
        corrected_direction = Direction.opposite(corrected_direction)
    end

    -- correct blueprint rotation
    if pre_build.direction then
        corrected_direction = (corrected_direction + pre_build.direction) % DIRECTION_SIZE
    end

    return corrected_direction
end


-- set loader direction according to the entity in front. Unlike other snapping code,
-- this only considers the entity in front of the loader
--
-- loader snaps to
--  - a belt off direction - switch loader to output
--  - a belt in direction - align loader with belt
--  - an entity in direction - check the direction of the entity, align with direction
--
---@param ml_entity miniloader.Data
---@param entity LuaEntity
---
function Snapping:forward_snap_loader_to_target(ml_entity, entity)
    if not const.forward_snapping_types[entity.type] then return end

    if not self:are_aligned(ml_entity.main, entity) then
        if entity.type ~= 'transport-belt' then return end

        -- if the loader points at a non-aligned transport belt, make it output to the belt
        return self:to_loader_type(ml_entity, const.loader_direction.output)
    else
        -- is the thing, that we point at, some sort of directional object?
        local entity_loader_type = get_loader_type(entity)
        if entity_loader_type then return self:to_loader_type(ml_entity, self:reverse_loader_type(entity_loader_type)) end

        -- something without loader_type, e.g. a belt
        -- if the actual loader direction is the same, do nothing, otherwise flip the loader type
        if self:compute_loader_direction(ml_entity.config) ~= entity.direction then
            ml_entity.config.loader_type = self:reverse_loader_type(ml_entity.config.loader_type)
        end
    end
end

-- returns loaders next to a given entity
---@param entity LuaEntity
---@return (miniloader.Data[]) ml_entities
local function find_loader_by_entity(entity)
    local area = Area(entity.prototype.selection_box):offset(entity.position):expand(1)

    if Framework.settings:startup_setting('debug_mode') then
        rendering.draw_rectangle {
            color = { r = 1, g = 0.5, b = 0.5 },
            surface = entity.surface,
            left_top = area.left_top,
            right_bottom = area.right_bottom,
            time_to_live = const.debug_lifetime,
        }
    end

    local candidates = entity.surface.find_entities_filtered {
        type = const.miniloader_type_names,
        name = const.supported_type_names,
        area = area,
        force = entity.force
    }

    local ml_entities = {}
    for _, candidate in pairs(candidates) do
        local ml_entity = This.MiniLoader:getEntity(candidate.unit_number)
        if ml_entity then table.insert(ml_entities, ml_entity) end
    end

    return ml_entities
end

---@param ml_entity miniloader.Data The loader to check
---@param direction defines.direction? Direction override
---@return LuaEntity? An entity that may influence the loader direction
local function find_neighbor_entity(ml_entity, direction)
    direction = direction or ml_entity.config.direction

    -- find area to look at in front of the miniloader (the miniloader points in 'direction')
    local area = Area(ml_entity.main.prototype.selection_box):offset(Position(ml_entity.main.position)):translate(direction, 1)

    if Framework.settings:startup_setting('debug_mode') then
        rendering.draw_rectangle {
            color = { r = 0.5, g = 0.5, b = 1 },
            surface = ml_entity.main.surface,
            left_top = area.left_top,
            right_bottom = area.right_bottom,
            time_to_live = const.debug_lifetime,
        }
    end

    local entities = ml_entity.main.surface.find_entities_filtered {
        type = const.snapping_type_names,
        area = area,
        force = ml_entity.main.force,
    }

    return #entities > 0 and Is.Valid(entities[1]) and entities[1] or nil
end

---@param ml_entity miniloader.Data
function Snapping:snapToNeighbor(ml_entity)
    if not Is.Valid(ml_entity.main) then return end
    local neighbor = find_neighbor_entity(ml_entity)
    if not neighbor then return end

    if const.forward_snapping_types[neighbor.type] then
        self:forward_snap_loader_to_target(ml_entity, neighbor)
    else
        -- it is a thing we should be loading/unloading from but the belt points at it. flip the loader
        ml_entity.config.direction = Direction.opposite(ml_entity.config.direction)

        -- now that we flipped the loader, check forward snap again.
        neighbor = find_neighbor_entity(ml_entity)
        if not (neighbor and const.forward_snapping_types[neighbor.type]) then return end

        self:forward_snap_loader_to_target(ml_entity, neighbor)
    end
end

function Snapping:updateNeighborLoaders(entity)
    if not Is.Valid(entity) then return end
    assert(entity)

    local ml_entities = find_loader_by_entity(entity)
    for _, ml_entity in pairs(ml_entities) do
        self:snapToNeighbor(ml_entity)
        This.MiniLoader:reconfigure(ml_entity)
    end
end

-- called when entity was rotated or non loader was built
---@param entity LuaEntity
function Snapping:updateLoaders(entity)
    self:updateNeighborLoaders(entity)

    if entity.type == 'underground-belt' then
        self:updateNeighborLoaders(entity.neighbours)
    elseif entity.type == 'linked-belt' then
        self:updateNeighborLoaders(entity.linked_belt_neighbour)
    end
end

return Snapping
