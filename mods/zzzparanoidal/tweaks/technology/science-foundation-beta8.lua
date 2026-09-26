-- Базовые связи науки по финальному normal-дампу Beta 8.
-- После OV.execute. Эффекты 2.0 сохраняем, кроме переноса открытия спутника.
-- Цемент III–IV переносится вместе с фиолетовой наукой, иначе возникает цикл.
local prerequisites = {
	["stone-wall"] = {},
	["military-science-pack"] = { "military-2", "stone-wall", "gun-turret" },
	["production-science-pack"] = {
		"advanced-material-processing-2", "automation-2", "angels-stone-smelting-4", "electric-engine",
	},
	["angels-stone-smelting-3"] = {
		"angels-powder-metallurgy-3", "angels-stone-smelting-2", "angels-aluminium-smelting-1",
	},
	["angels-stone-smelting-4"] = { "angels-stone-smelting-3", "angels-titanium-smelting-1" },
	["space-science-pack"] = { "rocket-silo", "bob-rtg", "bob-battery-3", "bob-radar-5" },
}

if mods["qol_research"] then
	for _, category in ipairs({ "crafting-speed", "inventory-size", "mining-speed", "movement-speed", "player-reach" }) do
		prerequisites["qol-" .. category .. "-1-1"] = {}
	end
end

local function finite(name)
	local technology = data.raw.technology[name]
	if technology and technology.max_level ~= "infinite" then return technology end
end

for name, list in pairs(prerequisites) do
	local technology = finite(name)
	if technology then technology.prerequisites = list end
end

local units = {
	["stone-wall"] = { count = 10, time = 10, ingredients = { { "automation-science-pack", 1 } } },
	["angels-stone-smelting-3"] = {
		count = 50, time = 30,
		ingredients = { { "automation-science-pack", 1 }, { "logistic-science-pack", 1 }, { "chemical-science-pack", 1 } },
	},
	["angels-stone-smelting-4"] = {
		count = 200, time = 30,
		ingredients = { { "automation-science-pack", 1 }, { "logistic-science-pack", 1 }, { "chemical-science-pack", 1 } },
	},
	["space-science-pack"] = {
		count = 2000, time = 30,
		ingredients = {
			{ "automation-science-pack", 1 }, { "logistic-science-pack", 1 }, { "chemical-science-pack", 1 },
			{ "production-science-pack", 1 }, { "utility-science-pack", 1 },
		},
	},
}
for name, unit in pairs(units) do
	local technology = finite(name)
	if technology then
		technology.research_trigger = nil
		technology.unit = unit
	end
end

-- В Beta 8 исследование космической науки открывало спутник, а не наоборот.
local space = finite("space-science-pack")
local silo = finite("rocket-silo")
if space and silo and data.raw.recipe["satellite"] then
	for index = #(silo.effects or {}), 1, -1 do
		local effect = silo.effects[index]
		if effect.type == "unlock-recipe" and effect.recipe == "satellite" then table.remove(silo.effects, index) end
	end
	space.effects = space.effects or {}
	local found = false
	for _, effect in ipairs(space.effects) do
		if effect.type == "unlock-recipe" and effect.recipe == "satellite" then found = true end
	end
	if not found then table.insert(space.effects, { type = "unlock-recipe", recipe = "satellite" }) end
end
