local modutils = require("prototypes.modutils")

data:extend({
    {
        type = "recipe",
        name = "radioisotope-thermoelectric-generator",
        energy_required = 150,
        enabled = false,
        ingredients =
        modutils.select(
        {
            { type = "item", name = "processing-unit", amount = 100 },
            { type = "item", name = "steel-plate",         amount = 100 },
            { type = "item", name = "substation",          amount = 10 },
            { type = "item", name = "uranium-fuel-cell",   amount = 100 },
        }, nil, {

            { type = "item", name = modutils.fusion_power_cell,   amount = 100 },
            { type = "item", name = modutils.tungsten_plate,   amount = 100 },
            { type = "item", name = modutils.quantum_processor,   amount = 50 },
        }),
        results = { { type = "item", name = "radioisotope-thermoelectric-generator", amount = 1 } },
        category = "satellite-crafting",
    }
})
