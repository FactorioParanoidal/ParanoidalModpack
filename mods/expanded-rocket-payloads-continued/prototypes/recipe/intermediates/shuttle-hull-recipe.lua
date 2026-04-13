local modutils = require("prototypes.modutils")

data:extend({
    {
        type = "recipe",
        name = "shuttle-hull-recipe",
        category = "satellite-crafting",
        energy_required = 480,
        enabled = false,
        auto_recycle = false,
        ingredients =
            modutils.select(
                {
                    { type = "item", name = "satellite-battery",         amount = 40 },
                    { type = "item", name = "satellite-bus",             amount = 70 },
                    { type = "item", name = "satellite-communications",  amount = 20 },
                    { type = "item", name = "satellite-flight-computer", amount = 50 },
                    { type = "item", name = "satellite-solar-array",     amount = 50 },
                    { type = "item", name = "satellite-radar",           amount = 30 },
                    { type = "item", name = "stone-brick",               amount = 50000 },
                    { type = "item", name = "plastic-bar",               amount = 10000 },

                }, nil, {
                    { type = "item", name = modutils.tungsten_plate, amount = 10000 },
                }),
        results = { { type = "item", name = "shuttle-hull", amount = 1 } }
    }
})
