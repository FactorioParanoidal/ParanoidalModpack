local function get_localised_name_from_resource(resource)
    local result = nil
    local resource_name = resource.name
    local resource_type = resource.type
    if not result then
        if game.item_prototypes[resource_name] then
            result = game.item_prototypes[resource_name].localised_name
        end
    end
    if not result then
        if game.fluid_prototypes[resource_name] then
            result = game.fluid_prototypes[resource_name].localised_name
        end
    end
    if not result then
        error("Неправильный тип ресурса " .. resource_type .. " с именем " .. resource_name)
    end
    return result
end
function research_technology_for_resource_if_exists_not_researched(resource, force, prefix, suffix)
    local resource_name = resource.name
    local resource_technology_name = get_resource_detected_technology_name(resource_name)
    -- log("resource_technology_name " .. resource_technology_name)
    if force.technologies[resource_technology_name] and not force.technologies[resource_technology_name].researched then
        local technology = force.technologies[resource_technology_name]
        technology.researched = true
        technology.enabled = true
        local resource_localised_name = get_localised_name_from_resource(resource)
        init_localised_name_translate_with_custom_data(force.players[1], resource_localised_name, prefix, suffix,
            function(translated_data)
                game.print(translated_data.prefix ..
                    translated_data.translated_result ..
                    translated_data.suffix .. game.players[translated_data.player_index].name)
            end)
    end
end

function research_technologies_for_resources_if_exists_not_researched(found_resources, force, prefix, suffix)
    if settings.startup["hardcore-mode-for-playing-use-separated-technologies-for-every-resource"].value then
        _table.each(found_resources, function(found_resource)
            research_technology_for_resource_if_exists_not_researched(
                found_resource, force, prefix, suffix
            )
        end)
    end
end
