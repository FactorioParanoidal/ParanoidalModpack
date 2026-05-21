-- Частичный порт Oberhaul (1.1-only, не портирован в 2.0):
-- mods/Oberhaul/prototypes/angelssmelting.lua. Без этих патчей slag в 2.0
-- добывается только через ore-sorting (4-8 crushed → 1 slag), весь stone-
-- crushed уходит в slag-slurry → mineral-sludge → caustic catalyst дефицит.

require("__zzzparanoidal__.paralib")

-- 1) slag-processing-dissolution: серная кислота 15 → 25.
-- Прямой data.raw вместо paralib.set_ingredient — последний внутри boblibrary
-- использует item.result() для fluid, что портит структуру и рецепт перестаёт
-- помещаться в Liquefier. Имя кислоты после Angels data-updates —
-- angels-liquid-sulfuric-acid (vanilla-имя матчим тоже для безопасности).
do
	local r = data.raw.recipe["angels-slag-processing-dissolution"]
	if r and r.ingredients then
		for _, ing in ipairs(r.ingredients) do
			if ing.name == "angels-liquid-sulfuric-acid" or ing.name == "sulfuric-acid" then
				ing.amount = 25
			end
		end
	end
end

-- 2) Slag как побочный продукт ore-processing рецептов (probability 0.1-0.6).
-- В 1.1 это был основной источник slag, в 2.0 потеряно. Probability — из Oberhaul.
-- Платина выпадает из шаблона angels-processed-<metal>: её рецепт назван
-- angels-platinum-ore-processing, а angels-processed-platinum — это item.
local slag_byproducts = {
	{ metal = "iron",      probability = 0.6 },
	{ metal = "copper",    probability = 0.6 },
	{ metal = "lead",      probability = 0.5 },
	{ metal = "tin",       probability = 0.5 },
	{ metal = "aluminium", probability = 0.3 },
	{ metal = "chrome",    probability = 0.3 },
	{ metal = "manganese", probability = 0.3 },
	{ metal = "nickel",    probability = 0.3 },
	{ metal = "silica",    probability = 0.3 },
	{ metal = "zinc",      probability = 0.3 },
	{ metal = "gold",      probability = 0.2 },
	{ metal = "silver",    probability = 0.2 },
	{ metal = "titanium",  probability = 0.2 },
	{ metal = "platinum",  probability = 0.1, recipe = "angels-platinum-ore-processing" },
	{ metal = "tungsten",  probability = 0.1 },
}

for _, b in ipairs(slag_byproducts) do
	local recipe_name = b.recipe or ("angels-processed-" .. b.metal)
	local main_item = "angels-processed-" .. b.metal
	if data.raw.recipe[recipe_name] then
		paralib.bobmods.lib.recipe.add_result(recipe_name, {
			type = "item",
			name = "angels-slag",
			amount = 1,
			probability = b.probability,
		})
		data.raw.recipe[recipe_name].main_product = main_item
	end
end
