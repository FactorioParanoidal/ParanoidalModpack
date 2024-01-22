

local function trafos_mkingredients(f)
	local advanced = {"trafo-"..(f - 1), 2}
	local ingredients = {
		{"iron-plate", 15},
		{"steel-plate", 2},
		{"copper-cable", 100},
	}

	if f ~= 1 then table.insert(ingredients, advanced) end
	return ingredients
end


local function trafos_mkrecipe(f) return {
	type = "recipe",
	name = "trafo-"..f,
	enabled = "false",
	result = "trafo-"..f,
	ingredients = trafos_mkingredients(f),
} end


local trafos_recipes = {}
for i = 1, 5 do
	table.insert(trafos_recipes, trafos_mkrecipe(i))
end


data:extend(trafos_recipes)

