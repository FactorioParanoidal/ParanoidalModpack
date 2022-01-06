------------------
---- data.lua ----
------------------

-- Get local functions
local OSM_local = require("utils.local-functions")

-- Setup function host
if not OSM.lib.recipe then OSM.lib.recipe = {} end

-- Assign subgroup to recipe [recipe_order is optional]
function OSM.lib.recipe.assign_subgroup(recipe_name, recipe_subgroup, recipe_order)
	if data.raw.recipe[recipe_name] then
		data.raw.recipe[recipe_name].subgroup = recipe_subgroup
		if recipe_order then
			data.raw.recipe[recipe_name].order = recipe_order
		end
	end
end

-- Replace ingredient in recipe [recipe_name is optional]
function OSM.lib.recipe.replace_ingredient(old_ingredient, new_ingredient, recipe_name)

	-- Safety check for duplicates
	local function check_duplicates(ingredient, ingredients)

		-- Fetch the current ingredient's name and amount
		local name = ingredient.name or ingredient[1]
		local amount = ingredient.amount or ingredient[2]
		local plus_amount

		-- If ingredient is duplicate get amount
		if name == new_ingredient then
			if ingredient.amount then
				plus_amount = ingredient.amount
			else
				plus_amount = ingredient[2]
			end

			if plus_amount == nil then plus_amount = 0 end

			-- Add duplicate amount to old ingredient if found
			if ingredients then
				for _, ingredient in pairs(ingredients) do
			
					local name = ingredient.name or ingredient[1]
					local amount = ingredient.amount or ingredient[2]

					if name == old_ingredient then
						if ingredient.amount then
							ingredient.amount = amount + plus_amount
						else
							ingredient[2] = amount + plus_amount
						end
					end
				end
			end
		end
	end

	-- Replace ingredient if needed
	local function replace_ingredients(ingredient)

		-- Fetch the current ingredient's name
		local name = ingredient.name or ingredient[1]

		-- Check if its a candidate for replacement
		if name == old_ingredient then
			if ingredient.name then
				ingredient.name = new_ingredient
			else
				ingredient[1] = new_ingredient
			end
		end
	end

	-- Scan ingredients
	local function update_ingredient(ingredients, recipe)

		-- Duplicate check
		for i, ingredient in pairs(ingredients) do
			
			check_duplicates(ingredient, ingredients)
			
			if ingredient.name == new_ingredient or ingredient[1] == new_ingredient then
				for _, ingredient in pairs(ingredients) do
					if ingredient.name == old_ingredient or ingredient[1] == old_ingredient then
						table.remove(ingredients, i)
					end
				end
			end
		end

		-- Update ingredient
		for _, ingredient in pairs(ingredients) do
			replace_ingredients(ingredient)
		end
	end

	-- If recipe name is not specified replaces ingredient in all recipes
	if recipe_name == nil then
		for _, recipe in pairs(data.raw.recipe) do

			if recipe.OSM_removed and recipe.OSM_removed == true then return end

			-- Get recipe difficulty and ingredients
			if recipe.normal then recipe = recipe.normal end
			if recipe.expensive then recipe = recipe.expensive end

			-- Scan and update ingredients
			if recipe.ingredients then update_ingredient(recipe.ingredients) end
		end

	-- If recipe name is specified replaces ingredient specified recipe
	elseif recipe_name ~= nil then
		if data.raw.recipe[recipe_name] then

			local recipe = data.raw.recipe[recipe_name]

			if recipe.OSM_removed and recipe.OSM_removed == true then return end

			-- Get recipe difficulty and ingredients
			if recipe.normal then recipe = recipe.normal end
			if recipe.expensive then recipe = recipe.expensive end

			-- Scan and update ingredients
			if recipe.ingredients then update_ingredient(recipe.ingredients) end
		end
	end
end

-- Replace result in recipe [recipe_name is optional]
function OSM.lib.recipe.replace_result(old_result, new_result, recipe_name)

	-- Safety check for duplicates
	local function check_duplicates(result, results)

		-- Fetch the old result properties
		local name = result.name or result[1]
		local amount = result.amount or result[2]
		local old_min_max = {}
		local plus_amount = {}
		local plus_mamount_min = {}
		local plus_amount_max = {}
		
		if result.amount_min and result.amount_max then old_min_max = true end

		-- Check if is duplicate
		if name == new_result then
			
			-- Get amount for fixed amount
			if result.amount then
				plus_amount = result.amount
			else
				plus_amount = result[2]
			end

			-- Get amount for minimum/maximum amount
			if old_min_max == true then
				plus_mamount_min = result.amount_min
				plus_amount_max = result.amount_max
			end

			-- Get amount for probability amount

			-- Set value to 0 if not found
			if plus_amount == nil then plus_amount = 0 end

			-- Adjust result amounts on old_result if duplicate is found
			if results then
				for _, result in pairs(results) do

					-- Fetch properties from results for duplicate check
					local name = result.name or result[1]
					local amount = result.amount or result[2]
					local min_max = {}
					local amount_min = {}
					local amount_max = {}

					-- Set value to 0 if not found
					if amount == nil then amount = 0 end

					-- Adjust result amounts for old_result
					if name == old_result then

						-- Get minimum/maximum amount
						if result.amount_min and result.amount_max then
							amount_min = result.amount_min
							amount_max = result.amount_max
						end

						-- Fixed amount result
						if result.amount then
							result.amount = amount + plus_amount
						elseif result[2] then
							result[2] = amount + plus_amount
						end
						
						-- Minimum/maximum amount result
						if old_min_max == true then
							if result.amount then
								result.amount_min = amount + plus_amount_min
								result.amount_max = amount + plus_amount_max
								result.amount = nil
							elseif amount_min or amount_max then
								result.amount_min = amount_min + plus_amount_min
								result.amount_max = amount_max + plus_amount_max
							end
						end
						
						-- Probability amount result

					end
				end
			end
		end
	end

	-- Replace result if needed
	local function replace_results(result)

		-- Fetch the current result's name
		local name = result.name or result[1]

		-- Check if its a candidate for replacement
		if name == old_result then
			if result.name then
				result.name = new_result
			else
				result[1] = new_result
			end
		end

		local new_subgroup = data.raw.item[new_result].subgroup
		
		if recipe.OSM_removed and recipe.OSM_removed == true then
				recipe.subgroup = "OSM_removed"
		else
			if result.main_product == old_result then
				recipe.subgroup = new_subgroup
			end
		end
	end

	-- Scan results and update results
	local function update_results(results, recipe)

		if results then
			for i, result in pairs(results) do

				-- Check for duplicates
				check_duplicates(result, results)

				-- Insert placeholder
				if result.name == new_result or result[1] == new_result then
					if recipe.main_product == old_result then
						recipe.main_product = new_result
					end


					for _, result in pairs(results) do
						if result.name == old_result or result[1] == old_result then
							table.remove(results, i)
							replace_results(result)
						end
					end
				end
			end
			
			for i, result in pairs(results) do
				if result.name == old_result or result[1] == old_result then

					-- Replace old result with new result
					replace_results(result)
				end
			end
		end
	end
	
	-- Update single result
	local function update_result(result, recipe)
		if result then
			local new_subgroup = data.raw.item[new_result].subgroup

			if recipe.OSM_removed and recipe.OSM_removed == true then
				recipe.subgroup = "OSM_removed"
			else
				if recipe.result == old_result then
					recipe.result = new_result
					recipe.subgroup = new_subgroup
				end
			end
		end
	end

	-- If recipe name is not specified replaces result in all recipes
	if recipe_name == nil then
		for _, recipe in pairs(data.raw.recipe) do
			
			if recipe.OSM_removed and recipe.OSM_removed == true then return end
			
			-- Get recipe difficulty
			if recipe.normal then recipe = recipe.normal end
			if recipe.expensive then recipe = recipe.expensive end

			-- Scan and update result
			if recipe.results then update_results(recipe.results, recipe) end
			if recipe.result then update_result(recipe.result, recipe) end
		end

	-- If recipe name is specified replaces result specified recipe
	elseif recipe_name ~= nil then
		if data.raw.recipe[recipe_name] then
			
			local recipe = data.raw.recipe[recipe_name]
			
			if recipe.OSM_removed and recipe.OSM_removed == true then return end
			
			-- Get recipe difficulty
			if recipe.normal then recipe = recipe.normal end
			if recipe.expensive then recipe = recipe.expensive end

			-- Scan and update result
			if recipe.results then update_results(recipe.results, recipe) end
			if recipe.result then update_result(recipe.result, recipe) end
		end
	end
end

-- Remove recipe from all modules limitation list
function OSM.lib.recipe.remove_limitation(recipe_name)
	for _, module in pairs(data.raw.module) do
		if module.limitation then
			for i, recipe in pairs(module.limitation) do
				if recipe == recipe_name then
					table.remove(module.limitation, i) -- yeah, fuck you twat
				end
			end
		end
	end
end
