--[[ Copyright (c) 2019 robot256 (MIT License)
 * Project: Multiple Unit Train Control
 * File: createMuLocoEntityPrototype.lua
 * Description: Copies a locomotive entity prototype and creates the "-mu" version with:
 *    - max_power is double the standard version.
 *    - MU localization text is added to name and description fields.
--]]


function createMuLocoEntityPrototype(name, newName, power_multiplier)
  -- Copy source locomotive prototype
  local oldLoco = data.raw["locomotive"][name]
  local loco = table.deepcopy(oldLoco)
  
  -- Change name of prototype
  loco.name = newName
  
  loco.hidden = true
  
  loco.factoriopedia_alternative = name
  
  -- Make it so bots can revive ghosts with the normal item and pipette works like magic
  loco.placeable_by = loco.placeable_by or {item=name, count=1}
  
  -- Change the power level (string contains suffix "kW"). This also increases fuel consumption.
  loco.max_power = multiply_energy_value(loco.max_power, power_multiplier)
  
  -- Concatenate the localized name and description string of the source loco with our template.
  if loco.localised_name then
    -- Original mod already set dynamic localised name, use it in our template
    loco.localised_name = {'template.mu-name',table.deepcopy(loco.localised_name)}
  else
    -- Use original mod's name from locale file
    loco.localised_name = {'template.mu-name',{'entity-name.'..name}}
  end
  
  if loco.localised_description then
    -- Original mod already set dynamic localised description, use it in our template
    loco.localised_description = {'template.mu-description',table.deepcopy(loco.localised_description)}
  else
    -- Use fallback group to append our description to an existing one
    loco.localised_description = {"?", {"",{"entity-description."..name},"\n",{'template.mu-description'}},
                                       {"",{"item-description."..name},"\n",{'template.mu-description'}},
                                       {'template.mu-description'}}
  end
  
  return loco
end

return createMuLocoEntityPrototype
