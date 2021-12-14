local data_util = require("__flib__.data-util")

local shortcut_file = "__QuickItemSearch__/graphics/shortcut.png"

data:extend({
  {
    type = "shortcut",
    name = "qis-search",
    icon = data_util.build_sprite(nil, { 0, 0 }, shortcut_file, 32, 2),
    disabled_icon = data_util.build_sprite(nil, { 48, 0 }, shortcut_file, 32, 2),
    small_icon = data_util.build_sprite(nil, { 0, 32 }, shortcut_file, 24, 2),
    disabled_small_icon = data_util.build_sprite(nil, { 36, 32 }, shortcut_file, 24, 2),
    toggleable = true,
    action = "lua",
    associated_control_input = "qis-search",
  },
})
