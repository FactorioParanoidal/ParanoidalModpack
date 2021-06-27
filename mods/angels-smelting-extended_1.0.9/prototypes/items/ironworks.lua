--spent-non-expendable mold
data:extend({
  {
    type = "item",
    name = "ASE-spent-metal-die",
    icons={
      {icon= "__angelssmelting__/graphics/icons/non-expendable-mold.png", icon_size = 32, icon_mipmaps = 1},
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
      {icon="__angelssmelting__/graphics/icons/non-expendable-mold.png",icon_size = 32, icon_mipmaps = 1},
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
      {icon= "__angelssmelting__/graphics/icons/expendable-mold.png",icon_size = 32, icon_mipmaps = 1},
    },
    icon_size = 32,
    subgroup = "angels-mold-casting",
    order = "a-ASE",
    stack_size = 200
  },
})