--- Unique Array class
-- For working with unique string array values. Creates an array with hash/dictionary indexing.
--- @class StdLib.UniqueArray
--- Adding or removeing values without using the provided methods can break the functionality of this class.
--- Additional methods exported by requering StdLib.UniqueArray are .set and .make_dictionary
--- @usage local unique_array = require('__Kux-CoreLib__/stdlib/utils/classes/unique_array')
--- local my_array = unique_array('first')
--- my_array:add('second')
--- if my_array['second'] then
---   print('its truthy')
--- end'
--- @set all=true
local M = {
    __class = 'UniqueArray'
}

local type, ipairs = type, ipairs
local getmetatable, setmetatable, rawset = getmetatable, setmetatable, rawset
local t_remove, t_sort = table.remove, table.sort

local function add(self, class, param)
    local index = #self + 1
    rawset(self, index, param)
    class.dictionary[param] = index
    class.len = class.len + 1
    return index
end

local function dictionary_sort(self, class)
    class.len = 0
    for i, v in ipairs(self) do
        class.len = class.len + 1
        class.dictionary[v] = i
    end
end

local function remove(self, class, param)
    t_remove(self, class.dictionary[param])
    class.dictionary[param] = nil
    dictionary_sort(self, class)
end

local wrappers = {}

local function create_class(tab)
    if type(tab) == 'table' then
        local class = {
            __concat = M.concat,
            __tostring = M.tostring,
            __eq = M.same,
            __lt = wrappers.__lt,
            __add = wrappers.__add,
            __sub = wrappers.__sub,
            __lte = wrappers.__lt,
            len = 0
        }

        class.dictionary = M.make_dictionary(tab)

        class.__index = function(_, k)
            return class.dictionary[k] or M[k]
        end

        return setmetatable(tab, class)
    end
end

local function unique_or_new(tab)
    if type(tab) == table and tab.__class == 'UniqueArray' then
        return tab
    else
        return M.new(tab)
    end
end

wrappers.__lt = function(lhs, rhs)
    lhs, rhs = unique_or_new(lhs), unique_or_new(rhs)
    return rhs:all(lhs)
end
wrappers.__add = function(lhs, rhs)
    return M.new(lhs):add(rhs)
end
wrappers.__sub = function(lhs, rhs)
    return M.new(lhs):remove(rhs)
end
wrappers.__pairs = function(self)
    local dictionary = getmetatable(self).dictionary
    return next, dictionary, nil
end

--- Methods
-- @section Methods

--- Create a new unique array.
--- @param ... StdLib.UniqueArray|string|string[]} strings to initialize the unique array with
--- @return StdLib.UniqueArray new
function M.new(...)
    return create_class {}:add(type((...)) == 'table' and (...) or { ... })
end

--- Add a string to the array if it doesn't exist in the array.
--- @param other StdLib.UniqueArray|string|string[]}
--- @return StdLib.UniqueArray self
function M:add(other)
    local class = getmetatable(self)
    for _, param in ipairs(type(other) == 'table' and other or { other }) do
        if not self[param] then
            add(self, class, param)
        end
    end
    return self
end

--- Remove the strings from the array if they exist.
--- @param other StdLib.UniqueArray|string|string[]}
--- @return StdLib.UniqueArray self
function M:remove(other)
    local class = getmetatable(self)
    for _, param in ipairs(type(other) == 'table' and other or { other }) do
        if self[param] then
            remove(self, class, param)
        end
    end
    return self
end

--- Toggles the passed name in the array by adding it if not present or removing it if it is.
--- @param other StdLib.UniqueArray|string|string[]
--- @return StdLib.UniqueArray self
function M:toggle(other)
    local class = getmetatable(self)
    for _, param in ipairs(type(other) == 'table' and other or { other }) do
        if self[param] then
            remove(self, class, param)
        else
            add(self, class, param)
        end
    end
    return self
end

--- Get all items that are NOT in both arrays.
--- @param other StdLib.UniqueArray|string|string[]}
--- @return StdLib.UniqueArray new
function M:diff(other)
    other = unique_or_new(other)
    local diff = M.new()
    for _, v in ipairs(self) do
        if not other[v] then
            diff:add(v)
        end
    end
    for _, v in ipairs(other) do
        if not self[v] then
            diff:add(v)
        end
    end
    return diff
end

--- Get all items that are in both arrays.
--- @param other StdLib.UniqueArray|string|string[]}
--- @return StdLib.UniqueArray new
function M:intersects(other)
    other = unique_or_new(other)
    local intersection = M.new()
    for _, v in ipairs(self) do
        if other[v] then
            intersection:add(v)
        end
    end
    for _, v in ipairs(other) do
        if self[v] and not intersection[v] then
            intersection:add(v)
        end
    end
    return intersection
end

--- Sort the UniqueArray in place.
--- @param cmp function? [opt] Comparator @{sort} function to use
--- @return StdLib.UniqueArray self
function M:sort(cmp)
    local class = getmetatable(self)
    t_sort(self, cmp)
    dictionary_sort(self, class)
    return self
end

--- Create a new UniqueArray by concatenating together.
--- @param other StdLib.UniqueArray|string|string[]
--- @return StdLib.UniqueArray new
function M:concat(other)
    return M.new(self):add(other)
end

--- Find all members in a unique array that match the pattern.
--- @param pattern string Lua @{pattern}
--- @return StdLib.UniqueArray new unique array containing all elements that match.
function M:find(pattern)
    local matches = M.new()
    for _, value in ipairs(self) do
        if value:find(pattern) then
            matches:add(value)
        end
    end
    return matches
end

--- Clear the array returning an empty array object
--- @return StdLib.UniqueArray self
function M:clear()
    local class = getmetatable(self)
    for i = #self, 1, -1 do
        self[i] = nil
    end
    class.dictionary = {}
    class.len = 0
    return self
end

--- Functions
-- @section Functions

--- Does this array have all of the passed strings.
--- @param other StdLib.UniqueArray|string|string[]}
--- @return boolean every passed string is in the array
function M:all(other)
    local params = type(other) == 'table' and other or { other }
    local count = 0
    for _, param in ipairs(params) do
        if self[param] then
            count = count + 1
        end
    end
    return count == #params
end
M.has = M.all

--- Does this array have any of the passed strings.
--- @param other StdLib.UniqueArray|string|string[]}
--- @return boolean any passed string is in the array
function M:any(other)
    for _, param in ipairs(type(other) == 'table' and other or { other }) do
        if self[param] then
            return true
        end
    end
    return false
end

--- Does this array have none of the passed strings.
--- @param other StdLib.UniqueArray|string|string[]}
--- @return boolean no passed strings are in the array
function M:none(other)
    for _, param in ipairs(type(other) == 'table' and other or { other }) do
        if self[param] then
            return false
        end
    end
    return true
end

--- Do both arrays contain the same items
--- @param other StdLib.UniqueArray|string|string[]}
--- @return boolean
function M:same(other)
    other = unique_or_new(other)
    if #self == #other then
        for _, value in ipairs(self) do
            if not other[value] then
                return false
            end
        end
        return true
    end
    return false
end

--- Do the unique arrays have no items in common
--- @param other StdLib.UniqueArray|string|string[]}
--- @return boolean
function M:disjointed(other)
    return #self:intersects(other) == 0
end

--- Convert the array to a string.
--- @return string
function M:tostring()
    return table.concat(self, ', ')
end

--- Return a dictionary mapping of the array.
-- can be passed a function to set the value of the field.
--- @param func function? [opt] value, index are passed as the first two paramaters
--- @param ... any [opt] additional values to pass to the function
--- @return {[any]:any}
function M:make_dictionary(func, ...)
    local dict = {}
    for index, value in ipairs(self) do
        dict[value] = func and func(value, index, ...) or index
    end
    return dict
end

--- Exports
-- @section Exports

local function from_dictionary(dict)
    local array = {}
    local i = 0
    for k in pairs(dict) do
        i = i + 1
        array[i] = k
    end
    return create_class(array)
end

--- These functions are available when requiring this class.
-- @table exports
local exports = {
    new = M.new, -- @{unique_array.new}
    set = create_class, -- set the class on an existing table
    dictionary = M.make_dictionary, -- @{unique_array.make_dictionary}
    from_dictionary = from_dictionary
}

setmetatable(
    exports,
    {
        __call = function(_, ...)
            return M.new(...)
        end
    }
)

return exports
