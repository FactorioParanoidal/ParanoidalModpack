local techUtil = require("__automated-utility-protocol__.util.technology-util")
local recipeUtil = require("__automated-utility-protocol__.util.recipe-util")
require("__automated-utility-protocol__.util.technology-tree-cache-util")
require("__automated-utility-protocol__.util.technology-tree-util")
local fluid_names = get_basic_fluid_names()
local empty_barrel_basic_fluid_recipe_names = _table.map(fluid_names, function(fluid_name)
	local target_fluid_name = fluid_name
	if target_fluid_name and target_fluid_name ~= "" then
		target_fluid_name = "-" .. target_fluid_name
	end
	return "empty" .. target_fluid_name .. "-barrel"
end)
local filled_barrel_basic_fluid_recipe_names = _table.map(fluid_names, function(fluid_name)
	local target_fluid_name = fluid_name
	if target_fluid_name and target_fluid_name ~= "" then
		target_fluid_name = "-" .. target_fluid_name
	end
	return "empty" .. target_fluid_name .. "-barrel"
end)
local specified_recipe_names = {
	"empty-barrel",
	"empty-canister",
	"gas-canister",
	"barreling-pump",
	"storage-tank",
	"pipe",
	"pipe-to-ground",
	"pump",
	"offshore-pump",
}

local all_fluid_in_container_unmached_recipe_names = {}
_table.insert_all_if_not_exists(all_fluid_in_container_unmached_recipe_names, specified_recipe_names)
_table.insert_all_if_not_exists(all_fluid_in_container_unmached_recipe_names, filled_barrel_basic_fluid_recipe_names)
_table.insert_all_if_not_exists(all_fluid_in_container_unmached_recipe_names, empty_barrel_basic_fluid_recipe_names)

local function filter_function(recipe_name)
	return not _table.contains(all_fluid_in_container_unmached_recipe_names, recipe_name)
		and not string.find(recipe_name, "empty", 1, true)
		and not string.find(recipe_name, "-minable", 1, true)
end
local function remove_from_basic_technology_fill_and_empty_recipe_names(
	basic_technology_name,
	recipe_name,
	empty_recipe_name,
	mode
)
	local technologies = data.raw["technology"]
	techUtil.remove_recipe_effect_from_technology(technologies[basic_technology_name], recipe_name, mode)
	techUtil.remove_recipe_effect_from_technology(technologies[basic_technology_name], empty_recipe_name, mode)
end
local function get_technology_names_for_ingredient_fuel_result_dont_contain_in_basic_technology_tree(
	all_technology_names_for_recipe_with_fuel_result,
	basic_technology_name,
	mode
)
	local result = {}
	_table.each(all_technology_names_for_recipe_with_fuel_result, function(filtered_technology_names, item_or_fluid)
		result[item_or_fluid] = {}
		_table.each(filtered_technology_names, function(filtered_technology_name)
			if
				not TechnologyTreeUtil.have_technology_in_tree(basic_technology_name, filtered_technology_name, mode)
			then
				table.insert(result[item_or_fluid], filtered_technology_name)
			end
		end)
	end)
	return result
end
local function hide_fill_and_empty_non_fuel_fluid_in_container_recipes(recipe_name, empty_recipe_name, mode)
	local recipes = data.raw["recipe"]
	techUtil.hide_recipe(recipes[recipe_name], mode)
	techUtil.hide_recipe(recipes[empty_recipe_name], mode)
end
local function add_fill_and_empty_non_fuel_fluid_in_container_recipes(
	target_technology_name,
	recipe_name,
	empty_recipe_name,
	mode
)
	local technologies = data.raw["technology"]
	techUtil.add_recipe_effect_to_technology(technologies[target_technology_name], recipe_name, mode)
	techUtil.add_recipe_effect_to_technology(technologies[target_technology_name], empty_recipe_name, mode)
end
local function handle_one_recipe(recipe_name, basic_technology_name, mode)
	local empty_recipe_name = string.gsub(recipe_name, "fill", "empty")
	remove_from_basic_technology_fill_and_empty_recipe_names(
		basic_technology_name,
		recipe_name,
		empty_recipe_name,
		mode
	)
	local all_technology_names_for_recipe_with_fuel_result =
		techUtil.get_all_technology_names_with_fuel_result_specified_in_another_recipe_by_name(recipe_name, mode)
	local technology_names_by_result_results =
		get_technology_names_for_ingredient_fuel_result_dont_contain_in_basic_technology_tree(
			all_technology_names_for_recipe_with_fuel_result,
			basic_technology_name,
			mode
		)
	if _table.size(technology_names_by_result_results) == 0 then
		hide_fill_and_empty_non_fuel_fluid_in_container_recipes(recipe_name, empty_recipe_name, mode)
		return
	end

	_table.each(technology_names_by_result_results, function(technology_names_by_result, item_or_fluid_key)
		if _table.size(technology_names_by_result) == 0 then
			return
		end
		log("start recipe_name " .. recipe_name)
		log(
			"all_technology_names_for_recipe_with_fuel_result "
				.. Utils.dump_to_console(all_technology_names_for_recipe_with_fuel_result)
				.. " for recipe_name "
				.. recipe_name
		)
		local recipe_fluid_candidate_ingredients = _table.filter(
			recipeUtil.get_all_recipe_ingredients(recipe_name, mode),
			function(recipe_ingredient)
				return recipe_ingredient.type == "fluid"
			end
		)
		_table.each(recipe_fluid_candidate_ingredients, function(recipe_fluid_candidate_ingredient)
			if not _table.deep_compare(item_or_fluid_key, recipe_fluid_candidate_ingredient) then
				hide_fill_and_empty_non_fuel_fluid_in_container_recipes(recipe_name, empty_recipe_name, mode)
				return
			end
			_table.each(technology_names_by_result, function(target_technology_name)
				add_fill_and_empty_non_fuel_fluid_in_container_recipes(
					target_technology_name,
					recipe_name,
					empty_recipe_name,
					mode
				)
				log(
					"add recipe pair "
						.. recipe_name
						.. " and "
						.. empty_recipe_name
						.. " into technology "
						.. target_technology_name
						.. " for mode "
						.. mode
				)
			end)
		end)
		log("end recipe_name " .. recipe_name)
	end)
end

local function update_fluid_in_container_processing_technology_recipe_effects_by_mode(mode, basic_technology_name)
	if not basic_technology_name or not type(basic_technology_name) == "string" then
		error("technology_name not specified!")
	end
	if not filter_function or not type(filter_function) == "function" then
		error("filter_function not specified!")
	end
	local technologies = data.raw["technology"]
	if not technologies[basic_technology_name] then
		error("technology '" .. basic_technology_name .. "' not found!")
	end
	local recipe_names = _table.filter(
		techUtil.get_all_recipe_names_for_specified_technology(basic_technology_name, mode),
		filter_function
	)
	log("fluid barrel recipes available: " .. Utils.dump_to_console(recipe_names))
	_table.each(recipe_names, function(recipe_name)
		handle_one_recipe(recipe_name, basic_technology_name, mode)
	end)
end

function update_fluid_in_container_processing_technology_recipe_fffects(technology_name)
	_table.each(GAME_MODES, function(mode)
		TechnologyTreeCacheUtil.init_technology_tree_cache(mode)
		update_fluid_in_container_processing_technology_recipe_effects_by_mode(mode, technology_name)
		TechnologyTreeCacheUtil.cleanup_technology_tree_cache(mode)
	end)
end
