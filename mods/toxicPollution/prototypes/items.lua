data:extend({
    {
        type = "armor",
        name = "respirator",
        icon = "__toxicPollution__/graphics/respirator.png",
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
            {"iron-plate", 4},
            {"wood", 4},
            {"coal", 2}
        },
        result = "respirator"
    }
})
