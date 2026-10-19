-- Beta 8: первый топор после стали; цена, бонус и оформление остаются прежними.
local technology = data.raw.technology["steel-axe"]
if technology and data.raw.technology["steel-processing"] then
	local prerequisites = {}
	for _, name in ipairs(technology.prerequisites or {}) do
		if name ~= "bob-alloy-processing" and name ~= "steel-processing" then
			table.insert(prerequisites, name)
		end
	end
	table.insert(prerequisites, "steel-processing")
	technology.prerequisites = prerequisites
end
