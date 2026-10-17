-- Beta 8 normal: связи продвинутой электроники и следующей науки.
-- Соответствие по открываемым цепочкам, не по одному ID/JSON-миграции.
-- Ранние electronics/bob-electronics, рецепты и эффекты 2.0 здесь не меняются.
local prerequisites = {
	["advanced-circuit"] = {
		"plastics", "bob-silicon-processing", "angels-chlorine-processing-1",
		"angels-silver-smelting-1", "angels-resins", "angels-aluminium-smelting-1",
		"angels-sulfur-processing-2",
	},
	["processing-unit"] = { "angels-gold-smelting-1", "angels-glass-smelting-2", "angels-rubbers" },
	["chemical-science-pack"] = {
		"advanced-circuit", "angels-sulfur-processing-1", "bob-alloy-processing", "engine",
	},
	["utility-science-pack"] = {
		"processing-unit", "low-density-structure", "electric-engine", "bob-battery-2",
		"bob-ceramics", "nuclear-power", "logistics-3",
		"automation-3", "angels-tungsten-smelting-1",
	},
	-- Латунные предметы старой zinc-processing теперь открывает brass-processing.
	["bob-brass-processing"] = { "angels-brass-smelting-1" },
	["bob-advanced-logistic-science-pack"] = { "robotics", "bob-brass-processing", "bob-express-inserter" },
}
for name, list in pairs(prerequisites) do
	local technology = data.raw.technology[name]
	if technology and technology.max_level ~= "infinite" then
		technology.prerequisites = list
	end
end

-- После OV.execute: вместо триггера изготовления латуни — исследование Beta 8.
local brass = data.raw.technology["bob-brass-processing"]
if brass and brass.max_level ~= "infinite" then
	brass.research_trigger = nil
	brass.unit = {
		count = 40, time = 30,
		ingredients = { { "automation-science-pack", 1 }, { "logistic-science-pack", 1 } },
	}
end
