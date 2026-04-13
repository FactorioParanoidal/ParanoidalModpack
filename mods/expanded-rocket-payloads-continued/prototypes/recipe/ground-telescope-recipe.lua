local modutils = require("prototypes.modutils")

data:extend({
  {
    type = "recipe",
    name = "ground-telescope",
    category = "satellite-crafting",
    enabled = false,
    ingredients =
        modutils.select(
          {
            { type = "item", name = "concrete",             amount = 1000 },
            { type = "item", name = "pipe",                 amount = 1000 },
            { type = "item", name = "electric-engine-unit", amount = 1000 },
            { type = "item", name = "telescope-components", amount = 1 },
          }, {
            { type = "item", name = "steel-plate",     amount = 2000 },
            { type = "item", name = "processing-unit", amount = 500 },
          }, {
            { type = "item", name = modutils.tungsten_plate,    amount = 2000 },
            { type = "item", name = modutils.quantum_processor, amount = 500 },
          }),
    energy_required = 180,
    results = { { type = "item", name = "ground-telescope", amount = 1 } },
  },
})
