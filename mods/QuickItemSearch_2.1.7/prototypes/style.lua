local constants = require("__QuickItemSearch__/constants")

local styles = data.raw["gui-style"].default

-- FRAME STYLES

styles.qis_window_dimmer = {
  type = "frame_style",
  graphical_set = {
    base = {
      filename = "__flib__/graphics/black.png",
      size = 1,
      opacity = 0.3,
    },
  },
}

-- LABEL STYLES

styles.qis_clickable_label = {
  type = "label_style",
  hovered_font_color = constants.colors.hovered,
  disabled_font_color = constants.colors.hovered,
}

styles.qis_clickable_item_label = {
  type = "label_style",
  parent = "qis_clickable_label",
  horizontally_stretchable = "on",
}

-- SCROLLPANE STYLES

styles.qis_list_box_scroll_pane = {
  type = "scroll_pane_style",
  parent = "list_box_scroll_pane",
  graphical_set = {
    shadow = default_inner_shadow,
  },
  vertical_flow_style = {
    type = "vertical_flow_style",
    vertical_spacing = 0,
    horizontally_stretchable = "on",
  },
}

-- TABLE STYLES

styles.qis_list_box_table = {
  type = "table_style",
  parent = "mods_table",
  top_margin = -6, -- to hide the strange first row styling
  column_alignments = {
    { column = 1, alignment = "left" },
    { column = 2, alignment = "center" },
    { column = 3, alignment = "center" },
  },
}

-- TEXTFIELD STYLES

styles.qis_disablable_textfield = {
  type = "textbox_style",
  disabled_background = styles.textbox.default_background,
  disabled_font_color = button_default_font_color,
}
