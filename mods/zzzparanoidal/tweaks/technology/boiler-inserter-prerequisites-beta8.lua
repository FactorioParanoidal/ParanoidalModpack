-- Согласованные связи Beta 8; цены, эффекты и рецепты сохраняются.
local technologies = data.raw.technology
local boiler = technologies["bob-boiler-3"]
if boiler and technologies["angels-invar-smelting-1"] then
	local prerequisites = {}
	local has_invar = false
	for _, name in ipairs(boiler.prerequisites or {}) do
		if name ~= "angels-aluminium-smelting-1" and name ~= "angels-nickel-smelting-1" then
			table.insert(prerequisites, name)
			if name == "angels-invar-smelting-1" then has_invar = true end
		end
	end
	if not has_invar then table.insert(prerequisites, "angels-invar-smelting-1") end
	boiler.prerequisites = prerequisites
end

local capacity = technologies["inserter-capacity-bonus-4"]
if capacity then
	local prerequisites = {}
	for _, name in ipairs(capacity.prerequisites or {}) do
		if name ~= "bob-advanced-logistic-science-pack" then
			table.insert(prerequisites, name)
		end
	end
	capacity.prerequisites = prerequisites
end
