local ICON = "__Delete-Chunk-Tool-reforged__/graphics/chunk-eraser.png"

data:extend({
    {
        type = "selection-tool",
        name = "chunk-eraser",
        icon = ICON,
        icon_size = 64,
        flags = {"only-in-cursor", "not-stackable", "spawnable"},
        subgroup = "tool",
        order = "c[automated-construction]-b[deconstruction-planner]",
        stack_size = 1,
        hidden = true,
        select = {border_color = {r = 0, g = 1, b = 0}, cursor_box_type = "pair", mode = "nothing"},
        alt_select = {border_color = {r = 1, g = 0.5, b = 0}, cursor_box_type = "pair", mode = "nothing"},
    },
    {
        type = "shortcut",
        name = "chunk-eraser",
        order = "o[chunk-eraser]-a",
        action = "spawn-item",
        item_to_spawn = "chunk-eraser",
        icon = ICON,
        icon_size = 64,
        small_icon = ICON,
        small_icon_size = 64,
    },
    {
        type = "shortcut",
        name = "chunk-trim",
        order = "o[chunk-eraser]-b",
        action = "lua",
        icon = ICON,
        icon_size = 64,
        small_icon = ICON,
        small_icon_size = 64,
    },
})
