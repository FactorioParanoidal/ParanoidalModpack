-- Logistic memory units: the technology takes every science pack of its prerequisites (modsets change the packs
-- of memory-unit and logistic-system), so it never costs less than what it builds on.
local technology = data.raw.technology["logistic-memory-unit"]
if technology and technology.unit and technology.unit.ingredients then
	local ingredients = technology.unit.ingredients
	local present = {}
	for _, ingredient in pairs(ingredients) do
		present[ingredient[1] or ingredient.name] = true
	end
	for _, prerequisite in pairs(technology.prerequisites or {}) do
		local parent = data.raw.technology[prerequisite]
		local unit = parent and parent.unit
		for _, ingredient in pairs(unit and unit.ingredients or {}) do
			local pack = ingredient[1] or ingredient.name
			if pack and not present[pack] then
				present[pack] = true
				ingredients[#ingredients + 1] = {pack, 1}
			end
		end
	end
end
