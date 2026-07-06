data:extend({
    {
        name = "tms-toggle",
        type = "shortcut",
        action = "lua",
        associated_control_input = "tms-toggle",
        technology_to_unlock = "automated-rail-transportation",
        toggleable = false,
        order = "p[tms]-a[switcher]",
        localised_name = {
            "shortcut.tms-toggle"
        },
        icons = {
            {
                icon = "__TrainModeSwitcher__/graphics/icons/tms_switcher_32.png",
                icon_size = 32,
                scale = 1
            }
        },
        small_icons = {
            {
                icon = "__TrainModeSwitcher__/graphics/icons/tms_switcher_24.png",
                icon_size = 24,
                scale = 1
            }
        }
    }
})