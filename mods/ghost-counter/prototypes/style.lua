local NAME = require("shared/constants")
local guistyle = data.raw["gui-style"]["default"]

guistyle[NAME.style.root_frame] = {type="frame_style", width=422}

guistyle[NAME.style.titlebar_flow] = {type="horizontal_flow_style", horizontal_spacing=6}

guistyle[NAME.style.titlebar_space_header] = {
    type = "empty_widget_style",
    parent = "draggable_space_header",
    height = 24,
    horizontally_stretchable = "on",
    left_margin = 4,
    right_margin = 4
}

guistyle[NAME.style.titlebar_button] = {type="button_style", parent="frame_action_button"}

guistyle[NAME.style.titlebar_button_active] = {
    type = "button_style",
    parent = "frame_action_button",
    default_graphical_set = guistyle["frame_button"].clicked_graphical_set,
    clicked_graphical_set = guistyle["frame_button"].default_graphical_set
}

guistyle[NAME.style.inside_deep_frame] = {
    type = "frame_style",
    parent = "inside_deep_frame",
    horizontally_stretchable = "stretch_and_expand",
    vertically_stretchable = "stretch_and_expand",
    vertical_flow_style = {type = "vertical_flow_style", vertical_spacing = 0}
}

guistyle[NAME.style.topbar_frame] = {
    type = "frame_style",
    parent = "subheader_frame",
    top_padding = 6,
    bottom_padding = 0,
    left_padding = 6,
    right_padding = 6,
    height = 40,
    horizontally_stretchable = "stretch_and_expand",
    horizontal_flow_style = {
        type = "horizontal_flow_style",
        height = 28,
        vertical_align = "center",
        horizontal_align = "left"
    }
}

guistyle[NAME.style.get_signals_button] = {
    type = "button_style",
    parent = NAME.style.ghost_request_button,
    padding = 2,
    width = 28,
    height = 28
}

guistyle[NAME.style.topbar_space] = {
    type = "empty_widget_style",
    height = 24,
    horizontally_stretchable = "on",
    left_margin = 4,
    right_margin = 4
}

guistyle[NAME.style.ghost_request_all_button] = {
    type = "button_style",
    parent = NAME.style.ghost_request_button,
    minimal_width = 100,
    height = 28
}

guistyle[NAME.style.ghost_cancel_all_button] = {
    type = "button_style",
    parent = "slot_sized_button_red",
    padding = 2,
    height = 28,
    width = 28
}

guistyle[NAME.style.scroll_pane] = {
    type = "scroll_pane_style",
    parent = "scroll_pane",
    padding = 2,
    extra_padding_when_activated = 0,
    extra_margin_when_activated = 0,
    maximal_height = 500,
    horizontally_stretchable = "stretch_and_expand",
    vertically_stretchable = "stretch_and_expand",
    vertical_flow_style = {type="vertical_flow_style", vertical_spacing=0}
}

guistyle[NAME.style.row_frame] = {
    type = "frame_style",
    horizontally_stretchable = "stretch_and_expand",
    height = 32,
    top_padding = 0,
    bottom_padding = 0,
    right_padding = 0,
    vertical_align = "center",
    horizontal_flow_style = {
        type = "horizontal_flow_style",
        horizontal_spacing = 8,
        vertical_align = "center",
        vertically_stretchable = "stretch_and_expand"
    }
}

guistyle[NAME.style.ghost_number_label] = {type="label_style", width=40, horizontal_align="right"}

guistyle[NAME.style.ghost_sprite] = {type="image_style", width=20, height=20}

guistyle[NAME.style.ghost_name_label] = {type="label_style", width=180}

guistyle[NAME.style.inventory_number_label] = {
    type = "label_style",
    parent = NAME.style.ghost_number_label,
    font_color = {0.6, 0.6, 0.6}
}

guistyle[NAME.style.ghost_request_button] = {
    type = "button_style",
    parent = "slot_sized_button_blue",
    size = {50, 24},
    default_font_color = {1, 1, 1},
    vertically_stretchable = "stretch_and_expand"
}

guistyle[NAME.style.ghost_request_active_button] = {
    type = "button_style",
    parent = NAME.style.ghost_request_button,
    default_font_color = {0, 0, 0},
    clicked_font_color = {1, 1, 1},
    default_graphical_set = guistyle["tool_button_blue"].clicked_graphical_set,
    clicked_graphical_set = guistyle["tool_button_blue"].default_graphical_set
}

guistyle[NAME.style.ghost_request_fulfilled_flow] = {
    type = "horizontal_flow_style",
    size = {50, 24},
    horizontal_align = "center",
    vertical_align = "center"
}

guistyle[NAME.style.ghost_request_fulfilled_sprite] = {type="image_style", size={20, 20}}
