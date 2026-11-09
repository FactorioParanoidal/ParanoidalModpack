local styles = data.raw["gui-style"]["default"]
local frame_width = 440 + 28 + 8 - 4
local scroll_pane_width = frame_width + 8 + 8

styles.sp_relative_stretchable_frame = {
  type = "frame_style",
  horizontally_stretchable = "off",
  vertical_flow_style = {
    type = "vertical_flow_style",
    vertical_spacing = 0
  }
  --vertically_stretchable = "off",
  --vertically_squashable = "on",
  -- maximal_height = 930,
  -- maximal_height is configurable and set at runtime
}

-- Copied from flib_titlebar_drag_handle
styles.sp_titlebar_drag_handle = {
  type = "empty_widget_style",
  parent = "draggable_space",
  left_margin = 4,
  right_margin = 4,
  height = 24,
  horizontally_stretchable = "on"
}

-- Change 'position' of graphical_set to match subheader frame
styles.sp_inside_shallow_frame =
{
  type = "frame_style",
  parent = "inside_shallow_frame",
  graphical_set =
  {
    base =
    {
      position = {17, 0}, corner_size = 8,
      center = {position = {256, 25}, size = {1, 1}},
      draw_type = "outer"
    },
    shadow = default_inner_shadow
  },
}

styles.sp_spidertron_schedule_scroll_pane = {
  type = "scroll_pane_style",
  parent = "train_schedule_scroll_pane",
  width = scroll_pane_width,
  margin = 0,
  scrollbars_go_outside = false,
  vertically_stretchable = "stretch_and_expand",
  background_graphical_set = {
    position = {282, 17},
    corner_size = 8,
    custom_horizontal_tiling_sizes = {28, frame_width - 40},
    overall_tiling_horizontal_spacing = 8,
    overall_tiling_horizontal_padding = 4,
    overall_tiling_vertical_spacing = 12,
    overall_tiling_vertical_size = 28,
    overall_tiling_vertical_padding = 4
  },
  graphical_set = {  -- Remove graphical_set, dark colour will be provided by containing sp_inside_shallow_frame
    shadow = default_inner_shadow
  },
}

styles.sp_empty_filler = {
  type = "empty_widget_style",
  horizontally_stretchable = "stretch_and_expand"
}
styles.sp_stretchable_subheader_frame = {
  type = "frame_style",
  parent = "subheader_frame",
  horizontally_stretchable = "on",
  horizontally_squashable = "on",
}

styles.sp_patrol_schedule_mode_switch_horizontal_flow = {
  type = "horizontal_flow_style",
  parent = "train_schedule_mode_switch_horizontal_flow",
  vertical_align = "center",
}

styles.sp_spidertron_schedule_station_frame = {
  type = "frame_style",
  parent = "train_schedule_station_frame",
  width = frame_width,
  horizontally_stretchable = "off",
}



styles.sp_schedule_move_button = {
  type = "button_style",
  parent = "train_schedule_delete_button",
  right_margin = -4,
  padding = -1,
  default_graphical_set = {
    base = {position = {68, 0}, corner_size = 8},
    shadow = {position = {399, 90}, corner_size = 4, draw_type = "outer"}  -- Removes black lines at right and bottom of shadow
  }
}

local button_style = styles.button
styles.sp_selected_schedule_move_button = {
  type = "button_style",
  parent = "sp_schedule_move_button",
  default_font_color = button_style.hovered_font_color,
  default_graphical_set = button_style.hovered_graphical_set,
  invert_colors_of_picture_when_hovered_or_toggled = false,  -- only used with black sprite, when moving waypoint to show which waypoint was moved
}

styles.sp_spidertron_camera = {
  type = "camera_style",
  minimal_height = 256,
  minimal_width = 256,
  horizontally_stretchable = "on",
  graphical_set = {}
}

styles.sp_spidertron_waypoint_label = {
  type = "label_style",
  parent = "clickable_label",
  font = "default-bold",
  horizontal_align = "center",
  minimal_width = 32,
  left_margin = -6,
  right_margin = -6,
}


styles.sp_stretchable_empty_widget = {
  type = "empty_widget_style",
  horizontally_stretchable = "stretch_and_expand",
  horizontally_squashable = "on",
}

styles.sp_player_input_horizontal_flow = {
  type = "horizontal_flow_style",
  parent = "player_input_horizontal_flow",
  natural_width = 300,  -- Will be squashed down
  horizontally_squashable = "on",
  --horizontally_stretchable = "stretch_and_expand",
  horizontal_spacing = 4,
  horizontal_align = "right",
  right_margin = -8,
}

styles.sp_compact_notched_slider = {
  type = "slider_style",
  parent = "notched_slider",
  horizontally_squashable = "on",
  natural_width = 300,  -- Set width very high but it will always be squashed down whilst taking up as much space as possible
  minimal_width = 20,
}

styles.sp_compact_slider_value_textfield = {
  type = "textbox_style",
  parent = "slider_value_textfield",
  width = 60,
}

data.raw["gui-style"]["default"].sp_spidertron_schedule_add_station_button = {
  type = "button_style",
  parent = "train_schedule_add_station_button",
  width = frame_width,
  horizontally_stretchable = "off",
}
