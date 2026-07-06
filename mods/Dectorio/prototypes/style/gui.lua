-- style/gui

default_gui = data.raw["gui-style"]["default"]

default_gui["dect-icon-frame"] = {
	type = "frame_style",
	parent = "frame",
	minimal_width = 288,
	minimal_height = 288,
	maximal_height = 512,
}

default_gui["dect-icon-table"] = {
	type = "table_style",
	cell_spacing = 2,
	horizontal_spacing = 1,
	vertical_spacing = 1
}

default_gui["dect-icon-button"] = {
	type = "button_style",
	parent = "button",
	minimal_width = 32,
	minimal_height = 32,
	top_padding = 0,
	right_padding = 0,
	bottom_padding = 0,
	left_padding = 0,
}

default_gui["dect-icon-button-active"] = {
	type = "button_style",
	parent = "button",
	minimal_width = 32,
	minimal_height = 32,
	top_padding = 0,
	right_padding = 0,
	bottom_padding = 0,
	left_padding = 0,
	default_graphical_set = {
		type = "composition",
		filename = "__core__/graphics/gui.png",
		priority = "extra-high-no-scale",
		corner_size = {3, 3},
		position = {0, 8}
	}
}
