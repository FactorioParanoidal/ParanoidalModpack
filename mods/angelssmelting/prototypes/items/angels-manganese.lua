data:extend({
  -- ORE
  {
    type = "item",
    name = "manganese-ore",
    icon = "__angelssmelting__/graphics/icons/ore-manganese.png",
    icon_size = 32,
    subgroup = "angels-manganese",
    order = "a",
    stack_size = 200,
  },
  -- SMELTING INTERMEDIATE
  {
    type = "item",
    name = "processed-manganese",
    icon = "__angelssmelting__/graphics/icons/processed-manganese.png",
    icon_size = 64,
    icon_mipmaps = 4,
    subgroup = "angels-manganese",
    order = "b",
    stack_size = 200,
  },
  {
    type = "item",
    name = "pellet-manganese",
    icon = "__angelssmelting__/graphics/icons/pellet-manganese.png",
    icon_size = 64,
    icon_mipmaps = 4,
    subgroup = "angels-manganese",
    order = "c",
    stack_size = 200,
  },
  {
    type = "item",
    name = "solid-manganese-oxide",
    icon = "__angelssmelting__/graphics/icons/solid-manganese-oxide.png",
    icon_size = 32,
    subgroup = "angels-manganese",
    order = "d",
    stack_size = 200,
  },
  {
    type = "item",
    name = "cathode-manganese",
    icon = "__angelssmelting__/graphics/icons/cathode-manganese.png",
    icon_size = 32,
    subgroup = "angels-manganese",
    order = "e",
    stack_size = 200,
  },
  -- SMELTING RESULTS
  {
    type = "item",
    name = "ingot-manganese",
    icon = "__angelssmelting__/graphics/icons/ingot-manganese.png",
    icon_size = 64,
    icon_mipmaps = 4,
    subgroup = "angels-manganese",
    order = "f",
    stack_size = 200,
  },
  {
    type = "item",
    name = "powder-manganese",
    icon = "__angelssmelting__/graphics/icons/powder-manganese.png",
    icon_size = 64,
    icon_mipmaps = 4,
    subgroup = "angels-manganese",
    order = "g",
    stack_size = 200,
  },
  -- CASTING INTERMEDIATE
  {
    type = "fluid",
    name = "liquid-molten-manganese",
    icon = "__angelssmelting__/graphics/icons/molten-manganese.png",
    icon_size = 64,
    icon_mipmaps = 4,
    subgroup = "angels-manganese-casting",
    order = "h",
    default_temperature = 1246,
    heat_capacity = "0KJ",
    base_color = { r = 242 / 255, g = 97 / 255, b = 97 / 255 },
    flow_color = { r = 242 / 255, g = 97 / 255, b = 97 / 255 },
    max_temperature = 1246,
    auto_barrel = false,
  },
  {
    type = "item",
    name = "angels-roll-manganese",
    icon = "__angelssmelting__/graphics/icons/roll-manganese.png",
    icon_size = 64,
    icon_mipmaps = 4,
    subgroup = "angels-manganese-casting",
    order = "i",
    stack_size = 200,
  },
  -- CASTING RESULT
  {
    type = "item",
    name = "angels-plate-manganese",
    icon = "__angelssmelting__/graphics/icons/plate-manganese.png",
    icon_size = 32,
    subgroup = "angels-manganese-casting",
    order = "j",
    stack_size = 200,
  },
})
