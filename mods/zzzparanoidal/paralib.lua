paralib = paralib or {}
paralib.utils = paralib.utils or {}
paralib.debugLevels = { NoDebug = 0, DebugToLog = 1, DebugAbort = 2 }
paralib.debug = paralib.debugLevels.DebugToLog

function paralib.ProcessError(message)
	if paralib.debug == paralib.debugLevels.NoDebug then
		return
	end
	if paralib.debug == paralib.debugLevels.DebugToLog then
		log("------------------------")
		log("DEBUG: " .. message)
		log(debug.traceback())
		log("------------------------")
		return
	end
	if paralib.debug == paralib.debugLevels.DebugAbort then
		assert(false, "DEBUG: " .. message)
	end
end

-- ----------- --
-- BOB LIBRARY --
-- ----------- --

paralib.bobmods = paralib.bobmods or {}
paralib.bobmods.lib = paralib.bobmods.lib or {}
paralib.bobmods.lib.tech = paralib.bobmods.lib.tech or {}
paralib.bobmods.lib.recipe = paralib.bobmods.lib.recipe or {}

---Check that value have proper type
---@param value string
---@param expectedType string
function paralib.EnsureType(value, expectedType)
	if type(value) ~= expectedType then
		paralib.ProcessError(
			serpent.block(value, { maxlevel = 1 })
				.. " expected to have type: "
				.. expectedType
				.. " but it is:"
				.. type(value)
		)
	end
end

---Check that data.raw[section][name] exists
---@param section string
---@param name string
function paralib.EnsureExists(section, name)
	if not data.raw[section] then
		paralib.ProcessError("data.raw[" .. section .. "] does not exists!")
		return
	end
	if not data.raw[section][name] then
		paralib.ProcessError("data.raw[" .. section .. "][" .. name .. "] does not exists!")
		return
	end
end

---Check that recipe part(ingredient/result) exists
---@param partName string
---@param recipePart table {type = "...", name = "...", amount = ...}
function paralib.utils.EnsureRecipePartExists(partName, recipePart)
	if type(recipePart) ~= "table" then
		paralib.ProcessError("Recipe " .. partName .. " expected to be table. But it is: " .. type(recipePart))
		return
	end
	if not recipePart.type then
		paralib.ProcessError(partName .. ".type not found!")
		return
	end
	if not recipePart.name then
		paralib.ProcessError(partName .. ".name not found!")
		return
	end
	if not recipePart.amount then
		paralib.ProcessError(partName .. ".amount not found!")
		return
	end
end

function paralib.utils.IsTablesEqual(tbl1, tbl2)
	if type(tbl1) ~= "table" or type(tbl2) ~= "table" then
		return false
	end

	-- check that tbl1 ==> tbl2
	for k, v in pairs(tbl1) do
		if tbl2[k] == nil or type(v) ~= type(tbl2[k]) then
			return false
		end
		if type(v) == "table" and not paralib.utils.IsTablesEqual(v, tbl2[k]) then
			return false
		end
		if type(v) == "number" or type(v) == "string" or type(v) == "boolean" then
			if v ~= tbl2[k] then
				return false
			end
		end
	end

	-- check that tbl2 ==> tbl1
	for k, v in pairs(tbl2) do
		if tbl1[k] == nil or type(v) ~= type(tbl1[k]) then
			return false
		end
		if type(v) == "table" and not paralib.utils.IsTablesEqual(v, tbl1[k]) then
			return false
		end
		if type(v) == "number" or type(v) == "string" or type(v) == "boolean" then
			if v ~= tbl1[k] then
				return false
			end
		end
	end
	return true
end

---Check that given table is array
---@param tbl table
function paralib.utils.IsArray(tbl)
	if type(tbl) ~= "table" then
		return false
	end
	if #tbl == 0 then
		return true
	end

	for i = 1, #tbl do
		if tbl[i] == nil then
			return false
		end
	end
	return true
end

function paralib.EnsureIngredientExists(ingredient)
	paralib.utils.EnsureRecipePartExists("ingredient", ingredient)
end

function paralib.EnsureResultExists(result)
	paralib.utils.EnsureRecipePartExists("result", result)
end

-- ---------------------------- --
-- TECHNOLOGY FUNCTION WRAPPERS --
-- ---------------------------- --
function paralib.bobmods.lib.tech.add_prerequisite(techBase, techRequired)
	paralib.EnsureExists("technology", techBase)
	paralib.EnsureExists("technology", techRequired)
	bobmods.lib.tech.add_prerequisite(techBase, techRequired)
end
function paralib.bobmods.lib.tech.replace_prerequisite(techBase, techOld, techNew)
	paralib.EnsureExists("technology", techBase)
	paralib.EnsureExists("technology", techOld)
	paralib.EnsureExists("technology", techNew)
	bobmods.lib.tech.replace_prerequisite(techBase, techOld, techNew)
end

function paralib.bobmods.lib.tech.remove_prerequisite(techBase, techRequired)
	paralib.EnsureExists("technology", techBase)
	paralib.EnsureExists("technology", techRequired)
	if not data.raw.technology[techBase] then
		return
	end
	local prereqExists = false
	for _, prereq in ipairs(data.raw.technology[techBase].prerequisites) do
		if prereq == techRequired then
			prereqExists = true
			break
		end
	end
	if not prereqExists then
		paralib.ProcessError("Required technology: " .. techRequired .. " not in prerequisites of tech: " .. techBase)
		return
	end
	bobmods.lib.tech.remove_prerequisite(techBase, techRequired)
end

function paralib.bobmods.lib.tech.add_recipe_unlock(tech, recipe)
	paralib.EnsureExists("technology", tech)
	paralib.EnsureExists("recipe", recipe)
	bobmods.lib.tech.add_recipe_unlock(tech, recipe)
end
function paralib.bobmods.lib.tech.remove_recipe_unlock(tech, recipe)
	paralib.EnsureExists("technology", tech)
	paralib.EnsureExists("recipe", recipe)
	bobmods.lib.tech.remove_recipe_unlock(tech, recipe)
end

function paralib.bobmods.lib.tech.hide(tech)
	paralib.EnsureExists("technology", tech)
	bobmods.lib.tech.hide(tech)
end

function paralib.bobmods.lib.tech.remove_science_pack(tech, pack)
	paralib.EnsureExists("technology", tech)
	paralib.EnsureExists("item", pack)
	bobmods.lib.tech.remove_science_pack(tech, pack)
end

function paralib.bobmods.lib.tech.set_science_packs(tech, packs)
	paralib.EnsureExists("technology", tech)
	bobmods.lib.tech.set_science_packs(tech, packs)
end

function paralib.bobmods.lib.tech.replace_science_pack(tech, packOld, packNew)
	paralib.EnsureExists("technology", tech)
	paralib.EnsureExists("item", packOld)
	paralib.EnsureExists("item", packNew)
	bobmods.lib.tech.replace_science_pack(tech, packOld, packNew)
end

-- ------------------------ --
-- RECIPE FUNCTION WRAPPERS --
-- ------------------------ --
function paralib.bobmods.lib.recipe.enabled(recipe, bool)
	paralib.EnsureExists("recipe", recipe)
	bobmods.lib.recipe.enabled(recipe, bool)
end

function paralib.bobmods.lib.recipe.hide(recipe)
	paralib.EnsureExists("recipe", recipe)
	bobmods.lib.recipe.hide(recipe)
end

function paralib.bobmods.lib.recipe.set_result(recipe, result)
	paralib.EnsureExists("recipe", recipe)
	paralib.EnsureResultExists(result)
	bobmods.lib.recipe.set_result(recipe, result)
end

function paralib.bobmods.lib.recipe.set_results(recipe, results)
	assert(bobmods.lib.recipe.set_results == nil, "Rewrite me to use bobmods.lib.recipe.set_results please!")
	paralib.EnsureExists("recipe", recipe)
	data.raw.recipe[recipe].results = results
end

function paralib.bobmods.lib.recipe.add_result(recipe, result)
	paralib.EnsureExists("recipe", recipe)
	paralib.EnsureResultExists(result)
	bobmods.lib.recipe.add_result(recipe, result)
end

function paralib.bobmods.lib.recipe.remove_result(recipe, result)
	paralib.EnsureExists("recipe", recipe)
	paralib.EnsureResultExists(result)
	bobmods.lib.recipe.remove_result(recipe, result)
end

function paralib.bobmods.lib.recipe.clear_ingredients(recipe)
	paralib.EnsureExists("recipe", recipe)
	bobmods.lib.recipe.clear_ingredients(recipe)
end

function paralib.bobmods.lib.recipe.add_ingredient(recipe, ingredient)
	paralib.EnsureExists("recipe", recipe)
	paralib.EnsureIngredientExists(ingredient)
	bobmods.lib.recipe.add_ingredient(recipe, ingredient)
end

function paralib.bobmods.lib.recipe.add_new_ingredient(recipe, ingredient)
	paralib.EnsureExists("recipe", recipe)
	paralib.EnsureIngredientExists(ingredient)
	bobmods.lib.recipe.add_new_ingredient(recipe, ingredient)
end

function paralib.bobmods.lib.recipe.remove_ingredient(recipe, ingredient)
	paralib.EnsureExists("recipe", recipe)
	paralib.EnsureType(ingredient, "string")
	bobmods.lib.recipe.remove_ingredient(recipe, ingredient)
end

function paralib.bobmods.lib.recipe.replace_ingredient(recipe, ingredientOld, ingredientNew)
	paralib.EnsureExists("recipe", recipe)
	paralib.EnsureIngredientExists(ingredientOld)
	paralib.EnsureType(ingredientNew, "string")
	bobmods.lib.recipe.replace_ingredient(recipe, ingredientOld, ingredientNew)
end

function paralib.bobmods.lib.recipe.set_ingredients(recipe, ingredients)
	paralib.EnsureExists("recipe", recipe)
	if not paralib.utils.IsArray(ingredients) then
		paralib.ProcessError("Ingredient expected to be array but it is not!")
	end
	for _, ingredient in ipairs(ingredients) do
		paralib.EnsureIngredientExists(ingredient)
	end
	bobmods.lib.recipe.set_ingredients(recipe, ingredients)
end

function paralib.bobmods.lib.recipe.set_ingredient(recipe, ingredient)
	paralib.EnsureExists("recipe", recipe)
	paralib.EnsureIngredientExists(ingredient)
	bobmods.lib.recipe.set_ingredient(recipe, ingredient)
end

function paralib.bobmods.lib.recipe.set_energy_required(recipe, time)
	paralib.EnsureExists("recipe", recipe)
	bobmods.lib.recipe.set_energy_required(recipe, time)
end

-- -------------- --
-- ANGELS LIBRARY --
-- -------------- --

paralib.angelsmods = paralib.angelsmods or {}
paralib.angelsmods.functions = paralib.angelsmods.functions or {}

function paralib.angelsmods.functions.allow_productivity(recipe)
	paralib.EnsureExists("recipe", recipe)
	angelsmods.functions.allow_productivity(recipe)
end
