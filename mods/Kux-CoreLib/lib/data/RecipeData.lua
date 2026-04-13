require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---@class KuxCoreLib.RecipeData : KuxCoreLib.Class
---@field asGlobal fun():KuxCoreLib.RecipeData
local RecipeData= {
	__class  = "KuxCoreLib.RecipeData",
	__guid   = "{6B1DC373-2A83-4C81-94BD-92E772340FDE}",
	__origin = "Kux-CoreLib/lib/data/RecipeData.lua",
}
if not KuxCoreLib.__classUtils.ctor(RecipeData) then return self end
---------------------------------------------------------------------------------------------------

local utils = KuxCoreLib.PrototypeData.extend.utils

---Clone an recipe prototype
---@param name string The name of the recipe prototype to clone
---@param item data.ItemPrototype The corresponding item prototype
---@param patch table?
---@return data.RecipePrototype #The cloned recipe prototype
RecipeData.clone = function(name, item, patch)
	local base = data.raw["recipe"][name]
	if(not base) then error("Prototype not found: "..name.." (tyoe: recipe)") end
	local recipe = table.deepcopy(base)
	recipe.name = item.name
	recipe.localised_name = {"recipe-name."..item.name}
	RecipeData.setResults(recipe, {{amount = 1, name = item.name, type = "item"}})
	if recipe.main_product then recipe.main_product = item.name end
	recipe["base"]=base -- additional data, only for data stage
	if(patch) then utils.patch(recipe, patch) end -- apply patch if any
	return recipe
end

RecipeData.setResults = function(recipe, results)
	if isV1 and recipe.normal then
		recipe.normal.results = results
		recipe.normal.result = nil
		recipe.results = nil
		recipe.result = nil
		if(recipe.expensive) then
			recipe.expensive.results = results
			recipe.expensive.result = nil
		end
	else
		recipe.results = results
		recipe.result = nil
	end
end

RecipeData.ingredientsFactor = function (ingredients, factor)
	if(not ingredients) then return nil end
	ingredients = table.deepcopy(ingredients) or {}

	--ingredients = {{type = "item", name = "iron-stick", amount = 2}, {type = "item", name = "iron-plate", amount = 3}}
	--ingredients = {{type="fluid", name="water", amount=50}, {type="fluid", name="crude-oil", amount=100}}
	-- ingredients = {{"iron-stick", 2}, {"iron-plate", 3}}
	for index, value in ipairs(ingredients) do
		if(value~=nil) then
			if(value.amount) then value.amount = value.amount * factor
			elseif(value[2]) then value[2] = value[2] * factor end
		end
	end
	return ingredients
end

RecipeData.recipeFactor = function (recipe, factor)
	if(recipe.normal and recipe.normal~=false) then recipe.normal = RecipeData.ingredientsFactor(recipe.normal, factor) end
	if(recipe.expensive and recipe.expensive~=false) then recipe.expensive = RecipeData.ingredientsFactor(recipe.expensive, factor) end
	if(recipe.ingredients) then recipe.ingredients = RecipeData.ingredientsFactor(recipe.ingredients, factor) end
end

---TODO: WIP
---@param value number|string value [v, vMJ, vkW]
---@param formula number|string formula [x, +x%, -x%, *x, /x]
---@return number|string
function RecipeData.calculate_value(value, formula) --TODO: WIP, TEST THIS
	-- Extract numeric value and unit from the input
	local numeric_value, unit = string.match(tostring(value), "(%d+%.?%d*)(%a*)")
	if not numeric_value then error("Invalid value: must be a number with an optional unit.") end
	if not unit then unit = "" end

	-- Convert numeric_value to a number
	numeric_value = tonumber(numeric_value)

	-- Validate and handle the formula
	local operator, operand = string.match(tostring(formula), "([%+%-%*/]?)([%d%%]+)")
	if not operator or not operand then
		error("Invalid formula: must match the pattern [x, +x%, -x%, *x, /x].")
	end

	-- Handle percentage values
	local is_percentage = string.find(operand, "%%")
	if is_percentage then operand = tonumber(string.sub(operand, 1, -2)) / 100 * numeric_value
	else operand = tonumber(operand) end

	-- Perform the operation
	local result
	if operator == "" or operator == nil then result = operand
	elseif operator == "+" then result = numeric_value + operand
	elseif operator == "-" then result = numeric_value - operand
	elseif operator == "*" then result = numeric_value * operand
	elseif operator == "/" then result = numeric_value / operand
	else error("Unsupported operator: " .. operator) end

	return unit == "" and result or tostring(result)..unit
	--TODO: FEATURE scale unit
end


---TODO: WIP Find a result entry in a recipe by name or index
---@param recipe data.RecipePrototype|string
---@param result number|string
---@return table? #result entry or nil
---@return string? #error description
function RecipeData.find_result(recipe, result)
	-- Ensure recipe is valid
	if type(recipe) == "string" then recipe = data.raw.recipe[recipe]  or error("Recipe '" .. recipe .. "' not found.")
	elseif type(recipe) ~= "table" then error("Invalid recipe: must be a recipe prototype or name.") end

	if not recipe.results or #recipe.results==0 then return nil, ("No results") end

	if type(result) == "number" then return recipe.results[result] end
	if type(result) ~= "string" then error("Invalid result: must be a string.") end

	-- Find the result in the recipe
	local result_entry
	for _, res in pairs(recipe.results) do
		if res.name == result or res[1] == result then
			result_entry = res
			break
		end
	end
	if not result_entry then return nil, ("Result '" .. result .. "' not found in recipe '" .. recipe.name .. "'.") end

	return result_entry
end

--- Remove an ingredient from an ingredients table.
--- @param ingredients Ingredient[]
--- @param name string Name of the ingredient to remove
function RecipeData.remove_ingredient(ingredients, name)
    for i, ingredient in pairs(ingredients or {}) do
        if ingredient[1] == name or ingredient.name == name then
            table.remove(ingredients, i)
            return true
        end
    end
end

--- Replace an ingredient.
--- @param ingredients Ingredient[]
--- @param find string ingredient to replace
--- @param replace Ingredient|string
function RecipeData.replace_ingredient(ingredients, find, replace)
    for i, ingredient in pairs(ingredients or {}) do
        if ingredient.name == find then
            if type(replace)=="string" then
				ingredient.name = replace
			else
				ingredient.type = replace.type and replace.type or ingredient.type
				ingredient.name = replace.name and replace.name or ingredient.name
                ingredient.amount = replace.amount and replace.amount or ingredient.amount
            end
            return true
        end
    end
end

---------------------------------------------------------------------------------------------------
return RecipeData