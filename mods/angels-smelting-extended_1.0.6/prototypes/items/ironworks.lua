--spent-non-expendable mold
data:extend({
  {
    type = "item",
    name = "ASE-spent-metal-die",
    icons={
      {icon= "__angelssmelting__/graphics/icons/non-expendable-mold.png", icon_size = 32},
      {icon = "__angelsrefining__/graphics/icons/slag.png",icon_size=32,scale=0.6}--leave in the middle
    },
    icon_size = 32,
    subgroup = "angels-mold-casting",
    order = "c-ASE",
    stack_size = 200
  },
  {
    type = "item",
    name = "ASE-metal-die",
    icons={
      {icon="__angelssmelting__/graphics/icons/non-expendable-mold.png",icon_size = 32},
      {icon="__angelssmelting__/graphics/icons/powder-steel.png",icon_size=32,scale = 0.32,shift = {-12, -12}},
    },
    icon_size=32,
    subgroup = "angels-mold-casting",
    order = "b-ASE",
    stack_size = 200
  },
  {
    type = "item",
    name = "ASE-sand-die",
    icons={
      {icon= "__angelssmelting__/graphics/icons/expendable-mold.png",icon_size = 32,},
      {icon = "__angelsrefining__/graphics/icons/solid-sand.png",icon_size=32,scale = 0.32,shift = {-12, -12}},
    },
    icon_size = 32,
    subgroup = "angels-mold-casting",
    order = "a-ASE",
    stack_size = 200
  },
})