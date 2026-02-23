if not (mods["angelsindustries"] and angelsmods.industries.components) then
  return
end

-- Revise the construction block ingredients.
local recipe_ingredient_changes = {
  ["block-construction-0"] = {
    new_name = "stone",
    old_name = "stone",
  },
  ["block-construction-1"] = {
    new_name = "stone-brick",
    old_name = "stone",
  },
  ["block-construction-2"] = {
    new_name = "angels-clay-brick",
    old_name = "stone-brick",
  },
  ["block-construction-3"] = {
    new_name = "concrete-brick",
    old_name = "angels-clay-brick",
  },
  ["block-construction-4"] = {
    new_name = "angels-reinforced-concrete-brick",
    old_name = "concrete-brick",
  },
  ["block-construction-5"] = {
    new_name = "angels-titanium-concrete-brick",
    old_name = "angels-reinforced-concrete-brick",
  },
}

for recipe_name, ingredient_changes in pairs(recipe_ingredient_changes) do
  local ingredients = data.raw.recipe[recipe_name].ingredients
  if ingredients then
    for _, ingredient in pairs(ingredients) do
      if ingredient.name == ingredient_changes.old_name then
        ingredient.name = ingredient_changes.new_name
      end
    end
  end
end

-- Shift the construction block ingredients down one tier for sets of recipe ingredients.
local remapped_ingredients = {
  ["block-construction-1"] = "block-construction-0",
  ["block-construction-2"] = "block-construction-1",
  ["block-construction-3"] = "block-construction-2",
  ["block-construction-4"] = "block-construction-3",
  ["block-construction-5"] = "block-construction-4",
  ["angels-titanium-concrete-brick"] = "block-construction-5",
}

local function try_remap_block_ingredient(ingredient)
  -- If the ingredient has a defined remap, apply it.
  if remapped_ingredients[ingredient.name] then
    ingredient.name = remapped_ingredients[ingredient.name]
  end
end

local function try_remap_block_ingredients(type_name)
  for prototype_name, _ in pairs(data.raw[type_name]) do
    local recipe = data.raw.recipe[prototype_name]
    if recipe then
      for _, ingredient in pairs(recipe.ingredients) do
        try_remap_block_ingredient(ingredient)
      end
    end
  end
end

local building_type_names = {
  "assembling-machine",
  "mining-drill",
  "lab",
  "furnace",
  "offshore-pump",
  "pump",
  "rocket-silo",
  "radar",
  "beacon",
  "boiler",
  "generator",
  "solar-panel",
  "accumulator",
  "reactor",
  "electric-pole",
  "wall",
  "gate",
}

for _, type_name in pairs(building_type_names) do
  try_remap_block_ingredients(type_name)
end

-- Component/Tech overhaul recipe corrections
local recipes_to_remove_first_entry = {
  "angels-algae-farm-5",
  "angels-bio-generator-temperate-2",
  "angels-bio-generator-temperate-3",
  "angels-bio-generator-swamp-2",
  "angels-bio-generator-swamp-3",
  "angels-bio-generator-desert-2",
  "angels-bio-generator-desert-3",
  "angels-bio-arboretum-2",
  "angels-bio-arboretum-3",
  "angels-advanced-chemical-plant-3",
  "angels-air-filter-4",
  "angels-hydro-plant-4",
  "angels-salination-plant-3",
  "angels-washing-plant-3",
  "angels-washing-plant-4",
  "angels-ore-crusher-4",
  "angels-ore-floatation-cell-4",
  "angels-ore-leaching-plant-4",
  "angels-ore-refinery-3",
  "angels-bio-press-2",
  "angels-bio-press-3",
  "angels-bio-processor-2",
  "angels-bio-processor-3",
  "angels-bio-butchery-2",
  "angels-bio-butchery-3",
  "angels-composter-2",
  "angels-composter-3",
  "angels-crop-farm-2",
  "angels-crop-farm-3",
  "angels-temperate-farm-2",
  "angels-temperate-farm-3",
  "angels-desert-farm-2",
  "angels-desert-farm-3",
  "angels-swamp-farm-2",
  "angels-swamp-farm-3",
  "angels-bio-hatchery-2",
  "angels-bio-hatchery-3",
  "angels-nutrient-extractor-2",
  "angels-nutrient-extractor-3",
  "angels-bio-refugium-fish-2",
  "angels-bio-refugium-fish-3",
  "angels-bio-refugium-puffer-2",
  "angels-bio-refugium-puffer-3",
  "angels-bio-refugium-biter-2",
  "angels-bio-refugium-biter-3",
  "angels-seed-extractor-2",
  "angels-seed-extractor-3",
}

for _, recipe_name in pairs(recipes_to_remove_first_entry) do
  local recipe = data.raw.recipe[recipe_name]
  if recipe and recipe.ingredients and #recipe.ingredients > 0 then
    table.remove(recipe.ingredients, 1)
  end
end

if settings.startup["angels-return-ingredients"].value then
  angelsmods.functions.AI.add_minable_results()
  angelsmods.functions.OV.execute()
end
