local modutils = require("prototypes.modutils")

data:extend({
    {
        type = "recipe",
        name = "satellite-bus",
        energy_required = 100,
        enabled = false,
        category = "satellite-crafting",
        ingredients =
            modutils.select(
                {
                    { type = "item", name = "copper-cable",          amount = 1000 },
                    { type = "item", name = "electric-engine-unit",  amount = 50 },
                    { type = "item", name = "low-density-structure", amount = 200 },
                }, nil, {

                    { type = "item", name = modutils.holmium_plate,  amount = 200 },
                    { type = "item", name = modutils.tungsten_plate, amount = 200 },
                }),
        results = { { type = "item", name = "satellite-bus", amount = 1 } },
    }
})
