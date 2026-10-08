-- Quality reads recipe ingredients in data-updates, before the final-fixes remap.
-- PCPRedux is an optional dependency, so its data.lua recipes already exist here.
for _, recipe in pairs(data.raw.recipe) do
	for _, list in ipairs({ recipe.ingredients or {}, recipe.results or {} }) do
		for _, entry in pairs(list) do
			if entry.type == "fluid" and entry.name == "angels-liquid-sulfuric-acid" then
				entry.name = "sulfuric-acid"
			end
		end
	end
end
