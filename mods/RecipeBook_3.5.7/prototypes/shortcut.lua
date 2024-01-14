local data_util = require("__flib__.data-util")

data:extend({
  {
    type = "shortcut",
    name = "rb-search",
    action = "lua",
    icon = data_util.build_sprite(nil, { 0, 0 }, "__RecipeBook__/graphics/shortcut.png", 32, 2),
    small_icon = data_util.build_sprite(nil, { 0, 32 }, "__RecipeBook__/graphics/shortcut.png", 24, 2),
    disabled_icon = data_util.build_sprite(nil, { 48, 0 }, "__RecipeBook__/graphics/shortcut.png", 32, 2),
    disabled_small_icon = data_util.build_sprite(nil, { 36, 32 }, "__RecipeBook__/graphics/shortcut.png", 24, 2),
    toggleable = true,
    associated_control_input = "rb-search",
  },
})
