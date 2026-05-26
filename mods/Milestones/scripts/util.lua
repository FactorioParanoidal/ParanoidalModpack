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

function validate_milestones(milestones)
    local valid_categories = {"item", "fluid", "item_consumption", "fluid_consumption", "technology", "kill", "group", "alias"}
    for _, milestone in pairs(milestones) do
        if not table_contains(valid_categories, milestone.type) then
            return nil, {"", {"milestones.message_invalid_import_type"}, milestone.type}
        end
        if type(milestone.name) ~= "string" then
            return nil, {"", {"milestones.message_invalid_import_missing_field"}, "name"}
        end
        if milestone.type ~= "group" then
            local num = tonumber(milestone.quantity)
            if num == nil or num < 1 then
                return nil, {"", {"milestones.message_invalid_import_quantity"}, milestone.quantity}
            end
            if milestone.next ~= nil then
                local operator, _ = parse_next_formula(milestone.next)
                if operator == nil then
                    return nil, {"", {"milestones.message_invalid_import_next"}, milestone.next}
                end
            end
        end
        if milestone.type == "alias" and type(milestone.equals) ~= "string" then
            return nil, {"", {"milestones.message_invalid_import_missing_field"}, "equals"}
        end
        if (type(milestone.hidden) == "boolean" and milestone.hidden) or milestone.hidden == "true" then
            milestone.hidden = true
        else
            milestone.hidden = nil
        end
    end
    return milestones, nil
end

function convert_and_validate_imported_json(import_string)
    local imported_milestones = helpers.json_to_table(import_string)

    if imported_milestones == nil then
        return nil, {"milestones.message_invalid_import_json"}
    end

    return validate_milestones(imported_milestones)
end

local delayed_chat_delay = 240

local function print_chat_delayed(event)
    if event.tick == 0 or storage.delayed_chat_messages == nil or next(storage.delayed_chat_messages) == nil then return end
    for _, delayed_chat_message in pairs(storage.delayed_chat_messages) do
        game.print(delayed_chat_message)
    end
    storage.delayed_chat_messages = {}
end

-- Register event handler unconditionally
script.on_nth_tick(delayed_chat_delay, function(event)
    print_chat_delayed(event)
end)

function print_delayed_red(message)
    table.insert(storage.delayed_chat_messages, ({"", "[color=red]", message, "[/color]"}))
end

function approximately_equal(a, b)
    return math.abs(a - b) < 0.00001
end
