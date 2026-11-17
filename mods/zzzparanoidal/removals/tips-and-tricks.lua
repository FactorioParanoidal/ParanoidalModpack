-- Убирает из «Советов и подсказок» все категории, кроме перечисленных в KEEP_CATEGORIES:
-- своих и сверенных с кодом модов, чьи анимации прогнаны в сборке.
-- Причина: симуляции базовых и модовых подсказок падают в нашей сборке
-- (например, «Создание пачками»: move_cursor без position), а их тексты описывают обычную игру;
-- ванильные разделы заменяются своими (решение пользователя 2026-11-16).
-- Чтобы вернуть категорию, проверьте её анимации и тексты и добавьте в KEEP_CATEGORIES.

local KEEP_CATEGORIES = {
    ["start"] = true,
    -- Презентации «Брак и доводка» и «Качество» (prototypes/tips-and-tricks/quality).
    ["zzz-defects"] = true,
    ["zzz-quality"] = true,
    -- Диспетчерская сеть поездов (prototypes/tips-and-tricks/cybersyn); без cybersyn категории нет.
    ["zzz-cybersyn"] = true,
    -- Советы форка Yuoki (prototypes/paranoidal/tips.lua в моде Yuoki); без мода категории нет.
    ["yuoki"] = true,
    -- Советы paranoidal-robot-attrition (анимации со скриптом мода, 2026-11-17); без мода категории нет.
    ["pra-robot-attrition"] = true,
    -- Железная дорога сборки (prototypes/tips-and-tricks/railway).
    ["zzz-railway"] = true,
    -- Советы своих и доработанных модов, сверенные с их кодом (2026-11-16); без мода категории нет.
    ["factorissimo"] = true,       -- Paranoidal-factorissimo-4: «Фабрики»
    ["ppd"] = true,                -- paranoidal-power-districts: «Регулируемые районы»
    ["tpr-smog"] = true,           -- ToxicPollution2-reforged: «Токсичный смог»
    ["bpsb-intro"] = true,         -- blueprint-sandboxes: песочница (одна симуляция: 16 конвейеров)
    ["bpsb-factorissimo"] = true,  -- blueprint-sandboxes: песочница и фабрики
}

local items = data.raw["tips-and-tricks-item"] or {}
for name, item in pairs(items) do
    if not KEEP_CATEGORIES[item.category] then
        items[name] = nil
    end
end

-- Зависимости оставшихся подсказок — только на оставшиеся.
for _, item in pairs(items) do
    if item.dependencies then
        local kept = {}
        for _, dependency in pairs(item.dependencies) do
            if items[dependency] then kept[#kept + 1] = dependency end
        end
        item.dependencies = #kept > 0 and kept or nil
    end
end

local categories = data.raw["tips-and-tricks-item-category"] or {}
for name in pairs(categories) do
    if not KEEP_CATEGORIES[name] then
        categories[name] = nil
    end
end
