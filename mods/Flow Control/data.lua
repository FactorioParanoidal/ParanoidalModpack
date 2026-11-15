require("prototypes.entities")
require("prototypes.items")
require("prototypes.recipes")

data:extend({
  {type = "custom-input", name = "flow-control-cycle", key_sequence = "",
    linked_game_control = "rotate", consuming = "none"},
  {type = "custom-input", name = "flow-control-cycle-reverse", key_sequence = "",
    linked_game_control = "reverse-rotate", consuming = "none"},
  {type = "custom-input", name = "flow-control-clear-cursor", key_sequence = "",
    linked_game_control = "clear-cursor", consuming = "none"},
  {type = "custom-input", name = "flow-control-drop-cursor", key_sequence = "",
    linked_game_control = "drop-cursor", consuming = "none"}
})