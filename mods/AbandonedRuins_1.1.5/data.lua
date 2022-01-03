local base_util = require("__core__/lualib/util")
data.raw["utility-constants"]["default"].default_other_force_color = base_util.copy(data.raw["utility-constants"]["default"].default_enemy_force_color)


data:extend
{
  {
    type = "selection-tool",
    name = "AbandonedRuins-claim",
    icon = "__AbandonedRuins__/graphics/AbandonedRuins-claim.png",
    icon_size = 64,
    stack_size = 1,
    selection_color = {1, 1, 1},
    alt_selection_color = {1, 1, 1},
    selection_mode = {"buildable-type", "not-same-force", "friend"},
    alt_selection_mode = {"any-entity", "not-same-force", "friend"},
    selection_cursor_box_type = "train-visualization",
    alt_selection_cursor_box_type = "train-visualization",
    always_include_tiles = true,
    flags = {"only-in-cursor", "spawnable"}
  },
  {
    type = "shortcut",
    name = "AbandonedRuins-claim",
    action = "spawn-item",
    icon =
    {
      filename = "__AbandonedRuins__/graphics/AbandonedRuins-claim-shortcut.png",
      size = 32
    },
    item_to_spawn = "AbandonedRuins-claim",
    associated_control_input = "AbandonedRuins-claim"
  },
  {
    type = "custom-input",
    name = "AbandonedRuins-claim",
    key_sequence = "SHIFT + C",
    action = "spawn-item",
    item_to_spawn = "AbandonedRuins-claim"
  }
}

