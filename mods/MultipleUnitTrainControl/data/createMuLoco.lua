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


-- Paranoidal: name of the item that places the locomotive. It may differ from the entity name
-- (Junk Train: item "JunkTrain" places "yir_usl").
local function find_loco_item(name)
  for _, item_type in pairs({"item-with-entity-data", "item"}) do
    if data.raw[item_type] and data.raw[item_type][name] then return name end
  end
  local placeable_by = data.raw["locomotive"][name].placeable_by
  if placeable_by then
    local entry = placeable_by.item and placeable_by or placeable_by[1]
    if entry and entry.item then return entry.item end
  end
  for _, item_type in pairs({"item-with-entity-data", "item"}) do
    for item_name, item in pairs(data.raw[item_type] or {}) do
      if item.place_result == name then return item_name end
    end
  end
  return name
end

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
	
  local item_name = find_loco_item(oldName)
  local mu_item = createMuLocoItemPrototype(oldName, newName, item_name)
  if mu_item then
    data:extend{ mu_item,
      createMuLocoEntityPrototype(oldName, newName, power_multiplier, item_name),
      createMuLocoRecipePrototype(oldName, newName, mu_fuel_item_name, item_name)
    }
    table.insert(data.raw.technology["multiple-unit-train-control-locomotives"].effects, {type = "unlock-recipe", recipe = newName})
	end
end

return createMuLoco
