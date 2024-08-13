data:extend({
    {
        type = "custom-input",
        name = ToggleGUI.toggleShortcut,
        order = "a[toggle]",
        key_sequence = "SHIFT + B"
    },
    {
        type = "shortcut",
        name = ToggleGUI.toggleShortcut,
        order = "b[blueprints]-z[sandbox]",
        action = "lua",
        associated_control_input = ToggleGUI.toggleShortcut,
        style = "green",
        toggleable = true,
        icon = {
            filename = BPSB.path .. "/graphics/icon-x64.png",
            priority = "extra-high-no-scale",
            size = 64,
            scale = 0.5,
            mipmap_count = 3,
            flags = { "gui-icon" },
        },
    },
})
