local OV = angelsmods.functions.OV

-- Strip out recipe order setting so that inheritance works properly
local bioprocessing_recipes = {
  "angels-algae-farm",
  "angels-algae-farm-2",
  "angels-algae-farm-3",
  "angels-algae-farm-4",
  "angels-bio-arboretum-1",
  "angels-bio-generator-temperate-1",
  "angels-bio-generator-swamp-1",
  "angels-bio-generator-desert-1",
  "angels-bio-press",
  "angels-bio-processor",
  "angels-bio-butchery",
  "angels-composter",
  "angels-crop-farm",
  "angels-temperate-farm",
  "angels-swamp-farm",
  "angels-desert-farm",
  "angels-bio-hatchery",
  "angels-nutrient-extractor",
  "angels-bio-refugium-fish",
  "angels-bio-refugium-puffer",
  "angels-bio-refugium-biter",
  "angels-seed-extractor",
}

for _, name in pairs(bioprocessing_recipes) do
  local recipe = data.raw.recipe[name]
  if recipe then
    recipe.order = nil
  end
end
--Hide Recipes
  if mods["bobplates"] then
OV.disable_recipe({ "bob-copper-tungsten-alloy" })
OV.disable_recipe({ "bob-tungsten-carbide" })
OV.disable_recipe({ "bob-tungsten-carbide-2" })
  end
OV.disable_recipe({ "angels-pellet-tungsten-smelting" })
--Productivity Overrides
angelsmods.functions.allow_productivity("angels-plate-tungsten-carbide")
angelsmods.functions.allow_productivity("angels-molten-copper-tungsten-smelting-1")
angelsmods.functions.allow_productivity("angels-titanium-concrete-brick")
