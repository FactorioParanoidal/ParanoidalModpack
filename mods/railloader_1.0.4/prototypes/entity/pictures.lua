local M = {}

local function flatten(ts)
  local out = {}
  for _, t in ipairs(ts) do
    for _, elem in ipairs(t) do
      out[#out+1] = elem
    end
  end
  return out
end

local all_base_rail_pictures = rail_pictures()

local function triple_rail_pictures(direction, layers)
  local out = {}
  for _, layer in ipairs(layers) do
    local l = all_base_rail_pictures["straight_rail_" .. direction][layer]
    for i=-1,1 do
      local shift = { i * 2, 0 }
      if direction == "vertical" then
        shift = { 0, i * 2 }
      end

      out[#out+1] = {
        filename = l.filename,
        width = l.width,
        height = l.height,
        frame_count = 1,
        shift = shift,
        hr_version = {
          filename = l.hr_version.filename,
          width = l.hr_version.width,
          height = l.hr_version.height,
          frame_count = 1,
          shift = shift,
          scale = 0.5,
        }
      }
    end
  end
  return out
end

local all_layers = {"stone_path_background", "stone_path", "ties", "backplates", "metals"}
local rail_only_layers = {"backplates", "metals"}

local wheels_layer = data.raw["cargo-wagon"]["cargo-wagon"].wheels
local wagon_layer = data.raw["cargo-wagon"]["cargo-wagon"].pictures.layers[1]
local cargo_wagon_layers = {
  horizontal = {
    -- left wheel
    {
      filename = wheels_layer.filenames[1],
      width = wheels_layer.width,
      height = wheels_layer.height,
      y = wheels_layer.height * 8,
      frame_count = 1,
      shift = {-2, -0.25},
      hr_version = {
        filename = wheels_layer.hr_version.filenames[3],
        width = wheels_layer.hr_version.width,
        height = wheels_layer.hr_version.height,
        frame_count = 1,
        shift = {-2, -0.25},
        scale = 0.5,
      },
    },
    -- right wheel
    {
      filename = wheels_layer.filenames[2],
      width = wheels_layer.width,
      height = wheels_layer.height,
      y = wheels_layer.height * 8,
      frame_count = 1,
      shift = {2, -0.25},
      hr_version = {
        filename = wheels_layer.hr_version.filenames[7],
        width = wheels_layer.hr_version.width,
        height = wheels_layer.hr_version.height,
        frame_count = 1,
        shift = {2, -0.25},
        scale = 0.5,
      },
    },
    -- wagon body
    {
      filename = wagon_layer.filenames[3],
      width = wagon_layer.width,
      height = wagon_layer.height,
      frame_count = 1,
      shift = wagon_layer.shift,
      hr_version = {
        filename = wagon_layer.hr_version.filenames[3],
        height = wagon_layer.hr_version.height,
        width = wagon_layer.hr_version.width,
        frame_count = 1,
        shift = wagon_layer.shift,
        scale = 0.5,
      }
    },
  },
  vertical = {
    {
      filename = wheels_layer.filenames[1],
      width = wheels_layer.width,
      height = wheels_layer.height,
      y = 0,
      frame_count = 1,
      shift = {0, 2.5},
      hr_version = {
        filename = wheels_layer.hr_version.filenames[1],
        width = wheels_layer.hr_version.width,
        height = wheels_layer.hr_version.height,
        frame_count = 1,
        shift = {0, 2.5},
        scale = 0.5,
      },
    },
    {
      filename = wagon_layer.filenames[1],
      width = wagon_layer.width,
      height = wagon_layer.height,
      frame_count = 1,
      shift = {0, 0},
      hr_version = {
        filename = wagon_layer.hr_version.filenames[1],
        height = wagon_layer.hr_version.height,
        width = wagon_layer.hr_version.width,
        frame_count = 1,
        shift = {0, 0},
        scale = 0.5,
      }
    }
  },
}

M.railloader_structure_horizontal = {
  filename = "__railloader__/graphics/railloader/structure-horizontal.png",
  priority = "extra-high",
  width = 188,
  height = 210,
  frame_count = 1,
}

M.railloader_structure_vertical = {
  filename = "__railloader__/graphics/railloader/structure-vertical.png",
  priority = "extra-high",
  width = 188,
  height = 210,
  frame_count = 1,
}

local railloader_horizontal = {
  layers = flatten{
    triple_rail_pictures("horizontal", all_layers),
    cargo_wagon_layers.horizontal,
    { M.railloader_structure_horizontal },
  }
}

local railloader_vertical = {
  layers = flatten{
    triple_rail_pictures("vertical", all_layers),
    cargo_wagon_layers.vertical,
    { M.railloader_structure_vertical },
  }
}

M.railloader_proxy_animations = {
  north = railloader_vertical,
  east = railloader_horizontal,
  south = railloader_vertical,
  west = railloader_horizontal,
}

M.railunloader_horizontal = {
  layers = flatten{
    {
      {
        filename = "__railloader__/graphics/railunloader/structure-horizontal.png",
        width = 384,
        height = 256,
        frame_count = 1,
        scale = 0.5,
      }
    },
    triple_rail_pictures("horizontal", rail_only_layers),
  }
}

M.railunloader_vertical = {
  layers = flatten{
    {
      {
        filename = "__railloader__/graphics/railunloader/structure-vertical.png",
        width = 256,
        height = 384,
        frame_count = 1,
        scale = 0.5,
      }
    },
    triple_rail_pictures("vertical", rail_only_layers),
  }
}

local railunloader_proxy_horizontal = {
  layers = flatten{
    M.railunloader_horizontal.layers,
    cargo_wagon_layers.horizontal,
  }
}

local railunloader_proxy_vertical = {
  layers = flatten{
    M.railunloader_vertical.layers,
    cargo_wagon_layers.vertical,
  }
}

M.railunloader_proxy_animations = {
  north = railunloader_proxy_vertical,
  east = railunloader_proxy_horizontal,
  south = railunloader_proxy_vertical,
  west = railunloader_proxy_horizontal,
}

M.empty_sheet = {
  filename = "__core__/graphics/add-icon.png",
  priority = "very-low",
  width = 1,
  height = 1,
}

M.empty_animation = {
  filename = "__core__/graphics/add-icon.png",
  priority = "very-low",
  width = 1,
  height = 1,
  frame_count = 0,
}

return M