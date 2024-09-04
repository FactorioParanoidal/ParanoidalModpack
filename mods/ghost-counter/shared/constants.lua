local mod_prefix = "ghost-counter-"

local NAME = {
    tool={ghost_counter=mod_prefix .. "tool"},
    shortcut={button=mod_prefix .. "shortcut"},
    setting={min_update_interval=mod_prefix .. "min-update-interval"},
    sprite = {
        get_signals_white = mod_prefix .. "get-signals-white",
        get_signals_black = mod_prefix .. "get-signals-black",
        hide_empty_white = mod_prefix .. "hide-empty-white",
        hide_empty_black = mod_prefix .. "hide-empty-black",
        craft_all_white = mod_prefix .. "craft-all-white",
        craft_all_black = mod_prefix .. "craft-all-black",
        cancel_white = mod_prefix .. "cancel-white",
        cancel_black = mod_prefix .. "cancel-black"
    },
    gui = {
        root_frame = mod_prefix .. "root-frame",
        hide_empty_button = mod_prefix .. "hide-empty-requests-button",
        close_button = mod_prefix .. "close-button",
        get_signals_button = mod_prefix .. "convert-to-signals-button",
        craft_all_button = mod_prefix .. "craft-all",
        request_all_button = mod_prefix .. "request-all-button",
        cancel_all_button = mod_prefix .. "cancel-all-button",
        scroll_pane = mod_prefix .. "scroll-pane"
    },
    input = {
        ghost_counter_selection = mod_prefix .. "selection-hotkey"
    },
    style = {
        root_frame = mod_prefix .. "root-frame",
        titlebar_flow = mod_prefix .. "titlebar-flow",
        titlebar_space_header = mod_prefix .. "titlebar-space-header",
        titlebar_button = mod_prefix .. "titlebar-button",
        titlebar_button_active = mod_prefix .. "titlebar-button-active",
        inside_deep_frame = mod_prefix .. "inside-deep-frame",
        topbar_frame = mod_prefix .. "topbar-frame",
        get_signals_button = mod_prefix .. "get-signals-button",
        topbar_space = mod_prefix .. "topbar-space",
        ghost_request_all_button = mod_prefix .. "ghost-request-all-button",
        ghost_cancel_all_button = mod_prefix .. "ghost-cancell-all-button",
        scroll_pane = mod_prefix .. "scroll-pane",
        row_frame = mod_prefix .. "row-frame",
        ghost_number_label = mod_prefix .. "ghost-number-label",
        ghost_sprite = mod_prefix .. "ghost-sprite",
        ghost_name_label = mod_prefix .. "ghost-name-label",
        inventory_number_label = mod_prefix .. "inventory-number-label",
        ghost_request_button = mod_prefix .. "ghost-request-button",
        ghost_request_active_button = mod_prefix .. "ghost-request-active-button",
        ghost_request_fulfilled_flow = mod_prefix .. "ghost-request-fulfilled-flow",
        ghost_request_fulfilled_sprite = mod_prefix .. "ghost-request-fulfilled-sprite"
    }
}

return NAME
