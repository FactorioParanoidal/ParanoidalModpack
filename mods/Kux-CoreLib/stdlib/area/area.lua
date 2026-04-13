--- Tools for working with bounding boxes.
--- @class StdLib.Area : StdLib.Core
--- @usage local Area = require('__Kux-CoreLib__/stdlib/area/area')
--- @see StdLib.Area.Position
--- @see BoundingBox
--- @see Position
local Area = {
	__class = 'Area',
	__index = require('__Kux-CoreLib__/stdlib/core') --[[@as StdLib.Core]]
}
setmetatable(Area, Area)

local Position = require('__Kux-CoreLib__/stdlib/area/position') --[[@as StdLib.Area.Position]]

local math = require('__Kux-CoreLib__/stdlib/utils/math') --[[@as StdLib.Utils.Math]]
local string = require('__Kux-CoreLib__/stdlib/utils/string') --[[@as StdLib.Utils.String]]
local abs, floor, max = math.abs, math.floor, math.max

local metatable

--- Constructor Methods
-- @section Constructors

Area.__call = function(_, ...)
    local type = type((...))
    if type == 'table' then
        local t = (...)
        if t.left_top and t.right_bottom then
            return Area.load(...)
        else
            return Area.new(...)
        end
    elseif type == 'string' then
        return Area.from_string(...)
    else
        return Area.construct(...)
    end
end

local function new_area(lt, rb, o)
    return setmetatable({ left_top = lt, right_bottom = rb, orientation = o }, metatable)
end

--- Converts an area in either array or table format to an area with a metatable.
-- Returns itself if it already has a metatable
--- @param area BoundingBox the area to convert
--- @return BoundingBox #a converted area
function Area.new(area)
    local left_top = Position.new(area.left_top or area[1])
    local right_bottom = Position.new(area.right_bottom or area[2] or area[1])
    return setmetatable({ left_top = left_top, right_bottom = right_bottom, orientation = area.orientation }, metatable)
end

--- Creates an area from number parameters.
--- @tparam x1 number [opt=0] x-position of left_top, first position
--- @tparam y1 number [opt=0] y-position of left_top, first position
--- @tparam x2 number [opt=0] x-position of right_bottom, second position
--- @tparam y2 number [opt=0] y-position of right_bottom, second position
--- @treturn BoundingBox #the area in a table format
function Area.construct(...)
    local args = type((...)) == 'table' and { select(2, ...) } or { select(1, ...) }

    local lt = Position.construct_xy(args[1] or 0, args[2] or 0)
    local rb = Position.construct_xy(args[3] or lt.x, args[4] or lt.y)

    return setmetatable({ left_top = lt, right_bottom = rb }, metatable)
end



--- Loads the metatable into the passed Area without creating a new one.
--- @param area BoundingBox the Area to set the metatable onto
--- @return BoundingBox #the Area with metatable attached
function Area.load(area)
    area.left_top = Position.load(area.left_top)
    area.right_bottom = Position.load(area.right_bottom)
    return setmetatable(area, metatable)
end

--- Converts an area string to an area.
--- @param area_string string the area to convert
--- @return BoundingBox
function Area.from_string(area_string)
    return Area(load('return ' .. area_string)())
end

--- Converts a string key area to an area.
--- @param area_string string the area to convert
--- @return BoundingBox
function Area.from_key(area_string)
	local function n(v) return tonumber(v) or error('Invalid number: ' .. v) end
    local tab = string.split(area_string, ',', false, tonumber)
    local lt = Position.new { x = n(tab[1]), y = n(tab[2]) }
    local rb = Position.new { x = n(tab[3]), y = n(tab[4]) }
    return new_area(lt, rb)
end

--- Area Methods
-- @section Methods

--- Stores the area for recall later, not deterministic.
-- Only the last area stored is saved.
--- @param area BoundingBox
function Area.store(area)
    rawset(getmetatable(area), '_saved', area)
    return area
end

--- Recalls the stored area.
--- @param area BoundingBox
--- @return BoundingBox #the stored area
function Area.recall(area)
    return rawget(getmetatable(area), '_saved')
end

--- Normalizes the given area.
-- <ul>
-- <li>Swaps the values between `right_bottom.x` & `left_top.x` **IF** `right_bottom.x` < `left_top.x`
-- <li>Swaps the values between `right_bottom.y` & `left_top.y` **IF** `right_bottom.y` < `left_top.y`
-- </ul>
--- @param area BoundingBox the area to normalize
--- @return BoundingBox #a new normalized area
function Area.normalize(area)
    local left_top = Position.new(area.left_top)
    local right_bottom = Position.new(area.right_bottom)

    if right_bottom.x < left_top.x then left_top.x, right_bottom.x = right_bottom.x, left_top.x end
    if right_bottom.y < left_top.y then left_top.y, right_bottom.y = right_bottom.y, left_top.y end

    return new_area(left_top, right_bottom, area.orientation)
end

--- Normalize an area in place.
--- @param area BoundingBox the area to normalize
--- @return BoundingBox area #The area normalized in place
function Area.normalized(area)
    local lt, rb = area.left_top, area.right_bottom
    if rb.x < lt.x then lt.x, rb.x = rb.x, lt.x end
    if rb.y < lt.y then lt.y, rb.y = rb.y, lt.y end
    return area
end

--- Convert area from pixels.
--- @param area BoundingBox
--- @return BoundingBox
function Area.from_pixels(area)
    return new_area(Position.from_pixels(area.left_top), Position.from_pixels(area.right_bottom), area.orientation)
end

--- Convert area to pixels.
--- @param area BoundingBox
--- @return BoundingBox
function Area.to_pixels(area)
    return new_area(Position.to_pixels(area.left_top), Position.to_pixels(area.right_bottom), area.orientation)
end

--- Rounds an areas points to its closest integer.
--- @param area BoundingBox
--- @return BoundingBox
function Area.round(area)
    return new_area(Position.round(area.left_top), Position.round(area.right_bottom), area.orientation)
end

--- Ceils an area by increasing the size of the area outwards
--- @param area BoundingBox the area to round
--- @return BoundingBox
function Area.ceil(area)
    return new_area(Position.floor(area.left_top), Position.ceil(area.right_bottom), area.orientation)
end

--- Floors an area by decreasing the size of the area inwards.
--- @param area BoundingBox the area to round
--- @return BoundingBox
function Area.floor(area)
    return new_area(Position.ceil(area.left_top), Position.floor(area.right_bottom), area.orientation)
end

-- When looking for tile center points, look inwards on right bottom
-- when x or y is int. This will keep the area with only the tiles it
-- contains.
local function right_bottom_center(pos)
    local x, y
    local fx, fy = floor(pos.x), floor(pos.y)
    x = fx == pos.x and (fx - 0.5) or (fx + 0.5)
    y = fy == pos.y and (fy - 0.5) or (fy + 0.5)
    return Position.construct_xy(x, y)
end

--- Gets the center positions of the tiles where the given area's two positions reside.
--- @param area BoundingBox
--- @return BoundingBox #the area with its two positions at the center of the tiles in which they reside
function Area.center_points(area)
    return new_area(Position.center(area.left_top), right_bottom_center(area.right_bottom), area.orientation)
end

---@class BoundingBox.corners : BoundingBox.0
---@field left_bottom Position
---@field right_top Position

--- add left_bottom and right_top to the area
--- @param area BoundingBox
--- @return BoundingBox.corners #the area with left_bottom and right_top included
function Area.corners(area)
	---@cast area BoundingBox.corners
    local lt, rb = area.left_top, area.right_bottom
    local lb = area.left_bottom or Position.construct_xy(0, 0)
    local rt = area.right_top or Position.construct_xy(0, 0)
    lb.x, lb.y = lt.x, rb.y
    rt.x, rt.y = rb.x, lt.y
    area.left_bottom = lb
    area.right_top = rt

    return area
end

--- Flip an area such that the value of its width becomes its height, and the value of its height becomes its width.
--- @param area BoundingBox the area to flip
--- @return BoundingBox #the fliped area
function Area.flip(area)
    local w, h = Area.dimensions(area)
    if h > w then
        local rad = h / 2 - w / 2
        return Area.adjust(area, { rad, -rad })
    elseif w > h then
        local rad = w / 2 - h / 2
        return Area.adjust(area, { -rad, rad })
	else
		return area -- no point flipping a square
    end
end

--- Return a non zero sized area by expanding if needed
--- @param area BoundingBox the area to check
--- @param amount number|Vector the amount to expand
--- @return BoundingBox the area
function Area.non_zero(area, amount)
    amount = amount or 0.01
    return Area.size(area) == 0 and Area.expand(area, amount) or area
end

--- Returns the area to the diameter from left_top
--- @param area BoundingBox
--- @param diameter number
--- @return BoundingBox
function Area.to_diameter(area, diameter)
    diameter = diameter or 0.1
    return new_area(Position.new(area.left_top), Position.add(area.left_top + diameter))
end

--- Returns the smallest sized area.
--- @param area BoundingBox
--- @param area2 BoundingBox
--- @return BoundingBox the smallest area
function Area.min(area, area2)
    return (Area.size(Area) <= Area.size(area2) and area) or area2
end

--- Returns the largest sized area.
--- @param area BoundingBox
--- @param area2 BoundingBox
--- @return BoundingBox the largest area
function Area.max(area, area2)
    return (Area.size(area) >= Area.size(area2) and area) or area2
end

--- Shrinks the area inwards by the given amount.
-- The area shrinks inwards from top-left towards the bottom-right, and from bottom-right towards the top-left.
--- @param area BoundingBox the area to shrink
--- @param amount number|Vector the amount to shrink
--- @return BoundingBox the area reduced by amount
function Area.shrink(area, amount)
    return new_area(Position.add(area.left_top, amount), Position.subtract(area.right_bottom, amount))
end

--- Expands the area outwards by the given amount.
--- @param area BoundingBox the area
--- @param amount number|Vector to expand each edge of the area outwards by
--- @return BoundingBox the area expanded by amount
-- @see Area.shrink
function Area.expand(area, amount)
    return new_area(Position.subtract(area.left_top, amount), Position.add(area.right_bottom, amount))
end

--- Adjust an area by shrinking or expanding.
-- Imagine pinching & holding with fingers the top-left & bottom-right corners of a 2D box and pulling outwards to expand and pushing inwards to shrink the box.
-- @usage local area = Area.adjust({{-2, -2}, {2, 2}}, {4, -1})
-- -- returns {left_top = {x = -6, y = -1}, right_bottom = {x = 6, y = 1}}
--- @param area BoundingBox the area to adjust
--- @param amount number|Vector the vectors to use
--- @return BoundingBox # adjusted bounding box
function Area.adjust(area, amount)
    local vec = Position(amount)
    area = Area.new(area)

    -- shrink or expand on x vector
    if vec.x > 0 then
        area = Area.expand(area, { vec.x, 0 })
    elseif vec.x < 0 then
        area = Area.shrink(area, { abs(vec.x), 0 })
    end

    -- shrink or expand on y vector
    if vec.y > 0 then
        area = Area.expand(area, { 0, vec.y })
    elseif vec.y < 0 then
        area = Area.shrink(area, { 0, abs(vec.y) })
    end

    return area
end

--- Offsets the area by the `{x, y}` values.
--- @param area BoundingBox the area to offset
--- @param pos Position the position to which the area will offset
--- @return BoundingBox #the area offset by the position
function Area.offset(area, pos)
    local vec = Position(pos)

    return new_area(Position.add(area.left_top, vec), Position.add(area.right_bottom, vec))
end

--- Translates an area in the given direction.
--- @param area BoundingBox the area to translate
--- @param direction defines.direction the direction of translation
--- @param distance number the distance of the translation
--- @return BoundingBox #the area translated
function Area.translate(area, direction, distance)
    direction = direction or 0
    distance = distance or 1

    return new_area(Position.translate(area.left_top, direction, distance),
        Position.translate(area.right_bottom, direction, distance))
end

--- Set an area to the whole size of the surface.
--- @param area BoundingBox
--- @param surface LuaSurface
--- @return BoundingBox
function Area.to_surface_size(area, surface)
    local w, h = surface.map_gen_settings.width, surface.map_gen_settings.height
    area.left_top.x = -(w / 2)
    area.right_bottom.x = (w / 2)
    area.left_top.y = -(h / 2)
    area.right_bottom.y = (h / 2)
    return area
end

--- Shrinks an area to the size of the surface if it is bigger.
--- @param area BoundingBox
--- @param surface LuaSurface
--- @return BoundingBox
function Area.shrink_to_surface_size(area, surface)
    local w, h = surface.map_gen_settings.width, surface.map_gen_settings.height
    if abs(area.left_top.x) > w / 2 then
        area.left_top.x = -(w / 2)
        area.right_bottom.x = (w / 2)
    end
    if abs(area.left_top.y) > w / 2 then
        area.left_top.y = -(h / 2)
        area.right_bottom.y = (h / 2)
    end
    return area
end

--- Return the chunk coordinates from an area.
--- @param area BoundingBox
--- @return BoundingBox #Chunk position coordinates
function Area.to_chunk_coords(area)
    return Area.load {
        left_top = { x = floor(area.left_top.x / 32), y = floor(area.left_top.y / 32) },
        right_bottom = { x = floor(area.right_bottom.x / 32), y = floor(area.right_bottom.y / 32) }
    }
end

--- Position Conversion Functions
-- @section ConversionFunctions

--- Calculates the center of the area and returns the position.
--- @param area BoundingBox the area
--- @return Position #the center of the area
function Area.center(area)
    local dist_x = area.right_bottom.x - area.left_top.x
    local dist_y = area.right_bottom.y - area.left_top.y

    return Position.construct_xy(area.left_top.x + (dist_x / 2), area.left_top.y + (dist_y / 2))
end

--- Area Functions
-- @section Functions

--- Return a suitable string for using as a table key
--- @param area BoundingBox
-- @return string
function Area.to_key(area)
    return table.concat({ area.left_top.x, area.left_top.y, area.right_bottom.x, area.right_bottom.y }, ',')
end

--- Converts an area to a string.
--- @param area BoundingBox the area to convert
--- @return string #the string representation of the area
function Area.to_string(area)
    local left_top = 'left_top = ' .. area.left_top
    local right_bottom = 'right_bottom = ' .. area.right_bottom

    local orientation = area.orientation and ', ' .. area.orientation or ''

    return '{' .. left_top .. ', ' .. right_bottom .. orientation .. '}'
end

--- Converts an area to an ltx, lty / rbx, rby string.
--- @param area BoundingBox the area to convert
--- @return string the string representation of the area
function Area.to_string_xy(area)
    return table.concat(area.left_top, ', ') .. ' / ' .. table.concat(area.right_bottom, ', ')
end

--- Is this a non zero sized area
--- @param area BoundingBox
--- @return boolean
function Area.is_zero(area)
    return Area.size(area) == 0
end

--- Is the area normalized.
--- @param area BoundingBox
--- @return boolean
function Area.is_normalized(area)
    return area.right_bottom.x >= area.left_top.x and area.right_bottom.y >= area.left_top.y
end

--- Is the area non-zero and normalized.
--- @param area BoundingBox
--- @return boolean
function Area.valid(area)
    return Area.is_normalized(area) and Area.size(area) ~= 0
end

--- Is this a simple area. {{num, num}, {num, num}}
--- @param area BoundingBox
--- @return boolean
function Area.is_simple_area(area)
    return Position.is_simple_position(area[1]) and Position.is_simple_position(area[2])
end

--- Is this a complex area {left_top = {x = num, y = num}, right_bottom = {x = num, y = num}}
--- @param area BoundingBox
--- @return boolean
function Area.is_complex_area(area)
    return Position.is_complex_position(area.left_top) and Position.is_complex_position(area.right_bottom)
end

--- Is this and area of any kind.
--- @param area BoundingBox
--- @return boolean
function Area.is_area(area)
    return Area.is_Area(area) or Area.is_complex_area(area) or Area.is_simple_area(area)
end

--- Does the area have the class attached
--- @param area BoundingBox
--- @return boolean
function Area.is_Area(area)
    return getmetatable(area) == metatable
end

--- Unpack an area into a tuple.
--- @param area BoundingBox
--- @return number lt.x
--- @return number lt.y
--- @return number rb.x
--- @return number rb.y
--- @return float orientation
function Area.unpack(area)
    return area.left_top.x, area.left_top.y, area.right_bottom.x, area.right_bottom.y, area.orientation
end

--- Unpack an area into a tuple of position tables.
--- @param area BoundingBox
--- @return Position left_top
--- @return Position right_bottom
function Area.unpack_positions(area)
    return area.left_top, area.right_bottom
end

--- Pack an area into an array.
--- @param area BoundingBox
--- @return BoundingBox array
function Area.pack(area)
    return { area.left_top.x, area.left_top.y, area.right_bottom.x, area.right_bottom.y, area.orientation }
end

--- Pack an area into a simple bounding box array
--- @param area BoundingBox
--- @return BoundingBox #simple array
function Area.pack_positions(area)
    return { { area.left_top.x, area.left_top.y }, { area.right_bottom.x, area.right_bottom.y } }
end

--- Gets the properties of the given area.
-- This function returns a total of four values that represent the properties of the given area.
--- @param area BoundingBox the area from which to get the size
--- @return number the size of the area &mdash; (width &times; height)
--- @return number the width of the area
--- @return number the height of the area
--- @return number the perimeter of the area &mdash; (2 &times; (width + height))
function Area.size(area)
    local width = Area.width(area)
    local height = Area.height(area)
    local area_size = width * height
    local perimeter = (width + width) * 2
    return area_size, width, height, perimeter
end

--- Return the rectangle.
--- @param area BoundingBox
--- @return number left_top.x
--- @return number left_top.y
--- @return number width
--- @return number height
function Area.rectangle(area)
    return area.left_top.x, area.left_top.y, Area.width(area), Area.height(area)
end

--- The width of the area.
--- @param area BoundingBox
--- @return number width
function Area.width(area)
    return abs(area.left_top.x - area.right_bottom.x)
end

--- The height of an area.
--- @param area BoundingBox
--- @return number width
function Area.height(area)
    return abs(area.left_top.y - area.right_bottom.y)
end

--- The dimensions of an area.
--- @param area BoundingBox
--- @return number width
--- @return number height
function Area.dimensions(area)
    return Area.width(area), Area.height(area)
end

--- The Perimiter of an area.
--- @param area BoundingBox
--- @return number width
function Area.perimeter(area)
    return (Area.width(area) + Area.height(area)) * 2
end

--- Returns true if two areas are the same.
--- @param area1 BoundingBox
--- @param area2 BoundingBox
--- @return boolean true if areas are the same
function Area.equals(area1, area2)
    if not (area1 and area2) then return false end
    local ori = area1.orientation or 0 == area2.orientation or 0
    return ori and area1.left_top == area2.left_top and area1.right_bottom == area2.right_bottom
end

--- Is area1 smaller in size than area2
--- @param area1 BoundingBox
--- @param area2 BoundingBox
--- @return boolean #is area1 less than area2 in size
function Area.less_than(area1, area2)
    if type(area1) == 'number' then
        return area1 < Area.size(area2)
    elseif type(area2) == 'number' then
        return Area.size(area1) < area2
    else
        return Area.size(area1) < Area.size(area2)
    end
end

--- Is area1 smaller or equal in size to area2.
--- @param area1 BoundingBox
--- @param area2 BoundingBox
--- @return boolean #is area1 less than or equal to area2 in size
-- @local
function Area.less_than_eq(area1, area2)
    if type(area1) == 'number' then
        return area1 <= Area.size(area2)
    elseif type(area2) == 'number' then
        return Area.size(area1) <= area2
    else
        return Area.size(area1) <= Area.size(area2)
    end
end

--- Does either area overlap/collide with the other area.
--- @param area1 BoundingBox
--- @param area2 BoundingBox
--- @return boolean
function Area.collides(area1, area2)
    local x1, y1 = Position.unpack(area1.left_top)
    local _, w1, h1 = Area.size(area1)
    local x2, y2 = Position.unpack(area2.left_top)
    local _, w2, h2 = Area.size(area2)

    return not ((x1 > x2 + w2) or (x1 > y2 + h2) or (x2 > x1 + w1) or (y2 > y1 + h1))
end

--- Are the passed positions all located in an area.
--- @param area BoundingBox the search area
--- @param positions Position[] array of Position
--- @return boolean #true if the positions are located in the area
function Area.contains_positions(area, positions)
    for _, pos in pairs(positions) do if not Position.inside(pos, area) then return false end end
    return true
end

--- Are all passed areas completly inside an area.
--- @param area BoundingBox
--- @param areas BoundingBox[] array of BoundingBox
--- @return boolean
function Area.contains_areas(area, areas)
    for _, inner in pairs(areas) do
        if not Area.contains_positions(area, { Area.unpack_positions(inner) }) then return false end
    end
    return true
end

--- Do all passed areas collide with an area.
--- @param area BoundingBox
--- @param areas BoundingBox[] array of BoundingBox
--- @return boolean
function Area.collides_areas(area, areas)
    for _, inner in pairs(areas) do if not Area.collides(area, inner) then return false end end
    return true
end

--- Area Iterators
-- @section Area Iterators

--- Iterates an area.
-- @usage
-- local area = {{0, -5}, {3, -3}}
-- for x,y in Area.iterate(area) do
--   -- return x, y values
-- end
-- for position in Area.iterate(area, true) do
--   -- returns a position object
-- end
-- -- Iterates from left_top.x to right_bottom.x then goes down y until right_bottom.y
--- @param area BoundingBox the area to iterate
--- @param as_position boolean? [opt=false] return a position object
--- @param inside boolean? [opt=false] only return values that contain the areas tiles
--- @param step number? [opt=1] size to increment
--- @return function #an iterator
function Area.iterate(area, as_position, inside, step)
    step = step or 1
    local x, y = area.left_top.x, area.left_top.y
    local max_x = area.right_bottom.x - (inside and 0.001 or 0)
    local max_y = area.right_bottom.y - (inside and 0.001 or 0)
    local first = true

    local function iterator()
        if first then
            first = false
        elseif x <= max_x and x + step <= max_x then
            x = x + step
        elseif y <= max_y and y + step <= max_y then
            x = area.left_top.x
            y = y + step
        else
            return
        end
        return (as_position and Position.construct_xy(x, y)) or x, (not as_position and y) or nil
    end

    return iterator
end

--- Iterates the given area in a spiral as depicted below, from innermost to the outermost location.
-- <p>![](http://i.imgur.com/EwfO0Es.png)
-- @usage for x, y in Area.spiral_iterate({{-2, -1}, {2, 1}}) do
-- print('(' .. x .. ', ' .. y .. ')')
-- end
-- prints: (0, 0) (1, 0) (1, 1) (0, 1) (-1, 1) (-1, 0) (-1, -1) (0, -1) (1, -1) (2, -1) (2, 0) (2, 1) (-2, 1) (-2, 0) (-2, -1)
--- @param area BoundingBox the area on which to perform a spiral iteration
--- @param as_position boolean return a position object instead of x, y
--- @return function #the iterator function
--- @return BoundingBox area #The area being iterated over.
--- @return number #A counter or status value, depending on the iteration logic.
function Area.spiral_iterate(area, as_position)
    local rx = area.right_bottom.x - area.left_top.x + 1
    local ry = area.right_bottom.y - area.left_top.y + 1
    local half_x = floor(rx / 2)
    local half_y = floor(ry / 2)
    local center_x = area.left_top.x + half_x
    local center_y = area.left_top.y + half_y
    local size = max(rx, ry) ^ 2

    local x, y, dx, dy = 0, 0, 0, -1

    local positions = {}
    local index = 1
    for _ = 1, size do
        if -(half_x) <= x and x <= half_x and -(half_y) <= y and y <= half_y then
            positions[#positions + 1] = { x = x, y = y }
        end
        if x == y or (x < 0 and x == -y) or (x > 0 and x == 1 - y) then
            local temp = dx
            dx = -(dy)
            dy = temp
        end
        x = x + dx
        y = y + dy
    end

    local function iterator()
        if index > #positions then return end
        local pos = positions[index]
        index = index + 1
        pos.x = pos.x + center_x
        pos.y = pos.y + center_y

        return (as_position and Position.load(pos)) or pos.x, (not as_position and pos.y) or nil
    end
    return iterator, area, 0
end

--- Area Arrays
-- @section Area Arrays

function Area.Positions(area, inside, step)
    local positions = {}

    for pos in Area.iterate(area, true, inside, step) do positions[#positions + 1] = pos end
    return positions
end

--- Metamethods
-- @section Metamethods

local function __add(area1, area2)
    area1, area2 = Area(area1), Area(area2)
    area1.left_top = area1.left_top + area2.left_top
    area1.right_bottom = area1.right_bottom + area2.right_bottom
    return area1
end

local function __sub(area1, area2)
    area1, area2 = Area(area1), Area(area2)
    area1.left_top = area1.left_top - area2.left_top
    area1.right_bottom = area1.right_bottom - area2.right_bottom
    return area1
end

local function __mul(area1, area2)
    area1, area2 = Area(area1), Area(area2)
    area1.left_top = area1.left_top * area2.left_top
    area1.right_bottom = area1.right_bottom * area2.right_bottom
    return area1
end

local function __div(area1, area2)
    area1, area2 = Area(area1), Area(area2)
    area1.left_top = area1.left_top / area2.left_top
    area1.right_bottom = area1.right_bottom / area2.right_bottom
    return area1
end

local function __mod(area1, area2)
    area1, area2 = Area(area1), Area(area2)
    area1.left_top = area1.left_top % area2.left_top
    area1.right_bottom = area1.right_bottom % area2.right_bottom
    return area1
end

local function __unm(area)
    ---@diagnostic disable: assign-type-mismatch
    area = Area.new(area)
    area.left_top = -area.left_top
    area.right_bottom = -area.right_bottom
    ---@diagnostic enable: assign-type-mismatch
    return area
end

--- Area tables are returned with these Metamethods attached.
-- @table Metamethods
metatable = {
    __class = 'area',
    __index = Area, -- If key is not found see if there is one available in the Area module.
    __tostring = Area.to_string, -- Will print a string representation of the area.
    __concat = _ENV.concat, -- calls tostring on both sides of concat.
    __add = __add, -- Will adjust if RHS is vector/position, add offset if RHS is number/area
    __sub = __sub, -- Will adjust if RHS is vector/position, sub offset if RHS is number/area
    __mul = __mul,
    __div = __div,
    __mod = __mod,
    __unm = __unm,
    __eq = Area.equals, -- Is area1 the same as area2.
    __lt = Area.less_than, -- Is the size of area1 less than number/area2.
    __le = Area.less_than_eq, -- Is the size of area1 less than or equal to number/area2.
    __len = Area.size, -- The size of the area.
    __call = Area.new, -- Return a new copy.
    __debugline = [[<Area>{[}left_top={left_top},right_bottom={right_bottom}{]}]]
}

return Area
