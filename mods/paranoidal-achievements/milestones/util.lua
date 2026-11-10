function table_contains(table, element)
    for _, value in pairs(table) do
        if value == element then return true end
    end
    return false
end

function table_get_index(table, element)
    for i, value in pairs(table) do
        if value == element then return i end
    end
    return nil
end

local schema = require("milestones.schema")

function validate_milestones(milestones)
    return schema.normalize(milestones)
end

function convert_and_validate_imported_json(import_string)
    if type(import_string) ~= "string" then return nil, {"milestones.message_invalid_import_json"} end
    local decoded_ok, decoded = pcall(helpers.decode_string, import_string)
    if decoded_ok and decoded then import_string = decoded end
    local ok, imported = pcall(helpers.json_to_table, import_string)
    if not ok or type(imported) ~= "table" then
        return nil, {"milestones.message_invalid_import_json"}
    end
    return validate_milestones(imported)
end

-- Called by the on_tick handler of control.lua every DELAYED_CHAT_DELAY ticks.
DELAYED_CHAT_DELAY = 240

function print_chat_delayed(event)
    if event.tick == 0 or storage.delayed_chat_messages == nil or next(storage.delayed_chat_messages) == nil then return end
    for _, delayed_chat_message in pairs(storage.delayed_chat_messages) do
        game.print(delayed_chat_message)
    end
    storage.delayed_chat_messages = {}
end

function print_delayed_red(message)
    table.insert(storage.delayed_chat_messages, ({"", "[color=red]", message, "[/color]"}))
end

function approximately_equal(a, b)
    return math.abs(a - b) < 0.00001
end
