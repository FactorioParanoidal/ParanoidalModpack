-- Переработка Quality: полная пересборка после всех правок рецептов (аудит 2026-10-13,
-- review/recycling-audit-20261013). Quality в data-updates берёт любой рецепт с одним предметным
-- результатом, при нескольких выигрывает случайный, а переименования Bob/Angels/zzz оставляют
-- дубли со старыми ID. Отсюда шлак -> ториевая руда, щебень -> бетон, сады -> уран и т. п.
--
-- Правило: у каждого предмета ровно один рецепт «<предмет>-recycling».
--   * Разбор на ингредиенты — только из доступного игроку сборочного рецепта этого предмета.
--   * Сырьё, плавка, литьё, сплавы, химия, переработка руды, фермы, побочные продукты, скрытые
--     предметы, предметы из рецептов с продуктивностью — самопереработка Quality: 25% того же предмета.
-- Все прежние рецепты переработки удаляются; старые исключения не сохраняются.
if not mods["recycler"] then return end

local recycling = require("__recycler__.recycling")
local raw = data.raw
local recipes = raw.recipe

-- Factorio 2.1: категории рецепта — список; первая — прежняя основная категория (category в 2.0).
local function categories_of(recipe) return recipe.categories or {"crafting"} end
local function main_category(recipe) return categories_of(recipe)[1] end
local function is_recycling(recipe)
	for _, category in pairs(categories_of(recipe)) do
		if category == "recycling" then return true end
	end
	return false
end
-- Пересобираются только чистые рецепты переработки (все категории — recycling), как в 2.0 удалялись
-- только рецепты с category = "recycling". Рецепт, который можно делать и в другом месте (переработка
-- лома из zzzparanoidal-start-bnl: {"recycling", "hand-crafting"}, в 2.0 — recycling-or-hand-crafting),
-- остаётся.
local function is_pure_recycling(recipe)
	for _, category in pairs(categories_of(recipe)) do
		if category ~= "recycling" then return false end
	end
	return true
end

-- Из рецептов этих категорий предмет разбирается на ингредиенты (сборочные автоматы и руки).
local assembly = {
	["crafting"] = true, ["advanced-crafting"] = true, ["crafting-with-fluid"] = true,
	["basic-crafting"] = true, ["electronics"] = true, ["electronics-machine"] = true,
	["electronics-with-fluid"] = true, ["satellite-crafting"] = true,
	["paranoidal-structure-crafting"] = true,
	["angels-barreling-pump"] = true, -- полная бочка -> пустая бочка, как в ванили
}
-- Решение пользователя 2026-10-13: эти рецепты не сборочные, но предметы разбираются на компоненты.
local decomposed_processing = {
	["nuclear-fuel"] = true, ["angels-nuclear-fuel"] = true, ["angels-nuclear-fuel-2"] = true,
	["clowns-hypernuclear-fuel"] = true, ["clowns-turbonuclear-fuel"] = true,
	["clowns-radiothermal-fuel"] = true, ["clowns-superradiothermal-fuel"] = true,
	["clowns-ultraradiothermal-fuel"] = true,
	["atomic-bomb"] = true, ["bob-heat-shield-tile"] = true,
	["bet-fuel-1-full"] = true, ["bet-fuel-2-full"] = true, ["bet-fuel-3-full"] = true, ["bet-fuel-4-full"] = true,
}
-- Источник разбора, хотя автор мода выключил его для Quality (auto_recycle = false): основной
-- рецепт скрыт в Paranoidal, этот остался единственным (решение 2026-10-13).
local auto_recycle_override = {["electronic-circuit-wood"] = true, ["bob-phenolic-board"] = true}
-- Factorio 2.1 (решение пользователя G23 «А», 2026-11-03): ваниль 2.1 скрыла рецепт пистолета и выключила ему
-- переработку (auto_recycle = false); в сборке он доступен, и пистолет разбирается на ингредиенты, как в 2.0.
-- Остальные рецепты, которым ваниль 2.1 выключила переработку (сталь, кирпич, взрывчатка, огнемётные
-- боеприпасы, крекинг, бочки), в сборке не сборочные: их предметы и в 2.0 шли в самопереработку.
auto_recycle_override["pistol"] = true
-- Сплавы (решение 2026-10-13) и прочие материалы: всегда самопереработка, даже при сборочном рецепте.
local always_self = {
	["bob-brass-alloy"] = true, ["bob-bronze-alloy"] = true, ["bob-cobalt-steel-alloy"] = true,
	["bob-copper-tungsten-alloy"] = true, ["bob-gunmetal-alloy"] = true, ["bob-invar-alloy"] = true,
	["bob-nitinol-alloy"] = true, ["bob-solder"] = true, ["ingot-sodium-lead-alloy"] = true,
	["wood"] = true, ["coal"] = true, ["stone"] = true,
	-- Литьё дешевле ручного рецепта: разбор по ручному давал пластик x10 и древесную массу x17
	-- (аудит эксплойтов 2026-10-15, решение пользователя).
	["bob-plastic-pipe"] = true, ["bob-plastic-pipe-to-ground"] = true, ["bob-wooden-board"] = true,
}
-- Без переработки: предметы с сохранённым содержимым (фабрики Factorissimo)
-- и планировщики (решение пользователя 2026-10-17: их переработка не нужна).
local excluded = {
	["factory-1-instantiated"] = true, ["factory-2-instantiated"] = true, ["factory-3-instantiated"] = true,
	["factory-4-instantiated"] = true,
	["blueprint"] = true, ["blueprint-book"] = true, ["deconstruction-planner"] = true, ["upgrade-planner"] = true,
	-- Валюты форка Yuoki (решение пользователя 2026-10-24): знаки, репутация, УК-A2 и символы
	-- господства без качества, переработка дала бы им качество через самопереработку.
	["y_rwtechsign"] = true, ["ypfw_trader_sign"] = true, ["y_greensign"] = true, ["ye_science_blue"] = true,
	["y-fame"] = true, ["y-unicomp-a2"] = true, ["y-infused-uca2"] = true,
	["ye_science_ultimate"] = true, ["y_trade_ultimate"] = true, ["ye_green_ultimate"] = true,
}
-- Как в Quality: эти рецепты не разбираются никогда.
local quality_excluded = {["tungsten-carbide"] = true, ["superconductor"] = true, ["biolab"] = true}

local function sorted_keys(map)
	local keys = {}
	for key in pairs(map) do keys[#keys + 1] = key end
	table.sort(keys)
	return keys
end

-- Все предметы всех типов.
local items = {}
for _, type_name in ipairs(sorted_keys(defines.prototypes.item)) do
	for name, item in pairs(raw[type_name] or {}) do
		if not items[name] then items[name] = item end
	end
end

-- Сырьё: добывается из ресурсов, деревьев, рыбы и камней.
local natural = {}
local function add_minable(minable)
	if type(minable) ~= "table" then return end
	if type(minable.result) == "string" then natural[minable.result] = true end
	for _, product in pairs(minable.results or {}) do
		if type(product) == "table" and (product.type or "item") == "item" then
			natural[product.name or product[1]] = true
		end
	end
end
for _, kind in ipairs({"resource", "tree", "fish", "plant"}) do
	for _, entity in pairs(raw[kind] or {}) do add_minable(entity.minable) end
end
for _, entity in pairs(raw["simple-entity"] or {}) do
	if entity.count_as_rock_for_filtered_deconstruction then add_minable(entity.minable) end
end

-- Рецепты, которые открывает хоть одно исследование.
local unlocked = {}
for _, technology in pairs(raw.technology or {}) do
	for _, effect in pairs(technology.effects or {}) do
		if effect.type == "unlock-recipe" and effect.recipe then unlocked[effect.recipe] = true end
	end
end

-- Предметы из доступного рецепта с продуктивностью: только самопереработка (решение пользователя
-- 2026-10-18). Иначе «сборка с продуктивностью -> разбор» — петля, в которой модули качества
-- поднимают предмет почти даром.
local productive = {}
for name, recipe in pairs(recipes) do
	if recipe.allow_productivity and not recipe.hidden and (recipe.enabled ~= false or unlocked[name])
		and not is_recycling(recipe) then
		for _, product in pairs(type(recipe.results) == "table" and recipe.results or {}) do
			if type(product) == "table" and (product.type or "item") == "item" then
				productive[product.name or product[1]] = true
			end
		end
	end
end

-- Factorio 2.1 (G23 «А»): RecipePrototype::recycle_to_ingredients_of (новое в 2.1; ваниль ставит его опасному
-- и укреплённому опасному бетону) разбирает предмет на ингредиенты другого рецепта (__recycler__/recycling.lua). В 2.0
-- поля не было: предмет разбирался на ингредиенты своего рецепта. Поле убирается у всех рецептов до пересборки.
local reverse_of_dropped = 0
for _, recipe in pairs(recipes) do
	if recipe.recycle_to_ingredients_of ~= nil then
		recipe.recycle_to_ingredients_of = nil
		reverse_of_dropped = reverse_of_dropped + 1
	end
end

-- Удаляем все прежние рецепты переработки: дальше каждый строится заново.
local removed = 0
for _, name in ipairs(sorted_keys(recipes)) do
	if is_pure_recycling(recipes[name]) then
		recipes[name] = nil
		removed = removed + 1
	end
end

-- Единственный предметный результат рецепта: имя и количество, иначе nil.
local function single_item(recipe)
	local results = recipe.results
	if type(results) ~= "table" then return nil end
	local found, count
	for _, product in pairs(results) do
		if type(product) ~= "table" then return nil end
		-- Жидкий результат: предмет здесь побочный продукт (шлак при переработке руды и т. п.).
		if (product.type or "item") ~= "item" then return nil end
		if found then return nil end
		found = product.name or product[1]
		count = product.amount or product[2]
		if not count and product.amount_min and product.amount_min == product.amount_max then count = product.amount_min end
		if not count or count <= 0 then return nil end
		if product.independent_probability and product.independent_probability ~= 1 then return nil end
		if product.extra_count_fraction and product.extra_count_fraction ~= 0 then return nil end
	end
	return found, count
end

local function ingredients_ok(recipe, item_name)
	if type(recipe.ingredients) ~= "table" then return false, 0 end
	local count = 0
	for _, ingredient in pairs(recipe.ingredients) do
		if type(ingredient) ~= "table" then return false, 0 end
		local name = ingredient.name or ingredient[1]
		if (ingredient.type or "item") == "item" then
			local item = items[name]
			if name == item_name or not item or item.hidden or item.parameter then return false, 0 end
			count = count + 1
		elseif not (raw.fluid and raw.fluid[name]) then
			return false, 0
		end
	end
	return count > 0, count
end

-- Кандидаты на разбор, признак «предмет делается переработкой/плавкой/химией» и предметы,
-- которые игрок вообще может получить рецептом или добычей.
local candidates, processed, obtainable = {}, {}, {}
for name in pairs(natural) do obtainable[name] = true end
for _, name in ipairs(sorted_keys(recipes)) do
	local recipe = recipes[name]
	local category = main_category(recipe)
	if not recipe.hidden then
		for _, product in pairs(type(recipe.results) == "table" and recipe.results or {}) do
			if type(product) == "table" and (product.type or "item") == "item" then obtainable[product.name or product[1]] = true end
		end
	end
	if not recipe.hidden and category ~= "parameters" then
		local allowed = assembly[category] or decomposed_processing[name]
		if not allowed then
			for _, product in pairs(type(recipe.results) == "table" and recipe.results or {}) do
				if type(product) == "table" and (product.type or "item") == "item" then
					processed[product.name or product[1]] = true
				end
			end
		else
			local item_name = single_item(recipe)
			local main = recipe.main_product
			local ok, count = false, 0
			if item_name then ok, count = ingredients_ok(recipe, item_name) end
			if ok and (main == nil or main == "" or main == item_name)
				and (recipe.enabled ~= false or unlocked[name])
				and (recipe.auto_recycle ~= false or auto_recycle_override[name]) and recipe.subgroup ~= "empty-barrel"
				and not quality_excluded[name]
				and not (string.find(name, "science", 1, true) and string.find(name, "pack", 1, true)) then
				candidates[item_name] = candidates[item_name] or {}
				table.insert(candidates[item_name], {recipe = recipe, rank = name == item_name and 0 or 1, count = count})
			end
		end
	end
end

-- Источник разбора: основной рецепт (имя = предмет); без него — только если предмет не делается
-- переработкой, и тогда рецепт с наибольшим числом предметных ингредиентов (не распаковка рулона).
local function source_of(item_name)
	local list = candidates[item_name]
	if not list then return nil end
	table.sort(list, function(a, b)
		if a.rank ~= b.rank then return a.rank < b.rank end
		if a.count ~= b.count then return a.count > b.count end
		return a.recipe.name < b.recipe.name
	end)
	if list[1].rank == 0 then return list[1].recipe end
	if processed[item_name] then return nil end
	return list[1].recipe
end

local function any_recipe() return true end

-- Factorio 2.1 (решение пользователя G20 «А», 2026-11-03): время переработки как в 2.0. Генератор 2.1
-- (__recycler__/recycling.lua, changelog 2.1.13) делит время на число предметов результата исходного рецепта (самопереработка —
-- рецепта с именем предмета), берёт время у recycle_to_ingredients_of и не опускает его ниже 0,0011 с; 2.0
-- (__quality__/prototypes/recycling.lua) брал время самого исходного рецепта (самопереработка — рецепта с именем
-- предмета, без него 0,5 с) / 16. Результаты и выход не меняются.
local function restore_time_2_0(key, recipe)
	local result = recipes[key]
	local seconds = ((recipe and recipe.energy_required) or 0.5) / 16
	-- RecipePrototype::energy_required должно быть > 0.001: с меньшим значением не загрузился бы и 2.0, остаётся время 2.1.
	if result and seconds > 0.001 then result.energy_required = seconds end
end

local function generate_from(recipe, item_name)
	local key = item_name .. "-recycling"
	recipes[key] = nil
	local ok = pcall(recycling.generate_recycling_recipe, recipe, any_recipe)
	local result = recipes[key]
	if not ok or not result or type(result.results) ~= "table" or not next(result.results) then
		recipes[key] = nil
		return false
	end
	for _, product in pairs(result.results) do
		local item = items[product.name]
		if product.name == item_name or not item or item.hidden then
			recipes[key] = nil
			return false
		end
	end
	restore_time_2_0(key, recipe)
	return true
end

-- Название, которое находится в локали при любых ID: первый существующий ключ.
local function display_name(item)
	local names = {"?"}
	if item.localised_name then names[#names + 1] = table.deepcopy(item.localised_name) end
	names[#names + 1] = {"item-name." .. item.name}
	if type(item.place_result) == "string" and item.place_result ~= "" then
		names[#names + 1] = {"entity-name." .. item.place_result}
	end
	if type(item.place_as_equipment_result) == "string" and item.place_as_equipment_result ~= "" then
		names[#names + 1] = {"equipment-name." .. item.place_as_equipment_result}
	end
	if type(item.place_as_tile) == "table" and type(item.place_as_tile.result) == "string" then
		names[#names + 1] = {"tile-name." .. item.place_as_tile.result}
	end
	names[#names + 1] = {"entity-name." .. item.name}
	names[#names + 1] = item.name
	return names
end

local decomposed, self_made, skipped = 0, 0, 0
for _, name in ipairs(sorted_keys(items)) do
	local item = items[name]
	local key = name .. "-recycling"
	if excluded[name] or item.parameter or item.auto_recycle == false or string.find(name, "creative-mod", 1, true)
		or (item.hidden and not obtainable[name]) then
		-- Скрытые предметы, которых нет ни в одном доступном рецепте, не перерабатываются вовсе.
		skipped = skipped + 1
	else
		local source
		if not (item.hidden or natural[name] or always_self[name] or productive[name]) then source = source_of(name) end
		if source and generate_from(source, name) then
			decomposed = decomposed + 1
		elseif string.find(name, "-barrel", 1, true) then
			-- Как в Quality: бочки без рецепта наполнения не перерабатываются.
			skipped = skipped + 1
		else
			recipes[key] = nil
			recycling.generate_self_recycling_recipe(item)
			restore_time_2_0(key, recipes[name])
			self_made = self_made + 1
		end
		if recipes[key] then recipes[key].localised_name = {"recipe-name.recycling", display_name(item)} end
	end
end
-- Factorio 2.1: генератор Recycler создаёт рецепты выключенными и открывает их скрытыми эффектами
-- исследования «recycling». В 2.0 переработка была доступна с начала (на этом стоят переработчики 1–3),
-- поэтому рецепты включены, а скрытые открытия рецептов переработки (и висящие — на удалённые
-- рецепты переработки) убраны из всех исследований.
local unlocks_dropped = 0
for _, recipe in pairs(recipes) do
	if is_recycling(recipe) then recipe.enabled = true end
end
for _, technology in pairs(raw.technology or {}) do
	if technology.effects then
		local kept = {}
		for _, effect in ipairs(technology.effects) do
			local target = effect.type == "unlock-recipe" and effect.recipe
			local drop = target and ((recipes[target] and is_recycling(recipes[target]))
				or (not recipes[target] and string.sub(target, -10) == "-recycling"))
			if drop then unlocks_dropped = unlocks_dropped + 1 else kept[#kept + 1] = effect end
		end
		technology.effects = kept
	end
end
log("Paranoidal: recycling rebuilt: removed " .. removed .. ", decomposed " .. decomposed
	.. ", self-recycling " .. self_made .. ", skipped " .. skipped .. ", recycling unlocks dropped " .. unlocks_dropped
	.. ", recycle_to_ingredients_of dropped " .. reverse_of_dropped)
