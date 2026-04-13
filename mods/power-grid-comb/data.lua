local item = {
  type = "selection-tool",
  name = "power-grid-comb",
  subgroup = "tool",
  order = "z[power-grid-comb]",

  icons = {
    {
      icon = "__power-grid-comb__/graphics/icons/power-grid-comb.png",
      icon_size = 32,
    }
  },

  flags = { "only-in-cursor", "spawnable" },
  stack_size = 1,
  hidden = true,

  select = {
    border_color = { r = 0.72, g = 0.45, b = 0.2, a = 1 },
    mode = { "buildable-type", "same-force" },
    cursor_box_type = "entity",
    entity_type_filters = { "electric-pole" },
  },

  alt_select = {
    border_color = { r = 0.72, g = 0.45, b = 0.2, a = 1 },
    mode = { "buildable-type", "same-force" },
    cursor_box_type = "entity",
    entity_type_filters = { "electric-pole" },
  },
}

local shortcut = {
  type = "shortcut",
  name = "shortcut-power-grid-comb-item",
  action = "spawn-item",
  item_to_spawn = "power-grid-comb",
  order = "m[power-grid-comb]",
  icon_size = 32,
  icon = "__power-grid-comb__/graphics/icons/power-grid-comb-x32.png",
  small_icon_size = 24,
  small_icon = "__power-grid-comb__/graphics/icons/power-grid-comb-x24.png",
}

data:extend { item, shortcut }
