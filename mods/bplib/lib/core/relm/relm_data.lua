---@diagnostic disable: undefined-global

--------------------------------------------------------------------------------
-- RELM DATA PHASE
-- This file adds sprites and styles used by Ultros. Any Relm
-- mod using Ultros UI controls should require this file in the data stage.
--
-- Embedding consumers must set the global variable `_G.__RELM_GRAPHICS_PATH__`
-- to the subdir within their mod path where the Relm graphics files are
-- located.
--
-- Some of the code below comes from `flib` under the MIT License.
--------------------------------------------------------------------------------

local styles = data.raw["gui-style"].default

-- Paths
local png_slot_tileset = _G.__RELM_GRAPHICS_PATH__ .. "slots.png"
local png_subheader_line = _G.__RELM_GRAPHICS_PATH__ .. "subheader-line.png"
local png_frame_action_icons = _G.__RELM_GRAPHICS_PATH__
	.. "frame-action-icons.png"
local png_indicators = _G.__RELM_GRAPHICS_PATH__ .. "indicators.png"
local png_dark_red_button = _G.__RELM_GRAPHICS_PATH__ .. "dark-red-button.png"

--------------------------------------------------------------------------------
-- SLOT BUTTONS (from flib)
--------------------------------------------------------------------------------

local function gen_slot(x, y, default_offset)
	default_offset = default_offset or 0
	return {
		type = "button_style",
		parent = "slot",
		size = 40,
		clicked_vertical_offset = 0,
		default_graphical_set = {
			base = {
				border = 4,
				position = { x + default_offset, y },
				size = 80,
				filename = png_slot_tileset,
			},
		},
		hovered_graphical_set = {
			base = {
				border = 4,
				position = { x + 80, y },
				size = 80,
				filename = png_slot_tileset,
			},
		},
		clicked_graphical_set = {
			base = {
				border = 4,
				position = { x + 160, y },
				size = 80,
				filename = png_slot_tileset,
			},
		},
		disabled_graphical_set = { -- identical to default graphical set
			base = {
				border = 4,
				position = { x + default_offset, y },
				size = 80,
				filename = png_slot_tileset,
			},
		},
	}
end

local function gen_slot_button(x, y, default_offset, glow)
	default_offset = default_offset or 0
	return {
		type = "button_style",
		parent = "slot_button",
		size = 40,
		clicked_vertical_offset = 0,
		default_graphical_set = {
			base = {
				border = 4,
				position = { x + default_offset, y },
				size = 80,
				filename = png_slot_tileset,
			},
			shadow = offset_by_2_rounded_corners_glow(default_dirt_color),
		},
		hovered_graphical_set = {
			base = {
				border = 4,
				position = { x + 80, y },
				size = 80,
				filename = png_slot_tileset,
			},
			shadow = offset_by_2_rounded_corners_glow(default_dirt_color),
			glow = offset_by_2_rounded_corners_glow(glow),
		},
		clicked_graphical_set = {
			base = {
				border = 4,
				position = { x + 160, y },
				size = 80,
				filename = png_slot_tileset,
			},
			shadow = offset_by_2_rounded_corners_glow(default_dirt_color),
		},
		disabled_graphical_set = { -- identical to default graphical set
			base = {
				border = 4,
				position = { x + default_offset, y },
				size = 80,
				filename = png_slot_tileset,
			},
			shadow = offset_by_2_rounded_corners_glow(default_dirt_color),
		},
	}
end

local function gen_standalone_slot_button(x, y, default_offset)
	default_offset = default_offset or 0
	return {
		type = "button_style",
		parent = "slot_button",
		size = 40,
		clicked_vertical_offset = 0,
		default_graphical_set = {
			base = {
				border = 4,
				position = { x + default_offset, y },
				size = 80,
				filename = png_slot_tileset,
			},
			shadow = offset_by_4_rounded_corners_shallow_inset,
		},
		hovered_graphical_set = {
			base = {
				border = 4,
				position = { x + 80, y },
				size = 80,
				filename = png_slot_tileset,
			},
			shadow = offset_by_4_rounded_corners_shallow_inset,
		},
		clicked_graphical_set = {
			base = {
				border = 4,
				position = { x + 160, y },
				size = 80,
				filename = png_slot_tileset,
			},
			shadow = offset_by_4_rounded_corners_shallow_inset,
		},
		disabled_graphical_set = { -- identical to default graphical set
			base = {
				border = 4,
				position = { x + default_offset, y },
				size = 80,
				filename = png_slot_tileset,
			},
			shadow = offset_by_4_rounded_corners_shallow_inset,
		},
	}
end

local slot_data = {
	{ name = "default", y = 0, glow = default_glow_color },
	{ name = "grey", y = 80, glow = default_glow_color },
	{ name = "red", y = 160, glow = { 230, 135, 135 } },
	{ name = "orange", y = 240, glow = { 216, 169, 122 } },
	{ name = "yellow", y = 320, glow = { 230, 218, 135 } },
	{ name = "green", y = 400, glow = { 153, 230, 135 } },
	{ name = "cyan", y = 480, glow = { 135, 230, 230 } },
	{ name = "blue", y = 560, glow = { 135, 186, 230 } },
	{ name = "purple", y = 640, glow = { 188, 135, 230 } },
	{ name = "pink", y = 720, glow = { 230, 135, 230 } },
}

for _, data in pairs(slot_data) do
	styles["relm_slot_" .. data.name] = gen_slot(0, data.y)
	styles["relm_selected_slot_" .. data.name] = gen_slot(0, data.y, 80)
	styles["relm_slot_button_" .. data.name] =
		gen_slot_button(240, data.y, 0, data.glow)
	styles["relm_selected_slot_button_" .. data.name] =
		gen_slot_button(240, data.y, 80, data.glow)
	styles["relm_standalone_slot_button_" .. data.name] =
		gen_standalone_slot_button(240, data.y)
	styles["relm_selected_standalone_slot_button_" .. data.name] =
		gen_standalone_slot_button(240, data.y, 80)
end

--------------------------------------------------------------------------------
-- INDICATORS (from flib)
--------------------------------------------------------------------------------

local indicators = {}
for i, color in ipairs({
	"black",
	"white",
	"red",
	"orange",
	"yellow",
	"green",
	"cyan",
	"blue",
	"purple",
	"pink",
}) do
	indicators[i] = {
		type = "sprite",
		name = "relm_indicator_" .. color,
		filename = png_indicators,
		y = (i - 1) * 32,
		size = 32,
		flags = { "icon" },
	}
end
data:extend(indicators)

--------------------------------------------------------------------------------
-- FRAME ACTION BUTTONS (from flib)
--------------------------------------------------------------------------------

data:extend({
	{
		type = "sprite",
		name = "relm_pin_black",
		filename = png_frame_action_icons,
		position = { 0, 0 },
		size = 32,
		flags = { "gui-icon" },
	},
	{
		type = "sprite",
		name = "relm_pin_white",
		filename = png_frame_action_icons,
		position = { 32, 0 },
		size = 32,
		flags = { "gui-icon" },
	},
	{
		type = "sprite",
		name = "relm_pin_disabled",
		filename = png_frame_action_icons,
		position = { 64, 0 },
		size = 32,
		flags = { "gui-icon" },
	},
	{
		type = "sprite",
		name = "relm_settings_black",
		filename = png_frame_action_icons,
		position = { 0, 32 },
		size = 32,
		flags = { "gui-icon" },
	},
	{
		type = "sprite",
		name = "relm_settings_white",
		filename = png_frame_action_icons,
		position = { 32, 32 },
		size = 32,
		flags = { "gui-icon" },
	},
	{
		type = "sprite",
		name = "relm_settings_disabled",
		filename = png_frame_action_icons,
		position = { 64, 32 },
		size = 32,
		flags = { "gui-icon" },
	},
})

--------------------------------------------------------------------------------
-- FLIB GENERAL STYLES (from flib)
--------------------------------------------------------------------------------

-- BUTTON STYLES

styles.relm_selected_frame_action_button = {
	type = "button_style",
	parent = "frame_action_button",
	default_font_color = button_hovered_font_color,
	default_graphical_set = {
		base = { position = { 225, 17 }, corner_size = 8 },
		shadow = { position = { 440, 24 }, corner_size = 8, draw_type = "outer" },
	},
	hovered_font_color = button_hovered_font_color,
	hovered_graphical_set = {
		base = { position = { 369, 17 }, corner_size = 8 },
		shadow = { position = { 440, 24 }, corner_size = 8, draw_type = "outer" },
	},
	clicked_font_color = button_hovered_font_color,
	clicked_graphical_set = {
		base = { position = { 352, 17 }, corner_size = 8 },
		shadow = { position = { 440, 24 }, corner_size = 8, draw_type = "outer" },
	},
	-- Simulate clicked-vertical-offset
	top_padding = 1,
	bottom_padding = -1,
	clicked_vertical_offset = 0,
}

local btn = styles.button

styles.relm_selected_tool_button = {
	type = "button_style",
	parent = "tool_button",
	default_font_color = btn.selected_font_color,
	default_graphical_set = btn.selected_graphical_set,
	hovered_font_color = btn.selected_hovered_font_color,
	hovered_graphical_set = btn.selected_hovered_graphical_set,
	clicked_font_color = btn.selected_clicked_font_color,
	clicked_graphical_set = btn.selected_clicked_graphical_set,
	-- Simulate clicked-vertical-offset
	top_padding = 1,
	bottom_padding = -1,
	clicked_vertical_offset = 0,
}

styles.relm_tool_button_light_green = {
	type = "button_style",
	parent = "item_and_count_select_confirm",
	padding = 2,
	top_margin = 0,
	tooltip = "",
}

styles.relm_tool_button_dark_red = {
	type = "button_style",
	parent = "tool_button",
	default_graphical_set = {
		base = {
			filename = png_dark_red_button,
			position = { 0, 0 },
			corner_size = 8,
		},
		shadow = default_dirt,
	},
	hovered_graphical_set = {
		base = {
			filename = png_dark_red_button,
			position = { 17, 0 },
			corner_size = 8,
		},
		shadow = default_dirt,
		glow = default_glow({ 236, 130, 130, 127 }, 0.5),
	},
	clicked_graphical_set = {
		base = {
			filename = png_dark_red_button,
			position = { 34, 0 },
			corner_size = 8,
		},
		shadow = default_dirt,
	},
}

-- EMPTY-WIDGET STYLES

styles.relm_dialog_footer_drag_handle = {
	type = "empty_widget_style",
	parent = "draggable_space",
	height = 32,
	horizontally_stretchable = "on",
}

styles.relm_dialog_footer_drag_handle_no_right = {
	type = "empty_widget_style",
	parent = "relm_dialog_footer_drag_handle",
	right_margin = 0,
}

styles.relm_dialog_titlebar_drag_handle = {
	type = "empty_widget_style",
	parent = "relm_titlebar_drag_handle",
	right_margin = 0,
}

styles.relm_horizontal_pusher = {
	type = "empty_widget_style",
	horizontally_stretchable = "on",
}

styles.relm_titlebar_drag_handle = {
	type = "empty_widget_style",
	parent = "draggable_space",
	left_margin = 4,
	right_margin = 4,
	height = 24,
	horizontally_stretchable = "on",
}

styles.relm_vertical_pusher = {
	type = "empty_widget_style",
	vertically_stretchable = "on",
}

-- FLOW STYLES

styles.relm_indicator_flow = {
	type = "horizontal_flow_style",
	vertical_align = "center",
}

styles.relm_titlebar_flow = {
	type = "horizontal_flow_style",
	horizontal_spacing = 8,
}

-- FRAME STYLES

styles.relm_shallow_frame_in_shallow_frame = {
	type = "frame_style",
	parent = "frame",
	padding = 0,
	graphical_set = {
		base = {
			position = { 85, 0 },
			corner_size = 8,
			center = { position = { 76, 8 }, size = { 1, 1 } },
			draw_type = "outer",
		},
		shadow = default_inner_shadow,
	},
	vertical_flow_style = {
		type = "vertical_flow_style",
		vertical_spacing = 0,
	},
}

-- IMAGE STYLES

styles.relm_indicator = {
	type = "image_style",
	size = 16,
	stretch_image_to_widget_size = true,
}

-- LABEL STYLES

styles.relm_frame_title = {
	type = "label_style",
	parent = "frame_title",
	bottom_padding = 3,
	top_margin = -3,
}

-- LINE STYLES

styles.relm_subheader_horizontal_line = {
	type = "line_style",
	horizontally_stretchable = "on",
	left_margin = -8,
	right_margin = -8,
	top_margin = -2,
	bottom_margin = -2,
	border = {
		border_width = 8,
		horizontal_line = { filename = png_subheader_line, size = { 1, 8 } },
	},
}

styles.relm_titlebar_separator_line = {
	type = "line_style",
	top_margin = -2,
	bottom_margin = 2,
}

-- SCROLL-PANE STYLES

styles.relm_naked_scroll_pane = {
	type = "scroll_pane_style",
	extra_padding_when_activated = 0,
	padding = 12,
	graphical_set = {
		shadow = default_inner_shadow,
	},
}

styles.relm_naked_scroll_pane_under_tabs = {
	type = "scroll_pane_style",
	parent = "relm_naked_scroll_pane",
	graphical_set = {
		base = {
			top = { position = { 93, 0 }, size = { 1, 8 } },
			draw_type = "outer",
		},
		shadow = default_inner_shadow,
	},
}

styles.relm_naked_scroll_pane_no_padding = {
	type = "scroll_pane_style",
	parent = "relm_naked_scroll_pane",
	padding = 0,
}

styles.relm_shallow_scroll_pane = {
	type = "scroll_pane_style",
	padding = 0,
	graphical_set = {
		base = { position = { 85, 0 }, corner_size = 8, draw_type = "outer" },
		shadow = default_inner_shadow,
	},
}

-- TABBED PANE STYLES

styles.relm_tabbed_pane_with_no_padding = {
	type = "tabbed_pane_style",
	tab_content_frame = {
		type = "frame_style",
		top_padding = 0,
		bottom_padding = 0,
		left_padding = 0,
		right_padding = 0,
		graphical_set = {
			base = {
				-- Same as tabbed_pane_graphical_set - but without bottom
				top = { position = { 76, 0 }, size = { 1, 8 } },
				center = { position = { 76, 8 }, size = { 1, 1 } },
			},
			shadow = top_shadow,
		},
	},
}

-- TEXTFIELD STYLES

styles.relm_widthless_textfield = {
	type = "textbox_style",
	width = 0,
}

styles.relm_widthless_invalid_textfield = {
	type = "textbox_style",
	parent = "invalid_value_textfield",
	width = 0,
}

styles.relm_titlebar_search_textfield = {
	type = "textbox_style",
	top_margin = -2,
	bottom_margin = 1,
	width = 150,
}

--------------------------------------------------------------------------------
-- RELM GENERAL STYLES
--------------------------------------------------------------------------------

styles.relm_table_white_lines = {
	type = "table_style",
	horizontal_line_color = { 1, 1, 1 },
	vertical_line_color = { 1, 1, 1 },
	top_cell_padding = 1,
	bottom_cell_padding = 2,
	left_cell_padding = 3,
	right_cell_padding = 2,
}

styles.relm_deep_frame_in_shallow_frame_stretchable = {
	type = "frame_style",
	parent = "deep_frame_in_shallow_frame",
	horizontally_stretchable = "on",
}

styles.relm_invisible_button = {
	type = "button_style",
	default_graphical_set = {
		base = { type = "none" },
	},
	hovered_graphical_set = {
		base = { type = "none" },
	},
	clicked_graphical_set = {
		base = { type = "none" },
	},
	disabled_graphical_set = {
		base = { type = "none" },
	},
	selected_graphical_set = {
		base = { type = "none" },
	},
	selected_hovered_graphical_set = {
		base = { type = "none" },
	},
	game_controller_selected_hovered_graphical_set = {
		base = { type = "none" },
	},
	selected_clicked_graphical_set = {
		base = { type = "none" },
	},
}

styles.relm_raised_frame = {
	type = "frame_style",
	graphical_set = {
		base = {
			position = { 68, 0 },
			corner_size = 8,
		},
		---@diagnostic disable-next-line: need-check-nil
		shadow = styles.train_with_minimap_frame.graphical_set.shadow,
	},
	padding = 4,
}

styles.relm_raised_frame_slot_buttons = {
	type = "frame_style",
	parent = "relm_raised_frame",
	background_graphical_set = {
		position = { 282, 17 },
		corner_size = 8,
		overall_tiling_vertical_size = 32,
		overall_tiling_vertical_spacing = 8,
		overall_tiling_vertical_padding = 4,
		overall_tiling_horizontal_size = 32,
		overall_tiling_horizontal_spacing = 8,
		overall_tiling_horizontal_padding = 4,
	},
}

-- A plain frame with a background consisting of empty slot buttons.
styles.relm_frame_slot_buttons_deep = {
	type = "frame_style",
	graphical_set = { type = "none" },
	background_graphical_set = {
		position = { 282, 17 },
		corner_size = 8,
		overall_tiling_vertical_size = 40,
		overall_tiling_vertical_spacing = 0,
		overall_tiling_vertical_padding = 0,
		overall_tiling_horizontal_size = 40,
		overall_tiling_horizontal_spacing = 0,
		overall_tiling_horizontal_padding = 0,
	},
	padding = 0,
	margin = 0,
}

styles.relm_frame_slot_buttons_shallow = {
	type = "frame_style",
	graphical_set = { type = "none" },
	background_graphical_set = {
		position = { 256, 136 },
		corner_size = 16,
		overall_tiling_vertical_size = 24,
		overall_tiling_vertical_spacing = 16,
		overall_tiling_vertical_padding = 8,
		overall_tiling_horizontal_size = 24,
		overall_tiling_horizontal_spacing = 16,
		overall_tiling_horizontal_padding = 8,
	},
	padding = 0,
	margin = 0,
}

styles.relm_label_signal_count = {
	type = "label_style",
	parent = "count_label",
	size = 36,
	horizontal_align = "right",
	vertical_align = "bottom",
	right_padding = 2,
	parent_hovered_font_color = { 1, 1, 1 },
}
