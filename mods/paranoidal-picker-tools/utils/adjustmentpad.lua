-------------------------------------------------------------------------------
--[Adjustment Pad]--
-------------------------------------------------------------------------------
local Pad = {}
local events = require('utils/events')
local lib = require('utils/lib')

function Pad.register_events(pad_name, func, extra_events)
    events.on_click(pad_name .. '_btn_reset', func)
    events.on_confirmed(
        pad_name .. '_text_box',
        function(event)
            event.change = true
            func(event)
        end
    )
    events.on_click(
        pad_name .. '_btn_up',
        function(event)
            event.change = 1
            func(event)
        end
    )
    events.on_click(
        pad_name .. '_btn_dn',
        function(event)
            event.change = -1
            func(event)
        end
    )

    local function keybind_event(event)
        if event.input_name == 'adjustment-pad-increase' then
            event.change = 1
            func(event)
        elseif event.input_name == 'adjustment-pad-decrease' then
            event.change = -1
            func(event)
        end
    end
    events.on({'adjustment-pad-increase', 'adjustment-pad-decrease'}, keybind_event)

    for _, event in pairs(extra_events or {}) do
        events.on(event, func)
    end
end

function Pad.remove_gui(player, frame_name, flow_name)
    flow_name = flow_name or 'picker'
    local main_flow = lib.get_or_create_main_left_flow(player, flow_name)
    return main_flow[frame_name] and main_flow[frame_name].destroy()
end

function Pad.get_or_create_adjustment_pad(player, pad_name, flow_name) -- return gui
    flow_name = flow_name or 'picker'
    local main_flow = lib.get_or_create_main_left_flow(player, flow_name)

    local gui = main_flow[pad_name .. '_frame_main']
    if not gui then
        gui =
            main_flow.add {
            type = 'frame',
            name = pad_name .. '_frame_main',
            direction = 'horizontal',
            style = 'adjustment_pad_frame_style'
        }
        local flow =
            gui.add {
            type = 'flow',
            name = pad_name .. '_flow',
            direction = 'horizontal',
            style = 'adjustment_pad_flow_style'
        }
        flow.add {
            type = 'label',
            name = pad_name .. '_label',
            caption = {pad_name .. '-gui.label-caption'},
            tooltip = {pad_name .. '-tooltip.label-caption'},
            style = 'heading_2_label'
        }
        flow.add {
            type = 'textfield',
            name = pad_name .. '_text_box',
            text = 0,
            style = 'adjustment_pad_text_style',
            lose_focus_on_confirm = true,
            numeric = true,
            clear_and_focus_on_right_click = true
        }
        --Up/Down buttons
        local button_flow =
            flow.add {
            type = 'flow',
            name = pad_name .. '_button_flow',
            direction = 'vertical',
            style = 'adjustment_pad_button_flow_style'
        }
        button_flow.add {
            type = 'sprite-button',
            name = pad_name .. '_btn_up',
            style = 'frame_action_button',
            sprite = 'adjustment_pad_button_plus',
            hovered_sprite = 'adjustment_pad_button_plus_dark',
            clicked_sprite = 'adjustment_pad_button_plus_dark'
        }
        button_flow.add {
            type = 'sprite-button',
            name = pad_name .. '_btn_dn',
            style = 'frame_action_button',
            sprite = 'adjustment_pad_button_minus',
            hovered_sprite = 'adjustment_pad_button_minus_dark',
            clicked_sprite = 'adjustment_pad_button_minus_dark'
        }
        --Reset button
        flow.add {
            type = 'sprite-button',
            name = pad_name .. '_btn_reset',
            tooltip = {pad_name .. '-tooltip.label-reset'},
            style = 'adjustment_pad_btn_reset_style',
            sprite = 'utility/reset'
        }
    end
    return gui[pad_name .. '_flow']
end

return Pad
