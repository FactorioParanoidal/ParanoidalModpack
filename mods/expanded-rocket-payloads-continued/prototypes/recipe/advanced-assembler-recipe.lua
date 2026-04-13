local modutils = require("prototypes.modutils")

--For advanced assembler entity. Nessesary to produce satellite components. Expensive.

data:extend({
  {
    type = "recipe",
    name = "advanced-assembler",
    enabled = false,
    energy_required = 180,
    auto_recycle = false,
    ingredients =
        modutils.select(
          {
            { type = "item", name = "assembling-machine-3", amount = 20 },
            { type = "item", name = "concrete",             amount = 400 },
            { type = "item", name = "bulk-inserter",        amount = 10 },
          }, {
            { type = "item", name = "steel-plate",     amount = 400 },
            { type = "item", name = "processing-unit", amount = 200 },
          }, {
            { type = "item", name = modutils.tungsten_plate,    amount = 400 },
            { type = "item", name = modutils.quantum_processor, amount = 200 },
          }),
    results = { { type = "item", name = "advanced-assembler", amount = 1 } },
    icon = "__expanded-rocket-payloads-continued__/graphic/advanced-assembler-32.png",
    icon_size = 32,
    subgroup = "buildings",
    order = "a"
  },
})
