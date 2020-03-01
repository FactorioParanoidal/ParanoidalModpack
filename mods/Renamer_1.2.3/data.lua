data:extend({
  {
    type = "custom-input",
    name = "rename",
    key_sequence = "CONTROL + R",
    consuming = "none"
  },
  {
    type = "custom-input",
    name = "rename-commit",
    key_sequence = "RETURN",
    consuming = "none"
  },
  {
    type = "font",
    name = "renamer-button",
    from = "default-bold",
    size = 14
  }
})

data.raw["gui-style"].default["renamer-button-style"] =
{
	type = "button_style",
	parent = "button",
	font = "renamer-button",
	align = "center",
  top_padding = 2,
  right_padding = 2,
  bottom_padding = 2,
  left_padding = 2,
	default_font_color = {r = 1, g = 0.707, b = 0.12},
	hovered_font_color = {r = 1, g = 1, b = 1},
	clicked_font_color = {r = 1, g = 0.707, b = 0.12}
}