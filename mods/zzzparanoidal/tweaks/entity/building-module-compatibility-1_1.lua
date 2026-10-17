-- Поведение модулей и маяков из 1.1, проверенное фактической вставкой в движке.
-- Скорости и слоты задаются отдельно; здесь только согласованные семейства зданий.
local machines = data.raw["assembling-machine"]

-- В 1.1 эти здания без слотов не получали бонусов маяков.
for _, name in ipairs({
    "CW-air-filter-machine-1",
    "bi-bio-garden",
    "bi-bio-garden-large",
    "bi-bio-garden-huge",
}) do
    local machine = machines[name]
    if machine then
        machine.effect_receiver = table.deepcopy(machine.effect_receiver or {})
        machine.effect_receiver.uses_beacon_effects = false
    end
end

-- В 2.0 одной маски allowed_effects недостаточно для прежних правил вставки.
-- Сохраняем остальные категории и запрещаем только выявленное отличие.
local function exclude_category(entity, excluded)
    if not entity then return end
    local categories = {}
    if entity.allowed_module_categories then
        for _, category in ipairs(entity.allowed_module_categories) do
            if category ~= excluded then categories[#categories + 1] = category end
        end
    else
        for category in pairs(data.raw["module-category"]) do
            if category ~= excluded then categories[#categories + 1] = category end
        end
        table.sort(categories)
    end
    entity.allowed_module_categories = categories
end

-- CW MK2–MK6 в 1.1 не принимали модули, создающие загрязнение.
for tier = 2, 6 do
    exclude_category(machines["CW-air-filter-machine-" .. tier], "pollution-create")
end

-- Только базовые термальные установки. Фильтруемые варианты в 1.1 имели
-- более широкую совместимость; их собственные настройки сохраняем.
local drills = data.raw["mining-drill"]
exclude_category(drills["angels-thermal-bore"], "effectivity")
exclude_category(drills["angels-thermal-extractor"], "effectivity")
