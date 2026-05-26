data:extend({
    {
        type = "armor",
        name = "respirator",
        icon = "__toxicPollution2__/graphics/respirator.png",
        icon_size = 128,
        resistances = {
            {type = "physical",     decrease = 0, percent = 0},
            {type = "acid",         decrease = 0, percent = 0},
            {type = "explosion",    decrease = 0, percent = 0},
            {type = "fire",         decrease = 0, percent = 0},
            {type = "toxin",        decrease = 0, percent = 5}
        },
        durability = 100,
        subgroup = "armor",
        order = "f[hazard]",
        stack_size = 10
    },
    {
        type = "recipe",
        name = "respirator",
        enabled = true,
        ingredients = {
            { type = "item", name = "iron-plate", amount = 4 },
            { type = "item", name = "wood",       amount = 4 },
            { type = "item", name = "coal",       amount = 2 },
        },
        results = { { type = "item", name = "respirator", amount = 1 } }
    }
})
