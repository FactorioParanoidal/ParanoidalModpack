--Удаляем из игры имбовые сельскохозяйственные модули, их рецепты и технологии
--(решение 2021 года, коммит 897a7572cc «Выпиливаем имбалансные агромодули из игры»)
local removed = {}
for i = 1, 8 do
	local name = i == 1 and "angels-bio-yield-module" or ("angels-bio-yield-module-" .. i)
	if data.raw.module[name] or data.raw.recipe[name] or data.raw.technology[name] then
		removed[name] = true
	end
	data.raw.module[name] = nil
	data.raw.recipe[name] = nil
	data.raw.recipe[name .. "-recycling"] = nil
	data.raw.technology[name] = nil
end

if not next(removed) then
	return
end

-- висячие ссылки на удалённые техи/рецепты в остальных технологиях
for _, tech in pairs(data.raw.technology) do
	if tech.prerequisites then
		for i = #tech.prerequisites, 1, -1 do
			if removed[tech.prerequisites[i]] then
				table.remove(tech.prerequisites, i)
			end
		end
	end
	if tech.effects then
		for i = #tech.effects, 1, -1 do
			local effect = tech.effects[i]
			if effect.type == "unlock-recipe" and removed[effect.recipe] then
				table.remove(tech.effects, i)
			end
		end
	end
end
