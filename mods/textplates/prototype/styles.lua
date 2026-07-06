data.raw["gui-style"]["default"]["textplates-table"] =
{
  type = "table_style",
  cell_spacing = 1,
  horizontal_spacing = 1,
  vertical_spacing = 1
}
data.raw["gui-style"]["default"]["textplates-button"] =
{
  type = "button_style",
  parent = "button",
  minimal_width = 32,
  minimal_height = 32,
  top_padding = 0,
  right_padding = 0,
  bottom_padding = 0,
  left_padding = 0,
}
data.raw["gui-style"]["default"]["textplates-button-active"] =
{
  type = "button_style",
  parent = "button",
  minimal_width = 32,
  minimal_height = 32,
  top_padding = 0,
  right_padding = 0,
  bottom_padding = 0,
  left_padding = 0,
  default_graphical_set =
  {
	type = "composition",
	filename = "__core__/graphics/gui.png",
	priority = "extra-high-no-scale",
	corner_size = {3, 3},
	position = {0, 8}
  },
}
