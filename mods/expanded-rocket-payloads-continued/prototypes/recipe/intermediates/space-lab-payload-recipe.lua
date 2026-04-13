local modutils = require("prototypes.modutils")

data:extend({
    {
        type = "recipe",
        name = "space-lab-payload",
        category = "satellite-crafting",
        energy_required = 100,
        enabled = false,
        ingredients =
            modutils.select(
                {
                    { type = "item", name = "satellite-battery",         amount = 1 },
                    { type = "item", name = "satellite-bus",             amount = 1 },
                    { type = "item", name = "satellite-communications",  amount = 1 },
                    { type = "item", name = "satellite-flight-computer", amount = 1 },
                    { type = "item", name = "satellite-solar-array",     amount = 1 },
                }, {
                    { type = "item", name = "lab", amount = 200 },
                },
                {
                    { type = "item", name = modutils.biolab, amount = 200 },
                }),
        results = { { type = "item", name = "space-lab-payload", amount = 1 } }
    }
})
