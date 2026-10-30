data:extend({
  {
    type = "custom-input",
    name = "runames-random-name",
    key_sequence = "CONTROL + N",
    consuming = "none",
    order = "a",
  },
  {
    type = "custom-input",
    name = "runames-rename",
    key_sequence = "CONTROL + R",
    consuming = "none",
    order = "b",
  },
})

data.raw["gui-style"].default["runames_titlebar_flow"] = {
  type = "horizontal_flow_style",
  horizontally_stretchable = "on",
  vertical_align = "center",
}
