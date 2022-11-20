local config = require('config')

local lib = {} ---@class HelperLibrary

---@param str string
---@param args table
---@return string
lib.parse_string = function(str, args)
    local count = 1
    for _, arg in pairs(args) do
        local var = '__' .. count .. '__'
        local s, e = string.find(str, var)
        while s ~= nil and e ~= nil do
            str = string.gsub(str, var, arg)
            s, e = string.find(str, var)
        end
        count = count + 1
    end
    return str
end

---Find a name in babelfish's locales dictonary
---@param item_name string
---@param item_type string
---@return string|nil
lib.find_name_in_babelfish_dictonary = function(item_name, item_type)
    if global.locale_dictionaries[item_type] and global.locale_dictionaries[item_type][item_name] then
        return global.locale_dictionaries[item_type][item_name]
    end
    return item_name
end

---Parse signal data to nice text format
---comment
---@param signal_data table
---@return string|nil
lib.parse_signal_to_rich_text = function(signal_data)
    if signal_data ~= nil then
        local text_type = signal_data.type or "item"
        if text_type == "virtual" then
            text_type = "virtual-signal"
        end

        if config['switch_icon_format'] then
            return string.format("[%s=%s]", text_type, signal_data.name)
        else
            return string.format("[img=%s/%s]", text_type, signal_data.name)
        end
    end
    return nil
end

---Get list of keys from a table
---@param t table @table to get keys from
---@return table keys @sorts list of keys from table
lib.get_keys = function(t)
    local keys = {}
    for key, _ in pairs(t) do
        table.insert(keys, key)
    end
    table.sort(keys)
    return keys
end

---@class Colors
lib.colors = {
    white = { r = 1.0, g = 1.0, b = 1.0 }, ---@type Color
}




return lib
