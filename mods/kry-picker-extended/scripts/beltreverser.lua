-------------------------------------------------------------------------------
--[Belt Reverser]--
-------------------------------------------------------------------------------
-- original mod name: Belt Reverser
-- original mod author: Cogito
-- original homepage: https://github.com/Cogito/belt-reverser
-- original description: "Reverse entire segments of belt"
-- original license: MIT

local Event = require('__kry_stdlib__/stdlib/event/event')
local Position = require('__kry_stdlib__/stdlib/area/position')
local Direction = require('__kry_stdlib__/stdlib/area/direction')
--local op_dir = Direction.opposite -- not needed, just call it directly

-- accounts for all of the new belt reverser mods, use those instead
if script.active_mods['belt-reverser'] then return end
if script.active_mods['belt-reverser2'] then return end
if script.active_mods['belt-reverser-space-age'] then return end
if script.active_mods['belt-reverserup-fixed'] then return end

local belt_types = {
    ['transport-belt'] = true,
    ['loader'] = true,
    ['underground-belt'] = true
}

-- replace the current line contents with contents
local function replace_line_contents(line, contents)
    line.clear()
    --local current = 0
    for key, data in pairs(contents) do
		-- inserts at position, with item table (name,count,quality), using stack_size of item count
        line.force_insert_at(data.position, data.stack, data.stack.count)
        --current = current + (0.03125 * 9)
    end
end

-- Get the reverse order of contents
local function get_contents(line)
    local contents = {}
	for key, data in pairs(line.get_detailed_contents()) do
		-- extract the name, count, and quality and place in stored table
		local new_stack = {name=data.stack.name,count=data.stack.count,quality=data.stack.quality}
		contents[key] = {position=data.position,stack=new_stack}
	end
	return contents
end

local function flip_lines(belt)
    local line_one = belt.get_transport_line(1)
    local line_two = belt.get_transport_line(2)
    --Get the contents before swapping otherwise we will be getting the wrong contents #77
    --Using a custom get_contents to keep ordering.
    local contents_one = get_contents(line_one)
    local contents_two = get_contents(line_two)
    replace_line_contents(line_one, contents_two)
    replace_line_contents(line_two, contents_one)
end

local function getBeltLike(surface, position, type)
    return surface.find_entities_filtered {position = position, type = type}[1]
end

local function isBeltTerminatingDownstream(belt, distance)
    distance = distance or 1
    local pos = Position(belt.position):translate(belt.direction, distance)
    local downstreamBelt = getBeltLike(belt.surface, pos, 'transport-belt')
    local downstreamUGBelt = getBeltLike(belt.surface, pos, 'underground-belt')
    local downstreamLoader = getBeltLike(belt.surface, pos, 'loader')

    if downstreamBelt and downstreamBelt.direction ~= Direction.opposite(belt.direction) then
        return false
    end
    if downstreamUGBelt and downstreamUGBelt.direction == belt.direction and downstreamUGBelt.belt_to_ground_type == 'input' then
        return false
    end
    if downstreamLoader and downstreamLoader.direction == belt.direction and downstreamLoader.loader_type == 'input' then
        return false
    end
    return true
end

local function isBeltSideloadingDownstream(belt, distance)
    distance = distance or 1
    local pos = Position(belt.position):translate(belt.direction, distance)
    local downstreamBelt = getBeltLike(belt.surface, pos, 'transport-belt')
    local downstreamUGBelt = getBeltLike(belt.surface, pos, 'underground-belt')
    local downstreamLoader = getBeltLike(belt.surface, pos, 'loader')
    if downstreamLoader then
        return false
    end
    if downstreamUGBelt and (downstreamUGBelt.direction == belt.direction or downstreamUGBelt.direction == Direction.opposite(belt.direction)) then
        return false
    end
    if downstreamBelt then
        if (downstreamBelt.direction == belt.direction or downstreamBelt.direction == Direction.opposite(belt.direction)) then
            return false
        else
            local up_pos = Position(downstreamBelt.position):translate(Direction.opposite(downstreamBelt.direction))
            local upstreamBelt = getBeltLike(belt.surface, up_pos, 'transport-belt')
            local upstreamUGBelt = getBeltLike(belt.surface, up_pos, 'underground-belt')
            local upstreamLoader = getBeltLike(belt.surface, up_pos, 'loader')

            local opposite_pos = Position(downstreamBelt.position):translate(belt.direction)
            local oppositeBelt = getBeltLike(belt.surface, opposite_pos, 'transport-belt')
            local oppositeUGBelt = getBeltLike(belt.surface, opposite_pos, 'underground-belt')
            local oppositeLoader = getBeltLike(belt.surface, opposite_pos, 'loader')

            local continuingBelt = true
            if not (upstreamBelt or upstreamUGBelt or upstreamLoader) then
                continuingBelt = false
            end
            if upstreamBelt and upstreamBelt.direction ~= downstreamBelt.direction then
                continuingBelt = false
            end
            if upstreamUGBelt and not (upstreamUGBelt.direction == downstreamBelt.direction and upstreamUGBelt.belt_to_ground_type == 'output') then
                continuingBelt = false
            end
            if upstreamLoader and upstreamLoader.direction ~= downstreamBelt.direction then
                continuingBelt = false
            end

            local sandwichBelt = true
            if not (oppositeBelt or oppositeUGBelt or oppositeLoader) then
                sandwichBelt = false
            end

            local opposite_direction = Direction.opposite(belt.direction)
            if oppositeBelt and oppositeBelt.direction ~= opposite_direction then
                sandwichBelt = false
            end
            if oppositeUGBelt and not (oppositeUGBelt.direction == opposite_direction and oppositeUGBelt.belt_to_ground_type == 'output') then
                sandwichBelt = false
            end
            if oppositeLoader and oppositeLoader.direction ~= opposite_direction then
                sandwichBelt = false
            end

            if not continuingBelt and not sandwichBelt then
                return false
            end
        end
    end
    return true
end

local function get_next_downstream_transport_line(belt)
    local distance = 1
    if belt.type == 'underground-belt' and belt.belt_to_ground_type == 'input' then
        if belt.neighbours then
            return belt.neighbours
        else
            return nil
        end
    end

    if belt.type == 'loader' then
        if belt.loader_type == 'output' then
            distance = 1.5
        else
            return nil
        end
    end

    local pos = Position(belt.position):translate(belt.direction, distance)
    local downstreamBelt = getBeltLike(belt.surface, pos, 'transport-belt')
    local downstreamUGBelt = getBeltLike(belt.surface, pos, 'underground-belt')
    local downstreamLoader = getBeltLike(belt.surface, pos, 'loader')

    if isBeltTerminatingDownstream(belt, distance) then
        return nil
    end
    if isBeltSideloadingDownstream(belt, distance) then
        return nil
    end
    local returnBelt = downstreamBelt or downstreamUGBelt or downstreamLoader
    return returnBelt
end

local function getUpstreamBeltInDirection(belt, direction, distance)
    distance = distance or 1
    local pos = Position(belt.position):translate(direction, distance)
    local upstreamBelt = getBeltLike(belt.surface, pos, 'transport-belt')
    local upstreamUGBelt = getBeltLike(belt.surface, pos, 'underground-belt')
    local upstreamLoader = getBeltLike(belt.surface, pos, 'loader')
    local opposite_direction = Direction.opposite(direction)
    if upstreamBelt and upstreamBelt.direction == opposite_direction then
        return upstreamBelt
    end
    if upstreamLoader and upstreamLoader.direction == opposite_direction and upstreamLoader.loader_type == 'output' then
        return upstreamLoader
    end
    if upstreamUGBelt and upstreamUGBelt.direction == opposite_direction and upstreamUGBelt.belt_to_ground_type == 'output' then
        return upstreamUGBelt
    end
    return nil
end

local function get_next_upstream_transport_line(belt)
    if belt.type == 'underground-belt' and belt.belt_to_ground_type == 'output' then
        if belt.neighbours then
            return belt.neighbours
        else
            return nil
        end
    end

    if belt.type == 'loader' then
        if belt.loader_type == 'input' then
            local linearBelt = getUpstreamBeltInDirection(belt, Direction.opposite(belt.direction), 1.5)
            if linearBelt then
                return linearBelt
            end
        end
        return nil
    end

    local linearBelt = getUpstreamBeltInDirection(belt, Direction.opposite(belt.direction))
    local leftTurnBelt = getUpstreamBeltInDirection(belt, Direction.next(belt.direction))
    local rightTurnBelt = getUpstreamBeltInDirection(belt, Direction.previous(belt.direction))
    if linearBelt then
        return linearBelt
    end
    if leftTurnBelt and not rightTurnBelt then
        return leftTurnBelt
    end
    if rightTurnBelt and not leftTurnBelt then
        return rightTurnBelt
    end
    return nil
end

local function find_start_of_transport_line(current_belt, initial_belt)
    local next_belt = get_next_upstream_transport_line(current_belt)
    if not next_belt then
        return current_belt
    end
    if next_belt == initial_belt then
        if next_belt.type == 'underground-belt' and next_belt.belt_to_ground_type == 'input' then
            return next_belt
        else
            return current_belt
        end
    end
    return find_start_of_transport_line(next_belt, initial_belt)
end

local function reverse_transport_entity(belt, direction)
    if belt.type == 'loader' or (belt.type == 'underground-belt' and belt.belt_to_ground_type == 'input') then
        belt.rotate()
    else
        belt.direction = direction
        flip_lines(belt)
    end
end

local function reverse_downstream_transport_line(current_belt, start_belt)
    local next_belt = get_next_downstream_transport_line(current_belt)
    if not next_belt or next_belt == start_belt then
        return -- we've nothing left to do as at end of belt
    else
        -- set next_belt direction to the opposite of current belt - this should reverse the entire line - but do it after reversing downstream
        reverse_downstream_transport_line(next_belt, start_belt)
        reverse_transport_entity(next_belt, Direction.opposite(current_belt.direction))
    end
end

local function reverse_entire_transport_line(event)
    local player = game.players[event.player_index]
    if player.selected and player.controller_type ~= defines.controllers.ghost and belt_types[player.selected.type] then
        local initial_belt = player.selected
        local start_belt = find_start_of_transport_line(initial_belt, initial_belt)
        local directionToTurnStartBelt = Direction.opposite(start_belt.direction)

        reverse_downstream_transport_line(start_belt, start_belt)

        reverse_transport_entity(start_belt, directionToTurnStartBelt)
    end
end
Event.register('picker-reverse-belts', reverse_entire_transport_line)