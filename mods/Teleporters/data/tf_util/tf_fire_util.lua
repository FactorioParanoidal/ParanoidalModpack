--Copy paste from base game
local fire_util = {}
local path = util.path("data/entities/teleporters/")

fire_util.create_fire_pictures = function(opts)
  local opts = opts or {}
  local fire_blend_mode = opts.blend_mode or "additive"
  local fire_animation_speed = opts.animation_speed or 0.5
  local fire_scale =  opts.scale or 1
  local fire_tint = opts.tint or {r=1,g=1,b=1,a=1}
  local fire_flags = opts.flags or { "compressed" }
  return 
  {
    {
      filename = path.."teleporter-explosion.png",
      draw_as_glow = true,
      priority = "high",
      line_length = 6,
      width = 44,
      height = 90,
      frame_count = 24,
      shift = util.by_pixel(-1,6),
      blend_mode = fire_blend_mode,
      animation_speed = fire_animation_speed,
      scale = fire_scale,
      tint = fire_tint,
      flags = fire_flags,
      hr_version =
      {
        filename = path.."hr-teleporter-explosion.png",
        draw_as_glow = true,
        priority = "high",
        line_length = 6,
        width = 88,
        height = 178,
        frame_count = 24,
        shift = util.by_pixel(-1,6),
        blend_mode = fire_blend_mode,
        animation_speed = fire_animation_speed,
        scale = fire_scale / 2,
        tint = fire_tint,
        flags = fire_flags,
      }
    },
  }
end

return fire_util