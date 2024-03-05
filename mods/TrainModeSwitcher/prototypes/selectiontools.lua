data:extend({
    {
        name = "tms-switcher",
        type = "selection-tool",
        flags = {
            "hidden",
            "only-in-cursor"
        },
        icon = "__TrainModeSwitcher__/graphics/icons/tms_switcher_64.png",
        icon_size = 64,
        selection_color = {
            b = 210,
            g = 210,
            r = 210
        },
        alt_selection_color = {
            b = 210,
            g = 210,
            r = 210
        },
        selection_mode = {
            "entity-with-health"
        },
        alt_selection_mode = {
            "entity-with-health"
        },
        selection_cursor_box_type = "entity",
        alt_selection_cursor_box_type = "entity",
        entity_type_filters = {
            "locomotive"
        },
        alt_entity_type_filters = {
            "locomotive"
        },
        entity_filter_mode = "whitelist",
        alt_entity_filter_mode = "whitelist",
        stackable = false,
        stack_size = 1,
        show_in_library = false
    }
})