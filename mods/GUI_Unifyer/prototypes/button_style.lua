local GUIPATH = "__GUI_Unifyer__/graphics/gui/"
local COLORS = {
    transparent = {0, 0, 0, 0},
    white = {1, 1, 1, 0.9},
    black = {0, 0, 0, 0.9},
    strikethrough = {0.5, 0.5, 0.5},
    disabled = {179, 179, 179}
}

-- Utility function to define styles in a streamlined way
local function define_button_style(name, parent, color, graphic_set)
    data.raw["gui-style"].default[name] = {
        type = "button_style",
        parent = parent,
        default_font_color = color,
        hovered_font_color = color,
        clicked_font_color = color,
        disabled_font_color = color,
        selected_font_color = color,
        selected_hovered_font_color = color,
        selected_clicked_font_color = color,
        strikethrough_color = color,
        default_graphical_set = graphic_set
    }
end

-- Core Button Styles
define_button_style("slot_button_notext", "slot_button", COLORS.transparent, nil)
define_button_style("slot_button_notext_selected", "slot_button_notext", COLORS.transparent, {
    base = {border = 4, position = {160, 736}, size = 80},
    shadow = offset_by_2_rounded_corners_glow({15, 7, 3, 100})
})
define_button_style("slot_button_whitetext", "slot_button", COLORS.white, nil)
define_button_style("slot_sized_button_notext", "slot_sized_button", COLORS.transparent, nil)
define_button_style("slot_sized_button_blacktext", "slot_sized_button", COLORS.black, nil)
define_button_style("slot_button_notext_transparent", "slot_button_notext", COLORS.transparent, {
    base = {border = 4, position = {0, 736}, size = 80, opacity = 0.5},
    shadow = offset_by_2_rounded_corners_glow({15, 7, 3, 100})
})

-- Custom Button Style Variants
data.raw["gui-style"].default["slot_sized_button_notext_selected"] = {
    type = "button_style",
    parent = "slot_sized_button_notext",
    default_graphical_set = {
        base = {position = {363, 744}, corner_size = 8},
        shadow = offset_by_2_default_glow(default_dirt_color, 0.5)
    }
}

data.raw["gui-style"].default["slot_button_notext_transparent_selected"] = {
    type = "button_style",
    parent = "slot_button_notext_transparent",
    default_graphical_set = {
        base = {border = 4, position = {0, 736}, size = 80, opacity = 0.5},
        shadow = offset_by_2_rounded_corners_glow({15, 7, 3, 100})
    }
}

-- Dynamic Button Style Creation
local function create_dynamic_button_style(name, imgsize, border, opacity)
    data.raw["gui-style"].default[name] = {
        type = "button_style",
        parent = "slot_button_notext",
        draw_shadow_under_picture = true,
        size = imgsize / 2,
        padding = 0,
        default_graphical_set = {
            base = {type = "composition", filename = GUIPATH .. name .. ".png", border = border, position = {0, 0}, size = imgsize, opacity = opacity}
        },
        hovered_graphical_set = {
            base = {type = "composition", filename = GUIPATH .. name .. ".png", border = border, position = {imgsize, 0}, size = imgsize, opacity = opacity}
        },
        clicked_graphical_set = {
            base = {type = "composition", filename = GUIPATH .. name .. ".png", border = border, position = {imgsize * 2, 0}, size = imgsize, opacity = opacity}
        },
        selected_graphical_set = {
            base = {type = "composition", filename = GUIPATH .. name .. ".png", border = border, position = {imgsize, 0}, size = imgsize, opacity = opacity}
        }
    }
end

-- Define custom button styles with varying opacities
for i = 1, 8 do
    local opacity = i <= 4 and 1 or (i <= 6 and 0.8 or 0.9)
    create_dynamic_button_style("gui_Unifier_gui_0" .. i, 80, 4, opacity)
end

-- Define Font and Button Styles for Specific Functions
data:extend({
    {
        type = "font",
        name = "default-semibold-snouz",
        from = "default-semibold",
        size = 12
    }
})

data.raw["gui-style"].default["todo_button_default_snouz"] = {
    type = "button_style",
    font = "default-semibold-snouz",
    horizontal_align = "center",
    vertical_align = "center",
    icon_horizontal_align = "center",
    ignored_by_search = true,
    minimal_width = 40,
    height = 40,
    default_font_color = COLORS.white,
    default_graphical_set = {base = {filename = GUIPATH .. "gui_Unifier_gui_default_recreated.png", position = {0, 0}, corner_size = 12, scale = 0.5}},
    hovered_font_color = COLORS.white,
    hovered_graphical_set = {base = {filename = GUIPATH .. "gui_Unifier_gui_default_recreated.png", position = {25, 0}, corner_size = 12, scale = 0.5}},
    clicked_font_color = COLORS.white,
    clicked_vertical_offset = 1,
    clicked_graphical_set = {base = {filename = GUIPATH .. "gui_Unifier_gui_default_recreated.png", position = {50, 0}, corner_size = 12, scale = 0.5}},
    disabled_font_color = COLORS.disabled,
    disabled_graphical_set = {base = {filename = GUIPATH .. "gui_Unifier_gui_default_recreated.png", position = {0, 0}, corner_size = 12, scale = 0.5}},
    selected_font_color = COLORS.white,
    selected_graphical_set = {base = {filename = GUIPATH .. "gui_Unifier_gui_default_recreated.png", position = {50, 0}, corner_size = 12, scale = 0.5}},
    pie_progress_color = COLORS.white,
    left_click_sound = {{filename = "__core__/sound/gui-click.ogg", volume = 1}}
}

data.raw["gui-style"].default["todo_button_default_snouz_selected"] = {
    type = "button_style",
    parent = "todo_button_default_snouz",
    default_graphical_set = {base = {filename = GUIPATH .. "gui_Unifier_gui_default_recreated.png", position = {50, 0}, corner_size = 12, scale = 0.5}}
}

data.raw["gui-style"].default["adjacentchunks_button"] = {
    type = "button_style",
    parent = "todo_button_default_snouz",
    width = 20,
    height = 13,
    left_padding = 0,
    right_padding = 0
}
