--
-- tools. Some of this code has been picked out of stdlib
--

local const = require('scripts.constants')

local collision_mask_util = require('collision-mask-util')

---@type epd.ModData
local mod_data = assert(prototypes.mod_data['even-pickier-dollies']).data

---@class EvenPickierDolliesTools
local tools = {
    mod_data_blacklist = mod_data.blacklist_names or {}
}

---@param player LuaPlayer
---@param position MapPosition
---@param silent? boolean
function tools.flying_text(player, text, position, silent)
    player.create_local_flying_text { text = text, position = position }
    if not silent then player.play_sound { path = "utility/cannot_build", position = player.position, volume = 1 } end
end

---@param entity LuaEntity
---@param cheat_mode boolean
---@return boolean
function tools.allow_moving(entity, cheat_mode)
    -- definitely blacklisted by either internal list, mod registration or in the mod-data object
    local blacklisted = const.blacklist_types[entity.type] or storage.blacklist_names[entity.name] or tools.mod_data_blacklist[entity.name] or false
    if blacklisted then return false end

    -- if it is not in the cheat whitelist, allow moving
    local only_in_cheat = const.whitelist_cheat_types[entity.type]
    if only_in_cheat then return cheat_mode end

    -- otherwise, allow moving
    return true
end

--- returns true if entity is belt connectable
---@param entity LuaEntity?
function tools.is_belt_type(entity)
    if not (entity and entity.valid) then return false end
    return const.belt_types[entity.type] or false
end

---@param entity LuaEntity?
---@param position MapPosition
---@param control epd.TransporterControl
---@return LuaEntity?
function tools.clone_entity(entity, position, control)
    if not (entity and entity.valid) then return nil end

    local result = entity.surface.create_entity {
        name = entity.name,
        position = position,
        direction = entity.direction,
        quality = entity.quality,
        force = entity.force,
        move_stuck_players = true,
        create_build_effect_smoke = false,
    }

    if not result then return nil end

    if control.fields then
        for _, field in pairs(control.fields) do
            result[field] = entity[field]
        end
    end

    -- connect wires on the new entity to the same entities as the source.
    local wire_connectors = entity.get_wire_connectors(false) or {}
    for _, wire_connector in pairs(wire_connectors) do
        local target_wire_connector = result.get_wire_connector(wire_connector.wire_connector_id, true)
        for _, connection in pairs(wire_connector.connections) do
            connection.target.connect_to(target_wire_connector, false, connection.origin)
        end
    end

    -- for belts, copy the items over
    if tools.is_belt_type(entity) then
        -- move items on belt. This should work but does not (https://forums.factorio.com/viewtopic.php?f=25&t=124332)
        for line_index = 1, entity.get_max_transport_line_index() do
            local source = entity.get_transport_line(line_index)
            local dest = result.get_transport_line(line_index)
            for item_index = 1, #source do
                dest.insert_at_back(source[item_index])
            end
            source.clear()
        end
    end

    -- copy control behavior, if supported
    local src_control_behavior = entity.get_or_create_control_behavior()
    if src_control_behavior then
        local dst_control_behavior = result.get_or_create_control_behavior()
        assert(dst_control_behavior)

        if control.control_fields then
            for _, field in pairs(control.control_fields) do
                dst_control_behavior[field] = src_control_behavior[field]
            end
        end

        if control.control_objects then
            for _, object in pairs(control.control_objects) do
                dst_control_behavior[object] = util.copy(src_control_behavior[object])
            end
        end
    end

    if control.filters then
        for i = 1, entity.filter_slot_count do
            result.set_filter(i, entity.get_filter(i))
        end
    end

    return result
end

---@param index integer
---@return EvenPickierDolliesPlayerData
function tools.pdata(index)
    storage.players = storage.players or {}
    storage.players[index] = storage.players[index] or {}
    return storage.players[index]
end

---@param pdata EvenPickierDolliesPlayerData
---@param entity LuaEntity?
---@param tick uint
function tools.save_entity(pdata, entity, tick)
    pdata.dolly = entity
    pdata.dolly_tick = tick
end

---@param pdata EvenPickierDolliesPlayerData
---@param tick uint
---@param save_time uint
---@return LuaEntity?
function tools.get_saved_entity(pdata, tick, save_time)
    if pdata.dolly and (not pdata.dolly.valid or tick > (pdata.dolly_tick + second * save_time)) then
        pdata.dolly = nil
    end
    return pdata.dolly
end

---@param player LuaPlayer
---@param pdata EvenPickierDolliesPlayerData
---@param tick uint
---@param save_time uint
---@return LuaEntity?
function tools.get_entity_to_move(player, pdata, tick, save_time)
    -- do not remember the last moved entity. Return either the current selection or nil.
    if save_time == 0 then return player.selected end

    -- clean out current entity if it is invalid or expired
    local dolly = tools.get_saved_entity(pdata, tick, save_time)

    -- if the player has not selected anything, return the current entity or nil
    if not player.selected then return dolly end

    -- if the selected object can not be moved and there is a current object, return that, otherwise the selected object
    if dolly and not tools.allow_moving(player.selected, player.cheat_mode) then
        return dolly
    else
        return player.selected
    end
end

--- Returns true if the wires can reach.
---
--- This performs a somewhat convoluted operation:
--- - for all wire connectors on the entity, find the corresponding connector on the target entity
--- - for each connection, find the target connector (on the other side) and see if it can reach "back" to the target entity connector
---
--- This allow checking whether wires that connect e.g. to a belt will connect to a new belt if that was moved (iaw deleted and re-created).
---@param entity LuaEntity This entity holds the current wires to check
---@param new_entity LuaEntity? The new entity that will be checked. This can be the same entity (for a normal move) or a new entity (for teleport mode)
---@return boolean can_move If true, the entity can be moved. If false, show the "wires can not be stretched any further" error
function tools.can_wires_reach(entity, new_entity)
    local wire_connectors = entity.get_wire_connectors(false) or {}
    if table_size(wire_connectors) == 0 then return true end

    new_entity = new_entity or entity
    for _, wire_connector in pairs(wire_connectors) do
        local new_wire_connector = new_entity.get_wire_connector(wire_connector.wire_connector_id, true)
        for _, connection in pairs(wire_connector.connections) do
            local target_wire_connector = connection.target
            if entity.prototype.get_max_circuit_wire_distance(entity.quality) > 0 and not
                -- if wires can connect directly, continue
                (target_wire_connector.can_wire_reach(new_wire_connector)
                    -- if the wire was made by a mod (or a radar), continue
                    or (connection.origin ~= defines.wire_origin.player)
                    -- finally, if the wire connects two entities on different surfaces (e.g. compact circuit connection points), continue
                    or (new_entity.surface_index ~= target_wire_connector.owner.surface_index)) then
                return false
            end
        end
    end
    return true
end

---@param entity LuaEntity
---@param target_box BoundingBox
---@param ignore_collisions boolean
---@return boolean collides
function tools.has_collision(entity, target_box, ignore_collisions)
    if ignore_collisions then return false end

    local collision_entities = entity.surface.find_entities_filtered {
        area = target_box,
        type = { 'item-entity', 'item-request-proxy', 'resource', }, -- ignore those entities, we deal with them below
        invert = true,
    }

    if #collision_entities == 0 or (#collision_entities == 1 and collision_entities[1].unit_number == entity.unit_number) then return false end

    for _, collision_entity in pairs(collision_entities) do
        -- don't check the entity against itself
        if collision_entity.unit_number ~= entity.unit_number
            -- but when they collide, do not move
            and collision_mask_util.masks_collide(entity.prototype.collision_mask, collision_entity.prototype.collision_mask) then
            return true
        end
    end

    return false
end

-- ----------------------
-- stdlib stuff
-- ----------------------

---@param direction defines.direction
---@param distance number
---@return MapPosition
function tools.direction_to_vector(direction, distance)
    local vector = util.direction_vectors[direction] or { 0, 0 }
    return { x = vector[1] * distance, y = vector[2] * distance }
end

---@param direction defines.direction
---@return defines.direction new_direction
function tools.direction_next(direction)
    return (direction + 4) % 16
end

---@param direction defines.direction
---@return defines.direction new_direction
function tools.direction_previous(direction)
    return (direction - 4) % 16
end

---@param pos1 MapPosition
---@param pos2 MapPosition
---@return MapPosition
function tools.position_add(pos1, pos2)
    return { x = pos1.x + pos2.x, y = pos1.y + pos2.y }
end

---@param pos1 MapPosition
---@param pos2 MapPosition
---@return MapPosition
function tools.position_subtract(pos1, pos2)
    return { x = pos1.x - pos2.x, y = pos1.y - pos2.y }
end

---@param pos MapPosition
---@param direction defines.direction
---@param distance number
function tools.position_translate(pos, direction, distance)
    direction = direction or 0
    distance = distance or 1
    return tools.position_add(pos, tools.direction_to_vector(direction, distance))
end

---@param pos MapPosition
---@param radius number
---@return BoundingBox
function tools.position_expand_to_area(pos, radius)
    radius = radius or 1

    local left_top = { x = pos.x - radius, y = pos.y - radius }
    local right_bottom = { x = pos.x + radius, y = pos.y + radius }

    return { left_top = left_top, right_bottom = right_bottom }
end

---@param area BoundingBox
---@param direction defines.direction
---@param distance number
---@return BoundingBox
function tools.area_translate(area, direction, distance)
    return {
        left_top = tools.position_translate(area.left_top, direction, distance),
        right_bottom = tools.position_translate(area.right_bottom, direction, distance),
    }
end

---@param area BoundingBox
---@param amount number
---@return BoundingBox
function tools.area_expand(area, amount)
    local offset = { x = amount, y = amount }
    return {
        left_top = tools.position_subtract(area.left_top, offset),
        right_bottom = tools.position_add(area.right_bottom, offset),
    }
end

---@param pos MapPosition
---@param area BoundingBox
---@eturn BoundingBox area
function tools.area_normalize(pos, area)
    return {
        left_top = tools.position_subtract(area.left_top, pos),
        right_bottom = tools.position_subtract(area.right_bottom, pos),
    }
end

---@param new_pos MapPosition
---@param old_pos MapPosition
---@param area BoundingBox
---@eturn BoundingBox area
function tools.area_center(new_pos, old_pos, area)
    local normalized = tools.area_normalize(old_pos, area)
    return {
        left_top = tools.position_add(normalized.left_top, new_pos),
        right_bottom = tools.position_add(normalized.right_bottom, new_pos),
    }
end

---@generic T : any
---@param tbl `T`[] the array to convert
---@param as_bool boolean? map to true instead of value
---@return table<T, T|true> table the converted table
function tools.array_to_dictionary(tbl, as_bool)
    local new_tbl = {}
    for _, v in ipairs(tbl) do
        if type(v) == 'string' or type(v) == 'number' then new_tbl[v] = as_bool and true or v end
    end
    return new_tbl
end

return tools
