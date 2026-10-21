data:extend({
    {
        name = "tms-switcher",
        type = "selection-tool",
        flags = {
            "only-in-cursor"
        },
        icon = "__TrainModeSwitcher__/graphics/icons/tms_switcher_64.png",
        icon_size = 64,
        select = {
            border_color = {
                b = 210,
                g = 210,
                r = 210
            },
            cursor_box_type = "entity",
            entity_filter_mode = "whitelist",
            entity_type_filters = {
                "locomotive"
            },
            mode = "entity-with-health"
        },
        alt_select = {
            border_color = {
                b = 210,
                g = 210,
                r = 210
            },
            cursor_box_type = "entity",
            entity_filter_mode = "whitelist",
            entity_type_filters = {
                "locomotive"
            },
            mode = "entity-with-health"  
        },
        stack_size = 1,
        hidden = true
    }
})