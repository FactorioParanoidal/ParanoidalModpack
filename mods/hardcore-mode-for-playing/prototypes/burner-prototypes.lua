local techUtil = require("__automated-utility-protocol__.util.technology-util")
require("__automated-utility-protocol__.util.technology-tree-util")
require("__automated-utility-protocol__.util.fuel-energy-util")
local function correct_effectivity_to_real(burner_source)
	local epsilon = 0.0001
	if not burner_source.effectivity then
		burner_source.effectivity = 1.0
	end
	while burner_source.effectivity > 1 do
		burner_source.effectivity = burner_source.effectivity / 2
	end
	if math.abs(burner_source.effectivity - 1) < epsilon then
		burner_source.effectivity = burner_source.effectivity - 0.1
	end
end

local function is_available_burner_or_energry_source_prototype(prototype, effectivity_max_item_stack_fuel_value)
	return prototype and (prototype.energy_source and prototype.energy_source.type == "burner" or prototype.burner)
end
local function evaluate_maximum_energy_consumption_for_entity_with_burner_prototype(
	prototype,
	effectivity_max_item_stack_fuel_value_per_secs
)
	local prototype_type = prototype.type
	if prototype_type == "locomotive" then
		return FuelEnergyUtil.read_power_consumption_value_in_raw_watts(prototype.max_power)
	end
	if prototype_type == "car" then
		return FuelEnergyUtil.read_power_consumption_value_in_raw_watts(prototype.consumption) / prototype.effectivity
	end
	if prototype_type == "furnace" then
		return FuelEnergyUtil.read_power_consumption_value_in_raw_watts(prototype.energy_usage)
	end
	if prototype_type == "generator-equipment" then
		return effectivity_max_item_stack_fuel_value_per_secs
	end
	if prototype_type == "assembling-machine" then
		return FuelEnergyUtil.read_power_consumption_value_in_raw_watts(prototype.energy_usage)
	end
	if prototype_type == "boiler" then
		return FuelEnergyUtil.read_power_consumption_value_in_raw_watts(prototype.energy_consumption)
	end
	if prototype_type == "reactor" then
		return FuelEnergyUtil.read_power_consumption_value_in_raw_watts(prototype.consumption)
	end
	if prototype_type == "spider-vehicle" then
		return FuelEnergyUtil.read_power_consumption_value_in_raw_watts(prototype.movement_energy_consumption)
	end
	if prototype_type == "inserter" then
		return effectivity_max_item_stack_fuel_value_per_secs
	end
	if prototype_type == "burner-generator" then
		return FuelEnergyUtil.read_power_consumption_value_in_raw_watts(prototype.max_power_output)
	end
	if prototype_type == "offshore-pump" then
		return effectivity_max_item_stack_fuel_value_per_secs
	end
	if prototype_type == "mining-drill" then
		return FuelEnergyUtil.read_power_consumption_value_in_raw_watts(prototype.energy_usage)
	end
	if prototype_type == "lab" then
		return FuelEnergyUtil.read_power_consumption_value_in_raw_watts(prototype.energy_usage)
	end
	error("unknown prototype_type " .. tostring(prototype_type))
end

local function is_allow_fuel_category_for_entity_with_burner_applying(prototype, effectivity_max_item_stack_fuel_value)
	local MINIMUM_TIME_IN_WORK_IN_SECS = 240
	local EPSILON = 0.001
	local maximum_energy_consumption_per_sec_for_entity_with_burner_prototype =
		evaluate_maximum_energy_consumption_for_entity_with_burner_prototype(
			prototype,
			effectivity_max_item_stack_fuel_value / MINIMUM_TIME_IN_WORK_IN_SECS
		)
	local maximum_energy_consumption_for_entity_with_burner_prototype = maximum_energy_consumption_per_sec_for_entity_with_burner_prototype
		* MINIMUM_TIME_IN_WORK_IN_SECS

	if
		effectivity_max_item_stack_fuel_value - maximum_energy_consumption_for_entity_with_burner_prototype >= -EPSILON
	then
		log(
			"maximum_energy_consumption_for_entity_with_burner_prototype "
				.. tostring(maximum_energy_consumption_for_entity_with_burner_prototype)
				.. " effectivity_max_item_stack_fuel_value "
				.. tostring(effectivity_max_item_stack_fuel_value)
		)
		return true
	end
	return false
end
local function nuclear_reactor_compatiable(recipe_result_prototype, prototype)
	local recipe_result_prototype_name = recipe_result_prototype.name
	local is_nuclear = false
	if
		string.find(recipe_result_prototype_name, "radio", 1, true)
		or string.find(recipe_result_prototype_name, "nuclear", 1, true)
		or string.find(recipe_result_prototype_name, "fuel-cell", 1, true)
	then
		is_nuclear = true
	end
	local prototype_type = prototype.type

	return (is_nuclear and prototype_type == "reactor") or (not is_nuclear and prototype_type ~= "reactor")
end
local function is_allow_prototype_to_apply_entity_with_burner_prototype(
	prototype,
	recipe_result_prototype,
	additional_data
)
	if
		not recipe_result_prototype
		or not recipe_result_prototype.type == "item"
		or not recipe_result_prototype.fuel_category
	then
		return false
	end
	local burner_energy_source = additional_data.burner_energy_source
	local burner_energy_source_effectivity = burner_energy_source.effectivity
	local burner_source_fuel_inventory_size = burner_energy_source.fuel_inventory_size

	if not burner_source_fuel_inventory_size then
		if prototype.type ~= "generator-equipment" then
			return false
		end
		burner_source_fuel_inventory_size = 1
	end
	log("recipe_result_prototype " .. Utils.dump_to_console(recipe_result_prototype.fuel_category))

	local fuel_candidate_stack_size = recipe_result_prototype.stack_size
	local max_item_stack_fuel_value = burner_source_fuel_inventory_size
		* FuelEnergyUtil.read_energy_value_in_raw_joules(recipe_result_prototype.fuel_value)
		* fuel_candidate_stack_size
	local effectivity_max_item_stack_fuel_value = max_item_stack_fuel_value * burner_energy_source_effectivity
	return nuclear_reactor_compatiable(recipe_result_prototype, prototype)
		and is_allow_fuel_category_for_entity_with_burner_applying(prototype, effectivity_max_item_stack_fuel_value)
end
local function handle_prototype_burner_or_energy_source_candidate(prototype, mode, technology_name)
	if not is_available_burner_or_energry_source_prototype(prototype) then
		return false
	end
	local burner_energy_source = prototype.burner or prototype.energy_source
	correct_effectivity_to_real(burner_energy_source)
	log(
		"found prototype type "
			.. prototype.type
			.. " called "
			.. prototype.name
			.. " in "
			.. technology_name
			.. " with burner "
			.. Utils.dump_to_console(burner_energy_source)
	)
	burner_energy_source.fuel_category = nil
	burner_energy_source.fuel_categories = {}
	local fuel_category_candidates = FuelEnergyUtil.evaluate_available_fuel_prototype_for_entity_prototype(
		prototype,
		is_allow_prototype_to_apply_entity_with_burner_prototype,
		technology_name,
		mode,
		{ burner_energy_source = burner_energy_source }
	)
	if not fuel_category_candidates or _table.size(fuel_category_candidates) == 0 then
		error(
			"for prototype "
				.. prototype.type
				.. " called "
				.. prototype.name
				.. " fuel_category_candidates is empty!May be technology tree don't contain technology with fuel candidates?"
		)
	end
	_table.each(fuel_category_candidates, function(fuel_category_candidate)
		table.insert(
			burner_energy_source.fuel_categories,
			get_fuel_category_name_for_prototype(fuel_category_candidate)
		)
	end)
	log(
		"changed prototype type "
			.. prototype.type
			.. " called "
			.. prototype.name
			.. " in "
			.. technology_name
			.. " with burner "
			.. Utils.dump_to_console(burner_energy_source)
	)
	return true
end

local function handle_prototype_table_burner_or_energy_source_candidate(prototypes, mode, technology_name)
	local result = nil
	_table.each(prototypes, function(prototype_data)
		_table.each(data.raw, function(prototype_type_table)
			local prototype = prototype_type_table[prototype_data.name]
			if handle_prototype_burner_or_energy_source_candidate(prototype, mode, technology_name) then
				result = prototype.type
			end
		end)
	end)
	return result
end

_table.each(GAME_MODES, function(mode)
	local technology_names = techUtil.get_all_active_technology_names(mode)
	local prototype_types = {}

	_table.each(technology_names, function(technology_name)
		local prototypes = techUtil.get_all_recipe_results_for_specified_technology(technology_name, mode)
		local result_type = handle_prototype_table_burner_or_energy_source_candidate(prototypes, mode, technology_name)
		if result_type then
			_table.insert_all_if_not_exists(prototype_types, { result_type })
		end
	end)
	--log("prototype_types " .. Utils.dump_to_console(prototype_types))
end)
