-- Beta 8: паровой двигатель II требует исследования зелёной науки.
local technology = data.raw.technology["bob-steam-engine-2"]
if technology and data.raw.technology["logistic-science-pack"] then
	technology.prerequisites = technology.prerequisites or {}
	for _, name in ipairs(technology.prerequisites) do
		if name == "logistic-science-pack" then return end
	end
	table.insert(technology.prerequisites, "logistic-science-pack")
end
