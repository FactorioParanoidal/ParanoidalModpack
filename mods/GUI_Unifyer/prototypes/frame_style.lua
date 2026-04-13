-- Frame Styles Constants
local BASE_FRAME_GRAPHICS = {
  position = {0, 0},
  corner_size = 8,
  draw_type = "outer"
}

-- Function to define a frame style with optional attributes
local function define_frame_style(name, parent, padding, graphical_set)
  data.raw["gui-style"].default[name] = {
      type = "frame_style",
      parent = parent,
      padding = padding or 0,
      margin = 0,
      use_header_filler = false,
      graphical_set = graphical_set or {},
      header_flow_style = {
          type = "horizontal_flow_style",
          bottom_padding = 0
      },
      horizontal_flow_style = {
          type = "horizontal_flow_style",
          horizontal_spacing = 0
      }
  }
end

-- Frame Styles Definitions
define_frame_style("snouz_invisible_frame", nil, 0, {}) -- Fully invisible frame
define_frame_style("snouz_barebone_frame", nil, 0, {base = BASE_FRAME_GRAPHICS}) -- Barebones frame
define_frame_style("snouz_large_barebone_frame", "snouz_barebone_frame", 3, {base = BASE_FRAME_GRAPHICS}) -- Larger barebones frame
define_frame_style("mod_gui_frame", "frame", 0, {base = BASE_FRAME_GRAPHICS}) -- Quick bar frame replacement
