-- Временно убирает все «Советы и подсказки», кроме категории PARANOIDAL
-- («PARANOIDAL» и «не обновляйте моды», prototypes/tips-and-tricks/1-1-1-start).
-- Причина: симуляции базовых и модовых подсказок падают в нашей сборке
-- (например, «Создание пачками»: move_cursor без position).
-- Чтобы вернуть категорию, добавьте её в KEEP_CATEGORIES.

local KEEP_CATEGORIES = {
    ["start"] = true,
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
