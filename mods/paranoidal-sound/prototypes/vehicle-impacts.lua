-- A vehicle hits the entity's material. Give just the selected entities a private
-- material; keep the original bullet/other effects and the vehicle's vibration.
return function(material, suffix, variations)
    local name = "pd-vehicle-" .. material .. "-" .. suffix
    assert(not data.raw["impact-category"][name], "Duplicate impact category: " .. name)
    local definitions = {{type = "impact-category", name = name}}
    local vehicle = false
    for _, original in pairs(data.raw["deliver-impact-combination"]) do
        if original.impact_category == material then
            local copy = table.deepcopy(original)
            copy.name = name .. "-" .. original.deliver_category
            copy.impact_category = name
            if copy.deliver_category == "vehicle" then
                local effect = copy.trigger_effect_item
                assert(effect.type == "play-sound" and effect.sound.variations, "Unexpected impact sound: " .. original.name)
                effect.sound.variations = table.deepcopy(variations)
                vehicle = true
            end
            definitions[#definitions + 1] = copy
        end
    end
    assert(vehicle, "Missing vehicle impact for " .. material)
    data:extend(definitions)
    return name
end
