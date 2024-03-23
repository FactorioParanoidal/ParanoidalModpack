local techUtil = require("__automated-utility-protocol__.util.technology-util")
local function detect_target_temperature_for_boiler(boiler)
	local boiler_mode = boiler.mode
	if boiler_mode == "output-to-separate-pipe" then
		return boiler.target_temperature
	end
	if boiler_mode == "heat-water-inside" then
		return data.raw["fluid"][boiler.output_fluid_box.filter].max_temperature
	end
	return nil
end

local function is_steam_boiler(boiler)
	return boiler.output_fluid_box.filter == "steam" and boiler.fluid_box.filter == "water"
end
local function is_fluid_energy_source_boiler(boiler)
	return boiler.energy_source.type == "fluid"
end
local function is_electric_energy_source_boiler(boiler)
	return boiler.energy_source.type == "electric"
end
local function is_heat_energy_source_boiler(boiler)
	return boiler.energy_source.type == "heat"
end
local function is_burner_energy_source_boiler(boiler)
	return boiler.energy_source.type == "burner"
end
local function check_boiler_data(boiler_data)
	return boiler_data.is_fluid_energy_source
		or boiler_data.is_electric_energy_source
		or boiler_data.is_burner_energy_source
		or boiler_data.is_heat_energy_source
end
local function get_boilers_by_target_temperature(technology_names, mode)
	local result = {}
	local boiler_count = 0
	_table.each(technology_names, function(technology_name)
		local results = techUtil.get_all_recipe_results_for_specified_technology(technology_name, mode)
		_table.each(results, function(recipe_result)
			local recipe_result_name = recipe_result.name or recipe_result[1]
			if not data.raw["boiler"][recipe_result_name] then
				return
			end
			local boiler = data.raw["boiler"][recipe_result_name]
			if not is_steam_boiler(boiler) then
				return
			end
			local target_temperature = detect_target_temperature_for_boiler(boiler)
			if not result[target_temperature] and target_temperature then
				result[target_temperature] = {}
			end
			if not result[target_temperature] then
				error(
					"for mode "
						.. mode
						.. " technology_name "
						.. technology_name
						.. " found boiler "
						.. recipe_result_name
						.. "\nValue:"
						.. Utils.dump_to_console(boiler)
						.. " target_temperature is not detected!"
				)
			end
			local boiler_data = {
				name = boiler.name,
				is_fluid_energy_source = is_fluid_energy_source_boiler(boiler),
				is_electric_energy_source = is_electric_energy_source_boiler(boiler),
				is_burner_energy_source = is_burner_energy_source_boiler(boiler),
				is_heat_energy_source = is_heat_energy_source_boiler(boiler),
				technology_name_occured_boiler_prototype = technology_name,
				mode = mode,
				effectivity = boiler.energy_source.effectivity,
				energy_consumption = boiler.energy_consumption,
				temperature = target_temperature,
			}
			if not check_boiler_data(boiler_data) then
				error(
					"for mode "
						.. mode
						.. " technology_name "
						.. technology_name
						.. " found boiler "
						.. recipe_result_name
						.. "\nValue:"
						.. Utils.dump_to_console(boiler)
						.. " not detected non Void energy_source!"
				)
			end
			_table.insert(result[target_temperature], boiler_data)
			boiler_count = boiler_count + 1
		end)
	end)
	log("total count of boilers is " .. tostring(boiler_count))
	return result
end
function boiler_processing(technology_names, mode)
	local technologies = data.raw["technology"]
	local result = get_boilers_by_target_temperature(technology_names, mode)
	_table.each(result, function(boiler_datas, target_temperature)
		_table.each(boiler_datas, function(boiler_data)
			local current_technology_name = boiler_data.technology_name_occured_boiler_prototype
			if not boiler_data.is_burner_energy_source then
				local filtered_boiler_data = _table.filter(boiler_datas, function(data)
					return data.is_burner_energy_source
				end)[1]
				techUtil.add_prerequisites_to_technology(
					technologies[current_technology_name],
					{ filtered_boiler_data.technology_name_occured_boiler_prototype },
					mode
				)
			end
		end)
	end)
	return result
end
local function set_recipe_result(target_boiler_recipe, target_boiler_name)
	target_boiler_recipe.normal.result = target_boiler_name
	target_boiler_recipe.normal.results = nil
	target_boiler_recipe.expensive.result = target_boiler_name
	target_boiler_recipe.expensive.results = nil
end
local function handle_one_recipe_data_by_temperature(recipe_data_by_temperature)
	local fuel_data_water_amount = recipe_data_by_temperature.fuel_data_water_amount
	--	log("fuel_data_water_amount " .. Utils.dump_to_console(fuel_data_water_amount))
	local fuel_data = fuel_data_water_amount.fuel_data
	local boiler_data = recipe_data_by_temperature.boiler_data
	local boiler_name = boiler_data.name
	--	log("boiler_name " .. boiler_name)
	local target_boiler_name = boiler_name .. "-" .. recipe_data_by_temperature.recipe_name
	--log("target_boiler_name " .. target_boiler_name)
	local target_boiler_prototype = flib.copy_prototype(data.raw["boiler"][boiler_name], target_boiler_name)
	local energy_source = target_boiler_prototype.energy_source
	if boiler_data.is_burner_energy_source then
		local fuel_category_name = fuel_data.type .. "-" .. fuel_data.name
		data:extend({ { type = "fuel-category", name = fuel_category_name } })
		data.raw[fuel_data.type][fuel_data.name].fuel_category = fuel_category_name
		energy_source.fuel_category = fuel_category_name
	end
	if boiler_data.is_fluid_energy_source then
		energy_source.fluid_box.filter = fuel_data.name
	end
	target_boiler_prototype.output_fluid_box.filter = recipe_data_by_temperature.recipe_name
	local target_boiler_item = flib.copy_prototype(data.raw["item"][boiler_name], target_boiler_name)
	local technology = data.raw["technology"][boiler_data.technology_name_occured_boiler_prototype]
	local mode = recipe_data_by_temperature.mode
	if techUtil.has_technology_recipe_effects(technology, boiler_name, mode) then
		--		log("from " .. boiler_data.technology_name_occured_boiler_prototype .. " removed recipe " .. boiler_name)
		techUtil.remove_recipe_effect_from_technology(technology, boiler_name, mode)
	end
	local target_boiler_recipe = flib.copy_prototype(data.raw["recipe"][boiler_name], target_boiler_name)
	set_recipe_result(target_boiler_recipe, target_boiler_name)
	data:extend({ target_boiler_prototype, target_boiler_item, target_boiler_recipe })
	--	log("target_boiler_recipe " .. Utils.dump_to_console(target_boiler_recipe))
	techUtil.add_recipe_effect_to_technology(technology, target_boiler_name, mode)
end
function update_boiler_prototype_by_steam_recipe_prototype(steam_recipes_by_temperature_sorted)
	_table.each(steam_recipes_by_temperature_sorted, function(recipe_datas_by_temperature_level)
		_table.each(recipe_datas_by_temperature_level, handle_one_recipe_data_by_temperature)
	end)
end
