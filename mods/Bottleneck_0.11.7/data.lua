--Quick to use empty sprite
local Prototype = {}
--Quick to use empty sprite
Prototype.empty_sprite ={
  filename = "__core__/graphics/empty.png",
  priority = "extra-high",
  width = 1,
  height = 1
}

--Quick to use empty animation
Prototype.empty_animation = {
  filename = Prototype.empty_sprite.filename,
  width = Prototype.empty_sprite.width,
  height = Prototype.empty_sprite.height,
  line_length = 1,
  frame_count = 1,
  shift = { 0, 0},
  animation_speed = 1,
  direction_count=1
}

--off, green, red, yellow, blue
local stoplight = {
  type = "simple-entity-with-force",
  name = "bottleneck-stoplight",
  flags = {"not-blueprintable", "not-deconstructable", "not-on-map", "placeable-off-grid"},
  filename = "__Bottleneck__/graphics/white.png",
  icon_size = 64,
  max_health = 100,
  selectable_in_game = false,
  mined_sound = nil,
  minable = nil,
  collision_box = nil,
  selection_box = nil,
  collision_mask = {},
  render_layer = "explosion",
  vehicle_impact_sound = nil,
  pictures = {
    {
      filename = "__Bottleneck__/graphics/off.png",
      priority = "extra-high",
      x = 0,
      y = 0,
      width = 64,
      height = 64,
      scale = 0.25,
    }
  }
}

local colors = {
  white = {r = 1, g = 1, b = 1, a = 0.8},
  blue = {r = 0, g = 0.7, b = 1, a = 0.8},
  red = {r = 1, g = 0.3, b = 0, a = 0.8},
  green = {r = 0, g = 0.8, b = 0, a = 0.8},
  yellow = {r = 1, g = 0.8, b = 0, a = 0.8}
}

local icons = {
  none = "__Bottleneck__/graphics/white-flat.png",
  alert = "__Bottleneck__/graphics/alert-flat.png",
  cross = "__Bottleneck__/graphics/cross-flat.png",
  minus = "__Bottleneck__/graphics/minus-flat.png",
  pause = "__Bottleneck__/graphics/pause-flat.png",
  stop = "__Bottleneck__/graphics/stop-flat.png",
  alert3D = "__Bottleneck__/graphics/alert.png",
  cross3D = "__Bottleneck__/graphics/cross.png",
  minus3D = "__Bottleneck__/graphics/minus.png",
  pause3D = "__Bottleneck__/graphics/pause.png",
  stop3D = "__Bottleneck__/graphics/stop.png"
}

for _, color_value in pairs(colors) do
  for _, icon_value in pairs(icons) do
    local picture = {
      priority = "extra-high",
      x = 0,
      y = 0,
      width = 64,
      height = 64,
      scale = 0.25,
    }
    picture.filename = icon_value
    picture.tint = color_value

    local picture_small = {
      priority = "extra-high",
      x = 0,
      y = 0,
      width = 64,
      height = 64,
      scale = 0.18,
    }
    picture_small.filename = icon_value
    picture_small.tint = color_value
    stoplight.pictures[#stoplight.pictures+1] = picture
    stoplight.pictures[#stoplight.pictures+1] = picture_small
  end
end
local key = {
  type = "custom-input",
  name = "bottleneck-hotkey",
  key_sequence = "SHIFT + ALT + L",
  consuming = "none",
}

data:extend({stoplight, key})
