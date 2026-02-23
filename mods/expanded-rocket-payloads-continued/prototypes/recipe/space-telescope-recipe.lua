data:extend({
    {
        type = "recipe",
        name = "space-telescope",
        category = "satellite-crafting",
        energy_required = 200,
        enabled = false,
        ingredients =
        {
            { type = "item", name = "satellite-battery",         amount = 4 },
            { type = "item", name = "satellite-bus",             amount = 2 },
            { type = "item", name = "satellite-communications",  amount = 5 },
            { type = "item", name = "satellite-flight-computer", amount = 5 },
            { type = "item", name = "satellite-solar-array",     amount = 4 },
            { type = "item", name = "satellite-radar",           amount = 3 },
            { type = "item", name = "satellite-thruster",        amount = 4, },
            { type = "item", name = "telescope-components",      amount = 3 },
        },
        results = { { type = "item", name = "space-telescope", amount = 1 } }
    }
})
