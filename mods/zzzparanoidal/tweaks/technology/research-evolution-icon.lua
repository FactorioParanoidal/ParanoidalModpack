-- research_evolution_factor добавляет в каждую техно эффект type="nothing"
-- без иконки, поэтому игра рисует дефолтный красный "+" (__core__/graphics/bonus-icon.png).
-- Восстанавливаем эффект у поздних технологий, задаём иконку и ставим после остальных эффектов.
-- Зависит от research_evolution_factor (см. info.json: "? research_evolution_factor"),
-- его data-final-fixes выполняется раньше zzzparanoidal, эффекты уже добавлены.
if not mods["research_evolution_factor"] then
    return
end

local icon = "__zzzparanoidal__/graphics/research-evolution-icon.png"
local params = require("__research_evolution_factor__/parameters")
local ignore_qol = settings.startup["research-evolution-factor-ignore-qol"].value
local ignore_infinite = settings.startup["research-evolution-factor-ignore-inf"].value
-- ключи локали эффекта из research_evolution_factor/locale/*/locale.cfg
local effect_keys = {
    ["research-evolution-factor-effect"] = true,
    ["research-evolution-factor-effect-unknown"] = true,
}

-- Формула отображения из research_evolution_factor/data-final-fixes.lua; параметры берём у мода.
local function evolution_effect(tech)
    local description = { "research-evolution-factor-effect-unknown" }
    if tech.unit and tech.unit.count then
        local cost = 0
        for _, ingredient in pairs(tech.unit.ingredients or {}) do
            local name = ingredient.name or ingredient[1]
            local amount = ingredient.amount or ingredient[2]
            if name and (not ingredient.type or ingredient.type == "item") then
                cost = cost + amount * (params.science_packet_cost[name] or 1)
            end
        end
        local inc = tech.unit.count * cost * 0.00001 * params.linear_factor + params.constant_factor * 0.01
        description = {
            "research-evolution-factor-effect",
            tostring(math.floor((1 - math.exp(-inc)) * 100000 + 0.5) * 0.001),
        }
    end
    return { type = "nothing", effect_description = description }
end

for _, tech in pairs(data.raw.technology) do
    -- Исключения как в control.lua мода; в прототипе формула находится в unit.count_formula.
    local participates = not (
        tech.hidden
        or (ignore_qol and string.sub(tech.name, 1, 4) == "qol-")
        or (ignore_infinite and tech.unit and tech.unit.count_formula)
    )
    if tech.effects or participates then
        local effects, evolution_effects = {}, {}
        for _, effect in ipairs(tech.effects or {}) do
            if
                effect.type == "nothing"
                and type(effect.effect_description) == "table"
                and effect_keys[effect.effect_description[1]]
            then
                table.insert(evolution_effects, effect)
            else
                table.insert(effects, effect)
            end
        end
        if participates and #evolution_effects == 0 then
            evolution_effects[1] = evolution_effect(tech)
        end
        for _, effect in ipairs(evolution_effects) do
            effect.icon = icon
            effect.icon_size = 64
            effect.use_icon_overlay_constant = false
            table.insert(effects, effect)
        end
        tech.effects = effects
    end
end
