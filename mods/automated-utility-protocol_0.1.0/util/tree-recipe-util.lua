TreeRecipeUtil = {}
local function checkTechnologyCandidate(technology_candidate)
	if not technology_candidate then
		error("technology not specifed")
	end
	if type(technology_candidate) ~= "table" then
		error("technology must be a table but got " .. type(technology_candidate))
	end
	return technology_candidate
end
TreeRecipeUtil.addPrerequisitesToTechnologyWithoutMode = function(technology_candidate, prerequisites)
	if not prerequisites then
		error("prerequisites not specified")
	end
	local technology = checkTechnologyCandidate(technology_candidate)
	if technology.prerequisites then
		_table.insert_all_if_not_exists(technology.prerequisites, prerequisites)
	else
		technology.prerequisites = prerequisites
	end
end

TreeRecipeUtil.removePrerequisitesFromTechnologyWithoutMode = function(technology_candidate, prerequisites)
	if not prerequisites then
		error("prerequisites not specified")
	end
	local technology = checkTechnologyCandidate(technology_candidate)
	if not technology.prerequisites then
		error("try to remove from not exists prerequisistes")
	end
	_table.each(prerequisites, function(prerequisite)
		_table.remove_item(technology.prerequisites, prerequisite)
	end)
end

TreeRecipeUtil.resetTechnologyPrerequisitesWithoutMode = function(technology_candidate, prerequisites)
	if not prerequisites then
		error("prerequisites not specified")
	end
	local technology = checkTechnologyCandidate(technology_candidate)
	if technology.prerequisites then
		technology.prerequisites = nil
	end
	TreeRecipeUtil.addPrerequisitesToTechnologyWithoutMode(technology_candidate, prerequisites)
end
TreeRecipeUtil.addRecipeEffectToTechnologyEffectsWithoutMode = function(technology_candidate, recipe_name)
	local technology = checkTechnologyCandidate(technology_candidate)
	if not recipe_name then
		error("recipe_name not specified!")
	end
	if not technology.effects then
		technology.effects = {}
	end
	table.insert(technology.effects, { type = "unlock-recipe", recipe = recipe_name })
	local recipe = data.raw.recipe[recipe_name]
	if not recipe then
		error("recipe with name " .. recipe_name .. " not found!")
	end
	recipe.enabled = false
end
TreeRecipeUtil.removeRecipeEffectFromTechnologyEffectsWithoutMode = function(technology_candidate, recipe_name)
	local technology = checkTechnologyCandidate(technology_candidate)
	if not recipe_name then
		error("recipe_name not specified!")
	end
	if not technology.effects then
		error("technology effects not specified!")
	end
	_table.remove_item(technology.effects, { type = "unlock-recipe", recipe = recipe_name })
end
TreeRecipeUtil.moveRecipeEffectsToTechnologyWithoutMode = function(from_name, to_name, recipe_name)
	local technologies = data.raw["technology"]
	TreeRecipeUtil.removeRecipeEffectFromTechnologyEffectsWithoutMode(technologies[from_name], recipe_name)
	TreeRecipeUtil.addRecipeEffectToTechnologyEffectsWithoutMode(technologies[to_name], recipe_name)
end

TreeRecipeUtil.hideTechnologyWithoutMode = function(technology_candidate)
	local technology = checkTechnologyCandidate(technology_candidate)
	technology.hidden = true
end

TreeRecipeUtil.showTechnologyWithoutMode = function(technology_candidate)
	local technology = checkTechnologyCandidate(technology_candidate)
	technology.hidden = false
end
