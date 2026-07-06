data:extend({
  {
    type = "custom-input",
    name = "pv-visualize-selected",
    key_sequence = "Y",
    action = "lua",
  },
  {
    type = "custom-input",
    name = "pv-toggle-overlay",
    key_sequence = "SHIFT + Y",
    action = "lua",
  },
  {
    type = "custom-input",
    name = "pv-toggle-mouseover",
    key_sequence = "ALT + Y",
    action = "lua",
  },
  {
    type = "custom-input",
    name = "pv-color-by-fluid-system",
    key_sequence = "CONTROL + SHIFT + Y",
    action = "lua",
  },
  {
    type = "shortcut",
    name = "pv-toggle-mouseover",
    order = "c[toggles]-p[pv-toggle-mouseover]",
    icons = {
      {
        icon = "__PipeVisualizer-Updated__/graphics/mouseover-dark-x32.png",
        icon_size = 32
      },
      {
        icon = "__PipeVisualizer-Updated__/graphics/mouseover-light-x32.png",
        icon_size = 32
      }
    },
    small_icons = {
      {
        icon = "__PipeVisualizer-Updated__/graphics/mouseover-dark-x24.png",
        icon_size = 24
      },
      {
        icon = "__PipeVisualizer-Updated__/graphics/mouseover-light-x24.png",
        icon_size = 24,
      }
    },
    associated_control_input = "pv-toggle-mouseover",
    action = "lua",
    toggleable = true,
  },
  {
    type = "shortcut",
    name = "pv-toggle-overlay",
    order = "c[toggles]-p[pv-toggle-overlay]",
    icons = {
      {
        icon = "__PipeVisualizer-Updated__/graphics/overlay-dark-x32.png",
        icon_size = 32
      },
      {
        icon = "__PipeVisualizer-Updated__/graphics/overlay-light-x32.png",
        icon_size = 32
      }
    },
    small_icons = {
      {
        icon = "__PipeVisualizer-Updated__/graphics/overlay-dark-x24.png",
        icon_size = 24
      },
      {
        icon = "__PipeVisualizer-Updated__/graphics/overlay-light-x24.png",
        icon_size = 24,
      }
    },
    associated_control_input = "pv-toggle-overlay",
    action = "lua",
    toggleable = true,
  },
  {
    type = "sprite",
    name = "pv-entity-box",
    filename = "__PipeVisualizer-Updated__/graphics/entity-box.png",
    size = 64,
    scale = 0.5,
    flags = { "icon" },
    --draw_as_glow = true,
  },
  {
    type = "sprite",
    name = "pv-overlay-box",
    filename = "__flib__/graphics/black.png",
    size = 1,
    scale = 32,
    --draw_as_glow = true,
  },
  {
    type = "sprite",
    name = "pv-underground-connection",
    filename = "__PipeVisualizer-Updated__/graphics/underground-connection.png",
    size = 64,
    scale = 0.5,
    flags = { "icon" },
    --draw_as_glow = true,
  },
  {
    type = "sprite",
    name = "pv-fluid-arrow",
    filename = "__PipeVisualizer-Updated__/graphics/fluid-arrow.png",
    size = 48,
    scale = 0.5,
    flags = { "icon" },
    --draw_as_glow = true,
  },
  {
    type = "sprite",
    name = "pv-fluid-arrow-output",
    filename = "__PipeVisualizer-Updated__/graphics/fluid-arrow-output.png",
    size = 48,
    scale = 0.5,
    flags = { "icon" },
    --draw_as_glow = true,
  },
  {
    type = "sprite",
    name = "pv-fluid-arrow-input",
    filename = "__PipeVisualizer-Updated__/graphics/fluid-arrow-input.png",
    size = 48,
    scale = 0.5,
    flags = { "icon" },
    --draw_as_glow = true,
  },
  {
    type = "sprite",
    name = "pv-fluid-arrow-input-output",
    filename = "__PipeVisualizer-Updated__/graphics/fluid-arrow-input-output.png",
    size = 48,
    scale = 0.5,
    flags = { "icon" },
    --draw_as_glow = true,
  },
})

for i = 0, 15 do
  data:extend({
    {
      type = "sprite",
      name = "pv-pipe-connections-" .. i,
      filename = "__PipeVisualizer-Updated__/graphics/pipe-connections.png",
      x = i * 64,
      size = 64,
      scale = 0.5,
      flags = { "icon" },
      draw_as_glow = true,
    },
  })
end

for i = 0, 15 do
  data:extend({
    {
      type = "sprite",
      name = "pv-pipe-connections-" .. i .. "-chart",
      filename = "__PipeVisualizer-Updated__/graphics/pipe-connections-chart.png",
      x = i * 64,
      size = 64,
      scale = 0.5,
      flags = { "icon" },
      --draw_as_glow = true,
    },
  })
end