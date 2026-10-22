-- Рецепты, которые существуют в сборке, но ничем не открываются (аудит 2026-10-20).
-- Выполняется в самом конце data-final-fixes, после всех OV.execute().
require("__zzzparanoidal__.paralib")

local function unlocked(name)
	for _, technology in pairs(data.raw.technology) do
		for _, effect in pairs(technology.effects or {}) do
			if effect.type == "unlock-recipe" and effect.recipe == name then return true end
		end
	end
	return false
end

-- Бетонный кирпич с полосами открывается вместе с бетонным кирпичом Angels.
if data.raw.recipe["hazard-concrete-brick"] and data.raw.technology["angels-stone-smelting-2"]
	and not unlocked("hazard-concrete-brick") then
	paralib.bobmods.lib.tech.add_recipe_unlock("angels-stone-smelting-2", "hazard-concrete-brick")
end

-- Без открывающей технологии рецепт только засоряет меню и Factoriopedia: скрываем.
-- spacex-combinator-stage — открывается только при SpaceX-split-combinator;
-- *-dropship-unboxing — ERPCTbaAB2 заменяет их на random-dropship-unboxing;
-- angels-gas-nitrogen-monoxide-2 — в Beta 8 намеренно не открывался (oberhaul-petrochem-port.lua).
for _, name in ipairs({
	"spacex-combinator-stage",
	"copper-dropship-unboxing",
	"iron-dropship-unboxing",
	"angels-gas-nitrogen-monoxide-2",
}) do
	local recipe = data.raw.recipe[name]
	if recipe and recipe.enabled == false and not recipe.hidden and not unlocked(name) then
		recipe.hidden = true
	end
end
