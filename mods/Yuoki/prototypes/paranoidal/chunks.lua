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

-- chunks can be handed in for UC-A2 (one way: UC-A2 no longer turns back into chunks)
for _, name in pairs({ "y-res1", "y-res2" }) do
	yi.lib.recipe.atomics.recipes_make_item(name, 64, 20, 1, "ore")
	data.raw.recipe["y-ac-uc2" .. name] = nil
end
