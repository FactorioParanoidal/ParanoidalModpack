-- Quality строит рецепты переработки в data-updates, до финальных правок рецептов сборки.
-- 1. Пересобираем выходы существующих рецептов переработки по итоговым рецептам (тем же генератором Quality).
-- 2. Предметам, появившимся после data-updates, создаём переработку так же, как Quality:
--    по итоговому рецепту, а если его разобрать нельзя — самопереработку (25% того же предмета).
if not mods["quality"] then return end

local recycling = require("__quality__.prototypes.recycling")
local recipes = data.raw.recipe

-- Не перерабатываются: предметы с сохранённым содержимым (фабрики Factorissimo).
local excluded = {
	["factory-1-instantiated"] = true, ["factory-2-instantiated"] = true, ["factory-3-instantiated"] = true,
}

local function find_item(name)
	for type_name in pairs(defines.prototypes.item) do
		local prototypes = data.raw[type_name]
		if prototypes and prototypes[name] then return prototypes[name] end
	end
end

-- Как в Quality: ровно один предметный результат.
local function single_item(recipe)
	local found
	for _, product in pairs(recipe.results or {}) do
		if product.type ~= "fluid" then
			if found then return nil end
			found = product.name or product[1]
		end
	end
	return found
end

local function same_results(a, b)
	if #a ~= #b then return false end
	for index, x in ipairs(a) do
		local y = b[index]
		if x.name ~= y.name or math.abs((x.amount or 0) - (y.amount or 0)) > 1e-9
			or math.abs((x.extra_count_fraction or 0) - (y.extra_count_fraction or 0)) > 1e-9 then
			return false
		end
	end
	return true
end

-- Снимок источников: генератор пишет в data.raw.recipe, обход по живой таблице недопустим.
local sources = {}
for name, recipe in pairs(recipes) do
	if recipe.category ~= "recycling" then sources[#sources + 1] = name end
end
table.sort(sources)

local candidates = {}
for _, name in ipairs(sources) do
	local recipe = recipes[name]
	local item = single_item(recipe)
	if item and not excluded[item] then
		local key = item .. "-recycling"
		local old = recipes[key]
		recipes[key] = nil
		local ok = pcall(recycling.generate_recycling_recipe, recipe)
		local fresh = ok and recipes[key] or nil
		recipes[key] = old
		if fresh then
			candidates[key] = candidates[key] or {}
			table.insert(candidates[key], { source = name, item = item, recipe = fresh })
		end
	end
end

-- Несколько рецептов одного предмета: основной (имя = предмет), затем не скрытый, затем по имени.
local function best_of(list)
	local best
	for _, candidate in ipairs(list) do
		local rank = (candidate.source == candidate.item and 0 or 2) + (recipes[candidate.source].hidden and 1 or 0)
		if not best or rank < best.rank then best = { rank = rank, recipe = candidate.recipe } end
	end
	return best.recipe
end

local refreshed, created, self_created = 0, 0, 0
local keys = {}
for key in pairs(candidates) do keys[#keys + 1] = key end
table.sort(keys)
for _, key in ipairs(keys) do
	local list = candidates[key]
	local old = recipes[key]
	local item = find_item(list[1].item)
	if old then
		if old.category == "recycling" then
			local current = false
			for _, candidate in ipairs(list) do
				if old.results and same_results(old.results, candidate.recipe.results) then current = true break end
			end
			if not current then
				local best = best_of(list)
				old.ingredients = best.ingredients
				old.results = best.results
				old.energy_required = best.energy_required
				old.crafting_machine_tint = best.crafting_machine_tint
				refreshed = refreshed + 1
			end
		end
	elseif item and not item.hidden and not item.parameter and item.auto_recycle ~= false then
		recipes[key] = best_of(list)
		created = created + 1
	end
end

-- Остальные видимые предметы без переработки: самопереработка, как в Quality data-updates.
for type_name in pairs(defines.prototypes.item) do
	local names = {}
	for name in pairs(data.raw[type_name] or {}) do names[#names + 1] = name end
	table.sort(names)
	for _, name in ipairs(names) do
		local item = data.raw[type_name][name]
		if not recipes[name .. "-recycling"] and not excluded[name] and not item.hidden and not item.parameter
			and item.auto_recycle ~= false and not string.find(name, "-barrel", 1, true)
			and not string.find(name, "^creative%-mod") then
			recycling.generate_self_recycling_recipe(item)
			self_created = self_created + 1
		end
	end
end
log("Paranoidal: recycling after final recipe changes: refreshed " .. refreshed .. ", created " .. created
	.. ", self-recycling " .. self_created)
