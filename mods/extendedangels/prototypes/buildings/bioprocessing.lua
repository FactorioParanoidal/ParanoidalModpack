if not angelsmods.bioprocessing then return end

-- Set common parameters
local tint = angelsmods.bioprocessing.number_tint

-- Create list of buildings with parameters different from source entity
local bioprocessing_buildings = {
    -- Algae farms
    ["angels-algae-farm-5"] = {
        source = "angels-algae-farm-4",
        icon = "__angelsbioprocessinggraphics__/graphics/icons/algae-farm.png",
        tier = 5,
        order = "a[algae]-e",
        subgroup = "angels-bio-processing-buildings-nauvis-a",
        crafting_speed = 3,
        emissions_per_minute = -100 / 3 * 3,
        energy_usage = "225kW",
    },
    -- Arboretums
    ["angels-bio-arboretum-2"] = {
        source = "angels-bio-arboretum-1",
        icon = "__angelsbioprocessinggraphics__/graphics/icons/bio-arboretum.png",
        tier = 2,
        order = "c[arboretum]-ab",
        subgroup = "angels-bio-processing-buildings-nauvis-a",
        next_upgrade = "angels-bio-arboretum-3",
        crafting_speed = 1,
        emissions_per_minute = -200,
        energy_usage = "200kW",
    },
    ["angels-bio-arboretum-3"] = {
        source = "angels-bio-arboretum-1",
        icon = "__angelsbioprocessinggraphics__/graphics/icons/bio-arboretum.png",
        tier = 3,
        order = "c[arboretum]-ac",
        subgroup = "angels-bio-processing-buildings-nauvis-a",
        crafting_speed = 2,
        emissions_per_minute = -400,
        energy_usage = "400kW",
    },
    -- Seed generators
    ["angels-bio-generator-temperate-2"] = {
        source = "angels-bio-generator-temperate-1",
        icon = "__angelsbioprocessinggraphics__/graphics/icons/bio-temperate-generator.png",
        tier = 2,
        order = "b[generator]-aa",
        subgroup = "angels-bio-processing-buildings-nauvis-a",
        next_upgrade = "angels-bio-generator-temperate-3",
        crafting_speed = 1,
        emissions_per_minute = -150,
        energy_usage = "200kW",
    },
    ["angels-bio-generator-temperate-3"] = {
        source = "angels-bio-generator-temperate-1",
        icon = "__angelsbioprocessinggraphics__/graphics/icons/bio-temperate-generator.png",
        tier = 3,
        order = "b[generator]-ab",
        subgroup = "angels-bio-processing-buildings-nauvis-a",
        crafting_speed = 2,
        emissions_per_minute = -300,
        energy_usage = "400kW",
    },
    ["angels-bio-generator-swamp-2"] = {
        source = "angels-bio-generator-swamp-1",
        icon = "__angelsbioprocessinggraphics__/graphics/icons/bio-swamp-generator.png",
        tier = 2,
        order = "b[generator]-ba",
        subgroup = "angels-bio-processing-buildings-nauvis-a",
        next_upgrade = "angels-bio-generator-swamp-3",
        crafting_speed = 1,
        emissions_per_minute = -150,
        energy_usage = "200kW",
    },
    ["angels-bio-generator-swamp-3"] = {
        source = "angels-bio-generator-swamp-1",
        icon = "__angelsbioprocessinggraphics__/graphics/icons/bio-swamp-generator.png",
        tier = 3,
        order = "b[generator]-bb",
        subgroup = "angels-bio-processing-buildings-nauvis-a",
        crafting_speed = 2,
        emissions_per_minute = -300,
        energy_usage = "400kW",
    },
    ["angels-bio-generator-desert-2"] = {
        source = "angels-bio-generator-desert-1",
        icon = "__angelsbioprocessinggraphics__/graphics/icons/bio-desert-generator.png",
        tier = 2,
        order = "b[generator]-ca",
        subgroup = "angels-bio-processing-buildings-nauvis-a",
        next_upgrade = "angels-bio-generator-desert-3",
        crafting_speed = 1,
        emissions_per_minute = -150,
        energy_usage = "200kW",
    },
    ["angels-bio-generator-desert-3"] = {
        source = "angels-bio-generator-desert-1",
        icon = "__angelsbioprocessinggraphics__/graphics/icons/bio-desert-generator.png",
        tier = 3,
        order = "b[generator]-cb",
        subgroup = "angels-bio-processing-buildings-nauvis-a",
        crafting_speed = 2,
        emissions_per_minute = -300,
        energy_usage = "400kW",
    },
    -- Presses
    ["angels-bio-press-2"] = {
        source = "angels-bio-press",
        icon = "__angelsbioprocessinggraphics__/graphics/icons/bio-press.png",
        tier = 2,
        order = "d[bio-press]-b[mk2]",
        subgroup = "angels-bio-processing-buildings-nauvis-a",
        next_upgrade = "angels-bio-press-3",
        crafting_speed = 1.5,
        emissions_per_minute = 0.04 * 60,
        energy_usage = "190kW",
    },
    ["angels-bio-press-3"] = {
        source = "angels-bio-press",
        icon = "__angelsbioprocessinggraphics__/graphics/icons/bio-press.png",
        tier = 3,
        order = "d[bio-press]-c[mk3]",
        subgroup = "angels-bio-processing-buildings-nauvis-a",
        crafting_speed = 2,
        emissions_per_minute = 0.05 * 60,
        energy_usage = "225kW",
    },
    -- Processors
    ["angels-bio-processor-2"] = {
        source = "angels-bio-processor",
        icon = "__angelsbioprocessinggraphics__/graphics/icons/bio-processor.png",
        tier = 2,
        order = "ca",
        subgroup = "angels-bio-processing-buildings-vegetabilis-b",
        next_upgrade = "angels-bio-processor-3",
        crafting_speed = 1.5,
        emissions_per_minute = 0.04 * 60,
        energy_usage = "190kW",
    },
    ["angels-bio-processor-3"] = {
        source = "angels-bio-processor",
        icon = "__angelsbioprocessinggraphics__/graphics/icons/bio-processor.png",
        tier = 3,
        order = "cb",
        subgroup = "angels-bio-processing-buildings-vegetabilis-b",
        crafting_speed = 2,
        emissions_per_minute = 0.05 * 60,
        energy_usage = "225kW",
    },
    -- Butcheries
    ["angels-bio-butchery-2"] = {
        source = "angels-bio-butchery",
        type = "furnace",
        icon = "__angelsbioprocessinggraphics__/graphics/icons/bio-butchery.png",
        tier = 2,
        order = "ba",
        subgroup = "angels-bio-processing-buildings-alien-a",
        next_upgrade = "angels-bio-butchery-3",
        crafting_speed = 3,
        emissions_per_minute = 0.02 * 60,
        energy_usage = "190kW",
    },
    ["angels-bio-butchery-3"] = {
        source = "angels-bio-butchery",
        type = "furnace",
        icon = "__angelsbioprocessinggraphics__/graphics/icons/bio-butchery.png",
        tier = 3,
        order = "bb",
        subgroup = "angels-bio-processing-buildings-alien-a",
        crafting_speed = 4,
        emissions_per_minute = 0.03 * 60,
        energy_usage = "225kW",
    },
    -- Composters
    ["angels-composter-2"] = {
        source = "angels-composter",
        type = "furnace",
        icon = "__angelsbioprocessinggraphics__/graphics/icons/composter.png",
        tier = 2,
        order = "ba",
        subgroup = "angels-bio-processing-buildings-vegetabilis-b",
        next_upgrade = "angels-composter-3",
        crafting_speed = 3,
        emissions_per_minute = 0.02 * 60,
        energy_usage = "40kW",
    },
    ["angels-composter-3"] = {
        source = "angels-composter",
        type = "furnace",
        icon = "__angelsbioprocessinggraphics__/graphics/icons/composter.png",
        tier = 3,
        order = "bb",
        subgroup = "angels-bio-processing-buildings-vegetabilis-b",
        crafting_speed = 4,
        emissions_per_minute = 0.03 * 60,
        energy_usage = "45kW",
    },
    -- Crop farms
    ["angels-crop-farm-2"] = {
        source = "angels-crop-farm",
        icon = "__angelsbioprocessinggraphics__/graphics/icons/basic-farm.png",
        tier = 2,
        order = "aa",
        subgroup = "angels-bio-processing-buildings-vegetabilis-a",
        next_upgrade = "angels-crop-farm-3",
        crafting_speed = 1.5,
        emissions_per_minute = -60,
        energy_usage = "125kW",
    },
    ["angels-crop-farm-3"] = {
        source = "angels-crop-farm",
        icon = "__angelsbioprocessinggraphics__/graphics/icons/basic-farm.png",
        tier = 3,
        order = "ab",
        subgroup = "angels-bio-processing-buildings-vegetabilis-a",
        crafting_speed = 2,
        emissions_per_minute = -80,
        energy_usage = "150kW",
    },
    ["angels-temperate-farm-2"] = {
        source = "angels-temperate-farm",
        icon = "__angelsbioprocessinggraphics__/graphics/icons/temperate-farm.png",
        tier = 2,
        order = "baa",
        subgroup = "angels-bio-processing-buildings-vegetabilis-a",
        next_upgrade = "angels-temperate-farm-3",
        crafting_speed = 3,
        emissions_per_minute = -120,
        energy_usage = "155kW",
    },
    ["angels-temperate-farm-3"] = {
        source = "angels-temperate-farm",
        icon = "__angelsbioprocessinggraphics__/graphics/icons/temperate-farm.png",
        tier = 3,
        order = "bab",
        subgroup = "angels-bio-processing-buildings-vegetabilis-a",
        crafting_speed = 4,
        emissions_per_minute = -160,
        energy_usage = "190kW",
    },
    ["angels-swamp-farm-2"] = {
        source = "angels-swamp-farm",
        icon = "__angelsbioprocessinggraphics__/graphics/icons/swamp-farm.png",
        tier = 2,
        order = "bba",
        subgroup = "angels-bio-processing-buildings-vegetabilis-a",
        next_upgrade = "angels-swamp-farm-3",
        crafting_speed = 3,
        emissions_per_minute = -120,
        energy_usage = "155kW",
    },
    ["angels-swamp-farm-3"] = {
        source = "angels-swamp-farm",
        icon = "__angelsbioprocessinggraphics__/graphics/icons/swamp-farm.png",
        tier = 3,
        order = "bbc",
        subgroup = "angels-bio-processing-buildings-vegetabilis-a",
        crafting_speed = 4,
        emissions_per_minute = -160,
        energy_usage = "190kW",
    },
    ["angels-desert-farm-2"] = {
        source = "angels-desert-farm",
        icon = "__angelsbioprocessinggraphics__/graphics/icons/desert-farm.png",
        tier = 2,
        order = "bca",
        subgroup = "angels-bio-processing-buildings-vegetabilis-a",
        next_upgrade = "angels-desert-farm-3",
        crafting_speed = 3,
        emissions_per_minute = -120,
        energy_usage = "155kW",
    },
    ["angels-desert-farm-3"] = {
        source = "angels-desert-farm",
        icon = "__angelsbioprocessinggraphics__/graphics/icons/desert-farm.png",
        tier = 3,
        order = "bcb",
        subgroup = "angels-bio-processing-buildings-vegetabilis-a",
        crafting_speed = 4,
        emissions_per_minute = -160,
        energy_usage = "190kW",
    },
    -- Hatcheries
    ["angels-bio-hatchery-2"] = {
        type = "furnace",
        source = "angels-bio-hatchery",
        icon = "__angelsbioprocessinggraphics__/graphics/icons/bio-hatchery.png",
        tier = 2,
        order = "ca",
        subgroup = "angels-bio-processing-buildings-alien-a",
        next_upgrade = "angels-bio-hatchery-3",
        crafting_speed = 3,
        emissions_per_minute = 0.02 * 60,
        energy_usage = "190kW",
    },
    ["angels-bio-hatchery-3"] = {
        type = "furnace",
        source = "angels-bio-hatchery",
        icon = "__angelsbioprocessinggraphics__/graphics/icons/bio-hatchery.png",
        tier = 3,
        order = "cb",
        subgroup = "angels-bio-processing-buildings-alien-a",
        crafting_speed = 4,
        emissions_per_minute = 0.03 * 60,
        energy_usage = "225kW",
    },
    -- Nutrient extractors
    ["angels-nutrient-extractor-2"] = {
        source = "angels-nutrient-extractor",
        icon = "__angelsbioprocessinggraphics__/graphics/icons/nutrient-extractor.png",
        tier = 2,
        order = "d[nutrient-extractor]-b[mk2]",
        subgroup = "angels-bio-processing-buildings-vegetabilis-b",
        next_upgrade = "angels-nutrient-extractor-3",
        crafting_speed = 1.5,
        emissions_per_minute = 0.04 * 60,
        energy_usage = "190kW",
    },
    ["angels-nutrient-extractor-3"] = {
        source = "angels-nutrient-extractor",
        icon = "__angelsbioprocessinggraphics__/graphics/icons/nutrient-extractor.png",
        tier = 3,
        order = "d[nutrient-extractor]-c[mk3]",
        subgroup = "angels-bio-processing-buildings-vegetabilis-b",
        crafting_speed = 2,
        emissions_per_minute = 0.05 * 60,
        energy_usage = "225kW",
    },
    -- Refugiums
    ["angels-bio-refugium-fish-2"] = {
        source = "angels-bio-refugium-fish",
        icon = "__angelsbioprocessinggraphics__/graphics/icons/bio-refugium-fish.png",
        tier = 2,
        order = "aa",
        subgroup = "angels-bio-processing-buildings-alien-a",
        next_upgrade = "angels-bio-refugium-fish-3",
        crafting_speed = 1.25,
        emissions_per_minute = -60,
        energy_usage = "190kW",
    },
    ["angels-bio-refugium-fish-3"] = {
        source = "angels-bio-refugium-fish",
        icon = "__angelsbioprocessinggraphics__/graphics/icons/bio-refugium-fish.png",
        tier = 3,
        order = "ab",
        subgroup = "angels-bio-processing-buildings-alien-a",
        crafting_speed = 2,
        emissions_per_minute = -100,
        energy_usage = "225kW",
    },
    ["angels-bio-refugium-puffer-2"] = {
        source = "angels-bio-refugium-puffer",
        icon = "__angelsbioprocessinggraphics__/graphics/icons/bio-refugium-puffer.png",
        tier = 2,
        order = "da",
        subgroup = "angels-bio-processing-buildings-alien-a",
        next_upgrade = "angels-bio-refugium-puffer-3",
        crafting_speed = 1.25,
        emissions_per_minute = -60,
        energy_usage = "190kW",
    },
    ["angels-bio-refugium-puffer-3"] = {
        source = "angels-bio-refugium-puffer",
        icon = "__angelsbioprocessinggraphics__/graphics/icons/bio-refugium-puffer.png",
        tier = 3,
        order = "db",
        subgroup = "angels-bio-processing-buildings-alien-a",
        crafting_speed = 2,
        emissions_per_minute = -100,
        energy_usage = "225kW",
    },
    ["angels-bio-refugium-biter-2"] = {
        source = "angels-bio-refugium-biter",
        icon = "__angelsbioprocessinggraphics__/graphics/icons/alien-farm.png",
        tier = 2,
        order = "ea",
        subgroup = "angels-bio-processing-buildings-alien-a",
        next_upgrade = "angels-bio-refugium-biter-3",
        crafting_speed = 3,
        emissions_per_minute = -40,
        energy_usage = "190kW",
    },
    ["angels-bio-refugium-biter-3"] = {
        source = "angels-bio-refugium-biter",
        icon = "__angelsbioprocessinggraphics__/graphics/icons/alien-farm.png",
        tier = 3,
        order = "eb",
        subgroup = "angels-bio-processing-buildings-alien-a",
        crafting_speed = 4,
        emissions_per_minute = -60,
        energy_usage = "225kW",
    },
    -- Seed extractors
    ["angels-seed-extractor-2"] = {
        source = "angels-seed-extractor",
        icon = "__angelsbioprocessinggraphics__/graphics/icons/seed-extractor.png",
        tier = 2,
        order = "aa",
        subgroup = "angels-bio-processing-buildings-vegetabilis-b",
        next_upgrade = "angels-seed-extractor-3",
        crafting_speed = 1.25,
        emissions_per_minute = 0.04 * 60,
        energy_usage = "180kW",
    },
    ["angels-seed-extractor-3"] = {
        source = "angels-seed-extractor",
        icon = "__angelsbioprocessinggraphics__/graphics/icons/seed-extractor.png",
        tier = 3,
        order = "ab",
        subgroup = "angels-bio-processing-buildings-vegetabilis-b",
        crafting_speed = 2,
        emissions_per_minute = 0.05 * 60,
        energy_usage = "220kW",
    },
}

for name, params in pairs(bioprocessing_buildings) do
    -- Check for source entity
    local source_entity = data.raw[params.type and params.type or "assembling-machine"][params.source]
    if not source_entity then goto continue end

    -- Fetch the icon with numeral overlay
    local icons = extangels.numeral_tier({ icon = params.icon, icon_size = params.icon_size or 32 }, params.tier, params.tint or tint)

    data:extend({
        -- Create the item
        {
            type = "item",
            name = name,
            icons = icons,
            subgroup = params.subgroup or nil,
            order = params.order,
            place_result = name,
            stack_size = params.stack_size or 10,
        },

        -- Create the entity
        util.merge { source_entity, {
            name = name,
            minable = { result = name },
            next_upgrade = params.next_upgrade or nil,
            crafting_speed = params.crafting_speed or nil,
            energy_source = params.emissions_per_minute and { 
                emissions_per_minute = {
                    pollution = params.emissions_per_minute,
                },
            } or nil,
            energy_usage = params.energy_usage or nil,
        } },
    })

    -- Set entity icon
    data.raw[params.type and params.type or "assembling-machine"][name].icons = icons

    -- Continue
    ::continue::
end

-- Fix properties for Angel buildings
local buildings = {
    ["angels-algae-farm"] = { prototype = "assembling-machine", tier = 1 },
    ["angels-algae-farm-2"] = { prototype = "assembling-machine", tier = 2 },
    ["angels-algae-farm-3"] = { prototype = "assembling-machine", tier = 3 },
    ["angels-algae-farm-4"] = { prototype = "assembling-machine", tier = 4 },
    ["angels-bio-arboretum-1"] = { prototype = "assembling-machine", tier = 1 },
    ["angels-bio-generator-temperate-1"] = { prototype = "assembling-machine", tier = 1 },
    ["angels-bio-generator-swamp-1"] = { prototype = "assembling-machine", tier = 1 },
    ["angels-bio-generator-desert-1"] = { prototype = "assembling-machine", tier = 1 },
    ["angels-bio-press"] = { prototype = "assembling-machine", tier = 1, order = "d[bio-press]-a[mk1]" },
    ["angels-bio-processor"] = { prototype = "assembling-machine", tier = 1 },
    ["angels-bio-butchery"] = { prototype = "furnace", tier = 1 },
    ["angels-composter"] = { prototype = "furnace", tier = 1 },
    ["angels-crop-farm"] = { prototype = "assembling-machine", tier = 1 },
    ["angels-temperate-farm"] = { prototype = "assembling-machine", tier = 1 },
    ["angels-swamp-farm"] = { prototype = "assembling-machine", tier = 1 },
    ["angels-desert-farm"] = { prototype = "assembling-machine", tier = 1 },
    ["angels-bio-hatchery"] = { prototype = "furnace", tier = 1 },
    ["angels-nutrient-extractor"] = { prototype = "assembling-machine", tier = 1, order = "d[nutrient-extractor]-a[mk1]" },
    ["angels-bio-refugium-fish"] = { prototype = "assembling-machine", tier = 1 },
    ["angels-bio-refugium-puffer"] = { prototype = "assembling-machine", tier = 1 },
    ["angels-bio-refugium-biter"] = { prototype = "assembling-machine", tier = 1 },
    ["angels-seed-extractor"] = { prototype = "assembling-machine", tier = 1 },
}

for name, params in pairs(buildings) do
    local item = data.raw.item[name]
    local entity = data.raw[params.prototype][name]

    if item and (item.icons or item.icon) then
        local item_icon, item_icon_size
        if item.icons then
            item_icon = item.icons[1].icon
            item_icon_size = item.icons[1].icon_size or item.icon_size or 32
        elseif item.icon then
            item_icon = item.icon
            item_icon_size = item.icon_size or 32
        end

        item.icons = extangels.numeral_tier({ icon = item_icon, icon_size = item_icon_size }, params.tier, tint)
    end

    if entity and (entity.icons or entity.icon) then
        local entity_icon, entity_icon_size
        if entity.icons then
            entity_icon = entity.icons[1].icon
            entity_icon_size = entity.icons[1].icon_size or entity.icon_size or 32
        elseif entity.icon then
            entity_icon = entity.icon
            entity_icon_size = entity.icon_size or 32
        end

        entity.icons = extangels.numeral_tier({ icon = entity_icon, icon_size = entity_icon_size }, params.tier, tint)
    end

    if item and params.order then
        item.order = params.order
    end
end
