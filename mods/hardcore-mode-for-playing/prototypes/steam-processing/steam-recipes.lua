local techUtil = require("__automated-utility-protocol__.util.technology-util")
require("__automated-utility-protocol__.util.technology-tree-util")
require("__automated-utility-protocol__.util.fuel-energy-util")
local STEAM_OUTPUT_LEVEL_FOR_TEMPERATURE_BY_FUEL = 100
-- пересчитаем соотношение теплоёмкостей пара и воды в соотношении с реальными теплоёмкостями пара и воды.
local function fix_steam_prototype()
	local steam_prototype = data.raw["fluid"]["steam"]
	steam_prototype.heat_capacity = tostring(
		FuelEnergyUtil.read_energy_value_in_raw_joules(data.raw["fluid"]["water"].heat_capacity) * 2200 / 4200
	) .. "J"
	steam_prototype.default_temperature = 100
end

local function create_steam_recipe_for_fuel_and_temperature(new_steam_name, fuel_data, water_amount)
	local resource_fluid_prototype = data.raw["fluid"]["steam"]
	local mode_data = {
		results = {
			{
				type = "fluid",
				name = "steam",
				amount = water_amount,
			},
		},
		ingredients = {
			{
				type = "fluid",
				name = "water",
				amount = water_amount,
			},
			fuel_data,
		},
		always_show_made_in = false,
		always_show_products = true,
		allow_intermediates = false,
		allow_as_intermediate = false,
		allow_decomposition = false,
		allow_inserter_overload = false,
		enabled = false,
	}
	local recipe = {
		type = "recipe",
		name = new_steam_name .. "-with-fuel-" .. fuel_data.type .. "-" .. fuel_data.name,
		icons = resource_fluid_prototype.icons,
		icon = resource_fluid_prototype.icon,
		icon_size = resource_fluid_prototype.icon_size,
		category = "crafting-with-fluid",
		normal = mode_data,
		expensive = mode_data,
	}
	data:extend({
		recipe,
	})
	log("basic recipe " .. new_steam_name .. " created")
	return recipe
end

local function is_allow_prototype_to_apply_boiler_prototype(boiler_prototype, recipe_result_prototype, boiler_data)
	if not recipe_result_prototype or not recipe_result_prototype.fuel_category then
		return false
	end
	local energy_source = boiler_prototype.energy_source
	if not energy_source then
		error("ennergy_source for boiler not specified!")
	end
	if boiler_data.is_burner_energy_source then
		return (
			energy_source.fuel_category and recipe_result_prototype.fuel_category == energy_source.fuel_category
			or energy_source.fuel_categories
				and _table.contains(energy_source.fuel_categories, recipe_result_prototype.fuel_category)
		)
	end
	if boiler_data.is_fluid_energy_source then
		--	log("fluid boiler")
		return energy_source.fluid_box
			and energy_source.fluid_box.filter
			and energy_source.fluid_box.filter == recipe_result_prototype.name
	end
	--log("another boiler")
	return false
end
local function evaluate_fuel_datas_for_recipe(
	prototype,
	is_allow_prototype_to_apply_prototype_function,
	technology_name,
	mode,
	boiler_data
)
	log("boiler_data " .. boiler_data.name)
	local available_fuel_prototypes = FuelEnergyUtil.evaluate_available_fuel_prototype_for_entity_prototype(
		prototype,
		is_allow_prototype_to_apply_prototype_function,
		technology_name,
		mode,
		boiler_data
	)
	log("available_fuel_prototypes " .. Utils.dump_to_console(available_fuel_prototypes))
	local result = {}
	local water_heating_energy_value =
		FuelEnergyUtil.evaluate_water_heating_to_temperature_energy_in_joules(boiler_data.temperature)
	_table.each(available_fuel_prototypes, function(prototype)
		local fuel_data_energy_value =
			FuelEnergyUtil.read_energy_value_in_raw_joules(data.raw[prototype.type][prototype.name].fuel_value)
		local water_amount_for_fuel = fuel_data_energy_value / water_heating_energy_value
		local fuel_data_element = {
			fuel_data = { type = prototype.type, name = prototype.name, amount = 1 },
			water_amount = water_amount_for_fuel,
		}
		log("fuel_data_element " .. Utils.dump_to_console(fuel_data_element))
		table.insert(result, fuel_data_element)
	end)
	return result
end
local function handle_one_fuel_data_water_amount(
	fuel_data_water_amount,
	target_temperature,
	boiler_occured_technology,
	mode,
	boiler_data
)
	if fuel_data_water_amount.water_amount < STEAM_OUTPUT_LEVEL_FOR_TEMPERATURE_BY_FUEL then
		return nil
	end

	local steam_recipe = create_steam_recipe_for_fuel_and_temperature(
		"steam-" .. tostring(target_temperature),
		fuel_data_water_amount.fuel_data,
		fuel_data_water_amount.water_amount
	)
	data:extend({
		steam_recipe,
	})
	local full_with_fuel_steam_recipe_name = steam_recipe.name
	local full_with_fuel_steam_fluid = flib.copy_prototype(data.raw["fluid"]["steam"], full_with_fuel_steam_recipe_name)
	data:extend({ full_with_fuel_steam_fluid })
	techUtil.add_recipe_effect_to_technology(boiler_occured_technology, full_with_fuel_steam_recipe_name, mode)
	return {
		recipe_name = full_with_fuel_steam_recipe_name,
		temperature = target_temperature,
		boiler_data = boiler_data,
		mode = mode,
		technology_name = boiler_occured_technology.name,
		fuel_data_water_amount = fuel_data_water_amount,
	}
end
local function handle_one_boiler_data(boiler_data, target_temperature, mode)
	local result = {}
	local boiler_occured_technology = data.raw["technology"][boiler_data.technology_name_occured_booiler_prototype]
	local boiler_prototype = data.raw["boiler"][boiler_data.name]
	local fuel_data_water_amounts = evaluate_fuel_datas_for_recipe(
		boiler_prototype,
		is_allow_prototype_to_apply_boiler_prototype,
		boiler_data.technology_name_occured_booiler_prototype,
		boiler_data.mode,
		boiler_data
	)
	_table.each(fuel_data_water_amounts, function(fuel_data_water_amount)
		local recipe_data = handle_one_fuel_data_water_amount(
			fuel_data_water_amount,
			target_temperature,
			boiler_occured_technology,
			mode,
			boiler_data
		)
		if recipe_data then
			table.insert(result, recipe_data)
		end
	end)
	return result
end
local function handle_one_temperature_boiler_datas(boiler_datas, target_temperature)
	local result = {}
	_table.each(boiler_datas, function(boiler_data)
		_table.insert_all_if_not_exists(
			result,
			handle_one_boiler_data(boiler_data, target_temperature, boiler_data.mode)
		)
	end)
	return result
end
function create_steam_recipe_and_fluids(boiler_by_temperature_sorted)
	local result = {}
	_table.each(boiler_by_temperature_sorted, function(boiler_datas, target_temperature)
		result[target_temperature] = handle_one_temperature_boiler_datas(boiler_datas, target_temperature)
	end)
	return result
end
fix_steam_prototype()
