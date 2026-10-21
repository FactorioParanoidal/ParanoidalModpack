-- 2.0 port: base fire-flame graphics are now 4 sheets x 90 frames
-- (see __base__/prototypes/fire-util.lua); the 13 single sheets of 1.1 are gone.
-- Keeps the 1.1 call contract: opts = {scale, shift, blend_mode, animation_speed, tint}.
local util = require("util")

local fire_util = {}

local flame_defs =
{
  {filename = "__base__/graphics/entity/fire-flame/fire-flame-01.png", width = 84, height = 130, shift = {0, -0.7}},
  {filename = "__base__/graphics/entity/fire-flame/fire-flame-02.png", width = 82, height = 106, shift = {0, -0.7}},
  {filename = "__base__/graphics/entity/fire-flame/fire-flame-03.png", width = 84, height = 124, shift = {0, -0.7}},
  {filename = "__base__/graphics/entity/fire-flame/fire-flame-04.png", width = 84, height = 94, shift = {0, -0.25}}
}

fire_util.create_fire_pictures = function(opts)
  local opts = opts or {}
  local fire_blend_mode = opts.blend_mode or "additive"
  local fire_animation_speed = opts.animation_speed or 0.5
  local fire_scale = opts.scale or 1
  local fire_tint = opts.tint or {r = 1, g = 1, b = 1, a = 1}
  local fire_shift = opts.shift

  local pictures = {}
  for k, def in pairs(flame_defs) do
    pictures[k] = util.draw_as_glow
    {
      filename = def.filename,
      line_length = 10,
      width = def.width,
      height = def.height,
      frame_count = 90,
      direction_count = 1,
      blend_mode = fire_blend_mode,
      animation_speed = fire_animation_speed,
      scale = fire_scale,
      tint = fire_tint,
      shift = fire_shift or {def.shift[1] * fire_scale, def.shift[2] * fire_scale}
    }
  end
  return pictures
end

return fire_util
