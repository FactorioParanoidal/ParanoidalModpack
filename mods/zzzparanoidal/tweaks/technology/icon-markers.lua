-- Маркеры иконок технологий: римский уровень справа сверху, значок ветки в рамке слева сверху.
-- Существующие слои иконки сохраняются; маркеры добавляются отдельными floating-слоями.
-- Правила: tweaks/technology/icon-markers-rules.lua. Отсутствующие и отключённые технологии пропускаются.
local rules = require("tweaks.technology.icon-markers-rules")
local graphics = "__zzzparanoidal__/graphics/technology/icon-markers/"
local marker_scale = 0.85 -- Цифры, рамка и значок уменьшены на 15%; углы сохраняются.

local badge_types = {
    "item", "fluid", "tool", "armor", "capsule", "ammo", "gun", "module", "repair-tool",
    "item-with-entity-data", "rail-planner", "selection-tool", "item-with-inventory",
}

local function find_badge(name, kind)
    if kind == "fluid" then return data.raw.fluid[name] end
    if kind == "recipe" then return data.raw.recipe and data.raw.recipe[name] end
    for _, t in ipairs(badge_types) do
        local p = data.raw[t] and data.raw[t][name]
        if p then return p end
    end
end

local function layers_of(prototype, expected)
    if prototype.icons then return table.deepcopy(prototype.icons) end
    if not prototype.icon then return nil end
    return {{ icon = prototype.icon, icon_size = prototype.icon_size or expected }}
end

local function geometry(layers, expected)
    local left, top, right, bottom
    for _, layer in ipairs(layers) do
        if not layer.floating then
            local size = layer.icon_size or 64
            local width = size * (layer.scale or (expected / 2) / size)
            local shift = layer.shift or {0, 0}
            local x, y = shift[1] or shift.x or 0, shift[2] or shift.y or 0
            left = math.min(left or math.huge, x - width / 2)
            right = math.max(right or -math.huge, x + width / 2)
            top = math.min(top or math.huge, y - width / 2)
            bottom = math.max(bottom or -math.huge, y + width / 2)
        end
    end
    if not left then return nil end
    return (left + right) / 2, (top + bottom) / 2, math.max(right - left, bottom - top)
end

local function equal(a, b)
    if type(a) ~= type(b) then return false end
    if type(a) ~= "table" then return a == b end
    for key, value in pairs(a) do
        if not equal(value, b[key]) then return false end
    end
    for key in pairs(b) do
        if a[key] == nil then return false end
    end
    return true
end

-- Размеры технологии и предмета различаются; сравниваем относительное расположение слоёв.
local function same_icon(base, badge)
    if #base ~= #badge then return false end
    local ax, ay, aw = geometry(base, 256)
    local bx, by, bw = geometry(badge, 64)
    if not ax or not bx or aw == 0 or bw == 0 then return false end
    for i, a in ipairs(base) do
        local b = badge[i]
        if a.icon ~= b.icon or not equal(a.tint, b.tint) then return false end
        local as, bs = a.icon_size or 64, b.icon_size or 64
        local ash, bsh = a.shift or {0, 0}, b.shift or {0, 0}
        local av = {as * (a.scale or 128 / as) / aw,
            ((ash[1] or ash.x or 0) - ax) / aw, ((ash[2] or ash.y or 0) - ay) / aw}
        local bv = {bs * (b.scale or 32 / bs) / bw,
            ((bsh[1] or bsh.x or 0) - bx) / bw, ((bsh[2] or bsh.y or 0) - by) / bw}
        for j = 1, 3 do
            if math.abs(av[j] - bv[j]) > 0.000001 then return false end
        end
    end
    return true
end

local function next_badge(technology, base)
    -- Сначала ищем другой продукт; если продукты одинаковые, пробуем собственные иконки рецептов.
    for pass = 1, 2 do
        for _, effect in ipairs(technology.effects or {}) do
            local recipe = effect.type == "unlock-recipe" and data.raw.recipe[effect.recipe]
            if recipe and not recipe.hidden then
                local candidates = pass == 1 and (recipe.results or {}) or {{name = effect.recipe, type = "recipe"}}
                for _, candidate in ipairs(candidates) do
                    local name, kind = candidate.name or candidate[1], candidate.type or "item"
                    local prototype = name and find_badge(name, kind)
                    local layers = prototype and layers_of(prototype, 64)
                    if layers and not same_icon(base, layers) then return layers end
                end
            end
        end
    end
end

for name, rule in pairs(rules) do
    local technology = data.raw.technology[name]
    local layers = technology and technology.enabled ~= false and layers_of(technology, 256)
    local cx, cy, width
    if layers then cx, cy, width = geometry(layers, 256) end
    if cx then
        local inset = width * (1 - marker_scale) / 2
        local function overlay(file, left)
            layers[#layers + 1] = {
                icon = graphics .. file .. ".png", icon_size = 256,
                scale = width * marker_scale / 256,
                shift = {cx + (left and -inset or inset), cy - inset}, floating = true,
            }
        end
        local item = rule.badge and find_badge(rule.badge, rule.badge_type)
        local badge = item and layers_of(item, 64)
        if rule.badge_from_unlocks or (badge and same_icon(layers, badge)) then
            badge = next_badge(technology, layers)
        end
        if rule.level ~= nil then
            -- corner = "left": справа сверху у иконки уже есть свой знак (танки Schall).
            overlay((rule.corner == "left" and "level-left-" or "level-") .. rule.level, rule.corner == "left")
        end
        local bx, by, bw
        if badge then bx, by, bw = geometry(badge, 64) end
        if bx then
            overlay("badge-frame", true)
            local factor = width * 0.225 * marker_scale / bw
            for _, layer in ipairs(badge) do
                local size = layer.icon_size or 64
                local shift = layer.shift or {0, 0}
                layer.scale = (layer.scale or 32 / size) * factor
                layer.shift = {
                    cx - inset - width * 0.328125 * marker_scale + ((shift[1] or shift.x or 0) - bx) * factor,
                    cy - inset - width * 0.328125 * marker_scale + ((shift[2] or shift.y or 0) - by) * factor,
                }
                layer.floating = true
                layers[#layers + 1] = layer
            end
        elseif rule.badge and not item then
            log("icon-markers: значок не найден: " .. rule.badge .. " для " .. name)
        end
        technology.icon = nil
        technology.icon_size = nil
        technology.icons = layers
    end
end
