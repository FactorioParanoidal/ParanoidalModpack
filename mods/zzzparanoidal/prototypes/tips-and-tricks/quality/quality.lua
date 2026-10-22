-- «Советы и подсказки»: две презентации для новичков — «Брак и доводка» и «Качество».
-- Тексты: locale/{en,ru}/tips-quality.cfg, анимации: simulations.lua (рядом).
-- Только когда включено качество ic-more-qualities; брак — когда включена его система брака
-- (те же стартовые настройки, что читает tweaks/recipe/quality-modules.lua).
-- Категории оставлены в removals/tips-and-tricks.lua (KEEP_CATEGORIES).
if not mods["ic-more-qualities"] then return end
local quality_setting = settings.startup["ic-more-qualities-quality"]
if quality_setting and quality_setting.value == false then return end
local defects_setting = settings.startup["ic-more-qualities-defects-preview"]
local defects_on = defects_setting ~= nil and defects_setting.value == true

local simulations = require("__zzzparanoidal__/prototypes/tips-and-tricks/quality/simulations")

local DEFECTS = "zzz-defects"
local QUALITY = "zzz-quality"

-- Пункт видим сразу (справочник); у заголовка триггер показывает уведомление.
local function tip(category, name, order, tag, simulation, title, trigger)
    return {
        type = "tips-and-tricks-item",
        name = name,
        category = category,
        order = order,
        indent = title and 0 or 1,
        is_title = title or nil,
        tag = tag,
        starting_status = "unlocked",
        trigger = trigger,
        simulation = simulation and simulations[simulation] or nil,
    }
end

local list = {}

if defects_on then
    list[#list + 1] = {type = "tips-and-tricks-item-category", name = DEFECTS, order = "b-a"}
    local items = {
        {"zzz-defects", "a", "[img=quality/ic-defect-5]", "defects", true, {type = "time-elapsed", ticks = 60 * 60 * 3}},
        {"zzz-defects-origin", "b", "[item=iron-chest,quality=ic-defect-5]", "defects_origin"},
        {"zzz-defects-research", "c", "[img=technology/ic-defect-control-1]", "defects_research"},
        {"zzz-defects-ingredients", "d", "[item=lighted-small-electric-pole,quality=ic-defect-3]", "defects_ingredients"},
        {"zzz-defects-buildings", "e", "[item=small-electric-pole,quality=ic-defect-5]", "defects_buildings"},
        {"zzz-defects-workshop", "f", "[item=ic-refine-workshop]", "defects_workshop"},
        {"zzz-defects-workshop-modes", "g", "[item=repair-pack]", "defects_workshop_modes"},
        {"zzz-defects-production-modes", "h", "[item=assembling-machine-1]", "defects_production_modes"},
        {"zzz-defects-post", "i", "[item=ic-control-post]", "defects_post"},
        {"zzz-defects-panel", "j", "[virtual-signal=signal-info]", nil},
    }
    for _, entry in ipairs(items) do
        list[#list + 1] = tip(DEFECTS, entry[1], entry[2], entry[3], entry[4], entry[5], entry[6])
    end
end

list[#list + 1] = {type = "tips-and-tricks-item-category", name = QUALITY, order = "b-b"}
local items = {
    {"zzz-quality", "a", "[img=quality/uncommon]", "quality", true, {type = "unlock-recipe", recipe = "quality-module"}},
    {"zzz-quality-modules", "b", "[item=quality-module]", "quality_modules"},
    {"zzz-quality-ladder", "c", "[item=quality-module-3]", "quality_ladder"},
    {"zzz-quality-ingredients", "d", "[item=iron-plate,quality=uncommon]", "quality_ingredients"},
    {"zzz-quality-recycling", "e", "[item=recycler-1]", "quality_recycling"},
    {"zzz-quality-tools", "g", "[img=quality_info]", nil},
}
if defects_on then
    -- Режимы производства есть только вместе с системой брака.
    items[#items + 1] = {"zzz-quality-modes", "f", "[img=utility/clock]", "quality_modes"}
end
for _, entry in ipairs(items) do
    list[#list + 1] = tip(QUALITY, entry[1], entry[2], entry[3], entry[4], entry[5], entry[6])
end

data:extend(list)
