local bounding_box = require("__flib__.bounding-box")

if not settings.startup["bnl-enable"].value then
  return
end

local additional_vertical_offset = 0.1

local horizontal_position = 0.3

local ignored_entities = {
  -- Mining Drones
  ["mining-depot"] = true,
  -- Space Exploration
  ["se-core-miner"] = true,
  ["se-rocket-launch-pad-silo"] = true,
  -- Transport Drones
  ["buffer-depot"] = true,
  ["fluid-depot"] = true,
  ["fuel-depot"] = true,
  ["request-depot"] = true,
  ["supply-depot"] = true,
}

local sizes = {
  small = 0.15,
  medium = 0.2,
  large = 0.25,
  huge = 0.5,
}

--- @type table<string, Color>
local status_colors = {}
for name, spec in pairs(settings.startup) do
  local key = string.match(name, "^bnl%-color%-(.-)$")
  if key then
    status_colors[key] = util.premul_color(spec.value --[[@as Color]])
  end
end

local enable_glow = settings.startup["bnl-glow"].value --[[@as boolean]]
local size = sizes[settings.startup["bnl-indicator-size"].value] --[[@as double]]

local function build_indicator(prototype)
  local box = bounding_box.ensure_explicit(prototype.selection_box or prototype.collision_box or prototype.drawing_box)
  --- @type table<string, MapPosition>
  local positions = {
    north_south = {},
    east_west = {},
  }
  for _, pos in pairs(positions) do
    pos.x = box.left_top.x + (bounding_box.width(box) * horizontal_position)
    pos.y = box.right_bottom.y - size - additional_vertical_offset
    box = bounding_box.rotate(box)
  end

  return {
    always_draw = true,
    apply_tint = "status",
    draw_as_light = enable_glow,
    draw_as_sprite = true,
    render_layer = "light-effect",
    animation = {
      filename = "__BottleneckLite__/graphics/solid.png",
      flags = { "icon" },
      size = 64,
      scale = size,
      line_length = 1,
      frame_count = 1,
      animation_speed = 1,
      direction_count = 1,
    },
    north_position = positions.north_south,
    east_position = positions.east_west,
    south_position = positions.north_south,
    west_position = positions.east_west,
  }
end

local function add_to_wv(prototype, wv_root)
  wv_root = wv_root or prototype

  wv_root.status_colors = status_colors

  local wv = wv_root.working_visualisations
  if not wv then
    wv = {}
    wv_root.working_visualisations = wv
  end

  wv[#wv + 1] = build_indicator(prototype)
end

for _, type in pairs({ "assembling-machine", "furnace", "rocket-silo" }) do
  for name, crafter in pairs(data.raw[type]) do
    if not ignored_entities[name] then
      if crafter.bottleneck_ignore then
        crafter.bottleneck_ignore = nil
      else
        add_to_wv(crafter)
      end
    end
  end
end

if not settings.startup["bnl-include-mining-drills"].value then
  return
end

for name, drill in pairs(data.raw["mining-drill"]) do
  if not ignored_entities[name] then
    if drill.bottleneck_ignore then
      drill.bottleneck_ignore = nil
    else
      drill.status_colors = status_colors

      if not drill.graphics_set then
        drill.graphics_set = {
          animation = drill.animations,
        }
      end

      add_to_wv(drill, drill.graphics_set)

      if drill.wet_mining_graphics_set then
        add_to_wv(drill, drill.wet_mining_graphics_set)
      end
    end
  end
end
