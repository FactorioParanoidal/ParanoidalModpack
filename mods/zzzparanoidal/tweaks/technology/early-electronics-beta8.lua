-- Beta 8 normal: ранняя электроника, стартовые исследования и зелёная наука.
-- После OV.execute и energy-balance. Категории рецептов/характеристики машин не меняются.
local prerequisites = {
	["burner-mechanics"] = {}, -- роль прежней basic-automation
	["basic-logistics"] = {},
	["electricity"] = { "burner-mechanics" },
	["electronics"] = { "angels-coal-processing", "angels-solder-smelting-1" },
	["logistics-0"] = {},
	["logistics"] = { "basic-logistics", "logistics-0", "electricity", "electronics" },
	["logistic-science-pack"] = { "electronics", "angels-bronze-smelting-1", "logistics" },
	["electric-lab"] = { "lamp", "electronics" },
	["bob-electronics-machine-1"] = { "automation", "steel-processing" },
	["automation-2"] = { "automation", "steel-processing", "logistic-science-pack" },
	["bob-repair-pack-2"] = { "steel-processing", "electronics" },
	["angels-basic-chemistry"] = { "automation", "basic-fluid-handling" },
	["angels-ore-crushing"] = { "angels-basic-chemistry", "electricity" },
	["angels-metallurgy-1"] = { "angels-ore-crushing" },
	-- Зависимые узлы сверены с Beta 8, а не глобально переименованы с bob-electronics.
	["fast-inserter"] = { "logistics-2" },
	["electronics-machine-4"] = { "bob-electronics-machine-3", "space-science-pack" },
	["electronics-machine-5"] = { "electronics-machine-4", "observation-satellite" },
	["nanobots"] = { "logistics" },
}
local units = {
	["burner-mechanics"] = { count = 1, time = 15 }, -- Ускоренный старт по решению пользователя.
	["basic-logistics"] = { count = 10, time = 30 },
	["logistics-0"] = { count = 10, time = 10 },
	["logistics"] = { count = 10, time = 15 },
	["bob-electronics-machine-1"] = { count = 30, time = 15 },
	["bob-repair-pack-2"] = { count = 20, time = 30 },
	["nanobots"] = { count = 30, time = 30 },
}
for name, list in pairs(prerequisites) do
	local technology = data.raw.technology[name]
	if technology and technology.max_level ~= "infinite" then
		technology.prerequisites = list
		technology.research_trigger = nil
		if units[name] then
			technology.unit = {
				count = units[name].count, time = units[name].time,
				ingredients = { { "automation-science-pack", 1 } },
			}
		end
	end
end

local basic = data.raw.technology["basic-logistics"]
if basic then basic.enabled = true; basic.hidden = false end

-- Открытия электроники разделились между двумя узлами 2.0. Возвращаем их старое место.
-- false означает стартовый рецепт без unlock; enabled задаёт recipe-патч.
local moves = {
	{ "bob-wooden-board", "electricity" },
	{ "bob-basic-circuit-board", "electricity" },
	{ "bob-basic-electronic-components", "electronics" },
	{ "electronic-circuit-wood", "electronics" },
	{ "angels-wire-tin", "electronics" },
	{ "condensator", "electricity" },
	{ "transport-belt", "basic-logistics" },
	{ "burner-lab", false },
	{ "motor", false },
	{ "electric-motor", false },
	{ "copper-cable", false },
	{ "repair-pack", "electricity" },
	{ "bob-stone-mixing-furnace", "burner-mechanics" },
}
for _, move in ipairs(moves) do
	local recipe, target = move[1], move[2]
	if data.raw.recipe[recipe] and (not target or data.raw.technology[target]) then
		for _, technology in pairs(data.raw.technology) do
			for index = #(technology.effects or {}), 1, -1 do
				local effect = technology.effects[index]
				if effect.type == "unlock-recipe" and effect.recipe == recipe then
					table.remove(technology.effects, index)
				end
			end
		end
		if target then
			local technology = data.raw.technology[target]
			technology.effects = technology.effects or {}
			table.insert(technology.effects, { type = "unlock-recipe", recipe = recipe })
		end
	end
end

-- Все активные потребители этих трёх лишних ворот исправлены выше.
-- Скрытые legacy-узлы и одноимённый скрытый electronic-circuit остаются для совместимости.
for _, name in ipairs({ "bob-electronics", "bob-lab", "repair-pack" }) do
	local technology = data.raw.technology[name]
	if technology and technology.max_level ~= "infinite" then
		technology.enabled = false
		technology.hidden = true
	end
end
-- automation-science-pack пока оставлена: внешние зависимости ещё не сопоставлены.
