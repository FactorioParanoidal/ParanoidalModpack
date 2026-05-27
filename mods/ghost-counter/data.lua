local NAME = require("shared/constants")

require("prototypes/style")

data:extend{
    {
        type = "selection-tool",
        name = NAME.tool.ghost_counter,
        subgroup = "tool",
        select = {
            mode = {"any-entity", "same-force"},
            cursor_box_type = "copy",
            border_color = {57, 156, 251},
            count_button_color = {43, 113, 180},
        },
        alt_select = {
            mode = {"any-entity", "same-force"},
            cursor_box_type = "copy",
            border_color = {0, 89, 132},
            count_button_color = {43, 113, 180}
        },
        stack_size = 1,
        hidden = true,
        flags = {"only-in-cursor", "not-stackable", "spawnable"},
        icon = "__ghost-counter__/graphics/ghost-small.png",
        icon_size = 64
    }, {
        type = "shortcut",
        name = NAME.shortcut.button,
        localised_name = {"shortcut.make-ghost-counter"},
        action = "lua",
        icon = "__ghost-counter__/graphics/ghost.png",
        small_icon = "__ghost-counter__/graphics/ghost.png",
        associated_control_input = NAME.input.ghost_counter_selection,
        style = "blue"
    }, {
        type = "custom-input",
        name = NAME.input.ghost_counter_selection,
        key_sequence = "CONTROL + G",
        order = "a",
        action = "lua"
    }, {
        type = "sprite",
        name = NAME.sprite.get_signals_white,
        filename = "__ghost-counter__/graphics/get-signals-white.png",
        priority = "extra-high",
        size = 64,
        flags = {"gui-icon"},
        scale = 0.5
    }, {
        type = "sprite",
        name = NAME.sprite.get_signals_black,
        filename = "__ghost-counter__/graphics/get-signals-black.png",
        priority = "extra-high",
        size = 64,
        flags = {"gui-icon"},
        scale = 0.5
    }, {
        type = "sprite",
        name = NAME.sprite.hide_empty_white,
        filename = "__ghost-counter__/graphics/hide-white.png",
        priority = "extra-high",
        size = 64,
        flags = {"gui-icon"},
        scale = 0.5
    }, {
        type = "sprite",
        name = NAME.sprite.hide_empty_black,
        filename = "__ghost-counter__/graphics/hide-black.png",
        priority = "extra-high",
        size = 64,
        flags = {"gui-icon"},
        scale = 0.5
    }, {
        type = "sprite",
        name = NAME.sprite.craft_all_white,
        filename = "__ghost-counter__/graphics/craft-white.png",
        priority = "extra-high",
        size = 64,
        flags = {"gui-icon"},
        scale = 0.5
    }, {
        type = "sprite",
        name = NAME.sprite.craft_all_black,
        filename = "__ghost-counter__/graphics/craft-black.png",
        priority = "extra-high",
        size = 64,
        flags = {"gui-icon"},
        scale = 0.5
    }, {
        type = "sprite",
        name = NAME.sprite.cancel_white,
        filename = "__ghost-counter__/graphics/cancel-white.png",
        priority = "extra-high",
        size = 64,
        flags = {"gui-icon"},
        scale = 0.5
    }, {
        type = "sprite",
        name = NAME.sprite.cancel_black,
        filename = "__ghost-counter__/graphics/cancel-black.png",
        priority = "extra-high",
        size = 64,
        flags = {"gui-icon"},
        scale = 0.5
    }
}
