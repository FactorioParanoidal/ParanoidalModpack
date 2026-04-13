data:extend{{
    type = "custom-input",
    name = "bv-highlight-belt",
    key_sequence = "SHIFT + G",
    action = "lua",
    order = "b",
}, {
    type = "custom-input",
    name = "bv-highlight-ghost",
    key_sequence = "G",
    action = "lua",
    order = "a",
}, {
    type = "custom-input",
    name = "bv-toggle-hover",
    key_sequence = "",
    action = "lua",
    order = "c",
}, {
    type = "shortcut",
    name = "bv-toggle-hover",
    localised_name = {"shortcut.bv-toggle-hover"},
    associated_control_input = "bv-toggle-hover",
    action = "lua",
    toggleable = true,
    icon = "__belt-visualizer__/graphics/toggle-hover-x32.png",
    icon_size = 32,
    small_icon = "__belt-visualizer__/graphics/toggle-hover-x24.png",
    small_icon_size = 24,
    -- icon = {
    --     filename = "__belt-visualizer__/graphics/toggle-hover-x32.png",
    --     size = 32,
    --     -- scale = 0.5,
    -- },
    -- small_icon =
    -- {
    --   filename = "__belt-visualizer__/graphics/toggle-hover-x24.png",
    --   size = 24,
    -- --   scale = 0.5,
    -- },
    -- disabled_small_icon =
    -- {
    --   filename = "__belt-visualizer__/graphics/toggle-hover-x24-white.png",
    --   size = 24,
    -- --   scale = 0.5,
    -- }
}}