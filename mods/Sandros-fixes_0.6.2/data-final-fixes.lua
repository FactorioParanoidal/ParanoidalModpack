local armor = data.raw.armor
local ammo = data.raw.ammo
local item = data.raw.item
local item_with_enitity_data = data.raw["item-with-entity-data"]
local fluid = data.raw.fluid
local lab = data.raw.lab
local recipe = data.raw.recipe
local subgroup = data.raw["item-subgroup"]

local function sort_recipe(recipe_sort, subgroup)
  if recipe[recipe_sort] then
    recipe[recipe_sort].subgroup = subgroup
  else
    log("Recipe " .. recipe_sort .. " does not exist.")
  end
end

local function sort_item_recipe(item_sort, subgroup)
  if item[item_sort] then
    item[item_sort].subgroup = subgroup
  else
    log("Item " .. item_sort .. " does not exist.")
  end
  if recipe[item_sort] then
    recipe[item_sort].subgroup = subgroup
  else
    log("Recipe " .. item_sort .. " does not exist.")
  end
end

local function sort_item_recipe_order(item_sort, subgroup, order)
  local any

  if item[item_sort] then
    any = item
  elseif ammo[item_sort] then
    any = ammo
  elseif armor[item_sort] then
    any = armor
  elseif item_with_enitity_data[item_sort] then
    any = item_with_enitity_data
  else
    log("Item " .. item_sort .. " does not exist.")
  end

  if any[item_sort] then
    any[item_sort].subgroup = subgroup
    any[item_sort].order = order
  end

  if recipe[item_sort] then
    recipe[item_sort].subgroup = subgroup
    recipe[item_sort].order = order
  else
    log("Recipe " .. item_sort .. " does not exist.")
  end
end

if mods["PCPRedux"] then
  if mods["angelsexploration"] then
    sort_item_recipe_order("plaswall", "angels-exploration-walls", "b[plastic]-a[wall]")
  end

  if mods["angelspetrochem"] then
    sort_recipe("carbon-dioxide", "petrochem-basics", "d[carbon-separation-3]")
  end
end

if mods["angelsindustries"] then
  if mods["bobvehicleequipment"] then
    sort_item_recipe_order("vehicle-belt-immunity-equipment", "angels-vehicle-equipment", "a[vehicle-belt-immunity-equipment]")
  end

  if mods["bobequipment"] and mods["Nanobots"] then
    sort_item_recipe_order("equipment-bot-chip-items", "angels-personal-equipment-power-d", "aa")
    sort_item_recipe_order("equipment-bot-chip-launcher", "angels-personal-equipment-power-d", "ab")
    sort_item_recipe_order("equipment-bot-chip-trees", "angels-personal-equipment-power-d", "ac")
    sort_item_recipe_order("equipment-bot-chip-feeder", "angels-personal-equipment-power-d", "ad")
    sort_item_recipe_order("equipment-bot-chip-nanointerface", "angels-personal-equipment-power-d", "ae")
  end

  if mods["Portable_power"] then
    sort_item_recipe_order("portable-generator-equipment", "angels-personal-equipment-power-a", "z")
  end
end

--DrD
if mods["angelsrefining"] then
      sort_item_recipe_order("angelsore7-crystallization-3", "intermediate-product", "aa1")
      sort_item_recipe_order("angelsore7-crystallization-1", "intermediate-product", "aa2")
	  sort_item_recipe_order("angelsore7-crystallization-4", "intermediate-product", "aa3")
	  sort_item_recipe_order("angelsore7-crystallization-5", "intermediate-product", "aa4")
	  sort_item_recipe_order("angelsore7-crystallization-2", "intermediate-product", "aa5")
	  sort_item_recipe_order("angelsore7-crystallization-6", "intermediate-product", "aa6")
end