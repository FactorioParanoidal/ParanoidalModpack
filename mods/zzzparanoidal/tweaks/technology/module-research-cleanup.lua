-- После modules-beta8 и всех правок дерева: убрать только остаточную цепочку Bob 2.0.
-- Прототипы, unlock-эффекты и ID сохраняются для уже исследованных технологий в сейвах.
local technologies = data.raw.technology
local obsolete = {}
for level = 2, 5 do obsolete["bob-modules-" .. level] = true end

-- Не скрывать неожиданного обязательного предка после обновления стороннего мода.
for name, technology in pairs(technologies) do
    if not obsolete[name] then
        for _, prerequisite in ipairs(technology.prerequisites or {}) do
            assert(not obsolete[prerequisite], "Module cleanup: " .. name .. " still requires " .. prerequisite)
        end
    end
end

local replacements = {
    { "modules", "bob-module-processor-board" },
    { "modules-2", "bob-module-processor-board-2" },
    { "modules-3", "bob-module-processor-board-3" },
}
for level, entry in ipairs(replacements) do
    local technology = assert(technologies[entry[1]], "Missing module technology: " .. entry[1])
    local has_unlock = false
    for _, effect in ipairs(technology.effects or {}) do
        if effect.type == "unlock-recipe" and effect.recipe == entry[2] then has_unlock = true end
    end
    assert(has_unlock, "Module cleanup would lose board unlock: " .. entry[2])
    technology.localised_name = { "technology-name.paranoidal-module-components-" .. level }
    technology.localised_description = { "technology-description.paranoidal-module-components-" .. level }
end

for name in pairs(obsolete) do
    local technology = technologies[name]
    if technology then
        technology.hidden = true
        technology.enabled = false
        technology.hidden_in_factoriopedia = true
    end
end

-- Согласованная тройка модулей с негорящими индикаторами; II–III остаются Beta 8.
local first = technologies.modules
first.icons = nil
first.icon = "__base__/graphics/technology/module.png"
first.icon_size = 256
first.icon_mipmaps = 4

for level = 1, 5 do
    local technology = assert(technologies["god-module-" .. level])
    technology.localised_name = { "technology-name.paranoidal-quantum-modules-" .. level }
end

-- Рецепт уже потребляет продуктивность VI; скорость/эффективность VI наследуются.
paralib.bobmods.lib.tech.add_prerequisite("thermonuclear-bomb", "bob-productivity-module-6")
