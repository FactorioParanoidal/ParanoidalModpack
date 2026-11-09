-- Misc inputs
data:extend{
  {
    type = "shortcut",
    name = "sp-give-spidertron-patrol-remote",
    order = "e-b[spidertron-remote]",
    action = "spawn-item",
    localised_name = {"shortcut-name.sp-give-spidertron-patrol-remote", SPIDERTRON_NAME},
    associated_control_input = "sp-give-spidertron-patrol-remote",
    -- Paranoidal fork: patrols open with Maraxsis' submarine automation, after the rocket (ПР-079 item 4), not with the
    -- home spidertron technology.
    technology_to_unlock = "sp-spidertron-automation",
    unavailable_until_unlocked = true,
    item_to_spawn = "sp-spidertron-patrol-remote",
    icon = "__SpidertronPatrols__/graphics/shortcut/spidertron-patrol-remote-shortcut-x56.png",
    icon_size = 56,
    small_icon = "__SpidertronPatrols__/graphics/shortcut/spidertron-patrol-remote-shortcut-x56.png",
    small_icon_size = 56,
  },
  {
    type = "custom-input",
    name = "sp-give-spidertron-patrol-remote",
    key_sequence = "CONTROL + ALT + A",
    --controller_key_sequence = "controller-lefttrigger + controller-y",
    block_modifiers = true,
    consuming = "game-only",
    item_to_spawn = "sp-spidertron-patrol-remote",
    action = "spawn-item"
  },
  {
    type = "custom-input",
    name = "sp-use-item-custom",
    key_sequence = "",
    linked_game_control = "use-item",
    consuming = "none",
  },
  {
    type = "custom-input",
    name = "sp-replace-previous-waypoint",
    key_sequence = "SHIFT + mouse-button-2",
    controller_key_sequence = "controller-righttrigger + controller-a",
    consuming = "none",
    order = "a"
  },
  {
    type = "custom-input",
    name = "sp-delete-all-waypoints",
    key_sequence = "CONTROL + mouse-button-2",
    controller_key_sequence = "controller-lefttrigger + controller-x",
    consuming = "none",
    order = "b"
  },
  {
    type = "custom-input",
    name = "sp-toggle-spidertron-automatic-manual",
    key_sequence = "CONTROL + R",
    consuming = "none",
    order = "c"
  },
  {
    type = "custom-input",
    name = "sp-confirm-gui",
    key_sequence = "",
    linked_game_control = "confirm-gui"
  },
}

-- Allows getting movement control events to detect when to turn on 'manual' mode
data:extend{
  {
    type = "custom-input",
    name = "move-right-custom",
    key_sequence = "",
    linked_game_control = "move-right"
  },
  --[[{
    type = "custom-input",
    name = "move-left-custom",
    key_sequence = "",
    linked_game_control = "move-left"
  },]]
  {
    type = "custom-input",
    name = "move-up-custom",
    key_sequence = "",
    linked_game_control = "move-up"
  },
  {
    type = "custom-input",
    name = "move-down-custom",
    key_sequence = "",
    linked_game_control = "move-down"
  },
}

if settings.startup["sp-enable-spiderling"].value then
  data.raw["shortcut"]["give-spidertron-remote"].technology_to_unlock = "sp-spiderling"
  data.raw["shortcut"]["sp-give-spidertron-patrol-remote"].technology_to_unlock = "sp-spiderling"
end
