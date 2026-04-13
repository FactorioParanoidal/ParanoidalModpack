local core_utils = require("__core__/lualib/util")
data.raw["utility-constants"]["default"].default_other_force_color = core_utils.copy(data.raw["utility-constants"]["default"].default_enemy_force_color)

data:extend({
  {
    type = "selection-tool",
    name = "ruins-claim-tool",
    icon = "__AbandonedRuins_updated_fork__/graphics/icons/ruins-claim-tool.png",
    icon_size = 64,
    small_icon = "__AbandonedRuins_updated_fork__/graphics/icons/ruins-claim-tool.png",
    small_icon_size = 64,
    stack_size = 1,
    select = {
      border_color = {1, 1, 1},
      mode = {"buildable-type", "not-same-force", "friend"},
      cursor_box_type = "train-visualization",
    },
    alt_select = {
      border_color = {1, 1, 1},
      mode = {"any-entity", "not-same-force", "friend"},
      cursor_box_type = "train-visualization",
    },
    always_include_tiles = true,
    flags = {"only-in-cursor", "spawnable"}
  }, {
    type = "shortcut",
    name = "ruins-claim-tool",
    action = "spawn-item",
    icon = "__AbandonedRuins_updated_fork__/graphics/icons/ruins-claim-tool-shortcut.png",
    icon_size = 32,
    small_icon = "__AbandonedRuins_updated_fork__/graphics/icons/ruins-claim-tool-shortcut.png",
    small_icon_size = 32,
    item_to_spawn = "ruins-claim-tool",
    associated_control_input = "ruins-claim-tool"
  }, {
    type = "custom-input",
    name = "ruins-claim-tool",
    key_sequence = "SHIFT + C",
    action = "spawn-item",
    item_to_spawn = "ruins-claim-tool"
  }
})
