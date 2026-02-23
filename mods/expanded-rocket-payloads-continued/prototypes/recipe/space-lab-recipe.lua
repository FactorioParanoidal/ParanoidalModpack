--one of the first compoents of the mod created. When I first started work on the mod it was just called space-lab

data:extend({
    {
        type = "recipe",
        name = "space-lab",
        category = "satellite-crafting",
        energy_required = 50,
        enabled = false,
        ingredients =
        {
            { type = "item", name = "satellite-battery",         amount = 2 },
            { type = "item", name = "satellite-bus",             amount = 1 },
            { type = "item", name = "satellite-communications",  amount = 1 },
            { type = "item", name = "satellite-flight-computer", amount = 1 },
            { type = "item", name = "satellite-solar-array",     amount = 2 },
            { type = "item", name = "satellite-radar",           amount = 1 },
            { type = "item", name = "satellite-thruster",        amount = 2 },
            { type = "item", name = "space-lab-payload",         amount = 1 },
        },
        results = { { type = "item", name = "space-lab", amount = 1 } }
    }
})
