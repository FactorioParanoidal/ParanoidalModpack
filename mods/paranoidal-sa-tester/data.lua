-- Tester panel: hotkey and shortcut-bar button (no game content, nothing before or after the rocket changes).
data:extend({
  {type = "custom-input", name = "paranoidal-sa-tester-toggle", key_sequence = "CONTROL + SHIFT + T", action = "lua",
    order = "a"},
  {type = "shortcut", name = "paranoidal-sa-tester", order = "z[paranoidal]-a[sa-tester]", action = "lua",
    toggleable = true, associated_control_input = "paranoidal-sa-tester-toggle",
    icon = "__paranoidal-sa-tester__/graphics/shortcut-x56.png", icon_size = 56,
    small_icon = "__paranoidal-sa-tester__/graphics/shortcut-x24.png", small_icon_size = 24},
})
