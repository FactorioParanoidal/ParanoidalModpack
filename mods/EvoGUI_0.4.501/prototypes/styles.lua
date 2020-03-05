local default_gui = data.raw["gui-style"].default

local function button_graphics(xpos, ypos)
    return {
        filename = "__EvoGUI__/graphics/gui.png",
        priority = "extra-high-no-scale",
        width = 16,
        height = 16,
        x = xpos,
        y = ypos
    }
end

default_gui.EvoGUI_outer_frame_no_border = {
    type = "frame_style",
    parent = "outer_frame",
    graphical_set = {}
}

default_gui.EvoGUI_button_with_icon = {
    type = "button_style",
    parent = "slot_button",

    scalable = true,

    top_padding = 0,
    right_padding = 0,
    bottom_padding = 0,
    left_padding = 0,

    width = 17,
    height = 17,

    default_graphical_set = button_graphics( 0,  0),
    hovered_graphical_set = button_graphics(16,  0),
    clicked_graphical_set = button_graphics(32,  0),
}



default_gui.EvoGUI_expando_closed = {
    type = "button_style",
    parent = "EvoGUI_button_with_icon",

    default_graphical_set = button_graphics( 0, 16),
    hovered_graphical_set = button_graphics(16, 16),
    clicked_graphical_set = button_graphics(32, 16),
}


default_gui.EvoGUI_expando_open = {
    type = "button_style",
    parent = "EvoGUI_button_with_icon",

    default_graphical_set = button_graphics( 0, 32),
    hovered_graphical_set = button_graphics(16, 32),
    clicked_graphical_set = button_graphics(32, 32),
}

default_gui.EvoGUI_settings = {
    type = "button_style",
    parent = "EvoGUI_button_with_icon",

    default_graphical_set = button_graphics( 0, 48),
    hovered_graphical_set = button_graphics(16, 48),
    clicked_graphical_set = button_graphics(32, 48),
}

default_gui.EvoGUI_cramped_flow_v = {
    type = "vertical_flow_style",
    vertical_spacing = 1,
    horizontal_spacing = 1,
}

default_gui.EvoGUI_cramped_flow_h = {
    type = "horizontal_flow_style",
    vertical_spacing = 1,
    horizontal_spacing = 1,
}
