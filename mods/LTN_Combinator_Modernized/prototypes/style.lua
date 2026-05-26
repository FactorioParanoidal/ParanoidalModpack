local styles = data.raw["gui-style"].default

styles.ltnc_cancel_button = {
  type = "button_style",
  parent = "red_button",
  size = 28,
  padding = 0,
  top_margin = 1,
  tooltip = "ltnc-tooltips.ltnc-cancel-instruction"
}

styles.ltnc_confirm_button = {
  type = "button_style",
  parent = "green_button",
  size = 28,
  padding = 0,
  top_margin = 1,
  tooltip = "ltnc-tooltips.ltnc-apply-instruction"
}

styles.ltnc_small_button = {
  type = "button_style",
  parent = "flib_standalone_slot_button_grey",
  size = 32,
  font = "default-small"
}

styles.ltnc_net_id_button = {
  type = "button_style",
  parent = "ltnc_small_button",
  size = 32,
  hovered_graphical_set = styles.flib_standalone_slot_button_grey.default_graphical_set,
}

styles.ltnc_net_id_button_pressed = {
  type = "button_style",
  parent = "flib_selected_standalone_slot_button_grey",
  size = 32,
  font = "default-small"
}
styles.ltnc_header_label = {
  type   = "label_style",
  parent = "caption_label",
  top_margin = 4,
  bottom_margin = 4,
}

styles.ltnc_entry_sprite = {
  type   = "image_style",
  parent = "image",
  size = 32,
  left_padding=2,
  stretch_image_to_widget_size = true,
}

styles.ltnc_entry_text = {
  type   = "textbox_style",
  parent = "short_number_textfield",
  --minimal_width = 108,
  minimal_width = 94,
  horizontal_align = "right",
  horizontally_stretchable = "off",
}

styles.ltnc_entry_text_default_value = {
  type = "textbox_style",
  parent = "ltnc_entry_text",
  font_color = { 1, 1, 1 },
  default_background = {
    base = {position = {282, 0}, corner_size = 8},
  },
  selection_background_color= {116, 106, 93},
}

styles.ltnc_entry_text_not_transmitted = {
  type = "textbox_style",
  parent = "ltnc_entry_text_default_value",
  font_color = {255, 1, 1},
}

styles.ltnc_entry_text_invalid_value = {
  type = "textbox_style",
  parent = "invalid_value_short_number_textfield",
  --minimal_width = 108,
  minimal_width = 94,
  horizontal_align = "right",
  horizontally_stretchable = "off",
}

styles.signal_count = {
  type = "label_style",
  parent = "count_label",
  size = 36,
  width = 36,
  horizontal_align = "right",
  vertical_align = "bottom",
  right_padding = 2,
}