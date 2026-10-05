-- Согласование открытий с материалами после OV и восстановления модульного дерева.
-- Только prerequisites/effects: цены, рецепты и характеристики остаются прежними.
local tech = paralib.bobmods.lib.tech

local prerequisites = {
	-- Химия I наследует кирпич через металлургию II.
	{ "angels-metallurgy-2", "angels-stone-smelting-1" },
	{ "angels-advanced-chemistry-2", "concrete" },
	{ "angels-metallurgy-3", "concrete" },
	{ "memory-unit", "warehouse-research" },
	{ "napalm", "flamethrower" },
	-- Первые потребители высшей огранки; старшие/составные модули наследуют связь.
	{ "bob-speed-module-5", "bob-gem-processing-3" },
	{ "bob-efficiency-module-5", "bob-gem-processing-3" },
	{ "bob-productivity-module-5", "bob-gem-processing-3" },
	{ "bob-pollution-clean-module-5", "bob-gem-processing-3" },
	{ "bob-pollution-create-module-5", "bob-gem-processing-3" },
	{ "advanced-machining", "automation-6" },
	{ "advanced-machining", "bob-bulk-inserter-4" },
}
for _, pair in ipairs(prerequisites) do
	if data.raw.technology[pair[1]] and data.raw.technology[pair[2]] then
		tech.add_prerequisite(pair[1], pair[2])
	end
end

local moves = {
	-- Примитивная латунь остаётся на месте; литейные способы ждут цинковых слитков/расплава.
	{ "angels-liquid-molten-brass", "angels-brass-smelting-1", "angels-zinc-smelting-1" },
	{ "molten-brass-alloy-mixing-1", "angels-brass-smelting-1", "angels-zinc-smelting-1" },
	-- Удобрение открывается на II; сама ферма I и природные сады не меняются.
	{ "desert-garden-generation", "angels-bio-farm-1", "angels-bio-farm-2" },
	{ "swamp-garden-generation", "angels-bio-farm-1", "angels-bio-farm-2" },
	{ "temperate-garden-generation", "angels-bio-farm-1", "angels-bio-farm-2" },
	-- Сохраняем независимые открытия труб через технологии вольфрама и его сплавов.
	{ "bob-copper-tungsten-pipe", "angels-nitinol-smelting-1", "angels-copper-tungsten-smelting-1" },
	{ "bob-copper-tungsten-pipe-to-ground", "angels-nitinol-smelting-1", "angels-copper-tungsten-smelting-1" },
}
for _, move in ipairs(moves) do
	if data.raw.recipe[move[1]] and data.raw.technology[move[2]] and data.raw.technology[move[3]] then
		tech.remove_recipe_unlock(move[2], move[1])
		tech.add_recipe_unlock(move[3], move[1])
	end
end
