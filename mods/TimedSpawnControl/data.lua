data:extend({
  {
    type = "font",
    name = "timed-spawn-control-font",
    from = "default-bold",
    size = 16,
  },
})

data.raw["gui-style"].default["timed-spawn-control-button"] = {
  type = "button_style",
  parent = "button",
  font = "timed-spawn-control-font",
  minimal_width = 100,
  maximal_width = 100,
  top_padding = 0,
  right_padding = 0,
  bottom_padding = 0,
  left_padding = 0,
}
