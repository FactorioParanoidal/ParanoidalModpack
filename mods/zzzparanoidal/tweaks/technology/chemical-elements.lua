-- Карточки C2 имеют одного владельца: после Reskins, старых замен и оптимизации атласа.
-- Не сравниваем прежние картинки: изменение чужой иконки не отменяет выбор сборки.
local registry = require("tweaks.technology.chemical-elements-data")
local mark = require("tweaks.technology.icon-markers")
local root = "__zzzparanoidal__/graphics/technology/chemical-elements/"
local marker_root = "__zzzparanoidal__/graphics/technology/icon-markers/"
local rules, count = {}, 0

for name, entry in pairs(registry) do
    local technology = assert(data.raw.technology[name],
        "chemical-elements: expected technology missing: " .. name .. "; update the C2 registry")
    if entry.badge then
        local kind = entry.badge_type or "item"
        assert(data.raw[kind] and data.raw[kind][entry.badge],
            "chemical-elements: branch badge missing: " .. entry.badge .. " for " .. name)
    end
    technology.icon = root .. entry.element .. ".png"
    technology.icon_size = 256
    technology.icons, technology.icon_mipmaps = nil, nil
    rules[name] = {level = entry.level, badge = entry.badge, badge_type = entry.badge_type}
    count = count + 1
end

-- Пересоздаём маркеры относительно новой основы, а не старых слоёв 32/128/256 px.
mark(rules)
for name, entry in pairs(registry) do
    local technology = data.raw.technology[name]
    local layers = technology.icons
    if layers then
        -- Значок продукта занимает угол рамки C2, не закрывает атомный номер.
        -- Римский уровень остаётся прежнего размера в правом верхнем углу.
        for i = 2, #layers do
            local layer = layers[i]
            if layer.floating and not layer.icon:find(marker_root .. "level-", 1, true) then
                local shift = layer.shift or {0, 0}
                layer.scale = (layer.scale or 32 / (layer.icon_size or 64)) * 0.65
                layer.shift = {
                    -64 + ((shift[1] or shift.x or 0) + 64) * 0.65 + 4,
                    -64 + ((shift[2] or shift.y or 0) + 64) * 0.65 + 4,
                }
            end
        end
    end
    assert((layers and layers[1].icon or technology.icon) == root .. entry.element .. ".png",
        "chemical-elements: card overwritten: " .. name)
    if technology.enabled ~= false and entry.level then
        local expected, found = marker_root .. "level-" .. entry.level .. ".png", false
        for _, layer in ipairs(layers or {}) do if layer.icon == expected then found = true end end
        assert(found, "chemical-elements: level marker missing: " .. name)
    end
    if technology.enabled ~= false and entry.badge then
        assert(layers and #layers >= (entry.level and 4 or 3),
            "chemical-elements: branch marker missing: " .. name)
    end
end
log("chemical-elements: assigned " .. count .. " technologies; C2 cards and branch/level markers verified")
