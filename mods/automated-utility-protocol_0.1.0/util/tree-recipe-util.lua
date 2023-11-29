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

TreeRecipeUtil.showRecipe = function(recipe_candidate)
	if not recipe_candidate or type(recipe_candidate) ~= "table" then
		error("wrong recipe prototype!")
	end
	recipe_candidate.hidden = false
end

TreeRecipeUtil.hideRecipe = function(recipe_candidate)
	if not recipe_candidate or type(recipe_candidate) ~= "table" then
		error("wrong recipe prototype!")
	end
	recipe_candidate.hidden = true
end

local function addSciencePackToTechnologyUnit(technology_candidate, ingredient_value)
	if not ingredient_value then
		error("ingredient_value not specified")
	end
	--[[local ingredient = {
		type = "tool",
		name = ingredient_value[1],
		amount = ingredient_value[2],
	}]]
	local technology = checkTechnologyCandidate(technology_candidate)
	if technology.unit and technology.unit.ingredients then
		--log("technology.unit.ingredients " .. Utils.dump_to_console(technology.unit.ingredients))
		_table.insert_all_if_not_exists_with_compare(
			technology.unit.ingredients,
			{ ingredient_value },
			function(__table, inserting_item)
				local ingredient_names = _table.map(__table, function(item)
					return item[1]
				end)
				--log("ingredient_names " .. Utils.dump_to_console(ingredient_names))
				local inserting_ingrediend_name = inserting_item[1]
				--log("inserting_ingredient_name " .. inserting_ingrediend_name)
				local result = not _table.contains(ingredient_names, inserting_ingrediend_name)
				--log("result " .. tostring(result))
				return result
			end
		)
		return
	end
	error(
		"unit ingredients table not found for technology "
			.. technology_candidate.name
			.. ", use moded version this technology!"
	)
end
TreeRecipeUtil.addSciencePacksToTechnologyUnits = function(technology_candidate, technology_units)
	if not technology_units then
		error("technology_units not specified")
	end
	_table.each(technology_units, function(technology_unit)
		addSciencePackToTechnologyUnit(technology_candidate, technology_unit)
	end)
end
TreeRecipeUtil.removeSciencePackFromWithoutMode = function(technology_candidate, science_pack_name)
	if not science_pack_name then
		error("science_pack_name not specified")
	end
	local technology = checkTechnologyCandidate(technology_candidate)
	_table.remove_item(technology.unit.ingredients, science_pack_name, function(table_item, item_for_remove)
		return table_item[1] == item_for_remove
	end)
end
