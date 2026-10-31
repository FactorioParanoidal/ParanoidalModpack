local graphics = "__PipeVisualizer-Updated-reforged__/graphics/"
local core_graphics = "__core__/graphics/fluid-visualization/"

local function shortcut(name)
  return {
    type = "shortcut",
    name = "pv-" .. name,
    order = "c[toggles]-p[pv-" .. name .. "]",
    icons = {
      { icon = graphics .. name:sub(8) .. "-dark-x32.png", icon_size = 32 },
      { icon = graphics .. name:sub(8) .. "-light-x32.png", icon_size = 32 },
    },
    small_icons = {
      { icon = graphics .. name:sub(8) .. "-dark-x24.png", icon_size = 24 },
      { icon = graphics .. name:sub(8) .. "-light-x24.png", icon_size = 24 },
    },
    associated_control_input = "pv-" .. name,
    action = "lua",
    toggleable = true,
  }
end

local function sprite(name, filename, size, extra)
  local proto = { type = "sprite", name = name, filename = filename, size = size, scale = 0.5, flags = { "icon" } }
  for k, v in pairs(extra or {}) do
    proto[k] = v
  end
  return proto
end

data:extend({
  { type = "custom-input", name = "pv-visualize-selected", key_sequence = "Y", action = "lua" },
  { type = "custom-input", name = "pv-toggle-overlay", key_sequence = "SHIFT + Y", action = "lua" },
  { type = "custom-input", name = "pv-toggle-mouseover", key_sequence = "ALT + Y", action = "lua" },
  { type = "custom-input", name = "pv-color-by-fluid-system", key_sequence = "CONTROL + SHIFT + Y", action = "lua" },
  shortcut("toggle-mouseover"),
  shortcut("toggle-overlay"),
  sprite("pv-entity-box", graphics .. "entity-box.png", 64),
  -- One black pixel stretched to one tile; the overlay scales it to its size in tiles.
  { type = "sprite", name = "pv-overlay-box", filename = graphics .. "black.png", size = 1, scale = 32 },
  -- Pixel-identical to the former fluid-arrow.png and fluid-arrow-input-output.png of the mod.
  sprite("pv-fluid-arrow", core_graphics .. "connection.png", 48),
  sprite("pv-fluid-arrow-input-output", core_graphics .. "connection-both-ways.png", 48),
  sprite("pv-fluid-arrow-output", graphics .. "fluid-arrow-output.png", 48),
  sprite("pv-fluid-arrow-input", graphics .. "fluid-arrow-input.png", 48),
})

for i = 0, 15 do
  data:extend({
    sprite("pv-pipe-connections-" .. i, graphics .. "pipe-connections.png", 64, { x = i * 64, draw_as_glow = true }),
    sprite("pv-pipe-connections-" .. i .. "-chart", graphics .. "pipe-connections-chart.png", 64, { x = i * 64 }),
  })
end
