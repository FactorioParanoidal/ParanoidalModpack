data:extend{
  {
    type = "custom-input",
    name = "give-route",
    localised_name = {"item-name.route"},
    key_sequence = "ALT + W",
    consuming = "none",
  },
  {
    type = "shortcut",
    name = "give-route",
    localised_name = {"item-name.route"},
    order = "",
    action = "lua",
    associated_control_input = "give-route",
    technology_to_unlock = "carriage_transport",
    --style = "blue",
    icon = GRAPHICSPATH .. "icon/route-shortcut-x56.png",
    icon_size = 56,
    small_icon = GRAPHICSPATH .. "icon/route-shortcut-x24.png",
    small_icon_size = 24,
  }
}
