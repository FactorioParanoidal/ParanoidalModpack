data:extend(
    {
        {
            type = "selection-tool",
            name = "chunk-eraser",
            icon = "__Delete-Chunk-Tool__/graphics/Delete-Chunk-Tool.png",
            flags = {"only-in-cursor", "not-stackable", "spawnable"},
            subgroup = "tool",
            order = "c[automated-construction]-b[deconstruction-planner]",
            stack_size = 1,
            icon_size = 64,
            stackable = false,
            select = {
                border_color = {r = 0, g = 1, b = 0},
                cursor_box_type = "pair",
                mode = "nothing"},
            alt_select = {
                border_color = {r = 0, g = 0, b = 1},
                cursor_box_type = "pair",
                mode = "nothing"},
            show_in_library = true,
            hidden = true
        },
        {
            type = "shortcut",
            name = "chunk-eraser",
            order = "o[chunk-eraser]",
            action = "spawn-item",
            item_to_spawn = "chunk-eraser",
            toggleable = true,
            icon = "__Delete-Chunk-Tool__/graphics/Delete-Chunk-Tool.png",
            small_icon =  "__Delete-Chunk-Tool__/graphics/Delete-Chunk-Tool.png"
        }
    }
)
