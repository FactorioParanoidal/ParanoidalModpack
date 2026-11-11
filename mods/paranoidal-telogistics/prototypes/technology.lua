local tiers = require("shared.tiers")

local ICON = "__paranoidal-telogistics__/graphics/technology/teleporter.png"

-- Packs every tier needs: home packs, space science and Muluna's interstellar pack.
local home = {
	{"automation-science-pack", 1},
	{"logistic-science-pack", 1},
	{"chemical-science-pack", 1},
	{"production-science-pack", 1},
	{"utility-science-pack", 1},
	{"space-science-pack", 1},
	{"interstellar-science-pack", 1},
}
local function packs(extra)
	local list = {}
	for _, pack in ipairs(home) do list[#list + 1] = pack end
	for _, name in ipairs(extra) do list[#list + 1] = {name, 1} end
	return list
end

-- Each tier belongs to a planet (user 2026-11-11): tier 1 — Muluna, right after its interstellar science pack;
-- tier 2 — Vulcanus, after the metallurgic science pack; tier 3 — Fulgora, after the electromagnetic science pack.
-- Prerequisites: the planet's science pack and the technologies of the recipe's ingredients; the previous tier is
-- added below (its item is an ingredient).
local research = {
	{count = 1000, extra = {}, prerequisites = {"interstellar-science-pack", "muluna-telescope",
		"muluna-nanofoamed-polymers", "muluna-aluminum-processing", "extremely-advanced-material-processing",
		"bob-electric-energy-accumulators-3"}},
	{count = 1500, extra = {"metallurgic-science-pack"}, prerequisites = {"metallurgic-science-pack",
		"tungsten-carbide", "tungsten-steel", "low-density-structure"}},
	{count = 2000, extra = {"metallurgic-science-pack", "electromagnetic-science-pack"}, prerequisites = {
		"electromagnetic-science-pack", "holmium-processing", "electromagnetic-plant"}},
}

local list = {}
for index, tier in ipairs(tiers.tiers) do
	local r = research[index]
	local prerequisites = {}
	if index > 1 then prerequisites[#prerequisites + 1] = tiers.tiers[index - 1].name end
	for _, name in ipairs(r.prerequisites) do prerequisites[#prerequisites + 1] = name end
	list[#list + 1] = {
		type = "technology",
		name = tier.name,
		localised_name = {"entity-name." .. tier.name},
		localised_description = {"technology-description.ptl-teleporter", tostring(tier.power_mw),
			tostring(tier.cycle_s), tostring(tier.slots), tostring(tier.receive_mw)},
		icons = {{icon = ICON, icon_size = 256, tint = tier.tint}},
		prerequisites = prerequisites,
		unit = {count = r.count, ingredients = packs(r.extra), time = 60},
		effects = {{type = "unlock-recipe", recipe = tier.name}},
		order = "z[ptl]-b" .. index,
	}
end

data:extend(list)
