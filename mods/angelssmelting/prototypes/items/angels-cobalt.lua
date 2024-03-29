data:extend({
  --ORE
  {
    type = "item",
    name = "cobalt-ore",
    icon = "__angelssmelting__/graphics/icons/ore-cobalt.png",
    icon_size = 32,
    subgroup = "angels-cobalt",
    order = "a",
    stack_size = 200,
  },
  -- SMELTING INTERMEDIATE
  {
    type = "item",
    name = "processed-cobalt",
    icon = "__angelssmelting__/graphics/icons/processed-cobalt.png",
    icon_size = 64,
    icon_mipmaps = 4,
    subgroup = "angels-cobalt",
    order = "b",
    stack_size = 200,
  },
  {
    type = "item",
    name = "pellet-cobalt",
    icon = "__angelssmelting__/graphics/icons/pellet-cobalt.png",
    icon_size = 64,
    icon_mipmaps = 4,
    subgroup = "angels-cobalt",
    order = "c",
    stack_size = 200,
  },
  {
    type = "item",
    name = "solid-cobalt-hydroxide",
    icon = "__angelssmelting__/graphics/icons/solid-cobalt-hydroxide.png",
    icon_size = 32,
    subgroup = "angels-cobalt",
    order = "d",
    stack_size = 200,
  },
  {
    type = "item",
    name = "solid-cobalt-oxide",
    icon = "__angelssmelting__/graphics/icons/solid-cobalt-oxide.png",
    icon_size = 32,
    subgroup = "angels-cobalt",
    order = "e",
    stack_size = 200,
  },
  -- SMELTING RESULTS
  {
    type = "item",
    name = "ingot-cobalt",
    icon = "__angelssmelting__/graphics/icons/ingot-cobalt.png",
    icon_size = 64,
    icon_mipmaps = 4,
    subgroup = "angels-cobalt",
    order = "f",
    stack_size = 200,
  },
  {
    type = "item",
    name = "powder-cobalt",
    icon = "__angelssmelting__/graphics/icons/powder-cobalt.png",
    icon_size = 64,
    icon_mipmaps = 4,
    subgroup = "angels-cobalt",
    order = "g",
    stack_size = 200,
  },
  -- CASTING INTERMEDIATE
  {
    type = "fluid",
    name = "liquid-molten-cobalt",
    icon = "__angelssmelting__/graphics/icons/molten-cobalt.png",
    icon_size = 64,
    icon_mipmaps = 4,
    subgroup = "angels-cobalt-casting",
    order = "h",
    default_temperature = 1495,
    heat_capacity = "0KJ",
    base_color = { r = 51 / 255, g = 74 / 255, b = 109 / 255 },
    flow_color = { r = 51 / 255, g = 74 / 255, b = 109 / 255 },
    max_temperature = 1495,
    auto_barrel = false,
  },
  {
    type = "item",
    name = "angels-roll-cobalt",
    icon = "__angelssmelting__/graphics/icons/roll-cobalt.png",
    icon_size = 64,
    icon_mipmaps = 4,
    subgroup = "angels-cobalt-casting",
    order = "i",
    stack_size = 200,
  },
  -- CASTING RESULT
  {
    type = "item",
    name = "angels-plate-cobalt",
    icon = "__angelssmelting__/graphics/icons/plate-cobalt.png",
    icon_size = 32,
    subgroup = "angels-cobalt-casting",
    order = "j",
    stack_size = 200,
  },
})
