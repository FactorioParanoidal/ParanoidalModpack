_table = require("__stdlib__/stdlib/utils/table")
_string = require("__stdlib__/stdlib/utils/string")
GAME_MODES = { "normal", "expensive" }
DETECTED_RESOURCE_TECHNOLOGY_SUFFIX = "-detected-resource-technology"
Utils = {}

_table.contains = function(__table, value)
    return _table.find(
        __table,
        function(__table_item)
            return __table_item == value
        end
    ) ~= nil
end

_table.contains_f = function(__table, value_function)
    return _table.find(
        __table,
        function(__table_item)
            return value_function(__table_item)
        end
    ) ~= nil
end

_table.contains_f_deep = function(__table, item)
    return _table.get_item_index(__table, item) ~= nil
end
_table.insert_all_if_not_exists = function(table1, table2)
    _table.each(
        table2,
        function(item)
            if not _table.contains_f_deep(table1, item) then
                table.insert(table1, #table1 + 1, item)
            end
        end
    )
end

_table.insert_all_if_not_exists_with_compare = function(table1, table2, comparing_function)
    if not comparing_function or type(comparing_function) ~= "function" then
        error(tostring(comparing_function) .. " is not function!")
    end
    _table.each(
        table2,
        function(item)
            if comparing_function(table1, item) then
                table.insert(table1, #table1 + 1, item)
            end
        end
    )
end
_table.get_item_index = function(__table, item)
    for k, v in pairs(__table) do
        if type(item) == "table" and _table.deep_compare(v, item) then
            return k
        end
        if type(item) ~= "table" and v == item then
            return k
        end
    end
    return nil
end
_table.remove_item = function(__table, item_for_remove, key_evaluate_function, allow_key_missing)
    local target_item = item_for_remove

    if key_evaluate_function then
        target_item =
            _table.first(
                _table.filter(
                    __table,
                    function(table_item)
                        return key_evaluate_function(table_item, item_for_remove)
                    end
                )
            )
    end
    local item_key = _table.get_item_index(__table, target_item)

    if item_key then
        __table[item_key] = nil
        return
    end
    if not allow_key_missing then
        error(
            "Can't delete item " ..
            Utils.dump_to_console(item_for_remove) ..
            " with key " ..
            Utils.dump_to_console(item_key) .. " from given table" .. Utils.dump_to_console(__table) .. "!"
        )
    end
end
Utils.dump_to_console = function(o)
    if type(o) == "table" then
        local s = "{ "
        for k, v in pairs(o) do
            if type(k) == "table" then
                k = '"' .. Utils.dump_to_console(k) .. '"'
            end
            if type(k) ~= "number" then
                k = '"' .. k .. '"'
            end
            s = s .. "[" .. k .. "] = " .. Utils.dump_to_console(v) .. ","
        end
        return s .. "} "
    else
        return tostring(o)
    end
end

Utils.get_moded_object = function(_type, name, mode)
    local object = data.raw[_type][name]
    if type(object) ~= "table" then
        error("object must be a table but got " ..
            type(object) .. "Cause: prototype with type " .. _type .. " called " .. name .. " not found!")
    end
    if not object or not mode or not object[mode] then
        error("mode " .. tostring(mode) .. " for object " .. Utils.dump_to_console(object) .. " is not available!")
    end
    return object[mode]
end

Utils.is_freeplay_scenario = function()
    return script.level.level_name == "freeplay" and script.level.mod_name == "base"
end
function get_resource_detected_technology_name(resource_name)
    return resource_name .. DETECTED_RESOURCE_TECHNOLOGY_SUFFIX
end
