local ICON = "__carbon-capture2__/graphics/technology/"

local function unlocks(...)
	local effects = {}
	for i, recipe in ipairs({ ... }) do effects[i] = { type = "unlock-recipe", recipe = recipe } end
	return effects
end

local function packs(red, green, blue, purple, yellow, white)
	local list = {}
	for i, pack in ipairs({
		{ "automation-science-pack", red }, { "logistic-science-pack", green },
		{ "chemical-science-pack", blue }, { "production-science-pack", purple },
		{ "utility-science-pack", yellow }, { "space-science-pack", white },
	}) do
		if pack[2] then list[i] = pack end
	end
	return list
end

-- name, prerequisites, unlocked recipes, count, packs, time; order sorts the tiers in their line.
local techs = {
	{ "CW-air-filtering-1", { "steel-processing", "electronics", "automation" },
		unlocks("CW-air-filter-machine-1", "CW-empty-air-filter", "CW-air-filter"), 100, packs(1), 30 },
	{ "CW-air-filtering-2", { "CW-air-filtering-1", "automation-2" },
		unlocks("CW-air-filter-machine-2"), 250, packs(1, 1), 30 },
	{ "CW-air-filtering-3", { "CW-air-filtering-2", "automation-3" },
		unlocks("CW-air-filter-machine-3"), 500, packs(1, 1, 1), 60 },
	{ "CW-air-filtering-4", { "CW-air-filtering-3" },
		unlocks("CW-air-filter-machine-4"), 500, packs(1, 1, 1, 2), 75 },
	{ "CW-air-filtering-5", { "CW-air-filtering-4" },
		unlocks("CW-air-filter-machine-5"), 2000, packs(2, 2, 2, 2, 1), 90 },
	{ "CW-air-filtering-6", { "CW-air-filtering-5" },
		unlocks("CW-air-filter-machine-6"), 2500, packs(5, 5, 5, 3, 2, 1), 180 },
	{ "CW-air-filter-cleaning-1", { "CW-air-filtering-1" },
		unlocks("CW-air-filter-cleaning-1"), 400, packs(1), 30 },
	{ "CW-air-filter-cleaning-2", { "CW-air-filter-cleaning-1" },
		unlocks("CW-air-filter-cleaning-2"), 500, packs(1, 1), 60 },
	{ "CW-air-filter-cleaning-3", { "CW-air-filter-cleaning-2" },
		unlocks("CW-air-filter-cleaning-3"), 500, packs(2, 2, 1), 90 },
	{ "CW-air-filter-cleaning-4", { "CW-air-filter-cleaning-3" },
		unlocks("CW-air-filter-cleaning-4"), 750, packs(2, 2, 1, 1), 90 },
}

local list = {}
for _, t in ipairs(techs) do
	local name = t[1]
	local line, tier = name:match("^CW%-(.-)%-(%d+)$")
	list[#list + 1] = {
		type = "technology",
		name = name,
		icon = ICON .. line .. "-" .. tier .. ".png",
		icon_size = 64,
		prerequisites = t[2],
		effects = t[3],
		unit = { count = t[4], ingredients = t[5], time = t[6] },
		order = "d-a-" .. (line == "air-filtering" and "a" or "b") .. "-" .. tier,
	}
end

data:extend(list)
