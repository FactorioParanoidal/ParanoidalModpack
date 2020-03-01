for _,fluid in pairs(data.raw["fluid"]) do
	local fluid_description_table = {""--[[, {"fluid-description.fluid-info", (fluid.pressure_to_speed_ratio * 100), (fluid.flow_to_energy_ratio * 100)}]]}
	if fluid.fuel_value and (fluid.fuel_value ~= "0") then
		table.insert(fluid_description_table, {"fluid-description.fuel-value", fluid.fuel_value})
	end
	if fluid.emissions_multiplier and (fluid.emissions_multiplier ~= 1.0) then
		table.insert(fluid_description_table, {"fluid-description.emmissions-multiplier", (fluid.emissions_multiplier * 100)})
	end
	--log(serpent.block(fluid_description_table))
	fluid.localised_description = fluid_description_table
end