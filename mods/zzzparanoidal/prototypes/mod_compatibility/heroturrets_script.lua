--------------------------------------------------------------------------------------------------
--[[ не используется
-- функция перебора данных в таблице
local function inTable(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end
]]
-- ###############################################################################################
-- функция замены entity через инструмент выделения
local function on_selected_area(event)

    -- проверка на соответсвие выбранного инструмента
    if event.item == "hero_downgrade" then
    else
        return
    end

    for k, entity in pairs(event.entities) do -- перебор объектов попавших под выделение
        if string.find(entity.name, "hero%-turret") then --если в названии найден шаблон
            
            --определение какой должна быть новая турель путем отрезания лишнего от старого названия
            local new_ent = nil
            local valuePos = entity.name:find("for")
            if valuePos then
            new_ent = entity.name:sub(valuePos+4)
            end

            if entity.valid then
                -- получение информации о текущем entity
                local s = entity.surface
                local p = entity.position
                local f = entity.force
                local h = entity.health
                local mh = entity.prototype.max_health
                local d = entity.direction
                local o = entity.orientation

                --получение информации о жидкости
                local fluid = {}
                if entity.fluidbox ~= nil then 
                  for k = 1, #entity.fluidbox do fb = entity.fluidbox[k]
                    if fb ~=nil and fb.name ~= nil then
                        table.insert(fluid,{name = fb.name, amount = fb.amount, temperature = fb.temperature})
                    end
                  end
                end

                -- получение информации о инвентаре
                local i = entity.get_inventory(defines.inventory.turret_ammo)
                local c = nil
                if i ~= nil then
                    c = i.get_contents()
                end

                entity.destroy() -- уничтожение старого entity

                -- создаем новый entity
                local new_entity = s.create_entity {
                    name = new_ent,
                    position = p,
                    force = f,
                    direction = d,
                    orientation = o,
                    raise_built = true
                }
                new_entity.health = h

                -- вставляем в новый entity инвентарь старого
                local inv = new_entity.get_inventory(defines.inventory.turret_ammo)
                if inv ~= nil and c ~= nil then
                    for name, count in pairs(c) do
                        inv.insert {
                            name = name,
                            count = count
                        }
                    end
                end
                --вставляем жидкость в новый инвентарь
                if fluid ~=nil then
                    for k = 1, #fluid do fb = fluid[k]
                        new_entity.fluidbox[k] = {name = fb.name, amount = fb.amount, temperature = fb.temperature}
                    end
                end
            end
        end
    end
end
-- ###############################################################################################

script.on_event({defines.events.on_player_selected_area, defines.events.on_player_alt_selected_area}, on_selected_area)