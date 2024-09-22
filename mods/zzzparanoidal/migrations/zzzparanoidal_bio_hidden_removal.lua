for _, surface in pairs(game.surfaces) do
    -- Найдем все сущности типа "bi-bio-farm" на этой поверхности
    local bio_farms = surface.find_entities_filtered { name = "bi-bio-farm" }

    -- Проходим по каждой сущности "bi-bio-farm"
    for _, bio_farm in pairs(bio_farms) do
        local position = bio_farm.position

        -- Определяем типы скрытых сущностей для удаления
        local hidden_entities = { 
            "bi-bio-farm-hidden-panel", 
            "hidden-electric-resistance", 
            "bi-bio-farm-hidden-lamp", 
            "bi-bio-farm-hidden-pole",
            "bi-bio-farm-hidden-connector_pole"
        }

        -- Проходим по каждому типу скрытых сущностей
        for _, hidden_name in pairs(hidden_entities) do
            -- Находим сущности по позиции "bi-bio-farm" и имени скрытой сущности
            local hidden_entity = surface.find_entities_filtered {
                name = hidden_name, 
                position = position
            }

            -- Удаляем найденные сущности
            for _, entity in pairs(hidden_entity) do
                entity.destroy()
            end
        end
    end
end
