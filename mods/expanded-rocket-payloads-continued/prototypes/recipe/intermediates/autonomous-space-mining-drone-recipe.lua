local modutils = require("prototypes.modutils")

data:extend({
    {
        type = "recipe",
        name = "autonomous-space-mining-drone",
        energy_required = 100,
        enabled = false,
        ingredients = modutils.select(
            {
                { type = "item", name = "assembling-machine-3",                  amount = 100 },
                { type = "item", name = "radioisotope-thermoelectric-generator", amount = 100 },
                { type = "item", name = "electric-mining-drill",                 amount = 1000 },
                { type = "item", name = "rocket-fuel",                           amount = 200 },
                { type = "item", name = "satellite-bus",                         amount = 30 },
                { type = "item", name = "satellite-flight-computer",             amount = 50 },
                { type = "item", name = "satellite-communications",              amount = 1 },
                { type = "item", name = "satellite-radar",                       amount = 10 },
                { type = "item", name = "satellite-thruster",                    amount = 10 },
                { type = "item", name = "bulk-inserter",                         amount = 100 },
            }, nil
            , {
                { type = "item", name = modutils.asteroid_collector, amount = 100 },
                { type = "item", name = modutils.crusher,            amount = 100 },
            }),

        results = { { type = "item", name = "autonomous-space-mining-drone", amount = 1 } },
        category = "satellite-crafting",
    }
})
