local array_translated_data = {}
local function on_string_translated(e)
    local translate_id = e.id
    if not array_translated_data[translate_id] then
        return
    end
    if e.translated then
        local translated_data_by_id = array_translated_data[translate_id]
        local operation = translated_data_by_id.operation
        if type(operation) == "function" then
            operation({
                prefix = translated_data_by_id.prefix,
                suffix = translated_data_by_id.suffix,
                translated_result = e.result,
                player_index = e.player_index
            })
        end
    end
    array_translated_data[translate_id] = nil
end
function init_localised_name_translate_with_custom_data(player, localised_name, prefix, suffix, operation)
    if not player then
        error("can't translate, player not specified")
    end
    if not localised_name then
        error("can't translate, localised_name not specified")
    end

    local translate_id = player.request_translation(localised_name)
    array_translated_data[translate_id] = { prefix = prefix, suffix = suffix, operation = operation }
end

script.on_event(defines.events.on_string_translated, on_string_translated)
