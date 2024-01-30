-- require("prototypes.tips-and-tricks.1-1-1-start.1-1-1-start-simulation-prototypes")
local simulations = require("__zzzparanoidal__/prototypes/tips-and-tricks/1-1-1-start/tips-and-tricks-simulations") -- файл с симуляциями
--  simulation = simulations.introduction --как инициализировать симуляцию

data:extend({{
    type = "tips-and-tricks-item-category", -- создаём категорию подсказок
    name = "start", -- имя категории
    order = "a" -- ордер для сортировки по алфавиту
}, {
    type = "tips-and-tricks-item", -- создаём подсказку
    name = "start", -- имя подсказки
    category = "start", -- имя категории подсказки

    is_title = true, -- нужен ли жирный шрифт
    tag = "[img=utility/played_green]", -- иконка в названии подсказки (зеленая стрелка)
    localised_name = {"tips-and-tricks-name.start"}, -- имя из tips-and-tricks.cfg
    localised_description = {"tips-and-tricks-description.start"}, -- описание из tips-and-tricks.cfg
    image = "__zzzparanoidal__/graphics/tips-and-tricks/1-1-1-start.png", -- загрузка изображения (ширина не менее 1024. пропорция 1:2)

    order = "a", -- ордер для сортировки по алфавиту
    indent = 0, -- отступ, 1=6 пробелов

    starting_status = "locked", -- начальный статус, заблокироана или открыта
    dependencies = nil, -- зависимости от других подсказок, пока они не откроются не будет доступна 
    trigger = {
        type = "time-elapsed", -- триггер для активации подсказки, подробнее здесь: https://wiki.factorio.com/Types/TipTrigger
        ticks = 60 * 10 -- 10 sec
    }

}, {
    type = "tips-and-tricks-item",
    name = "no-update",
    category = "start",

    is_title = true,
    tag = "[img=utility/played_green]",
    localised_name = {"tips-and-tricks-name.no-update"},
    localised_description = {"tips-and-tricks-description.no-update"},
    image = "__zzzparanoidal__/graphics/tips-and-tricks/no-update.png",

    order = "b",
    indent = 1,

    starting_status = "locked",
    dependencies = nil,
    trigger = {
        type = "time-elapsed",
        ticks = 60 * 60 -- 60 sec
    }

}})
