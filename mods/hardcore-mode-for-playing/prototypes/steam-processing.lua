local techUtil = require("__automated-utility-protocol__.util.technology-util")
require("__automated-utility-protocol__.util.main")
require("fuel-categories")
require("steam-processing.boiler-processing")
require("steam-processing.steam-recipes")
require("steam-processing.steam-generator-processing")
require("steam-processing.fluid-fuel-generator-processing")
require("steam-processing.solid-fuel-generator-processing")
local function handle_one_recipe_data_by_temperature(recipe_data_by_temperature)
	local fuel_data_water_amount = recipe_data_by_temperature.fuel_data_water_amount
	log("fuel_data_water_amount " .. Utils.dump_to_console(fuel_data_water_amount))
	local fuel_data = fuel_data_water_amount.fuel_data
	local boiler_data = recipe_data_by_temperature.boiler_data
	local boiler_name = boiler_data.name
	log("boiler_name " .. boiler_name)
	local target_boiler_name = boiler_name .. "-" .. recipe_data_by_temperature.recipe_name
	local boiler_prototype = flib.copy_prototype(data.raw["boiler"][boiler_name], target_boiler_name)
	local energy_source = boiler_prototype.energy_source
	if boiler_data.isBurnerEnergySource then
		local fuel_category_name = fuel_data.type .. "-" .. fuel_data.name
		data:extend({ { type = "fuel-category", name = fuel_category_name } })
		data.raw[fuel_data.type][fuel_data.name].fuel_category = fuel_category_name
		if energy_source.fuel_category then
			energy_source.fuel_category = nil
		end
		if not energy_source.fuel_categories then
			energy_source.fuel_categories = {}
		end
		table.insert(energy_source.fuel_categories, fuel_category_name)
	end
	if boiler_data.isFluidEnergySource then
		energy_source.fluid_box.filter = fuel_data.name
	end
	boiler_prototype.output_fluid_box.filter = recipe_data_by_temperature.recipe_name
	local technology = data.raw["technology"][boiler_data.technology_name_occured_booiler_prototype]
	local mode = recipe_data_by_temperature.mode
	log(Utils.dump_to_console(Utils.getModedObject(technology, mode)))
	if techUtil.hasRecipeEffectIntoTechnologyEffects(technology, boiler_name, mode) then
		techUtil.removeRecipeEffectFromTechnologyEffects(technology, boiler_name, mode)
	end
	local boiler_name_recipe = data.raw["recipe"][boiler_name]
	if not Utils.getModedObject(boiler_name_recipe, mode).hidden then
		techUtil.hideRecipe(boiler_name_recipe, mode)
	end
	local target_boiler_recipe = flib.copy_prototype(data.raw["recipe"][boiler_name], target_boiler_name)
	data:extend({ target_boiler_recipe })
	target_boiler_recipe.result = target_boiler_name
	techUtil.addRecipeEffectToTechnologyEffects(technology, target_boiler_name, mode)
end
local function updateBoilerBySteamRecipe(steam_recipes_by_temperature_sorted)
	_table.each(steam_recipes_by_temperature_sorted, function(recipe_datas_by_temperature_level)
		_table.each(recipe_datas_by_temperature_level, handle_one_recipe_data_by_temperature)
	end)
end
local function steamProcessing(mode)
	local technology_names = techUtil.getAllActiveTechnologyNames(mode)
	local boiler_by_temperature_sorted = boilerProcessing(technology_names, mode)
	local steam_recipes_by_temperature_sorted = create_steam_recipe_and_fluids(boiler_by_temperature_sorted)
	log("steam_recipes_by_temperature_sorted " .. Utils.dump_to_console(steam_recipes_by_temperature_sorted))
	updateBoilerBySteamRecipe(steam_recipes_by_temperature_sorted)
	local generator_count = 0
	_table.each(technology_names, function(technology_name)
		local results = techUtil.getAllRecipesResultsForSpecifiedTechnology(technology_name, mode)
		_table.each(results, function(recipe_result)
			local recipe_result_name = recipe_result.name or recipe_result[1]
			if data.raw["generator"][recipe_result_name] then
				log(
					"for mode "
						.. mode
						.. " technology_name "
						.. technology_name
						.. " found generator "
						.. recipe_result_name
						.. "\nValue:"
						.. Utils.dump_to_console(data.raw["generator"][recipe_result_name])
				)
				generator_count = generator_count + 1
			end
			if data.raw["burner-generator"][recipe_result_name] then
				log(
					"for mode "
						.. mode
						.. " technology_name "
						.. technology_name
						.. " found burner-generator "
						.. recipe_result_name
						.. "\nValue:"
						.. Utils.dump_to_console(data.raw["burner-generator"][recipe_result_name])
				)
				generator_count = generator_count + 1
			end
		end)
	end)
	log("total count of generators is " .. tostring(generator_count))
	--[[local reactor_count = 0
	_table.each(technology_names, function(technology_name)
		local results = techUtil.getAllRecipesResultsForSpecifiedTechnology(technology_name, mode)
		_table.each(results, function(recipe_result)
			local recipe_result_name = recipe_result.name or recipe_result[1]
			if data.raw["reactor"][recipe_result_name] then
				log(
					"for mode "
						.. mode
						.. " technology_name "
						.. technology_name
						.. " found reactor "
						.. recipe_result_name
						.. "\nValue:"
						.. Utils.dump_to_console(data.raw["reactor"][recipe_result_name])
				)
				reactor_count = reactor_count + 1
			end
		end)
	end)
	log("total count of reactors is " .. tostring(reactor_count))]]
end

_table.each(GAME_MODES, function(mode)
	steamProcessing(mode)
end)
