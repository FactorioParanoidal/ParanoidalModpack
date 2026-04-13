local Data = require('__Kux-CoreLib__/stdlib/data/data') --[[@as StdLib.Data]]
local Table = require('__Kux-CoreLib__/stdlib/utils/table') --[[@as StdLib.Utils.Table]]

--- Recipe class
--- @class StdLib.Data.Recipe : StdLib.Data
local Recipe = {
    __class = 'Recipe',
    __index = Data,
}

function Recipe:__call(recipe)
    local new = self:get(recipe, 'recipe')
    -- rawset(new, 'Ingredients', {})
    -- rawset(new, 'Results', {})
    return new
end
setmetatable(Recipe, Recipe)

--- Remove an ingredient from an ingredients table.
--- @param ingredients table
--- @param name string Name of the ingredient to remove
local function remove_ingredient(ingredients, name)
    for i, ingredient in pairs(ingredients or {}) do
        if ingredient[1] == name or ingredient.name == name then
            table.remove(ingredients, i)
            return true
        end
    end
end

--- Replace an ingredient.
--- @param ingredients table
--- @param find string ingredient to replace
--- @param replace Ingredient
--- @param replace_name_only boolean Don't replace amounts
local function replace_ingredient(ingredients, find, replace, replace_name_only)
    for i, ingredient in pairs(ingredients or {}) do
        if ingredient.name == find then
            if replace_name_only then
                local amount = ingredient.amount
                replace.amount = amount
            end
            ingredients[i] = replace
            return true
        end
    end
end

--- Remove a product from results table.
--- @param results table
--- @param name string|Product Name of the product to remove
local function remove_result(results, name)
    name = type(name)=="string" and name or name.name
    for i, product in pairs(results or {}) do
        if product[1] == name or product.name == name then
            table.remove(results, i)
            return true
        end
    end
end

--- Finds a product from results table.
--- @param results table
--- @param name string Name of the product to find
--- @return Product?
local function find_result(results, name)
    for i, product in pairs(results or {}) do
        if product.name == name then
            return product
        end
    end
end

--- Replace a product.
--- @param results table
--- @param find string product to replace
--- @param replace Product product
local function replace_result(results, find, replace)
    for i, product in pairs(results or {}) do
        if product[1] == find or product.name == find then
            results[i] = replace
            return true
        end
    end
end

--- Add a new ingredient to a recipe.
--- @param ingredient string|Ingredient Name or table to add
--- @param count number? [opt] Amount of ingredient
--- @return StdLib.Data.Recipe
function Recipe:add_ingredient(ingredient, count)
    if self:is_valid() then
		if type(ingredient)=="string" then
			local count = count or 1
			if type(count)=="boolean" then -- error handling for outdated mods
				count = 1
			end
			ingredient = {type="item",name=ingredient,amount=count}
		end
        if self.ingredients then
			local original_amount = false	-- prevent duplicate entries
			for _, ingred in pairs(self.ingredients) do
				if ingred.name == ingredient.name then
					original_amount = ingred.amount
				end
			end
			if original_amount then
				ingredient.amount = ingredient.amount + original_amount
				self:replace_ingredient(ingredient.name,ingredient)
			else
				table.insert(self.ingredients,ingredient)
			end
        end
    end
    return self
end
Recipe.add_ing = Recipe.add_ingredient

--- Remove one ingredient completely.
--- @param ingredient string Name of ingredient to remove
--- @return StdLib.Data.Recipe
function Recipe:remove_ingredient(ingredient)
    if self:is_valid() then
        if self.ingredients then
            remove_ingredient(self.ingredients, ingredient)
        end
    end
    return self
end
Recipe.rem_ing = Recipe.remove_ingredient

--- Replace one ingredient with another.
--- @param replace string Name of ingredient to be replaced
--- @param ingredient string|Ingredient Name or table to add
--- @param count number? [opt] Amount of ingredient
--- @return StdLib.Data.Recipe
function Recipe:replace_ingredient(replace, ingredient, count)
    assert(replace, 'Missing recipe to replace')
    if self:is_valid() then
		local replace_name_only = false
		if type(ingredient)=="string" and count then
			ingredient = {name=ingredient,amount=count,type="item"}
		elseif type(ingredient)=="string" then
			replace_name_only = true
			ingredient = {name=ingredient,amount=1,type="item"}
		end
		if self.ingredients then
            replace_ingredient(self.ingredients, replace, ingredient, replace_name_only)
        end
    end
    return self
end
Recipe.rep_ing = Recipe.replace_ingredient

--- Removes all ingredients from recipe completely.
--- @return self
function Recipe:clear_ingredients()
    if self:is_valid() then
		self.ingredients = {}
    end
    return self
end

--- Copies ingredients from one recipe to another.
--- @param recipe string Name of the recipe to copy ingredients from
--- @param keep_ingredients boolean? [opt] Whether to keep the original ingredients
--- @return self
function Recipe:copy_ingredients(recipe, keep_ingredients)
	if self:is_valid() then
		local recipe = Recipe(recipe)
		if recipe:is_valid() then
			if not keep_ingredients then
				self:clear_ingredients()
			end
			for _, ingredient in pairs(recipe:get_ingredients()) do
				self:add_ingredient(ingredient)
			end
		end
	end
    return self
end

--- Shorthand to get ingredient table associated with recipe.
--- @return table? Ingredients
function Recipe:get_ingredients()
    if self:is_valid() then
		return table.deepcopy(self.ingredients)
    end
end

--- Multiplies the amount of each ingredient in a recipe.
--- @param mult number Amount to multiply each ingredient by
--- @return self
function Recipe:multiply_ingredients(mult)
	if self:is_valid() then
		if self.ingredients then
			for _, ingred in pairs(self.ingredients) do
				ingred.amount = mult*ingred.amount
			end
		end
	end
	return self
end

--- Change the recipe category.
--- @param category_name string The new crafting category
--- @return self
function Recipe:change_category(category_name)
    if self:is_valid() then
        local Category = require('__Kux-CoreLib__/stdlib/data/category')
        self.category = Category(category_name, 'recipe-category'):is_valid() and category_name or self.category
    end
    return self
end
Recipe.set_category = Recipe.change_category

--- Add to technology as a recipe unlock.
--- @param tech_name string Name of the technology to add the unlock too
--- @return self
function Recipe:add_unlock(tech_name)
    if self:is_valid() then
        local Tech = require('__Kux-CoreLib__/stdlib/data/technology')
        Tech.add_effect(self, tech_name) --self is passed as a valid recipe
    end
    return self
end

--- Remove the recipe unlock from the technology.
--- @param tech_name string Name of the technology to remove the unlock from
--- @return self
function Recipe:remove_unlock(tech_name)
    if self:is_valid('recipe') then
        local Tech = require('__Kux-CoreLib__/stdlib/data/technology')
        Tech.remove_effect(self, tech_name, 'unlock-recipe')
    end
    return self
end

-- Locate the first technology that unlocks recipe, and adds this recipe to that technology
function Recipe:copy_unlock(recipe)
	if self:is_valid() then
        local Tech = require('__Kux-CoreLib__/stdlib/data/technology')
		local originalTech = ""
		-- Locate the originalTech for recipe
		for _, tech in pairs(data.raw.technology) do
			if tech.effects and (not string.find(tech.name, "demo-")) then
				for _, effect in pairs (tech.effects) do
					if recipe == effect.recipe then
						originalTech = tech.name
						break
					end
				end
			end
		end
		--Then add this recipe to originalTech
		if Tech(originalTech):is_valid() then
			self:add_unlock(originalTech)
		else
			self:set_enabled(true)	-- assume no tech, so should be enabled from start
		end
	end
end

--- Set the enabled status of the recipe.
--- @param enabled boolean Enable or disable the recipe
--- @return self
function Recipe:set_enabled(enabled)
    if self:is_valid() then
        self.enabled = enabled
    end
    return self
end

--- Set the main product of the recipe.
--- @param main_product string
--- @return self
function Recipe:set_main_product(main_product)
    if self:is_valid('recipe') then
		local Item = require('__Kux-CoreLib__/stdlib/data/item')
		if Item(main_product):is_valid() then
			self.main_product = main_product
		end
    end
    return self
end

--- Remove the main product of the recipe.
--- @return self
function Recipe:remove_main_product()
    if self:is_valid('recipe') then
        self.main_product = ""
    end
    return self
end

--- Add a new product to results table.
--- @param product string|Product product Name or table to add
--- @param count number? [opt] Amount of product
--- @param probability number? [opt] A value in range [0, 1]. Item is only given with this probability; otherwise no product is produced.
--- @return StdLib.Data.Recipe
function Recipe:add_result(product, count, probability)
    if self:is_valid() then
		if type(product)=="string" then
			local count = count or 1
			local probability = probability or 1
			product = {type="item", name=product, amount=count, probability=probability}--[[@as ItemProduct]]
		end
        if self.results then
			table.insert(self.results, product)
        end
    end
    return self
end

--- Remove a product from results table.
--- @param product string|Product Name or table to add
--- @return StdLib.Data.Recipe
function Recipe:remove_result(product)
    if self:is_valid() then
        if self.results then
            remove_result(self.results, product)
        end
    end
    return self
end

--- Replace a product from results with a new product.
--- @param replace string Name of product to be replaced
--- @param product string|Product Name or table to add
--- @param count number? [opt] Amount of product
--- @param probability number? [opt] A value in range [0, 1]. Item is only given with this probability; otherwise no product is produced.
--- @return StdLib.Data.Recipe
function Recipe:replace_result(replace, product, count, probability)
    if not self:is_valid() then return self end
	if type(product)=="string" then
		local p0 = find_result(self.results, replace)
		if not p0 then return self end
		local count = (p0.amount and p0.amount > 0) and p0.amount or ((count and count > 1) and count or 1)
		local probability = (p0.probability and p0.probability > 0) and p0.probability or ((probability and probability > 1) and probability or 1)
		product = {name=product, amount=count, type="item", probability=probability}
	end
	if self.results then
		replace_result(self.results, replace, product)
	end
    return self
end

--- Removes all results from recipe completely.
--- @return self
function Recipe:clear_results()
    if self:is_valid() then
		self.results = {}
    end
    return self
end

--- Copies results from one recipe to another.
--- @param recipe string Name of the recipe to copy results from
--- @param keep_results boolean? [opt] Whether to keep the original results
--- @return self
function Recipe:copy_results(recipe, keep_results)
	if self:is_valid() then
		local recipe = Recipe(recipe)
		if recipe:is_valid() then
			if not keep_results then
				self:clear_results()
			end
			for _, result in pairs(recipe:get_results()) do
				self:add_result(result)
			end
		end
	end
    return self
end

--- Shorthand to get results table associated with recipe.
--- @return Product[]? #Results
function Recipe:get_results()
    if self:is_valid() then
		return self["results"]
    end
end

--- Removes all surface conditions from recipe completely.
--- @return self
function Recipe:clear_surface_conditions()
    if self:is_valid() then
		self.surface_conditions = {}
    end
    return self
end

return Recipe
