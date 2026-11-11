local path = "__mferrari_lib__/"

function flying_saucer_animation()
-- Half-resolution frames; odd source dimensions were padded right/bottom before filtering.
-- The 0.25-pixel shifts keep the original frame origins at the doubled scale.
local anim =  {
    layers =
    {

      {
          filename = path .. "graphics/entity/flying_saucer/light-spritesheet.png",
          line_length = 5,
          width = 364,
          height = 311,
          frame_count = 20,
          animation_speed = 0.12, --18
          direction_count = 1,
          run_mode = "forward",
         -- shift = util.by_pixel(0, 0),
        --  y = variation * 354 * 2,
          scale = 1
      },

      {
          filename = path .. "graphics/entity/flying_saucer/spritesheet.png",
          line_length = 5,
          width = 346,
          height = 225,
          frame_count = 20,
          animation_speed = 0.12, --18
          direction_count = 1,
          run_mode = "forward",
          shift = util.by_pixel(0.25, -179.75),
        --  y = variation * 354 * 2,
          scale = 1
      },

      {
        filename = path .. "graphics/entity/flying_saucer/mask.png",
        flags = { "mask" },
          line_length = 5,
          width = 346,
          height = 225,
          frame_count = 20,
          animation_speed = 0.12,
          run_mode = "forward",
		  direction_count = 1,
          shift = util.by_pixel(0.25, -179.75),
          scale = 1,
		  apply_runtime_tint = true,
		  tint = {r=5,g=210,b=255, a=1}, --{r=20,g=183,b=255, a=0.8},
		  --tint = {r=153,g=237,b=231},
	 	--draw_as_glow = true, blend_mode = "additive",
      },

	{

          filename = path .. "graphics/entity/flying_saucer/shadow.png",
          draw_as_shadow = true,
          width = 369,
          height = 207,
		  direction_count = 1,
		  shift = util.by_pixel(200.25, 0),
		  line_length = 4, 
          frame_count = 20,
		  --repeat_count=60,
          animation_speed = 0.12,
          run_mode = "forward",
          --shift = util.by_pixel(36, 10),
          --line_length = 4,
          --y = variation * 406 * 2,
          scale = 1

      }
    }
  }
 return anim
end
