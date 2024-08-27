require("prototypes.mod_compatibility.heroturrets_script") -- скрипт разжалования турелей
require("__PMRPGsystem__/prototypes/test")
-- ##############################
-- код для работы новых насосов
local offshore_pump_types = {"offshore-mk0-pump", "offshore-pump", "offshore-mk2-pump", "offshore-mk3-pump", "offshore-mk4-pump", "seafloor-pump", "seafloor-pump-2", "seafloor-pump-3"}

local function offshore_pump_setup(entity)
    local direction = entity.direction
    local position = entity.position
    position.y = position.y + 1 / 32
    entity.surface.create_entity {
        name = entity.name .. "-output",
        position = position,
        direction = direction,
        force = entity.force
    }
end

local function on_entity_created(event)
    local entity = event.created_entity or event.entity
    if entity and entity.valid then
        for _, pump in pairs(offshore_pump_types) do
            if entity.name == pump then
                offshore_pump_setup(entity)
                return
            end
        end
    end
end

local function hidden_entity_created(event) --создаём скрытые pole
    local entity = event.created_entity or event.entity
    if entity and entity.valid then
        for _, pump in pairs(offshore_pump_types) do
            -- Исключаем "offshore-mk0-pump"
            if entity.name == "offshore-mk0-pump" then
                return
            end
            if entity.name == pump then
                entity.surface.create_entity{name="hidden-electric-pole", position=entity.position, force=entity.force}
                return
            end
        end
    end
end

local function remove_entities(surface, names, position, area)
    for _, name in pairs(names) do
        for _, entity in pairs(surface.find_entities_filtered {
            area = {{position.x - area, position.y - area}, {position.x + area, position.y + area}},
            name = name
        }) do
            entity.destroy()
        end
    end
end

local function on_entity_removed(event) --удаление лишних сущностей
    if event.entity and event.entity.valid then
        local entity = event.entity
        for _, pump in pairs(offshore_pump_types) do
            if entity.name == pump .. "-output" then
                remove_entities(entity.surface, {pump}, entity.position, 0.5)
                remove_entities(entity.surface, {"hidden-electric-pole"}, entity.position, 0.5)
                return
            elseif entity.name == pump then
                remove_entities(entity.surface, {pump .. "-output"}, entity.position, 0.5)
                remove_entities(entity.surface, {"hidden-electric-pole"}, entity.position, 0.5)
                return
            end
        end
    end
end

local function on_player_rotated_entity(event) --я хз зачем это все равно помпы низя вертеть, но пусть будет
    if event.entity and event.entity.valid then
        local entity = event.entity
        for _, pump in pairs(offshore_pump_types) do
            if entity.name == pump .. "-output" then
                local pumps = entity.surface.find_entities_filtered {
                    area = {{entity.position.x - 0.5, entity.position.y - 0.5},
                            {entity.position.x + 0.5, entity.position.y + 0.5}},
                    name = pump,
                    limit = 1
                }
                if #pumps > 0 then
                    local pump = pumps[1]
                    entity.direction = pump.direction
                end
                return
            end
        end
    end
end


local function replace_blueprint(event) --устраняем баги при смерти насоса
    local entity = event.entity
    if entity and entity.valid then
        for _, pump_name in pairs(offshore_pump_types) do
            -- Проверяем, является ли сущность одним из типов с суффиксом "-output"
            if entity.name == pump_name .. "-output" then
                -- Получаем необходимые параметры
                local surface = entity.surface
                local position = entity.position
                local force = entity.force
                local direction = entity.direction

                -- Удаляем призрак output-типа
                entity.destroy()

                -- Создаем призрак соответствующего обычного типа на том же месте
                surface.create_entity {
                    name = "entity-ghost",
                    inner_name = pump_name,
                    position = position,
                    direction = direction,
                    force = force
                }

                return
            end
        end
    end
end

-- Функция для проверки наличия значения в таблице
local function table_contains(tbl, value)
    for _, v in pairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

-- Функция для проверки и удаления насосов на других поверхностях
local function kill_nasos(event)
    local entity = event.created_entity or event.entity
    -- Проверяем, является ли установленная сущность офшорным насосом
    if entity and table_contains(offshore_pump_types, entity.name) then
        -- Проверяем, находится ли она на поверхности nauvis
        if entity.surface.name ~= "nauvis" then
            -- Уничтожаем сущность, если она не на поверхности nauvis
            entity.destroy()
            -- Вывод сообщения игроку (опционально)
            if event.player_index then
                local player = game.get_player(event.player_index)
                player.print("Зачем ты ставишь насосы в фабрике? Тяни трубы как нормальный мужик!")
            end
        end
    end
end


-- ###############################################################################################
-- скрипт для удаления лишних проводов с биоферм

local farm = "bi-bio-farm"

local function on_entity_bio_removed(event)
    if event.entity and event.entity.valid then
        local entity = event.entity
        if entity.name == "bi-bio-farm" then
            local surface = entity.surface
            local position = entity.position
            local entities_to_remove = {
                "bi-bio-farm-hidden-connector_pole",
                "bi-bio-farm-hidden-lamp",
                "bi-bio-farm-hidden-panel",
                "bi-bio-farm-hidden-pole",
                "bi-bio-solar-farm",
                "bi-bio-solar-farm-hidden-pole",
                "hidden-electric-resistance"
            }

            for _, name in pairs(entities_to_remove) do
                local nearby_entities = surface.find_entities_filtered{
                    name = name, 
                    position = position, 
                    radius = 1
                }
                for _, nearby_entity in pairs(nearby_entities) do
                    if nearby_entity and nearby_entity.valid then
                        nearby_entity.destroy()
                    end
                end
            end
        end
    end
end
-- ###############################################################################################
-- from some corpse marker
script.on_event(defines.events.on_pre_player_died, function(event)
    local player = game.players[event.player_index]
    player.force.add_chart_tag(player.surface, {
        position = player.position,
        text = 'Corpse: ' .. player.name .. '; Time: ' .. math.floor(game.tick / 60 / 60 / 60) .. ':' ..
            (math.floor(game.tick / 60 / 60) % 60),
        icon = {
            type = "virtual",
            name = "signal-info"
        }
    })
end)

if (settings.global["paranoidal-disable-vanilla-evolution"] or {}).value then
    script.on_init(function()
        game.map_settings.enemy_evolution.enabled = false
    end)
end
-- ###############################################################################################
-- задаём функцию для SpilledItems
local function spilled_items(event)
    --	on_entity_died
    --	Called when an entity dies. Can be filtered using LuaEntityDiedEventFilters

    --	Contains
    --	entity :: LuaEntity
    --	cause :: LuaEntity (optional): The entity that did the killing if available.
    --	loot :: LuaInventory: The loot generated by this entity if any.
    --	force :: LuaForce (optional): The force that did the killing if any.
    --	damage_type :: LuaDamagePrototype (optional): The damage type if any.
    local entity = event.entity
    local surface = entity.surface
    local position = entity.position

    local inventories = {}
    table.insert(inventories, entity.get_inventory(defines.inventory.chest))
    --	print ('defines.inventory.chest' .. defines.inventory.chest)
    table.insert(inventories, entity.get_inventory(defines.inventory.car_trunk))
    --	print ('defines.inventory.car_trunk' .. defines.inventory.car_trunk)
    table.insert(inventories, entity.get_inventory(defines.inventory.turret_ammo))
    --	print ('defines.inventory.turret_ammo' .. defines.inventory.turret_ammo)

    table.insert(inventories, entity.get_output_inventory())

    table.insert(inventories, entity.get_module_inventory())

    table.insert(inventories, entity.get_fuel_inventory())

    table.insert(inventories, entity.get_burnt_result_inventory())

    local grid = entity.grid -- LuaEquipmentGrid
    if grid then
        local equipments = grid.equipment -- array of LuaEquipment [R]
        for i, equipment in pairs(equipments) do
            local prototype = equipment.prototype -- LuaEquipmentPrototype [Read-only]
            local item_prototype = prototype.take_result -- LuaItemPrototype [Read-only]
            local name = item_prototype.name
            surface.spill_item_stack(position, {
                name = name,
                count = 1
            })
        end
        grid.clear() -- not for other mods
    end

    for i, inventory in pairs(inventories) do
        for j = 1, #inventory do
            local item_stack = inventory[j]
            if item_stack and item_stack.valid_for_read then
                if item_stack.grid then
                    surface.spill_item_stack(position, item_stack)
                else
                    local prototype = item_stack.prototype
                    local stack_size = prototype.stack_size
                    local name = item_stack.name
                    local count = item_stack.count
                    --					if count >= stack_size then
                    --						surface.create_entity{name="item-on-ground", 
                    --							position=position, 
                    --							stack={name=name, count=count}}
                    --					else -- I want to split count by stacks, but not today
                    surface.spill_item_stack(position, {
                        name = name,
                        count = count
                    })
                    --					end
                end
                item_stack.clear()
            end
        end

        inventory.clear() -- not for other mods
    end
end
-- ###############################################################################################
-- ############################## Все ресурсы х5 на дефолт настройках

-- Список имен ресурсов, которые вы хотите изменить
local resourceNames = {"angels-ore1", "angels-ore2", "coal", "angels-ore3", "angels-ore4", "angels-ore5", "angels-ore6",
                       "angels-natural-gas", "crude-oil"}

if settings.startup["newbie_resourse"].value == true then
    -- Обработчик события on_chunk_generated
    script.on_event(defines.events.on_chunk_generated, function(event)
        -- Проверяем, что это именно генерация ресурсов
        if event.surface.name == "nauvis" then
            -- Изменяем настройки генерации ресурсов в чанках
            for _, entity in pairs(event.surface.find_entities_filtered {
                area = event.area
            }) do
                -- Проверяем, является ли сущность ресурсом
                if isResource(entity.name, resourceNames) then
                    if entity.amount * 5 >= 4294967294 then
                        entity.amount = 4294967294
                    else
                        entity.amount = entity.amount * 5 -- Увеличьте количество ресурсов в чанке
                    end
                end
            end
        end
    end)

    -- Функция для проверки, является ли имя сущности ресурсом
    function isResource(name, resourceNames)
        for _, resourceName in ipairs(resourceNames) do
            if name == resourceName then
                return true
            end
        end
        return false
    end
end
-- ###############################################################################################
-- Запрещаем двигать все насосы через PickerDollies
local function configure_picker_dollies()
    if remote.interfaces["PickerDollies"] then
        local suffixes = {"-output"}
        for _, pump_type in ipairs(offshore_pump_types) do
            for _, suffix in ipairs(suffixes) do
                local name = pump_type .. suffix
                remote.call("PickerDollies", "add_blacklist_name", name)
                remote.call("PickerDollies", "add_oblong_name", name)
            end
        end
    end
end

-- ##############################
-- ############################## Скрипт для удаления лишнего окна в Gui Unifer
local function delete_gui_random(event)
    myVariable = myVariable + 1
    if myVariable <= 5 then
        for _, player in pairs(game.players) do
            if player.gui.top.mod_gui_top_frame.children[1].random then
                player.gui.top.mod_gui_top_frame.children[1].random.destroy()
            end
        end
    end
end

-- ##############################
-- запускаем скрипты
local function spilled_and_removed(event)
    if settings.startup["item-drop"].value == true then
        spilled_items(event) -- должен быть первым
    end
    on_entity_removed(event)
    replace_blueprint(event) -- заменяем чертежи скрытой помпы при смерти
    on_entity_bio_removed(event)
end

local function offshore_and_bio(event)
    on_entity_removed(event)
    -- replace_blueprint(event) -- сдесь надо код на замену чертежа при контрол зет. пока непоянтно как
    on_entity_bio_removed(event)
end

local function gui_and_created(event)
    kill_nasos(event)
    on_entity_created(event)
    delete_gui_random(event)
    hidden_entity_created(event)
end

local function nasos_and_entity(event)
    kill_nasos(event)
    on_entity_created(event)
    hidden_entity_created(event)
end

script.on_event(defines.events.on_built_entity, gui_and_created) -- вместе с delete gui
script.on_event(defines.events.on_robot_built_entity, nasos_and_entity)
script.on_event(defines.events.script_raised_built, nasos_and_entity)
script.on_event(defines.events.script_raised_revive, nasos_and_entity)

script.on_event(defines.events.on_player_rotated_entity, on_player_rotated_entity)

script.on_event(defines.events.on_entity_died, spilled_and_removed) -- вместе с SpilledItems
script.on_event(defines.events.on_pre_player_mined_item, offshore_and_bio)
script.on_event(defines.events.on_robot_pre_mined, offshore_and_bio)
script.on_event(defines.events.script_raised_destroy, offshore_and_bio)
-- script.on_event(defines.events.on_entity_destroyed, offshore_and_bio) --скорей всего не понадобится, но пусть лежит

script.on_init(function() --наш любимый init, запрещаем двигать наши насосы
    configure_picker_dollies()
end)

script.on_load(function()
    configure_picker_dollies()
end)
