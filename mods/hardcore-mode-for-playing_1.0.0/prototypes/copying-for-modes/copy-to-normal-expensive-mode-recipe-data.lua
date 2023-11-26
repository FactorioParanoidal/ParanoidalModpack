local recipe_data_field_names = {
	"ingredients",
	"result",
	"result_count",
	"results",
	"energy_required",
	"emissions_multiplier",
	"requester_paste_multiplier",
	"overload_multiplier",
	"allow_inserter_overload",
	"enabled",
	"hidden",
	"hide_from_stats",
	"hide_from_player_crafting",
	"allow_decomposition",
	"allow_as_intermediate",
	"allow_intermediates",
	"always_show_made_in",
	"show_amount_in_title",
	"always_show_products",
	"unlock_results",
	"main_product",
}
local function createRecipeDataFromGeneralRecipeData(recipe)
	local result = {}
	_table.each(recipe_data_field_names, function(recipe_data_field_name)
		if type(recipe[recipe_data_field_name]) == "table" then
			result[recipe_data_field_name] = _table.deep_copy(recipe[recipe_data_field_name])
		else
			result[recipe_data_field_name] = recipe[recipe_data_field_name]
		end
	end)
	return result
end

local recipes = data.raw["recipe"]

_table.each(GAME_MODES, function(mode)
	local technology_names = techUtil.getAllTechnologyNamesWithHidden()
	_table.each(technology_names, function(technology_name)
		local recipe_names = techUtil.getAllRecipesNamesForSpecifiedTechnology(technology_name, mode)
		_table.each(recipe_names, function(recipe_name)
			local recipe = recipes[recipe_name]
			local recipe_data = createRecipeDataFromGeneralRecipeData(recipe)
			if not recipes[recipe_name][mode] then
				recipes[recipe_name][mode] = recipe_data
				return
			end
			local for_merging_recipe_data = recipes[recipe_name][mode]
			_table.merge(for_merging_recipe_data, recipe_data)
		end)
	end)
end)
local function clearRecipeData(reciipe)
	_table.each(recipe_data_field_names, function(technology_data_field_name)
		reciipe[technology_data_field_name] = nil
	end)
end

_table.each(GAME_MODES, function(mode)
	local technology_names = techUtil.getAllTechnologyNamesWithHidden()
	_table.each(technology_names, function(technology_name)
		local recipe_names = techUtil.getAllRecipesNamesForSpecifiedTechnology(technology_name, mode)
		_table.each(recipe_names, function(recipe_name)
			local recipe = recipes[recipe_name]
			clearRecipeData(recipe)
			log(
				"for mode "
					.. mode
					.. " recipe named "
					.. recipe_name
					.. " is after copying for modes "
					.. Utils.dump_to_console(recipe)
			)
		end)
	end)
end)
