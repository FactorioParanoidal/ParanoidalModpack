local modutils = require("prototypes.modutils")

data:extend({
    {
        type = "recipe",
        name = "telescope-components",
        category = "satellite-crafting",
        energy_required = 100,
        enabled = false,
        auto_recycle = false,
        ingredients =
            modutils.select(
                {
                    { type = "item", name = "electric-engine-unit",      amount = 50 },
                    { type = "item", name = "low-density-structure",     amount = 100 },
                    { type = "item", name = "radar",                     amount = 2000 },
                    { type = "item", name = "satellite-flight-computer", amount = 10 },
                    { type = "item", name = "stone-brick",               amount = 10000 },
                }, {
                    { type = "item", name = "lab", amount = 100 },
                }, {
                    { type = "item", name = modutils.biolab,         amount = 100 },
                    { type = "item", name = modutils.tungsten_plate, amount = 100 },
                }),
        results = { { type = "item", name = "telescope-components", amount = 1 } }
    }
})
