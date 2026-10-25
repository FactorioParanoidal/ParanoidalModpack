-- Paranoidal fork: N4 (y-res1, УниКомпозитный кусок) and F7 (y-res2, Энергоминерал) material chunks.
-- Declared in data-final-fixes on purpose: Angels Refining (data-updates, `if data.raw.item["y-res1"]`) would
-- otherwise add the chunks to its ore sorting, slag and chunk-mix recipes, but in Paranoidal they come only from
-- centrifuging super-pure ores (crystallization.lua). There are no map resources.
data:extend({
	{
		type = "item",
		name = "y-res1",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/uni-com-pur.png",
		subgroup = "raw-resource",
		order = "r",
		stack_size = 250,
	},
	{
		type = "item",
		name = "y-res2",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/yi-res-2-pur.png",
		subgroup = "raw-resource",
		order = "r",
		stack_size = 250,
	},
})

-- Recipes declared in data.lua with a chunk ingredient lose it before data-final-fixes (the item did not exist yet):
-- the crushers made crushed N4/F7 from water and from a tool head alone. Restore the chunks.
for recipe_name, chunk in pairs({
	["y-crush-unicomp-raw"] = { "y-res1", 3 }, ["y-crush-fuel-raw"] = { "y-res2", 3 },
	["y-crush-blue_whead"] = { "y-res1", 6 }, ["y-crush-green_whead"] = { "y-res2", 6 },
}) do
	local recipe = assert(data.raw.recipe[recipe_name], recipe_name)
	local found = false
	for _, ing in pairs(recipe.ingredients) do
		if ing.name == chunk[1] then
			found = true
		end
	end
	if not found then
		table.insert(recipe.ingredients, 1, { type = "item", name = chunk[1], amount = chunk[2] })
	end
end

-- chunks can be handed in for UC-A2 (one way: UC-A2 no longer turns back into chunks)
for _, name in pairs({ "y-res1", "y-res2" }) do
	yi.lib.recipe.atomics.recipes_make_item(name, 64, 20, 1, "ore")
	data.raw.recipe["y-ac-uc2" .. name] = nil
end
