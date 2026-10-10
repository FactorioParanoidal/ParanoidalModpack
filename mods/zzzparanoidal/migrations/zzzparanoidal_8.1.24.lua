-- Сохраняем доступ после переноса Valves в раннюю технологию Angels.
-- Исторический список этой версии; другие рецепты и исследования не сбрасываем.
if not script.active_mods["angelspetrochem"] or not script.active_mods["valves"] then return end

local valves = { "valves-one_way", "valves-overflow", "valves-top_up" }
for _, force in pairs(game.forces) do
    local early = force.technologies["angels-fluid-control"]
    local previous = force.technologies["fluid-handling"]
    -- В старых сейвах поздняя технология могла быть изучена без нынешней ранней предпосылки.
    -- Bob's пересчитывает эффекты после миграций: сохраняем доступ через изученную цель.
    if early and not early.researched and previous and previous.researched then
        early.researched = true
    end
    if (early and early.researched) or (previous and previous.researched) then
        for _, name in ipairs(valves) do
            local recipe = force.recipes[name]
            if recipe then recipe.enabled = true end
        end
    end
end
