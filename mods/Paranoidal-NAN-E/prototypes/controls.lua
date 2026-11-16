local shared = require("shared")

-- Her window: Alt+N (I is the base journal of paranoidal-CodexRPG), the shortcut bar, or the button at the top left.
data:extend
{
  {
    type = "custom-input",
    name = shared.input,
    key_sequence = "ALT + N",
    action = "lua",
    enabled_while_spectating = true
  },
  {
    type = "shortcut",
    name = shared.shortcut,
    order = "z[nan-e]",
    action = "lua",
    associated_control_input = shared.input,
    icon = shared.mod .. "/graphics/icons/shortcut.png",
    icon_size = 64,
    small_icon = shared.mod .. "/graphics/icons/shortcut.png",
    small_icon_size = 64
  }
}
