data:extend({
  {
    type = "custom-input",
    name = "rename",
    key_sequence = "CONTROL + R",
    consuming = "none"
  }
})

data.raw["gui-style"].default["renamer_titlebar_flow"] = {
    type = "horizontal_flow_style",
    direction = "horizontal",
    horizontally_stretchable = "on",
    vertical_align = "center"
}