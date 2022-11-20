------------------
---- data.lua ----
------------------

--[[##################################################################]]
--[[############################# HELPERS ############################]]

-- Returns item prototype
function OSM.lib.get_item_prototype(prototype_name, get_copy)
	for _, item in pairs(OSM.item_types) do
		if data.raw[item][prototype_name] then
			local item = data.raw[item][prototype_name]
			if get_copy then
				item = table.deepcopy(item)
			end
			return item
		end
	end
end

-- Returns fluid prototype
function OSM.lib.get_fluid_prototype(prototype_name, get_copy)
	if data.raw.fluid[prototype_name] then
		local fluid = data.raw.fluid[prototype_name]
		if get_copy then
			fluid = table.deepcopy(fluid)
		end
		return fluid
	end
end

-- Returns recipe prototype
function OSM.lib.get_recipe_prototype(prototype_name, get_copy)
	if data.raw.recipe[prototype_name] then
		local recipe = data.raw.recipe[prototype_name]
		if get_copy then
			recipe = table.deepcopy(recipe)
		end
		return recipe
	end
end

-- Returns entity prototype
function OSM.lib.get_entity_prototype(prototype_name, get_copy)
	for _, sub_type in pairs(OSM.entity_types) do
		if data.raw[sub_type][prototype_name] then
			local entity = data.raw[sub_type][prototype_name]
			if get_copy then
				entity = table.deepcopy(entity)
			end
			return entity
		end
	end
end

-- Returns technology prototype
function OSM.lib.get_technology_prototype(prototype_name, get_copy)
	if data.raw.technology[prototype_name] then
		local technology = data.raw.technology[prototype_name]
		if get_copy then
			technology = table.deepcopy(technology)
		end
		return data.raw.technology[prototype_name]
	end
end

-- Returns result prototype
function OSM.lib.get_result_prototype(prototype_name, get_copy)
	for _, item in pairs(OSM.item_types) do
		if data.raw[item][prototype_name] or data.raw.fluid[prototype_name] then
			local result = data.raw[item][prototype_name] or data.raw.fluid[prototype_name]
			if get_copy then
				result = table.deepcopy(result)
			end
			return result
		end
	end
end

-- Returns resource prototype
function OSM.lib.get_resource_prototype(prototype_name, get_copy)
	if data.raw.resource[prototype_name] then
		local resource = data.raw.resource[prototype_name]
		if get_copy then
			resource = table.deepcopy(resource)
		end
		return resource
	end
end

-- Returns ingredient prototype
function OSM.lib.get_ingredient_prototype(prototype_name, get_copy)
	for _, item in pairs(OSM.item_types) do
		if data.raw[item][prototype_name] or data.raw.fluid[prototype_name] then
			local ingredient = data.raw[item][prototype_name] or data.raw.fluid[prototype_name]
			if get_copy then
				ingredient = table.deepcopy(ingredient)
			end
			return ingredient
		end
	end
end

-- Returns main result prototype
function OSM.lib.get_main_result_prototype(recipe_name, get_copy)

	if not data.raw.recipe[recipe_name] then return end
	
	local recipe = data.raw.recipe[recipe_name]
	
	local recipe_difficulty = {recipe}
	
	if recipe.normal then table.insert(recipe_difficulty, recipe.normal) end
	if recipe.expensive then table.insert(recipe_difficulty, recipe.expensive) end
	
	for _, recipe in pairs(recipe_difficulty) do
		if recipe.results then
			for _, recipe_result in pairs(recipe.results) do

				recipe_result = recipe_result.name or recipe_result[1]
				recipe_result = OSM.lib.get_result_prototype(recipe_result)
				
				if not recipe_result then return end
				
				if get_copy then
					recipe_result = table.deepcopy(recipe_result)
				end

				if recipe.main_product and recipe.main_product == recipe_result.name then return recipe_result end
				if recipe.results[1] and not recipe.results[2] then return recipe_result end
			end
		elseif recipe.result then
			
			local recipe_result = OSM.lib.get_result_prototype(recipe.result)
			
			if recipe_result then
				if get_copy then
					recipe_result = table.deepcopy(recipe_result)
				end
				return recipe_result
			end
		end
	end
end

-- Returns boolean setting value
function OSM.lib.get_setting_boolean(setting_name)
	if settings.startup[setting_name] then
	
		local value = settings.startup[setting_name].value

		if type(value) == "boolean" then return value end
	end
end

--[[##################################################################]]
--[[############################# PROTOTYPE ##########################]]

-- Disable prototype [supports: entity, resource, recipe, item, fluid, technology (as single string or table array)]
function OSM.lib.disable_prototype(prototype_type, prototype_name)
	
	-- Data stage check
	if OSM.data_stage == 3 then error("Function: "..'"OSM.lib.disable_prototype"'.." MUST be called before final-fixes stage!") end

	-- Check if mod calling the function is declared
	if not OSM.mod or OSM.mod == {} then
		error("Mod name not specified")
	end

	-- Indexing function
	local function index_prototypes(prototype_type, prototype_name)
		
		local recipe = OSM.lib.get_recipe_prototype(prototype_name, true)
		local item = OSM.lib.get_item_prototype(prototype_name, true)
		local entity = OSM.lib.get_entity_prototype(prototype_name, true)
		local fluid = OSM.lib.get_fluid_prototype(prototype_name, true)
		local technology = OSM.lib.get_technology_prototype(prototype_name, true)
		local resource = OSM.lib.get_resource_prototype(prototype_name, true)
		
		if prototype_type == "all" then
			if entity then
				OSM.table.disabled_prototypes["entity"][entity.name] = {}
				OSM.table.disabled_prototypes["entity"][entity.name].name = entity.name
				OSM.table.disabled_prototypes["entity"][entity.name].mod_name = OSM.mod
				OSM.table.disabled_prototypes["entity"][entity.name].type = entity.type
			end
			if recipe then
				OSM.table.disabled_prototypes["recipe"][recipe.name] = {}
				OSM.table.disabled_prototypes["recipe"][recipe.name].name = recipe.name
				OSM.table.disabled_prototypes["recipe"][recipe.name].mod_name = OSM.mod
			end
			if item then
				OSM.table.disabled_prototypes["item"][item.name] = {}
				OSM.table.disabled_prototypes["item"][item.name].name = item.name
				OSM.table.disabled_prototypes["item"][item.name].mod_name = OSM.mod
				OSM.table.disabled_prototypes["item"][item.name].type = item.type
			end
			if fluid then
				OSM.table.disabled_prototypes["fluid"][fluid.name] = {}
				OSM.table.disabled_prototypes["fluid"][fluid.name].name = fluid.name
				OSM.table.disabled_prototypes["fluid"][fluid.name].mod_name = OSM.mod
			end
			if technology then
				OSM.table.disabled_prototypes["technology"][technology.name] = {}
				OSM.table.disabled_prototypes["technology"][technology.name].name = technology.name
				OSM.table.disabled_prototypes["technology"][technology.name].mod_name = OSM.mod
			end
		elseif prototype_type == "entity" then
			if entity then
				OSM.table.disabled_prototypes["entity"][entity.name] = {}
				OSM.table.disabled_prototypes["entity"][entity.name].name = entity.name
				OSM.table.disabled_prototypes["entity"][entity.name].mod_name = OSM.mod
				OSM.table.disabled_prototypes["entity"][entity.name].type = entity.type
			end
		elseif prototype_type == "recipe" then
			if recipe then
				OSM.table.disabled_prototypes["recipe"][recipe.name] = {}
				OSM.table.disabled_prototypes["recipe"][recipe.name].name = recipe.name
				OSM.table.disabled_prototypes["recipe"][recipe.name].mod_name = OSM.mod
			end
		elseif prototype_type == "item" then
			if item then
				OSM.table.disabled_prototypes["item"][item.name] = {}
				OSM.table.disabled_prototypes["item"][item.name].name = item.name
				OSM.table.disabled_prototypes["item"][item.name].mod_name = OSM.mod
				OSM.table.disabled_prototypes["item"][item.name].type = item.type
			end
		elseif prototype_type == "fluid" then
			if fluid then
				OSM.table.disabled_prototypes["fluid"][fluid.name] = {}
				OSM.table.disabled_prototypes["fluid"][fluid.name].name = fluid.name
				OSM.table.disabled_prototypes["fluid"][fluid.name].mod_name = OSM.mod
			end
		elseif prototype_type == "technology" then
			if technology then
				OSM.table.disabled_prototypes["technology"][technology.name] = {}
				OSM.table.disabled_prototypes["technology"][technology.name].name = technology.name
				OSM.table.disabled_prototypes["technology"][technology.name].mod_name = OSM.mod
			end
		elseif prototype_type == "technology-chain" then
			for _, upgrade in pairs(data.raw.technology) do
	
				local upgrade_name = upgrade.name
		
				local technology_level = tonumber(string.sub(prototype_name, -1))
				local upgrade_level = tonumber(string.sub(upgrade_name, -1))
				
				if type(technology_level) == "number" then prototype_name = string.sub(prototype_name, 1, #prototype_name-1) end
				if type(upgrade_level) == "number" then upgrade_name = string.sub(upgrade_name, 1, #upgrade_name-1) end
		
				if (prototype_name == upgrade_name) or (prototype_name.."-" == upgrade_name) then
					OSM.table.disabled_prototypes["technology"][upgrade.name] = {}
					OSM.table.disabled_prototypes["technology"][upgrade.name].name = upgrade.name
					OSM.table.disabled_prototypes["technology"][upgrade.name].mod_name = OSM.mod
				end
			end
		elseif prototype_type == "resource" then
			if resource then
				OSM.table.disabled_prototypes["resource"][resource.name] = {}
				OSM.table.disabled_prototypes["resource"][resource.name].name = resource.name
				OSM.table.disabled_prototypes["resource"][resource.name].mod_name = OSM.mod
			end
		else 
			error("Specified prototype type: "..prototype_type.." is not supported")
		end
	end

	-- Index prototypes
	if type(prototype_type) == "string" then
		index_prototypes(prototype_type, prototype_name)
	elseif type(prototype_type) == "table" then
		for _, sub_type in pairs(prototype_type) do
			index_prototypes(sub_type, prototype_name)
		end
	end
end

-- Enable prototype [overrides disable prototype, supports: entity, resource, recipe, item, fluid, technology and technology-chain (as single string or table array)]
function OSM.lib.enable_prototype(prototype_type, prototype_name)

	-- Data stage check
	if OSM.data_stage == 3 then error("Function: "..'"OSM.lib.enable_prototype"'.." MUST be called before final-fixes stage!") end

	-- Check if mod calling the function is declared
	if not OSM.mod or OSM.mod == {} then
		error("Mod name not specified")
	end

	-- Indexing function
	local function index_prototypes(prototype_type, prototype_name)
		
		local entity = OSM.lib.get_entity_prototype(prototype_name, true)
		local recipe = OSM.lib.get_recipe_prototype(prototype_name, true)
		local item = OSM.lib.get_item_prototype(prototype_name, true)
		local fluid = OSM.lib.get_fluid_prototype(prototype_name, true)
		local technology = OSM.lib.get_technology_prototype(prototype_name, true)
		local resource = OSM.lib.get_resource_prototype(prototype_name, true)
		
		if prototype_type == "all" then
			if entity then
				OSM.table.enabled_prototypes["entity"][entity.name] = {}
				OSM.table.enabled_prototypes["entity"][entity.name].name = entity.name
				OSM.table.enabled_prototypes["entity"][entity.name].mod_name = OSM.mod
				OSM.table.enabled_prototypes["entity"][entity.name].type = entity.type
			end
			if recipe then
				OSM.table.enabled_prototypes["recipe"][recipe.name] = {}
				OSM.table.enabled_prototypes["recipe"][recipe.name].name = recipe.name
				OSM.table.enabled_prototypes["recipe"][recipe.name].mod_name = OSM.mod
			end
			if item then
				OSM.table.enabled_prototypes["item"][item.name] = {}
				OSM.table.enabled_prototypes["item"][item.name].name = item.name
				OSM.table.enabled_prototypes["item"][item.name].mod_name = OSM.mod
				OSM.table.enabled_prototypes["item"][item.name].type = item.type
			end
			if fluid then
				OSM.table.enabled_prototypes["fluid"][fluid.name] = {}
				OSM.table.enabled_prototypes["fluid"][fluid.name].name = fluid.name
				OSM.table.enabled_prototypes["fluid"][fluid.name].mod_name = OSM.mod
			end
			if technology then
				OSM.table.enabled_prototypes["technology"][technology.name] = {}
				OSM.table.enabled_prototypes["technology"][technology.name].name = technology.name
				OSM.table.enabled_prototypes["technology"][technology.name].mod_name = OSM.mod
			end
		elseif prototype_type == "entity" then
			if entity then
				OSM.table.enabled_prototypes["entity"][entity.name] = {}
				OSM.table.enabled_prototypes["entity"][entity.name].name = entity.name
				OSM.table.enabled_prototypes["entity"][entity.name].mod_name = OSM.mod
				OSM.table.enabled_prototypes["entity"][entity.name].type = entity.type
			end
		elseif prototype_type == "recipe" then
			if recipe then
				OSM.table.enabled_prototypes["recipe"][recipe.name] = {}
				OSM.table.enabled_prototypes["recipe"][recipe.name].name = recipe.name
				OSM.table.enabled_prototypes["recipe"][recipe.name].mod_name = OSM.mod
			end
		elseif prototype_type == "item" then
			if item then
				OSM.table.enabled_prototypes["item"][item.name] = {}
				OSM.table.enabled_prototypes["item"][item.name].name = item.name
				OSM.table.enabled_prototypes["item"][item.name].mod_name = OSM.mod
				OSM.table.enabled_prototypes["item"][item.name].type = item.type
			end
		elseif prototype_type == "fluid" then
			if fluid then
				OSM.table.enabled_prototypes["fluid"][fluid.name] = {}
				OSM.table.enabled_prototypes["fluid"][fluid.name].name = fluid.name
				OSM.table.enabled_prototypes["fluid"][fluid.name].mod_name = OSM.mod
			end
		elseif prototype_type == "technology" then
			if technology then
				OSM.table.enabled_prototypes["technology"][technology.name] = {}
				OSM.table.enabled_prototypes["technology"][technology.name].name = technology.name
				OSM.table.enabled_prototypes["technology"][technology.name].mod_name = OSM.mod
			end
		elseif prototype_type == "technology-chain" then
			for _, upgrade in pairs(data.raw.technology) do
	
				local upgrade_name = upgrade.name
		
				local technology_level = tonumber(string.sub(prototype_name, -1))
				local upgrade_level = tonumber(string.sub(upgrade_name, -1))
				
				if type(technology_level) == "number" then prototype_name = string.sub(prototype_name, 1, #prototype_name-1) end
				if type(upgrade_level) == "number" then upgrade_name = string.sub(upgrade_name, 1, #upgrade_name-1) end
		
				if (prototype_name == upgrade_name) or (prototype_name.."-" == upgrade_name) then
					OSM.table.enabled_prototypes["technology"][upgrade.name] = {}
					OSM.table.enabled_prototypes["technology"][upgrade.name].name = upgrade.name
					OSM.table.enabled_prototypes["technology"][upgrade.name].mod_name = OSM.mod
				end
			end
		elseif prototype_type == "resource" then
			if resource then
				OSM.table.enabled_prototypes["resource"][resource.name] = {}
				OSM.table.enabled_prototypes["resource"][resource.name].name = resource.name
				OSM.table.enabled_prototypes["resource"][resource.name].mod_name = OSM.mod
			end
		else 
			error("Specified prototype type: "..prototype_type.." is not supported")
		end
	end

	-- Index prototypes
	if type(prototype_type) == "string" then
		index_prototypes(prototype_type, prototype_name)
	elseif type(prototype_type) == "table" then
		for _, sub_type in pairs(prototype_type) do
			index_prototypes(sub_type, prototype_name)
		end
	end
end

-- Assign subgroup to prototype [supports: entity, recipe, item, fluid] [order is optional]
function OSM.lib.prototype_assign_subgroup(prototype_type, prototype_name, subgroup_name, order)

	-- Entity regroup function
	local function regroup_entity(prototype_name)

		local entity = OSM.lib.get_entity_prototype(prototype_name)

		if entity and not entity.OSM_removed then
			entity.subgroup = subgroup_name
			if order then
				entity.order = order
			end
		end
	end

	-- Recipe regroup function
	local function regroup_recipe(prototype_name)
		
		local recipe = OSM.lib.get_recipe_prototype(prototype_name)
		
		if recipe and not recipe.OSM_removed then
			recipe.subgroup = subgroup_name
			if order then
				recipe.order = order
			end
		end
	end

	-- Item regroup function
	local function regroup_item(prototype_name)

		local item = OSM.lib.get_item_prototype(prototype_name)

		if item and not item.OSM_removed then
			item.subgroup = subgroup_name
			if order then
				item.order = order
			end
		end
	end

	-- Fluid regroup function
	local function regroup_fluid(prototype_name)
		
		local fluid = OSM.lib.get_fluid_prototype(prototype_name)
		
		if fluid and not fluid.OSM_removed then
			fluid.subgroup = subgroup_name
			if order then
				fluid.order = order
			end
		end
	end

	-- Regroup function
	local function regroup_prototypes(prototype_type, prototype_name, subgroup_name, order)
		if prototype_type == "all" then
			regroup_entity(prototype_name)
			regroup_recipe(prototype_name)
			regroup_item(prototype_name)
			regroup_fluid(prototype_name)
		elseif prototype_type == "entity" then
			regroup_entity(prototype_name)
		elseif prototype_type == "recipe" then
			regroup_recipe(prototype_name)
		elseif prototype_type == "item" then
			regroup_item(prototype_name)
		elseif prototype_type == "fluid" then
			regroup_fluid(prototype_name)
		else 
			error("Specified prototype type: "..prototype_type.." is not supported")
		end
	end

	-- Index prototypes
	if type(prototype_type) == "string" then
		regroup_prototypes(prototype_type, prototype_name)
	elseif type(prototype_type) == "table" then
		for _, indexed_type in pairs(prototype_type) do
			regroup_prototypes(indexed_type, prototype_name)
		end
	end
end

--[[##################################################################]]
--[[############################# RECIPE #############################]]

-- Add ingredient to recipe
function OSM.lib.recipe_add_ingredient(ingredient_name, ingredient_amount, recipe_name)

	if not OSM.mod or OSM.mod == {} then error("Mod name not specified") end

	local recipe = OSM.lib.get_recipe_prototype(recipe_name)
	local ingredient = OSM.lib.get_ingredient_prototype(ingredient_name, true)
	
	if not recipe then return end
	if not ingredient then return end
	
	local ingredient_type = ingredient.type

	if ingredient_type ~= "fluid" then ingredient_type = "item" end

	local recipe_difficulty = {recipe}

	if recipe.normal then table.insert(recipe_difficulty, recipe.normal) end
	if recipe.expensive then table.insert(recipe_difficulty, recipe.expensive) end

	for _, recipe in pairs(recipe_difficulty) do
		if recipe.ingredients then
			for _, dupe_ingredient in pairs(recipe.ingredients) do
				if dupe_ingredient == ingredient.name or ingredient[1] then return end
			end
			table.insert(recipe.ingredients, {type=ingredient_type, name=ingredient_name, amount=ingredient_amount})
			table.insert(OSM.log.recipe, '"'..OSM.mod..'"'..": Info: Added ingredient: ("..ingredient.type..") "..'"'..ingredient.name..'"'.." to recipe: "..'"'..recipe.name..'"')
		end
	end
end

-- Add result to recipe [result_amount as table supports: amount, amount_min, amount_max, probability]
function OSM.lib.recipe_add_result(result_name, result_amount, recipe_name)

	if not OSM.mod or OSM.mod == {} then error("Mod name not specified") end

	local result_amount_min = result_amount.amount_min or nil
	local result_amount_max = result_amount.amount_max or nil
	local result_probability = result_amount.probability or nil

	if type(result_amount) == "table" then result_amount = result_amount.amount end
	
	local recipe = OSM.lib.get_recipe_prototype(recipe_name)
	local result = OSM.lib.get_result_prototype(result_name, true)
	
	if not recipe then return end
	if not result then return end
	
	local result_type = result.type

	if result_type ~= "fluid" then result_type = "item" end

	local recipe_difficulty = {recipe}

	if recipe.normal then table.insert(recipe_difficulty, recipe.normal) end
	if recipe.expensive then table.insert(recipe_difficulty, recipe.expensive) end

	for _, recipe in pairs(recipe_difficulty) do
		if recipe.results then
			for _, dupe_result in pairs(recipe.results) do
				if dupe_result == result.name or result[1] then return end
			end
			table.insert(recipe.results, {type=result_type, name=result_name, amount=result_amount, amount_min=result_amount_min, amount_max=result_amount_max})
			table.insert(OSM.log.recipe, '"'..OSM.mod..'"'..": Info: Added result: ("..result.type..") "..'"'..result.name..'"'.." to recipe: "..'"'..recipe.name..'"')

		elseif recipe.result then
			
			local single_result = OSM.lib.get_result_prototype(recipe.result, true)
			
			recipe.results =
			{
				{type="item", name=single_result.name, amount=recipe.result_count or 1},
				{type=result_type, name=result_name, amount=result_amount, amount_min=result_amount_min, amount_max=result_amount_max}
			}

			recipe.result = nil
			recipe.result_count = nil
			recipe.main_product = single_result.name
			table.insert(OSM.log.recipe, '"'..OSM.mod..'"'..": Info: Added result: ("..result.type..") "..'"'..result.name..'"'.." to recipe: "..'"'..recipe.name..'"')
		end
	end
end

-- Remove ingredient from recipe [recipe_name is optional]
function OSM.lib.recipe_remove_ingredient(ingredient_name, recipe_name)

	if not OSM.mod or OSM.mod == {} then error("Mod name not specified") end

	local recipe = OSM.lib.get_recipe_prototype(recipe_name)
	local ingredient = OSM.lib.get_ingredient_prototype(ingredient_name, true)
	
	if OSM.debug_mode then
		if recipe_name and not recipe then 
			table.insert(OSM.log.errors, '"'..OSM.mod..'"'..": Warning: function: recipe_remove_ingredient() targeting missing prototype: "..'"'..recipe_name..'"'.." (recipe)")
		end

		if not ingredient then 
			table.insert(OSM.log.errors, '"'..OSM.mod..'"'..": Warning: function: recipe_remove_ingredient() targeting missing prototype: "..'"'..ingredient_name..'"'.." (target ingredient)")
		end
	end
	
	if not ingredient then return end

	local function remove_ingredient(recipe)
		if recipe.ingredients and recipe.ingredients[#recipe.ingredients] > 1 then
			for i, ingredient in pairs(recipe.ingredients) do
				if ingredient_name == ingredient.name or ingredient[1] then
					recipe.ingredients[i] = nil
					table.insert(OSM.log.recipe, '"'..OSM.mod..'"'..": Info: Removed ingredient: ("..ingredient.type..") "..'"'..ingredient.name..'"'.." from recipe: "..'"'..recipe.name..'"')
				end
			end
		end
	end
	
	if recipe_name and recipe then
		
		local recipe_difficulty = {recipe}

		if recipe.normal then table.insert(recipe_difficulty, recipe.normal) end
		if recipe.expensive then table.insert(recipe_difficulty, recipe.expensive) end
		
		for _, recipe in pairs(recipe_difficulty) do
			remove_ingredient(recipe)
		end
	
	elseif not recipe_name then
		for _, recipe in pairs(data.raw.recipe) do

			local recipe_difficulty = {recipe}

			if recipe.normal then table.insert(recipe_difficulty, recipe.normal) end
			if recipe.expensive then table.insert(recipe_difficulty, recipe.expensive) end
			
			for _, recipe in pairs(recipe_difficulty) do
				remove_ingredient(recipe)
			end
		end
	end
end

-- Remove result from recipe [recipe_name is optional]
function OSM.lib.recipe_remove_result(result_name, recipe_name)

	if not OSM.mod or OSM.mod == {} then error("Mod name not specified") end

	local recipe = OSM.lib.get_recipe_prototype(recipe_name)
	local result = OSM.lib.get_result_prototype(result_name, true)
	
	if OSM.debug_mode then
		if recipe_name and not recipe then 
			table.insert(OSM.log.errors, '"'..OSM.mod..'"'..": Warning: function: recipe_remove_result() targeting missing prototype: "..'"'..recipe_name..'"'.." (recipe)")
		end

		if not result then 
			table.insert(OSM.log.errors, '"'..OSM.mod..'"'..": Warning: function: recipe_remove_result() targeting missing prototype: "..'"'..result_name..'"'.." (target result)")
		end
	end
	
	if not result then return end

	local function remove_result(recipe)
		if recipe.results and recipe.results[#recipe.results] > 1 then
			for i, result in pairs(recipe.results) do
				if result_name == result.name or result[1] then
					recipe.results[i] = nil
					table.insert(OSM.log.recipe, '"'..OSM.mod..'"'..": Info: Removed result: ("..result.type..") "..'"'..result.name..'"'.." from recipe: "..'"'..recipe.name..'"')
				end
			end
	
		elseif (recipe.result and recipe.result == result_name and not recipe.results) or (recipe.results and recipe.results[#recipe.results] <= 1) then
			if OSM.debug_mode then
				table.insert(OSM.log.recipe, '"'..OSM.mod..'"'..": Warning: to remove single result: ("..result.type..") "..'"'..result.name..'"'.." from recipe: "..'"'..recipe_name..'"')
			end
		end
	end
	
	if recipe_name and recipe then
		
		local recipe_difficulty = {recipe}

		if recipe.normal then table.insert(recipe_difficulty, recipe.normal) end
		if recipe.expensive then table.insert(recipe_difficulty, recipe.expensive) end
		
		for _, recipe in pairs(recipe_difficulty) do
			remove_result(recipe)
		end
	
	elseif not recipe_name then
		for _, recipe in pairs(data.raw.recipe) do

			local recipe_difficulty = {recipe}

			if recipe.normal then table.insert(recipe_difficulty, recipe.normal) end
			if recipe.expensive then table.insert(recipe_difficulty, recipe.expensive) end
			
			for _, recipe in pairs(recipe_difficulty) do
				remove_result(recipe)
			end
		end
	end
end

-- Remove recipe from module limitation list
function OSM.lib.recipe_remove_module_limitation(recipe_name)
	for _, module in pairs(data.raw.module) do
		if module.limitation then
			for i, limitation in pairs(module.limitation) do
				if limitation == recipe_name then
					module.limitation[i] = nil
				end
			end
		end
	end
end

-- Replace ingredient in recipe [new_ingredient_args supports string or table array, recipe_name is optional]
function OSM.lib.recipe_replace_ingredient(old_ingredient_name, new_ingredient_args, recipe_name)

		-- Check if mod calling the function is declared
	if not OSM.mod or OSM.mod == {} then error("Mod name not specified") end
	
	-- Index prototypes
	local new_ingredient_name = false
	local new_ingredient_amount = false
	
	if type(new_ingredient_args) == "table" then
		new_ingredient_name = new_ingredient_args.name or new_ingredient_args[1]
		new_ingredient_amount = new_ingredient_args.amount or new_ingredient_args[2]
	elseif type(new_ingredient_args) == "string" then
		new_ingredient_name = new_ingredient_args
	end

	local recipe = OSM.lib.get_recipe_prototype(recipe_name)
	local new_ingredient = OSM.lib.get_ingredient_prototype(new_ingredient_name, true)
	local old_ingredient = OSM.lib.get_ingredient_prototype(old_ingredient_name, true)

	if OSM.debug_mode then
		if recipe_name and not data.raw.recipe[recipe_name] then 
			table.insert(OSM.log.errors, '"'..OSM.mod..'"'..": Warning: function: recipe_replace_ingredient() targeting missing prototype: "..'"'..recipe_name..'"'.." (recipe)")
		end

		if not old_ingredient then 
			table.insert(OSM.log.errors, '"'..OSM.mod..'"'..": Warning: function: recipe_replace_ingredient() targeting missing prototype: "..'"'..old_ingredient_name..'"'.." (old ingredient)")
		end
		
		if not new_ingredient then 
			table.insert(OSM.log.errors, '"'..OSM.mod..'"'..": Warning: function: recipe_replace_ingredient() targeting missing prototype: "..'"'..new_ingredient_name..'"'.." (new ingredient)")
		end
	end

	if not new_ingredient then return end
	if not old_ingredient then return end

	-- Scan ingredients
	local function replace_ingredient(recipe, recipe_name)

		if recipe.ingredients then
			for _, ingredient in pairs(recipe.ingredients) do
				if old_ingredient.name == (ingredient.name or ingredient[1]) then
	
					local old_ingredient_amount = ingredient.amount or ingredient[2]
					local duplicate_index = {}

					-- Check for duplicates
					for i, dupe_ingredient in pairs (recipe.ingredients) do
						if new_ingredient.name == (dupe_ingredient.name or dupe_ingredient[1]) then

							duplicate_index.amount = dupe_ingredient.amount or dupe_ingredient[2]
	
							recipe.ingredients[i] = nil
						end
					end

					if not ingredient.name then ingredient[1] = nil end
					if not ingredient.amount then ingredient[2] = nil end
					if new_ingredient.type ~= "fluid" then new_ingredient.type = "item" end
					
					ingredient.name = new_ingredient.name
					ingredient.type = new_ingredient.type
					ingredient.amount = new_ingredient_amount or old_ingredient_amount
					
					if duplicate_index.amount and ingredient.amount and not new_ingredient_amount then
						ingredient.amount = old_ingredient_amount+duplicate_index.amount
					end 
					
					table.insert(OSM.log.recipe, '"'..OSM.mod..'"'..": Info: Replaced ingredient: ("..old_ingredient.type..") "..'"'..old_ingredient.name..'"'.." with: ("..new_ingredient.type..") "..'"'..new_ingredient.name..'"'.." in recipe: "..'"'..recipe_name..'"')
				end
			end
		end
	end
	
	if recipe_name and recipe then

		local recipe_difficulty = {recipe}

		if recipe.normal then table.insert(recipe_difficulty, recipe.normal) end
		if recipe.expensive then table.insert(recipe_difficulty, recipe.expensive) end

		for _, recipe in pairs(recipe_difficulty) do
			replace_ingredient(recipe, recipe_name)
		end

	elseif not recipe_name then
		for _, recipe in pairs(data.raw.recipe) do
			
			local recipe_difficulty = {recipe}
			local recipe_name = recipe.name

			if recipe.normal then table.insert(recipe_difficulty, recipe.normal) end
			if recipe.expensive then table.insert(recipe_difficulty, recipe.expensive) end

			for _, recipe in pairs(recipe_difficulty) do
				replace_ingredient(recipe, recipe_name)
			end
		end
	end
end

-- Replace result in recipe [new_result_args supports string or table array, recipe_name is optional]
function OSM.lib.recipe_replace_result(old_result_name, new_result_args, recipe_name)

	if not OSM.mod or OSM.mod == {} then error("Mod name not specified") end

	-- Index prototypes
	local new_result_name = false
	local new_result_amount = false
	local new_result_amount_min = false
	local new_result_amount_max = false
	local new_result_probability = false
	
	if type(new_result_args) == "table" then
		new_result_name = new_result_args.name or new_result_args[1]
		new_result_amount = new_result_args.amount or new_result_args[2]
		if new_result_args.name then
			new_result_amount_min = new_result_args.amount_min
			new_result_amount_max = new_result_args.amount_max
			new_result_probability = new_result_args.probability
		end
	elseif type(new_result_args) == "string" then
		new_result_name = new_result_args
	end

	local recipe = OSM.lib.get_recipe_prototype(recipe_name)
	local new_result = OSM.lib.get_result_prototype(new_result_name, true)
	local old_result = OSM.lib.get_result_prototype(old_result_name, true)

	if OSM.debug_mode then
		if recipe_name and not recipe then 
			table.insert(OSM.log.errors, '"'..OSM.mod..'"'..": Warning: function: recipe_replace_result() targeting missing prototype: "..'"'..recipe_name..'"'.." (recipe)")
		end

		if not old_result then 
			table.insert(OSM.log.errors, '"'..OSM.mod..'"'..": Warning: function: recipe_replace_result() targeting missing prototype: "..'"'..old_result_name..'"'.." (old result)")
		end
		
		if not new_result then 
			table.insert(OSM.log.errors, '"'..OSM.mod..'"'..": Warning: function: recipe_replace_result() targeting missing prototype: "..'"'..new_result_name..'"'.." (new result)")
		end
	end
	
	if not new_result then return end
	if not old_result then return end

	local function replace_result(recipe, recipe_name)

		if recipe.results then
			for _, result in pairs(recipe.results) do
				if old_result.name == (result.name or result[1]) then

					local result_amount = result.amount or result[2]
					local duplicate_index = {}
					
					-- Check for duplicates
					for i, dupe_result in pairs (recipe.results) do
						if new_result.name == (dupe_result.name or dupe_result[1]) then

							duplicate_index.amount = dupe_result.amount or dupe_result[2]
							duplicate_index.amount_min = dupe_result.amount_min
							duplicate_index.amount_max = dupe_result.amount_max
							duplicate_index.probability = dupe_result.probability
	
							recipe.results[i] = nil
						end
					end

					if not result.name then result[1] = nil end
					if not result.amount then result[2] = nil end
					if new_result.type ~= "fluid" then new_result.type = "item" end
					
					result.name = new_result.name
					result.type = new_result.type
					result.amount = new_result_amount or result_amount
					result.amount_min = new_result_amount_min or result.amount_min
					result.amount_max = new_result_amount_max or result.amount_min
					result.probability = new_result_probability or result.probability
					
					
					if duplicate_index.amount and result.amount and not new_result_amount then
						result.amount = result.amount+duplicate_index.amount
					end 
					if duplicate_index.amount_min and result.amount_min and not new_result_amount_min then
						result.amount_min = math.floor((result.amount_min+duplicate_index.amount_min)/2-0.5)
					end
					if duplicate_index.amount_max and result.amount_max and not new_result_amount_max then
						result.amount_max = math.floor((result.amount_max+duplicate_index.amount_max)/2-0.5)
					end	
					if duplicate_index.probability and result.probability and not new_result_probability then
						result.probability = math.floor((result.probability+duplicate_index.probability)/2-0.5)
					end
					if duplicate_index.temperature and result.temperature then
						result.temperature = duplicate_index.temperature
					end
					
					table.insert(OSM.log.recipe, '"'..OSM.mod..'"'..": Info: Replaced result: ("..old_result.type..") "..'"'..old_result.name..'"'.." with: ("..new_result.type..") "..'"'..new_result.name..'"'.." in recipe: "..'"'..recipe_name..'"')
				end
				
				-- Check if replaced product is main_product
				if recipe.main_product and recipe.main_product == old_result.name then
					recipe.main_product = new_result.name
				end
			end
		end

		if recipe.result and recipe.result == old_result.name then
			recipe.result = new_result.name
			table.insert(OSM.log.recipe, '"'..OSM.mod..'"'..": Info: Replaced result: ("..old_result.type..") "..'"'..old_result.name..'"'.." with: ("..new_result.type..") "..'"'..new_result.name..'"'.." in recipe: "..'"'..recipe_name..'"')
		end
	end

	if recipe_name and recipe then

		local recipe_difficulty = {recipe}

		if recipe.normal then table.insert(recipe_difficulty, recipe.normal) end
		if recipe.expensive then table.insert(recipe_difficulty, recipe.expensive) end

		for _, recipe in pairs(recipe_difficulty) do
			replace_result(recipe, recipe_name)
		end

	elseif not recipe_name then
		for _, recipe in pairs(data.raw.recipe) do

			local recipe_difficulty = {recipe}
			local recipe_name = recipe.name

			if recipe.normal then table.insert(recipe_difficulty, recipe.normal) end
			if recipe.expensive then table.insert(recipe_difficulty, recipe.expensive) end

			for _, recipe in pairs(recipe_difficulty) do
				replace_result(recipe, recipe_name)
			end
		end
	end
end

--[[##################################################################]]
--[[############################# TECHNOLOGY #########################]]

-- Add recipe unlock
function OSM.lib.technology_add_unlock(recipe_name, technology_name)

	if not OSM.mod or OSM.mod == {} then error("Mod name not specified") end
	
	local technology = OSM.lib.get_technology_prototype(technology_name)
	local recipe = OSM.lib.get_recipe_prototype(recipe_name, true)
	
	if OSM.debug_mode then
		if technology_name and not technology then
			table.insert(OSM.log.errors, '"'..OSM.mod..'"'..": Warning: function: technology_add_unlock() targeting missing prototype: "..'"'..technology_name..'"'.." (technology)")
			return
		end

		if not recipe then 
			table.insert(OSM.log.errors, '"'..OSM.mod..'"'..": Warning: function: technology_add_unlock() targeting missing prototype: "..'"'..recipe_name..'"'.." (recipe)")
		end
	end

	if not recipe then return end

	if technology and technology.effects then
		for _, dupe_effect in pairs(technology.effects) do
			if dupe_effect.type == "unlock-recipe" and dupe_effect.recipe == recipe.name then return end
		end
		table.insert(technology.effects, {type = "unlock-recipe", recipe = recipe.name})
		table.insert(OSM.log.technology, '"'..OSM.mod..'"'..": Info: Added recipe unlock: "..'"'..recipe.name..'"'.." to technology: "..'"'..technology.name..'"')

	elseif technology and not technology.effects then
		technology.effects = {{type = "unlock-recipe", recipe = recipe.name}}
		table.insert(OSM.log.technology, '"'..OSM.mod..'"'..": Info: Added recipe unlock: "..'"'..recipe.name..'"'.." to technology: "..'"'..technology.name..'"')
	end
end

-- Add prerequisite
function OSM.lib.technology_add_prerequisite(prerequisite_name, technology_name)
	
	if not OSM.mod or OSM.mod == {} then error("Mod name not specified") end
	
	local technology = OSM.lib.get_technology_prototype(technology_name)
	local prerequisite = OSM.lib.get_technology_prototype(prerequisite_name, true)
	
	if OSM.debug_mode then
		if not technology then
			table.insert(OSM.log.errors, '"'..OSM.mod..'"'..": Warning: function: technology_add_prerequisite() targeting missing prototype: "..'"'..technology_name..'"'.." (technology)")
		end

		if not prerequisite then
			table.insert(OSM.log.errors, '"'..OSM.mod..'"'..": Warning: function: technology_add_prerequisite() targeting missing prototype: "..'"'..prerequisite_name..'"'.." (new prerequisite)")
		end
	end

	if not prerequisite then return end
	
	if technology and technology.prerequisites then
		for _, dupe_prerequisite in pairs(technology.prerequisites) do
			if dupe_prerequisite == prerequisite.name then return end
		end
		table.insert(technology.prerequisites, prerequisite.name)
		table.insert(OSM.log.technology, '"'..OSM.mod..'"'..": Info: Added prerequisite: "..'"'..prerequisite.name..'"'.." to technology: "..'"'..technology.name..'"')

	elseif technology and not technology.prerequisites then
		technology.prerequisites = {prerequisite.name}
		table.insert(OSM.log.technology, '"'..OSM.mod..'"'..": Info: Added prerequisite: "..'"'..prerequisite.name..'"'.." to technology: "..'"'..technology.name..'"')
	end
end

-- Remove recipe unlock [technology_name is optional]
function OSM.lib.technology_remove_unlock(recipe_name, technology_name)

	if not OSM.mod or OSM.mod == {} then error("Mod name not specified") end
	
	local technology = OSM.lib.get_technology_prototype(technology_name)
	local recipe = OSM.lib.get_recipe_prototype(recipe_name, true)
	
	if OSM.debug_mode then
		if technology_name and not technology then
			table.insert(OSM.log.errors, '"'..OSM.mod..'"'..": Warning: function: technology_remove_unlock() targeting missing prototype: "..'"'..technology_name..'"'.." (technology)")
		end

		if not recipe then 
			table.insert(OSM.log.errors, '"'..OSM.mod..'"'..": Warning: function: technology_remove_unlock() targeting missing prototype: "..'"'..recipe_name..'"'.." (recipe)")
			return
		end
	end

	if not recipe then return end
	
	local function remove_unlock(technology)
		for i, effect in pairs(technology.effects) do
			if effect.type == "unlock-recipe" and effect.recipe == recipe_name then
				technology.effects[i] = nil
				table.insert(OSM.log.technology, '"'..OSM.mod..'"'..": Info: Removed unlock of recipe: "..'"'..recipe.name..'"'.." from technology: "..'"'..technology.name..'"')
			end
		end
	end

	if technology_name and technology and technology.effects then
		remove_unlock(technology)
	
	elseif not technology_name then
		for _, technology in pairs(data.raw.technology) do
			if technology.effects then
				remove_unlock(technology)
			end
		end
	end
end

-- Remove prerequisite [technology_name is optional]
function OSM.lib.technology_remove_prerequisite(prerequisite_name, technology_name)

	if not OSM.mod or OSM.mod == {} then error("Mod name not specified") end
	
	local technology = OSM.lib.get_technology_prototype(technology_name)
	local prerequisite = OSM.lib.get_technology_prototype(prerequisite_name, true)
	
	if OSM.debug_mode then
		if technology_name and not technology then
			table.insert(OSM.log.errors, '"'..OSM.mod..'"'..": Warning: function: technology_remove_prerequisite() targeting missing prototype: "..'"'..technology_name..'"'.." (technology)")
			return
		end

		if not prerequisite then
			table.insert(OSM.log.errors, '"'..OSM.mod..'"'..": Warning: function: technology_remove_prerequisite() targeting missing prototype: "..'"'..prerequisite_name..'"'.." (prerequisite)")
			return
		end
	end

	local function remove_prerequisite(technology)
		for i, prerequisite in pairs (technology.prerequisites) do
			if prerequisite == prerequisite_name then
				technology.prerequisites[i] = nil
				table.insert(OSM.log.technology, '"'..OSM.mod..'"'..": Info: Removed prerequisite: "..'"'..prerequisite.name..'"'.." from technology: "..'"'..technology.name..'"')
			end
		end
	end

	if technology_name and technology and technology.prerequisites then
		if technology.prerequisites then
			remove_prerequisite(technology)
		end

	elseif not technology_name then
		for _, technology in pairs(data.raw.technology) do
			if technology.prerequisites then
				remove_prerequisite(technology)	
			end
		end
	end
end

-- Replace recipe unlock [technology_name is optional]
function OSM.lib.technology_replace_unlock(old_recipe_name, new_recipe_name, technology_name)

	if not OSM.mod or OSM.mod == {} then error("Mod name not specified") end

	local technology = OSM.lib.get_technology_prototype(technology_name)
	local old_recipe = OSM.lib.get_recipe_prototype(old_recipe_name, true)
	local new_recipe = OSM.lib.get_recipe_prototype(new_recipe_name, true)

	if OSM.debug_mode then
		if technology_name and not technology then
			table.insert(OSM.log.errors, '"'..OSM.mod..'"'..": Warning: function: technology_replace_unlock() targeting missing prototype: "..'"'..technology_name..'"'.." (technology)")
			return
		end
	
		if not old_recipe then
			table.insert(OSM.log.errors, '"'..OSM.mod..'"'..": Warning: function: technology_replace_unlock() targeting missing prototype: "..'"'..old_recipe_name..'"'.." (old recipe)")
			return
		end
	
		if not new_recipe then
			table.insert(OSM.log.errors, '"'..OSM.mod..'"'..": Warning: function: technology_replace_unlock() targeting missing prototype: "..'"'..new_recipe_name..'"'.." (new recipe)")
			return
		end
	end

	if not old_recipe then return end
	if not new_recipe then return end
	
	local function replace_unlock(technology)
		for i, effect in pairs(technology.effects) do
			if effect.type == "unlock-recipe" and effect.recipe == old_recipe.name then
				for k, dupe_effect in pairs(technology.effects) do
					if dupe_effect.type == "unlock-recipe" and dupe_effect.recipe == new_recipe.name then
						technology.effects[k] = nil
					end
				end
				technology.effects[i].recipe = new_recipe.name
				table.insert(OSM.log.technology, '"'..OSM.mod..'"'..": Info: Replaced unlock of recipe: "..'"'..old_recipe.name..'"'.." with: "..'"'..new_recipe.name..'"'.." in technology: "..'"'..technology.name..'"')
			end
		end
	end

	if technology_name and technology and technology.effects then
		replace_unlock(technology)

	elseif not technology_name then
		for _, technology in pairs(data.raw.technology) do
			if technology.effects then
				replace_unlock(technology)
			end
		end
	end
end

-- Replace prerequisite [technology_name is optional]
function OSM.lib.technology_replace_prerequisite(old_prerequisite_name, new_prerequisite_name, technology_name)

	if not OSM.mod or OSM.mod == {} then error("Mod name not specified") end
	
	local technology = OSM.lib.get_technology_prototype(technology_name)
	local old_prerequisite = OSM.lib.get_technology_prototype(old_prerequisite_name, true)
	local new_prerequisite = OSM.lib.get_technology_prototype(new_prerequisite_name, true)

	if OSM.debug_mode then
		if technology_name and not technology then
			table.insert(OSM.log.errors, '"'..OSM.mod..'"'..": Warning: function: technology_replace_prerequisite() targeting missing prototype: "..'"'..technology_name..'"'.." (technology)")
			return
		end
	
		if not old_prerequisite then
			table.insert(OSM.log.errors, '"'..OSM.mod..'"'..": Warning: function: technology_replace_prerequisite() targeting missing prototype: "..'"'..old_prerequisite_name..'"'.." (old prerequisite)")
			return
		end
	
		if not new_prerequisite then
			table.insert(OSM.log.errors, '"'..OSM.mod..'"'..": Warning: function: technology_replace_prerequisite() targeting missing prototype: "..'"'..new_prerequisite_name..'"'.." (new prerequisite)")
			return
		end
	end

	if not old_prerequisite then return end
	if not new_prerequisite then return end

	local function replace_prerequisite(technology)
		for i, prerequisite in pairs(technology.prerequisites) do
			if prerequisite == old_prerequisite.name then
				for k, dupe_prerequisite in pairs(technology.prerequisites) do
					if dupe_prerequisite == new_prerequisite.name then
						technology.prerequisites[k] = nil
					end
				end
				technology.prerequisites[i] = new_prerequisite.name
				table.insert(OSM.log.technology, '"'..OSM.mod..'"'..": Info: Replaced prerequisite: "..'"'..old_prerequisite.name..'"'.." with: "..'"'..new_prerequisite.name..'"'.." in technology: "..'"'..technology.name..'"')
			end
		end
	end

	if technology_name and technology and technology.prerequisites then
		replace_prerequisite(technology)
	
	elseif not technology_name then
		for _, technology in pairs(data.raw.technology) do
			if technology.prerequisites then
				replace_prerequisite(technology)
			end
		end
	end
end

-- Replace technology science pack [technology_name is optional]
function OSM.lib.technology_replace_science_pack(old_pack_name, new_pack_args, technology_name)

	if not OSM.mod or OSM.mod == {} then error("Mod name not specified") end
	
	-- Index prototypes
	local new_pack_name = false
	local new_pack_amount = false
	
	if type(new_pack_args) == "table" then
		new_pack_name = new_pack_args.name or new_pack_args[1]
		new_pack_amount = new_pack_args.amount or new_pack_args[2]
	elseif type(new_pack_args) == "string" then
		new_pack_name = new_pack_args
	end

	local technology = OSM.lib.get_technology_prototype(technology_name)
	local old_pack = OSM.lib.get_item_prototype(old_pack_name, true)
	local new_pack = OSM.lib.get_item_prototype(new_pack_name, true)

	if OSM.debug_mode then
		if technology_name and not technology then 
			table.insert(OSM.log.errors, '"'..OSM.mod..'"'..": Warning: function: technology_replace_science_pack() targeting missing prototype: "..'"'..technology_name..'"'.." (technology)")
		end

		if not old_pack then 
			table.insert(OSM.log.errors, '"'..OSM.mod..'"'..": Warning: function: technology_replace_science_pack() targeting missing prototype: "..'"'..old_pack_name..'"'.." (old science pack)")
		end
		
		if not new_pack then 
			table.insert(OSM.log.errors, '"'..OSM.mod..'"'..": Warning: function: technology_replace_science_pack() targeting missing prototype: "..'"'..new_pack_name..'"'.." (new science pack)")
		end
	end
	
	if not old_pack then return end
	if not new_pack then return end

	local function replace_science_pack(technology)
		
		for _, pack in pairs(technology.unit.ingredients) do
			if old_pack.name == (pack.name or pack[1]) then

				local pack_amount = pack.amount or pack[2]
				local duplicate_index = {}
				
				-- Check for duplicates
				for i, dupe_pack in pairs (technology.unit.ingredients) do
					if new_pack.name == (dupe_pack.name or dupe_pack[1]) then

						duplicate_index.amount = dupe_pack.amount or dupe_pack[2]

						technology.unit.ingredients[i] = nil
					end
				end

				if not pack.name then pack[1] = nil end
				if not pack.amount then pack[2] = nil end
				if new_pack.type ~= "fluid" then new_pack.type = "item" end
				
				pack.name = new_pack.name
				pack.type = new_pack.type
				pack.amount = new_pack_amount or pack_amount
				
				if duplicate_index.amount and pack.amount and not new_pack_amount then
					pack.amount = pack.amount+duplicate_index.amount
				end
				table.insert(OSM.log.technology, '"'..OSM.mod..'"'..": Info: Replaced science pack: ("..old_pack.type..") "..'"'..old_pack.name..'"'.." with: ("..new_pack.type..") "..'"'..new_pack.name..'"'.." in recipe: "..'"'..technology.name..'"')
			end
		end
	end

	if technology_name and technology.unit and technology.unit.ingredients then
		replace_science_pack(technology)
	
	elseif not technology_name then
		for _, technology in pairs(data.raw.technology) do
			if technology.unit and technology.unit.ingredients then
				replace_science_pack(technology)
			end
		end
	end
end

--[[##################################################################]]
--[[############################ RESOURCE ############################]]

-- Replace resource result [resource_name is optional]
function OSM.lib.resource_add_result(result_name, result_amount, resource_name)

	if not OSM.mod or OSM.mod == {} then error("Mod name not specified") end

	local resource = OSM.lib.get_resource_prototype(resource_name)
	local new_result = OSM.lib.get_result_prototype(new_result_name, true)
	
	if OSM.debug_mode then
		if resource_name and not resource then 
			table.insert(OSM.log.errors, '"'..OSM.mod..'"'..": Warning: function: resource_add_result() targeting missing prototype: "..'"'..resource_name..'"'.." (resource)")
		end
		
		if not new_result then 
			table.insert(OSM.log.errors, '"'..OSM.mod..'"'..": Warning: function: resource_add_result() targeting missing prototype: "..'"'..new_result_name..'"'.." (new result)")
		end
	end
	
	if not resource.minable then return end
	if not new_result then return end
	
	local function replace_result(resource)

		if resource.minable.results then
			for _, result in pairs(resource.minable.results) do
				if old_result.name == (result.name or result[1]) then
				
					local result_type = new_result.type
					local result_amount = result.amount or result[2]
					local duplicate_index = {}

					if result_type ~= "fluid" then result_type = "item" end
					
					-- Check for duplicates
					for i, dupe_result in pairs (resource.minable.results) do
						if new_result.name == (dupe_result.name or dupe_result[1]) then

							duplicate_index.amount = dupe_result.amount or dupe_result[2]
							duplicate_index.amount_min = dupe_result.amount_min
							duplicate_index.amount_max = dupe_result.amount_max
							duplicate_index.probability = dupe_result.probability
	
							results[i] = nil
						end
					end

					if not result.name then result[1] = nil end
					if not result.amount then result[2] = nil end
					
					result.name = new_result.name
					result.type = result_type
					result.amount = result_amount
					
					if duplicate_index.amount and result.amount then
						result.amount = result.amount+duplicate_index.amount
					end 
					if duplicate_index.amount_min and result.amount_min then
						result.amount_min = math.floor((result.amount_min+duplicate_index.amount_min)/2-0.5)
					end		
					if duplicate_index.amount_max and result.amount_max then
						result.amount_max = math.floor((result.amount_max+duplicate_index.amount_max)/2-0.5)
					end				
					if duplicate_index.probability and result.probability then
						result.probability = math.floor((result.probability+duplicate_index.probability)/2-0.5)
					end
					if duplicate_index.temperature and result.temperature then
						result.probability = math.floor((result.probability+duplicate_index.probability)/2-0.5)
					end
					
					table.insert(OSM.log.resource, '"'..OSM.mod..'"'..": Info: Replaced result: ("..old_result.type..") "..'"'..old_result.name..'"'.." with: ("..new_result.type..") "..'"'..new_result.name..'"'.." in resource: "..'"'..resource.name..'"')
				end
			end
		end

		if resource.minable.result and resource.minable.result.name == old_result.name then
			resource.minable.result.name = new_result.name
			table.insert(OSM.log.resource, '"'..OSM.mod..'"'..": Info: Replaced result: ("..old_result.type..") "..'"'..old_result.name..'"'.." with: ("..new_result.type..") "..'"'..new_result.name..'"'.." in resource: "..'"'..resource.name..'"')
		end

	end
	
	if resource_name and resource then
		replace_result(resource)

	elseif not resource_name then
		for _, resource in pairs(data.raw.resource) do
			replace_result(resource)
		end
	end
end

-- Replace resource result [resource_name is optional]
function OSM.lib.resource_replace_result(old_result_name, new_result_name, resource_name)

	if not OSM.mod or OSM.mod == {} then error("Mod name not specified") end

	local resource = OSM.lib.get_resource_prototype(resource_name)
	local new_result = OSM.lib.get_result_prototype(new_result_name, true)
	local old_result = OSM.lib.get_result_prototype(old_result_name, true)
	
	if OSM.debug_mode then
		if resource_name and not resource then 
			table.insert(OSM.log.errors, '"'..OSM.mod..'"'..": Warning: function: resource_replace_result() targeting missing prototype: "..'"'..resource_name..'"'.." (resource)")
		end

		if not old_result then 
			table.insert(OSM.log.errors, '"'..OSM.mod..'"'..": Warning: function: resource_replace_result() targeting missing prototype: "..'"'..old_result_name..'"'.." (old result)")
		end
		
		if not new_result then 
			table.insert(OSM.log.errors, '"'..OSM.mod..'"'..": Warning: function: resource_replace_result() targeting missing prototype: "..'"'..new_result_name..'"'.." (new result)")
		end
	end
	
	if not resource.minable then return end
	if not new_result then return end
	if not old_result then return end
	
	local function replace_result(resource)

		if resource.minable.results then
			for _, result in pairs(resource.minable.results) do
				if old_result.name == (result.name or result[1]) then
				
					local result_type = new_result.type
					local result_amount = result.amount or result[2]
					local duplicate_index = {}

					if result_type ~= "fluid" then result_type = "item" end
					
					-- Check for duplicates
					for i, dupe_result in pairs (resource.minable.results) do
						if new_result.name == (dupe_result.name or dupe_result[1]) then

							duplicate_index.amount = dupe_result.amount or dupe_result[2]
							duplicate_index.amount_min = dupe_result.amount_min
							duplicate_index.amount_max = dupe_result.amount_max
							duplicate_index.probability = dupe_result.probability
	
							results[i] = nil
						end
					end

					if not result.name then result[1] = nil end
					if not result.amount then result[2] = nil end
					
					result.name = new_result.name
					result.type = result_type
					result.amount = result_amount
					
					if duplicate_index.amount and result.amount then
						result.amount = result.amount+duplicate_index.amount
					end 
					if duplicate_index.amount_min and result.amount_min then
						result.amount_min = math.floor((result.amount_min+duplicate_index.amount_min)/2-0.5)
					end		
					if duplicate_index.amount_max and result.amount_max then
						result.amount_max = math.floor((result.amount_max+duplicate_index.amount_max)/2-0.5)
					end				
					if duplicate_index.probability and result.probability then
						result.probability = math.floor((result.probability+duplicate_index.probability)/2-0.5)
					end
					if duplicate_index.temperature and result.temperature then
						result.probability = math.floor((result.probability+duplicate_index.probability)/2-0.5)
					end
					
					table.insert(OSM.log.resource, '"'..OSM.mod..'"'..": Info: Replaced result: ("..old_result.type..") "..'"'..old_result.name..'"'.." with: ("..new_result.type..") "..'"'..new_result.name..'"'.." in resource: "..'"'..resource.name..'"')
				end
			end
		end

		if resource.minable.result and resource.minable.result.name == old_result.name then
			resource.minable.result.name = new_result.name
			table.insert(OSM.log.resource, '"'..OSM.mod..'"'..": Info: Replaced result: ("..old_result.type..") "..'"'..old_result.name..'"'.." with: ("..new_result.type..") "..'"'..new_result.name..'"'.." in resource: "..'"'..resource.name..'"')
		end

	end
	
	if resource_name and resource then
		replace_result(resource)

	elseif not resource_name then
		for _, resource in pairs(data.raw.resource) do
			replace_result(resource)
		end
	end
end