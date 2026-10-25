-- Paranoidal fork: delete removed Yuoki/Engines content at the end of data.lua, before data-updates of other mods
-- (barrels, lighted poles, drill variants etc. are then never generated for it).
local names = require("prototypes.paranoidal.removed-names")
local removed = {}
for _, name in pairs(names) do
	removed[name] = true
end

-- Yuoki slag is the Angels slag in Paranoidal (as Yuoki 1.2.21 does in data-final-fixes); replace it before the
-- result rule below would delete every recipe that still yields y-slag.
local function replace_in(list, old, new)
	for _, entry in pairs(list or {}) do
		if entry.name == old then
			entry.name = new
		end
	end
end
if mods["angelsrefining"] then
	for _, recipe in pairs(data.raw.recipe) do
		replace_in(recipe.ingredients, "y-slag", "angels-slag")
		replace_in(recipe.results, "y-slag", "angels-slag")
	end
end

local keep_types = {
	["recipe-category"] = true,
	["item-subgroup"] = true,
	["item-group"] = true,
	["fuel-category"] = true,
	["ammo-category"] = true,
	["damage-type"] = true,
}
local count = 0
for type_name, prototypes in pairs(data.raw) do
	if not keep_types[type_name] then
		for name in pairs(removed) do
			if prototypes[name] then
				prototypes[name] = nil
				count = count + 1
			end
		end
	end
end

-- Recipes that still yield a removed item or fluid have no purpose left.
local orphan_recipes = {}
for name, recipe in pairs(data.raw.recipe) do
	for _, result in pairs(recipe.results or {}) do
		if removed[result.name] then
			orphan_recipes[#orphan_recipes + 1] = name
			break
		end
	end
end
for _, name in pairs(orphan_recipes) do
	data.raw.recipe[name] = nil
end
table.sort(orphan_recipes)
log("Yuoki (Paranoidal): removed " .. count .. " prototypes and " .. #orphan_recipes .. " recipes yielding them: "
	.. table.concat(orphan_recipes, ", "))
