--[[ Copyright (c) 2017 Optera
 * Part of Lighted Electric Poles +
 *
 * See LICENSE.md in the project directory for license information.
--]]

local optera_lib = require("__OpteraLib__.data.utilities")

local items = {}  -- dictionary [oritinal pole item] -> lighted pole entity/item/recipe
local lightedPoles = {}
local lep_icons_layer = { { icon = "__LightedPolesPlus__/graphics/icons/lighted.png", icon_size = 32, tint = {r=1, g=1, b=1, a=0.85} } }
local pole_entity_blacklist = {
  -- Bio Industries
  ["bi-power-to-rail-pole"] = true,
  ["bi-rail-hidden-power-pole"] = true,
}
local technology_overwrite = {
  ["basic-electronics"] = "optics", -- 0.17 shows small-electric-pole in basic-electronics, we want to move it into optics
 }

 -- check if recipe contains entry from Items
function GetItemFromRecipeResult(recipe)
  if recipe.result and items[recipe.result] then
    -- log(tostring(recipe.result).." found in "..tostring(recipe.name)..".result")
    return recipe.result
  end
  if recipe.normal and recipe.normal.result and items[recipe.normal.result] then
    -- log(tostring(recipe.normal.result).." found in "..tostring(recipe.name)..".normal.result")
    return recipe.normal.result
  end
  if recipe.expensive and recipe.expensive.result and items[recipe.expensive.result] then
    -- log(tostring(recipe.expensive.result).." found in "..tostring(recipe.name)..".expensive.result")
    return recipe.expensive.result
  end

  if recipe.results then
    for _, item in pairs(recipe.results) do
      if item.name and ( not item.type or item.type == "item") and items[item.name] then
        -- log(tostring(item.name).." found in "..tostring(recipe.name)..".results")
        return item.name
      end
    end
  end
  if recipe.normal and recipe.normal.results then
    for _, item in pairs(recipe.normal.results) do
      if item.name and ( not item.type or item.type == "item") and items[item.name] then
        -- log(tostring(item.name).." found in "..tostring(recipe.name)..".normal.results")
        return item.name
      end
    end
  end
  if recipe.expensive and recipe.expensive.results then
    for _, item in pairs(recipe.expensive.results) do
      if item.name and ( not item.type or item.type == "item") and items[item.name] then
        -- log(tostring(item.name).." found in "..tostring(recipe.name)..".expensive.results")
        return item.name
      end
    end
  end

  return nil
end


-- look through items for electric-poles should save looking through recipes and entities
for _, item in pairs (data.raw["item"]) do
  -- look through all item.place_result in case item and recipe names don't match entity name
  if item.place_result and data.raw["electric-pole"][item.place_result] and not pole_entity_blacklist[item.place_result] then
    log("[LEP+] found pole "..item.place_result.." in item "..item.name)
    local pole = data.raw["electric-pole"][item.place_result]
    if pole.minable and pole.minable.result and pole.minable.result == item.name then -- only generate lighted pole if item and entity properly reference another
			pole.fast_replaceable_group = pole.fast_replaceable_group or "electric-pole"

			local newName = "lighted-"..pole.name

      log("[LEP+] copying entity "..tostring(pole.name).." to "..tostring(newName))
      local newPole = optera_lib.copy_prototype(pole, newName)
      newPole.icons = optera_lib.create_icons(newPole, lep_icons_layer) or lep_icons_layer
      newPole.icon = nil
      newPole.icon_size= nil
      newPole.localised_name = {"entity-name.lighted-pole", {"entity-name." .. pole.name}}
      if newPole.next_upgrade then
        newPole.next_upgrade = "lighted-"..newPole.next_upgrade
      end

      log("[LEP+] copying item "..tostring(item.name).." to "..tostring(newName))
      items[item.name] = newName --save items for technology lookup
      local newItem = optera_lib.copy_prototype(item, newName)
      newItem.icons = optera_lib.create_icons(newItem, lep_icons_layer) or lep_icons_layer
      newItem.icon = nil
      newItem.icon_size= nil
      newItem.localised_name = newPole.localised_name
      newItem.order = item.order.."-0"
      -- log("group: "..tostring(item.subgroup).." order: "..tostring(item.order) )

      newPole.icons = newPole.icons or newItem.icons -- use item icon for lighted pole in case base pole entity had none

      local newRecipe =
      {
        type = "recipe",
        name = newName,
        enabled = "false",
        ingredients =
        {
          {item.name, 1},
          {"small-lamp", 1}
        },
        result = newName
      }

      -- find original recipe so new recipe can be sorted next to it
      for _, recipe in pairs (data.raw["recipe"]) do
        -- take first recipe
        if recipe.result == item.name then
          if recipe.subgroup then newRecipe.subgroup = recipe.subgroup end
          if recipe.order then newRecipe.order = recipe.order.."-0" end
          break
        end
      end

      -- temporary store generated pole, will be added to data after generation is complete
      table.insert(lightedPoles, newPole)
      table.insert(lightedPoles, newItem)
      table.insert(lightedPoles, newRecipe)
    end
  end

end
data:extend(lightedPoles)

 -- add to technology
for _, tech in pairs(data.raw["technology"]) do
  local tech_name = technology_overwrite[tech.name] or tech.name
  if tech.effects then
    for _, effect in pairs(tech.effects) do
      if effect.recipe and data.raw["recipe"][effect.recipe] then
        local base_item = GetItemFromRecipeResult(data.raw["recipe"][effect.recipe])
        if base_item then
          if data.raw["technology"][tech_name].effects then
            log("[LEP+] found original pole "..base_item.." in technology "..tech.name..", inserting "..items[base_item].." into technology "..tech_name)
            table.insert(data.raw["technology"][tech_name].effects, {type="unlock-recipe",recipe=items[base_item]})
          else
            log("[LEP+] found original pole "..base_item.." in technology "..tech.name..", creating new effects table for "..items[base_item].." in technology "..tech_name)
            data.raw["technology"][tech_name].effects = {type="unlock-recipe",recipe=items[base_item]}
          end
          items[base_item] = nil -- track inserted pole by removing entry
        end
      end
    end
  end
end
