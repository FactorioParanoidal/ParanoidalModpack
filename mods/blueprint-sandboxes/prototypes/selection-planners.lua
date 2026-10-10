SelectionPlanner = require("scripts.selection-planner")

data:extend({
    {
        type = "selection-tool",
        name = SelectionPlanner.forTiles,
        icons = {
            {
                icon = BPSB.path .. "/graphics/wrapper-x56.png",
                icon_size = 56,
                tint = { r = 0.5, g = 0.5, b = 0.5, a = 0.5 },
                scale = 1,
            },
            {
                icon = "__core__/graphics/icons/category/tiles-editor.png",
                icon_size = 128,
                scale = 0.5,
            },
        },
        group = BPSB.name,
        hidden = true,
        hidden_in_factoriopedia = true,
        stack_size = 1,
        always_include_tiles = true,
        select = {
            border_color = { r = 0, g = 1, b = 0 },
            cursor_box_type = "pair",
            mode = { "any-tile" },
        },
        alt_select = {
            border_color = { r = 0, g = 1, b = 0 },
            cursor_box_type = "pair",
            mode = { "any-tile" },
        },
        reverse_select = {
            border_color = { r = 0.5, g = 0.5, b = 1 },
            cursor_box_type = "pair",
            mode = { "any-tile" },
            tile_filters = { "lab-dark-1", "lab-dark-2" },
            tile_filter_mode = "blacklist",
        },
        alt_reverse_select = {
            border_color = { r = 0.5, g = 0.5, b = 1 },
            cursor_box_type = "pair",
            mode = { "any-tile" },
            tile_filters = { "lab-dark-1", "lab-dark-2" },
            tile_filter_mode = "blacklist",
        },
        flags = { "not-stackable", "only-in-cursor" },
    },
    {
        type = "selection-tool",
        name = SelectionPlanner.forEntities,
        icons = {
            {
                icon = BPSB.path .. "/graphics/wrapper-x56.png",
                icon_size = 56,
                tint = { r = 0.5, g = 0.5, b = 0.5, a = 0.5 },
                scale = 1,
            },
            {
                icon = "__core__/graphics/icons/category/resource-editor.png",
                icon_size = 128,
                scale = 0.25,
                shift = { -16, -16 },
            },
            {
                icon = "__core__/graphics/icons/category/enemies.png",
                icon_size = 128,
                scale = 0.25,
                shift = { 16, -16 },
            },
            {
                icon = "__core__/graphics/icons/category/asteroid-chunk-editor.png",
                icon_size = 128,
                scale = 0.25,
                shift = { -16, 16 },
            },
            {
                icon = "__core__/graphics/icons/category/environment.png",
                icon_size = 128,
                scale = 0.25,
                shift = { 16, 16 },
            },
        },
        group = BPSB.name,
        hidden = true,
        hidden_in_factoriopedia = true,
        stack_size = 1,
        select = {
            border_color = { r = 0.25, g = 0.75, b = 0 },
            cursor_box_type = "entity",
            mode = { "nothing" },
        },
        alt_select = {
            border_color = { r = 0.5, g = 1, b = 0.1 },
            cursor_box_type = "entity",
            mode = { "nothing" },
        },
        reverse_select = {
            border_color = { r = 1, g = 0.25, b = 0.5 },
            cursor_box_type = "entity",
            mode = { "any-entity" },
        },
        alt_reverse_select = {
            border_color = { r = 1, g = 0, b = 0 },
            cursor_box_type = "entity",
            mode = { "any-entity" },
        },
        flags = { "not-stackable", "only-in-cursor" },
    },
})