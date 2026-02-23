data:extend({
    {
        type = "recipe",
        name = "observation-satellite",
        category = "satellite-crafting",
        energy_required = 100,
        enabled = false,
        ingredients =
        {
            { type = "item", name = "satellite-battery",         amount = 4 },
            { type = "item", name = "satellite-bus",             amount = 3 },
            { type = "item", name = "satellite-communications",  amount = 4 },
            { type = "item", name = "satellite-flight-computer", amount = 4 },
            { type = "item", name = "satellite-solar-array",     amount = 4 },
            { type = "item", name = "satellite-radar",           amount = 5 },
            { type = "item", name = "satellite-thruster",        amount = 3, },
        },
        results = { { type = "item", name = "observation-satellite", amount = 1 } }
    }
})
