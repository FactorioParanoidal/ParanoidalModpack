local style = data.raw["gui-style"].default

style.ed_stretch = {
	type = "empty_widget_style",
	horizontally_stretchable = "on",
}

style.ed_settings_inner_frame = {
	type = "frame_style",
	parent = "frame",
	horizontally_stretchable = "on",
}


style.ed_switch_button = {
	type = "button_style",
	parent = "button",
	left_padding = 0,
	right_padding = 0,

	hovered_font_color = button_default_font_color,
	hovered_graphical_set =
	{
		base = {position = {0, 17}, corner_size = 8},
		shadow = default_dirt
	},
	clicked_font_color = button_default_font_color,
	clicked_graphical_set =
	{
		base = {position = {0, 17}, corner_size = 8},
		shadow = default_dirt
	},
	-- clicked_font_color = button_hovered_font_color,
	-- clicked_graphical_set =
	-- {
	-- 	base = {position = {225, 17}, corner_size = 8},
	-- 	shadow = default_dirt
	-- },
}

style.ed_switch_button_selected = {
	type = "button_style",
	parent = "button",
	left_padding = 0,
	right_padding = 0,

	-- selected button graphical sets as default
	default_font_color = button_hovered_font_color,
	default_graphical_set =
	{
		base = {position = {225, 17}, corner_size = 8},
		shadow = default_dirt
	},
	-- hovered_font_color = button_hovered_font_color,
	-- hovered_graphical_set =
	-- {
	-- 	base = {position = {369, 17}, corner_size = 8},
	-- 	shadow = default_dirt
	-- },
	hovered_font_color = button_hovered_font_color,
	hovered_graphical_set =
	{
		base = {position = {225, 17}, corner_size = 8},
		shadow = default_dirt
	},
	-- clicked_font_color = button_hovered_font_color,
	-- clicked_graphical_set =
	-- {
	-- 	base = {position = {352, 17}, corner_size = 8},
	-- 	shadow = default_dirt
	-- },
	clicked_font_color = button_hovered_font_color,
	clicked_graphical_set =
	{
		base = {position = {225, 17}, corner_size = 8},
		shadow = default_dirt
	},
}

style.ed_switch_button_small = {
	type = "button_style",
	parent = "ed_switch_button",
    minimal_width  = 40,
    minimal_height = 40,
    left_margin    = -2,
    right_margin   = -2,
}

style.ed_switch_button_small_selected = {
	type = "button_style",
	parent = "ed_switch_button_selected",
    minimal_width  = 40,
    minimal_height = 40,
    left_margin    = -2,
    right_margin   = -2,
}

style.ed_switch_button_large = {
	type = "button_style",
	parent = "ed_switch_button",
    minimal_width  = 40*2,
    minimal_height = 40*2+20,
    left_margin    = -2,
    right_margin   = -2,
    padding        = 2,
}

style.ed_switch_button_large_selected = {
	type = "button_style",
	parent = "ed_switch_button_selected",
    minimal_width  = 40*2,
    minimal_height = 40*2+20,
    left_margin    = -2,
    right_margin   = -2,
    padding        = 2,
}