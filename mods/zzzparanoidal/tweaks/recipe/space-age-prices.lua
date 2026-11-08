-- Ветка Space Age (ПР-078): цены планет и космоса по правилам самой сборки Paranoidal.
-- Замер 2026-11-08 (ванильная 2.1.24 против сборки без Космической эпохи, единицы ингредиентов на один продукт,
-- test-runs/sa-prices-src/factors.txt): объёмы исследований, большинство зданий и промежуточных предметов — как в
-- ванили; научные пакеты дороже примерно в 5 раз (красный 8, зелёный 4,75, синий 4,33, жёлтый 5,75), ключевые детали
-- дороже по-своему (home_ratio ниже). Отсюда:
-- * научные пакеты планет и космоса берут в PACK_FACTOR раз больше ингредиентов;
-- * рецепт Космической эпохи, который делает домашний предмет, берёт ингредиенты с коэффициентом этого предмета, а
--   рецепт со случайными продуктами даёт такие предметы во столько же раз реже (остаток — пустая выдача);
-- * исследования, здания и собственные материалы планет — как в Космической эпохе (в них уже домашние детали по ценам
--   Paranoidal).
-- Теплоноситель, который входит холодным и выходит горячим, не расходуется: его количество не меняется.
-- Без Космической эпохи ничего не делает.
local filter = data.paranoidal_space_age_filter
if not (filter and filter.space_age_recipes) then return end

local PACK_FACTOR = 5
-- Paranoidal / ваниль, единицы ингредиентов на предмет (замер 2026-11-08); меньше 1 не берётся.
local home_ratio = {
	["processing-unit"] = 6.22, ["advanced-circuit"] = 3.38, ["engine-unit"] = 3.5, ["electric-engine-unit"] = 2.44,
	["flying-robot-frame"] = 2.29, ["low-density-structure"] = 2.22, ["rocket-fuel"] = 1.82,
	["iron-plate"] = 1.75, ["copper-plate"] = 1.75, ["iron-gear-wheel"] = 1.5, ["iron-stick"] = 5,
	["copper-cable"] = 5, ["pipe"] = 4, ["pipe-to-ground"] = 1.33, ["battery"] = 1.25,
}
local loops = {["fluoroketone-cold"] = "fluoroketone-hot"}
local MAX_AMOUNT = 65535

local raw = data.raw
local lab_inputs = {}
for _, lab in pairs(raw.lab or {}) do
	for _, name in pairs(lab.inputs or {}) do lab_inputs[name] = true end
end

local function pure_recycling(recipe)
	local categories = recipe.categories or {recipe.category}
	for _, category in pairs(categories) do
		if category ~= "recycling" then return false end
	end
	return #categories > 0
end

local function result_names(recipe)
	local names = {}
	for _, result in ipairs(recipe.results or {}) do names[result.name] = result end
	return names
end

-- Ингредиенты в factor раз больше, кроме тех, что сами выходят из рецепта (катализаторы, теплоноситель).
local function scale_ingredients(recipe, factor)
	local results = result_names(recipe)
	for _, ingredient in ipairs(recipe.ingredients or {}) do
		local back = results[ingredient.name] or (loops[ingredient.name] and results[loops[ingredient.name]])
		if not back and ingredient.amount then
			ingredient.amount = math.min(MAX_AMOUNT, math.ceil(ingredient.amount * factor - 1e-9))
		end
	end
end

-- Случайные продукты: домашние предметы выпадают в home_ratio раз реже.
local function thin_products(recipe)
	local changed = false
	local shared = {}
	for _, result in ipairs(recipe.results or {}) do
		local ratio = home_ratio[result.name]
		if result.shared_probability then
			shared[#shared + 1] = result
		elseif ratio and ratio > 1 and result.independent_probability then
			result.independent_probability = result.independent_probability / ratio
			changed = true
		end
	end
	if #shared > 0 then
		table.sort(shared, function(a, b) return a.shared_probability.min < b.shared_probability.min end)
		local at = 0
		for _, result in ipairs(shared) do
			local width = result.shared_probability.max - result.shared_probability.min
			local ratio = home_ratio[result.name]
			if ratio and ratio > 1 then
				width = width / ratio
				changed = true
			end
			result.shared_probability = {min = at, max = at + width}
			at = at + width
		end
	end
	return changed
end

local packs, homes, thinned = {}, {}, {}
local names = {}
for name in pairs(filter.space_age_recipes()) do names[#names + 1] = name end
table.sort(names)
for _, name in ipairs(names) do
	local recipe = raw.recipe[name]
	if recipe and not recipe.hidden and not pure_recycling(recipe) then
		local results = recipe.results or {}
		local single = #results == 1 and results[1]
		-- A science pack is what a lab takes (in Paranoidal the packs are items, not tools); the cryogenic pack also
		-- gives back its coolant.
		local pack = false
		for _, result in ipairs(results) do
			if result.type ~= "fluid" and lab_inputs[result.name] then pack = true end
		end
		if pack then
			scale_ingredients(recipe, PACK_FACTOR)
			packs[#packs + 1] = name
		elseif single and single.type ~= "fluid" and (home_ratio[single.name] or 0) > 1 then
			scale_ingredients(recipe, home_ratio[single.name])
			homes[#homes + 1] = name .. " x" .. home_ratio[single.name]
		elseif #results > 1 and thin_products(recipe) then
			thinned[#thinned + 1] = name
		end
	end
end
log("zzzparanoidal space-age-prices: science packs x" .. PACK_FACTOR .. ": " .. table.concat(packs, ", ")
	.. "; home items: " .. table.concat(homes, ", ") .. "; home items rarer: " .. table.concat(thinned, ", "))
