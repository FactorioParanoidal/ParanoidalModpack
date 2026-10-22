-- Beta 8 normal: те же три роли аквариумов и цепь улучшений Extended Angels.
-- Только бетон в цене II/III; категории, оформление и характеристики не меняем.
for _, definition in ipairs({
	{ "angels-bio-refugium-fish-2", "angels-concrete-brick", "concrete" },
	{ "angels-bio-refugium-fish-3", "angels-reinforced-concrete-brick", "refined-concrete" },
}) do
	local recipe = data.raw.recipe[definition[1]]
	if recipe and data.raw.item[definition[3]] then
		for _, ingredient in ipairs(recipe.ingredients) do
			if ingredient.name == definition[2] then ingredient.name = definition[3] end
		end
	end
end
