data:extend({
    {
        type = "recipe",
        name = "advanced-probe",
        category = "satellite-crafting",
        energy_required = 200,
        enabled = false,
        ingredients =
        {
            { type = "item", name = "radioisotope-thermoelectric-generator", amount = 1 },
            { type = "item", name = "satellite-bus",                         amount = 1 },
            { type = "item", name = "satellite-communications",              amount = 1 },
            { type = "item", name = "satellite-flight-computer",             amount = 1 },
            { type = "item", name = "satellite-radar",                       amount = 1 },
            { type = "item", name = "satellite-thruster",                    amount = 1 },
        },
        results = { { type = "item", name = "advanced-probe", amount = 1 } }
    }
})
