-- Сборка без SpaceX (решения пользователя 2026-11-07 и 2026-11-10, победа за первую ракету): из «Расширенных ракетных грузов»
-- остаются шаттлы, капсулы и фабрикатор; космическая лаборатория, спутник наблюдения и центр обработки
-- данных остаются как источник науки для их исследований; орбитальный солнечный коллектор остаётся и
-- открывается «Проблемой потребляемой мощности орбитальных сборщиков» вместо своего исследования.
-- Обсерватории, зонды, картографический шаттл, сборка станции, AI-ядро и бесконечные бонусы скрыты;
-- прототипы остаются для ссылок стороннего кода. При SpaceX файл ничего не делает.
if mods["SpaceModFeorasFork"] or not mods["expanded-rocket-payloads-continued"] then return end

local technologies = {
	"ground-telescope", "space-telescope", "spy-shuttle", "advanced-probe", "orbital-solar-collector",
	"satellite-tracking", "space-station-assembly", "orbital-ai-core",
}
-- Бесконечные и многоуровневые бонусы: <имя>-<номер>.
local series = {
	"orbital-prospecting", "stack-inserter-research", "Space-Lab-Research", "advanced-battery-research",
	"advanced-fan-research", "robot-global-positioning-system", "space-telescope-research",
	"orbital-artillery-rangefinding",
}
local recipes = {
	"ground-telescope", "study-the-stars", "telescope-components", "space-telescope", "space-study-the-stars",
	"study-the-planet", "spy-shuttle", "refurbish-spy-shuttle", "repurpose-spy-shuttle", "advanced-probe",
	"probe-data-processing",
}
local items = {
	"ground-telescope", "telescope-components", "space-telescope", "space-telescope-uplink-station",
	"spy-shuttle", "landed-spy-shuttle", "advanced-probe", "probe-data",
}

local function hide_technology(technology)
	technology.hidden = true
	technology.enabled = false
end

for _, name in ipairs(technologies) do
	local technology = data.raw.technology[name]
	if technology then hide_technology(technology) end
end
for name, technology in pairs(data.raw.technology) do
	for _, prefix in ipairs(series) do
		if name:sub(1, #prefix + 1) == prefix .. "-" and name:sub(#prefix + 2):match("^%d+$") then
			hide_technology(technology)
		end
	end
end

for _, name in ipairs(recipes) do
	local recipe = data.raw.recipe[name]
	if recipe then
		recipe.enabled = false
		recipe.hidden = true
		recipe.hide_from_player_crafting = true
	end
end
for _, name in ipairs(items) do
	local item = data.raw.item[name]
	if item then item.hidden = true end
end

-- «Перепрофилирование шаттлов» (разборка шаттла на детали) остаётся: открывается после добычи
-- на астероидах вместо скрытого картографического шаттла и без его разборки.
local repurposing = data.raw.technology["shuttle-repurposing"]
if repurposing then
	local prerequisites = {}
	for _, prerequisite in ipairs(repurposing.prerequisites or {}) do
		if prerequisite ~= "spy-shuttle" then table.insert(prerequisites, prerequisite) end
	end
	table.insert(prerequisites, "asteroid-mining")
	repurposing.prerequisites = prerequisites
	local effects = {}
	for _, effect in ipairs(repurposing.effects or {}) do
		if not (effect.type == "unlock-recipe" and effect.recipe == "repurpose-spy-shuttle") then
			table.insert(effects, effect)
		end
	end
	repurposing.effects = effects
end

-- Орбитальный солнечный коллектор (решение пользователя 2026-11-07): его собственное исследование скрыто,
-- рецепт открывает «Проблема потребляемой мощности орбитальных сборщиков» (цепочка фабрикатора).
local power_problem = data.raw.technology["orbital-assembler-power-problem"]
if power_problem and data.raw.recipe["orbital-solar-collector"] then
	power_problem.effects = power_problem.effects or {}
	table.insert(power_problem.effects, { type = "unlock-recipe", recipe = "orbital-solar-collector" })
end
