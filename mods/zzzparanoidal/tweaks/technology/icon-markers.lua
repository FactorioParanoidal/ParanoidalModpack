-- Маркеры иконок технологий: римский уровень справа сверху, значок ветки в рамке слева сверху.
-- Существующие слои иконки сохраняются; маркеры добавляются отдельными floating-слоями.
-- Правила: tweaks/technology/icon-markers-rules.lua. Отсутствующая технология или значок пропускаются.
local rules = require("tweaks.technology.icon-markers-rules")
local graphics = "__zzzparanoidal__/graphics/technology/icon-markers/"

local badge_types = {
    "item", "fluid", "tool", "armor", "capsule", "ammo", "gun", "module", "repair-tool",
    "item-with-entity-data", "rail-planner", "selection-tool", "item-with-inventory",
}

local function find_badge(name, kind)
    if kind == "fluid" then return data.raw.fluid[name] end
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

for name, rule in pairs(rules) do
    local technology = data.raw.technology[name]
    local layers = technology and layers_of(technology, 256)
    local cx, cy, width
    if layers then cx, cy, width = geometry(layers, 256) end
    if cx then
        local function overlay(file)
            layers[#layers + 1] = {
                icon = graphics .. file .. ".png", icon_size = 256,
                scale = width / 256, shift = {cx, cy}, floating = true,
            }
        end
        if rule.level ~= nil then
            -- corner = "left": справа сверху у иконки уже есть свой знак (танки Schall).
            overlay((rule.corner == "left" and "level-left-" or "level-") .. rule.level)
        end
        local item = rule.badge and find_badge(rule.badge, rule.badge_type)
        local badge = item and layers_of(item, 64)
        local bx, by, bw
        if badge then bx, by, bw = geometry(badge, 64) end
        if bx then
            overlay("badge-frame")
            local factor = width * 0.225 / bw
            for _, layer in ipairs(badge) do
                local size = layer.icon_size or 64
                local shift = layer.shift or {0, 0}
                layer.scale = (layer.scale or 32 / size) * factor
                layer.shift = {
                    cx - width * 0.328125 + ((shift[1] or shift.x or 0) - bx) * factor,
                    cy - width * 0.328125 + ((shift[2] or shift.y or 0) - by) * factor,
                }
                layer.floating = true
                layers[#layers + 1] = layer
            end
        elseif rule.badge then
            log("icon-markers: значок не найден: " .. rule.badge .. " для " .. name)
        end
        technology.icon = nil
        technology.icon_size = nil
        technology.icons = layers
    end
end
