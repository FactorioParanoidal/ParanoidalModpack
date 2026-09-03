-- 1.1-количества поверх стока Bob+Angels: сколько предыдущего тира и электроники
-- требуют лента, подземная и разделитель. Материал фурнитуры и плиты остаются
-- стоковыми. Значения — дамп 1.1 (моды Oberhaul и marathon).

local amounts = {
	-- рецепт                            ингредиент                          1.1
	{ "transport-belt",                   "bob-basic-transport-belt",           2 },
	{ "fast-transport-belt",              "transport-belt",                     1 },
	{ "express-transport-belt",           "fast-transport-belt",                2 },
	{ "turbo-transport-belt",             "express-transport-belt",             2 },
	{ "bob-ultimate-transport-belt",      "turbo-transport-belt",               1 },

	{ "underground-belt",                 "bob-basic-underground-belt",         2 },
	{ "fast-underground-belt",            "underground-belt",                   4 },
	{ "express-underground-belt",         "fast-underground-belt",              3 },
	{ "turbo-underground-belt",           "express-underground-belt",           4 },
	{ "bob-ultimate-underground-belt",    "turbo-underground-belt",             2 },

	{ "splitter",                         "bob-basic-splitter",                 1 },
	{ "fast-splitter",                    "splitter",                           1 },
	{ "express-splitter",                 "fast-splitter",                      2 },
	{ "express-splitter",                 "advanced-circuit",                  10 },
	{ "turbo-splitter",                   "express-splitter",                   2 },
	{ "turbo-splitter",                   "processing-unit",                   10 },
	{ "bob-ultimate-splitter",            "turbo-splitter",                     1 },
}

for _, entry in ipairs(amounts) do
	local recipe = data.raw.recipe[entry[1]]
	if recipe and recipe.ingredients then
		for _, ingredient in pairs(recipe.ingredients) do
			-- ingredients в 2.0 встречаются в обеих формах: {name=, amount=} и {name, count}
			local name = ingredient.name or ingredient[1]
			if name == entry[2] then
				if ingredient.amount then
					ingredient.amount = entry[3]
				else
					ingredient[2] = entry[3]
				end
			end
		end
	end
end
