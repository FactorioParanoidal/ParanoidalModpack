--[[ Copyright (c) 2019 robot256 (MIT License)
 * Project: Multiple Unit Train Control
 * File: createMuLocoRETFuelItem.lua
 * Description: Creates a new dummy fuel item for the "-mu" version of a Realistic Electric Trains locomotive:
--]]


function createMuLocoRETFuelItem(oldFuel, newFuel, power_multiplier)
	power_multiplier = power_multiplier or 2
	
	-- Generate dummy fuel items for base locos, because they are sized based on power consumption and we don't balance burner heat between pairs
	local dummy_fuel_mu = optera_lib.copy_prototype(data.raw["item"][oldFuel],newFuel)
	
	-- Change the power level (string contains suffix "kW"). This also increases fuel consumption.
	dummy_fuel_mu.fuel_value = optera_lib.multiply_energy_value(dummy_fuel_mu.fuel_value, power_multiplier)
	
	return dummy_fuel_mu
end

return createMuLocoRETFuelItem
