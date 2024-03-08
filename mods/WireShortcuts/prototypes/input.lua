function wire_hotkey(wire_type, keybind)
    return {
        type = "custom-input",
        name = "WireShortcuts-give-" .. wire_type,
        key_sequence = keybind,
        action = "lua",
        consuming = "none"
    }
end

data:extend({
    wire_hotkey("red", "ALT + F"),
    wire_hotkey("green", "ALT + G"),
    wire_hotkey("copper", "ALT + C"),
    wire_hotkey("cutter", "ALT + X"),
    {
        type = "custom-input",
        name = "WireShortcuts-switch-wire",
        key_sequence = "CONTROL + TAB",
        consuming = "none"
    }
})
