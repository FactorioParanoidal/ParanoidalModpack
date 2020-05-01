local default_glow_color = {225, 177, 106, 255}
local red_glow_color = {225, 51, 0, 255}
local default_dirt_color = {15, 7, 3, 100}
local function default_glow(tint_value, scale_value)
  return
  {
    position = {200, 128},
    corner_size = 8,
    tint = tint_value,
    scale = scale_value,
    draw_type = "outer"
  }
end
local default_dirt = default_glow(default_dirt_color, 0.5)

-- mod_gui_button with red background
add_style("ltnt_toggle_button_with_alert", {
  type = "button_style",
  parent = "mod_gui_button",
  default_graphical_set = {
    base = {position = {136, 17}, corner_size = 8},
    shadow = default_dirt,
  },
  hovered_graphical_set = {
    base = {position = {170, 17}, corner_size = 8},
    shadow = default_dirt,
    glow = default_glow(default_glow_color, 0.5),
  },
  clicked_vertical_offset = 1,
  clicked_graphical_set = {
    base = {position = {187, 17}, corner_size = 8},
    shadow = default_dirt,
  },
})

-- tab selector at the top of the root frame
add_style("ltnt_tab_button", {
  type = "button_style",
  font = "ltnt_font_tab_caption",
  horizontal_align = "center",
  vertical_align = "center",
  disabled_font_color = {r=1, g=1, b=1},
  minimal_width = C.main_frame.button_width,
  maximal_width = C.main_frame.button_width,
})

add_style("ltnt_tab_button_highlight", {
  type = "button_style",
  parent = "ltnt_tab_button",
  default_graphical_set = {
    base = {position = {136, 17}, corner_size = 8},
    shadow = default_dirt,
  },
  hovered_graphical_set = {
    base = {position = {170, 17}, corner_size = 8},
    shadow = default_dirt,
    glow = default_glow(red_glow_color, 0.5),
  },
  clicked_vertical_offset = 1,
  clicked_graphical_set = {
    base = {position = {187, 17}, corner_size = 8},
    shadow = default_dirt,
  },
})
-- depot selector button
add_style("ltnt_depot_button", {
  type = "button_style",
  parent = "button",
  padding = 0,
  minimal_height = 100,
  maximal_height = 100,
  minimal_width = C.depot_tab.pane_width_left - 20,
  maximal_width = C.depot_tab.pane_width_left - 20,
  default_font_color = C.styles.font_color_black,
  hovered_font_color = C.styles.font_color_black,
  clicked_font_color = C.styles.font_color_black,
})

-- item buttons for inventory tab
add_style("ltnt_empty_button", {
  type = "button_style",
  parent = "slot_button",
  disabled_graphical_set = {
    border = 1,
    filename = "__core__/graphics/gui.png",
    position = {111, 0},
    size = 36,
    scale = 1
  }
})
add_style("ltnt_provided_button", {
  type = "button_style",
  parent = "green_slot_button",
  disabled_graphical_set = {
    border = 1,
    filename = "__core__/graphics/gui.png",
    position = {111, 108},
    size = 36,
    scale = 1
  },
})
add_style("ltnt_requested_button", {
  type = "button_style",
  parent = "red_slot_button",
  disabled_graphical_set = {
    border = 1,
    filename = "__core__/graphics/gui.png",
    position = {111, 36},
    size = 36,
    scale = 1
  },
})

-- sort triangle button in station table header
add_style("ltnt_sort_button_on", {
  type = "button_style",
  size = {16, 16},
  default_graphical_set = {
    filename = "__core__/graphics/arrows/table-header-sort-arrow-down-active.png",
    size = {16, 16},
    scale = 1
  },
  hovered_graphical_set = {
    filename = "__core__/graphics/arrows/table-header-sort-arrow-down-hover.png",
    size = {16, 16},
    scale = 1
  },
  clicked_graphical_set = {
    filename = "__core__/graphics/arrows/table-header-sort-arrow-down-active.png",
    size = {16, 16},
    scale = 1
  },
  disabled_graphical_set = {
    filename = "__core__/graphics/arrows/table-header-sort-arrow-down-white.png",
    size = {16, 16},
    scale = 1
  }
})
add_style("ltnt_sort_button_off", {
  type = "button_style",
  size = {16, 16},
  default_graphical_set = {
    filename = "__core__/graphics/arrows/table-header-sort-arrow-down-white.png",
    size = {16, 16},
    scale = 1
  },
  hovered_graphical_set = {
    filename = "__core__/graphics/arrows/table-header-sort-arrow-down-hover.png",
    size = {16, 16},
    scale = 1
  },
  clicked_graphical_set = {
    filename = "__core__/graphics/arrows/table-header-sort-arrow-down-white.png",
    size = {16, 16},
    scale = 1
  },
  disabled_graphical_set = {
    filename = "__core__/graphics/arrows/table-header-sort-arrow-down-white.png",
    size = {16, 16},
    scale = 1
  }
})