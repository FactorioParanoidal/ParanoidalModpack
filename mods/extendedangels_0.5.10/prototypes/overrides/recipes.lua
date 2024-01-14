-- Strip out recipe order setting so that inheritance works properly
local bioprocessing_recipes = {
    "algae-farm",
    "algae-farm-2",
    "algae-farm-3",
    "algae-farm-4",
    "bio-arboretum-1",
    "bio-generator-temperate-1",
    "bio-generator-swamp-1",
    "bio-generator-desert-1",
    "bio-press",
    "bio-processor",
    "bio-butchery",
    "composter",
    "crop-farm",
    "temperate-farm",
    "swamp-farm",
    "desert-farm",
    "bio-hatchery",
    "nutrient-extractor",
    "bio-refugium-fish",
    "bio-refugium-puffer",
    "bio-refugium-biter",
    "seed-extractor",
}

for _, name in pairs(bioprocessing_recipes) do
    local recipe = data.raw.recipe[name]
    if recipe then recipe.order = nil end
end
