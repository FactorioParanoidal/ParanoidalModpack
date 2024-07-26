-- трубы деревянные
local basic_inventory_items = {
    { name = "bi-wood-pipe",                count = 150 },
    { name = "bi-wood-pipe-to-ground",      count = 20 },
    -- одного насоса с твердотопливным питанием хватит в месте падения
    { name = "salvaged-offshore-pump-0",    count = 1 },
    -- батарейка корабельная, используется как UPS
    { name = "salvaged-generator",          count = 1 },
    { name = "burner-inserter",             count = 20 },
    -- дробление 4 видов руд.
    { name = "salvaged-assembling-machine", count = 8 },
    -- плавка 4 видов руд
    { name = "stone-furnace",               count = 4 },
    -- самые медленные конвейеры в игре
    { name = "basic-transport-belt",        count = 200 },
    -- базовый набор топлива, для питания всего этого добра
    { name = "coal",                        count = 2000 },
    -- для исследований начала игры очень даже достаточно, электрических лабораторий у нас для вас нет
    { name = "salvaged-lab",                count = 1 },
    -- может быть использовано для хранения различных продуктов
    { name = "wooden-chest",                count = 20 },
    -- пистолет для самообороны от кусак + несколько сотен магазинов(потому что до патронов можно и не дожить)
    { name = "pistol",                      count = 1 },
    { name = "firearm-magazine",            count = 800 },
    -- туррели с корабля для обороны стартовой зоны.
    { name = "gun-turret",                  count = 4 },

}
if settings.global["hardcore-mode-for-playing-disable-hand-resource-mining"].value then
    -- для производства дерева, так как никакой добычи с леса быть не может. Ибо это чит.
    table.insert(basic_inventory_items, { name = "coal-tree-seed", count = 600 })
    table.insert(basic_inventory_items, { name = "salvaged-iron-gear-wheel", count = 128 })
    table.insert(basic_inventory_items, { name = "wood", count = 1200 })
    table.insert(basic_inventory_items, { name = "salvaged-mining-drill-bit-mk0", count = 20 })
end
--[[ производственные здания, без них невозможно ничего исследовать или собрать,
			механика мода запрещает стоить любые производящие здания непосредственно на поверхности планеты]]
if settings.global["hardcore-mode-for-playing-disable-production-entities-beyond-factorissimo-building"].value then
    table.insert(basic_inventory_items, { name = "factory-1", count = 4 })
end
if settings.startup["hardcore-mode-for-playing-move-basic-recipe-to-new-basic-technology-hard-start"].value then
    -- автоматизационные исследовательские пакеты - для старта игры
    table.insert(basic_inventory_items, { name = "salvaged-automation-science-pack", count = 231 })
    -- ремонтные пакеты на первое время
    table.insert(basic_inventory_items, { name = "repair-pack", count = 4 })
end
if settings.startup["hardcore-mode-for-playing-use-separated-technologies-for-every-resource"].value then
    -- радар для исследования территории рядом с точкой падения для поиска базовых ресурсов, чтобы начать исследование планеты и постройку базы
    table.insert(basic_inventory_items, { name = "salvaged-radar", count = 1 })
    table.insert(basic_inventory_items, { name = "small-electric-pole", count = 1 })
end

function technology_research_finished(e)
    local researched_technology = e.research
    if researched_technology.name == "salvaged-automation-tech" then
        if global.basic_item_inserted then return end
        local players = researched_technology.force.players
        _table.each(players, function(player)
            local player_inventory = player.get_main_inventory()
            _table.each(basic_inventory_items, function(item_stack)
                player_inventory.insert(item_stack)
            end)
        end)
        global.basic_item_inserted = true
        return
    end
    handle_researched_technology(researched_technology)
    enable_player_entity_on_all_surfaces(game.players[1].force)
end
