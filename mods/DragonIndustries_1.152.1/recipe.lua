require "arrays"
require "items"
require "mathhelper"

function parseIngredient(entry, toFull)
	local type = entry.name and entry.name or entry[1]
	local amt = entry.amount and entry.amount or entry[2]
	local form = getItemType(type)
	return toFull and {name=type, amount=amt, type=form} or {type, amt, form}
end

function changeRecipeTime(recipe, factor, delta)
	if type(recipe) == "string" then recipe = data.raw.recipe[recipe] end
	if recipe.normal and recipe.normal.energy_required then
		recipe.normal.energy_required = roundToPlaces(recipe.normal.energy_required*factor+delta, -1)
		recipe.expensive.energy_required = roundToPlaces(recipe.expensive.energy_required*factor+delta, -1)
	else
		recipe.energy_required = roundToPlaces(recipe.energy_required*factor+delta, -1)
	end
end

---@param recipe table|string
---@param item string
function getRecipeCost(recipe, item)
	if type(recipe) == "string" then recipe = data.raw.recipe[recipe] end
	if recipe.normal and recipe.normal.ingredients then
		local norm = -1
		local exp = -1
		for _,ing in pairs(recipe.normal.ingredients) do
			local parse = parseIngredient(ing)
			if parse[1] == item then
				norm = parse[2]
				break
			end
		end
		for _,ing in pairs(recipe.expensive.ingredients) do
			local parse = parseIngredient(ing)
			if parse[1] == item then
				exp = parse[2]
				break
			end
		end
		return {norm, exp}
	elseif recipe.ingredients then
		for _,ing in pairs(recipe.ingredients) do
			local parse = parseIngredient(ing)
			if parse[1] == item then
				return parse[2]
			end
		end
	else
		log(serpent.block(recipe))
		error("Recipe '" .. recipe .. "' has no ingredients?!")
	end
end

function recipeStartsEnabled(recipe)
	if recipe.normal then
		return recipe.normal.enabled == nil or recipe.normal.enabled == true
	else
		return recipe.enabled == nil or recipe.enabled == true
	end
end

---@return string|table
function getRecipeOutput(recipe)
	if type(recipe) == "string" then recipe = data.raw.recipe[recipe] end
	if not recipe then error(serpent.block("No such recipe found!")) end
	if recipe.results then
		return recipe.results
	elseif recipe.result then
		return recipe.result
	end
	if recipe.normal then
		if recipe.normal.results then
			return recipe.normal.results
		elseif recipe.normal.result then
			return recipe.normal.result
		end
	end
	error("Recipe '" .. recipe.name .. "' has no output!")
end

---@param recipe table
---@param item string
---@return boolean
function recipeProduces(recipe, item)
	--log("Checking outputs of recipe '" .. recipe.name .. "' for '" .. item .. "'")
	local out = getRecipeOutput(recipe)
	--log(serpent.block(out))
	if type(out) == "table" then
		for _,e in pairs(out) do
			if listHasValue(e, item) then return true end
		end
		return false
	else
		return out == item
	end
end

function convertRecipeToResultTable(recipe)
	if recipe.result and not recipe.results then
		recipe.results = {{type = "item", name = recipe.result, amount = recipe.result_count}}
	end
	if recipe.normal and recipe.normal.result and not recipe.normal.results then
		recipe.normal.results = {{type = "item", name = recipe.normal.result, amount = recipe.normal.result_count}}
	end
	if recipe.expensive and recipe.expensive.result and not recipe.expensive.results then
		recipe.expensive.results = {{type = "item", name = recipe.expensive.result, amount = recipe.expensive.result_count}}
	end
end

function addRecipeProduct(recipe, item, amountnormal, amountexpensive, addIfPresent)
	if type(recipe) == "string" then recipe = data.raw.recipe[recipe] end
	if not recipe then error(serpent.block("No such recipe found!")) end
	convertRecipeToResultTable(recipe)
	if recipe.results then
		addIngredientToList(recipe.results, item, amountnormal, addIfPresent)
	end
	if recipe.normal and recipe.normal.results then
		addIngredientToList(recipe.normal.results, item, amountnormal, addIfPresent)
	end
	if recipe.expensive and recipe.expensive.results then
		local amt = amountexpensive and amountexpensive or amountnormal
		addIngredientToList(recipe.expensive.results, item, amt, addIfPresent)
	end
	if not recipe.icon and not recipe.icons then -- needs an icon when >1 output
		recipe.icons = {}
		
		local seek = data.raw.item[recipe.name]
		if not seek then seek = data.raw.fluid[recipe.name] end
		if seek then
			table.insert(recipe.icons, {icon = seek.icon, icon_size = seek.icon_size})
		else
			local li = recipe.results
			if not li and recipe.normal then li = recipe.normal.results end
			for _,ing in pairs(li) do
				if not ing.name then error("Found nil-named from: " .. serpent.block(li)) end
				local val = data.raw.item[ing.name]
				if not val then val = data.raw.fluid[ing.name] end
				if not val then error("Product " .. ing.name .. " not indexable?!") end
				table.insert(recipe.icons, {icon = val.icon, icon_size = val.icon_size})
			end
		end
		table.insert(recipe.icons, {icon = "__DragonIndustries__/graphics/multi-recipe.png", icon_size = 32})
	end
end

function turnRecipeIntoConversion(from, to)
	local tgt = data.raw.recipe[to]
	if not tgt then return end
	local rec = createConversionRecipe(from, to, false)
	tgt.ingredients = rec.ingredients
	if tgt.normal then tgt.normal.ingredients = rec.normal.ingredients end
	if tgt.expensive then tgt.expensive.ingredients = rec.expensive.ingredients end
end

function splitRecipeToNormalExpensive(recipe)
	recipe.normal = {
		enabled = recipe.enabled,
		ingredients = table.deepcopy(recipe.ingredients),
		results = recipe.results and table.deepcopy(recipe.results) or nil,
		result = recipe.result,
		energy_required = recipe.energy_required,
	}
	recipe.expensive = table.deepcopy(recipe.normal)
	
	recipe.ingredients = nil
	recipe.results = nil
	recipe.result = nil
	recipe.enabled = nil
	recipe.energy_required = nil
end

---@param list table
---@param item string
---@param amount number
---@param addIfPresent? boolean
---@param catalyst? boolean
function addIngredientToList(list, item, amount, addIfPresent, catalyst)
	local added = false
	local itype = type(item) == "table" and item.type or "item"
	local name = type(item) == "table" and item.name or item
	log("Inserting recipe item " .. itype .. "/" .. name .. " x " .. amount)
	for _,ing in pairs(list) do
		local parse = parseIngredient(ing, true)
		--log(serpent.block(parse))
		if parse.name == item then
			--log("Match")
			if addIfPresent then
				if ing.amount then
					ing.amount = parse.amount+amount
				else
					if ing.amount then
						ing.amount = parse.amount+amount
					else
						ing[2] = parse.amount+amount
					end
				end
				--log("Adding " .. amount .. " to " .. serpent.block(ing))
			end
			added = true
			break
		end
	end
	if not added then
		local add = {type = itype, name = name, amount = amount}
		if catalyst then add.catalyst = catalyst end
		table.insert(list, add)
	end
end

function changeIngredientInList(list, item, repl, ratio, skipError)
	for i = 1,#list do
		local ing = parseIngredient(list[i])
		--[[
		if ing[1] then
			log("Pos " .. i .. ": " .. ing[1] .. " x" .. ing[2] .. " for " .. item .. "->" .. repl)
		else
			log("Pos " .. i .. " is invalid!")
		end--]]
		--log("Comparing '" .. ing[1] .. "' and '" .. item .. "': " .. (ing[1] == item and "true" or "false"))
		if ing[1] == item then
			ing[1] = repl
			ing[2] = math.ceil(ing[2]*ratio)
			ing.name = repl
			ing.amount = ing[2]
			ing.type = ing[3]
			list[i] = ing
			return ing.amount
		end
	end
	if skipError then
		--log("No such item '" .. item .. "' in recipe!\n" .. debug.traceback())
		return 0
	else
		error("No such item '" .. item .. "' in recipe!\n" .. debug.traceback())
	end
end

function changeCountInList(list, item, delta, skipError)
	for i = #list,1,-1 do
		local ing = parseIngredient(list[i])
		--[[
		if ing[1] then
			log("Pos " .. i .. ": " .. ing[1] .. " x" .. ing[2] .. " for " .. item .. "->" .. repl)
		else
			log("Pos " .. i .. " is invalid!")
		end--]]
		--log("Comparing '" .. ing[1] .. "' and '" .. item .. "': " .. (ing[1] == item and "true" or "false"))
		if ing[1] == item then
			ing[2] = ing[2]+delta
			ing.name = item
			ing.amount = ing[2]
			ing.type = ing[3]
			ing = {name = ing.name, amount = ing.amount, type = ing.type}
			list[i] = ing
			if ing.amount <= 0 then
				table.remove(list, i)
				return 0
			else
				return ing.amount
			end
		end
	end
	if skipError then
		log("No such item '" .. item .. "' in recipe!\n" .. debug.traceback())
		return 0
	else
		error("No such item '" .. item .. "' in recipe!\n" .. debug.traceback())
	end
end

function replaceItemInRecipe(recipe, item, repl, ratio, skipError)
	if type(recipe) == "string" then recipe = data.raw.recipe[recipe] end
	if not recipe then error(serpent.block("No such recipe found! " .. debug.traceback())) end
	if type(ratio) == "table" and recipe.ingredients then
		splitRecipeToNormalExpensive(recipe)
	end
	local def, norm, exp = 0, 0, 0
	local ratn = type(ratio) == "table" and ratio[1] or ratio
	local rate = type(ratio) == "table" and ratio[2] or ratio
	if recipe.ingredients then
		def = changeIngredientInList(recipe.ingredients, item, repl, ratn, skipError)
	end
	if recipe.normal and recipe.normal.ingredients then
		norm = changeIngredientInList(recipe.normal.ingredients, item, repl, ratn, skipError)
	end
	if recipe.expensive and recipe.expensive.ingredients then
		exp = changeIngredientInList(recipe.expensive.ingredients, item, repl, rate, skipError)
	end
	log("Replaced item " .. item .. " with " .. repl .. " in recipe " .. recipe.name .. " with a ratio of " .. serpent.block(ratio) .. "x")
	return {def, norm, exp}
end

function changeItemCountInRecipe(recipe, item, delta, skipError)
	if type(recipe) == "string" then recipe = data.raw.recipe[recipe] end
	if not recipe then error(serpent.block("No such recipe found! " .. debug.traceback())) end
	local def, norm, exp = 0, 0, 0
	if recipe.ingredients then
		def = changeCountInList(recipe.ingredients, item, delta, skipError)
	end
	if recipe.normal and recipe.normal.ingredients then
		norm = changeCountInList(recipe.normal.ingredients, item, delta, skipError)
	end
	if recipe.expensive and recipe.expensive.ingredients then
		exp = changeCountInList(recipe.expensive.ingredients, item, delta, skipError)
	end
	log("Changed count of item " .. item .. " + " .. delta .. " in recipe " .. recipe.name)
	--log(serpent.block(recipe))
	return {def, norm, exp}
end

function removeItemFromRecipe(recipe, item)
	if type(recipe) == "string" then recipe = data.raw.recipe[recipe] end
	if not recipe then error(serpent.block("No such recipe found!")) end
	if recipe.ingredients then
		for i,ing in pairs(recipe.ingredients) do
			if ing[1] == item then
				table.remove(recipe.ingredients, i)
				break
			end
		end
	end
	if recipe.normal and recipe.normal.ingredients then
		for i,ing in pairs(recipe.normal.ingredients) do
			if ing[1] == item then
				table.remove(recipe.normal.ingredients, i)
				break
			end
		end
	end
	if recipe.expensive and recipe.expensive.ingredients then
		for i,ing in pairs(recipe.expensive.ingredients) do
			if ing[1] == item then
				table.remove(recipe.expensive.ingredients, i)
				break
			end
		end
	end
end

---@param recipe table|string
---@param item string
---@param amountnormal number
---@param amountexpensive? number
---@param addIfPresent? boolean
---@param catalyst? boolean
function addItemToRecipe(recipe, item, amountnormal, amountexpensive, addIfPresent, catalyst)
	if type(recipe) == "string" then recipe = data.raw.recipe[recipe] end
	if not recipe then error(serpent.block("No such recipe found!")) end
	if not item then error("Tried to add null item!") end
	local find = data.raw.item[item]
	if not find then find = data.raw.fluid[item] end
	if not find then error("No such item '" .. item .. "'!") end
	log("Adding '" .. find.name .. "' x" .. amountnormal .. " to recipe '" .. recipe.name .. "'")
	if recipe.ingredients then
		addIngredientToList(recipe.ingredients, find, amountnormal, addIfPresent, catalyst)
	end
	if recipe.normal and recipe.normal.ingredients then
		addIngredientToList(recipe.normal.ingredients, find, amountnormal, addIfPresent, catalyst)
	end
	if recipe.expensive and recipe.expensive.ingredients then
		local amt = amountexpensive and amountexpensive or amountnormal
		addIngredientToList(recipe.expensive.ingredients, find, amt, addIfPresent, catalyst)
	end
end

---@param recipe table|string
---@param item string
---@param recipeRef string|table
---@param ratio number
---@param addIfPresent? boolean
function addRecipeIngredientToRecipe(recipe, item, recipeRef, ratio, addIfPresent)
	local cost = getRecipeCost(recipeRef, item)
	if cost == nil then cost = 0 end
	if cost == 0 then cost = 1 end
	local amountnormal = type(cost) == "table" and cost[1] or cost
	local amountexpensive = type(cost) == "table" and cost[2] or cost
	addItemToRecipe(recipe, item, amountnormal*ratio, amountexpensive*ratio, addIfPresent)
end

function moveRecipe(recipe, from, to)
	local tech = data.raw.technology[from]
	local tech2 = data.raw.technology[to]
	if not tech then error("Tech '" .. from .. "' does not exist!") end
	if not tech2 then error("Tech '" .. to .. "' does not exist!") end
	local effects = {}
	for _,effect in pairs(tech.effects) do
		if effect.type == "unlock-recipe" and effect.recipe == recipe then
		
		else
			table.insert(effects, effect)
		end
	end
	tech.effects = effects
	for _,eff in pairs(tech2.effects) do
		if eff.type == "unlock-recipe" and eff.recipe == recipe then return end
	end
	table.insert(tech2.effects, {type = "unlock-recipe", recipe = recipe})
end

function lockRecipe(recipe, from)
	if type(recipe) == "string" then recipe = data.raw.recipe[recipe] end
	if not recipe then return end
	local tech = data.raw.technology[from]
	if not tech then error("Tech '" .. from .. "' does not exist!") end
	if not tech.effects then tech.effects = {} end
	table.insert(tech.effects, {type = "unlock-recipe", recipe = recipe.name})
	log("Putting recipe '" .. recipe.name .. "' behind tech '" .. tech.name .. "'")
	recipe.enabled = false
	if recipe.normal then
		recipe.normal.enabled = false
	end
	if recipe.expensive then
		recipe.expensive.enabled = false
	end
end

--returns nil if none, not {}
local function buildRecipeSurplus(name1, name2, list1, list2)
	local counts = {}
	local ret = nil
	for i = 1,#list1 do
		local ing = parseIngredient(list1[i])
		--log("Parsing input ingredient: " .. (ing[1] and ing[1] or "nil") .. " x " .. (ing[2] and ing[2] or "nil"))
		if #ing > 0 then
			--log(#ing .. " > " .. tostring(ing))
			counts[ing[1]] = (counts[ing[1]] and counts[ing[1]] or 0)+(ing[2] and ing[2] or 1) -- += in case recipe specifies an ingredient multiple times
		else
			log("Found empty entry in recipe " .. name1 .. "!")
		end
	end
	for i = 1,#list2 do
		local ing = parseIngredient(list2[i])
		--log("Parsing output ingredient: " .. (ing[1] and ing[1] or "nil") .. " x " .. (ing[2] and ing[2] or "nil"))
		if #ing > 0 then
			if counts[ing[1]] then
				counts[ing[1]] = counts[ing[1]]-ing[2]
			end
		else
			log("Found empty entry in recipe " .. name2 .. "!")
		end
	end
	for item,amt in pairs(counts) do
		if counts[item] > 0 and data.raw.item[item] then
			if not ret then ret = {} end
			ret[item] = amt
		end
	end
	return ret
end

--Supply nil for list1 to get a plain ingredient list for list2
local function buildRecipeDifference(name1, name2, list1, list2, form, recursion)

	if recursion then
		for i,ing in ipairs(list1) do
			--log(serpent.block(ing))
			if listHasValue(list2, ing[1]) and data.raw.recipe[ing[1]] then
				log("Recursing " .. ing[1])
				table.remove(list1, i)
				local list = form == "expensive" and data.raw.recipe[ing[1]].expensive.ingredients or ("normal" and data.raw.recipe[ing[1]].normal.ingredients or data.raw.recipe[ing[1]].ingredients)
				for _,e in pairs(buildRecipeDifference("", ing[1], nil, list)) do
					table.insert(list1, e)
					log("Adding " .. e[1])
				end
			end
		end
	end
	
	if not list2 then error(debug.traceback()) end
	
	local counts = {}
	local ret = {}
	if list1 then
		for i = 1,#list1 do
			local ing = parseIngredient(list1[i])
			--log("Parsing input ingredient: " .. (ing[1] and ing[1] or "nil") .. " x " .. (ing[2] and ing[2] or "nil"))
			if #ing > 0 and ing[1] then
				--log(#ing .. " > " .. tostring(ing))
				counts[ing[1]] = (counts[ing[1]] and counts[ing[1]] or 0)+(ing[2] and ing[2] or 1) -- += in case recipe specifies an ingredient multiple times
			else
				log("Found empty entry in recipe " .. name1 .. "!")
			end
		end
	end
	for i = 1,#list2 do
		local ing = parseIngredient(list2[i])
		--log("Parsing output ingredient: " .. (ing[1] and ing[1] or "nil") .. " x " .. (ing[2] and ing[2] or "nil"))
		if #ing > 0 and ing[1] then
			local amt = ing[2]-(counts[ing[1]] and counts[ing[1]] or 0)
			if amt > 0 then
				ret[#ret+1] = {ing[1], amt}
			end
		else
			log("Found empty entry in recipe " .. name2 .. "!")
		end
	end
	
	for i = #ret,1,-1 do
		local e = ret[i]
		if e == nil or e[1] == nil then
			log("Slot #" .. i .. " in the recipe difference between '" .. name1 .. "' and '" .. name2 .. "' was nil or nil-named!")
			table.remove(ret, i)
		end
	end
	
	return ret
end

---@param recipe table
local function createRecipeProfile(recipe)
    return
    {
      enabled = recipe.enabled,
      ingredients = table.deepcopy(recipe.ingredients),
      result = recipe.result,
      results = recipe.results and table.deepcopy(recipe.results) or nil,
    }
end

---@param recipe table|string
local function swapRecipeIO(recipe)
	if type(recipe) == "string" then recipe = data.raw.recipe[recipe] end
	if not recipe then return end
	local temp = table.deepcopy(recipe.ingredients)
	for _,e in pairs(temp) do
		if not e.name then
			e.name = e[1]
			e.amount = e[2]
			e.type = "item"
		end
	end
	local result = recipe.results
	if not result then
		result = {{type = "item", name = recipe.result, amount = recipe.result_count and recipe.result_count or 1}}
	end
	recipe.ingredients = table.deepcopy(result)
	recipe.results = temp
end

---@param recipe table
---@param ref table
function createUncraftingRecipe(recipe, ref)
	local ret = table.deepcopy(recipe)
	swapRecipeIO(ret)
	ret.name = recipe.name .. "-uncraft"
	ret.icons = {{icon = ref.icon, icon_size = ref.icon_size}, {icon = "__DragonIndustries__/graphics/icons/uncrafting_overlay.png", icon_size = 32}}
	ret.subgroup = ref.subgroup
	ret.allow_decomposition = false
	ret.allow_as_intermediate = false
	ret.allow_intermediates = false
	ret.localised_name = {"uncraft-recipe.name", {"entity-name." .. ref.name}}
	return ret
end

---@param from string|table
---@param to string|table
---@param register? boolean
---@param tech? string|table
---@param recursion? table
function createConversionRecipe(from, to, register, tech, recursion)
	local rec1 = type(from) == "table" and from or data.raw.recipe[from]
	local rec2 = type(to) == "table" and from or data.raw.recipe[to]
	if tech and type(tech) == "table" then tech = tech.name end
	
	if not rec1 then
		error("No such recipe '" .. from .. "'!")
	end
	if not rec2 then
		error("No such recipe '" .. to .. "'!")
	end
	
	rec1 = table.deepcopy(rec1)
	rec2 = table.deepcopy(rec2)
	
	local name = rec1.name .. "-conversion-to-" .. rec2.name
	
	if data.raw.recipe.name then
		error("Conversion recipe already exists: " .. name)
	else
		log("Creating conversion recipe " .. name)
		if recursion then
			log("Recursing ingredients " .. serpent.block(recursion))
		end
	end
	
	local list = nil
	local exp = nil
	local norm = nil
	
	local e_list = nil
	local e_exp = nil
	local e_norm = nil
	
	if rec1.normal and not rec2.normal then --harmonize the recipe styles
		rec2.normal = createRecipeProfile(rec2)
		rec2.expensive = createRecipeProfile(rec2)
	elseif rec2.normal and not rec1.normal then
		rec1.normal = createRecipeProfile(rec1)
		rec1.expensive = createRecipeProfile(rec1)
	end
	
	local prev = rec1.expensive and rec1.expensive.result or rec1.result
	if not prev then
		local list = rec1.results and rec1.results or rec1.expensive.results --[[@as table]]
		for _,res in pairs(list) do
			if res.type == "item" then
				prev = res.name
				break
			end
		end
	end
	
	if rec1.ingredients and rec2.ingredients then
		list = buildRecipeDifference(from, to, rec1.ingredients, rec2.ingredients, "basic", recursion)
		e_list = buildRecipeSurplus(from, to, rec1.ingredients, rec2.ingredients)
	end
	
	if rec1.expensive or rec2.expensive then
		local exp1 = rec1.expensive and rec1.expensive.ingredients or rec1.ingredients
		local exp2 = rec2.expensive and rec2.expensive.ingredients or rec2.ingredients
		exp = buildRecipeDifference(from, to, exp1, exp2, "expensive", recursion)
		e_exp = buildRecipeSurplus(from, to, exp1, exp2)
	end
	
	if rec1.normal or rec2.normal then
		local norm1 = rec1.normal and rec1.normal.ingredients or rec1.ingredients
		local norm2 = rec2.normal and rec2.normal.ingredients or rec2.ingredients
		norm = buildRecipeDifference(from, to, norm1, norm2, "normal", recursion)
		e_norm = buildRecipeSurplus(from, to, norm1, norm2)
	end
	
	if prev then
		if list then
			table.insert(list, {prev, rec1.result_count and rec1.result_count or 1})
		end
		if exp then
			table.insert(exp, {prev, rec1.expensive.result_count and rec1.expensive.result_count or 1})
		end
		if norm then
			table.insert(norm, {prev, rec1.normal.result_count and rec1.normal.result_count or 1})
		end
	end
	
	local ret = table.deepcopy(rec2)
	ret.name = name
	ret.ingredients = list
	local main = rec1.result and rec1.result or rec1.normal.result
	local result = rec2.result and rec2.result or rec2.normal.result
	
	if main == nil then
		local rec1results = rec1.results and rec1.results or rec1.normal.results
		if rec1results == nil then
			error("Recipe '" .. rec1.name .. "' has neither a result on the recipe nor its cost subrecipe!" .. serpent.block(rec1))
		end
		for _,ing in pairs(rec1results) do
			if ing.type == "item" then
				main = ing.name
				break
			end
		end
	end
	if result == nil then
		local rec2results = rec2.results and rec2.results or rec2.normal.results
		if rec2results == nil then
			error("Recipe '" .. rec1.name .. "' has neither a result on the recipe nor its cost subrecipe!" .. serpent.block(rec1))
		end
		for _,ing in pairs(rec2results) do
			if ing.type == "item" then
				result = ing.name
				break
			end
		end
	end
	
	if not main then
		error("Cannot create a conversion recipe from a recipe that has no output!" .. serpent.block(rec1))
	end	
	if not result then
		error("Cannot create a conversion recipe to a recipe that has no output!" .. serpent.block(rec2))
	end
	
	local out = getItemByName(result)
	
	if not out then
		error("Cannot create a conversion recipe to an item that does not exist!" .. serpent.block(rec2))
	end
	
	local itemType = out.type
	
	ret.localised_name = {"conversion-recipe.name", {"entity-name." .. main}, {"entity-name." .. result}}
	local orig_icon_src = rec2
	if (not (orig_icon_src.icon or orig_icon_src.icons)) and data.raw[itemType][result] then
		orig_icon_src = data.raw[itemType][result]
	end
	if not (orig_icon_src and (orig_icon_src.icon or orig_icon_src.icons)) then
		error("Could not find an icon for " .. rec2.name .. ", in either the recipe or its produced item! This item is invalid and would have crashed the game anyways!")
	end
	local ico = orig_icon_src.icon and orig_icon_src.icon or orig_icon_src.icons[1].icon
	local icosz = orig_icon_src.icon_size and orig_icon_src.icon_size or orig_icon_src.icons[1].icon_size
	ret.icons = {{icon = ico, icon_size = icosz}, {icon = "__DragonIndustries__/graphics/icons/conversion_overlay.png", icon_size = 32}}
	if not ret.icon then
		if data.raw[itemType][result] then
			ret.icon = data.raw[itemType][result].icon
		else
			log("Could not create icon for conversion recipe '" .. name .. "'! No such item '" .. result .. "'")
		end
	end
	if e_list then
		local out = ret.result
		if out == nil then
			for _,ing in pairs(ret.results) do
				if ing.type == "item" then
					out = ing.name
					break
				end
			end
		end
		ret.results = {{type = "item", name = out, amount = ret.result_count and ret.result_count or 1}}
		for type,count in pairs(e_list) do
			if not type then
				log("Found a nameless entry in a recipe result/ingredient list when generating a conversion recipe?")
			else
				table.insert(ret.results, {type = "item", name = type, amount = count})
			end
		end
		ret.result = nil
		ret.subgroup = data.raw[itemType][result].subgroup
	end
	if ret.normal then
		ret.normal.ingredients = norm
		if e_norm then
			local out = ret.normal.result
			if out == nil then
				for _,ing in pairs(ret.normal.results) do
					if ing.type == "item" then
						out = ing.name
						break
					end
				end
			end
			ret.normal.results = {{type = "item", name = out, amount = ret.normal.result_count and ret.normal.result_count or 1}}
			for type,count in pairs(e_norm) do
				if not type then
					log("Found a nameless entry in a recipe result/ingredient list when generating a conversion recipe?")
				else
					table.insert(ret.normal.results, {type = "item", name = type, amount = count})
				end
			end
			ret.normal.result = nil
			ret.subgroup = data.raw[itemType][result].subgroup
		end
	end
	if ret.expensive then
		ret.expensive.ingredients = exp
		if e_exp then
			local out = ret.expensive.result
			if out == nil then
				for _,ing in pairs(ret.expensive.results) do
					if ing.type == "item" then
						out = ing.name
						break
					end
				end
			end
			ret.expensive.results = {{type = "item", name = out, amount = ret.expensive.result_count and ret.expensive.result_count or 1}}
			for type,count in pairs(e_exp) do
				if not type then
					log("Found a nameless entry in a recipe result/ingredient list when generating a conversion recipe?")
				else
					table.insert(ret.expensive.results, {type = "item", name = type, amount = count})
				end
			end
			ret.expensive.result = nil
			ret.subgroup = data.raw[itemType][result].subgroup
		end
	end
	
	if data.raw.item["basic-circuit-board"] then
		replaceItemInRecipe(ret, "electronic-circuit", "basic-circuit-board", 1, true)
	end
	
	ret.allow_decomposition = false
	ret.allow_as_intermediate = false
	ret.allow_intermediates = false
	if ret.normal then
		ret.normal.allow_decomposition = false
		ret.normal.allow_as_intermediate = false
		ret.normal.allow_intermediates = false
	end
	if ret.expensive then
		ret.expensive.allow_decomposition = false
		ret.expensive.allow_as_intermediate = false
		ret.expensive.allow_intermediates = false
	end
	
	if ret.ingredients == nil and (ret.normal == nil or ret.normal.ingredients == nil) then error("Conversion recipe " .. ret.name .. " has no specified ingredients! Source recipes: " .. serpent.block(rec1) .. " , " .. serpent.block(rec2)) end
	if ret.ingredients then
		for _,ing in pairs(ret.ingredients) do
			if ing[2] == 0 then
				error("Conversion recipe " .. ret.name .. " has no 0-count ingredients! Source recipes: " .. serpent.block(rec1) .. " , " .. serpent.block(rec2))
			end
		end
	end
	if ret.normal and ret.normal.ingredients then
		for _,ing in pairs(ret.normal.ingredients) do
			if ing[2] == 0 then
				error("Conversion recipe " .. ret.name .. " has no 0-count ingredients! Source recipes: " .. serpent.block(rec1) .. " , " .. serpent.block(rec2))
			end
		end
	end
	
	if register then
		data:extend({ret})
		
		if tech then
			table.insert(data.raw.technology[tech].effects, {type = "unlock-recipe", recipe = name})
		end
	end
	
	--log(serpent.block(ret))
	
	return ret
end

function streamlineRecipeOutputWithRecipe(recipe, with, main, skipError)
	log("Streamlining '" .. recipe.name .. "' with recipe '" .. with .. "' for main item '" .. main .. "'")
	if not recipe.results then error("You can only output-streamline multi-output recipes!") end
	local stream = data.raw.recipe[with]
	if not stream then error("Recipe '" .. with .. "' does not exist!") end
	local extras = {}
	local extraAmt = {}
	local amt = -1
	for _,ing in pairs(recipe.results) do
		local parse = parseIngredient(ing)
		if parse[1] == main then
			amt = parse[2]
		else
			table.insert(extras, parse[1])
			extraAmt[parse[1]] = parse[2]
		end
	end
	log("Extras: " .. serpent.block(extraAmt))
	local need = stream.ingredients
	if not need and stream.normal then need = stream.normal.ingredients end
	if not need then error("Recipe '" .. with .. "' has no ingredients!") end
	log("Total needed: " .. serpent.block(need))
	need = table.deepcopy(need)
	for i=#need,1,-1 do
		local ing = need[i]
		local parse = parseIngredient(ing)
		if listHasValue(extras, parse[1]) then
			local ext = extraAmt[parse[1]]
			if parse[2] <= ext then
				log("Output contained sufficient extra. Removing from need.")
				table.remove(need, i)
				table.remove(recipe.results, i)
			else
				log("Output did not contain sufficient extra. Removing only " .. ext .. " from need of " .. parse[2] .. ".")
				extraAmt[parse[1]] = 0
				parse[2] = parse[2]-ext
				if ing.amount then
					ing.amount = parse[2]
					recipe.results[i].amount = ing.amount
				else
					ing[2] = parse[2]
					recipe.results[i][2] = ing[2]
				end
			end
		end
	end
	--log("Diff needed: " .. serpent.block(need))
	for _,ing in pairs(need) do
		local parse = parseIngredient(ing)
		local amt = parse[2]
		addItemToRecipe(recipe, parse[1], amt, amt, true)
	end
	changeItemCountInRecipe(recipe, with, -1, skipError)
	--log(serpent.block(recipe))
end

---@param item string|table
function markItemForProductivityAllowed(item)
	if type(item) == "string" then item = getItemByName(item) end
	if not item then error("No such item '" .. item .. "'") end
	log("Adding item '" .. item.name .. "' to the valid-with-productivity list")
	for name,recipe in pairs(data.raw.recipe) do
		if recipeProduces(recipe, item.name) then
			markForProductivityAllowed(recipe)
		end
	end
end

---@param recipe string|table
function markForProductivityAllowed(recipe)
	local arg = recipe
	if type(recipe) == "string" then recipe = data.raw.recipe[recipe] end
	if not recipe then error("No such recipe '" .. arg .. "'") end
	--if not recipe.allow_as_intermediate then log("Skipping productivity allowance on uncraft/upgrade recipe to prevent exploits: " .. recipe.name) return end
	for name,module in pairs(data.raw.module) do
		if module.effect and module.effect["productivity"] and module.limitation and getTableSize(module.limitation) > 0 then
			log("Adding recipe '" .. recipe.name .. "' to the valid-with-productivity list on '" .. name .. "'")
			table.insert(module.limitation, recipe.name)
		end
	end
end