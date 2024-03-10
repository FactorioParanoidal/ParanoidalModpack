TreeRecipeUtil = {}
local function check_technology_candidate(technology_candidate)
	if not technology_candidate then
		error("technology not specifed")
	end
	if type(technology_candidate) ~= "table" then
		error("technology must be a table but got " .. type(technology_candidate))
	end
	return technology_candidate
end
TreeRecipeUtil.add_prerequisites_to_technology_without_mode = function(technology_candidate, prerequisites)
	if not prerequisites then
		error("prerequisites not specified")
	end
	local technology = check_technology_candidate(technology_candidate)
	if technology.prerequisites then
		_table.insert_all_if_not_exists(technology.prerequisites, prerequisites)
	else
		technology.prerequisites = prerequisites
	end
end

TreeRecipeUtil.remove_prerequisites_from_technology_without_mode = function(technology_candidate, prerequisites)
	if not prerequisites then
		error("prerequisites not specified")
	end
	local technology = check_technology_candidate(technology_candidate)
	if not technology.prerequisites then
		error("try to remove from not exists prerequisistes")
	end
	_table.each(prerequisites, function(prerequisite)
		_table.remove_item(technology.prerequisites, prerequisite)
	end)
end

TreeRecipeUtil.reset_prerequisites_for_technology_without_mode = function(technology_candidate, prerequisites)
	if not prerequisites then
		error("prerequisites not specified")
	end
	local technology = check_technology_candidate(technology_candidate)
	if technology.prerequisites then
		technology.prerequisites = nil
	end
	TreeRecipeUtil.add_prerequisites_to_technology_without_mode(technology_candidate, prerequisites)
end
TreeRecipeUtil.add_recipe_effect_to_technology_without_mode = function(technology_candidate, recipe_name)
	local technology = check_technology_candidate(technology_candidate)
	if not recipe_name then
		error("recipe_name not specified!")
	end
	local recipe = data.raw.recipe[recipe_name]
	if not recipe then
		error("recipe with name " .. recipe_name .. " not found!")
	end
	recipe.enabled = false
	if not technology.effects then
		technology.effects = {}
	end
	table.insert(technology.effects, { type = "unlock-recipe", recipe = recipe_name })
end
TreeRecipeUtil.remove_recipe_effect_from_technology_without_mode = function(technology_candidate, recipe_name)
	local technology = check_technology_candidate(technology_candidate)
	if not recipe_name then
		error("recipe_name not specified!")
	end
	if not technology.effects then
		error("technology effects not specified!")
	end
	_table.remove_item(technology.effects, { type = "unlock-recipe", recipe = recipe_name })
end
TreeRecipeUtil.move_recipe_effects_to_another_technology_without_mode = function(from_name, to_name, recipe_name)
	local technologies = data.raw["technology"]
	TreeRecipeUtil.remove_recipe_effect_from_technology_without_mode(technologies[from_name], recipe_name)
	TreeRecipeUtil.add_recipe_effect_to_technology_without_mode(technologies[to_name], recipe_name)
end

TreeRecipeUtil.hide_technology_without_mode = function(technology_candidate)
	local technology = check_technology_candidate(technology_candidate)
	technology.hidden = true
end

TreeRecipeUtil.show_technology_without_mode = function(technology_candidate)
	local technology = check_technology_candidate(technology_candidate)
	technology.hidden = false
end

TreeRecipeUtil.show_recipe_without_mode = function(recipe_candidate)
	if not recipe_candidate or type(recipe_candidate) ~= "table" then
		error("wrong recipe prototype!")
	end
	recipe_candidate.hidden = false
end

TreeRecipeUtil.hide_recipe_without_mode = function(recipe_candidate)
	if not recipe_candidate or type(recipe_candidate) ~= "table" then
		error("wrong recipe prototype!")
	end
	recipe_candidate.hidden = true
end

local function add_science_pack_to_technology_units_without_mode(technology_candidate, ingredient_value)
	if not ingredient_value then
		error("ingredient_value not specified")
	end
	local technology = check_technology_candidate(technology_candidate)
	if technology.unit and technology.unit.ingredients then
		_table.insert_all_if_not_exists_with_compare(
			technology.unit.ingredients,
			{ ingredient_value },
			function(__table, inserting_item)
				local ingredient_names = _table.map(__table, function(item)
					return item[1]
				end)
				local inserting_ingrediend_name = inserting_item[1]
				local result = not _table.contains(ingredient_names, inserting_ingrediend_name)
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
TreeRecipeUtil.add_science_packs_to_technology_units_without_mode = function(technology_candidate, technology_units)
	if not technology_units then
		error("technology_units not specified")
	end
	_table.each(technology_units, function(technology_unit)
		add_science_pack_to_technology_units_without_mode(technology_candidate, technology_unit)
	end)
end
TreeRecipeUtil.remove_science_pack_from_technology_units_without_mode = function(
	technology_candidate,
	science_pack_name
)
	if not science_pack_name then
		error("science_pack_name not specified")
	end
	local technology = check_technology_candidate(technology_candidate)
	_table.remove_item(technology.unit.ingredients, science_pack_name, function(table_item, item_for_remove)
		return table_item[1] == item_for_remove
	end)
end
