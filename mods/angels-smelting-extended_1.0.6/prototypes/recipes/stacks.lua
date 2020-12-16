if mods["angelsindustries"] and angelsmods.industries.components then
    -- Add the recipes directly since there's only one intermediate to add right now
    data:extend({
        {
            type = "recipe",
            name = "girder-stack-casting",
            category = "strand-casting",
            subgroup = "angels-iron-casting",
            energy_required = 4,
            enabled = false,
            ingredients = {
                { type = "fluid", name = "liquid-molten-iron", amount = 60 },
                { type = "fluid", name = "water", amount = 40 }
            },
            results =
            {
                { type = "item", name = "angels-girder-stack", amount = 2 },
            },
        },
        {
            type = "recipe",
            name = "girder-stack-casting-fast",
            category = "strand-casting",
            subgroup = "angels-iron-casting",
            energy_required = 2,
            enabled = false,
            ingredients = {
                { type = "fluid", name = "liquid-molten-iron", amount = 110 },
                { type = "fluid", name = "liquid-coolant", amount = 40, maximum_temperature = 50 }
            },
            results =
            {
                { type = "item", name = "angels-girder-stack", amount = 4 },
                { type = "fluid", name = "liquid-coolant-used", amount = 40, temperature = 300 }
            },
            main_product = "angels-girder-stack"
        },
        {
            type = "recipe",
            name = "angels-girder-stack-converting",
            category = "advanced-crafting",
            subgroup = "angels-iron-casting",
            energy_required = 0.5,
            enabled = false,
            allow_decomposition = false,
            ingredients = {
                {type = "item", name = "angels-girder-stack", amount = 1}
            },
            results = {
                {type = "item", name = "angels-girder", amount = 4}
            },
            icons = {
                {
                    icon = "__angelsindustries__/graphics/icons/girder.png"
                },
                {
                    icon = "__angels-smelting-extended__/graphics/icons/girder-stack.png",
                    scale = 0.4375,
                    shift = {-10, -10}
                }
            },
            icon_size = 32,
            order = "m[angels-girder]-b"
        }
    })
end