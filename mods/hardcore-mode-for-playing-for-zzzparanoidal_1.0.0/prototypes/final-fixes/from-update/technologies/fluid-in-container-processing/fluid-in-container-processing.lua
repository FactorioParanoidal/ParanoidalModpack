local techUtil = require("__automated-utility-protocol__.util.technology-util")
require("__automated-utility-protocol__.util.technology-tree-cache-util")
require("__automated-utility-protocol__.util.technology-tree-util")
local fluid_names = getBasicFluidNames()
local empty_barrel_basic_fluid_recipe_names = _table.map(fluid_names, function(fluid_name)
	local target_fluid_name = fluid_name
	if target_fluid_name and target_fluid_name ~= "" then
		target_fluid_name = "-" .. target_fluid_name
	end
	return "empty" .. target_fluid_name .. "-barrel"
end)
local filled_barrel_basic_fluid_recipe_names = _table.map(fluid_names, function(fluid_name)
	local target_fluid_name = fluid_name
	if target_fluid_name and target_fluid_name ~= "" then
		target_fluid_name = "-" .. target_fluid_name
	end
	return "empty" .. target_fluid_name .. "-barrel"
end)
local specified_recipe_names = { "empty-barrel", "empty-canister", "gas-canister", "barreling-pump" }

local all_fluid_in_container_unmached_recipe_names = {}
_table.insert_all_if_not_exists(all_fluid_in_container_unmached_recipe_names, specified_recipe_names)
_table.insert_all_if_not_exists(all_fluid_in_container_unmached_recipe_names, filled_barrel_basic_fluid_recipe_names)
_table.insert_all_if_not_exists(all_fluid_in_container_unmached_recipe_names, empty_barrel_basic_fluid_recipe_names)

local function filter_function(recipe_name)
	return not _table.contains(all_fluid_in_container_unmached_recipe_names, recipe_name)
		and not string.find(recipe_name, "empty", 1, true)
end
local function updateFluidInContainerProcessingTechnologyEffectsByMode(technologies, mode, basic_technology_name)
	if not basic_technology_name or not type(basic_technology_name) == "string" then
		error("technology_name not specified!")
	end
	if not filter_function or not type(filter_function) == "function" then
		error("filter_function not specified!")
	end
	if not technologies[basic_technology_name] then
		return
	end
	local recipe_names =
		_table.filter(techUtil.getAllRecipesNamesForSpecifiedTechnology(basic_technology_name, mode), filter_function)
	log("fluid barrel recipes available: " .. Utils.dump_to_console(recipe_names))
	_table.each(recipe_names, function(recipe_name)
		local empty_recipe_name = string.gsub(recipe_name, "fill", "empty")
		techUtil.removeRecipeEffectFromTechnologyEffects(technologies[basic_technology_name], recipe_name, mode)
		techUtil.removeRecipeEffectFromTechnologyEffects(technologies[basic_technology_name], empty_recipe_name, mode)

		local technology_names = _table.filter(
			techUtil.getAllTechnologiesWithRecipeFluidResultSpecifiedInAnotherRecipeByName(recipe_name, mode),
			function(filtered_technology_name)
				log("basic_technology_name " .. basic_technology_name)
				log("filtered_technology_name " .. filtered_technology_name)
				return not TechnologyTreeUtil.haveTechnologyInTree(
					basic_technology_name,
					filtered_technology_name,
					mode
				)
			end
		)
		log(
			"for filled recipe "
				.. recipe_name
				.. " found following technologies with fluid result "
				.. Utils.dump_to_console(technology_names)
		)
		_table.each(technology_names, function(target_technology_name)
			techUtil.addRecipeEffectToTechnologyEffects(technologies[target_technology_name], recipe_name, mode)
			techUtil.addRecipeEffectToTechnologyEffects(technologies[target_technology_name], empty_recipe_name, mode)
		end)
	end)
end

function updateFluidInContainerProcessingTechnologyEffects(technology_name)
	local technologies = data.raw["technology"]
	_table.each(GAME_MODES, function(mode)
		TechnologyTreeCacheUtil.initTechnologyTreeCache(mode)
		updateFluidInContainerProcessingTechnologyEffectsByMode(technologies, mode, technology_name)
		TechnologyTreeCacheUtil.clearTechnologyTreeCache(mode)
	end)
end
