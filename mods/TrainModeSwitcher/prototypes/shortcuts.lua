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
        icon = {
            filename = "__TrainModeSwitcher__/graphics/icons/tms_switcher_32.png",
            priority = "extra-high-no-scale",
            size = 32,
            scale = 1,
            flags = {
                "icon"
            }
        },
        small_icon = {
            filename = "__TrainModeSwitcher__/graphics/icons/tms_switcher_24.png",
            priority = "extra-high-no-scale",
            size = 24,
            scale = 1,
            flags = {
                "icon"
            }
        }
    }
})