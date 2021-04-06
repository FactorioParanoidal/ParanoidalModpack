local styles = data.raw["gui-style"].default
styles["module-inserter-small-button"] = {
    type = "button_style",
    parent = "button",
    width = 60
}

styles["mi_delete_preset"] = {
    type = "button_style",
    parent = "tool_button_red",
    padding = 0
}

styles["mi_shortcut_bar_button_green"] = {
    type = "button_style",
    parent = "shortcut_bar_button_green",
    padding = 4
}

styles["mi_preset_button"] = {
    type = "button_style",
    parent = "button",
    width = 150,
}

local button = styles.button

styles["mi_preset_button_selected"] = {
    type = "button_style",
    parent = "mi_preset_button",
    default_font_color = button.selected_font_color,
    default_graphical_set = button.selected_graphical_set,

    hovered_font_color = button.selected_hovered_font_color,
    hovered_graphical_set = button.selected_hovered_graphical_set,

    clicked_font_color = button.selected_clicked_font_color,
    clicked_vertical_offset = 1, -- text/icon goes down on click
    clicked_graphical_set = button.selected_clicked_graphical_set,
}

styles.frame_action_button_red =
    {
      type = "button_style",
      parent = "frame_action_button",
      default_graphical_set =
      {
        base = {position = {136, 17}, corner_size = 8},
        shadow = {position = {440, 24}, corner_size = 8, draw_type = "outer"},
      },
      hovered_graphical_set =
      {
        base = {position = {170, 17}, corner_size = 8},
        shadow = {position = {440, 24}, corner_size = 8, draw_type = "outer"},
        glow = default_glow(red_button_glow_color, 0.5)--luacheck: ignore
      },
      clicked_graphical_set =
      {
        base = {position = {187, 17}, corner_size = 8},
        shadow = {position = {440, 24}, corner_size = 8, draw_type = "outer"}
      },
      disabled_graphical_set =
      {
        base = {position = {153, 17}, corner_size = 8},
        shadow = {position = {440, 24}, corner_size = 8, draw_type = "outer"}
      },
      left_click_sound = {{ filename = "__core__/sound/gui-red-button.ogg", volume = 0.5 }},
    }

data:extend{
    {
        type = "sprite",
        name = "mi_import_string",
        filename = "__base__/graphics/icons/shortcut-toolbar/mip/import-string-x24.png",
        priority = "extra-high-no-scale",
        size = 24,
        scale = 0.5,
        mipmap_count = 2,
        flags = {"gui-icon"}
    }
}

styles.mi_naked_scroll_pane = {
    type = "scroll_pane_style",
    extra_padding_when_activated = 0,
    padding = 4,
}