-- Шахта баллистических ракет MIRV2 (решение пользователя 2026-11-05: цена «посередине» между рецептом MIRV 2.1.0
-- и ракетной шахтой сборки): бетон, процессоры и трубы как у ракетной шахты, её особые детали наполовину,
-- электродвигатели между 50 у автора и 100 у ракетной шахты.
-- Ракета РГЧ ИН собирается в самой шахте, её ингредиенты задаёт rcu-consumers-beta8.lua.
local recipe = data.raw.recipe["ballistic-missile-silo"]
if recipe then
	local ingredients = {}
	for _, ingredient in ipairs({
		{ "concrete", 200 },
		{ "electric-engine-unit", 75 },
		{ "processing-unit", 50 },
		{ "bob-titanium-pipe", 50 },
		{ "bob-nitinol-alloy", 250 },
		{ "bob-advanced-processing-unit", 100 },
		{ "low-density-structure", 25 },
		{ "bob-heat-shield-tile", 50 },
		{ "bob-assembling-machine-6", 50 },
	}) do
		if data.raw.item[ingredient[1]] then
			ingredients[#ingredients + 1] = { type = "item", name = ingredient[1], amount = ingredient[2] }
		else
			log("[mirv-silo] missing ingredient: " .. ingredient[1])
		end
	end
	recipe.ingredients = ingredients
end
