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
