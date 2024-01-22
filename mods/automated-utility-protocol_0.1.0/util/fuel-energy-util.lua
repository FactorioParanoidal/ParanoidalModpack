local techUtil = require("technology-util")
require("technology-tree-util")
FuelEnergyUtil = {}
local modifier_table = {
	[""] = 1,
	["k"] = math.pow(10, 3),
	["K"] = math.pow(10, 3),
	["M"] = math.pow(10, 6),
	["G"] = math.pow(10, 9),
	["T"] = math.pow(10, 12),
	["P"] = math.pow(10, 15),
	["E"] = math.pow(10, 18),
	["Z"] = math.pow(10, 21),
	["Y"] = math.pow(10, 24),
}
local function convert_energy_value_with_modifier(value, modifier)
	if not modifier then
		return value
	end
	local modifier_value = modifier_table[modifier]
	if not modifier_value then
		error("wrong specified modifier '" .. modifier .. "'")
	end
	return modifier_value * value
end

FuelEnergyUtil.read_energy_value_in_raw_joules = function(energy_string_value)
	local value, modifier = string.match(energy_string_value, "(%d+%.*%d*)([kKMGTPEZY]*)J")
	return convert_energy_value_with_modifier(tonumber(value), modifier)
end

FuelEnergyUtil.read_power_consumption_value_in_raw_watts = function(energy_string_value)
	local value, modifier = string.match(energy_string_value, "(%d+%.*%d*)([kKMGTPEZY]*)W")
	return convert_energy_value_with_modifier(tonumber(value), modifier)
end
FuelEnergyUtil.evaluate_available_fuel_prototype_for_recipe = function(
	prototype,
	is_allow_prototype_to_apply_prototype_function,
	technology_name,
	mode,
	additional_data
)
	local result = {}
	TechnologyTreeCacheUtil.initTechnologyTreeCache(mode)
	local prerequisite_names = TechnologyTreeUtil.findPrerequisitesForTechnologyForAllLevels(technology_name, mode)
	_table.insert(prerequisite_names, technology_name)
	_table.each(prerequisite_names, function(prerequisite_name)
		local recipe_results = techUtil.getAllRecipesResultsForSpecifiedTechnology(prerequisite_name, mode)
		_table.insert_all_if_not_exists(
			result,
			_table.filter(recipe_results, function(recipe_result)
				local recipe_result_prototype = data.raw[recipe_result.type][recipe_result.name]
				return is_allow_prototype_to_apply_prototype_function(
					prototype,
					recipe_result_prototype,
					additional_data
				)
			end)
		)
	end)
	TechnologyTreeCacheUtil.cleanupTechnologyTreeCache(mode)
	return result
end
FuelEnergyUtil.evaluate_water_heating_to_temperature_energy_in_joules = function(temperature)
	local water_prototype = data.raw["fluid"]["water"]
	local steam_prototype = data.raw["fluid"]["steam"]
	if not temperature or temperature <= steam_prototype.default_temperature then
		error("can't steam energy evaluating for temperature " .. tostring(temperature))
	end
	return (water_prototype.max_temperature - water_prototype.default_temperature)
			* FuelEnergyUtil.read_energy_value_in_raw_joules(water_prototype.heat_capacity)
		+ (temperature - steam_prototype.default_temperature)
			* FuelEnergyUtil.read_energy_value_in_raw_joules(steam_prototype.heat_capacity)
end
