local RecipeUtil = {}

local function getRecipeObjectForMode(recipe_name, mode)
	return Utils.getModedObject(data.raw["recipe"][recipe_name], mode)
end

local function getRecipeDataProducts(recipeData)
	local result = {}
	if not recipeData then
		return result
	end
	if recipeData.main_product and recipeData.main_product ~= "" then
		table.insert(result, {
			name = recipeData.main_product,
			type = "item",
		})
	end
	if recipeData.result and recipeData.result ~= "" then
		table.insert(result, {
			name = recipeData.result,
			type = "item",
		})
	end
	if recipeData.results and _table.size(recipeData.results) > 0 then
		_table.each(recipeData.results, function(result_data)
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

local function createTechnologyEffectResultFromRocketLaunchProduct(rocket_launch_product_data)
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
local function getRocketLaunchResults(result_data)
	local result = {}
	local result_data_item = data.raw[result_data.type][result_data.name]
	if not result_data_item then
		return result
	end
	if result_data_item.rocket_launch_product then
		table.insert(
			result,
			createTechnologyEffectResultFromRocketLaunchProduct(result_data_item.rocket_launch_product)
		)
	end
	if result_data_item.rocket_launch_products and _table.size(result_data_item.rocket_launch_products) > 0 then
		_table.each(result_data_item.rocket_launch_products, function(rocket_launch_product_data)
			table.insert(result, createTechnologyEffectResultFromRocketLaunchProduct(rocket_launch_product_data))
		end)
	end
	return result
end

RecipeUtil.getAllRecipeResults = function(recipe_name, mode)
	local result = {}
	local recipeData = getRecipeObjectForMode(recipe_name, mode)
	_table.insert_all_if_not_exists(result, getRecipeDataProducts(recipeData))
	local rocketLaunchResults = {}
	_table.each(result, function(result_data)
		_table.insert_all_if_not_exists(rocketLaunchResults, getRocketLaunchResults(result_data))
	end)
	_table.insert_all_if_not_exists(result, rocketLaunchResults)
	return result
end

local function getRecipeDataIngredients(recipeData)
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

RecipeUtil.getAllRecipeIngredients = function(recipe_name, mode)
	local result = {}
	local recipeData = getRecipeObjectForMode(recipe_name, mode)
	_table.insert_all_if_not_exists(result, getRecipeDataIngredients(recipeData))
	return result
end

RecipeUtil.isBasicRecipeCategoryOrCompatible = function(category)
	if not category then
		return false
	end
	return string.find(category, "advanced-crafting", 1, true)
		or string.find(category, "basic-crafting", 1, true)
		or string.find(category, "centrifuging", 1, true)
		or string.find(category, "chemistry", 1, true)
		or string.find(category, "crafting", 1, true)
		or string.find(category, "crafting-with-fluid", 1, true)
		or string.find(category, "oil-processing", 1, true)
		or string.find(category, "rocket-building", 1, true)
		or string.find(category, "smelting", 1, true)
		or string.find(category, "electronics", 1, true)
end

RecipeUtil.isContainDry411Srev = function(recipe_name)
	return string.find(recipe_name, "dry411srev-", 1, true)
end

-- любой рецепт должен быть открыт какой-то технологией
RecipeUtil.disableAllRecipesFromGameStart = function(mode)
	_table.each(data.raw["recipe"], function(recipe)
		--[[		_table.each(GAME_RECIPE_MODES[mode],
				function (recipe_mode)
					local modedObject=Utils.getModedObject(recipe,recipe_mode)
					if modedObject then
						modedObject.enabled=false
					end
				end)]]
	end)
end

return RecipeUtil
