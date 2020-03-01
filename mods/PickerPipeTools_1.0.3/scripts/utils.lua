local utils = {}

utils.truthy = {['on'] = true, ['true'] = true}
utils.falsey = {['off'] = true, ['false'] = true}

local ev = defines.events
utils.selection_tool_event = {
    [ev.on_player_selected_area] = true,
    [ev.on_player_alt_selected_area] = true
}

utils.color = {
    yellow = {r = 1, g = 1},
    green = {g = 1},
    red = {r = 1}
}

function utils.get_ew(deltaX)
    return deltaX > 0 and defines.direction.west or defines.direction.east
end

function utils.get_ns(deltaY)
    return deltaY > 0 and defines.direction.north or defines.direction.south
end

function utils.get_direction(entity_position, neighbour_position)
    local abs = math.abs
    local delta_x = entity_position.x - neighbour_position.x
    local delta_y = entity_position.y - neighbour_position.y
    if delta_x ~= 0 then
        if delta_y == 0 then
            return utils.get_ew(delta_x)
        else
            local adx, ady = abs(delta_x), abs(delta_y)
            if adx > ady then
                return utils.get_ew(delta_x)
            else --? Exact diagonal relations get returned as a north/south relation.
                return utils.get_ns(delta_y)
            end
        end
    else
        return utils.get_ns(delta_y)
    end
end

return utils
