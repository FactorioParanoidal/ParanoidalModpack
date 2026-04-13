--- Functions for working with directions and orientations.
--- @class StdLib.Area.Direction : StdLib.Core
--- @usage local Direction = require('__Kux-CoreLib__/stdlib/area/direction')
--- --@see defines.direction
local Direction = {
    __class = 'Direction',
    __index = require('__Kux-CoreLib__/stdlib/core') --[[@as StdLib.Core]]
}
setmetatable(Direction, Direction)

--- defines.direction.north
Direction.north = defines.direction.north
--- defines.direction.east
Direction.east = defines.direction.east
--- defines.direction.west
Direction.west = defines.direction.west
--- defines.direction.south
Direction.south = defines.direction.south
--- defines.direction.northeast
Direction.northeast = defines.direction.northeast
--- defines.direction.northwest
Direction.northwest = defines.direction.northwest
--- defines.direction.southeast
Direction.southeast = defines.direction.southeast
--- defines.direction.southwest
Direction.southwest = defines.direction.southwest

Direction.northnortheast=defines.direction.northnortheast
Direction.eastnortheast=defines.direction.eastnortheast
Direction.eastsoutheast=defines.direction.eastsoutheast
Direction.southsoutheast=defines.direction.southsoutheast
Direction.southsouthwest=defines.direction.southsouthwest
Direction.westsouthwest=defines.direction.westsouthwest
Direction.westnorthwest=defines.direction.westnorthwest
Direction.northnorthwest=defines.direction.northnorthwest

--- Returns the opposite direction
--- @param direction defines.direction the direction
--- @return defines.direction #the opposite direction
function Direction.opposite(direction)
    return (direction + 8) % 16 -- 2.0
end

--- Returns the next direction.
--> For entities that only support two directions, see @{opposite}.
--- @param direction defines.direction the starting direction
--- @param eight_way boolean? [opt=false] true to get the next direction in 8-way (note: not many prototypes support 8-way)
--- @return defines.direction #the next direction
function Direction.next(direction, eight_way)
    return (direction + (eight_way and 2 or 4)) % 16 --2.0
end

--- Returns the previous direction.
--> For entities that only support two directions, see @{opposite}.
--- @param direction defines.direction the starting direction
--- @param eight_way boolean? [opt=false] true to get the previous direction in 8-way (note: not many prototypes support 8-way)
--- @return defines.direction the next direction
function Direction.previous(direction, eight_way)
    return (direction + (eight_way and -2 or -4)) % 16 --2.0
end

--- Returns an orientation from a direction.
--- @param direction defines.direction
--- @return float
function Direction.to_orientation(direction)
    return direction / 16 --2.0
end

--- Returns a vector from a direction.
--- @param direction defines.direction
--- @param distance number? [opt = 1]
--- @return Position
function Direction.to_vector(direction, distance)
    distance = distance or 1
    local x, y = 0, 0
	--[[
    if     direction == Direction.north     then y = y - distance
    elseif direction == Direction.northeast then x, y = x + distance, y - distance
    elseif direction == Direction.east      then x = x + distance
    elseif direction == Direction.southeast then x, y = x + distance, y + distance
    elseif direction == Direction.south     then y = y + distance
    elseif direction == Direction.southwest then x, y = x - distance, y + distance
    elseif direction == Direction.west      then x = x - distance
    elseif direction == Direction.northwest then x, y = x - distance, y - distance
    end
	]]

	if direction == Direction.north then x, y = 0, -distance
	elseif direction == Direction.northnortheast then x, y = distance * 0.5, -distance
	elseif direction == Direction.northeast then x, y = distance, -distance
	elseif direction == Direction.eastnortheast then x, y = distance, -distance * 0.5
	elseif direction == Direction.east then x, y = distance, 0
	elseif direction == Direction.eastsoutheast then x, y = distance, distance * 0.5
	elseif direction == Direction.southeast then x, y = distance, distance
	elseif direction == Direction.southsoutheast then x, y = distance * 0.5, distance
	elseif direction == Direction.south then x, y = 0, distance
	elseif direction == Direction.southsouthwest then x, y = -distance * 0.5, distance
	elseif direction == Direction.southwest then x, y = -distance, distance
	elseif direction == Direction.westsouthwest then x, y = -distance, distance * 0.5
	elseif direction == Direction.west then x, y = -distance, 0
	elseif direction == Direction.westnorthwest then x, y = -distance, -distance * 0.5
	elseif direction == Direction.northwest then x, y = -distance, -distance
	elseif direction == Direction.northnorthwest then x, y = -distance * 0.5, -distance
	end
    return { x = x, y = y }
end

--NEW: calc real veactor
--- Returns a vector from a direction.
--- @param direction defines.direction
--- @param distance number? [opt = 1]
--- @return Position
function Direction.to_vector2(direction, distance, round)
    distance = distance or 1
    local x, y = 0, 0

	if     direction == Direction.north then x, y = 0, -distance
	elseif direction == Direction.northnortheast then x, y = math.floor(0.9239 * distance), -math.floor(0.3827 * distance)
	elseif direction == Direction.northeast then x, y = math.floor(0.7071 * distance), -math.floor(0.7071 * distance)
	elseif direction == Direction.eastnortheast then x, y = math.floor(0.3827 * distance), -math.floor(0.9239 * distance)
	elseif direction == Direction.east then x, y = distance, 0
	elseif direction == Direction.eastsoutheast then x, y = math.floor(0.9239 * distance), math.floor(0.3827 * distance)
	elseif direction == Direction.southeast then x, y = math.floor(0.7071 * distance), math.floor(0.7071 * distance)
	elseif direction == Direction.southsoutheast then x, y = math.floor(0.3827 * distance), math.floor(0.9239 * distance)
	elseif direction == Direction.south then x, y = 0, distance
	elseif direction == Direction.southsouthwest then x, y = -math.floor(0.3827 * distance), math.floor(0.9239 * distance)
	elseif direction == Direction.southwest then x, y = -math.floor(0.7071 * distance), math.floor(0.7071 * distance)
	elseif direction == Direction.westsouthwest then x, y = -math.floor(0.9239 * distance), math.floor(0.3827 * distance)
	elseif direction == Direction.west then x, y = -distance, 0
	elseif direction == Direction.westnorthwest then x, y = -math.floor(0.9239 * distance), -math.floor(0.3827 * distance)
	elseif direction == Direction.northwest then x, y = -math.floor(0.7071 * distance), -math.floor(0.7071 * distance)
	elseif direction == Direction.northnorthwest then x, y = -math.floor(0.3827 * distance), -math.floor(0.9239 * distance)
	end
    return { x = x, y = y }
end

-- Deprecated
if false then
    local Orientation = require('__Kux-CoreLib__/stdlib/area/orientation')

    Direction.opposite_direction = Direction.opposite
    Direction.direction_to_orientation = Direction.to_orientation

    function Direction.orientation_to_4way(orientation)
        return Orientation.to_direction(orientation)
    end

    function Direction.orientation_to_8way(orientation)
        return Orientation.to_direction(orientation, true)
    end

    function Direction.next_direction(direction, reverse, eight_way)
        return (direction + (eight_way and ((reverse and -2) or 2) or ((reverse and -4) or 4))) % 16
    end
end

return Direction
