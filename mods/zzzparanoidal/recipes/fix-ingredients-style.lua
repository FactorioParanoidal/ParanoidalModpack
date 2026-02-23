local Assert = require("__zzzcompability__/utils/assert")
local KaoExtended = require("__KaoExtended__/library/recipe")

for rName, recipe in pairs(data.raw.recipe) do
	if not recipe.ingredients then goto continue end
	for index, ingredient in ipairs(recipe.ingredients) do
		if #ingredient == 2 and type(ingredient[0]) == "string" and type(ingredient[1]) == "number" then
			local type = KaoExtended.item.get_basic_type(ingredient[0])
			local name = ingredient[0]
			local amount = ingredient[1]
			recipe.ingredients[index] = {
				type = type,
				name = name,
				amount = amount
			}
		end
	end
	::continue::
end
