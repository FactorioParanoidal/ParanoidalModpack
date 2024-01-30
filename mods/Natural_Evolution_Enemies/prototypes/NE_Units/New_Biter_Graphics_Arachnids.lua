require ("util")

local ENTITYPATH = NE_Common.alt_graphicspath .. "arachnids/"

function arachnids_runanimation(scale, tint2, tint1)
  return
  {
    layers=
    {
      {
        filenames =
        {
          ENTITYPATH .. "Arachnids-run-01.png",
          ENTITYPATH .. "Arachnids-run-02.png",
          ENTITYPATH .. "Arachnids-run-03.png",
          ENTITYPATH .. "Arachnids-run-04.png"
        },
        slice = 8,
        lines_per_file = 8,
        line_length = 8,
        width = 199,
        height = 175,
        frame_count = 16,
        direction_count = 16,
        --shift = util.mul_shift(util.by_pixel(-2, -6), scale),
        scale = scale,
        hr_version =
        {
          filenames =
          {
            ENTITYPATH .. "hr-Arachnids-run-01.png",
            ENTITYPATH .. "hr-Arachnids-run-02.png",
            ENTITYPATH .. "hr-Arachnids-run-03.png",
            ENTITYPATH .. "hr-Arachnids-run-04.png"
          },
          slice = 8,
          lines_per_file = 8,
          line_length = 8,
          width = 398,
          height = 350,
          frame_count = 16,
          --shift = util.mul_shift(util.by_pixel(-1, -5), scale),
          direction_count = 16,
          scale = 0.5 * scale
        }
      },
      {
        filenames =
        {
          ENTITYPATH .. "Arachnids-run-mask1-01.png",
          ENTITYPATH .. "Arachnids-run-mask1-02.png",
          ENTITYPATH .. "Arachnids-run-mask1-03.png",
          ENTITYPATH .. "Arachnids-run-mask1-04.png"
        },
        slice = 8,
        lines_per_file = 8,
        flags = { "mask" },
        line_length = 8,
        width = 199,
        height = 175,
        frame_count = 16,
        direction_count = 16,
        --shift = util.mul_shift(util.by_pixel(-2, -6), scale),
        scale = scale,
        tint = tint1,
        hr_version =
        {
          filenames =
          {
            ENTITYPATH .. "hr-Arachnids-run-mask1-01.png",
            ENTITYPATH .. "hr-Arachnids-run-mask1-02.png",
            ENTITYPATH .. "hr-Arachnids-run-mask1-03.png",
            ENTITYPATH .. "hr-Arachnids-run-mask1-04.png"
          },
          slice = 8,
          lines_per_file = 8,
          line_length = 8,
          width = 398,
          height = 350,
          frame_count = 16,
          --shift = util.mul_shift(util.by_pixel(-1, -37), scale),
          direction_count = 16,
          scale = 0.5 * scale,
          tint = tint1
        }
      },
      {
        filenames =
        {
          ENTITYPATH .. "Arachnids-run-mask2-01.png",
          ENTITYPATH .. "Arachnids-run-mask2-02.png",
          ENTITYPATH .. "Arachnids-run-mask2-03.png",
          ENTITYPATH .. "Arachnids-run-mask2-04.png"
        },
        slice = 8,
        lines_per_file = 8,
        flags = { "mask" },
        line_length = 8,
        width = 199,
        height = 175,
        frame_count = 16,
        direction_count = 16,
        --shift = util.mul_shift(util.by_pixel(-2, -6), scale),
        scale = scale,
        tint = tint2,
        hr_version =
        {
          filenames =
          {
            ENTITYPATH .. "hr-Arachnids-run-mask2-01.png",
            ENTITYPATH .. "hr-Arachnids-run-mask2-02.png",
            ENTITYPATH .. "hr-Arachnids-run-mask2-03.png",
            ENTITYPATH .. "hr-Arachnids-run-mask2-04.png"
          },
          slice = 8,
          lines_per_file = 8,
          line_length = 8,
          width = 398,
          height = 350,
          frame_count = 16,
          --shift = util.mul_shift(util.by_pixel(-1, -5), scale),
          direction_count = 16,
          scale = 0.5 * scale,
          tint = tint2
        }
      },
      {
        filenames =
        {
          ENTITYPATH .. "Arachnids-run-shadow-01.png",
          ENTITYPATH .. "Arachnids-run-shadow-02.png",
          ENTITYPATH .. "Arachnids-run-shadow-03.png",
          ENTITYPATH .. "Arachnids-run-shadow-04.png"
        },
        slice = 8,
        lines_per_file = 8,
        line_length = 8,
        width = 199,
        height = 120,
        frame_count = 16,
        shift = util.mul_shift(util.by_pixel(18, 18), scale),
        direction_count = 16,
        scale =  1.24 * scale,
        draw_as_shadow = true,
        hr_version =
        {
          filenames =
          {
            ENTITYPATH .. "hr-Arachnids-run-shadow-01.png",
            ENTITYPATH .. "hr-Arachnids-run-shadow-02.png",
            ENTITYPATH .. "hr-Arachnids-run-shadow-03.png",
            ENTITYPATH .. "hr-Arachnids-run-shadow-04.png"
          },
          slice = 8,
          lines_per_file = 8,
          line_length = 8,
          width = 398,
          height = 240,
          frame_count = 16,
          shift = util.mul_shift(util.by_pixel(18, 18), scale),
          direction_count = 16,
          scale = 0.62 * scale,
          draw_as_shadow = true
        }
      }
    }
  }
end

function arachnids_attackanimation(scale, tint1, tint2)
  return
  {
    layers=
    {
      {
        filenames =
        {
          ENTITYPATH .. "Arachnids-attack-01.png",
          ENTITYPATH .. "Arachnids-attack-02.png",
          ENTITYPATH .. "Arachnids-attack-03.png",
          ENTITYPATH .. "Arachnids-attack-04.png"
        },
        slice = 11,
        lines_per_file = 4,
        line_length = 16,
        width = 199,
        height = 175,
        frame_count = 11,
        direction_count = 16,
        animation_speed = 0.4,
        --shift = util.mul_shift(util.by_pixel(-2, -26), scale),
        scale = scale,
        hr_version =
        {
          filenames =
          {
            ENTITYPATH .. "hr-Arachnids-attack-01.png",
            ENTITYPATH .. "hr-Arachnids-attack-02.png",
            ENTITYPATH .. "hr-Arachnids-attack-03.png",
            ENTITYPATH .. "hr-Arachnids-attack-04.png"
          },
          slice = 11,
          lines_per_file = 4,
          line_length = 16,
          width = 398,
          height = 350,
          frame_count = 11,
          --shift = util.mul_shift(util.by_pixel(0, -25), scale),
          direction_count = 16,
          animation_speed = 0.4,
          scale = scale * 0.5
        }
      },
      {
        filenames =
        {
          ENTITYPATH .. "Arachnids-attack-mask1-01.png",
          ENTITYPATH .. "Arachnids-attack-mask1-02.png",
          ENTITYPATH .. "Arachnids-attack-mask1-03.png",
          ENTITYPATH .. "Arachnids-attack-mask1-04.png"
        },
        slice = 11,
        lines_per_file = 4,
        flags = { "mask" },
        line_length = 16,
        width = 199,
        height = 175,
        frame_count = 11,
        direction_count = 16,
        animation_speed = 0.4,
        --shift = util.mul_shift(util.by_pixel(0, -42), scale),
        scale = scale,
        tint = tint1,
        hr_version =
        {
          filenames =
          {
            ENTITYPATH .. "hr-Arachnids-attack-mask1-01.png",
            ENTITYPATH .. "hr-Arachnids-attack-mask1-02.png",
            ENTITYPATH .. "hr-Arachnids-attack-mask1-03.png",
            ENTITYPATH .. "hr-Arachnids-attack-mask1-04.png"
          },
          slice = 11,
          lines_per_file = 4,
          line_length = 16,
          width = 398,
          height = 350,
          frame_count = 11,
          --shift = util.mul_shift(util.by_pixel(-1, -41), scale),
          direction_count = 16,
          animation_speed = 0.4,
          scale = scale * 0.5,
          tint = tint1
        }
      },
      {
        filenames =
        {
          ENTITYPATH .. "Arachnids-attack-mask2-01.png",
          ENTITYPATH .. "Arachnids-attack-mask2-02.png",
          ENTITYPATH .. "Arachnids-attack-mask2-03.png",
          ENTITYPATH .. "Arachnids-attack-mask2-04.png"
        },
        slice = 11,
        lines_per_file = 4,
        flags = { "mask" },
        line_length = 16,
        width = 199,
        height = 175,
        frame_count = 11,
        direction_count = 16,
        animation_speed = 0.4,
        --shift = util.mul_shift(util.by_pixel(-2, -42), scale),
        scale = scale,
        tint = tint2,
        hr_version =
        {
          filenames =
          {
            ENTITYPATH .. "hr-Arachnids-attack-mask2-01.png",
            ENTITYPATH .. "hr-Arachnids-attack-mask2-02.png",
            ENTITYPATH .. "hr-Arachnids-attack-mask2-03.png",
            ENTITYPATH .. "hr-Arachnids-attack-mask2-04.png"
          },
          slice = 11,
          lines_per_file = 4,
          line_length = 16,
          width = 398,
          height = 350,
          frame_count = 11,
          --shift = util.mul_shift(util.by_pixel(-1, -41), scale),
          direction_count = 16,
          animation_speed = 0.4,
          scale = scale * 0.5,
          tint = tint2
        }
      },
      {
        filenames =
        {
          ENTITYPATH .. "Arachnids-attack-shadow-01.png",
          ENTITYPATH .. "Arachnids-attack-shadow-02.png",
          ENTITYPATH .. "Arachnids-attack-shadow-03.png",
          ENTITYPATH .. "Arachnids-attack-shadow-04.png"
        },
        slice = 11,
        lines_per_file = 4,
        line_length = 16,
        width = 199,
        height = 120,
        frame_count = 11,
        shift = util.mul_shift(util.by_pixel(18, 18), scale),
        direction_count = 16,
        animation_speed = 0.4,
        scale = scale * 1.24,
        draw_as_shadow = true,
        hr_version =
        {
          filenames =
          {
            ENTITYPATH .. "hr-Arachnids-attack-shadow-01.png",
            ENTITYPATH .. "hr-Arachnids-attack-shadow-02.png",
            ENTITYPATH .. "hr-Arachnids-attack-shadow-03.png",
            ENTITYPATH .. "hr-Arachnids-attack-shadow-04.png"
          },
          slice = 11,
          lines_per_file = 4,
          line_length = 16,
          width = 398,
          height = 240,
          frame_count = 11,
          shift = util.mul_shift(util.by_pixel(18, 18), scale),
          direction_count = 16,
          animation_speed = 0.4,
          scale = scale * 0.62,
          draw_as_shadow = true
        }
      }
    }
  }
end

function arachnids_dieanimation(scale, tint1, tint2)
  return
  {
    layers=
    {
      {
        filenames =
        {

          ENTITYPATH .. "Arachnids-die-01.png",
          ENTITYPATH .. "Arachnids-die-02.png",
          ENTITYPATH .. "Arachnids-die-03.png",
          ENTITYPATH .. "Arachnids-die-04.png",
          ENTITYPATH .. "Arachnids-die-05.png",
          ENTITYPATH .. "Arachnids-die-06.png",
          ENTITYPATH .. "Arachnids-die-07.png",
          ENTITYPATH .. "Arachnids-die-08.png",
          ENTITYPATH .. "Arachnids-die-09.png",
          ENTITYPATH .. "Arachnids-die-10.png",
          ENTITYPATH .. "Arachnids-die-11.png",
          ENTITYPATH .. "Arachnids-die-12.png",
          ENTITYPATH .. "Arachnids-die-13.png",
          ENTITYPATH .. "Arachnids-die-14.png",
          ENTITYPATH .. "Arachnids-die-15.png",
          ENTITYPATH .. "Arachnids-die-16.png",
          ENTITYPATH .. "Arachnids-die-17.png"
		
         
        },
        slice = 4,
        lines_per_file = 4,
        line_length = 4,
        width = 199,
        height = 175,
        frame_count = 17,
        direction_count = 16,
        --shift= util.mul_shift(util.by_pixel(-2, -4), scale),
        scale = scale,
        hr_version =
        {
          filenames =
          {
            ENTITYPATH .. "hr-Arachnids-die-01.png",
            ENTITYPATH .. "hr-Arachnids-die-02.png",
            ENTITYPATH .. "hr-Arachnids-die-03.png",
            ENTITYPATH .. "hr-Arachnids-die-04.png",
            ENTITYPATH .. "hr-Arachnids-die-05.png",
            ENTITYPATH .. "hr-Arachnids-die-06.png",
            ENTITYPATH .. "hr-Arachnids-die-07.png",
            ENTITYPATH .. "hr-Arachnids-die-08.png",
            ENTITYPATH .. "hr-Arachnids-die-09.png",
            ENTITYPATH .. "hr-Arachnids-die-10.png",
            ENTITYPATH .. "hr-Arachnids-die-11.png",
            ENTITYPATH .. "hr-Arachnids-die-12.png",
            ENTITYPATH .. "hr-Arachnids-die-13.png",
            ENTITYPATH .. "hr-Arachnids-die-14.png",
            ENTITYPATH .. "hr-Arachnids-die-15.png",
            ENTITYPATH .. "hr-Arachnids-die-16.png",
            ENTITYPATH .. "hr-Arachnids-die-17.png"
          },
          slice = 4,
          lines_per_file = 4,
          line_length = 4,
          width = 398,
          height = 350,
          frame_count = 17,
          --shift = util.mul_shift(util.by_pixel(0, -4), scale),
          direction_count = 16,
          scale = 0.5 * scale
        }
      },





      {
        filenames =
        {

          ENTITYPATH .. "Arachnids-die-shadow-01.png",
          ENTITYPATH .. "Arachnids-die-shadow-02.png",
          ENTITYPATH .. "Arachnids-die-shadow-03.png",
          ENTITYPATH .. "Arachnids-die-shadow-04.png",
          ENTITYPATH .. "Arachnids-die-shadow-05.png",
          ENTITYPATH .. "Arachnids-die-shadow-06.png",
          ENTITYPATH .. "Arachnids-die-shadow-07.png",
          ENTITYPATH .. "Arachnids-die-shadow-08.png",
          ENTITYPATH .. "Arachnids-die-shadow-09.png",
          ENTITYPATH .. "Arachnids-die-shadow-10.png",
          ENTITYPATH .. "Arachnids-die-shadow-11.png",
          ENTITYPATH .. "Arachnids-die-shadow-12.png",
          ENTITYPATH .. "Arachnids-die-shadow-13.png",
          ENTITYPATH .. "Arachnids-die-shadow-14.png",
          ENTITYPATH .. "Arachnids-die-shadow-15.png",
          ENTITYPATH .. "Arachnids-die-shadow-16.png",
          ENTITYPATH .. "Arachnids-die-shadow-17.png"
		
        },
        slice = 4,
        lines_per_file = 4,
        line_length = 4,
        width = 199,
        height = 120,
        frame_count = 17,
        shift = util.mul_shift(util.by_pixel(18, 18), scale),
        direction_count = 16,
        scale = 1.24 * scale,
        draw_as_shadow = true,
        hr_version =
        {
          filenames =
          {
            ENTITYPATH .. "hr-Arachnids-die-shadow-01.png",
            ENTITYPATH .. "hr-Arachnids-die-shadow-02.png",
            ENTITYPATH .. "hr-Arachnids-die-shadow-03.png",
            ENTITYPATH .. "hr-Arachnids-die-shadow-04.png",
            ENTITYPATH .. "hr-Arachnids-die-shadow-05.png",
            ENTITYPATH .. "hr-Arachnids-die-shadow-06.png",
            ENTITYPATH .. "hr-Arachnids-die-shadow-07.png",
            ENTITYPATH .. "hr-Arachnids-die-shadow-08.png",
            ENTITYPATH .. "hr-Arachnids-die-shadow-09.png",
            ENTITYPATH .. "hr-Arachnids-die-shadow-10.png",
            ENTITYPATH .. "hr-Arachnids-die-shadow-11.png",
            ENTITYPATH .. "hr-Arachnids-die-shadow-12.png",
            ENTITYPATH .. "hr-Arachnids-die-shadow-13.png",
            ENTITYPATH .. "hr-Arachnids-die-shadow-14.png",
            ENTITYPATH .. "hr-Arachnids-die-shadow-15.png",
            ENTITYPATH .. "hr-Arachnids-die-shadow-16.png",
            ENTITYPATH .. "hr-Arachnids-die-shadow-17.png"
          },
          slice = 4,
          lines_per_file = 4,
          line_length = 4,
          width = 398,
          height = 240,
          frame_count = 17,
          shift = util.mul_shift(util.by_pixel(18, 18), scale),
          direction_count = 16,
          scale = 0.62 * scale,
          draw_as_shadow = true
        }
      }
    }
  }
end


arachnids_alternative_attacking_animation_sequence =
{
  warmup_frame_sequence = { 1, 2, 3, 4, 5, 6 },
  warmup2_frame_sequence = { 7, 7, 7, 7, 7, 7 },
  attacking_frame_sequence = { 7, 8, 9, 10, 11, 10, 9, 8, 7 },
  cooldown_frame_sequence = { 7 },
  prepared_frame_sequence = { 7 },
  back_to_walk_frame_sequence = { 6, 5, 4, 3, 2, 1 },

  warmup_animation_speed = 1 / 6 * 0.4,
  attacking_animation_speed = 1 / 16 * 0.4,
  cooldown_animation_speed = 1 / 1 * 0.4 * 0.125,
  prepared_animation_speed = 1 / 1 * 0.5 * 0.4,
  back_to_walk_animation_speed = 1 / 6 * 0.4
}

--[[

local function arachnids_spawner_integration()
return
  {
    filename = ENTITYPATH .. "Arachnids-spawner-idle-integration.png",
    variation_count = 4,
    width = 5,
    height = 20,
    shift = util.by_pixel(2, -2),
    frame_count = 1,
    line_length = 1,
    hr_version =
    {
      filename = ENTITYPATH .. "Arachnids-spawner-idle-integration.png",
      variation_count = 4,
      width = 5,
      height = 20,
      shift = util.by_pixel(3, -3),
      frame_count = 1,
      line_length = 1,
      scale = 0.5
    }
  }
end



local function arachnids_spawner_idle_animation(scale, variation)
return
  {
    layers =
    {
      {
        filename = ENTITYPATH .. "Arachnids-spawner-idle.png",
        line_length = 1,
        width = 175,
        height = 181,
	  frame_count = 1,
	  shift = util.mul_shift(util.by_pixel(-10, -20), scale),	
        --shift = util.by_pixel(-10, -20),
        y = variation * 181,
	 scale = scale,	
        hr_version =
        {
          filename = ENTITYPATH .. "hr-Arachnids-spawner-idle.png",
          line_length = 1,
          width = 350,
          height = 362,
	    frame_count = 1,
	    shift = util.mul_shift(util.by_pixel(-10, -20), scale),
          --shift = util.by_pixel(-10, -20),
          y = variation * 362,
          scale = 0.5 * scale
        }
      },
      {
        filename = ENTITYPATH .. "Arachnids-spawner-idle-shadow.png",
        draw_as_shadow = true,
        width = 185,
        height = 120,
	  frame_count = 1,
        shift = util.mul_shift(util.by_pixel(20, -2), scale),
        line_length = 1,
        y = variation * 120,
	  scale = 1.18 * scale,	
        hr_version =
        {
          filename = ENTITYPATH .. "hr-Arachnids-spawner-idle-shadow.png",
          draw_as_shadow = true,
          width = 370,
          height = 240,
	    frame_count = 1,
          shift = util.mul_shift(util.by_pixel(20, -2), scale),
          line_length = 1,
          y = variation * 240,
          scale = 0.59 * scale
        }
      }
    }
  }
end

local function arachnids_spawner_die_animation(scale,variation)
return
  {
    layers =
    {
      {
        filename = ENTITYPATH .. "Arachnids-spawner-die.png",
        line_length = 8,
        width = 175,
        height = 181,
        frame_count = 8,
        direction_count = 1,
        shift = util.mul_shift(util.by_pixel(-10, -20), scale),
        y = variation * 181,
	  scale = scale,
        hr_version =
        {
          filename = ENTITYPATH .. "hr-Arachnids-spawner-die.png",
          line_length = 8,
          width = 350,
          height = 362,
          frame_count = 8,
          direction_count = 1,
          shift = util.mul_shift(util.by_pixel(-10, -20), scale),
          y = variation * 362,
          scale = 0.5 * scale
        }
      },
      {
        filename = ENTITYPATH .. "Arachnids-spawner-die-shadow.png",
        draw_as_shadow = true,
        width = 185,
        height = 120,
        frame_count = 8,
        direction_count = 1,
        shift = util.mul_shift(util.by_pixel(20, -2), scale),
        line_length = 8,
        y = variation * 120,
	  scale = 1.18 * scale,
        hr_version =
        {
          filename = ENTITYPATH .. "hr-Arachnids-spawner-die-shadow.png",
          draw_as_shadow = true,
          width = 370,
          height = 240,
          frame_count = 8,
          direction_count = 1,
          shift = util.mul_shift(util.by_pixel(20, -2), scale),
          line_length = 8,
          y = variation * 240,
          scale = 0.59 * scale
        }
      }
    }
  }
end

arachnids_ground_patch = {
        sheet = {
          filename = "__base__/graphics/entity/biter/blood-puddle-var-main.png",
          flags = {
            "low-object"
          },
          frame_count = 1,
          height = 68,
          hr_version = {
            filename = "__base__/graphics/entity/biter/hr-blood-puddle-var-main.png",
            flags = {
              "low-object"
            },
            frame_count = 1,
            height = 134,
            line_length = 4,
            scale = 0.5,
            shift = {
              -0.015625,
              -0.015625
            },
            tint = {
              a = 1,
              b = 0.1,
              g = 1,
              r = 0.4
            },
            variation_count = 4,
            width = 164
          },
          line_length = 4,
          scale = 0.75,
          shift = {
            0.03125,
            0
          },
          tint = {
            a = 1,
            b = 0.1,
            g = 1,
            r = 0.4
          },
          variation_count = 4,
          width = 84
        }
      }

local particle_animations = {}

particle_animations.get_blood_particle_pictures = function(options)
  local options = options or {}
  return
  {
    sheet =
    {
      filename = "__base__/graphics/particle/blood-particle/blood-particle.png",
      line_length = 12,
      width = 10,
      height = 8,
      frame_count = 12,
      variation_count = 7,
      tint = options.tint,
      shift = util.add_shift(util.by_pixel(2,-1), options.shift),
      hr_version =
      {
        filename = "__base__/graphics/particle/blood-particle/hr-blood-particle.png",
        line_length = 12,
        width = 16,
        height = 16,
        frame_count = 12,
        variation_count = 7,
        tint = options.tint,
        scale = 0.5,
        shift = util.add_shift(util.by_pixel(1.5,-1), options.shift)
      }
    }
  }
end


data.raw["optimized-particle"]["blood-particle"].pictures = particle_animations.get_blood_particle_pictures({tint = {r = 60, g = 200, b = 20}})
data.raw["optimized-particle"]["blood-particle-lower-layer"].pictures = particle_animations.get_blood_particle_pictures({tint = {r = 60, g = 200, b = 20}})
data.raw["optimized-particle"]["blood-particle-carpet"].pictures = particle_animations.get_blood_particle_pictures({tint = {r = 60, g = 200, b = 20}})

data.raw["corpse"]["small-biter-corpse"].ground_patch = arachnids_ground_patch 
data.raw["corpse"]["medium-biter-corpse"].ground_patch = arachnids_ground_patch 
data.raw["corpse"]["big-biter-corpse"].ground_patch = arachnids_ground_patch 
data.raw["corpse"]["behemoth-biter-corpse"].ground_patch = arachnids_ground_patch 

data.raw.unit['small-biter'].run_animation = arachnidsrunanimation (small_biter_scale, small_biter_tint1, small_biter_tint2)
data.raw.unit['small-biter'].distance_per_frame = 0.2
data.raw.unit['medium-biter'].run_animation = arachnidsrunanimation (medium_biter_scale, medium_biter_tint1, medium_biter_tint2)
data.raw.unit['medium-biter'].distance_per_frame = 0.225
data.raw.unit['big-biter'].run_animation = arachnidsrunanimation (big_biter_scale, big_biter_tint1, big_biter_tint2)
data.raw.unit['big-biter'].distance_per_frame = 0.25
data.raw.unit['behemoth-biter'].run_animation = arachnidsrunanimation (behemoth_biter_scale, behemoth_biter_tint1, behemoth_biter_tint2)
data.raw.unit['behemoth-biter'].distance_per_frame = 0.3

data.raw.unit['small-biter']['attack_parameters'].animation = arachnidsattackanimation (small_biter_scale, small_biter_tint1, small_biter_tint2)
data.raw.unit['medium-biter']['attack_parameters'].animation = arachnidsattackanimation (medium_biter_scale, medium_biter_tint1, medium_biter_tint2)
data.raw.unit['big-biter']['attack_parameters'].animation = arachnidsattackanimation (big_biter_scale, big_biter_tint1, big_biter_tint2)
data.raw.unit['behemoth-biter']['attack_parameters'].animation = arachnidsattackanimation (behemoth_biter_scale, behemoth_biter_tint1, behemoth_biter_tint2)

data.raw["corpse"]["small-biter-corpse"].animation = arachnidsdieanimation (small_biter_scale, small_biter_tint1, small_biter_tint2)
data.raw["corpse"]["medium-biter-corpse"].animation = arachnidsdieanimation (medium_biter_scale, medium_biter_tint1, medium_biter_tint2)
data.raw["corpse"]["big-biter-corpse"].animation = arachnidsdieanimation (big_biter_scale, big_biter_tint1, big_biter_tint2)
data.raw["corpse"]["behemoth-biter-corpse"].animation = arachnidsdieanimation (behemoth_biter_scale, behemoth_biter_tint1, behemoth_biter_tint2)



data.raw["corpse"]["small-spitter-corpse"].ground_patch = arachnids_ground_patch 
data.raw["corpse"]["medium-spitter-corpse"].ground_patch = arachnids_ground_patch 
data.raw["corpse"]["big-spitter-corpse"].ground_patch = arachnids_ground_patch 
data.raw["corpse"]["behemoth-spitter-corpse"].ground_patch = arachnids_ground_patch 

data.raw.unit['small-spitter'].run_animation = arachnidsrunanimation (small_biter_scale, small_biter_tint1, small_biter_tint2)
data.raw.unit['small-spitter'].distance_per_frame = 0.225
data.raw.unit['medium-spitter'].run_animation = arachnidsrunanimation (medium_biter_scale, medium_biter_tint1, medium_biter_tint2)
data.raw.unit['medium-spitter'].distance_per_frame = 0.225
data.raw.unit['big-spitter'].run_animation = arachnidsrunanimation (big_biter_scale, big_biter_tint1, big_biter_tint2)
data.raw.unit['big-spitter'].distance_per_frame = 0.225
data.raw.unit['behemoth-spitter'].run_animation = arachnidsrunanimation (behemoth_biter_scale, behemoth_biter_tint1, behemoth_biter_tint2)
data.raw.unit['behemoth-spitter'].distance_per_frame = 0.225

data.raw.unit['small-spitter']['attack_parameters'].animation = arachnidsattackanimation (small_biter_scale, small_biter_tint1, small_biter_tint2)
data.raw.unit['small-spitter'].alternative_attacking_frame_sequence = arachnids_alternative_attacking_animation_sequence
data.raw.unit['medium-spitter']['attack_parameters'].animation = arachnidsattackanimation (medium_biter_scale, medium_biter_tint1, medium_biter_tint2)
data.raw.unit['medium-spitter'].alternative_attacking_frame_sequence = arachnids_alternative_attacking_animation_sequence
data.raw.unit['big-spitter']['attack_parameters'].animation = arachnidsattackanimation (big_biter_scale, big_biter_tint1, big_biter_tint2)
data.raw.unit['big-spitter'].alternative_attacking_frame_sequence = arachnids_alternative_attacking_animation_sequence
data.raw.unit['behemoth-spitter']['attack_parameters'].animation = arachnidsattackanimation (behemoth_biter_scale, behemoth_biter_tint1, behemoth_biter_tint2)
data.raw.unit['behemoth-spitter'].alternative_attacking_frame_sequence = arachnids_alternative_attacking_animation_sequence

data.raw["corpse"]["small-spitter-corpse"].animation = arachnidsdieanimation (small_biter_scale, small_biter_tint1, small_biter_tint2)
data.raw["corpse"]["medium-spitter-corpse"].animation = arachnidsdieanimation (medium_biter_scale, small_biter_tint1, small_biter_tint2)
data.raw["corpse"]["big-spitter-corpse"].animation = arachnidsdieanimation (big_biter_scale, small_biter_tint1, small_biter_tint2)
data.raw["corpse"]["behemoth-spitter-corpse"].animation = arachnidsdieanimation (behemoth_biter_scale, small_biter_tint1, small_biter_tint2)



data.raw["unit-spawner"]["biter-spawner"].animations = {arachnids_spawner_idle_animation(biter_spawner_scale_0,0),arachnids_spawner_idle_animation(biter_spawner_scale_1,1),arachnids_spawner_idle_animation(biter_spawner_scale_2,2),arachnids_spawner_idle_animation(biter_spawner_scale_3,3)}
data.raw["unit-spawner"]["biter-spawner"].integration = {sheet = arachnids_spawner_integration()}
data.raw["corpse"]["biter-spawner-corpse"].animation = {arachnids_spawner_die_animation(biter_spawner_scale_0,0),arachnids_spawner_die_animation(biter_spawner_scale_1,1),arachnids_spawner_die_animation(biter_spawner_scale_2,2),arachnids_spawner_die_animation(biter_spawner_scale_3,3)}
data.raw["corpse"]["biter-spawner-corpse"].ground_patch = {sheet = arachnids_spawner_integration()}
data.raw["corpse"]["biter-spawner-corpse"].dying_speed = 0.04

data.raw["unit-spawner"]["spitter-spawner"].animations = {arachnids_spawner_idle_animation(biter_spawner_scale_3,0),arachnids_spawner_idle_animation(biter_spawner_scale_2,1),arachnids_spawner_idle_animation(biter_spawner_scale_0,2),arachnids_spawner_idle_animation(biter_spawner_scale_1,3)}
data.raw["unit-spawner"]["spitter-spawner"].integration = {sheet = arachnids_spawner_integration()}
data.raw["corpse"]["spitter-spawner-corpse"].animation = {arachnids_spawner_die_animation(biter_spawner_scale_3,0),arachnids_spawner_die_animation(biter_spawner_scale_2,1),arachnids_spawner_die_animation(biter_spawner_scale_0,2),arachnids_spawner_die_animation(biter_spawner_scale_1,3)}
data.raw["corpse"]["spitter-spawner-corpse"].ground_patch = {sheet = arachnids_spawner_integration()}
data.raw["corpse"]["spitter-spawner-corpse"].dying_speed = 0.04

]]













