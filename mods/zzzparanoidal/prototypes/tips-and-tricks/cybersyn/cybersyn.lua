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
local items = {
    {"zzz-cybersyn", "a", "[item=cybersyn-combinator]", "overview", true, {type = "unlock-recipe", recipe = "cybersyn-combinator"}},
    {"zzz-cybersyn-controller", "b", "[virtual-signal=signal-S]", "controller"},
    {"zzz-cybersyn-depot", "c", "[virtual-signal=signal-D]", "depot"},
    {"zzz-cybersyn-provider", "d", "[virtual-signal=up-arrow]", "provider"},
    {"zzz-cybersyn-requester", "e", "[virtual-signal=down-arrow]", "requester"},
    {"zzz-cybersyn-threshold", "f", "[virtual-signal=cybersyn-request-threshold]", "threshold"},
    {"zzz-cybersyn-delivery", "g", "[item=locomotive]", "delivery"},
    {"zzz-cybersyn-bypass", "h", "[virtual-signal=right-arrow]", "bypass"},
    {"zzz-cybersyn-refuel", "i", "[item=coal]", "refuel"},
    {"zzz-cybersyn-networks", "j", "[virtual-signal=signal-A]", "networks"},
    {"zzz-cybersyn-masks", "k", "[virtual-signal=signal-each]", "masks"},
    {"zzz-cybersyn-priority", "l", "[virtual-signal=cybersyn-priority]", "priority"},
    {"zzz-cybersyn-allow-list", "m", "[item=bulk-inserter]", "allow_list"},
    {"zzz-cybersyn-fluids", "n", "[item=fluid-wagon]", "fluids"},
    {"zzz-cybersyn-multi", "o", "[virtual-signal=cybersyn-locked-slots]", "multi"},
    {"zzz-cybersyn-station-control", "p", "[virtual-signal=signal-C]", "station_control"},
    {"zzz-cybersyn-problems", "q", "[virtual-signal=signal-alert]", "problems"},
}
for _, entry in ipairs(items) do
    list[#list + 1] = tip(entry[1], entry[2], entry[3], entry[4], entry[5], entry[6])
end

data:extend(list)
