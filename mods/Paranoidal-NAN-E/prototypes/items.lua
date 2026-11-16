local shared = require("shared")

local icons = shared.mod .. "/graphics/icons/"

data:extend
{
  {
    -- A refurbished NAN-E in her BnL box: placed, she boots up for whoever placed her (one per engineer).
    type = "item",
    name = shared.item,
    icon = icons .. "nan-e.png",
    subgroup = "logistic-network",
    order = "z[nan-e]",
    place_result = shared.husk,
    stack_size = 1
  },
  {
    -- A bedtime story on a card, written in one of her 47 dialects: one fragment of her memory each.
    type = "item",
    name = shared.card,
    icon = icons .. "memory-card.png",
    subgroup = "logistic-network",
    order = "z[nan-e]-b[card]",
    stack_size = 50
  },
  {
    -- The colony's keepsake from the last camp. Does nothing; it is a drawing.
    type = "item",
    name = shared.drawing,
    icon = icons .. "drawing.png",
    subgroup = "logistic-network",
    order = "z[nan-e]-c[drawing]",
    stack_size = 1
  },
  {
    type = "recipe",
    name = shared.item,
    enabled = false,
    energy_required = 10,
    ingredients =
    {
      {type = "item", name = "electronic-circuit", amount = 10},
      {type = "item", name = "iron-gear-wheel", amount = 6},
      {type = "item", name = "iron-plate", amount = 10},
      {type = "item", name = "copper-cable", amount = 10}
    },
    results = {{type = "item", name = shared.item, amount = 1}}
  }
}
