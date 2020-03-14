--remotes.lua
-- Registers remote calls for other mods to use

-- Register a Locomotive Type as an electric locomotive with the given dummy fuel item.
-- This locomotive type will then be handled by RET. The registration is not persistent
-- so it needs to be repeated whenever the map is loaded (i.e. during the evaluation of 
-- control.lua)	
-- The fuel item can be any item that can be used as fuel. There are three dummy items
-- provided by RET: ret-dummy-fuel-1 (from the tier 1 electric locomotive), 
-- ret-dummy-fuel-2 (from the tier 2 electric locomotive) and "ret-dummy-fuel-modular".
-- The latter enables modules being detected in the locomotive.
function register_locomotive_type(loco_name, fuel_item)
	if (not game.entity_prototypes[loco_name]) or 
	   (fuel_item ~= nil and fuel_item ~= "ret-dummy-fuel-modular" and game.item_prototypes[fuel_item] == nil) then
		error("register_locomotive_type called with invalid arguments")
	end
	global.electric_loco_registry[loco_name] = fuel_item

	if remote.interfaces["FuelTrainStop"] then
		remote.call("FuelTrainStop", "exclude_from_fuel_schedule", loco_name)
	end
end

-- Returns the fuel item this locomotive type was registered with.
function get_locomotive_fuel(loco_name)
	return global.electric_loco_registry[loco_name]
end


remote.add_interface("realistic_electric_trains",
{
	["register_locomotive_type"] = register_locomotive_type,
	["get_locomotive_fuel"] = get_locomotive_fuel
})
