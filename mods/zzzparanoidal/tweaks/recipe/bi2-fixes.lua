-- Bio Industries сохранил имена stone-crushed и solid-sand из Factorio 1.1,
-- которые Angels Refining 2.0 заменил на angels-stone-crushed и angels-solid-sand.

local function rename_item_in_list(list, old_name, new_name)
	if not list then return end
	for _, item in pairs(list) do
		if item.name == old_name then
			item.name = new_name
		elseif item[1] == old_name then
			item[1] = new_name
		end
	end
end

local function rename_item_in_recipe(recipe, old_name, new_name)
	if not recipe then return end
	rename_item_in_list(recipe.ingredients, old_name, new_name)
	rename_item_in_list(recipe.results, old_name, new_name)
	if recipe.normal then rename_item_in_recipe(recipe.normal, old_name, new_name) end
	if recipe.expensive then rename_item_in_recipe(recipe.expensive, old_name, new_name) end
end

-- Все рецепты сборки используют единый щебень Angels. Имена рецептов Bio
-- Industries сохраняются, поэтому настроенные машины продолжают работать.
for _, recipe in pairs(data.raw.recipe) do
	rename_item_in_recipe(recipe, "stone-crushed", "angels-stone-crushed")
end

-- Старый предмет остаётся только как скрытый прототип для совместимости.
local legacy_crushed_stone = data.raw.item["stone-crushed"]
if legacy_crushed_stone then
	legacy_crushed_stone.hidden = true
	legacy_crushed_stone.hidden_in_factoriopedia = true
end

-- bi-sand: 2 crushed stone → 5 solid sand (через bi-stone-crusher)
rename_item_in_recipe(data.raw.recipe["bi-sand"], "solid-sand", "angels-solid-sand")

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
