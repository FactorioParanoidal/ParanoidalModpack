require("__zzzparanoidal__.paralib")
local function newRecipe(item, time)
	local rec = {
		type = "recipe",
		name = "mining-drill-bit-" .. item,
		category = "crafting",
		enabled = false,
		energy_required = time,
		ingredients = {},
		results = {{type="item", name= "mining-drill-bit-" .. item, amount = 1}}
	}
	data:extend({ rec })
	return rec
end
newRecipe("mk0", 2).ingredients = {
	{ type = "item", name = "iron-plate", amount = 8},
	{ type = "item", name = "iron-stick", amount = 3},
}
data.raw.recipe["mining-drill-bit-mk0"].enabled = true
data.raw.recipe["mining-drill-bit-mk0"].category = "crafting"

newRecipe("mk1", 5).ingredients = {
	{ type = "item", name = "mining-drill-bit-mk0", amount = 2},
	{ type = "item", name = "iron-plate", amount = 15},
}
paralib.bobmods.lib.tech.add_recipe_unlock("electric-mining-drill", "mining-drill-bit-mk1")

newRecipe("mk2", 7).ingredients = {
	{ type = "item", name = "mining-drill-bit-mk1", amount = 2},
	{ type = "item", name = "steel-plate", amount = 15},
}
paralib.bobmods.lib.tech.add_recipe_unlock("steel-processing", "mining-drill-bit-mk2")

newRecipe("mk3", 12).ingredients = {
	{ type = "item", name = "mining-drill-bit-mk2", amount = 2},
	{ type = "item", name = "bob-cobalt-steel-alloy", amount = 20},
}
paralib.bobmods.lib.tech.add_recipe_unlock("bob-drills-2", "mining-drill-bit-mk3")

newRecipe("mk4", 15).ingredients = {
	{ type = "item", name = "mining-drill-bit-mk3", amount = 2},
	{ type = "item", name = "bob-titanium-plate", amount = 20},
}
paralib.bobmods.lib.tech.add_recipe_unlock("bob-drills-3", "mining-drill-bit-mk4")

newRecipe("mk5", 15).ingredients = {
	{ type = "item", name = "mining-drill-bit-mk4", amount = 2},
	{ type = "item", name = "bob-nitinol-gear-wheel", amount = 4},
	{ type = "item", name = "bob-tungsten-carbide", amount = 20},
}
paralib.bobmods.lib.tech.add_recipe_unlock("bob-drills-4", "mining-drill-bit-mk5")

