local chunk_func = {}


-- File variables
local damage_reduction = 15


-- Settings variables
local mod_name = "Stuckez12-Radiation-"


function chunk_func.add_chunk_data(surface, xpos, ypos, chest_data)
    local data = {
        chest = chest_data,
        damage = 0,
        effect_dist = 0,
        last_updated = 0
    }

    data = chunk_func.calc_chunk_damage(data)

    storage.chunk_data[surface] = storage.chunk_data[surface] or {}
    storage.chunk_data[surface][xpos] = storage.chunk_data[surface][xpos] or {}
    storage.chunk_data[surface][xpos][ypos] = data
end


function chunk_func.update_chunk_data(surface, xpos, ypos)
    if not storage.chunk_data[surface] then return end
    if not storage.chunk_data[surface][xpos] then return end
    if not storage.chunk_data[surface][xpos][ypos] then return end

    local chunk = storage.chunk_data[surface][xpos][ypos]
    local chests = chunk.chest

    local damage = 0

    for _, chest in pairs(chests) do
        if not chest.valid then goto invalid end

        local inv = chest.get_inventory(defines.inventory.chest)

        for i = 1, #inv do
            local item = inv[i]

            if item and item.valid_for_read then
                local value = storage.radiation_items[item.name]

                if not value then goto skip_item end

                damage = damage + (item.count * value)
            end

            ::skip_item::
        end

        ::invalid::
    end

    local chunk_radius = settings.global[mod_name .. "Chunk-Effect-Radius"].value
    local time_ext = 60 * 60 * 3

    chunk.damage = damage
    chunk.effect_dist = math.min(math.floor(damage / (50 * damage_reduction)), chunk_radius)
    chunk.last_updated = game.tick + time_ext + (20 * math.random(10))
end


function chunk_func.delete_chunk_data(surface, xpos, ypos)
    storage.chunk_data[surface][xpos][ypos] = nil
end


function chunk_func.calc_chunk_damage(chunk_data)
    if not chunk_data then return chunk_data end
    if not chunk_data.chests then return chunk_data end
    if next(chunk_data.chests) == nil then return chunk_data end

    local damage = 0

    for chest in chunk_data.chests do
        local inv = chest.get_inventory(define)

        for item, value in pairs(storage.radiation_items) do
            local count = inv.get_item_count(item)

            damage = damage + (count * value)
        end
    end

    chunk_data.damage = damage
    chunk_data.effect_dist = math.min(math.floor((damage / 50) + 0.5) + 1, 8)

    return chunk_data
end


function chunk_func.update_concurrent_damage(character)
    storage.player_connections = storage.player_connections or {}

    local char_data = storage.player_connections[character]

    if not char_data then return end

    local pos = {
        x = math.floor(character.position.x / 32),
        y = math.floor(character.position.y / 32)
    }
    local surface = character.surface.index

    if not char_data.chunk then char_data.chunk = pos; char_data.concurrent_damage = 0 end

    local chunk_radius = settings.global[mod_name .. "Chunk-Effect-Radius"].value

    if pos.x == char_data.chunk.x and pos.y == char_data.chunk.y then return end

    local concurrent_damage = 0
    local diameter = (chunk_radius * 2) + 1

    storage.chunk_data = storage.chunk_data or {}

    if not storage.chunk_data[surface] then return end

    for x = (pos.x - chunk_radius), diameter do
        if not storage.chunk_data[surface][x] then goto large_continue end

        for y = (pos.y - chunk_radius), diameter do
            if not storage.chunk_data[surface][x][y] then goto continue end

            local chunk = storage.chunk_data[surface][x][y]

            chunk.last_updated = chunk.last_updated or 0

            if chunk.last_updated >= game.tick then
                goto skip_re_calc
            end

            chunk_func.add_chunk_to_que(surface, x, y)

            ::skip_re_calc::

            local dx = math.abs(pos.x - x)
            local dy = math.abs(pos.y - y)
            local chunk_dist = math.max(dx, dy)

            local percent = (chunk_dist / chunk.effect_dist)

            if percent ~= percent then percent = 0 end

            local dist_percent = math.max(1 - percent, 0)

            local character_damage = math.max(chunk.damage * (dist_percent^2.75), 0)

            concurrent_damage = concurrent_damage + character_damage

            ::continue::
        end

        ::large_continue::
    end

    char_data.concurrent_damage = concurrent_damage
    char_data.chunk.x = pos.x
    char_data.chunk.y = pos.y
end


function chunk_func.chest_placed(event)
    local entity = event.entity

    if entity.type ~= "container" and entity.type ~= "logistic-container" then return end

    chunk_func.add_chest(entity.surface.index, math.floor(entity.position.x / 32), math.floor(entity.position.y / 32), entity)
end


function chunk_func.add_chest(surface, xpos, ypos, chest)
    storage.chunk_data = storage.chunk_data or {}
    storage.chunk_data[surface] = storage.chunk_data[surface] or {}
    storage.chunk_data[surface][xpos] = storage.chunk_data[surface][xpos] or {}
    if not storage.chunk_data[surface][xpos][ypos] then 
        chunk_func.add_chunk_data(surface, xpos, ypos, {chest})
    end

    local chunk = storage.chunk_data[surface][xpos][ypos]

    table.insert(chunk.chest, chest)
end


function chunk_func.chest_removed(event)
    local entity = event.entity

    if entity.type ~= "container" and entity.type ~= "logistic-container" then return end

    remove_chest(entity.surface.index, math.floor(entity.position.x / 32), math.floor(entity.position.y / 32), entity)
end


function remove_chest(surface, xpos, ypos, chest)
    storage.chunk_data = storage.chunk_data or {}
    storage.chunk_data[surface] = storage.chunk_data[surface] or {}
    storage.chunk_data[surface][xpos] = storage.chunk_data[surface][xpos] or {}
    if not storage.chunk_data[surface][xpos][ypos] then return end

    local chunk = storage.chunk_data[surface][xpos][ypos]

    chunk.chest[chest.unit_number] = nil

    local new_chest_list = {}

    for _, entity in pairs(chunk.chest) do
        if entity.valid then
            table.insert(new_chest_list, entity)
        end
    end

    chunk.chest = new_chest_list

    if not next(chunk.chest) then
        chunk_func.delete_chunk_data(surface, xpos, ypos)
    end
end


function chunk_func.add_chunk_to_que(surface, xpos, ypos)
    storage.chunk_que = storage.chunk_que or {}

    for _, chunk in ipairs(storage.chunk_que) do
        if chunk.surface == surface and chunk.x == xpos and chunk.y == ypos then
            return
        end
    end

    table.insert(storage.chunk_que, {surface=surface, x=xpos, y=ypos})
end


function chunk_func.update_chunks_in_que()
    storage.chunk_que = storage.chunk_que or {}

    for i=1, settings.global[mod_name .. "Chunks-Per-Call"].value do
        local chunk = storage.chunk_que[1]

        if chunk == nil then return end

        table.remove(storage.chunk_que, 1)

        chunk_func.update_chunk_data(chunk.surface, chunk.x, chunk.y)
    end
end


return chunk_func
