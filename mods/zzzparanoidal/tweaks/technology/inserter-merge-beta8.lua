-- ПР-033: связи обычных тиров Beta 8, без отдельной фильтрующей линейки.
-- Unit, эффекты вместимости и бесконечные технологии не меняем.
local prerequisites = {
	["bulk-inserter"] = { "fast-inserter" },
	["bob-express-inserter"] = { "fast-inserter", "logistics-3" },
	["bob-turbo-inserter"] = { "logistics-4" },
}
for name, list in pairs(prerequisites) do
	local technology = data.raw.technology[name]
	local available = technology and technology.max_level ~= "infinite"
	for _, prerequisite in ipairs(list) do available = available and data.raw.technology[prerequisite] ~= nil end
	if available then technology.prerequisites = list end
end

-- ПР-034: ровно один предок электробура, не цена/рецепт/характеристики добычи.
local mining = data.raw.technology["electric-mining-drill"]
if mining and mining.max_level ~= "infinite" then
	for index = #(mining.prerequisites or {}), 1, -1 do
		if mining.prerequisites[index] == "automation-science-pack" then
			table.remove(mining.prerequisites, index)
		end
	end
end
-- ПР-035: вся follower-robot-count цепь остаётся 2.0, патч ей не требуется.
