-- Beta 8: очиститель воздуха IV открывал азот IV, не advanced chemistry IV.
-- После OV.execute; цены, прочие открытия и сами технологии азота не выравниваем.
if not mods["extendedangels"] then return end
local recipe = "angels-air-filter-4"
local target = data.raw.technology["angels-nitrogen-processing-4"]
if not target or target.max_level == "infinite" or not data.raw.recipe[recipe] then return end
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
