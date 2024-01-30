local RecipeUtil = {}

local function get_recipe_object_for_mode(recipe_name, mode)
	return Utils.get_moded_object(data.raw["recipe"][recipe_name], mode)
end

local function get_recipe_data_products(recipe_data)
	local result = {}
	if not recipe_data then
		return result
	end
	if recipe_data.main_product and recipe_data.main_product ~= "" then
		table.insert(result, {
			name = recipe_data.main_product,
			type = "item",
		})
	end
	if recipe_data.result and recipe_data.result ~= "" then
		table.insert(result, {
			name = recipe_data.result,
			type = "item",
		})
	end
	if recipe_data.results and _table.size(recipe_data.results) > 0 then
		_table.each(recipe_data.results, function(result_data)
			local result_name = result_data.name or result_data[1]
			if result_name ~= "" then
				table.insert(result, {
					name = result_name,
					type = result_data.type or "item",
				})
			end
		end)
	end
	return result
end

local function create_technology_effect_result_from_rocket_launch_product(rocket_launch_product_data)
	if not rocket_launch_product_data then
		error("rocket launch product not found")
	end
	local rocket_launch_product_data_type = rocket_launch_product_data.type or "item"
	local rocket_launch_product_data_name = rocket_launch_product_data.name or rocket_launch_product_data[1]
	--log("rocket launch result type " .. rocket_launch_product_data_type .. " name " .. rocket_launch_product_data_name)
	return {
		name = rocket_launch_product_data_name,
		type = rocket_launch_product_data_type,
	}
end
local function get_rocket_launch_results(result_data)
	local result = {}
	local result_data_item = data.raw[result_data.type][result_data.name]
	if not result_data_item then
		return result
	end
	if result_data_item.rocket_launch_product then
		table.insert(
			result,
			create_technology_effect_result_from_rocket_launch_product(result_data_item.rocket_launch_product)
		)
	end
	if result_data_item.rocket_launch_products and _table.size(result_data_item.rocket_launch_products) > 0 then
		_table.each(result_data_item.rocket_launch_products, function(rocket_launch_product_data)
			table.insert(result, create_technology_effect_result_from_rocket_launch_product(rocket_launch_product_data))
		end)
	end
	return result
end

RecipeUtil.get_all_recipe_results = function(recipe_name, mode)
	local result = {}
	local recipeData = get_recipe_object_for_mode(recipe_name, mode)
	_table.insert_all_if_not_exists(result, get_recipe_data_products(recipeData))
	local rocket_launch_results = {}
	_table.each(result, function(result_data)
		_table.insert_all_if_not_exists(rocket_launch_results, get_rocket_launch_results(result_data))
	end)
	_table.insert_all_if_not_exists(result, rocket_launch_results)
	return result
end

local function get_recipe_data_ingredients(recipeData)
	local result = {}
	if not recipeData then
		return result
	end
	if recipeData.ingredients and _table.size(recipeData.ingredients) > 0 then
		_table.each(recipeData.ingredients, function(result_data)
			local result_name = result_data.name or result_data[1]
			if result_name ~= "" then
				table.insert(result, {
					name = result_name,
					type = result_data.type or "item",
				})
			end
		end)
	end
	return result
end

RecipeUtil.get_all_recipe_ingredients = function(recipe_name, mode)
	local result = {}
	local recipeData = get_recipe_object_for_mode(recipe_name, mode)
	_table.insert_all_if_not_exists(result, get_recipe_data_ingredients(recipeData))
	return result
end

RecipeUtil.is_contain_dry411_srev = function(recipe_name)
	return string.find(recipe_name, "dry411srev-", 1, true)
end

return RecipeUtil
