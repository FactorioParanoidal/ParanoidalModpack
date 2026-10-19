-- Тяжёлая дробовая турель требует обычную пулемётную турель в рецепте.
-- Возвращаем предка Beta 8, сохраняя остальные зависимости 2.0.
local technology = data.raw.technology["w93-scattergun-turrets"]
if technology and data.raw.technology["gun-turret"] then
	technology.prerequisites = technology.prerequisites or {}
	for _, name in ipairs(technology.prerequisites) do
		if name == "gun-turret" then return end
	end
	table.insert(technology.prerequisites, "gun-turret")
end
