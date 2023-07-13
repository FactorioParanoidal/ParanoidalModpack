
local default_style = data.raw["gui-style"].default

--- taken from flib
default_style.mpp_selected_frame_action_button = {
	type = "button_style",
	parent = "frame_action_button",
	default_graphical_set = {
		base = {position = {225, 17}, corner_size = 8},
		shadow = {position = {440, 24}, corner_size = 8, draw_type = "outer"},
	},
	hovered_graphical_set = {
		base = {position = {369, 17}, corner_size = 8},
		shadow = {position = {440, 24}, corner_size = 8, draw_type = "outer"},
	},
	clicked_graphical_set = {
		base = {position = {352, 17}, corner_size = 8},
		shadow = {position = {440, 24}, corner_size = 8, draw_type = "outer"},
	}
}

default_style.mpp_blueprint_mode_button = {
	type = "button_style",
	parent = "recipe_slot_button",
	size = 28,
}

default_style.mpp_blueprint_mode_button_active = {
	type = "button_style",
	parent = "recipe_slot_button",
	size = 28,
	default_graphical_set = {
		base = {position = {225, 17}, corner_size = 8},
		shadow = {position = {440, 24}, corner_size = 8, draw_type = "outer"},
	},
	hovered_graphical_set = {
		base = {position = {369, 17}, corner_size = 8},
		shadow = {position = {440, 24}, corner_size = 8, draw_type = "outer"},
	},
	clicked_graphical_set = {
		base = {position = {352, 17}, corner_size = 8},
		shadow = {position = {440, 24}, corner_size = 8, draw_type = "outer"},
	}
}

default_style.mpp_fake_item_placeholder = {
	type="image_style",
	stretch_image_to_widget_size = true,
	size=32,
}

default_style.mpp_fake_blueprint_button = {
	type="button_style",
	parent="shortcut_bar_button_blue",
	padding=3,
	size=48,
}
default_style.mpp_delete_blueprint_button = {
	type="button_style",
	parent="shortcut_bar_button_red",
	padding=0,
	size=24,
	stretch_image_to_widget_size=true,
}

default_style.mpp_fake_blueprint_button_selected = {
	type="button_style",
	parent="shortcut_bar_button_blue",
	padding=3,
	size=48,
	default_graphical_set = {
		base = {position = {225, 17}, corner_size = 8},
		shadow = {position = {440, 24}, corner_size = 8, draw_type = "outer"},
	},
	hovered_graphical_set = {
		base = {position = {369, 17}, corner_size = 8},
		shadow = {position = {440, 24}, corner_size = 8, draw_type = "outer"},
	},
	clicked_graphical_set = {
		base = {position = {352, 17}, corner_size = 8},
		shadow = {position = {440, 24}, corner_size = 8, draw_type = "outer"},
	}
}

default_style.mpp_fake_blueprint_button_invalid = {
	type="button_style",
	parent="shortcut_bar_button_red",
	padding=3,
	size=48,
	stretch_image_to_widget_size=true,
}

default_style.mpp_fake_blueprint_table = {
	type="table_style",
	padding=0,
	cell_padding=0,
	horizontal_spacing=2,
	vertical_spacing=2,
}

default_style.mpp_fake_blueprint_sprite = {
	type="image_style",
	size=16,
	stretch_image_to_widget_size=true,
}
