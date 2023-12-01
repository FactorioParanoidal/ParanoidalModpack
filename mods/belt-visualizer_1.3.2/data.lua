data:extend{{
    type = "custom-input",
    name = "bv-highlight-belt",
    key_sequence = "SHIFT + H",
    action = "lua",
    order = "b",
},{
    type = "custom-input",
    name = "bv-highlight-ghost",
    key_sequence = "H",
    action = "lua",
    order = "a",
},{
    type = "custom-input",
    name = "bv-toggle-hover",
    key_sequence = "",
    action = "lua",
    order = "c",
},{
    type = "shortcut",
    name = "bv-toggle-hover",
    action = "lua",
    localised_name = {"shortcut.bv-toggle-hover"},
    associated_control_input = "bv-toggle-hover",
    toggleable = true,
    icon = {
        filename = "__belt-visualizer__/graphics/toggle-hover-x32.png",
        priority = "extra-high-no-scale",
        size = 32,
        scale = 0.5,
        mipmap_count = 1,
        flags = {"gui-icon"},
    },
    small_icon =
    {
      filename = "__belt-visualizer__/graphics/toggle-hover-x24.png",
      priority = "extra-high-no-scale",
      size = 24,
      scale = 0.5,
      mipmap_count = 1,
      flags = {"gui-icon"}
    },
    disabled_small_icon =
    {
      filename = "__belt-visualizer__/graphics/toggle-hover-x24-white.png",
      priority = "extra-high-no-scale",
      size = 24,
      scale = 0.5,
      mipmap_count = 1,
      flags = {"gui-icon"}
    }
}}
