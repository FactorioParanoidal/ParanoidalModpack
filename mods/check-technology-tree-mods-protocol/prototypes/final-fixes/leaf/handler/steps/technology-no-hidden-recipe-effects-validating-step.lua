local techUtil = require("__automated-utility-protocol__.util.technology-util")
local TechnologyNoHiddenRecipeEffectsValidatingStep = {}
TechnologyNoHiddenRecipeEffectsValidatingStep.evaluate = function(technology_name, mode)
	local recipe_names = techUtil.getAllRecipesNamesForSpecifiedTechnology(technology_name, mode)
	_table.each(recipe_names, function(recipe_name)
		local moded_recipe = Utils.getModedObject(data.raw["recipe"][recipe_name], mode)
		if not moded_recipe or moded_recipe.hidden then
			error(
				" for technology "
					.. technology_name
					.. " for mode "
					.. mode
					.. " effect recipe with name "
					.. recipe_name
					.. " is HIDDEN!"
			)
		end
	end)
end
return TechnologyNoHiddenRecipeEffectsValidatingStep
