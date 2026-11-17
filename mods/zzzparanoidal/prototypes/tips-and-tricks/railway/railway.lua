-- «Советы и подсказки»: железная дорога сборки (деревянные рельсы, светофоры, станции, подвижной состав,
-- топливо, перегруз, спарка, электровозы, надземные рельсы). Тексты: locale/{en,ru}/tips-railway.cfg;
-- анимации: simulations.lua (рядом); схемы: graphics/tips-and-tricks/railway/*.png (генератор
-- tools/tips-schemes в рабочей папке, только значки и числа). Категория оставлена в removals/tips-and-tricks.lua.
-- Все пункты видны сразу (справочник); триггер исследования показывает уведомление, когда механика появляется.
local simulations = require("__zzzparanoidal__/prototypes/tips-and-tricks/railway/simulations")

local CATEGORY = "zzz-railway"
local IMAGES = "__zzzparanoidal__/graphics/tips-and-tricks/railway/"

local function research(technology)
    if data.raw.technology[technology] then return {type = "research", technology = technology} end
end

-- name, order, tag, simulation or image, trigger technology
local items = {
    {"zzz-railway", "a", "[item=rail]", {image = "railway-path"}, "JunkTrain_tech"},
    {"zzz-railway-wood", "b", "[item=scrap-rail]", {simulation = "wood"}, "JunkTrain_tech"},
    {"zzz-railway-signals", "c", "[entity=rail-signal]", {simulation = "signals"}, "automated-scrap-rail-transportation"},
    {"zzz-railway-chain", "d", "[entity=rail-chain-signal]", {simulation = "crossing"}, "automated-scrap-rail-transportation"},
    {"zzz-railway-stations", "e", "[entity=train-stop]", {simulation = "stations"}, "automated-scrap-rail-transportation"},
    {"zzz-railway-rolling-stock", "f", "[entity=locomotive]", {image = "rolling-stock"}, "railway"},
    {"zzz-railway-fuel", "g", "[item=rocket-fuel]", {image = "fuel"}, "railway"},
    {"zzz-railway-overload", "h", "[entity=cargo-wagon]", {image = "overload"}, "railway"},
    {"zzz-railway-mu", "i", "[technology=multiple-unit-train-control]", {image = "mu"}, "multiple-unit-train-control"},
    {"zzz-railway-electric", "j", "[entity=bet-locomotive]", {image = "electric"}, "bet-tech"},
    {"zzz-railway-elevated", "k", "[entity=rail-ramp]", {image = "elevated"}, "elevated-rail"},
    {"zzz-railway-control", "l", "[img=utility/train_stop_placement_indicator]", {}, "automated-rail-transportation"},
}

local list = {{type = "tips-and-tricks-item-category", name = CATEGORY, order = "b-c"}}
for _, entry in ipairs(items) do
    local title = entry[1] == CATEGORY
    list[#list + 1] = {
        type = "tips-and-tricks-item",
        name = entry[1],
        category = CATEGORY,
        order = entry[2],
        indent = title and 0 or 1,
        is_title = title or nil,
        tag = entry[3],
        starting_status = "unlocked",
        trigger = research(entry[5]),
        simulation = entry[4].simulation and simulations[entry[4].simulation] or nil,
        image = entry[4].image and (IMAGES .. entry[4].image .. ".png") or nil,
    }
end

data:extend(list)
