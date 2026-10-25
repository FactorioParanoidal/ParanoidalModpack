-- Shortcut bar buttons and hotkeys: the squad command tool and the army window;
-- the sprite of the selection marks.
local shared = require("lib.shared")

local ICONS = shared.mod_path .. "/graphics/icons/"

data:extend({
  {
    type = "custom-input",
    name = shared.tool,
    localised_name = {"controls.robotarmy-command-tool"},
    localised_description = {"controls-description.robotarmy-command-tool"},
    order = "a",
    key_sequence = "",
    consuming = "none",
    action = "spawn-item",
    item_to_spawn = shared.tool,
  },
  {
    type = "shortcut",
    name = shared.tool,
    order = "r[robotarmy]-a",
    action = "spawn-item",
    item_to_spawn = shared.tool,
    associated_control_input = shared.tool,
    localised_name = {"shortcut-name." .. shared.tool},
    icon = ICONS .. "selection_tool.png",
    icon_size = 64,
    small_icon = ICONS .. "selection_tool.png",
    small_icon_size = 64,
  },
  {
    type = "custom-input",
    name = shared.army_shortcut,
    localised_name = {"controls.robotarmy-army"},
    localised_description = {"controls-description.robotarmy-army"},
    order = "b",
    key_sequence = "",
    consuming = "none",
    action = "lua",
  },
  {
    type = "shortcut",
    name = shared.army_shortcut,
    order = "r[robotarmy]-b",
    action = "lua",
    toggleable = true,
    associated_control_input = shared.army_shortcut,
    localised_name = {"shortcut-name." .. shared.army_shortcut},
    icon = ICONS .. "signal_droid_counter.png",
    icon_size = 64,
    small_icon = ICONS .. "signal_droid_counter.png",
    small_icon_size = 64,
  },
  {
    type = "sprite",
    name = shared.selection_sprite,
    filename = ICONS .. "unit-selection.png",
    size = 64,
    priority = "extra-high-no-scale",
  },
})
