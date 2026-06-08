-- Factorissimo вешает на factory-recursion-t1/t2 пустой эффект-заглушку
-- {type="nothing", effect_description=""}, который рисуется как голый "+".
-- Способность вкладывать фабрики выдаётся скриптом (factory-buildings.lua, по .researched),
-- эффект косметический. Убираем только пустые nothing-эффекты; эффект эволюции
-- (research_evolution_factor, у него описание — таблица) не трогаем.
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
