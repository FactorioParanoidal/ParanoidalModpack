-- Фиксы регрессий Bio_Industries_2 для 2.0: мод сохранил старые 1.1-имена
-- items (stone-crushed, solid-sand), а Angels Refining в 2.0 переименовал их
-- в angels-stone-crushed / angels-solid-sand. Без этих патчей рецепты bi-*
-- сломаны (несуществующие ingredient/result).

local function rename_item_in_list(list, old_name, new_name)
	if not list then return end
	for _, item in pairs(list) do
		if item.name == old_name then item.name = new_name end
	end
end

local function patch_bi_recipe(name, renames)
	local r = data.raw.recipe[name]
	if not r then return end
	for old, new in pairs(renames) do
		rename_item_in_list(r.ingredients, old, new)
		rename_item_in_list(r.results, old, new)
	end
end

-- bi-sand: 2 stone-crushed → 5 solid-sand (через bi-stone-crusher)
patch_bi_recipe("bi-sand", {
	["stone-crushed"] = "angels-stone-crushed",
	["solid-sand"] = "angels-solid-sand",
})

-- Подменяем item-icon angels-solid-sand с "миски" (angelsrefininggraphics/
-- solid-sand.png) на нормальную кучку песка из aai-industry. Это автоматически
-- наследуется во все рецепты, где явный icon не задан (включая bi-sand и сам
-- angels-solid-sand рецепт washing-plant).
do
	local sand_item = data.raw.item["angels-solid-sand"]
	if sand_item then
		sand_item.icon = "__aai-industry__/graphics/icons/sand.png"
		sand_item.icon_size = 64
		sand_item.icons = nil
	end
end

-- Рецепты с явно прописанной "миской" (angelsrefininggraphics/solid-sand.png) —
-- bi-sand (нужен явный icon из-за main_product = "") и sand-sluicing
-- (Clowns-Processing) — переводим на ту же AAI кучку песка.
local sand_icon = "__aai-industry__/graphics/icons/sand.png"
for _, recipe_name in ipairs({ "bi-sand", "sand-sluicing" }) do
	local r = data.raw.recipe[recipe_name]
	if r then
		r.icons = nil
		r.icon = sand_icon
		r.icon_size = 64
	end
end
