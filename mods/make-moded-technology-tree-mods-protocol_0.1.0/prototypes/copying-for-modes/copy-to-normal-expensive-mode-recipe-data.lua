local recipe_data_field_names = {
	"ingredients",
	"results",
	--simples
	"result",
	"result_count",
	"main_product",
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
}

local recipe_data_field_simple_names = {
	"result",
	"result_count",
	"main_product",
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
}
local function mergeRecipeDataData(for_merging_recipe_data_mode, recipe_data_general)
	_table.each(recipe_data_field_names, function(recipe_data_field_name)
		if not recipe_data_general[recipe_data_field_name] then
			--log("property '" .. recipe_data_field_name .. "' not specified in general data!")
			return
		end
		if _table.contains(recipe_data_field_simple_names, recipe_data_field_name) then
			for_merging_recipe_data_mode[recipe_data_field_name] = recipe_data_general[recipe_data_field_name]
			return
		end

		if not for_merging_recipe_data_mode[recipe_data_field_name] then
			for_merging_recipe_data_mode[recipe_data_field_name] = recipe_data_general[recipe_data_field_name]
			return
		end
		if for_merging_recipe_data_mode[recipe_data_field_name] and recipe_data_general[recipe_data_field_name] then
			_table.insert_all_if_not_exists_with_compare(
				for_merging_recipe_data_mode[recipe_data_field_name],
				recipe_data_general[recipe_data_field_name],
				function(o1, o2)
					return ((o1.name or o1[1]) == (o2.name or o2[1])) and ((o1.type or "item") == (o2.type or "item"))
				end
			)
		end
	end)
end
local function createRecipeDataFromGeneralRecipeData(recipe)
	local result = {}
	_table.each(recipe_data_field_names, function(recipe_data_field_name)
		if recipe[recipe_data_field_name] and type(recipe[recipe_data_field_name]) == "table" then
			result[recipe_data_field_name] = _table.deep_copy(recipe[recipe_data_field_name])
		else
			result[recipe_data_field_name] = recipe[recipe_data_field_name]
		end
	end)
	return result
end

local recipes = data.raw["recipe"]

_table.each(GAME_MODES, function(mode)
	_table.each(data.raw["recipe"], function(recipe)
		--log("recipe_name " .. recipe.name)
		local recipe_data = createRecipeDataFromGeneralRecipeData(recipe)
		if not recipe[mode] then
			recipe[mode] = recipe_data
			--	log("not found recipe mode " .. mode .. " replacing general data!")
			return
		end
		local for_merging_recipe_data = recipe[mode]
		--log("for_merging_recipe_data " .. Utils.dump_to_console(for_merging_recipe_data))
		--log("recipe_data " .. Utils.dump_to_console(recipe_data))
		mergeRecipeDataData(for_merging_recipe_data, recipe_data)
		--log("merged_data " .. Utils.dump_to_console(for_merging_recipe_data))
	end)
end)
local function clearRecipeData(recipe)
	_table.each(recipe_data_field_names, function(technology_data_field_name)
		recipe[technology_data_field_name] = nil
	end)
end

_table.each(GAME_MODES, function(mode)
	--[[_table.each(data.raw["recipe"], function(recipe)
		clearRecipeData(recipe)
		log(
			"for mode "
				.. mode
				.. " recipe named "
				.. recipe.name
				.. " is after copying for modes "
				.. Utils.dump_to_console(recipe)
		)
	end)]]
end)
