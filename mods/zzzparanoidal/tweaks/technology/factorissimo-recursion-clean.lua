-- Рекурсия выдаётся скриптом (по .researched), а не эффектом, поэтому пустой
-- nothing-эффект Factorissimo (голый "+") можно безопасно убрать.
if not mods["factorissimo-2-notnotmelon"] then
    return
end

for _, name in pairs({ "factory-recursion-t1", "factory-recursion-t2" }) do
    local tech = data.raw.technology[name]
    if tech and tech.effects then
        for i = #tech.effects, 1, -1 do
            local effect = tech.effects[i]
            if effect.type == "nothing" and effect.effect_description == "" then
                table.remove(tech.effects, i)
            end
        end
    end
end
