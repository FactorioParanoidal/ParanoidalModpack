-- 'consuming'
-- available options:
-- none: default if not defined
-- all: if this is the first input to get this key sequence then no other inputs listening for this sequence are fired
-- script-only: if this is the first *custom* input to get this key sequence then no other *custom* inputs listening for this sequence are fired.
----Normal game inputs will still be fired even if they match this sequence.
-- game-only: The opposite of script-only: blocks game inputs using the same key sequence but lets other custom inputs using the same key sequence fire.
data:extend {
    {
        type = 'custom-input',
        name = 'adjustment-pad-increase',
        key_sequence = 'PAD +',
        linked_game_control = 'larger-terrain-building-area'
    },
    {
        type = 'custom-input',
        name = 'adjustment-pad-decrease',
        key_sequence = 'PAD -',
        linked_game_control = 'smaller-terrain-building-area'
    }
}

data:extend {
    {
        type = 'sprite',
        name = 'adjustment_pad_button_plus',
        filename = '__PickerAtheneum__/graphics/gui/frame-button-icons.png',
        position = {0,0},
        size = 32,
        flags = {'icon'}
    },
    {
        type = 'sprite',
        name = 'adjustment_pad_button_minus',
        filename = '__PickerAtheneum__/graphics/gui/frame-button-icons.png',
        position = {32,0},
        size = 32,
        flags = {'icon'}
    },
    {
        type = 'sprite',
        name = 'adjustment_pad_button_plus_dark',
        filename = '__PickerAtheneum__/graphics/gui/frame-button-icons.png',
        position = {0,32},
        size = 32,
        flags = {'icon'}
    },
    {
        type = 'sprite',
        name = 'adjustment_pad_button_minus_dark',
        filename = '__PickerAtheneum__/graphics/gui/frame-button-icons.png',
        position = {32,32},
        size = 32,
        flags = {'icon'}
    }
}

data:extend {
    {
        type = 'font',
        name = 'adjustment_pad-button-font',
        from = 'default',
        size = 8
    }
}

local style = data.raw['gui-style'].default

style.adjustment_pad_frame_style = {
    type = 'frame_style',
    parent = 'frame',
    top_padding = 2,
    left_padding = 6,
    right_padding = 6,
    bottom_padding = 2
}

style.adjustment_pad_flow_style = {
    type = 'horizontal_flow_style',
    vertical_align = 'center',
    horizontal_spacing = 8
}

style.adjustment_pad_text_style = {
    type = 'textbox_style',
    parent = 'number_input_textbox',
    maximal_width = 42,
    minimal_width = 42,
    maximal_height = 24,
    minimal_height = 24,
    font = 'default-small'
}

style.adjustment_pad_button_flow_style = {
    type = 'vertical_flow_style',
    vertical_spacing = 0
}

style.adjustment_pad_btn_reset_style = {
    type = 'button_style',
    parent = 'red_icon_button',
    left_margin = 1
}