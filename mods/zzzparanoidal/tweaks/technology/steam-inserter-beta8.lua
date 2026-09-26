-- Beta 8 micro-final-fix: паровой манипулятор открывала basic-automation (ныне burner-mechanics).
-- Цена/свойства манипулятора и unit/prerequisites энергетики остаются 2.0.
local target = data.raw.technology["burner-mechanics"]
local recipe = "bob-steam-inserter"
if target and data.raw.recipe[recipe] then
	for _, technology in pairs(data.raw.technology) do
		if technology.max_level ~= "infinite" then
			for index = #(technology.effects or {}), 1, -1 do
				local effect = technology.effects[index]
				if effect.type == "unlock-recipe" and effect.recipe == recipe then
					table.remove(technology.effects, index)
				end
			end
		end
	end
	target.effects = target.effects or {}
	table.insert(target.effects, { type = "unlock-recipe", recipe = recipe })
end
