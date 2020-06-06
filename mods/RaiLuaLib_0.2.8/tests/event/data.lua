data:extend{
  {
    type = "custom-input",
    name = "demo-input",
    key_sequence = "SHIFT + mouse-wheel-up"
  },
  {
    type = "shortcut",
    name = "toggle-fire-at-feet",
    icon = {
      filename = "__core__/graphics/icons/tooltips/tooltip-category-heat.png",
      priority = "extra-high-no-scale",
      size = 40,
      scale = 1,
      mipmap_count = 2,
      flags = {"icon"}
    },
    action = "lua",
    toggleable = true,
    localised_name = "Toggle Fire at Feet"
  }
}