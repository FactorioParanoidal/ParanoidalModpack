local techUtil = require("__automated-utility-protocol__.util.technology-util")
local recipeUtil = require("__automated-utility-protocol__.util.recipe-util")
local TechnologyLeafHandlerMissedIngredientsInTechnologyTreeStep = {}

TechnologyLeafHandlerMissedIngredientsInTechnologyTreeStep.excluded_item_science_pack =
	{ type = "item", name = "salvaged-automation-science-pack" }
local function filter_technology_name_candidate_by_predicate(
	technology_name_candidate,
	mode,
	effect_ingredient_not_found_in_current_tree
)
	local products =
		EvaluatingStepStatusHolder.get_effect_results_from_technology_status(mode, technology_name_candidate)
	return _table.contains_f(products, function(product)
		--[[	log('technology_name_candidate ' ..
				technology_name_candidate .. ',product.type ' .. product.type ..
				',product.name ' .. product.name)]]
		return effect_ingredient_not_found_in_current_tree.type == product.type
			and effect_ingredient_not_found_in_current_tree.name == product.name
	end)
end
local function filter_all_avaliable_technologies_with_ingredient(
	all_found_technology_names,
	mode,
	effect_ingredient_not_found_in_current_tree
)
	return _table.filter(all_found_technology_names, function(found_technology_name)
		return filter_technology_name_candidate_by_predicate(
			found_technology_name,
			mode,
			effect_ingredient_not_found_in_current_tree
		)
	end)
end
local function print_info_about_available_for_ingredients_technology_names(
	available_technology_name_for_ingredients,
	technology_name,
	mode
)
	local basic_units = EvaluatingStepStatusHolder.get_tool_units_from_technology_status(mode, technology_name)
	local units = EvaluatingStepStatusHolder.get_tool_units_from_technology_status(
		mode,
		available_technology_name_for_ingredients
	)
	local diff_units = _table.deep_copy(units)
	_table.each(basic_units, function(basic_unit)
		_table.remove_item(diff_units, basic_unit, nil, true)
	end)
	log(
		available_technology_name_for_ingredients
			.. " has missing for current technology units "
			.. Utils.dump_to_console(diff_units)
	)
	log(
		"results for "
			.. available_technology_name_for_ingredients
			.. " are "
			.. Utils.dump_to_console(
				EvaluatingStepStatusHolder.get_effect_results_from_technology_status(
					mode,
					available_technology_name_for_ingredients
				)
			)
	)
	log(
		available_technology_name_for_ingredients
			.. " is "
			.. Utils.dump_to_console(data.raw["technology"][available_technology_name_for_ingredients])
	)
	local cyclingCandidates = EvaluatingStepStatusHolder.get_occurs_technology_in_another_technology_tree(
		available_technology_name_for_ingredients,
		technology_name,
		mode
	)
	if _table.size(cyclingCandidates) > 0 then
		log(
			technology_name
				.. " contains in tree of "
				.. available_technology_name_for_ingredients
				.. " in following technologies "
				.. Utils.dump_to_console(cyclingCandidates)
		)
	end
end

local function get_another_trees_handling_error_message(
	effect_ingredient_not_found_in_current_tree,
	technology_name,
	mode,
	available_technology_names_for_ingredients,
	technology_properties_evaluating_step
)
	local all_found_technology_names = EvaluatingStepStatusHolder.get_all_technology_names_foun_for_mode(mode)
	local available_technology_names_for_missed_ingredient = filter_all_avaliable_technologies_with_ingredient(
		all_found_technology_names,
		mode,
		effect_ingredient_not_found_in_current_tree
	)
	local all_with_hidden_technology_names = techUtil.get_all_technology_names_with_hidden()
	local result = "all with hidden technology names "
		.. Utils.dump_to_console(all_with_hidden_technology_names)
		.. "\n"
	EvaluatingStepStatusHolder.init_for_mode(mode)
	TechnologyTreeCacheUtil.cleanup_technology_tree_cache(mode)
	TechnologyTreeCacheUtil.init_technology_tree_cache(mode)
	_table.each(all_with_hidden_technology_names, function(all_with_hidden_technology_name)
		technology_properties_evaluating_step.evaluate(all_with_hidden_technology_name, mode, true)
	end)
	local all_with_hidden_technology_names_for_missed_ingredient = filter_all_avaliable_technologies_with_ingredient(
		all_with_hidden_technology_names,
		mode,
		effect_ingredient_not_found_in_current_tree
	)

	local effect_ingredient_not_found_in_current_tree_name = effect_ingredient_not_found_in_current_tree.name
		or effect_ingredient_not_found_in_current_tree[1]
	result = result
		.. "with ingredient as result "
		.. effect_ingredient_not_found_in_current_tree_name
		.. " all ACTIVE technologies "
		.. Utils.dump_to_console(available_technology_names_for_missed_ingredient)
		.. "\n"
	result = result
		.. "with ingredient as result "
		.. effect_ingredient_not_found_in_current_tree_name
		.. " all WITH HIDDEN technologies "
		.. Utils.dump_to_console(all_with_hidden_technology_names_for_missed_ingredient)
		.. "\n"
	_table.each(
		available_technology_names_for_missed_ingredient,
		function(available_technology_name_for_missed_ingredient)
			print_info_about_available_for_ingredients_technology_names(
				available_technology_name_for_missed_ingredient,
				technology_name,
				mode
			)
		end
	)
	result = result
		.. 'data.raw["technology"]['
		.. technology_name
		.. "]"
		.. Utils.dump_to_console(data.raw["technology"][technology_name])
		.. "\n"
	result = result
		.. "technology tree of "
		.. technology_name
		.. " is "
		.. Utils.dump_to_console(
			TechnologyTreeUtil.find_prerequisites_for_technology_for_all_levels(technology_name, mode)
		)
		.. "\n"
	result = result
		.. "available_technology_names_for_ingredients "
		.. Utils.dump_to_console(available_technology_names_for_ingredients)
		.. "\n"
	_table.each(available_technology_names_for_ingredients, function(available_technology_name_for_ingredients)
		print_info_about_available_for_ingredients_technology_names(
			available_technology_name_for_ingredients,
			technology_name,
			mode
		)
	end)
	EvaluatingStepStatusHolder.cleanup_for_mode(mode)
	TechnologyTreeCacheUtil.cleanup_technology_tree_cache(mode)
	local recipe_names = techUtil.get_all_recipe_names_for_specified_technology(technology_name, mode)
	local available_recipe_names_for_ingredient = _table.filter(recipe_names, function(recipe_name)
		return _table.contains_f_deep(
			recipeUtil.get_all_recipe_ingredients(recipe_name, mode),
			effect_ingredient_not_found_in_current_tree
		)
	end)

	result = result
		.. "for technology "
		.. technology_name
		.. " for mode "
		.. mode
		.. " keep unresolved "
		.. Utils.dump_to_console(effect_ingredient_not_found_in_current_tree)
		.. " ingredient dependency! Contained recipe names: "
		.. Utils.dump_to_console(available_recipe_names_for_ingredient)
		.. "\n"
	return result
end

local function raise_error_unresolved_ingredient_in_technology_tree(
	technology_name,
	mode,
	unresolved_ingredient,
	technology_properties_evaluating_step
)
	log("\nhandle unresolved ingredient")
	local all_found_technology_names =
		EvaluatingStepStatusHolder.get_technology_names_with_compatiable_science_pack(mode, technology_name)
	local available_technology_names_for_ingredients =
		filter_all_avaliable_technologies_with_ingredient(all_found_technology_names, mode, unresolved_ingredient)
	local error_message = get_another_trees_handling_error_message(
		unresolved_ingredient,
		technology_name,
		mode,
		available_technology_names_for_ingredients,
		technology_properties_evaluating_step
	)
	log("\nunresolved ingredient handled")
	error(error_message)
end

local function is_unresolved_ingredient_in_technology_product_list(ingredient, products)
	return not _table.contains_f(products, function(product)
		return ingredient.type == product.type and ingredient.name == product.name
	end)
end
local function write_missed_ingredients_in_technology_tree_to_technology_status(technology_name, mode)
	local result = {}
	local recipe_ingredients =
		EvaluatingStepStatusHolder.getEffectIngredientsFromTechnologyStatus(mode, technology_name)
	local technology_unit_ingredients =
		EvaluatingStepStatusHolder.get_tool_units_from_technology_status(mode, technology_name)
	local all_need_ingredients_for_technology_research = {}
	_table.insert_all_if_not_exists(all_need_ingredients_for_technology_research, recipe_ingredients)
	_table.insert_all_if_not_exists(all_need_ingredients_for_technology_research, technology_unit_ingredients)
	local products = EvaluatingStepStatusHolder.get_effect_results_from_technology_status(mode, technology_name)
	_table.each(all_need_ingredients_for_technology_research, function(ingredient)
		if is_unresolved_ingredient_in_technology_product_list(ingredient, products) then
			table.insert(result, ingredient)
		end
	end)
	return result
end
local function try_to_resolve_ingregient_in_herself_tree_recipe_products(
	technology_name,
	mode,
	unresolved_ingredients,
	technology_properties_evaluating_step
)
	if not unresolved_ingredients or _table.size(unresolved_ingredients) == 0 then
		return
	end
	local all_technology_candidate_names =
		TechnologyTreeUtil.find_prerequisites_for_technology_for_all_levels(technology_name, mode)
	table.insert(all_technology_candidate_names, technology_name)
	local all_recipe_products_by_technologies = _table.map(
		all_technology_candidate_names,
		function(technology_candidate_name)
			return {
				technology_name = technology_candidate_name,
				products = EvaluatingStepStatusHolder.get_effect_results_from_technology_status(
					mode,
					technology_candidate_name
				),
			}
		end
	)
	_table.each(unresolved_ingredients, function(unresolved_ingredient)
		local found = false
		_table.each(all_recipe_products_by_technologies, function(all_recipe_products_by_technology)
			if found then
				return
			end
			local products = all_recipe_products_by_technology.products
			if
				_table.contains_f(products, function(product)
					return unresolved_ingredient.type == product.type and unresolved_ingredient.name == product.name
				end)
			then
				found = true
			end
		end)
		if not found then
			raise_error_unresolved_ingredient_in_technology_tree(
				technology_name,
				mode,
				unresolved_ingredient,
				technology_properties_evaluating_step
			)
		end
	end)
end
TechnologyLeafHandlerMissedIngredientsInTechnologyTreeStep.evaluate = function(
	technology_name,
	mode,
	technology_properties_evaluating_step
)
	if EvaluatingStepStatusHolder.is_visited_technology(mode, technology_name) then
		return
	end
	EvaluatingStepStatusHolder.mark_technology_as_visited(mode, technology_name)

	local unresolved_ingredients =
		write_missed_ingredients_in_technology_tree_to_technology_status(technology_name, mode)
	try_to_resolve_ingregient_in_herself_tree_recipe_products(
		technology_name,
		mode,
		unresolved_ingredients,
		technology_properties_evaluating_step
	)
	local dependencies = EvaluatingStepStatusHolder.get_tree_from_technology_status(mode, technology_name)
	_table.each(dependencies, function(dependency_name)
		TechnologyLeafHandlerMissedIngredientsInTechnologyTreeStep.evaluate(
			dependency_name,
			mode,
			technology_properties_evaluating_step
		)
	end)
end

return TechnologyLeafHandlerMissedIngredientsInTechnologyTreeStep
