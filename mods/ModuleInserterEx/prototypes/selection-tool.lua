data:extend {
    {
        type = "selection-tool",
        name = "module-inserter-ex",
        icon = "__ModuleInserterEx__/graphics/module-inserter-icon.png",
        icon_size = 32,
        flags = { "not-stackable", "mod-openable", "spawnable", "only-in-cursor" },
        hidden = true,
        stack_size = 1,
        select = {
            border_color = { r = 0, g = 1, b = 0 },
            mode = { "same-force", "deconstruct" },
            cursor_box_type = "copy",
            entity_type_filters = { "mining-drill", "furnace", "assembling-machine", "lab", "beacon", "rocket-silo" },
            entity_filter_mode = "whitelist",
        },
        alt_select = {
            border_color = { r = 0, g = 0, b = 1 },
            mode = { "same-force", "any-entity" },
            cursor_box_type = "copy",
            entity_type_filters = { "mining-drill", "furnace", "assembling-machine", "lab", "beacon", "rocket-silo" },
            entity_filter_mode = "whitelist",
        },
        reverse_select = {
            border_color = { r = 1, g = 0, b = 0 },
            mode = { "same-force", "deconstruct" },
            cursor_box_type = "copy",
            entity_type_filters = { "mining-drill", "furnace", "assembling-machine", "lab", "beacon", "rocket-silo" },
            entity_filter_mode = "whitelist",
        },
    }
}
