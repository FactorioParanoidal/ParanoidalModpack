local flib_bounding_box = require("__flib__.bounding-box")

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
  tiny = 0.075,
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

local function add_indicator(prototype, graphics_set)
  if not graphics_set then
    return
  end

  graphics_set.status_colors = status_colors

  local working_visualisations = graphics_set.working_visualisations
  if not working_visualisations then
    working_visualisations = {}
    graphics_set.working_visualisations = working_visualisations
  end

  local box = prototype.selection_box or prototype.collision_box
  if not box then
    return
  end
  box = flib_bounding_box.ensure_explicit(box)
  --- @type table<string, MapPosition>
  local positions = {
    north_south = {},
    east_west = {},
  }
  for _, pos in pairs(positions) do
    pos.x = box.left_top.x + (flib_bounding_box.width(box) * horizontal_position)
    pos.y = box.right_bottom.y - size - additional_vertical_offset
    box = flib_bounding_box.rotate(box)
  end

  working_visualisations[#working_visualisations + 1] = {
    always_draw = true,
    apply_tint = "status",
    render_layer = "light-effect",
    animation = {
      filename = "__BottleneckLite__/graphics/solid.png",
      flags = { "icon" },
      size = 64,
      scale = size,
      line_length = 1,
      frame_count = 1,
      animation_speed = 1,
      draw_as_glow = enable_glow,
    },
    north_position = positions.north_south,
    east_position = positions.east_west,
    south_position = positions.north_south,
    west_position = positions.east_west,
  }
end

for _, type in pairs({ "assembling-machine", "furnace", "rocket-silo" }) do
  for name, crafter in pairs(data.raw[type]) do
    if not ignored_entities[name] then
      if crafter.bottleneck_ignore then
        crafter.bottleneck_ignore = nil --- @diagnostic disable-line:inject-field
      else
        add_indicator(crafter, crafter.graphics_set)
        add_indicator(crafter, crafter.graphics_set_flipped)
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
      drill.bottleneck_ignore = nil --- @diagnostic disable-line:inject-field
    else
      add_indicator(drill, drill.graphics_set)
      add_indicator(drill, drill.wet_mining_graphics_set)
    end
  end
end
