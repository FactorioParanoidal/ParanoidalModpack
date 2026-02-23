local modutils = require("prototypes.modutils")

data:extend({
  {
    type = "recipe",
    name = "erp-lab",
    energy_required = 20,
    subgroup = "buildings",
    enabled = false,
    ingredients =
        modutils.select(
          {
            { type = "item", name = "electronic-circuit", amount = 200 },
            { type = "item", name = "advanced-circuit",   amount = 100 },
            { type = "item", name = "steel-plate",        amount = 100 },
          }, {
            { type = "item", name = "processing-unit", amount = 50 },
          }, {
            { type = "item", name = modutils.quantum_processor, amount = 50 },
            { type = "item", name = modutils.tungsten_plate,    amount = 100 },
          }),
    results = { { type = "item", name = "erp-lab", amount = 1 } }
  }
})
