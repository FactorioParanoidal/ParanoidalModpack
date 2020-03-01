--[[ Copyright (c) 2018 Optera
 * Part of Re-Stack
 *
 * See LICENSE.md in the project directory for license information.
--]]

-- Ore Stack Size
SelectItemByEntity("resource", settings.startup["ReStack-ores"].value, "ore")

for _,recipe in pairs(data.raw.recipe) do
  -- Plate stack size
  if recipe.category == "smelting" then
    SelectItemsByRecipeResult(recipe, settings.startup["ReStack-plates"].value, "smelting")
  end

  --Rocket Parts
  if recipe.category == "rocket-building" then
    SelectItemsByRecipeInput(recipe, settings.startup["ReStack-rocket-parts"].value, "rocket-part")
  end
end

-- Science Packs
for _, tech in pairs(data.raw.technology) do
  if tech.unit and tech.unit.ingredients then
    add_from_item_array(tech.unit.ingredients, settings.startup["ReStack-science-pack"].value, "science-pack")
  end
end

  -- nuclear fuel category & waste products
for _,item in pairs(data.raw.item) do
  if item.fuel_category == "nuclear" then
    ReStack_Items[item.name] = {stack_size = settings.startup["ReStack-fuel-category-nuclear"].value, type = "fuel-category-nuclear"}
    if item.burnt_result then
      ReStack_Items[item.burnt_result] = {stack_size = settings.startup["ReStack-fuel-category-nuclear"].value, type = "fuel-category-nuclear"}
    end
  end
end

-- refined Uranium
ReStack_Items["uranium-235"] = {stack_size = settings.startup["ReStack-uranium"].value, type = "uranium"}
ReStack_Items["uranium-238"] = {stack_size = settings.startup["ReStack-uranium"].value, type = "uranium"}

-- Fuels by item name (coal = ore, rocket-fuel = rocket-parts)
ReStack_Items["wood"] = {stack_size = settings.startup["ReStack-wood"].value, type = "wood"}
ReStack_Items["solid-fuel"] = {stack_size = settings.startup["ReStack-solid-fuel"].value, type = "solid-fuel"}
ReStack_Items["nuclear-fuel"] = {stack_size = settings.startup["ReStack-nuclear-fuel"].value, type = "nuclear-fuel"}

-- Tiles - applied last to overwrite when wood or ore is directly used as floor
for _,item in pairs(data.raw.item) do
  if item.place_as_tile and (Tile_Whitelist[item.name] or (settings.startup["ReStack-tiles-priority"].value or not ReStack_Items[item.name])) then
    ReStack_Items[item.name] = {stack_size = settings.startup["ReStack-tiles"].value, type = "tile"}
  end
end
