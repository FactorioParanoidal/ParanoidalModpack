-- Sort bioprocessing buildings into more rows
local bioprocessing_buildings = {
    -- Nauvis
    ["bio-generator-temperate-1"] = "bio-processing-buildings-nauvis-b",
    ["bio-generator-temperate-2"] = "bio-processing-buildings-nauvis-b",
    ["bio-generator-temperate-3"] = "bio-processing-buildings-nauvis-b",
    ["bio-generator-swamp-1"] = "bio-processing-buildings-nauvis-b",
    ["bio-generator-swamp-2"] = "bio-processing-buildings-nauvis-b",
    ["bio-generator-swamp-3"] = "bio-processing-buildings-nauvis-b",
    ["bio-generator-desert-1"] = "bio-processing-buildings-nauvis-b",
    ["bio-generator-desert-2"] = "bio-processing-buildings-nauvis-b",
    ["bio-generator-desert-3"] = "bio-processing-buildings-nauvis-b",
    -- Vegetabilis
    ["desert-farm"] = "bio-processing-buildings-vegetabilis-b",
    ["desert-farm-2"] = "bio-processing-buildings-vegetabilis-b",
    ["desert-farm-3"] = "bio-processing-buildings-vegetabilis-b",
    ["swamp-farm"] = "bio-processing-buildings-vegetabilis-b",
    ["swamp-farm-2"] = "bio-processing-buildings-vegetabilis-b",
    ["swamp-farm-3"] = "bio-processing-buildings-vegetabilis-b",
    ["seed-extractor"] = "bio-processing-buildings-vegetabilis-c",
    ["seed-extractor-2"] = "bio-processing-buildings-vegetabilis-c",
    ["seed-extractor-3"] = "bio-processing-buildings-vegetabilis-c",
    ["composter"] = "bio-processing-buildings-vegetabilis-c",
    ["composter-2"] = "bio-processing-buildings-vegetabilis-c",
    ["composter-3"] = "bio-processing-buildings-vegetabilis-c",
    ["bio-press"] = "bio-processing-buildings-vegetabilis-d",
    ["bio-press-2"] = "bio-processing-buildings-vegetabilis-d",
    ["bio-press-3"] = "bio-processing-buildings-vegetabilis-d",
    ["nutrient-extractor"] = "bio-processing-buildings-vegetabilis-d",
    ["nutrient-extractor-2"] = "bio-processing-buildings-vegetabilis-d",
    ["nutrient-extractor-3"] = "bio-processing-buildings-vegetabilis-d",
    ["bio-processor"] = "bio-processing-buildings-vegetabilis-e",
    ["bio-processor-2"] = "bio-processing-buildings-vegetabilis-e",
    ["bio-processor-3"] = "bio-processing-buildings-vegetabilis-e",
    -- Animalis
    ["bio-refugium-biter"] = "bio-processing-buildings-alien-b",
    ["bio-refugium-biter-2"] = "bio-processing-buildings-alien-b",
    ["bio-refugium-biter-3"] = "bio-processing-buildings-alien-b",
    ["bio-refugium-puffer"] = "bio-processing-buildings-alien-b",
    ["bio-refugium-puffer-2"] = "bio-processing-buildings-alien-b",
    ["bio-refugium-puffer-3"] = "bio-processing-buildings-alien-b",
}

if settings.startup["extangels-adjust-ordering"].value then
    for name, subgroup in pairs(bioprocessing_buildings) do
        local item = data.raw.item[name]
        local entity = data.raw["assembling-machine"][name]
        local recipe = data.raw.recipe[name]

        if item then item.subgroup = subgroup end

        -- Clear entity/recipe subgroups for proper inheritance from item
        if entity then entity.subgroup = nil end
        if recipe then recipe.subgroup = nil end
    end
end
