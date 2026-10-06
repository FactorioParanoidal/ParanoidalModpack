-- Beta 8: обработка бочек требует исследования зелёной науки.
-- Согласованные открытия рецептов 2.0 не меняются.
local technology = data.raw.technology["bob-fluid-barrel-processing"]
if technology and data.raw.technology["logistic-science-pack"] then
	technology.prerequisites = technology.prerequisites or {}
	for _, name in ipairs(technology.prerequisites) do
		if name == "logistic-science-pack" then return end
	end
	table.insert(technology.prerequisites, "logistic-science-pack")
end
