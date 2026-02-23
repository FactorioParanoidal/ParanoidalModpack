local util = require("data-util")

local basic_circuit = data.raw.item["basic-circuit-board"] and "basic-circuit-board" or "electronic-circuit"

-- Bobs

-- Angels

util.conditional_modify({
  type = "recipe",
  name = "burner-ore-crusher",
  ingredients = {
    {type="item", name="stone-brick", amount=4},
    {type="item", name="iron-plate", amount=4},
    {type="item", name="motor", amount=1}
  },
})

util.conditional_modify({
  type = "recipe",
  name = "ore-crusher",
  ingredients = {
    {type="item", name="stone-brick", amount=8},
    {type="item", name="iron-gear-wheel", amount=8},
    {type="item", name="electric-motor", amount=2},
    {type="item", name="burner-ore-crusher", amount=1}
  },
})

util.conditional_modify({
  type = "recipe",
  name = "ore-sorting-facility",
  ingredients = {
    {type="item", name="stone-brick", amount=30},
    {type="item", name="iron-plate", amount=15},
    {type="item", name="electric-motor", amount=5}
  },
})

util.conditional_modify({
  type = "recipe",
  name = "ore-sorting-facility",
  ingredients = {
    {type="item", name="stone-brick", amount=30},
    {type="item", name="iron-plate", amount=15},
    {type="item", name="electric-motor", amount=5}
  },
})

util.conditional_modify({
  type = "recipe",
  name = "ore-floatation-cell",
  ingredients = {
    {type="item", name="steel-plate", amount=10},
    {type="item", name="stone-brick", amount=20},
    {type="item", name=basic_circuit, amount=10},
    {type="item", name="electric-motor", amount=5}
  },
})
