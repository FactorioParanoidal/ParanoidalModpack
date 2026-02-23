local order = 65
local function createSC(name)
	data:extend({
		{
			type = "item",
			name = name .. "-structure-components",
			icon = "__KaoExtended__/graphics/" .. name .. "SC.png",
			subgroup = "structurecomponents",
			order = "a-" .. string.char(order),
			stack_size = 50,
			icon_size = 32,
		},
	})
	order = order + 1
end
data:extend({
	{
		type = "item-subgroup",
		name = "structurecomponents",
		group = "intermediate-products",
		order = "z-z",
	},
})
local function newRecipe(item, time)
	local rec = {
		type = "recipe",
		name = item .. "-structure-components",
		category = "crafting",
		enabled = false,
		energy_required = time,
		ingredients = {},
		results = { { type = "item", name = item .. "-structure-components", amount = 1 } },
	}
	data:extend({ rec })
	return rec
end
createSC("basic")
createSC("intermediate")
createSC("advanced")
createSC("anotherworld")
newRecipe("basic", 15).ingredients = {
	{ type = "item", name = "bob-lead-plate", amount = 33 },
	{ type = "item", name = "bob-glass", amount = 15 },
	{ type = "item", name = "stone-brick", amount = 22 },
}
newRecipe("intermediate", 30).ingredients = {
	{ type = "item", name = "basic-structure-components", amount = 2 },
	{ type = "item", name = "bob-brass-gear-wheel", amount = 8 },
	{ type = "item", name = "bob-bronze-alloy", amount = 10 },
	{ type = "item", name = "bob-invar-alloy", amount = 25 },
}
newRecipe("advanced", 60).ingredients = {
	{ type = "item", name = "intermediate-structure-components", amount = 2 },
	{ type = "item", name = "bob-nickel-plate", amount = 27 },
	{ type = "item", name = "bob-aluminium-plate", amount = 32 },
	{ type = "item", name = "bob-titanium-plate", amount = 52 },
	{ type = "item", name = "bob-cobalt-steel-alloy", amount = 20 },
	{ type = "item", name = "plastic-bar", amount = 40 },
}
if data.raw.item["bob-alien-science-pack"] then
	newRecipe("anotherworld", 120).ingredients = {
		{ type = "item", name = "advanced-structure-components", amount = 10 },
		{ type = "item", name = "plastic-bar", amount = 200 },
		{ type = "item", name = "bob-tungsten-carbide", amount = 200 },
		{ type = "item", name = "bob-titanium-bearing", amount = 200 },
		{ type = "item", name = "bob-ceramic-bearing", amount = 200 },
		{ type = "item", name = "bob-gold-plate", amount = 100 },
		{ type = "item", name = "bob-silver-plate", amount = 100 },
		{ type = "item", name = "bob-nitinol-gear-wheel", amount = 200 },
		{ type = "item", name = "bob-alien-science-pack", amount = 200 },
	}
else
	newRecipe("anotherworld", 120).ingredients = {
		{ type = "item", name = "advanced-structure-components", amount = 10 },
		{ type = "item", name = "plastic-bar", amount = 200 },
		{ type = "item", name = "bob-tungsten-carbide", amount = 200 },
		{ type = "item", name = "bob-titanium-bearing", amount = 200 },
		{ type = "item", name = "bob-ceramic-bearing", amount = 200 },
		{ type = "item", name = "bob-gold-plate", amount = 100 },
		{ type = "item", name = "bob-silver-plate", amount = 100 },
		{ type = "item", name = "bob-nitinol-gear-wheel", amount = 200 },
	}
end

bobmods.lib.recipe.remove_ingredient("bob-brass-alloy", "copper-plate")
bobmods.lib.recipe.remove_ingredient("bob-brass-alloy", "bob-zinc-plate")
table.insert(
	data.raw["recipe"]["bob-brass-alloy"].ingredients,
	{ type = "item", name = "bob-bronze-alloy", amount = 2 }
)
table.insert(data.raw["recipe"]["bob-brass-alloy"].ingredients, { type = "item", name = "bob-zinc-plate", amount = 8 })

bobmods.lib.recipe.remove_ingredient("bob-invar-alloy", "iron-plate")
table.insert(data.raw["recipe"]["bob-invar-alloy"].ingredients, { type = "item", name = "bob-lead-plate", amount = 3 })
