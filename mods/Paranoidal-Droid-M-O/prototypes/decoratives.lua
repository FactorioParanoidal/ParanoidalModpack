local shared = require("shared")
local tile_sounds = require("__base__.prototypes.tile.tile-sounds")

-- Muddy prints a character leaves on the paving after a walk on the ground, and mud splats off a vehicle's wheels.
-- Decals on top of the floor tiles; created only by the script (script/tracks.lua), so no autoplace.
local function pictures(name)
  local list = {}
  for i = 1, 4 do
    list[i] =
    {
      filename = shared.mod .. "/graphics/decorative/" .. name .. "-" .. i .. ".png",
      size = 64,
      scale = 0.5
    }
  end
  return list
end

local function decal(name, file, order)
  return
  {
    type = "optimized-decorative",
    name = name,
    order = "z[droid-m-o]-" .. order,
    collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
    collision_mask = {layers = {water_tile = true}, colliding_with_tiles_only = true},
    walking_sound = tile_sounds.walking.mud,
    render_layer = "decals",
    tile_layer = 255,
    decal_overdraw_priority = 400,
    pictures = pictures(file)
  }
end

data:extend
{
  decal(shared.footprints, "footprints", "a"),
  decal(shared.mud, "mud", "b")
}
