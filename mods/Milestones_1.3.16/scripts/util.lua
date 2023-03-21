function table_contains(table, element)
    for _, value in pairs(table) do
        if value == element then return true end
    end
    return false
end

function validate_milestones(milestones)
    local valid_categories = {'item', 'fluid', 'technology', 'kill', 'group', 'alias'}
    for _, milestone in pairs(milestones) do
        if not table_contains(valid_categories, milestone.type) then
            return nil, {"", {"milestones.message_invalid_import_type"}, milestone.type}
        end
        if type(milestone.name) ~= "string" then
            return nil, {"", {"milestones.message_invalid_import_missing_field"}, "name"}
        end
        if milestone.type ~= 'group' then
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
        if milestone.type == 'alias' and type(milestone.equals) ~= "string" then
            return nil, {"", {"milestones.message_invalid_import_missing_field"}, "equals"}
        end
    end
    return milestones, nil
end

function convert_and_validate_imported_json(import_string)
    local imported_milestones = game.json_to_table(import_string)

    if imported_milestones == nil then
        return nil, {"milestones.message_invalid_import_json"}
    end

    return validate_milestones(imported_milestones)
end

local delayed_chat_delay = 240

local function print_chat_delayed(event)
    log("Printing delayed chat")
    if event.tick == 0 then return end
    for _, delayed_chat_message in pairs(global.delayed_chat_messages) do
        game.print(delayed_chat_message)
    end
    global.delayed_chat_messages = {}
    script.on_nth_tick(delayed_chat_delay, nil)
end

function create_delayed_chat()
    script.on_nth_tick(delayed_chat_delay, function(event)
        print_chat_delayed(event)
    end)
end

function print_delayed_red(message)
    table.insert(global.delayed_chat_messages, ({"", "[color=red]", message, "[/color]"}))
end
