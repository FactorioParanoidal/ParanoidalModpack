data:extend({
    -- Hydro plant 4
    {
        type = "item",
        name = "hydro-plant-4",
        icons = extangels.numeral_tier({icon = "__angelsrefining__/graphics/icons/hydro-plant.png", icon_size = 32}, 4, angelsmods.refining.number_tint),
        subgroup = "water-treatment-building",
        order = "a[hydro-plant]-d[mk4]",
        place_result = "hydro-plant-4",
        stack_size = 10,
    },

    util.merge{data.raw["assembling-machine"]["hydro-plant"], {
        name = "hydro-plant-4",
        minable = {result = "hydro-plant-4"},
        module_specification = {module_slots = 4},
        crafting_speed = 4,
        energy_source = {emissions_per_minute = 0.06 * 60},
        energy_usage = "300kW",
    }},

    -- Salination plant 3
    {
        type = "item",
        name = "salination-plant-3",
        icons = extangels.numeral_tier({icon = "__angelsrefining__/graphics/icons/salination-plant.png", icon_size = 32}, 3, angelsmods.refining.number_tint),
        subgroup = "water-treatment-building",
        order = "f[salination-plant3]",
        place_result = "salination-plant-3",
        stack_size = 10,
    },

    util.merge{data.raw["assembling-machine"]["salination-plant"], {
        name = "salination-plant-3",
        minable = {result = "salination-plant-3"},
        module_specification = {module_slots = 3},
        crafting_speed = 3,
        energy_source = {emissions_per_minute = 0.05 * 60},
        energy_usage = "300kW",
    }},

    -- Washing plant 3
    {
        type = "item",
        name = "washing-plant-3",
        icons = extangels.numeral_tier({icon = "__angelsrefining__/graphics/icons/washing-plant-ico.png", icon_size = 32}, 3, angelsmods.refining.number_tint),
        subgroup = "washing-building",
        order = "b[washing-plant]-c[mk3]",
        place_result = "washing-plant-3",
        stack_size = 10,
    },

    util.merge{data.raw["assembling-machine"]["washing-plant"], {
        name = "washing-plant-3",
        minable = {result = "washing-plant-3"},
        next_upgrade = "washing-plant-4",
        module_specification = {module_slots = 3},
        crafting_speed = 3,
        energy_source = {emissions_per_minute = 0.05 * 60},
        energy_usage = "200kW",
    }},

    -- Washing plant 4
    {
        type = "item",
        name = "washing-plant-4",
        icons = extangels.numeral_tier({icon = "__angelsrefining__/graphics/icons/washing-plant-ico.png", icon_size = 32}, 4, angelsmods.refining.number_tint),
        subgroup = "washing-building",
        order = "b[washing-plant]-d[mk4]",
        place_result = "washing-plant-4",
        stack_size = 10,
    },

    util.merge{data.raw["assembling-machine"]["washing-plant"], {
        name = "washing-plant-4",
        minable = {result = "washing-plant-4"},
        module_specification = {module_slots = 4},
        crafting_speed = 4,
        energy_source = {emissions_per_minute = 0.06 * 60},
        energy_usage = "250kW",
    }},

    -- Ore crusher 4
    {
        type = "item",
        name = "ore-crusher-4",
        icons = extangels.numeral_tier({icon = "__extendedangels__/graphics/icons/ore-crusher-4.png", icon_size = 32}, 5, angelsmods.refining.number_tint),
        subgroup = "ore-crusher",
        order = "e[ore-crusher-4]",
        place_result = "ore-crusher-4",
        stack_size = 10,
    },

    util.merge{data.raw["assembling-machine"]["ore-crusher-3"], {
        name = "ore-crusher-4",
        minable = {result = "ore-crusher-4"},
        module_specification = {module_slots = 4},
        crafting_speed = 4,
        energy_source = {emissions_per_minute = 0.06 * 60},
        energy_usage = "175kW",
    }},

    -- Ore floatation cell 4
    {
        type = "item",
        name = "ore-floatation-cell-4",
        icons = extangels.numeral_tier({icon = "__extendedangels__/graphics/icons/ore-floatation-cell-4.png", icon_size = 32}, 4, angelsmods.refining.number_tint),
        subgroup = "ore-floatation",
        order = "d[ore-floatation-cell-4]",
        place_result = "ore-floatation-cell-4",
        stack_size = 10,
    },

    util.merge{data.raw["assembling-machine"]["ore-floatation-cell-3"], {
        name = "ore-floatation-cell-4",
        minable = {result = "ore-floatation-cell-4"},
        module_specification = {module_slots = 4},
        crafting_speed = 2,
        energy_source = {emissions_per_minute = 0.05 * 60},
        energy_usage = "350kW",
    }},

    -- Ore leaching plant 4
    {
        type = "item",
        name = "ore-leaching-plant-4",
        icons = extangels.numeral_tier({icon = "__extendedangels__/graphics/icons/ore-leaching-plant-4.png", icon_size = 32}, 4, angelsmods.refining.number_tint),
        subgroup = "ore-leaching",
        order = "d[ore-leaching-plant-4]",
        place_result = "ore-leaching-plant-4",
        stack_size = 10,
    },

    util.merge{data.raw["assembling-machine"]["ore-leaching-plant-3"], {
        name = "ore-leaching-plant-4",
        minable = {result = "ore-leaching-plant-4"},
        module_specification = {module_slots = 4},
        crafting_speed = 2,
        energy_source = {emissions_per_minute = 0.07 * 60},
        energy_usage = "350kW",
    }},

    -- Ore refinery 3
    {
        type = "item",
        name = "ore-refinery-3",
        icons = extangels.numeral_tier({icon = "__angelsrefining__/graphics/icons/ore-refinery.png", icon_size = 32}, 3, angelsmods.refining.number_tint),
        subgroup = "ore-refining",
        order = "c[ore-refinery-3]",
        place_result = "ore-refinery-3",
        stack_size = 10,
    },

    util.merge{data.raw["assembling-machine"]["ore-refinery-2"], {
        name = "ore-refinery-3",
        minable = {result = "ore-refinery-3"},
        module_specification = {module_slots = 3},
        crafting_speed = 2,
        energy_source = {emissions_per_minute = 0.04 * 60},
        energy_usage = "400kW",
    }},

    -- Crystallizer 3
    {
        type = "item",
        name = "crystallizer-3",
        icons = extangels.numeral_tier({icon = "__angelsrefining__/graphics/icons/crystallizer.png", icon_size = 32}, 3, angelsmods.refining.number_tint),
        subgroup = "refining-buildings",
        order = "c[crystallizer]-c[mk3]",
        place_result = "crystallizer-3",
        stack_size = 10,
    },

    util.merge{data.raw["assembling-machine"]["crystallizer"], {
        name = "crystallizer-3",
        minable = {result = "crystallizer-3"},
        module_specification = {module_slots = 3},
        crafting_speed = 3,
        energy_source = {emissions_per_minute = 0.05 * 60},
        energy_usage = "350kW",
    }},

    -- Filtration unit 3
    {
        type = "item",
        name = "filtration-unit-3",
        icons = extangels.numeral_tier({icon = "__angelsrefining__/graphics/icons/filtration-unit.png", icon_size = 32}, 3, angelsmods.refining.number_tint),
        subgroup = "refining-buildings",
        order = "b[filtration-unit]-c[mk3]",
        place_result = "filtration-unit-3",
        stack_size = 10,
    },

    util.merge{data.raw["assembling-machine"]["filtration-unit-2"], {
        name = "filtration-unit-3",
        minable = {result = "filtration-unit-3"},
        module_specification = {module_slots = 3},
        crafting_speed = 3,
        energy_source = {emissions_per_minute = 0.05 * 60},
        energy_usage = "200kW",
    }},
})

-- Item order fixes
data.raw.item["hydro-plant"].order = "a[hydro-plant]-a[mk1]"
data.raw.item["hydro-plant-2"].order = "a[hydro-plant]-b[mk2]"
data.raw.item["hydro-plant-3"].order = "a[hydro-plant]-c[mk3]"
data.raw.item["washing-plant"].order = "b[washing-plant]-a[mk1]"
data.raw.item["washing-plant-2"].order = "b[washing-plant]-b[mk2]"

-- Entity icon adjustments
data.raw["assembling-machine"]["hydro-plant-4"].icons = extangels.numeral_tier({icon = "__angelsrefining__/graphics/icons/hydro-plant.png", icon_size = 32}, 4, angelsmods.refining.number_tint)
data.raw["assembling-machine"]["salination-plant-3"].icons = extangels.numeral_tier({icon = "__angelsrefining__/graphics/icons/salination-plant.png", icon_size = 32}, 3, angelsmods.refining.number_tint)
data.raw["assembling-machine"]["washing-plant-3"].icons = extangels.numeral_tier({icon = "__angelsrefining__/graphics/icons/washing-plant-ico.png", icon_size = 32}, 3, angelsmods.refining.number_tint)
data.raw["assembling-machine"]["washing-plant-4"].icons = extangels.numeral_tier({icon = "__angelsrefining__/graphics/icons/washing-plant-ico.png", icon_size = 32}, 4, angelsmods.refining.number_tint)
data.raw["assembling-machine"]["ore-crusher-4"].icons = extangels.numeral_tier({icon = "__extendedangels__/graphics/icons/ore-crusher-4.png", icon_size = 32}, 5, angelsmods.refining.number_tint)
data.raw["assembling-machine"]["ore-floatation-cell-4"].icons = extangels.numeral_tier({icon = "__extendedangels__/graphics/icons/ore-floatation-cell-4.png", icon_size = 32}, 4, angelsmods.refining.number_tint)
data.raw["assembling-machine"]["ore-leaching-plant-4"].icons = extangels.numeral_tier({icon = "__extendedangels__/graphics/icons/ore-leaching-plant-4.png", icon_size = 32}, 4, angelsmods.refining.number_tint)
data.raw["assembling-machine"]["ore-refinery-3"].icons = extangels.numeral_tier({icon = "__extendedangels__/graphics/icons/ore-refinery-3.png", icon_size = 32}, 3, angelsmods.refining.number_tint)
data.raw["assembling-machine"]["crystallizer-3"].icons = extangels.numeral_tier({icon = "__angelsrefining__/graphics/icons/crystallizer.png", icon_size = 32}, 3, angelsmods.refining.number_tint)
data.raw["assembling-machine"]["filtration-unit-3"].icons = extangels.numeral_tier({icon = "__angelsrefining__/graphics/icons/filtration-unit.png", icon_size = 32}, 3, angelsmods.refining.number_tint)

-- Entity tint adjustments
if data.raw["assembling-machine"]["hydro-plant-3"].animation.layers then
    data.raw["assembling-machine"]["hydro-plant-3"].animation.layers[2].tint = {r = 0.50, g = 0.1, b = 0.05} -- Red
end

if data.raw["assembling-machine"]["hydro-plant-4"].animation.layers then
    data.raw["assembling-machine"]["hydro-plant-4"].animation.layers[2].tint = {r = 0.70, g = 0.50, b = 0} -- Yellow
end

if data.raw["assembling-machine"]["ore-crusher-4"].animation.layers then
    data.raw["assembling-machine"]["ore-crusher-4"].animation.layers[2].tint = {r = 0.70, g = 0.50, b = 0} -- Yellow
end

if data.raw["assembling-machine"]["ore-floatation-cell-4"].animation.layers then
    data.raw["assembling-machine"]["ore-floatation-cell-4"].animation.layers[2].tint = {r = 0.70, g = 0.50, b = 0} -- Yellow
end

if data.raw["assembling-machine"]["ore-leaching-plant-4"].animation.layers then
    data.raw["assembling-machine"]["ore-leaching-plant-4"].animation.layers[2].tint = {r = 0.70, g = 0.50, b = 0} -- Yellow
end

if data.raw["assembling-machine"]["ore-refinery-3"].animation.layers then
    data.raw["assembling-machine"]["ore-refinery-3"].animation.layers[2].tint = {r = 0.50, g = 0.1, b = 0.05} -- Red
end