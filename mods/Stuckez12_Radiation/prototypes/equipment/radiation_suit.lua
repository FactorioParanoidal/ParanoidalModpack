data:extend({
    {
        type = "armor",
        name = "radiation-suit",
        icon = "__Stuckez12_Radiation__/graphics/icon/radiation-suit.png",
        icon_size = 128,
        resistances =
        {
            {
                type = "Stuckez12-radiation",
                decrease = 250,
                percent = 95
            }
        },
        subgroup = "armor",
        order = "a[armor]-b[speed]",
        stack_size = 1,
        equipment_grid = "medium-equipment-grid",
        inventory_size_bonus = 20,
        infinite = true,
        hidden = true
    },
    {
        type = "recipe",
        name = "radiation-suit-recipe",
        enabled = false,
        energy_required = 5,
        ingredients = {
            {type = "item", name = "battery", amount = 10},
            {type = "item", name = "iron-plate", amount = 300},
            {type = "item", name = "copper-plate", amount = 200},
            {type = "item", name = "steel-plate", amount = 150},
        },
        results = {
            { type = "item", name = "radiation-suit", amount = 1 }
        }
    }
})


table.insert(data.raw.character["character"].animations[2].armors, "radiation-suit")
