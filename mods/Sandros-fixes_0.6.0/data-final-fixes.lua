local armor = data.raw.armor
local ammo = data.raw.ammo
local item = data.raw.item
local item_with_enitity_data = data.raw["item-with-entity-data"]
local fluid = data.raw.fluid
local lab = data.raw.lab
local recipe = data.raw.recipe
local subgroup = data.raw["item-subgroup"]

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

  if recipe[item_sort] then
    recipe[item_sort].subgroup = subgroup
    recipe[item_sort].order = order
  else
    log("Recipe " .. item_sort .. " does not exist.")
  end
end

local function sort_recipe_order(recipe_sort, subgroup)
  if item[recipe_sort] then
    item[recipe_sort].subgroup = subgroup
  else
    log("Item " .. recipe_sort .. " does not exist.")
  end
  if recipe[recipe_sort] then
    recipe[recipe_sort].subgroup = subgroup
  else
    log("Recipe " .. recipe_sort .. " does not exist.")
  end
end

if mods["angelsexploration"] and mods["PCPRedux"] then
  sort_item_recipe_order("plaswall", "angels-exploration-walls", "b[plastic]-a[wall]")
end

if mods["angelspetrochem"] and mods["PCPRedux"] then
  sort_recipe_order("carbon-dioxide", "petrochem-basics", "d[carbon-separation-3]")
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