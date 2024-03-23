-- Remove recipes and clear module limitations
local recipe_list = {
    "pellet-tungsten-smelting",
    "tungsten-carbide",
    "tungsten-carbide-2",
    "copper-tungsten-alloy"
}

for _, recipe in pairs(recipe_list) do
    data.raw.recipe[recipe] = nil

    for _, module in pairs(data.raw.module) do
        if module.limitation then
            for j,limit in pairs(module.limitation) do
                if limit == recipe then
                    table.remove(module.limitation,j)
                    break
                end
            end
        end
    end
end

-- Component/Tech overhaul recipe corrections
local previous_building = {
    "algae-farm-5",
    "bio-generator-temperate-2",
    "bio-generator-temperate-3",
    "bio-generator-swamp-2",
    "bio-generator-swamp-3",
    "bio-generator-desert-2",
    "bio-generator-desert-3",
    "bio-arboretum-2",
    "bio-arboretum-3",
    "gas-refinery-4",
    "advanced-chemical-plant-3",
    -- "angels-air-filter-3",
    "angels-air-filter-4",
    "hydro-plant-4",
    "salination-plant-3",
    "washing-plant-3",
    "washing-plant-4",
    "ore-crusher-4",
    "ore-floatation-cell-4",
    "ore-leaching-plant-4",
    "ore-refinery-3",
    -- "crystallizer-3",
    -- "filtration-unit-3",
    "bio-press-2",
    "bio-press-3",
    "bio-processor-2",
    "bio-processor-3",
    "bio-butchery-2",
    "bio-butchery-3",
    "composter-2",
    "composter-3",
    "crop-farm-2",
    "crop-farm-3",
    "temperate-farm-2",
    "temperate-farm-3",
    "desert-farm-2",
    "desert-farm-3",
    "swamp-farm-2",
    "swamp-farm-3",
    "bio-hatchery-2",
    "bio-hatchery-3",
    "nutrient-extractor-2",
    "nutrient-extractor-3",
    "bio-refugium-fish-2",
    "bio-refugium-fish-3",
    "bio-refugium-puffer-2",
    "bio-refugium-puffer-3",
    "bio-refugium-biter-2",
    "bio-refugium-biter-3",
    "seed-extractor-2",
    "seed-extractor-3"
}

require("prototypes.recipes.angels-components")

if mods["angelsindustries"] then
    if angelsmods.industries.components then
        local OV = angelsmods.functions.OV

        extangels.replace_construction_materials()
        OV.execute()

        for _, n in pairs(previous_building) do
            table.remove(data.raw["recipe"][n]["normal"].ingredients, 1);
            table.remove(data.raw["recipe"][n]["expensive"].ingredients, 1);
        end

        if settings.startup["angels-return-ingredients"].value then
            if not extangels.migration.is_newer_version("0.14.13", mods["angelsindustries"]) then
                angelsmods.functions.AI.add_minable_results()
            else
                add_minable_results()
            end
            OV.execute()
        end
    end
end
