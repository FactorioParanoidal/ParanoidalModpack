if not angelsmods.bioprocessing then return end

-- Set common parameters
local tint = angelsmods.bioprocessing.number_tint

-- Create list of buildings with parameters different from source entity
local bioprocessing_buildings = {
    -- Algae Farm
    ["algae-farm-4"] = {
        source = "algae-farm-3",
        icon = "__angelsbioprocessing__/graphics/icons/algae-farm.png",
        tier = 4,
        order = "a[algae]-d",
        subgroup = "bio-processing-buildings-nauvis-a",
        -- module_slots = 4,
        crafting_speed = 3,
        emissions_per_minute = -100/3 * 3,
        energy_usage = "250kW",
    },

    -- Arboretums
    ["bio-arboretum-2"] = {
        source = "bio-arboretum-1",
        icon = "__angelsbioprocessing__/graphics/icons/bio-arboretum.png",
        tier = 2,
        order = "c[arboretum]-ab",
        subgroup = "bio-processing-buildings-nauvis-a",
        -- module_slots = 4,
        next_upgrade = "bio-arboretum-3",
        crafting_speed = 1,
        emissions_per_minute = -200,
        energy_usage = "200kW",
    },

    ["bio-arboretum-3"] = {
        source = "bio-arboretum-1",
        icon = "__angelsbioprocessing__/graphics/icons/bio-arboretum.png",
        tier = 3,
        order = "c[arboretum]-ac",
        subgroup = "bio-processing-buildings-nauvis-a",
        -- module_slots = 6,
        crafting_speed = 2,
        emissions_per_minute = -400,
        energy_usage = "400kW",
    },

    -- Seed generators
    ["bio-generator-temperate-2"] = {
        source = "bio-generator-temperate-1",
        icon = "__angelsbioprocessing__/graphics/icons/bio-temperate-generator.png",
        tier = 2,
        order = "b[generator]-aa",
        subgroup = "bio-processing-buildings-nauvis-a",
        -- module_slots = 4,
        next_upgrade = "bio-generator-temperate-3",
        crafting_speed = 1,
        emissions_per_minute = -150,
        energy_usage = "200kW",
    },

    ["bio-generator-temperate-3"] = {
        source = "bio-generator-temperate-1",
        icon = "__angelsbioprocessing__/graphics/icons/bio-temperate-generator.png",
        tier = 3,
        order = "b[generator]-ab",
        subgroup = "bio-processing-buildings-nauvis-a",
        -- module_slots = 6,
        crafting_speed = 2,
        emissions_per_minute = -300,
        energy_usage = "400kW",
    },

    ["bio-generator-swamp-2"] = {
        source = "bio-generator-swamp-1",
        icon = "__angelsbioprocessing__/graphics/icons/bio-swamp-generator.png",
        tier = 2,
        order = "b[generator]-ba",
        subgroup = "bio-processing-buildings-nauvis-a",
        -- module_slots = 4,
        next_upgrade = "bio-generator-swamp-3",
        crafting_speed = 1,
        emissions_per_minute = -150,
        energy_usage = "200kW",
    },

    ["bio-generator-swamp-3"] = {
        source = "bio-generator-swamp-1",
        icon = "__angelsbioprocessing__/graphics/icons/bio-swamp-generator.png",
        tier = 3,
        order = "b[generator]-bb",
        subgroup = "bio-processing-buildings-nauvis-a",
        -- module_slots = 6,
        crafting_speed = 2,
        emissions_per_minute = -300,
        energy_usage = "400kW",
    },

    ["bio-generator-desert-2"] = {
        source = "bio-generator-desert-1",
        icon = "__angelsbioprocessing__/graphics/icons/bio-desert-generator.png",
        tier = 2,
        order = "b[generator]-ca",
        subgroup = "bio-processing-buildings-nauvis-a",
        -- module_slots = 4,
        next_upgrade = "bio-generator-desert-3",
        crafting_speed = 1,
        emissions_per_minute = -150,
        energy_usage = "200kW",
    },

    ["bio-generator-desert-3"] = {
        source = "bio-generator-desert-1",
        icon = "__angelsbioprocessing__/graphics/icons/bio-desert-generator.png",
        tier = 3,
        order = "b[generator]-cb",
        subgroup = "bio-processing-buildings-nauvis-a",
        -- module_slots = 6,
        crafting_speed = 2,
        emissions_per_minute = -300,
        energy_usage = "400kW",
    },

    -- Presses
    ["bio-press-2"] = {
        source = "bio-press",
        icon = "__angelsbioprocessing__/graphics/icons/bio-press.png",
        tier = 2,
        order = "d[bio-press]-b[mk2]",
        subgroup = "bio-processing-buildings-nauvis-a",
        -- module_slots = 3,
        next_upgrade = "bio-press-3",
        crafting_speed = 1.5,
        emissions_per_minute = 0.04 * 60,
        energy_usage = "190kW",
    },

    ["bio-press-3"] = {
        source = "bio-press",
        icon = "__angelsbioprocessing__/graphics/icons/bio-press.png",
        tier = 3,
        order = "d[bio-press]-c[mk3]",
        subgroup = "bio-processing-buildings-nauvis-a",
        -- module_slots = 4,
        crafting_speed = 2,
        emissions_per_minute = 0.05 * 60,
        energy_usage = "225kW",
    },

    -- Processors
    ["bio-processor-2"] = {
        source = "bio-processor",
        icon = "__angelsbioprocessing__/graphics/icons/bio-processor.png",
        tier = 2,
        order = "ca",
        subgroup = "bio-processing-buildings-vegetabilis-b",
        -- module_slots = 3,
        next_upgrade = "bio-processor-3",
        crafting_speed = 1.5,
        emissions_per_minute = 0.04 * 60,
        energy_usage = "190kW",
    },

    ["bio-processor-3"] = {
        source = "bio-processor",
        icon = "__angelsbioprocessing__/graphics/icons/bio-processor.png",
        tier = 3,
        order = "cb",
        subgroup = "bio-processing-buildings-vegetabilis-b",
        -- module_slots = 4,
        crafting_speed = 2,
        emissions_per_minute = 0.05 * 60,
        energy_usage = "225kW",
    },

    -- Butcheries
    ["bio-butchery-2"] = {
        source = "bio-butchery",
        type = "furnace",
        icon = "__angelsbioprocessing__/graphics/icons/bio-butchery.png",
        tier = 2,
        order = "ba",
        subgroup = "bio-processing-buildings-alien-a",
        -- module_slots = 3,
        next_upgrade = "bio-butchery-3",
        crafting_speed = 3,
        emissions_per_minute = 0.02 * 60,
        energy_usage = "190kW",
    },

    ["bio-butchery-3"] = {
        source = "bio-butchery",
        type = "furnace",
        icon = "__angelsbioprocessing__/graphics/icons/bio-butchery.png",
        tier = 3,
        order = "bb",
        subgroup = "bio-processing-buildings-alien-a",
        -- module_slots = 4,
        crafting_speed = 4,
        emissions_per_minute = 0.03 * 60,
        energy_usage = "225kW",
    },

    -- Composters
    ["composter-2"] = {
        source = "composter",
        type = "furnace",
        icon = "__angelsbioprocessing__/graphics/icons/composter.png",
        tier = 2,
        order = "ba",
        subgroup = "bio-processing-buildings-vegetabilis-b",
        -- module_slots = 3,
        next_upgrade = "composter-3",
        crafting_speed = 3,
        emissions_per_minute = 0.02 * 60,
        energy_usage = "40kW",
    },

    ["composter-3"] = {
        source = "composter",
        type = "furnace",
        icon = "__angelsbioprocessing__/graphics/icons/composter.png",
        tier = 3,
        order = "bb",
        subgroup = "bio-processing-buildings-vegetabilis-b",
        -- module_slots = 4,
        crafting_speed = 4,
        emissions_per_minute = 0.03 * 60,
        energy_usage = "45kW",
    },

    -- Crop farms
    ["crop-farm-2"] = {
        source = "crop-farm",
        icon = "__angelsbioprocessing__/graphics/icons/basic-farm.png",
        tier = 2,
        order = "aa",
        subgroup = "bio-processing-buildings-vegetabilis-a",
        -- module_slots = 3,
        next_upgrade = "crop-farm-3",
        crafting_speed = 1.5,
        emissions_per_minute = -60,
        energy_usage = "125kW",
    },

    ["crop-farm-3"] = {
        source = "crop-farm",
        icon = "__angelsbioprocessing__/graphics/icons/basic-farm.png",
        tier = 3,
        order = "ab",
        subgroup = "bio-processing-buildings-vegetabilis-a",
        -- module_slots = 4,
        crafting_speed = 2,
        emissions_per_minute = -80,
        energy_usage = "150kW",
    },

    ["temperate-farm-2"] = {
        source = "temperate-farm",
        icon = "__angelsbioprocessing__/graphics/icons/temperate-farm.png",
        tier = 2,
        order = "baa",
        subgroup = "bio-processing-buildings-vegetabilis-a",
        -- module_slots = 3,
        next_upgrade = "temperate-farm-3",
        crafting_speed = 3,
        emissions_per_minute = -120,
        energy_usage = "155kW",
    },

    ["temperate-farm-3"] = {
        source = "temperate-farm",
        icon = "__angelsbioprocessing__/graphics/icons/temperate-farm.png",
        tier = 3,
        order = "bab",
        subgroup = "bio-processing-buildings-vegetabilis-a",
        -- module_slots = 4,
        crafting_speed = 4,
        emissions_per_minute = -160,
        energy_usage = "190kW",
    },

    ["swamp-farm-2"] = {
        source = "swamp-farm",
        icon = "__angelsbioprocessing__/graphics/icons/swamp-farm.png",
        tier = 2,
        order = "bba",
        subgroup = "bio-processing-buildings-vegetabilis-a",
        -- module_slots = 3,
        next_upgrade = "swamp-farm-3",
        crafting_speed = 3,
        emissions_per_minute = -120,
        energy_usage = "155kW",
    },

    ["swamp-farm-3"] = {
        source = "swamp-farm",
        icon = "__angelsbioprocessing__/graphics/icons/swamp-farm.png",
        tier = 3,
        order = "bbc",
        subgroup = "bio-processing-buildings-vegetabilis-a",
        -- module_slots = 4,
        crafting_speed = 4,
        emissions_per_minute = -160,
        energy_usage = "190kW",
    },

    ["desert-farm-2"] = {
        source = "desert-farm",
        icon = "__angelsbioprocessing__/graphics/icons/desert-farm.png",
        tier = 2,
        order = "bca",
        subgroup = "bio-processing-buildings-vegetabilis-a",
        -- module_slots = 3,
        next_upgrade = "desert-farm-3",
        crafting_speed = 3,
        emissions_per_minute = -120,
        energy_usage = "155kW",
    },

    ["desert-farm-3"] = {
        source = "desert-farm",
        icon = "__angelsbioprocessing__/graphics/icons/desert-farm.png",
        tier = 3,
        order = "bcb",
        subgroup = "bio-processing-buildings-vegetabilis-a",
        -- module_slots = 4,
        crafting_speed = 4,
        emissions_per_minute = -160,
        energy_usage = "190kW",
    },

    -- Hatcheries
    ["bio-hatchery-2"] = {
        type = "furnace",
        source = "bio-hatchery",
        icon = "__angelsbioprocessing__/graphics/icons/bio-hatchery.png",
        tier = 2,
        order = "ca",
        subgroup = "bio-processing-buildings-alien-a",
        -- module_slots = 3,
        next_upgrade = "bio-hatchery-3",
        crafting_speed = 3,
        emissions_per_minute = 0.02 * 60,
        energy_usage = "190kW",
    },

    ["bio-hatchery-3"] = {
        type = "furnace",
        source = "bio-hatchery",
        icon = "__angelsbioprocessing__/graphics/icons/bio-hatchery.png",
        tier = 3,
        order = "cb",
        subgroup = "bio-processing-buildings-alien-a",
        -- module_slots = 4,
        crafting_speed = 4,
        emissions_per_minute = 0.03 * 60,
        energy_usage = "225kW",
    },

    -- Nutrient extractors
    ["nutrient-extractor-2"] = {
        source = "nutrient-extractor",
        icon = "__angelsbioprocessing__/graphics/icons/nutrient-extractor.png",
        tier = 2,
        order = "d[nutrient-extractor]-b[mk2]",
        subgroup = "bio-processing-buildings-vegetabilis-b",
        -- module_slots = 3,
        next_upgrade = "nutrient-extractor-3",
        crafting_speed = 1.5,
        emissions_per_minute = 0.04 * 60,
        energy_usage = "190kW",
    },

    ["nutrient-extractor-3"] = {
        source = "nutrient-extractor",
        icon = "__angelsbioprocessing__/graphics/icons/nutrient-extractor.png",
        tier = 3,
        order = "d[nutrient-extractor]-c[mk3]",
        subgroup = "bio-processing-buildings-vegetabilis-b",
        -- module_slots = 4,
        crafting_speed = 2,
        emissions_per_minute = 0.05 * 60,
        energy_usage = "225kW",
    },

    -- Refugiums
    ["bio-refugium-fish-2"] = {
        source = "bio-refugium-fish",
        icon = "__angelsbioprocessing__/graphics/icons/bio-refugium-fish.png",
        tier = 2,
        order = "aa",
        subgroup = "bio-processing-buildings-alien-a",
        -- module_slots = 3,
        next_upgrade = "bio-refugium-fish-3",
        crafting_speed = 1.25,
        emissions_per_minute = -60,
        energy_usage = "190kW",
    },

    ["bio-refugium-fish-3"] = {
        source = "bio-refugium-fish",
        icon = "__angelsbioprocessing__/graphics/icons/bio-refugium-fish.png",
        tier = 3,
        order = "ab",
        subgroup = "bio-processing-buildings-alien-a",
        -- module_slots = 4,
        crafting_speed = 2,
        emissions_per_minute = -100,
        energy_usage = "225kW",
    },

    ["bio-refugium-puffer-2"] = {
        source = "bio-refugium-puffer",
        icon = "__angelsbioprocessing__/graphics/icons/bio-refugium-puffer.png",
        tier = 2,
        order = "da",
        subgroup = "bio-processing-buildings-alien-a",
        -- module_slots = 3,
        next_upgrade = "bio-refugium-puffer-3",
        crafting_speed = 1.25,
        emissions_per_minute = -60,
        energy_usage = "190kW",
    },

    ["bio-refugium-puffer-3"] = {
        source = "bio-refugium-puffer",
        icon = "__angelsbioprocessing__/graphics/icons/bio-refugium-puffer.png",
        tier = 3,
        order = "db",
        subgroup = "bio-processing-buildings-alien-a",
        -- module_slots = 4,
        crafting_speed = 2,
        emissions_per_minute = -100,
        energy_usage = "225kW",
    },

    ["bio-refugium-biter-2"] = {
        source = "bio-refugium-biter",
        icon = "__angelsbioprocessing__/graphics/icons/alien-farm.png",
        tier = 2,
        order = "ea",
        subgroup = "bio-processing-buildings-alien-a",
        -- module_slots = 3,
        next_upgrade = "bio-refugium-biter-3",
        crafting_speed = 3,
        emissions_per_minute = -40,
        energy_usage = "190kW",
    },

    ["bio-refugium-biter-3"] = {
        source = "bio-refugium-biter",
        icon = "__angelsbioprocessing__/graphics/icons/alien-farm.png",
        tier = 3,
        order = "eb",
        subgroup = "bio-processing-buildings-alien-a",
        -- module_slots = 4,
        crafting_speed = 4,
        emissions_per_minute = -60,
        energy_usage = "225kW",
    },

    -- Seed extractors
    ["seed-extractor-2"] = {
        source = "seed-extractor",
        icon = "__angelsbioprocessing__/graphics/icons/seed-extractor.png",
        tier = 2,
        order = "aa",
        subgroup = "bio-processing-buildings-vegetabilis-b",
        -- module_slots = 3,
        next_upgrade = "seed-extractor-3",
        crafting_speed = 1.25,
        emissions_per_minute = 0.04 * 60,
        energy_usage = "180kW",
    },

    ["seed-extractor-3"] = {
        source = "seed-extractor",
        icon = "__angelsbioprocessing__/graphics/icons/seed-extractor.png",
        tier = 3,
        order = "ab",
        subgroup = "bio-processing-buildings-vegetabilis-b",
        -- module_slots = 4,
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
    local icons = extangels.numeral_tier({icon = params.icon, icon_size = params.icon_size or 32}, params.tier, params.tint or tint)

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
        util.merge{source_entity, {
            name = name,
            minable = {result = name},
            next_upgrade = params.next_upgrade or nil,
            module_specification = params.module_slots and {module_slots = params.module_slots} or nil,
            crafting_speed = params.crafting_speed or nil,
            energy_source = params.emissions_per_minute and {emissions_per_minute = params.emissions_per_minute} or nil,
            energy_usage = params.energy_usage or nil,
        }},
    })

    -- Set entity icon
    data.raw[params.type and params.type or "assembling-machine"][name].icons = icons

    -- Continue
    ::continue::
end

-- Fix properties for Angel buildings
local buildings = {
    ["algae-farm"] = {prototype = "assembling-machine", tier = 1},
    ["algae-farm-2"] = {prototype = "assembling-machine", tier = 2},
    ["algae-farm-3"] = {prototype = "assembling-machine", tier = 3},
    ["bio-arboretum-1"] = {prototype = "assembling-machine", tier = 1},
    ["bio-generator-temperate-1"] = {prototype = "assembling-machine", tier = 1},
    ["bio-generator-swamp-1"] = {prototype = "assembling-machine", tier = 1},
    ["bio-generator-desert-1"] = {prototype = "assembling-machine", tier = 1},
    ["bio-press"] = {prototype = "assembling-machine", tier = 1, order = "d[bio-press]-a[mk1]"},
    ["bio-processor"] = {prototype = "assembling-machine", tier = 1},
    ["bio-butchery"] = {prototype = "furnace", tier = 1},
    ["composter"] = {prototype = "furnace", tier = 1},
    ["crop-farm"] = {prototype = "assembling-machine", tier = 1},
    ["temperate-farm"] = {prototype = "assembling-machine", tier = 1},
    ["swamp-farm"] = {prototype = "assembling-machine", tier = 1},
    ["desert-farm"] = {prototype = "assembling-machine", tier = 1},
    ["bio-hatchery"] = {prototype = "furnace", tier = 1},
    ["nutrient-extractor"] = {prototype = "assembling-machine", tier = 1, order = "d[nutrient-extractor]-a[mk1]"},
    ["bio-refugium-fish"] = {prototype = "assembling-machine", tier = 1},
    ["bio-refugium-puffer"] = {prototype = "assembling-machine", tier = 1},
    ["bio-refugium-biter"] = {prototype = "assembling-machine", tier = 1},
    ["seed-extractor"] = {prototype = "assembling-machine", tier = 1},
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

        item.icons = extangels.numeral_tier({icon = item_icon, icon_size = item_icon_size}, params.tier, tint)
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

        entity.icons = extangels.numeral_tier({icon = entity_icon, icon_size = entity_icon_size}, params.tier, tint)
    end

    if item and params.order then
        item.order = params.order
    end
end