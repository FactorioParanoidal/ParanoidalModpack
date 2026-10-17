-- Beta 8 normal: обычный/железобетон в ценах химических построек, не кирпичи Angels.
-- Только перечисленные рецепты; характеристики, категории и продуктивность остаются 2.0.
local buildings = {
	"angels-electrolyser-3", "angels-electrolyser-4", "angels-advanced-chemical-plant-2",
	"angels-gas-refinery-2", "angels-gas-refinery-3",
	"angels-gas-refinery-small-2", "angels-gas-refinery-small-3", "angels-gas-refinery-small-4",
	"angels-separator-2", "angels-separator-3", "angels-separator-4",
	"angels-steam-cracker-3", "angels-steam-cracker-4",
}
local concrete = {
	["angels-concrete-brick"] = "concrete",
	["angels-reinforced-concrete-brick"] = "refined-concrete",
	["angels-titanium-concrete-brick"] = "refined-concrete",
}
for _, name in ipairs(buildings) do
	local recipe = data.raw.recipe[name]
	if recipe then
		for _, ingredient in ipairs(recipe.ingredients) do
			local replacement = concrete[ingredient.name]
			if replacement and data.raw.item[replacement] then ingredient.name = replacement end
		end
	end
end
-- Включённая в 2.0 платина переключила ветку petrochem override.
-- Возвращаем конкретные руды катализаторов, не отключаем платину/её добычу.
for _, change in ipairs({
	{ "angels-catalyst-metal-blue", "bob-gold-ore", "bob-cobalt-ore" },
	{ "angels-catalyst-metal-yellow", "angels-platinum-ore", "bob-nickel-ore" },
}) do
	local recipe = data.raw.recipe[change[1]]
	if recipe and data.raw.item[change[3]] then
		for _, ingredient in ipairs(recipe.ingredients) do
			if ingredient.name == change[2] then ingredient.name = change[3] end
		end
	end
end
