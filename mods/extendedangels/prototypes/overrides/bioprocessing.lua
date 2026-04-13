-- Sort bioprocessing buildings into more rows
local bioprocessing_buildings = {
  -- Nauvis
  ["angels-bio-generator-temperate-1"] = "angels-bio-processing-buildings-nauvis-b",
  ["angels-bio-generator-temperate-2"] = "angels-bio-processing-buildings-nauvis-b",
  ["angels-bio-generator-temperate-3"] = "angels-bio-processing-buildings-nauvis-b",
  ["angels-bio-generator-swamp-1"] = "angels-bio-processing-buildings-nauvis-b",
  ["angels-bio-generator-swamp-2"] = "angels-bio-processing-buildings-nauvis-b",
  ["angels-bio-generator-swamp-3"] = "angels-bio-processing-buildings-nauvis-b",
  ["angels-bio-generator-desert-1"] = "angels-bio-processing-buildings-nauvis-b",
  ["angels-bio-generator-desert-2"] = "angels-bio-processing-buildings-nauvis-b",
  ["angels-bio-generator-desert-3"] = "angels-bio-processing-buildings-nauvis-b",
  -- Vegetabilis
  ["angels-desert-farm"] = "angels-bio-processing-buildings-vegetabilis-b",
  ["angels-desert-farm-2"] = "angels-bio-processing-buildings-vegetabilis-b",
  ["angels-desert-farm-3"] = "angels-bio-processing-buildings-vegetabilis-b",
  ["angels-swamp-farm"] = "angels-bio-processing-buildings-vegetabilis-b",
  ["angels-swamp-farm-2"] = "angels-bio-processing-buildings-vegetabilis-b",
  ["angels-swamp-farm-3"] = "angels-bio-processing-buildings-vegetabilis-b",
  ["angels-seed-extractor"] = "angels-bio-processing-buildings-vegetabilis-c",
  ["angels-seed-extractor-2"] = "angels-bio-processing-buildings-vegetabilis-c",
  ["angels-seed-extractor-3"] = "angels-bio-processing-buildings-vegetabilis-c",
  ["angels-composter"] = "angels-bio-processing-buildings-vegetabilis-c",
  ["angels-composter-2"] = "angels-bio-processing-buildings-vegetabilis-c",
  ["angels-composter-3"] = "angels-bio-processing-buildings-vegetabilis-c",
  ["angels-bio-press"] = "angels-bio-processing-buildings-vegetabilis-d",
  ["angels-bio-press-2"] = "angels-bio-processing-buildings-vegetabilis-d",
  ["angels-bio-press-3"] = "angels-bio-processing-buildings-vegetabilis-d",
  ["angels-nutrient-extractor"] = "angels-bio-processing-buildings-vegetabilis-d",
  ["angels-nutrient-extractor-2"] = "angels-bio-processing-buildings-vegetabilis-d",
  ["angels-nutrient-extractor-3"] = "angels-bio-processing-buildings-vegetabilis-d",
  ["angels-bio-processor"] = "angels-bio-processing-buildings-vegetabilis-e",
  ["angels-bio-processor-2"] = "angels-bio-processing-buildings-vegetabilis-e",
  ["angels-bio-processor-3"] = "angels-bio-processing-buildings-vegetabilis-e",
  -- Animalis
  ["angels-bio-refugium-biter"] = "angels-bio-processing-buildings-alien-b",
  ["angels-bio-refugium-biter-2"] = "angels-bio-processing-buildings-alien-b",
  ["angels-bio-refugium-biter-3"] = "angels-bio-processing-buildings-alien-b",
  ["angels-bio-refugium-puffer"] = "angels-bio-processing-buildings-alien-b",
  ["angels-bio-refugium-puffer-2"] = "angels-bio-processing-buildings-alien-b",
  ["angels-bio-refugium-puffer-3"] = "angels-bio-processing-buildings-alien-b",
}

if settings.startup["extangels-adjust-ordering"].value then
  for name, subgroup in pairs(bioprocessing_buildings) do
    local item = data.raw.item[name]
    local entity = data.raw["assembling-machine"][name]
    local recipe = data.raw.recipe[name]

    if item then
      item.subgroup = subgroup
    end

    -- Clear entity/recipe subgroups for proper inheritance from item
    if entity then
      entity.subgroup = nil
    end
    if recipe then
      recipe.subgroup = nil
    end
  end
end
