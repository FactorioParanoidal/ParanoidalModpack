-- «Советы и подсказки»: диспетчерская сеть поездов (Project Cybersyn) для новичков.
-- Тексты: locale/{en,ru}/tips-cybersyn.cfg, анимации: simulations.lua (рядом).
-- Только когда в сборке есть cybersyn. Категория оставлена в removals/tips-and-tricks.lua (KEEP_CATEGORIES).
if not mods["cybersyn"] then return end

local simulations = require("__zzzparanoidal__/prototypes/tips-and-tricks/cybersyn/simulations")

local CATEGORY = "zzz-cybersyn"

-- Пункт видим сразу (справочник); у заголовка триггер показывает уведомление после исследования.
local function tip(name, order, tag, simulation, title, trigger)
    return {
        type = "tips-and-tricks-item",
        name = name,
        category = CATEGORY,
        order = order,
        indent = title and 0 or 1,
        is_title = title or nil,
        tag = tag,
        starting_status = "unlocked",
        trigger = trigger,
        simulation = simulation and simulations[simulation] or nil,
    }
end

local list = {{type = "tips-and-tricks-item-category", name = CATEGORY, order = "b-c"}}
-- Порядок обучения: быстрый старт → устройство станций → как сеть выбирает → настройка → для опытных → неисправности.
local items = {
    {"zzz-cybersyn", "a", "[item=cybersyn-combinator]", "quickstart", true, {type = "unlock-recipe", recipe = "cybersyn-combinator"}},
    {"zzz-cybersyn-controller", "b", "[virtual-signal=signal-S]", "controller"},
    {"zzz-cybersyn-depot", "c", "[virtual-signal=signal-D]", "depot"},
    {"zzz-cybersyn-provider", "d", "[virtual-signal=up-arrow]", "provider"},
    {"zzz-cybersyn-requester", "e", "[virtual-signal=down-arrow]", "requester"},
    {"zzz-cybersyn-threshold", "f", "[virtual-signal=cybersyn-request-threshold]", "threshold"},
    {"zzz-cybersyn-delivery", "g", "[virtual-signal=cybersyn-priority]", "delivery"},
    {"zzz-cybersyn-bypass", "h", "[item=coal]", "bypass"},
    {"zzz-cybersyn-networks", "i", "[virtual-signal=signal-A]", "networks"},
    {"zzz-cybersyn-allow-list", "j", "[item=bulk-inserter]", "allow_list"},
    {"zzz-cybersyn-fluids", "k", "[item=fluid-wagon]", "fluids"},
    {"zzz-cybersyn-multi", "l", "[virtual-signal=cybersyn-locked-slots]", "multi"},
    {"zzz-cybersyn-problems", "m", "[virtual-signal=signal-alert]", "problems"},
}
for _, entry in ipairs(items) do
    list[#list + 1] = tip(entry[1], entry[2], entry[3], entry[4], entry[5], entry[6])
end

data:extend(list)
