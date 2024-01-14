data:extend({
    -- Advanced Chemical Plant
    {
        type = "item",
        name = "advanced-chemical-plant-3",
        icons = extangels.numeral_tier({ icon = "__angelspetrochem__/graphics/icons/advanced-chemical-plant.png", icon_size = 32 }, 3, angelsmods.petrochem.number_tint),
        subgroup = "petrochem-buildings-chemical-plant",
        order = "b[advanced]-c",
        place_result = "advanced-chemical-plant-3",
        stack_size = 10,
    },

    util.merge { data.raw["assembling-machine"]["advanced-chemical-plant"], {
        name = "advanced-chemical-plant-3",
        minable = { result = "advanced-chemical-plant-3" },
        module_specification = { module_slots = 4 },
        crafting_speed = 3.5,
        energy_source = { emissions_per_minute = 0.1 * 60 },
        energy_usage = "500kW",
    } },

    -- Air filter 4
    {
        type = "item",
        name = "angels-air-filter-4",
        icons = extangels.numeral_tier({ icon = "__angelspetrochem__/graphics/icons/air-filter.png", icon_size = 32 }, 4, angelsmods.petrochem.number_tint),
        subgroup = "petrochem-buildings-electrolyser",
        order = "b[angels-air-filter]-d",
        place_result = "angels-air-filter-4",
        stack_size = 10,
    },

    util.merge { data.raw["assembling-machine"]["angels-air-filter"], {
        name = "angels-air-filter-4",
        minable = { result = "angels-air-filter-4" },
        module_specification = { module_slots = 4 },
        crafting_speed = 4,
        energy_source = { emissions_per_minute = -0.16 * 60 },
        energy_usage = "300kW",
    } },
})

-- Next upgrade fixes, due to util.merge usage
data.raw["assembling-machine"]["advanced-chemical-plant-3"].next_upgrade = nil
data.raw["assembling-machine"]["angels-air-filter-4"].next_upgrade = nil

-- Entity icon adjustments
data.raw["assembling-machine"]["advanced-chemical-plant-3"].icons = extangels.numeral_tier({ icon = "__angelspetrochem__/graphics/icons/advanced-chemical-plant.png", icon_size = 32 }, 3, angelsmods.petrochem.number_tint)
data.raw["assembling-machine"]["angels-air-filter-4"].icons = extangels.numeral_tier({ icon = "__angelspetrochem__/graphics/icons/air-filter.png", icon_size = 32 }, 4, angelsmods.petrochem.number_tint)
