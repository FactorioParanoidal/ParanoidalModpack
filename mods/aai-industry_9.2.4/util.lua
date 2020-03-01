local util = {}

util.min = math.min
util.max = math.max
util.floor = math.floor
util.abs = math.abs
util.sqrt = math.sqrt
util.sin = math.sin
util.cos = math.cos
util.atan = math.atan
util.pi = math.pi
util.remove = table.remove
util.insert = table.insert
util.str_gsub = string.gsub

function util.send_message(text)
    for _, player in pairs(game.players) do
        player.print(text)
    end
end

function util.remove_from_table(list, item)
    local index = 0
    for _,_item in ipairs(list) do
        if item == _item then
            index = _
            break
        end
    end
    if index > 0 then
        util.remove(list, index)
    end
end

function util.transfer_burner (entity_a, entity_b)
    if entity_a.burner and entity_a.burner.currently_burning and entity_b.burner then
        entity_b.burner.currently_burning = entity_a.burner.currently_burning.name
        entity_b.burner.remaining_burning_fuel = entity_a.burner.remaining_burning_fuel
    end
end

function util.transfer_inventory (entity_a, entity_b, inventory_type)
    local inv_a = entity_a.get_inventory(inventory_type)
    local inv_b = entity_b.get_inventory(inventory_type)
    if inv_a and inv_b then
    local contents = inv_a.get_contents()
        for item_type, item_count in pairs(contents) do
            inv_b.insert({name=item_type, count=item_count})
        end
    end
end

function util.transfer_inventory_filters (entity_a, entity_b, inventory_type)
    local inv_a = entity_a.get_inventory(inventory_type)
    local inv_b = entity_b.get_inventory(inventory_type)
    if inv_a.supports_filters() and inv_b.supports_filters() then
        for i = 1, util.min(#inv_a, #inv_b) do
            local filter = inv_a.get_filter(i)
            if filter then
                inv_b.set_filter(i, filter)
            end
        end
    end
end

function util.transfer_equipment_grid (entity_a, entity_b)
    if not (entity_a.grid and entity_b.grid) then return end
    local grid_a = entity_a.grid
    local grid_b = entity_b.grid
    local equipment = grid_a.equipment
    for _, item in pairs(equipment) do
        local new_item = grid_b.put({
                name=item.name,
                position=item.position})
        if new_item then
            if item.shield and item.shield > 0 then
                new_item.shield = item.shield
            end
            if item.energy and item.energy > 0 then
                new_item.energy = item.energy
            end
        else
            util.send_message("Error transfering "..item.name)
        end
    end
end

function util.position_to_tile(position)
    return {x = math.floor(position.x), y = math.floor(position.y)}
end
function util.tile_to_position(tile_position)
    return {x = tile_position.x+0.5, y = tile_position.y+0.5}
end

function util.position_to_xy_string(position)
    return util.xy_to_string(position.x, position.y)
end

function util.xy_to_string(x, y)
    return util.floor(x) .. "_" .. util.floor(y)
end

function util.lerp_angles(a, b, alpha)
    local da = b - a

    if da < -0.5 then
        da = da + 1
    elseif da > 0.5 then
        da = da - 1
    end
    local na = a + da * alpha
    if na < 0 then
        na = na + 1
    elseif na > 1 then
        na = na - 1
    end
    return na
end

function util.array_to_vector(array)
    return {x = array[1], y = array[2]}
end

function util.vectors_delta(a, b)
    return {x = b.x - a.x, y = b.y - a.y}
end

function util.vectors_delta_length(a, b)
    return util.vector_length_xy(b.x - a.x, b.y - a.y)
end

function util.vector_length(a)
    return util.sqrt(a.x * a.x + a.y * a.y)
end

function util.vector_length_xy(x, y)
    return util.sqrt(x * x + y * y)
end

function util.vector_dot(a, b)
    return a.x * b.x + a.y * b.y
end

function util.vector_dot_projection(a, b)
    local n = util.vector_normalise(a)
    local d = util.vector_dot(n, b)
    return {x = n.x * d, y = n.y * d}
end

function util.vector_normalise(a)
    local length = util.vector_length(a)
    return {x = a.x/length, y = a.y/length}
end

function util.orientation_from_to(a, b)
    return util.vector_to_orientation_xy(b.x - a.x, b.y - a.y)
end

function util.orientation_to_vector(orientation, length)
    return {x = length * util.sin(orientation * 2 * util.pi), y = -length * util.cos(orientation * 2 * util.pi)}
end

function util.vectors_add(a, b)
    return {x = a.x + b.x, y = a.y + b.y}
end

function util.lerp_vectors(a, b, alpha)
    return {x = a.x + (b.x - a.x) * alpha, y = a.y + (b.y - a.y) * alpha}
end

function util.move_to(a, b, max_distance, eliptical)
    -- move rfom a to b with max_distance.
    -- if eliptical, reduce y change (i.e. turret muzzle flash offset)
    local eliptical_scale = 0.9
    local delta = util.vectors_delta(a, b)
    if eliptical then
        delta.y = delta.y / eliptical_scale
    end
    local length = util.vector_length(delta)
    if (length > max_distance) then
        local partial = max_distance / length
        delta = {x = delta.x * partial, y = delta.y * partial}
    end
    if eliptical then
        delta.y = delta.y * eliptical_scale
    end
    return {x = a.x + delta.x, y = a.y + delta.y}
end

function util.vector_to_orientation(v)
    return util.vector_to_orientation_xy(v.x, v.y)
end

function util.vector_to_orientation_xy(x, y)
    if x == 0 then
        if y > 0 then
            return 0.5
        else
            return 0
        end
    elseif y == 0 then
        if x < 0 then
            return 0.75
        else
            return 0.25
        end
    else
        if y < 0 then
            if x > 0 then
                return util.atan(x / -y) / util.pi / 2
            else
                return 1 + util.atan(x / -y) / util.pi / 2
            end
        else
            return 0.5 + util.atan(x / -y) / util.pi / 2
        end
    end
end

function util.direction_to_orientation(direction)
    if direction == defines.direction.north then
        return 0
    elseif direction == defines.direction.northeast then
        return 0.125
    elseif direction == defines.direction.east then
        return 0.25
    elseif direction == defines.direction.southeast then
        return 0.375
    elseif direction == defines.direction.south then
        return 0.5
    elseif direction == defines.direction.southwest then
        return 0.625
    elseif direction == defines.direction.west then
        return 0.75
    elseif direction == defines.direction.northwest then
        return 0.875
    end
    return 0
end

function util.signal_to_string(signal)
    return signal.type .. "__" .. signal.name
end

function util.signal_container_add(container, signal, count)
    if signal then
        if not container[signal.type] then
            container[signal.type] = {}
        end
        if container[signal.type][signal.name] then
            container[signal.type][signal.name].count = container[signal.type][signal.name].count + count
        else
            container[signal.type][signal.name] = {signal = signal, count = count}
        end
    end
end

function util.signal_container_add_inventory(container, entity, inventory)
    local inv = entity.get_inventory(inventory)
    if inv then
        local contents = inv.get_contents()
        for item_type, item_count in pairs(contents) do
            util.signal_container_add(container, {type="item", name=item_type}, item_count)
        end
    end
end

function util.signal_container_get(container, signal)
    if container[signal.type] and container[signal.type][signal.name] then
        return container[signal.type][signal.name]
    end
end

util.char_to_multiplier = {
    m = 0.001,
    c = 0.01,
    d = 0.1,
    h = 100,
    k = 1000,
    M = 1000000,
    G = 1000000000,
    T = 1000000000000,
    P = 1000000000000000,
}

function util.string_to_number(str)
    str = ""..str
    local number_string = ""
    local last_char = nil
    for i = 1, #str do
        local c = str:sub(i,i)
        if c == "." or tonumber(c) ~= nil then
            number_string = number_string .. c
        else
            last_char = c
            break
        end
    end
    if last_char and util.char_to_multiplier[last_char] then
        return tonumber(number_string) * util.char_to_multiplier[last_char]
    end
    return tonumber(number_string)
end

function util.replace(str, what, with)
    what = util.str_gsub(what, "[%(%)%.%+%-%*%?%[%]%^%$%%]", "%%%1") -- escape pattern
    with = util.str_gsub(with, "[%%]", "%%%%") -- escape replacement
    return util.str_gsub(str, what, with)
end


function util.replace_filenames_recursive(subject, what, with)
  if subject.filename then
    subject.filename = util.replace(subject.filename, what, with)
  else
    for _, sub in pairs(subject) do
      if (type(sub) == "table") then
        util.replace_filenames_recursive(sub, what, with)
      end
    end
  end
end

function util.allow_productivity(recipe_name)
  for _, prototype in pairs(data.raw["module"]) do
    if prototype.limitation and string.find(prototype.name, "productivity", 1, true) then
      table.insert(prototype.limitation, recipe_name)
    end
  end
end

return util
