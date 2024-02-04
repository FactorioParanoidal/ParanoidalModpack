local techUtil = require("__automated-utility-protocol__.util.technology-util")
local function detectTargetTemperatureForBoiler(boiler)
	local boiler_mode = boiler.mode
	if boiler_mode == "output-to-separate-pipe" then
		return boiler.target_temperature
	end
	if boiler_mode == "heat-water-inside" then
		return data.raw["fluid"][boiler.output_fluid_box.filter].max_temperature
	end
	return nil
end

local function isSteamBoiler(boiler)
	return boiler.output_fluid_box.filter == "steam" and boiler.fluid_box.filter == "water"
end

local function isFluidEnergySourceBoiler(boiler)
	return boiler.energy_source.type == "fluid"
end
local function isElectricEnergySourceBoiler(boiler)
	return boiler.energy_source.type == "electric"
end
local function isHeatEnergySourceBoiler(boiler)
	return boiler.energy_source.type == "heat"
end
local function isBurnerEnergySourceBoiler(boiler)
	return boiler.energy_source.type == "burner"
end
local function checkBoilerData(boiler_data)
	return boiler_data.isFluidEnergySource
		or boiler_data.isElectricEnergySource
		or boiler_data.isBurnerEnergySource
		or boiler_data.isHeatEnergySource
end
local function getBoilersByTargetTemperature(technology_names, mode)
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
			if not isSteamBoiler(boiler) then
				return
			end
			local target_temperature = detectTargetTemperatureForBoiler(boiler)
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
				isFluidEnergySource = isFluidEnergySourceBoiler(boiler),
				isElectricEnergySource = isElectricEnergySourceBoiler(boiler),
				isBurnerEnergySource = isBurnerEnergySourceBoiler(boiler),
				isHeatEnergySource = isHeatEnergySourceBoiler(boiler),
				technology_name_occured_booiler_prototype = technology_name,
				mode = mode,
				effectivity = boiler.energy_source.effectivity,
				energy_consumption = boiler.energy_consumption,
				temperature = target_temperature,
			}
			if not checkBoilerData(boiler_data) then
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
function boilerProcessing(technology_names, mode)
	local technologies = data.raw["technology"]
	local result = getBoilersByTargetTemperature(technology_names, mode)
	_table.each(result, function(boiler_datas, target_temperature)
		_table.each(boiler_datas, function(boiler_data)
			local current_technology_name = boiler_data.technology_name_occured_booiler_prototype
			if not boiler_data.isBurnerEnergySource then
				local filtered_boiler_data = _table.filter(boiler_datas, function(data)
					return data.isBurnerEnergySource
				end)[1]
				techUtil.add_prerequisites_to_technology(
					technologies[current_technology_name],
					{ filtered_boiler_data.technology_name_occured_booiler_prototype },
					mode
				)
			end
		end)
	end)
	return result
end
