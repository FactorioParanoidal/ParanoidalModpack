-- Adds new functions to the builtin string class.

---Splits a string into a table of substrings.
---@param s string
---@param seperator string
---@return table
string.split = function(s, seperator)
    local result = {}
    for match in (s .. seperator):gmatch("(.-)" .. seperator) do
        result[#result + 1] = match
    end
    return result
end

---Returns a boolean indicating whether a string is a digit.
---@param s string
---@return boolean
string.is_digit = function(s)
    return s:match("%d") ~= nil
end

---Returns a boolean indicating if the first string starts with the second string.
---@param s string
---@param start string
---@return boolean
string.starts_with = function(s, start)
    return s:sub(1, #start) == start
end

---Returns a boolean indicating if the first string ends with the second string.
---@param s string
---@param ending string
---@return boolean
string.ends_with = function(s, ending)
    return ending == "" or s:sub(- #ending) == ending
end
