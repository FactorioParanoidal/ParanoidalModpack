local area = require("__flib__.area")

local constants = require("constants")

if not settings.startup["bnl-enable"].value then return end

-- Extract settings
local status_colors = {}
for name, spec in pairs(settings.startup) do
  local matched, _, key = string.find(name, "^bnl%-color%-(.-)$")
  if matched then
    status_colors[key] = constants.colors[spec.value]
  end
end

local enable_glow = settings.startup["bnl-glow"].value
local size = constants.sizes[settings.startup["bnl-indicator-size"].value]

local function build_indicator(prototype)
  -- Calculate shift for the indicator
  local selection_box = prototype.selection_box or prototype.collision_box or prototype.drawing_box
  -- TODO: Add a flib function for converting from a keyless representation
  local Box = area.load{
    left_top = {x = selection_box[1][1], y = selection_box[1][2]},
    right_bottom = {x = selection_box[2][1], y = selection_box[2][2]}
  }
  local positions = {
    north_south = {},
    east_west = {},
  }
  for _, tbl in pairs(positions) do
    tbl[1] = Box.left_top.x + (Box:width() * constants.horizontal_position) -- X
    tbl[2] = Box.right_bottom.y - size - constants.additional_vertical_offset -- Y
    Box = Box:rotate()
  end

  return {
    always_draw = true,
    apply_tint = "status",
    draw_as_light = enable_glow,
    draw_as_sprite = true,
    render_layer = "light-effect",
    animation = {
      filename = "__BottleneckLite__/graphics/solid.png",
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

  -- Set status colors
  wv_root.status_colors = status_colors

  -- Get or create working visualisations table
  local wv = wv_root.working_visualisations
  if not wv then
    wv = {}
    wv_root.working_visualisations = wv
  end

  -- Add indicator to working visualisations
  wv[#wv + 1] = build_indicator(prototype)
end

for _, type in pairs{"assembling-machine", "furnace", "rocket-silo"} do
  for name, crafter in pairs(data.raw[type]) do
    if constants.ignored_entities[name] then goto continue end
    if crafter.bottleneck_ignore then
      -- Remove the property to avoid pollution with some debugging features
      crafter.bottleneck_ignore = nil
      goto continue
    end

    add_to_wv(crafter)

    ::continue::
  end
end

if settings.startup["bnl-include-mining-drills"].value then
  for name, drill in pairs(data.raw["mining-drill"]) do
    if constants.ignored_entities[name] then goto continue end
    if drill.bottleneck_ignore then
      -- Remove the property to avoid pollution with some debugging features
      drill.bottleneck_ignore = nil
      goto continue
    end

    drill.status_colors = status_colors

    -- Ensure the drill has a graphics set
    if not drill.graphics_set then
      drill.graphics_set = {
        animation = drill.animations
      }
    end

    add_to_wv(drill, drill.graphics_set)

    if drill.wet_mining_graphics_set then
      add_to_wv(drill, drill.wet_mining_graphics_set)
    end

    ::continue::
  end
end
