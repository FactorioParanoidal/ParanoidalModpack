-- 1.1 source: zzzparanoidal/prototypes/micro-final-fix.lua:1726-1729.

if not mods["Teleporters"] then return end

require("__zzzparanoidal__.paralib")

if not data.raw.recipe["teleporter"] then return end

paralib.bobmods.lib.recipe.set_ingredients("teleporter", {
	{ type = "item",  name = "speed-module-3",            amount = 8   },
	{ type = "item",  name = "space-science-pack",        amount = 50  },
	{ type = "item",  name = "advanced-processing-unit",  amount = 50  },
	{ type = "item",  name = "low-density-structure",     amount = 150 },
	{ type = "item",  name = "bob-battery-3",   amount = 100 },
	{ type = "item",  name = "bob-nitinol-alloy",         amount = 150 },
})

local tech = data.raw.technology["teleporter"]
if tech then
	tech.unit.count = 2000
	tech.unit.ingredients = {
		{ "automation-science-pack",            1 },
		{ "logistic-science-pack",              1 },
		{ "military-science-pack",              1 },
		{ "chemical-science-pack",              1 },
		{ "bob-advanced-logistic-science-pack", 1 },
		{ "production-science-pack",            1 },
		{ "utility-science-pack",               1 },
		{ "space-science-pack",                 1 },
	}
	paralib.bobmods.lib.tech.add_prerequisite("teleporter", "space-science-pack")
end
