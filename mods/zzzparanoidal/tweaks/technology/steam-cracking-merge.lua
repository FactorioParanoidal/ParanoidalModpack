-- Объединяется только I уровень. II уровень остаётся двумя самостоятельными технологиями.
-- Выполняется после cracking-beta8 и остальных восстановлений дерева.
local target_name, legacy_name = "angels-steam-cracking-1", "angels-oil-steam-cracking-1"
local technologies = data.raw.technology
local target, legacy = technologies[target_name], technologies[legacy_name]
if not (target and legacy) then return end

local parents, seen = {}, {}
for _, technology in ipairs({ target, legacy }) do
    for _, name in ipairs(technology.prerequisites or {}) do
        if name ~= target_name and name ~= legacy_name and not seen[name] then
            parents[#parents + 1], seen[name] = name, true
        end
    end
end
target.prerequisites = parents

local effects, recipes = {}, {}
for _, technology in ipairs({ target, legacy }) do
    for _, effect in ipairs(technology.effects or {}) do
        local description = effect.effect_description
        local evolution = effect.type == "nothing" and type(description) == "table"
            and (description[1] == "research-evolution-factor-effect"
                or description[1] == "research-evolution-factor-effect-unknown")
        -- Финальный research-evolution-icon пересчитает одну подсказку по новой цене.
        if not evolution then
            if effect.type ~= "unlock-recipe" or not recipes[effect.recipe] then
                effects[#effects + 1] = table.deepcopy(effect)
                if effect.type == "unlock-recipe" then recipes[effect.recipe] = true end
            end
        end
    end
end
target.effects = effects
target.unit = {
    count = 100, time = 15,
    ingredients = { { "automation-science-pack", 1 }, { "logistic-science-pack", 1 } },
}
target.research_trigger = nil

-- Все потребители старой нефтяной технологии наследуют объединённую, без повторов.
for _, technology in pairs(technologies) do
    local list, included = {}, {}
    for _, name in ipairs(technology.prerequisites or {}) do
        if name == legacy_name then name = target_name end
        if not included[name] then
            list[#list + 1], included[name] = name, true
        end
    end
    if technology.prerequisites then technology.prerequisites = list end
end

-- Сохраняем ID до Lua-миграции, чтобы прочитать прежнее researched в существующих сейвах.
legacy.hidden = true
legacy.enabled = false
legacy.visible_when_disabled = false
legacy.prerequisites = {}
legacy.effects = {}
