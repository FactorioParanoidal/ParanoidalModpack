local modutils = require("prototypes.modutils")

data:extend({
  {
    type = "recipe",
    name = "refurbish-mining-shuttle",
    energy_required = 2400,
    enabled = false,
    ingredients =
        modutils.select(
          {
            { type = "fluid", name = "water",                 amount = 20000 },
            { type = "item",  name = "landed-mining-shuttle", amount = 1 },
            { type = "item",  name = "rocket-fuel",           amount = 1000 },
            { type = "item",  name = "stone-brick",           amount = 2000 },
          }, nil,
          { { type = "item", name = modutils.tungsten_plate, amount = 100 },
            { type = "item", name = modutils.tungsten_carbide, amount = 100 }
          }
        )
    ,
    results =
        modutils.select(
          {
            { type = "item", name = "copper-dropship", amount = 7500 },
            { type = "item", name = "iron-dropship",   amount = 10000 },
            { type = "item", name = "mining-shuttle",  amount = 1 },
          }, nil, {
            { type = "item", name = "multiore-dropship", amount = 5000 },
          }),
    icon = "__expanded-rocket-payloads-continued__/graphic/landed-mining-shuttle-32.png",
    icon_size = 32,
    subgroup = "shuttle-processies",
    order = "b",
    category = "satellite-crafting",
  },
})
