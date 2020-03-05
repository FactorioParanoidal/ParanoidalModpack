data:extend({
  {
    type = "custom-input",
    name = "rename",
    key_sequence = "CONTROL + R",
    consuming = "none"
  },
  {
    type = "sprite",
    name = "renamer-black-check",
    filename = "__Renamer__/graphics/black-check.png",
    priority = "extra-high-no-scale",
    size = 32,
    scale = 1,
    flags = {"icon"}
  },
  {
    type = "sprite",
    name = "renamer-black-cross",
    filename = "__Renamer__/graphics/black-cross.png",
    priority = "extra-high-no-scale",
    size = 32,
    scale = 1,
    flags = {"icon"}
  }
})

data.raw["gui-style"].default["renamer_titlebar_flow"] = {
    type = "horizontal_flow_style",
    direction = "horizontal",
    horizontally_stretchable = "on",
    vertical_align = "center"
}