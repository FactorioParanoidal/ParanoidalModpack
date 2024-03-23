local techUtil = require("__automated-utility-protocol__.util.technology-util")
local function is_steam_generator(generator)
	return generator.fluid_box.filter == "steam"
end
local function check_generator_data_not_nuclear(generator)
	return generator.energy_source
		and generator.energy_source.usage_priority
		and not generator.energy_source.buffer_capacity
		and not generator.energy_source.input_flow_limit
		and generator.maximum_temperature
		and generator.fluid_box
		and (generator.max_power_output or generator.fluid_box.filter)
		and not string.find(generator.name, "steam-turbine", 1, true)
end
function get_generators_sorted_by_temperatures_not_nuclear(temperatures, mode)
	local result = {}
	local steam_generator_count = 0
	local technology_names = techUtil.get_all_active_technology_names(mode)
	_table.each(technology_names, function(technology_name)
		local results = techUtil.get_all_recipe_results_for_specified_technology(technology_name, mode)
		_table.each(results, function(recipe_result)
			local recipe_result_name = recipe_result.name or recipe_result[1]
			if not data.raw["generator"][recipe_result_name] then
				return
			end
			local generator = data.raw["generator"][recipe_result_name]
			if not is_steam_generator(generator) then
				return
			end
			local target_temperature = generator.maximum_temperature
			if not result[target_temperature] and target_temperature then
				result[target_temperature] = {}
			end
			if not result[target_temperature] then
				error(
					"for mode "
						.. mode
						.. " technology_name "
						.. technology_name
						.. " found generator "
						.. recipe_result_name
						.. "\nValue:"
						.. Utils.dump_to_console(generator)
						.. " target_temperature is not detected!"
				)
			end
			if check_generator_data_not_nuclear(generator) then
				local generator_data = {
					name = generator.name,
					technology_name_occured_boiler_prototype = technology_name,
					mode = mode,
					output_flow_limit = generator.energy_source.output_flow_limit,
					temperature = target_temperature,
					max_power_output = generator.max_power_output,
				}
				_table.insert(result[target_temperature], generator_data)
				steam_generator_count = steam_generator_count + 1
				log("generator_data " .. Utils.dump_to_console(generator_data))
				return
			end
		end)
	end)
	log("total count of steam generators not nuclear is " .. tostring(steam_generator_count))
	_table.each(temperatures, function(temperature)
		if _table.size(result[temperature]) == 0 then
			error(
				"for temperature "
					.. tostring(temperature)
					.. " not found no one steam generators with not nuclear steam input!"
			)
		end
	end)
	return result
end
