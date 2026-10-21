if not mods["Clowns-AngelBob-Nuclear"] then return end

local bomb = data.raw.recipe["thermonuclear-bomb"]
if not (bomb and bomb.ingredients) then return end

local ingredients = bomb.ingredients
local modules = mods["bobmodules"]
	and { "bob-speed-module-5", "bob-productivity-module-5", "bob-efficiency-module-5" }
	or { "speed-module-3", "productivity-module-3", "efficiency-module-3" }
local reactor = data.raw.item["fusion-reactor-equipment-2"]
	and "fusion-reactor-equipment-2" or "fission-reactor-equipment"

local function matches(index, kind, name, amount)
	local ingredient = ingredients[index]
	return ingredient and ingredient.type == kind and ingredient.name == name and ingredient.amount == amount
end

-- Clowns-Nuclear already supplies these ingredients. The 2.0.13 add-on repeats them,
-- ending with a reactor whose invalid type is "name".
for i = 4, #ingredients do
	if matches(i, "name", reactor, 1)
		and matches(i - 3, "item", modules[1], 3)
		and matches(i - 2, "item", modules[2], 3)
		and matches(i - 1, "item", modules[3], 3)
	then
		for _ = 1, 4 do table.remove(ingredients, i - 3) end
		break
	end
end
