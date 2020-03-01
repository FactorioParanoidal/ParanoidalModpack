--[[ Copyright (c) 2019 robot256 (MIT License)
 * Project: Multiple Unit Train Control
 * File: saveBurner.lua
 * Description: Saves and restores the state and contents of a burner.
 *    Includes currently burning data, fuel inventory, and burnt inventory.
--]]


function saveBurner(burner)
	if burner and burner.valid then
		saved = {	heat = burner.heat, 
					remaining_burning_fuel = burner.remaining_burning_fuel,
					currently_burning = burner.currently_burning,
					inventory = burner.inventory.get_contents(),
					burnt_result_inventory = burner.burnt_result_inventory.valid and burner.burnt_result_inventory.get_contents() or nil
				}
		return saved
	else
		return nil
	end
end

function restoreBurner(target,saved)
	target.heat = saved.heat
	target.currently_burning = saved.currently_burning
	target.remaining_burning_fuel = saved.remaining_burning_fuel
	for k,v in pairs(saved.inventory) do
		target.inventory.insert({name=k, count=v})
	end
	if ( saved.burnt_result_inventory ) then
		for k,v in pairs(saved.burnt_result_inventory) do
			target.burnt_result_inventory.insert({name=k, count=v})
		end
	end
end


return saveBurner,restoreBurner
