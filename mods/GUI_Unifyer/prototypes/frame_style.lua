------------------
-- FRAME STYLES --
------------------

local snouz_invisible_frame =
{
  type = "frame_style",
  use_header_filler = false,
  padding = 0,
  margin = 0,
  graphical_set =
  {
    base =
    {
      position = {0, 0},
      corner_size = 1,
      center = {position = {42, 8},
      size = {1, 1}},
      draw_type = "outer",
      opacity = 0,
    },
  },
  header_flow_style =
  {
    type = "horizontal_flow_style",
    bottom_padding = 0
  },
  horizontal_flow_style =
  {
    type = "horizontal_flow_style",
    horizontal_spacing = 0
  },
}

data.raw["gui-style"].default["snouz_invisible_frame"] = snouz_invisible_frame

local snouz_barebone_frame =
{
  type = "frame_style",
  padding = 0,
  margin = 0,
  use_header_filler = false,
  header_flow_style =
  {
    type = "horizontal_flow_style",
    bottom_padding = 0
  },
  horizontal_flow_style =
  {
    type = "horizontal_flow_style",
    horizontal_spacing = 0
  },
}

data.raw["gui-style"].default["snouz_barebone_frame"] = snouz_barebone_frame

local snouz_large_barebone_frame =
{
  type = "frame_style",
  parent = "snouz_barebone_frame",
  padding = 3,
}

data.raw["gui-style"].default["snouz_large_barebone_frame"] = snouz_large_barebone_frame