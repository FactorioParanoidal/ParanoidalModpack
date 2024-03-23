function update_steam_generator_prototype_by_steam_recipe_prototype(steam_recipes_by_temperature_sorted, mode)
	local temperatures = _table.keys(steam_recipes_by_temperature_sorted)
	log("temperatures " .. Utils.dump_to_console(temperatures))
	local generator_datas_by_temperature_sorted = get_generators_sorted_by_temperatures_not_nuclear(temperatures, mode)
end
