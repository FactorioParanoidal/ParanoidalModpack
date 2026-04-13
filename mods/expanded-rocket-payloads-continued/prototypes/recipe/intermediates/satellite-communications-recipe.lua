local modutils = require("prototypes.modutils")

data:extend({
    {
        type = "recipe",
        name = "satellite-communications",
        category = "satellite-crafting",
        energy_required = 100,
        enabled = false,
        ingredients =
            modutils.select(
                {
                    { type = "item", name = "beacon",                amount = 5 },
                    { type = "item", name = "electric-engine-unit",  amount = 10 },
                    { type = "item", name = "low-density-structure", amount = 20 },
                    { type = "item", name = "processing-unit",       amount = 10 },
                    { type = "item", name = "roboport",              amount = 5 },
                }, nil, {

                    { type = "item", name = modutils.holmium_plate,  amount = 20 },
                    { type = "item", name = modutils.superconductor, amount = 10 },
                }),
        results = { { type = "item", name = "satellite-communications", amount = 1 } }
    }
})
