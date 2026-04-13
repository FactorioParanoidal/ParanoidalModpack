error("deprecated. Use unique-array.lua")
--- @diagnostic disable
--- not used internally
--- if needed, we will make it a normal string array later
---------------------------------------------------------------------------------------------------
--- String Array Metatable
-- For working with string arrays without duplicate values
--- @class StdLib.Classes.StringArray
local M = {
    __class = 'string-array-class'
}
local metatable

--- Does this array contain name.
--- @param name string The string to find.
--- @return boolean string is in array
function M:has(name)
    local type = type(name)
    if type == 'table' then
        for _, str in pairs(name) do
            if not self:has(str) then
                return false
            end
        end
        return true
    end

    assert(type == 'string', 'name must be a string')
    for _, str in ipairs(self) do
        if str == name then
            return true
        end
    end
    return false
end

--- Add a string to the array if it doesn't exist in the array.
--- @param name string|string[] The string to add.
--- @return self
function M:add(name)
    local type = type(name)
    if type == 'table' then
        for _, str in pairs(name) do
            self:add(str)
        end
        return self
    end

    assert(type == 'string', 'name must be a string')
    for _, str in ipairs(self) do
        if str == name then
            return self
        end
    end
    table.insert(self, name)
    return self
end

--- Remove the string from the array if it exists.
--- @param name string
--- @return self
function M:remove(name)
    local type = type(name)
    if type == 'table' then
        for _, str in pairs(name) do
            self:remove(str)
        end
        return self
    end

    assert(type == 'string', 'name must be a string')
    for i, str in ipairs(self) do
        if str == name then
            table.remove(self, i)
            return self
        end
    end
    return self
end

--- Toggles the passed name in the array by adding it if not present or removing it if it is.
--- @param name string
--- @return self
function M:toggle(name)
    local type = type(name)
    if type == 'table' then
        for _, str in pairs(name) do
            self:toggle(str)
        end
        return self
    end

    assert(type == 'string', 'name must be a string')
    for i, str in ipairs(self) do
        if str == name then
            table.remove(self, i)
            return self
        end
    end
    table.insert(self, name)
    return self
end

--- Clear the array returning an empty array object
--- @return self
function M:clear()
    for i = #self, 1, -1 do
        table.remove(self, i)
    end
    return self
end

--- Convert the array to a string
--- @return string
function M:tostring()
    return table.concat(self, ', ')
end


--[[ WTF?
--- Concat string-arrays and strings together
--- @param rhs string|StdLib.Classes.StringArray
--- @return StdLib.Classes.StringArray
function M:concat(rhs)
    if getmetatable(self) == metatable then
        return self:add(rhs)
    else
        return rhs:add(self)
    end
end
]]

--- Concat string-arrays and strings together
--- @param rhs string|StdLib.Classes.StringArray
--- @return StdLib.Classes.StringArray
function M:concat(rhs)
    if type(rhs) == "string" then
        return self:add(rhs)
    elseif getmetatable(rhs) == metatable then
        return self:add(rhs)
    else
        error("Invalid type for rhs: " .. type(rhs))
    end
end

--- The following metamethods are provided.
-- @table metatable
metatable = {
    __index = M, -- Index to the string array class.
    __tostring = M.tostring, -- tostring.
    __concat = M.concat, -- adds the right hand side to the object.
    __add = M.add, -- Adds a string to the string-array object.
    __sub = M.remove, -- Removes a string from the string-array object.
    __unm = M.clear, -- Clears the array.
    __call = M.has -- Array contains this string.
}

return function(array)
    if type(array) == 'table' then
        return setmetatable(array, metatable)
    end
end
