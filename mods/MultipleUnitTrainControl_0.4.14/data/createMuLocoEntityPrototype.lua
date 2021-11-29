--[[ Copyright (c) 2019 robot256 (MIT License)
 * Project: Multiple Unit Train Control
 * File: createMuLocoEntityPrototype.lua
 * Description: Copies a locomotive entity prototype and creates the "-mu" version with:
 *    - max_power is double the standard version.
 *    - MU localization text is added to name and description fields.
--]]


function createMuLocoEntityPrototype(name, newName, has_description, power_multiplier)
  -- Copy source locomotive prototype
  local oldLoco = data.raw["locomotive"][name]
  local loco = table.deepcopy(oldLoco)
  
  -- Change name of prototype
  loco.name = newName
  -- Make this entity non-placeable (you're not allowed to have -mu items in your inventory), doesn't really work?
  if(loco.flags["placeable-neutral"]) then
    loco.flags["placeable-neutral"] = nil
  end
  if(loco.flags["placeable-player"]) then
    loco.flags["placeable-player"] = nil
  end
  if(loco.flags["placeable-enemy"]) then
    loco.flags["placeable-enemy"] = nil
  end
  
  -- Make it so a normal locomotive can be pasted on this blueprint, doesn't really work?
  loco.additional_pastable_entities = {name}
  
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
  elseif has_description==true then
    -- We know this mod set a description in their locale file (no way to determine dynamically at this phase)
    loco.localised_description = {'template.mu-description',{'entity-description.'..name}}
  else
    -- Assume there is no description in locale file
    loco.localised_description = {'template.plain-mu-description'}
  end
  
  return loco
end

return createMuLocoEntityPrototype
