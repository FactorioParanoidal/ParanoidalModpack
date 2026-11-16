
local unitSpawnerUtils = {}

-- Paranoidal: the shifts in the vanilla sprite data are made for scale 0.5; a nest of size `scale` multiplies them
-- too (multiply_shift), so every layer keeps its place on the body, alive and dying
function unitSpawnerUtils.spawner_idle_animation(variation, tint, scale, tint2)
return
  {
    layers =
    {
      util.sprite_load("__base__/graphics/entity/spawner/spawner-idle",
        {
          frame_count = 7,
          scale = 0.5 * scale,
          multiply_shift = scale,
          animation_speed = 0.18,
          run_mode = "forward-then-backward",
		  -- shift = util.by_pixel(2, -4),
          tint = tint,
          y = variation * 376 * 2,
          allow_forced_downscale = true,
          surface = "nauvis",
          usage = "enemy"
        }
      ),
      util.sprite_load("__base__/graphics/entity/spawner/spawner-idle-mask",
        {
          frame_count = 7,
          scale = 0.5 * scale,
          multiply_shift = scale,
          animation_speed = 0.18,
          run_mode = "forward-then-backward",
		  -- shift = util.by_pixel(-1.5 + (-0.5 * scale * 0.5), -11 + (-3 * scale * 0.5)),
          tint = tint2,
          flags = { "mask" },
          y = variation * 230 * 2,
          allow_forced_downscale = true,
          surface = "nauvis",
          usage = "enemy"
        }
      )
	}
   }	
end

function unitSpawnerUtils.spawner_die_animation(variation, tint, scale, tint2)
	return
	  {
		layers =
		{
		  util.sprite_load("__base__/graphics/entity/spawner/spawner-death-v" .. tostring(variation+1),
			{
			  frame_count = 18,
			  direction_count = 1,
			  scale = 0.5 * scale,
			  multiply_shift = scale,
			  tint = tint,
			  flags = {"corpse-decay"},
			  allow_forced_downscale = true,
			  surface = "nauvis",
			  usage = "enemy"
			}
		  ),
		  util.sprite_load("__base__/graphics/entity/spawner/spawner-death-mask-v" .. tostring(variation+1),
			{
			  frame_count = 18,
			  direction_count = 1,
			  scale = 0.5 * scale,
			  multiply_shift = scale,
			  tint = tint2,
			  flags = {"corpse-decay"},
			  allow_forced_downscale = true,
			  surface = "nauvis",
			  usage = "enemy"

			}
		  ),
		  util.sprite_load("__base__/graphics/entity/spawner/spawner-death-shadow-v" .. tostring(variation+1),
			{
			  draw_as_shadow = true,
			  frame_count = 18,
			  direction_count = 1,
			  scale = 0.5 * scale,
			  multiply_shift = scale,
			  allow_forced_downscale = true,
			  surface = "nauvis",
			  usage = "enemy"
			}
		  ),
		}
	  }
end

return unitSpawnerUtils
