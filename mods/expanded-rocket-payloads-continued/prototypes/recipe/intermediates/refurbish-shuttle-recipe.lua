local modutils = require("prototypes.modutils")

data:extend({
  {
    type = "recipe",
    name = "refurbish-space-shuttle",
    energy_required = 800,
    enabled = false,
    auto_recycle = false,
    ingredients =
    {
      { type = "fluid", name = "water",             amount = 20000 },
      { type = "item",  name = "landed-shuttle",    amount = 1 },
      { type = "item",  name = "rocket-fuel",       amount = 500 },
      { type = "item",  name = "stone-brick",       amount = 500 },
      { type = "item",  name = "space-lab-payload", amount = 1 },
    },
    results =
    {
      { type = "item", name = "station-science", amount = 2 },
      { type = "item", name = "space-shuttle",   amount = 1 },
    },
    icon = "__expanded-rocket-payloads-continued__/graphic/landed-shuttle-32.png",
    icon_size = 32,
    subgroup = "shuttle-processies",
    order = "b",
    category = "satellite-crafting",
  },
  {
    type = "recipe",
    name = "refurbish-spy-shuttle",
    auto_recycle = false,
    energy_required = 800,
    enabled = false,
    ingredients =
        modutils.select({
          { type = "fluid", name = "water",              amount = 20000 },
          { type = "item",  name = "landed-spy-shuttle", amount = 1 },
          { type = "item",  name = "rocket-fuel",        amount = 500 },
          { type = "item",  name = "stone-brick",        amount = 1000 },
        }, nil, {
          { type = "item", name = modutils.tungsten_plate,   amount = 100 },
          { type = "item", name = modutils.tungsten_carbide, amount = 100 }
        }),
    results =
    {
      { type = "item", name = "spy-shuttle",    amount = 1 },
      { type = "item", name = "planetary-data", amount = 2 },
    },
    icon = "__expanded-rocket-payloads-continued__/graphic/landed-shuttle-32.png",
    icon_size = 32,
    subgroup = "shuttle-processies",
    order = "b",
    category = "satellite-crafting",
  },
})
