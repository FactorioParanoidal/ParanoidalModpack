-- Beta 8: одна основная натриевая ступень и отдельная поздняя из Extended Angels.
-- Нынешние имена/иконки I и III сохраняются; промежуточная II больше не собирает дополнительную плату.
local base = "angels-sodium-processing-1"
local redundant = "angels-sodium-processing-2"
local late = "angels-sodium-processing-3"
if not (data.raw.technology[base] and data.raw.technology[redundant] and data.raw.technology[late]) then return end

local function set_unlocks(name, recipes)
	local technology = data.raw.technology[name]
	local effects = {}
	for _, recipe in ipairs(recipes) do
		effects[#effects + 1] = { type = "unlock-recipe", recipe = recipe }
	end
	for _, effect in ipairs(technology.effects or {}) do
		if effect.type ~= "unlock-recipe" then effects[#effects + 1] = effect end
	end
	technology.effects = effects
end
set_unlocks(base, {
	"angels-liquid-aqueous-sodium-hydroxide", "angels-liquid-aqueous-sodium-hydroxide-reverse",
	"angels-solid-sodium", "angels-solid-sodium-hydroxide", "angels-solid-sodium-carbonate",
	"angels-solid-sodium-carbonate-electrolysis", "angels-solid-sodium-cyanide",
	"angels-solid-sodium-sulfate", "angels-solid-sodium-sulfate-separation",
})
set_unlocks(late, { "angels-solid-sodium-fluoride-1", "angels-solid-sodium-fluoride-2", "Calcium-chloride-Calcium-carbonate" })
set_unlocks(redundant, {})
data.raw.technology[base].prerequisites = { "angels-chlorine-processing-3", "angels-coal-processing-3", "angels-nitrogen-processing-2" }
data.raw.technology[late].prerequisites = { base }
data.raw.technology[redundant].hidden = true
data.raw.technology[redundant].enabled = false

-- Только перенаправление натриевого предка, не перенос прочих полей металлургии/энергетики.
-- РИТЭГ — точное исключение ПР-037; остальные его предки, пять наук и цена 2.0 прежние.
local redirects = {
	["bob-rtg"] = base,
	["angels-aluminium-smelting-3"] = base,
	["angels-chrome-smelting-3"] = base,
	["angels-glass-smelting-3"] = base,
	["angels-gold-smelting-3"] = late,
	["angels-silver-smelting-3"] = late,
	["advanced-osmium-smelting"] = base,
	["phosphorus-processing-2"] = base,
}
for name, target in pairs(redirects) do
	local technology = data.raw.technology[name]
	if technology then
		for index, prerequisite in ipairs(technology.prerequisites or {}) do
			if prerequisite == redundant then technology.prerequisites[index] = target end
		end
	end
end

local nitrogen = data.raw.technology["angels-nitrogen-processing-3"]
if nitrogen then
	nitrogen.prerequisites = { "angels-nitrogen-processing-2", "angels-advanced-chemistry-3", base, "flammables" }
end
local paper = data.raw.technology["angels-bio-paper-3"]
if paper then
	paper.prerequisites = { "angels-bio-paper-2", "angels-chlorine-processing-3" }
	paper.unit = { count = 50, time = 30, ingredients = {
		{ "automation-science-pack", 1 }, { "logistic-science-pack", 1 }, { "chemical-science-pack", 1 },
	} }
end

-- Солевой электролиз был у хлора III. Бумажный override 2.0 перенёс его в натрий I.
local chlorine = data.raw.technology["angels-chlorine-processing-3"]
if chlorine and data.raw.recipe["angels-solid-salt-separation"] then
	local found = false
	for _, effect in ipairs(chlorine.effects or {}) do
		if effect.type == "unlock-recipe" and effect.recipe == "angels-solid-salt-separation" then found = true end
	end
	if not found then table.insert(chlorine.effects, 1, { type = "unlock-recipe", recipe = "angels-solid-salt-separation" }) end
end
for _, technology in pairs(data.raw.technology) do
	for index = #(technology.effects or {}), 1, -1 do
		if technology.effects[index].type == "unlock-recipe"
			and technology.effects[index].recipe == "angels-solid-sodium-hypochlorite-decomposition" then
			table.remove(technology.effects, index)
		end
	end
end
-- Платина/аммоний ПР-038 и плазменные цепи ПР-040 целиком остаются 2.0; их здесь не переписываем.
