-- [[ CORE STYLES ]] --
data.raw["gui-style"].default["ltnc_frame_style"] = {
  type   = "frame_style",
  parent = "frame",
  graphical_set = {
    base = {position = {0, 0}, corner_size = 8},
    shadow = nil
  },
  horizontally_stretchable = "on",
  
  horizontal_flow_style = { type = "horizontal_flow_style", padding=0, top_padding=10, bottom_padding=5},
  vertical_flow_style = { type = "vertical_flow_style", padding=0, top_padding=5, bottom_padding=5, vertical_spacing=10},
}

data.raw["gui-style"].default["ltnc_checkbox_style"] = {
  type   = "checkbox_style",
  parent = "checkbox",
  font = "default-semibold",
  hovered_font_color = "bold_font_color",
  width = 90,
}

-- [[ LTN STYLES ]] --
data.raw["gui-style"].default["ltnc_entry_sprite"] = {
  type   = "image_style",
  parent = "image",
  size = 32,
  left_padding=2,
  stretch_image_to_widget_size = true,
}

data.raw["gui-style"].default["ltnc_entry_label"] = {
  type   = "label_style",
  parent = "caption_label",
  horizontally_stretchable = "on",
}

data.raw["gui-style"].default["ltnc_entry_text"] = {
  type   = "textbox_style",
  parent = "short_number_textfield",
  horizontal_align = "right",
  horizontally_stretchable = "off",
}

data.raw["gui-style"].default["ltnc_entry_checkbox"] = {
  type   = "checkbox_style",
  parent = "checkbox",
  left_margin = 34,
  horizontally_stretchable = "off",
}

-- [[ MISC STYLES ]] --
data.raw["gui-style"].default["ltnc_misc_slot_empty"] = {
  type   = "button_style",
  parent = "logistic_slot_button",
}

data.raw["gui-style"].default["ltnc_misc_slot_selected"] = {
  type   = "button_style",
  parent = "selected_logistic_slot_button",
}

-- [[ NETWORK STYLES ]] --
data.raw["gui-style"].default["ltnc_network_frame"] = {
  type = "frame_style",
  parent = "ltnc_frame_style",
  title_style = {
    type = "label_style",
    parent = "ltnc_network_frame_title",
  },
  horizontal_flow_style = { type = "horizontal_flow_style", padding=0, top_padding=5, bottom_padding=5},
  vertical_flow_style = { type = "vertical_flow_style", padding=0, top_padding=5, bottom_padding=5},
}

data.raw["gui-style"].default["ltnc_network_frame_title"] = {
  type = "label_style",
  parent = "label",
  font = "heading-2",
  font_color = heading_font_color,
  top_padding = 0,
  left_padding = 0,
  bottom_padding = 0,
  right_padding = 0,
}

data.raw["gui-style"].default["ltnc_network_button_all"] = {
  type = "button_style",
  parent = "shortcut_bar_button",
  font = "default-small",
  padding = 2,
  width = 94,
  height = 28,
}

data.raw["gui-style"].default["ltnc_network_button_config"] = {
  type = "button_style",
  parent = "shortcut_bar_button",
  font = "default-small",
  padding = 2,
  size = 28
}

data.raw["gui-style"].default["ltnc_network_network_button"] = {
  type = "button_style",
  parent = "shortcut_bar_button",
  padding = 2,
  size = 32
}

data.raw["gui-style"].default["ltnc_network_network_button_pressed"] = {
  type = "button_style",
  parent = "ltnc_network_network_button",
  default_graphical_set = data.raw["gui-style"].default["button"]["selected_graphical_set"],
  hovered_graphical_set = data.raw["gui-style"].default["button"]["selected_hovered_graphical_set"],
}

data.raw["gui-style"].default["ltnc_network_sprite_button"] = {
  type = "button_style",
  parent = "shortcut_bar_button",
  padding = 2,
  size = 28,
  font = "default-small",
}

data.raw["gui-style"].default["ltnc_network_sprite_button_pressed"] = {
  type = "button_style",
  parent = "ltnc_network_sprite_button",
  default_graphical_set = data.raw["gui-style"].default["button"]["selected_graphical_set"],
  hovered_graphical_set = data.raw["gui-style"].default["button"]["selected_hovered_graphical_set"],
}
