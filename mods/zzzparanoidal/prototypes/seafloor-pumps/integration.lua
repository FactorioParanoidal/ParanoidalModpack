-- После OV и чужих правок рецептов: цены Beta 8 и единственное открытие каждого тира.
local tiers = require("prototypes.seafloor-pumps.tiers")

local opener = {}
for _, spec in ipairs(tiers) do
	local recipe = data.raw.recipe[spec.name]
	if recipe then
		recipe.ingredients = table.deepcopy(spec.ingredients)
		recipe.energy_required = spec.energy_required
		opener[spec.name] = spec.technology
	end
end

for name, technology in pairs(data.raw.technology) do
	local effects = technology.effects or {}
	for index = #effects, 1, -1 do
		local effect = effects[index]
		if effect.type == "unlock-recipe" and opener[effect.recipe] and opener[effect.recipe] ~= name then
			table.remove(effects, index)
		end
	end
end

for recipe, name in pairs(opener) do
	local technology = data.raw.technology[name]
	if technology then
		technology.effects = technology.effects or {}
		local unlocked = false
		for _, effect in ipairs(technology.effects) do
			unlocked = unlocked or (effect.type == "unlock-recipe" and effect.recipe == recipe)
		end
		if not unlocked then
			table.insert(technology.effects, { type = "unlock-recipe", recipe = recipe })
		end
	end
end
