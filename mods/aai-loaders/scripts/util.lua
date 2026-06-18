local Util = {}

---Removes the first instance of an item in a given array.
---@param array any[] Array to remove item from
---@param item any Item to remove
function Util.remove_from_array(array, item)
    local index

    for i, _item in pairs(array) do
        if item == _item then
            index = i
            break
        end
    end

    if index then
        table.remove(array, index)
    end
end

---Returns true if a given string starts with another string.
---@param str string String to evaluate
---@param start string String to look for at the beginning of `str`
---@return boolean
function Util.string_starts(str, start)
  return string.sub(str, 1, string.len(start)) == start
end

return Util
