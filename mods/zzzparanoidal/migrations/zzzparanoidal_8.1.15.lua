-- Если изучена хотя бы одна прежняя ветка I, сохраняем доступ через объединённую.
-- Legacy-прототип оставлен скрытым: его researched доступен во время миграции.
local target_name, legacy_name = "angels-steam-cracking-1", "angels-oil-steam-cracking-1"
for _, force in pairs(game.forces) do
    local target, legacy = force.technologies[target_name], force.technologies[legacy_name]
    if target and legacy then
        local queue, replace_queue = {}, false
        for _, technology in ipairs(force.research_queue or {}) do
            queue[#queue + 1] = technology
            if technology.name == legacy_name then replace_queue = true end
        end
        if target.researched or legacy.researched then
            target.researched = true
            -- Уже изученный target не переключается false -> true: включаем новые открытия явно.
            for _, effect in pairs(target.prototype.effects or {}) do
                if effect.type == "unlock-recipe" and force.recipes[effect.recipe] then
                    force.recipes[effect.recipe].enabled = true
                end
            end
        end
        legacy.enabled = false
        if replace_queue then
            local replacement, seen = {}, {}
            for _, technology in ipairs(queue) do
                if technology.name == legacy_name then technology = target end
                if not technology.researched and not seen[technology.name] then
                    replacement[#replacement + 1] = technology
                    seen[technology.name] = true
                end
            end
            -- Движок пропустит исследования, чьи новые обязательные предки ещё не изучены.
            force.research_queue = replacement
        end
    end
end
