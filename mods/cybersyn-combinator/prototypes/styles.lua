local styles = data.raw["gui-style"].default

styles["cybersyn-combinator_cs-signal-sprite"] = {
  type = "image_style",
  parent = "image",
  size = 32,
  left_padding = 2,
  stretch_image_to_widget_size = true
}

styles["cybersyn-combinator_cs-signal-label"] = {
  type = "label_style",
  parent = "caption_label",
  horizontally_stretchable = "on"
}

styles["cybersyn-combinator_cs-signal-text"] = {
  type = "textbox_style",
  parent = "short_number_textfield",
  horizontal_align = "right",
  horizontally_stretchable = "off"
}

styles["cybersyn-combinator_cs-signal-reset"] = {
  type = "button_style",
  parent = "tool_button_red",
  horizontally_stretchable = "off"
}

styles["cybersyn-combinator_signal-button"] = {
  type = "button_style",
  parent = "flib_slot_button_default"
}

styles["cybersyn-combinator_signal-button_pressed"] = {
  type = "button_style",
  parent = "flib_selected_slot_button_default"
}

-- styles["cybersyn-combinator_signal-button_disabled"] = {
--   type = "button_style",
--   parent = "flib_slot_button_default",
--   draw_grayscale_picture = true,
--   default_graphical_set = {
--     base = {
--       border = 4, position = { 0, 0 }, size = 80,
--       filename = "__cybersyn-combinator__/graphics/gui/disabled-slot-button-tileset.png"
--     },
--     shadow = offset_by_2_rounded_corners_glow(default_dirt_color)
--   },
--   hovered_graphical_set = {
--     base = {
--       border = 4, position = { 80, 0 }, size = 80,
--       filename = "__cybersyn-combinator__/graphics/gui/disabled-slot-button-tileset.png"
--     },
--     shadow = offset_by_2_rounded_corners_glow(default_dirt_color),
--     glow = offset_by_2_rounded_corners_glow(default_glow_color)
--   },
--   clicked_graphical_set = {
--     base = {
--       border = 4, position = { 160, 0 }, size = 80,
--       filename = "__cybersyn-combinator__/graphics/gui/disabled-slot-button-tileset.png"
--     },
--     shadow = offset_by_2_rounded_corners_glow(default_dirt_color)
--   }
-- }

-- styles["cybersyn-combinator_signal-button_disabled_pressed"] = {
--   type = "button_style",
--   parent = "cybersyn-combinator_signal-button_disabled",
--   default_graphical_set = styles["cybersyn-combinator_signal-button_disabled"].clicked_graphical_set
-- }

styles["cybersyn-combinator_signal-comparator"] = {
  type = "label_style",
  parent = "label",
  font = "cybersyn-combinator_signal-comparator-font",
  size = 36,
  horizontal_align = "left",
  vertical_align = "top",
  margin = 0,
  padding = 0,
  parent_hovered_font_color = { 1, 1, 1 }
}

styles["cybersyn-combinator_signal-count"] = {
  type = "label_style",
  parent = "count_label",
  size = 36,
  horizontal_align = "right",
  vertical_align = "bottom",
  right_padding = 2,
  parent_hovered_font_color = { 1, 1, 1 }
}

styles["cybersyn-combinator_network-list_info-sprite"] = {
  type = "image_style",
  parent = "image",
  size = 10,
  stretch_image_to_widget_size = true,
  vertical_align = "center"
}

styles["cybersyn-combinator_network-mask-text-input"] = {
  type = "textbox_style",
  horizontal_align = "right"
}

-- Credit to FactoryPlanner for list-box/scroll-pane styles
styles["cybersyn-combinator_network-list_scroll-pane"] = {
  type = "scroll_pane_style",
  parent = "list_box_in_shallow_frame_scroll_pane",
  background_graphical_set = { -- rubber grid
    position = { 282, 17 },
    corner_size = 8,
    overall_tiling_vertical_size = 22,
    overall_tiling_vertical_spacing = 6,
    overall_tiling_vertical_padding = 4,
    overall_tiling_horizontal_padding = 4
  },
  vertically_stretchable = "on",
  horizontally_stretchable = "on",
  padding = 0,
  vertical_flow_style = {
    type = "vertical_flow_style",
    vertical_spacing = 0
  }
}

styles["cybersyn-combinator_network-list_item"] = {
  type = "button_style",
  parent = "list_box_item",
  horizontally_stretchable = "on",
  horizontally_squashable = "on"
}

styles["cybersyn-combinator_network-list_item-active"] = {
  type = "button_style",
  parent = "cybersyn-combinator_network-list_item",
  default_graphical_set = styles.button.selected_graphical_set,
  hovered_graphical_set = styles.button.selected_hovered_graphical_set,
  clicked_graphical_set = styles.button.selected_clicked_graphical_set,
  default_font_color = styles.button.selected_font_color,
  default_vertical_offset = styles.button.selected_vertical_offset
}

styles["cybersyn-combinator_group-list_scroll-pane"] = {
  type = "scroll_pane_style",
  parent = "list_box_in_shallow_frame_under_subheader_scroll_pane",
  padding = 0,
  vertical_flow_style = {
    type = "vertical_flow_style",
    vertical_spacing = 0
  }
}

styles["cybersyn-combinator_frame_transparent"] = {
  type = "frame_style",
  graphical_set = {
    base = {
      type = "composition",
      filename = "__cybersyn-combinator__/graphics/frame/transparent-pixel.png",
      corner_size = 1,
      position = { 0, 0 }
    }
  }
}

styles["cybersyn-combinator_frame_semitransparent"] = {
  type = "frame_style",
  graphical_set = {
    base = {
      type = "composition",
      filename = "__cybersyn-combinator__/graphics/frame/semitransparent-pixel.png",
      corner_size = 1,
      position = { 0, 0 }
    }
  }
}

styles["cybersyn-combinator_encoder_bit-button"] = {
  type = "button_style",
  parent = "flib_standalone_slot_button_grey",
  size = 32,
  hovered_graphical_set = styles.flib_standalone_slot_button_grey.default_graphical_set
}

styles["cybersyn-combinator_encoder_bit-button_pressed"] = {
  type = "button_style",
  parent = "flib_selected_standalone_slot_button_grey",
  size = 32
}
