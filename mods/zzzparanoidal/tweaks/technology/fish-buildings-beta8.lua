-- Beta 8: аквариум II открывался вместе с разведением рыбы; III — отдельным узлом.
-- Нынешняя технология -4 открывает постройку III: соответствие по роли, не суффиксу.
-- После OV.execute; рыб 0–2 и характеристики аквариумов не возвращаем.
local technologies = data.raw.technology
local second = technologies["angels-bio-refugium-fish-2"]
local redundant = technologies["angels-bio-refugium-fish-3"]
local third = technologies["angels-bio-refugium-fish-4"]
local recipe = "angels-bio-refugium-fish-2"
if second and redundant and third and data.raw.recipe[recipe] then
	for _, technology in pairs(technologies) do
		if technology.max_level ~= "infinite" then
			for index = #(technology.effects or {}), 1, -1 do
				local effect = technology.effects[index]
				if effect.type == "unlock-recipe" and effect.recipe == recipe then
					table.remove(technology.effects, index)
				end
			end
		end
	end
	second.effects = second.effects or {}
	table.insert(second.effects, { type = "unlock-recipe", recipe = recipe })
	-- Display the third active tier without renaming the saved technology ID.
	third.localised_name = { "technology-name.paranoidal-fish-farm-3" }
	third.prerequisites = {
		"angels-bio-refugium-fish-2", "chemical-science-pack", "processing-unit", "angels-titanium-smelting-1",
	}
	third.unit = {
		count = 100, time = 30,
		ingredients = { { "automation-science-pack", 1 }, { "logistic-science-pack", 1 }, { "chemical-science-pack", 1 } },
	}
	-- Единственный потребитель лишнего промежуточного узла перенесён выше.
	-- Сам прототип и его non-unlock эффекты сохраняются.
	redundant.hidden = true
	redundant.enabled = false
end
