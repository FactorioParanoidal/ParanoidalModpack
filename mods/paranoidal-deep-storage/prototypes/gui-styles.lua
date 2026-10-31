local styles = data.raw["gui-style"].default
local mod_prefix = "mu_"

styles[mod_prefix .. "entity_preview"] = {
	type = "empty_widget_style",
	vertically_stretchable = "on",
	horizontally_stretchable = "on",
	padding = 0,
	graphical_set = {
		base = {
			position = {17, 0},
			corner_size = 8,
			center = {position = {76, 8}, size = {1, 1}},
			draw_type = "outer"
		},
		shadow = default_inner_shadow
	}
}
