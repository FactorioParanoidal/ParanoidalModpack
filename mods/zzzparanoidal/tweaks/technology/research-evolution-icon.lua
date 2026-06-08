-- research_evolution_factor добавляет в каждую техно эффект type="nothing"
-- без иконки, поэтому игра рисует дефолтный красный "+" (__core__/graphics/bonus-icon.png).
-- Меняем его на иконку-график "роста эволюции".
-- Зависит от research_evolution_factor (см. info.json: "? research_evolution_factor"),
-- его data-final-fixes выполняется раньше zzzparanoidal, эффекты уже добавлены.
if not mods["research_evolution_factor"] then
    return
end

local icon = "__zzzparanoidal__/graphics/research-evolution-icon.png"
-- ключи локали эффекта из research_evolution_factor/locale/*/locale.cfg
local effect_keys = {
    ["research-evolution-factor-effect"] = true,
    ["research-evolution-factor-effect-unknown"] = true,
}

for _, tech in pairs(data.raw.technology) do
    if tech.effects then
        for _, effect in ipairs(tech.effects) do
            if
                effect.type == "nothing"
                and type(effect.effect_description) == "table"
                and effect_keys[effect.effect_description[1]]
            then
                effect.icon = icon
                effect.icon_size = 64
                effect.use_icon_overlay_constant = false
            end
        end
    end
end
