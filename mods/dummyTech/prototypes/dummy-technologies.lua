local _table = require("__stdlib__/stdlib/utils/table")
local dummyEffects = {}

for k,recipe in pairs(data.raw["recipe"]) do
	log("recipe.enabled "..serpent.dump(recipe.enabled))
	log("recipe.hidden "..serpent.dump(recipe.hidden))
	log(recipe.name)
	if recipe.enabled and not recipe.hidden then
		log("aftercheck recipe.enabled "..serpent.dump(recipe.enabled))
		log("aftercheck recipe.hidden "..serpent.dump(recipe.hidden))
		_table.insert(dummyEffects, { type = "unlock-recipe", recipe = recipe.name})
	end
end

data:extend({
	{
		type = "technology",
		name = "the-technology-of-everything",
		effects = dummyEffects,
		unit =
		{
			count = 42069,
			time = 0,
		},
		normal = {
			effects = dummyEffects,
			unit =
			{
				count = 42069,
				time = 0,
			}
		},
		expensive = {
			effects = dummyEffects,
			unit =
			{
				count = 42069,
				time = 0,
			}
		}
	}
})
log(serpent.dump(data.raw["technology"]["the-technology-of-everything"]))
for k,technology in pairs(data.raw["technology"]) do
	if technology.name~="the-technology-of-everything" then
		if technology.normal then
			if not technology.normal.prerequisites or technology.normal.prerequisites == { } then
				technology.normal.prerequisites = {"the-technology-of-everything"}
			end
		end
		if technology.expensive then
			if not technology.expensive.prerequisites or technology.expensive.prerequisites == { } then
				technology.expensive.prerequisites = {"the-technology-of-everything"}
			end
		end
		if not technology.prerequisites or technology.prerequisites == { } then
			technology.prerequisites = {"the-technology-of-everything"}
		end
	end
end