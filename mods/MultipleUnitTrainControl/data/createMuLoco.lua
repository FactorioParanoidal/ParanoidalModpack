--[[ Copyright (c) 2020 robot256 (MIT License)
 * Project: Multiple Unit Train Control
 * File: createMuLoco.lua
 * Description: Creates new prototypes for a burner-type MU locomotive version.
 * Arguments:
 *  std= entity name string of the standard version
 *  mu= entity name string of the mu version to be created
 *  power_multiplier= power buff to multiply, defaults to 2
 *  fuel_item= item name string of Realistic Electric Trains dummy fuel item used by the standard version
--]]

require ("data.createMuLocoRETFuelItem")
require ("data.createMuLocoEntityPrototype")
require ("data.createMuLocoItemPrototype")
require ("data.createMuLocoRecipePrototype")


function createMuLoco(arg)
	local oldName = arg.std
	local newName = arg.mu
	local power_multiplier = arg.power_multiplier or 2
	local fuel_item = arg.fuel_item
  
  log("Creating locomotive \""..newName.."\"")
	
	-- Check that source exists
	if not data.raw["locomotive"][oldName] then
		error("MUTC Prototype Maker: locomotive " .. oldName .. " doesn't exist")
	end
	
	-- RET fuel compatibility
	local mu_fuel_item = nil
	local mu_fuel_item_name = nil
	if fuel_item then
		mu_fuel_item = createMuLocoRETFuelItem(fuel_item, fuel_item.."-mu", power_multiplier)
		mu_fuel_item_name = mu_fuel_item.name
		data:extend{mu_fuel_item}
	end
	
  local mu_item = createMuLocoItemPrototype(oldName, newName)
  if mu_item then
    data:extend{ mu_item,
      createMuLocoEntityPrototype(oldName, newName, power_multiplier),
      createMuLocoRecipePrototype(oldName, newName, mu_fuel_item_name)
    }
    table.insert(data.raw.technology["multiple-unit-train-control-locomotives"].effects, {type = "unlock-recipe", recipe = newName})
	end
end

return createMuLoco
