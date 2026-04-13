data:extend({
    {
        type = "recipe",
        name = "orbital-solar-collector",
        category = "satellite-crafting",
        energy_required = 100,
        enabled = false,
        ingredients =
        {
            { type = "item", name = "satellite-battery",         amount = 20 },
            { type = "item", name = "satellite-bus",             amount = 1 },
            { type = "item", name = "satellite-communications",  amount = 10 },
            { type = "item", name = "satellite-flight-computer", amount = 2 },
            { type = "item", name = "satellite-solar-array",     amount = 250 },
            { type = "item", name = "satellite-radar",           amount = 1 },
            { type = "item", name = "satellite-thruster",        amount = 10 },
        },
        results = { { type = "item", name = "orbital-solar-collector", amount = 1 } }
    }
})
