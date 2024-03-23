--require("__automated-utility-protocol__.util.fuel-energy-util")
_table.each(data.raw, function(prototype_table)
	_table.each(prototype_table, function(prototype)
		if not prototype.fuel_value then
			return
		end
		local prototype_type = prototype.type
		local prototype_name = prototype.name
		--log("found prototype as fuel with type " .. prototype_type .. " called " .. prototype_name)
		if prototype_type == "item" then
			local fuel_category_name = get_fuel_category_name_for_prototype(prototype)
			data:extend({ { type = "fuel-category", name = fuel_category_name } })
			change_fuel_category_fuel_item(prototype_name, fuel_category_name)
			--[[local actual_joil_prototype_stack_energy_value = FuelEnergyUtil.read_energy_value_in_raw_joules(
				prototype.fuel_value
			) * prototype.stack_size
			log("actual_joil_prototype_stack_energy_value " .. tostring(actual_joil_prototype_stack_energy_value))]]
		end
	end)
end)
