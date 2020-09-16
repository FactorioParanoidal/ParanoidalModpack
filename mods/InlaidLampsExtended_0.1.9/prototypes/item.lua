local IMGPATH = "__InlaidLampsExtended__/graphics/icon/"

data:extend({
  -- Flat Lamp Item
  {
    type = "item",
    name = "flat-lamp",
    icon = IMGPATH .. "flat-lamp.png",
    icon_size = 64,
    icon_mipmaps = 4,
    subgroup = "circuit-network",
    order = "a[InlaidLampsExtended]-u[flat-lamp]",
    place_result = "flat-lamp",
    stack_size = 50
  },
  -- 2x2 Flat Lamp Item
  {
    type = "item",
    name = "flat-lamp-big",
    icon = IMGPATH .. "flat-lamp-big.png",
    icon_size = 64,
    icon_mipmaps = 4,
    subgroup = "circuit-network",
    order = "a[InlaidLampsExtended]-v[flat-lamp-big]",
    place_result = "flat-lamp-big",
    stack_size = 50
  }
})
