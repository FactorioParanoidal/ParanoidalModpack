local wormUtils = {}

function wormUtils.wormFoldedAnimation(scale, tint, tint2)
  return
  {
    layers=
    {
      util.sprite_load("__base__/graphics/entity/worm/worm-folded",
        {
          frame_count = 9,
          direction_count = 1,
          scale = scale * 0.5,
          run_mode = "forward-then-backward",
          tint=tint,
          multiply_shift = scale,
          allow_forced_downscale = true,
          surface = "nauvis",
          usage = "enemy"
        }
      ),
      util.sprite_load("__base__/graphics/entity/worm/worm-folded-mask",
        {
          frame_count = 9,
          direction_count = 1,
          scale = scale * 0.5,
          run_mode = "forward-then-backward",
          tint=tint2,
          multiply_shift = scale,
          allow_forced_downscale = true,
          surface = "nauvis",
          usage = "enemy"
        }
      ),
      util.sprite_load("__base__/graphics/entity/worm/worm-folded-shadow",
        {
          frame_count = 9,
          direction_count = 1,
          scale = scale * 0.5,
          run_mode = "forward-then-backward",
          draw_as_shadow = true,
          multiply_shift = scale,
          allow_forced_downscale = true,
          surface = "nauvis",
          usage = "enemy"
        }
      )
    }
  }
end

function wormUtils.wormPreparingAnimation(scale, tint, run_mode, tint2)
  return
  {
    layers=
    {
      util.sprite_load("__base__/graphics/entity/worm/worm-preparing",
        {
          frame_count = 18,
          direction_count = 1,
          scale = scale * 0.5,
          run_mode = run_mode,
          tint=tint,
          multiply_shift = scale,
          allow_forced_downscale = true,
          surface = "nauvis",
          usage = "enemy"
        }
      ),
      util.sprite_load("__base__/graphics/entity/worm/worm-preparing-mask",
        {
          frame_count = 18,
          direction_count = 1,
          scale = scale * 0.5,
          run_mode = run_mode,
          flags = { "mask" },
          tint = tint2,
          multiply_shift = scale,
          allow_forced_downscale = true,
          surface = "nauvis",
          usage = "enemy"
        }
      ),
      util.sprite_load("__base__/graphics/entity/worm/worm-preparing-shadow",
        {
          frame_count = 18,
          direction_count = 1,
          scale = scale * 0.5,
          run_mode = run_mode,
          draw_as_shadow = true,
          multiply_shift = scale,
          allow_forced_downscale = true,
          surface = "nauvis",
          usage = "enemy"
        }
      )
    }
  }
end

function wormUtils.wormPreparedAnimation(scale, tint, tint2)
  return
  {
    layers=
    {
      util.sprite_load("__base__/graphics/entity/worm/worm-prepared",
        {
          frame_count = 9,
          direction_count = 1,
          scale = scale * 0.5,
          run_mode = "forward-then-backward",
          tint=tint,
          multiply_shift = scale,
          allow_forced_downscale = true,
          surface = "nauvis",
          usage = "enemy"
        }
      ),
      util.sprite_load("__base__/graphics/entity/worm/worm-prepared-mask",
        {
          frame_count = 9,
          direction_count = 1,
          scale = scale * 0.5,
          run_mode = "forward-then-backward",
          tint = tint2,
          multiply_shift = scale,
          allow_forced_downscale = true,
          surface = "nauvis",
          usage = "enemy"
        }
      ),
      util.sprite_load("__base__/graphics/entity/worm/worm-prepared-shadow",
        {
          frame_count = 9,
          direction_count = 1,
          scale = scale * 0.5,
          run_mode = "forward-then-backward",
          draw_as_shadow = true,
          multiply_shift = scale,
          allow_forced_downscale = true,
          surface = "nauvis",
          usage = "enemy"
        }
      )
    }
  }
end


function wormUtils.wormPreparedAlternativeAnimation(scale, tint, tint2)
  return
  {
    layers=
    {
      util.sprite_load("__base__/graphics/entity/worm/worm-prepared-alternative",
        {
          direction_count = 1,
          scale = scale * 0.5,
          frame_count = 17,
          frame_sequence = alternate_frame_sequence,
          tint=tint,
          multiply_shift = scale,
          allow_forced_downscale = true,
          surface = "nauvis",
          usage = "enemy"
        }
      ),
      util.sprite_load("__base__/graphics/entity/worm/worm-prepared-alternative-mask",
        {
          direction_count = 1,
          scale = scale * 0.5,
          frame_sequence = alternate_frame_sequence,
          frame_count = 17,
          flags = { "mask" },
          tint = tint2,
          multiply_shift = scale,
          allow_forced_downscale = true,
          surface = "nauvis",
          usage = "enemy"
        }
      ),
      util.sprite_load("__base__/graphics/entity/worm/worm-prepared-alternative-shadow",
        {
          direction_count = 1,
          scale = scale * 0.5,
          frame_sequence = alternate_frame_sequence,
          frame_count = 17,
          draw_as_shadow = true,
          multiply_shift = scale,
          allow_forced_downscale = true,
          surface = "nauvis",
          usage = "enemy"
        }
      )
    }
  }
end


function wormUtils.wormStartAttackAnimation(scale, tint, tint2)
  return
  {
    layers=
    {
      util.sprite_load("__base__/graphics/entity/worm/worm-attack",
        {
          slice = 4,
          frame_count = 10,
          direction_count = 16,
          scale = scale * 0.5,
          frame_sequence = start_attack_frame_sequence,
          tint=tint,
          multiply_shift = scale,
          allow_forced_downscale = true,
          surface = "nauvis",
          usage = "enemy"
        }
      ),
      util.sprite_load("__base__/graphics/entity/worm/worm-attack-mask",
        {
          slice = 4,
          frame_count = 10,
          direction_count = 16,
          scale = scale * 0.5,
          frame_sequence = start_attack_frame_sequence,
          tint = tint2,
          multiply_shift = scale,
          allow_forced_downscale = true,
          surface = "nauvis",
          usage = "enemy"
        }
      ),
      util.sprite_load("__base__/graphics/entity/worm/worm-attack-shadow",
        {
          slice = 4,
          frame_count = 10,
          direction_count = 16,
          scale = scale * 0.5,
          frame_sequence = start_attack_frame_sequence,
          draw_as_shadow = true,
          multiply_shift = scale,
          allow_forced_downscale = true,
          surface = "nauvis",
          usage = "enemy"
        }
      )
    }
  }
		
end

function wormUtils.wormEndAttackAnimation(scale, tint, tint2)
  return
  {
    layers=
    {
      util.sprite_load("__base__/graphics/entity/worm/worm-attack",
        {
          slice = 4,
          frame_count = 10,
          direction_count = 16,
          scale = scale * 0.5,
          frame_sequence = end_attack_frame_sequence,
          tint=tint,
          multiply_shift = scale,
          allow_forced_downscale = true,
          surface = "nauvis",
          usage = "enemy"
        }
      ),
      util.sprite_load("__base__/graphics/entity/worm/worm-attack-mask",
        {
          slice = 4,
          frame_count = 10,
          direction_count = 16,
          scale = scale * 0.5,
          frame_sequence = end_attack_frame_sequence,
          tint = tint2,
          multiply_shift = scale,
          allow_forced_downscale = true,
          surface = "nauvis",
          usage = "enemy"
        }
      ),
      util.sprite_load("__base__/graphics/entity/worm/worm-attack-shadow",
        {
          slice = 4,
          frame_count = 10,
          direction_count = 16,
          scale = scale * 0.5,
          frame_sequence = end_attack_frame_sequence,
          draw_as_shadow = true,
          multiply_shift = scale,
          allow_forced_downscale = true,
          surface = "nauvis",
          usage = "enemy"
        }
      )
    }
  }
end


local function dead_worm_animation (path, scale, tint, frame_count, usage, tint2)
  return
  {
    util.sprite_load( path ,
      {
        frame_count = frame_count,
        direction_count = 1,
        scale = scale * 0.5,
        tint=tint,
        multiply_shift = scale,
        flags = {"corpse-decay"},
        allow_forced_downscale = true,
        surface = "nauvis",
        usage = usage or "enemy"
      }
    ),
    util.sprite_load( path .. "-mask",
      {
        frame_count = frame_count,
        direction_count = 1,
        scale = scale * 0.5,
        tint = tint2,
        multiply_shift = scale,
        flags = {"corpse-decay"},
        allow_forced_downscale = true,
        surface = "nauvis",
        usage = usage or "enemy"
      }
    ),
    util.sprite_load( path .. "-shadow",
      {
        frame_count = frame_count,
        direction_count = 1,
        scale = scale * 0.5,
        draw_as_shadow = true,
        multiply_shift = scale,
        allow_forced_downscale = true,
        surface = "nauvis",
        usage = usage or "enemy"
      }
    ),
  }
end

function wormUtils.wormDieAnimation(scale, tint, tint2)
  return
  {
    {
      layers = dead_worm_animation("__base__/graphics/entity/worm/worm-die-01", scale, tint, 24, "enemy", tint2)
    },
    {
      layers = dead_worm_animation("__base__/graphics/entity/worm/worm-die-02", scale, tint, 24, "enemy", tint2)
    },
    {
      layers = dead_worm_animation("__base__/graphics/entity/worm/worm-die-03", scale, tint, 24, "enemy", tint2)
    }
  }
end


return wormUtils
