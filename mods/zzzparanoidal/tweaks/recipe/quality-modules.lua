-- Ветка качества (решение пользователя): модули качества дешевле и раньше.
-- Модуль 1 — сразу после логистической науки, рецепт из ранней электроники.
-- Модуль 2 — сразу после химической науки, рецепт из модулей 1 и схем.
-- Модули 3–5 получают прежний рецепт предыдущего тира (2 модуля предыдущего тира + его схемы);
-- схемы модулей качества открываются вместе с модулем, где используются.
if not mods["quality"] then return end

local recipes, technologies = data.raw.recipe, data.raw.technology

local function item(name, amount) return { type = "item", name = name, amount = amount } end

if recipes["quality-module"] then
	recipes["quality-module"].ingredients = {
		item("electronic-circuit", 10), item("bob-basic-circuit-board", 5),
		item("bob-tinned-copper-cable", 10), item("bob-bronze-alloy", 5),
	}
end
if technologies["quality-module"] then
	-- «Контроль качества 10» добавляет ic-more-qualities позже.
	technologies["quality-module"].prerequisites = { "logistic-science-pack" }
end
if technologies["quality-module-2"] then
	technologies["quality-module-2"].prerequisites = { "quality-module", "chemical-science-pack" }
end

-- Сдвиг рецептов на тир вверх: снимок до изменений, предыдущий модуль заменяется на свой тир.
local tiers = { "quality-module", "quality-module-2", "quality-module-3", "bob-quality-module-4", "bob-quality-module-5" }
-- zzz прячет модули вне набора Beta 8, а ic-more-qualities открывает этот ряд позже, в своём
-- data-final-fixes. Открываем его здесь при том же условии, чтобы пересборка переработки
-- (quality-recycling-refresh) видела модули видимыми и разбирала их и их потребителей.
-- Качество включено, если есть ic-more-qualities и его галочка «Paranoidal: качество» не снята
-- (с браком и без брака одинаково). Иначе — игра без качества, см. конец файла.
local quality_setting = settings.startup["ic-more-qualities-quality"]
local quality_on = mods["ic-more-qualities"] ~= nil and (quality_setting == nil or quality_setting.value ~= false)
if quality_on then
	for _, name in ipairs(tiers) do
		if data.raw.module[name] then data.raw.module[name].hidden = false end
		if recipes[name] then recipes[name].hidden = false end
	end
end
-- Явный номер первого модуля после «Контроля качества 10»; единое название для всех тиров.
for level, name in ipairs(tiers) do
	local technology = technologies[name]
	if technology then
		technology.localised_name = { "", { "technology-name.quality-module" }, " " .. level }
	end
end
local old = {}
for index = 2, 4 do
	local recipe = recipes[tiers[index]]
	old[index] = recipe and table.deepcopy(recipe.ingredients)
end
for index = 3, 5 do
	local recipe, source = recipes[tiers[index]], old[index - 1]
	if recipe and source then
		for _, ingredient in pairs(source) do
			if (ingredient.name or ingredient[1]) == tiers[index - 2] then
				ingredient.name, ingredient[1] = tiers[index - 1], nil
			end
		end
		for _, ingredient in pairs(source) do
			if ingredient.name == tiers[index - 1] then ingredient.amount = 2 end
		end
		recipe.ingredients = source
	end
end
if recipes["quality-module-2"] then
	recipes["quality-module-2"].ingredients = {
		item("quality-module", 2), item("advanced-circuit", 5), item("electronic-circuit", 10),
	}
end

-- Схемы: открываются на тир позже (там, где теперь используются).
local processor_unlock = {
	["bob-quality-processor"] = "quality-module-3",
	["bob-quality-processor-2"] = "bob-quality-module-4",
	["bob-quality-processor-3"] = "bob-quality-module-5",
}
for recipe_name, target in pairs(processor_unlock) do
	if recipes[recipe_name] and technologies[target] then
		for _, technology in pairs(technologies) do
			for index = #(technology.effects or {}), 1, -1 do
				local effect = technology.effects[index]
				if effect.type == "unlock-recipe" and effect.recipe == recipe_name then
					table.remove(technology.effects, index)
				end
			end
		end
		technologies[target].effects = technologies[target].effects or {}
		table.insert(technologies[target].effects, 1, { type = "unlock-recipe", recipe = recipe_name })
	end
end

-- Схемы во вкладке «Модули» — одним рядом (Bob раскладывает их по трём подгруппам-строкам).
for _, name in ipairs({ "bob-quality-processor", "bob-quality-processor-2", "bob-quality-processor-3" }) do
	if data.raw.item[name] and data.raw["item-subgroup"]["bob-module-intermediates-2"] then
		data.raw.item[name].subgroup = "bob-module-intermediates-2"
	end
end

-- Гармонические кристаллы в схемах: 1 — без кристалла, 2 — малый, 3 — средний.
local crystal = {
	["bob-quality-processor"] = false,
	["bob-quality-processor-2"] = "angels-crystal-splinter-harmonic",
	["bob-quality-processor-3"] = "angels-crystal-shard-harmonic",
}
for recipe_name, replacement in pairs(crystal) do
	local recipe = recipes[recipe_name]
	if recipe and (replacement == false or data.raw.item[replacement]) then
		for index = #(recipe.ingredients or {}), 1, -1 do
			local name = recipe.ingredients[index].name or recipe.ingredients[index][1]
			if name and name:find("^angels%-crystal%-.+%-harmonic$") then
				if replacement then
					recipe.ingredients[index] = item(replacement, recipe.ingredients[index].amount or recipe.ingredients[index][2])
				else
					table.remove(recipe.ingredients, index)
				end
			end
		end
	end
end

-- Игра без качества (галочка «Paranoidal: качество» снята или ic-more-qualities отключён):
-- модули качества, их схемы и исследования качества скрыты; рецепты Bob, где был модуль
-- качества (плазменная турель 4, оборудование BET), обходятся без него, как Bob без модулей
-- качества; зависимые исследования получают предков скрытого исследования.
if not quality_on then
	local items = { ["bob-quality-processor"] = true, ["bob-quality-processor-2"] = true, ["bob-quality-processor-3"] = true }
	for _, name in ipairs(tiers) do items[name] = true end
	for name, recipe in pairs(recipes) do
		if not items[name] then
			for index = #(recipe.ingredients or {}), 1, -1 do
				local ingredient = recipe.ingredients[index]
				if items[ingredient.name or ingredient[1]] then table.remove(recipe.ingredients, index) end
			end
		end
	end
	for name in pairs(items) do
		local prototype = data.raw.module[name] or data.raw.item[name]
		if prototype then prototype.hidden = true end
		if recipes[name] then recipes[name].hidden = true; recipes[name].enabled = false end
	end
	local hidden = {}
	for _, name in ipairs({ "quality-module", "quality-module-2", "quality-module-3", "bob-quality-module-4",
		"bob-quality-module-5", "epic-quality", "legendary-quality" }) do
		local technology = technologies[name]
		if technology then
			hidden[name] = true
			technology.hidden = true
			technology.enabled = false
			technology.hidden_in_factoriopedia = true
		end
	end
	for name, technology in pairs(technologies) do
		if not hidden[name] and technology.prerequisites then
			local prerequisites, seen, changed = {}, {}, false
			local function add(prerequisite)
				if seen[prerequisite] then return end
				seen[prerequisite] = true
				if hidden[prerequisite] then
					changed = true
					for _, parent in ipairs(technologies[prerequisite].prerequisites or {}) do add(parent) end
				else
					prerequisites[#prerequisites + 1] = prerequisite
				end
			end
			for _, prerequisite in ipairs(technology.prerequisites) do add(prerequisite) end
			if changed then technology.prerequisites = prerequisites end
		end
	end
end
