-------------------------------------------------------------------------------
--[[STYLES and BUTTON SPRITES]] --
-------------------------------------------------------------------------------
local style = data.raw['gui-style'].default

--[[Frames]]
style.picker_frame = {
    type = 'frame_style',
    parent = 'frame',
    top_padding = 0,
    bottom_padding = 0,
    right_padding = 0,
    left_padding = 0
}

--[[Tables]]
style.picker_table = {
    type = 'table_style',
    parent = 'table',
    top_padding = 0,
    bottom_padding = 0,
    right_padding = 0,
    left_padding = 0,
    cell_spacing = 0,
    horizontal_spacing = 0,
    vertical_spacing = 0
}

--[[32x32 Button Styles]]
style.picker_buttons = {
    type = 'button_style',
    parent = 'button',
    maximal_height = 33,
    minimal_height = 33,
    maximal_width = 33,
    minimal_width = 33,
    top_padding = 0,
    bottom_padding = 0,
    right_padding = 0,
    left_padding = 0,
    left_click_sound = {
        {
            filename = '__core__/sound/gui-click.ogg',
            volume = 1
        }
    },
    right_click_sound = {
        {
            filename = '__core__/sound/gui-click.ogg',
            volume = 1
        }
    }
}

style.picker_buttons_med = {
    type = 'button_style',
    parent = 'picker_buttons',
    maximal_height = 48,
    minimal_height = 48,
    maximal_width = 48,
    minimal_width = 48
}

style.picker_buttons_big = {
    type = 'button_style',
    parent = 'picker_buttons',
    maximal_height = 64,
    minimal_height = 64,
    maximal_width = 64,
    minimal_width = 64
}

style.picker_buttons_med_off = {
    type = 'button_style',
    parent = 'picker_buttons_med',
    default_graphical_set = {
        corner_size = {
            3,
            3
        },
        filename = '__core__/graphics/gui.png',
        load_in_minimal_mode = true,
        position = {
            16,
            16
        },
        priority = 'extra-high-no-scale',
        type = 'composition'
    }
}

--[[What is it used for]]
style.small_spacing_scroll_pane_style = {
    type = 'scroll_pane_style',
    parent = 'scroll_pane',
    top_padding = 2,
    left_padding = 0,
    right_padding = 0
    --flow_style = "slot_table_spacing_flow"
}
style.row_table_style = {
    type = 'table_style',
    cell_padding = 5,
    horizontal_spacing = 0,
    vertical_spacing = 0,
    odd_row_graphical_set = {
        type = 'composition',
        filename = '__core__/graphics/gui.png',
        priority = 'extra-high-no-scale',
        corner_size = {3, 3},
        position = {8, 0}
    },
    even_row_graphical_set = {
        type = 'composition',
        filename = '__core__/graphics/gui.png',
        priority = 'extra-high-no-scale',
        corner_size = {3, 3},
        position = {8, 0}
    }
}
