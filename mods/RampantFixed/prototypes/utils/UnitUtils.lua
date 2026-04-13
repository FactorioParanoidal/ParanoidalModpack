local unitUtils = {}
require("__base__.prototypes.entity.biter-animations")

local function sprite_load(path, table)
  local original_shift = table.shift or {0, 0}
  local multiply_shift = table.multiply_shift or 1
  local sprite_data = require(path)
  table.width       = sprite_data.width
  table.height      = sprite_data.height
  table.shift       = {sprite_data.shift[1] * multiply_shift + original_shift[1], sprite_data.shift[2] * multiply_shift + original_shift[2]}
  table.line_length = sprite_data.line_length
  table.frames      = sprite_data.frames

  if table.frame_index then
    local column_index = table.frame_index % sprite_data.line_length
    local row_index = (table.frame_index - column_index) / sprite_data.line_length
    table.x = column_index * sprite_data.width
    table.y = row_index * sprite_data.height
    table.frame_index = nil
  end

  if sprite_data.filenames then
    local t = {}
    for k, v in pairs(sprite_data.filenames) do
      t[k] = path .. v
    end
    table.filenames = t
    table.lines_per_file = sprite_data.lines_per_file
  else
    table.filename = path .. '.png'
  end

  table.multiply_shift = nil

  return table
end


function unitUtils.spitter_water_reflection(scale)
  return
  {
    pictures =
    {
      filename = "__base__/graphics/entity/spitter/spitter-reflection.png",
      priority = "extra-high",
      width = 20,
      height = 32,
      shift = util.by_pixel(5, 15),
      scale = 5 * scale,
      variation_count = 1,
    },
    rotate = true,
    orientation_to_variation = false
  }
end

function unitUtils.biter_water_reflection(scale)
  return
  {
    pictures =
    {
      filename = "__base__/graphics/entity/biter/biter-reflection.png",
      priority = "extra-high",
      width = 20,
      height = 28,
      shift = util.by_pixel(5, 15),
      scale = 5 * scale,
      variation_count = 1,
    },
    rotate = true,
    orientation_to_variation = false
  }
end


function unitUtils.spitter_alternative_attacking_animation_sequence()
    return {
        warmup_frame_sequence = { 1, 2, 3, 4, 5, 6 },
        warmup2_frame_sequence = { 7, 7, 7, 7, 7, 7 },
        attacking_frame_sequence = { 7, 8, 9, 10, 11,  12, 13, 14, 13, 14,  13, 12, 11, 10, 9,  8 },
        cooldown_frame_sequence = { 7 },
        prepared_frame_sequence = { 7 },
        back_to_walk_frame_sequence = { 6, 5, 4, 3, 2, 1 },

        warmup_animation_speed = 1 / 6 * 0.4,
        attacking_animation_speed = 1 / 16 * 0.4,
        cooldown_animation_speed = 1 / 1 * 0.4 * 0.125;
        prepared_animation_speed = 1 / 1 * 0.5 * 0.4,
        back_to_walk_animation_speed = 1 / 6 * 0.4,
    }
end

function unitUtils.spitterrunanimation(scale, tint1, tint2)
  return
  {
    layers=
    {
      util.sprite_load("__base__/graphics/entity/spitter/spitter-run",
        {
          slice = 6,
          frame_count = 16,
          direction_count = 16,
          scale = scale * 0.5,
          multiply_shift = scale,
          allow_forced_downscale = true,
          surface = "nauvis",
          usage = "enemy"
        }
      ),
      util.sprite_load("__base__/graphics/entity/spitter/spitter-run-mask1",
        {
          slice = 6,
          frame_count = 16,
          direction_count = 16,
          scale = scale * 0.5,
          flags = { "mask" },
          tint = tint1,
          multiply_shift = scale,
          allow_forced_downscale = true,
          surface = "nauvis",
          usage = "enemy"
        }
      ),
      util.sprite_load("__base__/graphics/entity/spitter/spitter-run-mask2",
        {
          slice = 6,
          frame_count = 16,
          direction_count = 16,
          scale = scale * 0.5,
          flags = { "mask" },
          tint = tint2,
          multiply_shift = scale,
          allow_forced_downscale = true,
          surface = "nauvis",
          usage = "enemy"
        }
      ),
      util.sprite_load("__base__/graphics/entity/spitter/spitter-run-shadow",
        {
          slice = 6,
          frame_count = 16,
          direction_count = 16,
          scale = scale * 0.5,
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

function unitUtils.spitterdyinganimation(scale, tint1, tint2)
  return
  {
    layers=
    {
      util.sprite_load("__base__/graphics/entity/spitter/spitter-die",
        {
          slice = 6,
          frame_count = 15,
          direction_count = 16,
          scale = scale * 0.5,
          multiply_shift = scale,
          flags = {"corpse-decay"},
          allow_forced_downscale = true,
          surface = "nauvis",
          usage = "enemy"
        }
      ),
      util.sprite_load("__base__/graphics/entity/spitter/spitter-die-mask1",
        {
          slice = 6,
          frame_count = 15,
          direction_count = 16,
          scale = scale * 0.5,
          tint = tint1,
          multiply_shift = scale,
          flags = {"corpse-decay"},
          allow_forced_downscale = true,
          surface = "nauvis",
          usage = "enemy"
        }
      ),
      util.sprite_load("__base__/graphics/entity/spitter/spitter-die-mask2",
        {
          slice = 6,
          frame_count = 15,
          direction_count = 16,
          scale = scale * 0.5,
          tint = tint2,
          multiply_shift = scale,
          flags = {"corpse-decay"},
          allow_forced_downscale = true,
          surface = "nauvis",
          usage = "enemy"
        }
      ),
      util.sprite_load("__base__/graphics/entity/spitter/spitter-die-shadow",
        {
          slice = 6,
          frame_count = 15,
          direction_count = 16,
          scale = scale * 0.5,
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

function unitUtils.spitterattackanimation(scale, tint1, tint2)
  return
  {
    layers=
    {
      util.sprite_load("__base__/graphics/entity/spitter/spitter-attack",
        {
          slice = 6,
          frame_count = 14,
          direction_count = 16,
          scale = scale * 0.5,
          run_mode = "forward-then-backward",
          animation_speed = 0.4,
          multiply_shift = scale,
          allow_forced_downscale = true,
          surface = "nauvis",
          usage = "enemy"
        }
      ),
      util.sprite_load("__base__/graphics/entity/spitter/spitter-attack-mask1",
        {
          slice = 6,
          frame_count = 14,
          direction_count = 16,
          scale = scale * 0.5,
          run_mode = "forward-then-backward",
          animation_speed = 0.4,
          tint = tint1,
          multiply_shift = scale,
          allow_forced_downscale = true,
          surface = "nauvis",
          usage = "enemy"
        }
      ),
      util.sprite_load("__base__/graphics/entity/spitter/spitter-attack-mask2",
        {
          slice = 6,
          frame_count = 14,
          direction_count = 16,
          scale = scale * 0.5,
          run_mode = "forward-then-backward",
          animation_speed = 0.4,
          tint = tint2,
          multiply_shift = scale,
          allow_forced_downscale = true,
          surface = "nauvis",
          usage = "enemy"
        }
      ),
      util.sprite_load("__base__/graphics/entity/spitter/spitter-attack-shadow",
        {
          slice = 6,
          frame_count = 14,
          direction_count = 16,
          scale = scale * 0.5,
          run_mode = "forward-then-backward",
          animation_speed = 0.4,
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

local function vanillaDieBiter(scale, tint1, tint2)
  return
  {
    layers=
    {
      util.sprite_load("__base__/graphics/entity/biter/biter-die",
        {
          slice = 8,
          frame_count = 17,
          direction_count = 16,
          scale = scale * 0.5,
          multiply_shift = scale,
          flags = {"corpse-decay"},
          allow_forced_downscale = true,
          surface = "nauvis",
          usage = "enemy"
        }
      ),
      util.sprite_load("__base__/graphics/entity/biter/biter-die-mask1",
        {
          slice = 8,
          frame_count = 17,
          direction_count = 16,
          scale = scale * 0.5,
          tint = tint1,
          multiply_shift = scale,
          flags = {"corpse-decay"},
          allow_forced_downscale = true,
          surface = "nauvis",
          usage = "enemy"
        }
      ),
      util.sprite_load("__base__/graphics/entity/biter/biter-die-mask2",
        {
          slice = 8,
          frame_count = 17,
          direction_count = 16,
          scale = scale * 0.5,
          tint = tint2,
          multiply_shift = scale,
          flags = {"corpse-decay"},
          allow_forced_downscale = true,
          surface = "nauvis",
          usage = "enemy"
        }
      ),
      util.sprite_load("__base__/graphics/entity/biter/biter-die-shadow",
        {
          slice = 6,
          frame_count = 17,
          direction_count = 16,
          scale = scale * 0.5,
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
-------- v 1.2 armoured biters
local function armoredDieBiter(scale, tint1, tint2)
-- function biterarmoureddieanimation(scale, tint1, tint2)
    return {
        layers = {
            {
                filenames = {
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-01.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-02.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-03.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-04.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-05.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-06.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-07.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-08.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-09.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-10.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-11.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-12.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-13.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-14.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-15.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-16.png"
                },
                slice = 4,
                lines_per_file = 4,
                line_length = 4,
                width = 476,
                height = 340,
                frame_count = 16,
                shift = {0, 0},
                direction_count = 16,
                scale = 0.5 * scale
            },
            {
                filenames = {
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-mask1-01.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-mask1-02.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-mask1-03.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-mask1-04.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-mask1-05.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-mask1-06.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-mask1-07.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-mask1-08.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-mask1-09.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-mask1-10.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-mask1-11.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-mask1-12.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-mask1-13.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-mask1-14.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-mask1-15.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-mask1-16.png"
                },
                slice = 4,
                lines_per_file = 4,
                line_length = 4,
                width = 476,
                height = 340,
                frame_count = 16,
                shift = {0, 0},
                direction_count = 16,
                scale = 0.5 * scale,
                tint = tint1
            },
            {
                filenames = {
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-mask2-01.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-mask2-02.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-mask2-03.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-mask2-04.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-mask2-05.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-mask2-06.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-mask2-07.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-mask2-08.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-mask2-09.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-mask2-10.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-mask2-11.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-mask2-12.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-mask2-13.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-mask2-14.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-mask2-15.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-mask2-16.png"
                },
                slice = 4,
                lines_per_file = 4,
                line_length = 4,
                width = 476,
                height = 340,
                frame_count = 16,
                shift = {0, 0},
                direction_count = 16,
                scale = 0.5 * scale,
                tint = tint2
            },
            {
                filenames = {
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-shadow-01.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-shadow-02.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-shadow-03.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-shadow-04.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-shadow-05.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-shadow-06.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-shadow-07.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-shadow-08.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-shadow-09.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-shadow-10.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-shadow-11.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-shadow-12.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-shadow-13.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-shadow-14.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-shadow-15.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-die-shadow-16.png"
                },
                slice = 4,
                lines_per_file = 4,
                line_length = 4,
                width = 476,
                height = 340,
                frame_count = 16,
                shift = {0, 0},
                direction_count = 16,
                scale = 0.5 * scale,
                draw_as_shadow = true
            }
        }
    }
end

local function armoredAttackBiter(scale, tint1, tint2)
    return {
        layers = {
            {
                filenames = {
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-attack-01.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-attack-02.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-attack-03.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-attack-04.png"
                },
                slice = 11,
                lines_per_file = 4,
                line_length = 16,
                width = 476,
                height = 340,
                frame_count = 11,
                shift = {0, 0},
                direction_count = 16,
                animation_speed = 0.4,
                scale = 0.5 * scale
            },
            {
                filenames = {
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-attack-mask1-01.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-attack-mask1-02.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-attack-mask1-03.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-attack-mask1-04.png"
                },
                slice = 11,
                lines_per_file = 4,
                line_length = 16,
                width = 476,
                height = 340,
                frame_count = 11,
                shift = {0, 0},
                direction_count = 16,
                animation_speed = 0.4,
                scale = 0.5 * scale,
                tint = tint1
            },
            {
                filenames = {
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-attack-mask2-01.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-attack-mask2-02.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-attack-mask2-03.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-attack-mask2-04.png"
                },
                slice = 11,
                lines_per_file = 4,
                line_length = 16,
                width = 476,
                height = 340,
                frame_count = 11,
                shift = {0, 0},
                direction_count = 16,
                animation_speed = 0.4,
                scale = 0.5 * scale,
                tint = tint2
            },
            {
                filenames = {
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-attack-shadow-01.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-attack-shadow-02.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-attack-shadow-03.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-attack-shadow-04.png"
                },
                slice = 11,
                lines_per_file = 4,
                line_length = 16,
                width = 476,
                height = 340,
                frame_count = 11,
                shift = {0, 0},
                direction_count = 16,
                animation_speed = 0.4,
                scale = 0.5 * scale,
                draw_as_shadow = true
            }
        }
    }
end

local function armoredRunBiter(scale, tint1, tint2)
    return {
        layers = {
            {
                filenames = {
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-run-01.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-run-02.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-run-03.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-run-04.png"
                },
                slice = 8,
                lines_per_file = 8,
                line_length = 8,
                width = 476,
                height = 340,
                frame_count = 16,
                shift = {0, 0},
                direction_count = 16,
                scale = 0.5 * scale
            },
            {
                filenames = {
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-run-mask1-01.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-run-mask1-02.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-run-mask1-03.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-run-mask1-04.png"
                },
                slice = 8,
                lines_per_file = 8,
                line_length = 8,
                width = 476,
                height = 340,
                frame_count = 16,
                shift = {0, 0},
                direction_count = 16,
                scale = 0.5 * scale,
                tint = tint1
            },
            {
                filenames = {
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-run-mask2-01.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-run-mask2-02.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-run-mask2-03.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-run-mask2-04.png"
                },
                slice = 8,
                lines_per_file = 8,
                line_length = 8,
                width = 476,
                height = 340,
                frame_count = 16,
                shift = {0, 0},
                direction_count = 16,
                scale = 0.5 * scale,
                tint = tint2
            },
            {
                filenames = {
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-run-shadow-01.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-run-shadow-02.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-run-shadow-03.png",
                    "__ArmouredBiters__/graphics/armoured-biter/armoured-biter-run-shadow-04.png"
                },
                slice = 8,
                lines_per_file = 8,
                line_length = 8,
                width = 476,
                height = 340,
                frame_count = 16,
                shift = {0, 0},
                direction_count = 16,
                scale = 0.5 * scale,
                draw_as_shadow = true
            }
        }
    }
end


-------------------------------



-- local function armoredDieBiter(scale, tint1, tint2)
    -- return {
        -- layers=
            -- {
                -- {
                    -- filenames =
                        -- {
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-01.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-02.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-03.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-04.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-05.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-06.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-07.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-08.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-09.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-10.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-11.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-12.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-13.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-14.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-15.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-16.png"
                        -- },
                    -- slice = 4,
                    -- lines_per_file = 4,
                    -- line_length = 4,
                    -- width = 238,
                    -- height = 170,
                    -- frame_count = 16,
                    -- direction_count = 16,
                    -- shift= {0,0},
                    -- tint=tint1,
                    -- scale = scale,
                    -- hr_version =
                        -- {
                            -- filenames =
                                -- {
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-01.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-02.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-03.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-04.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-05.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-06.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-07.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-08.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-09.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-10.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-11.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-12.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-13.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-14.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-15.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-16.png"
                                -- },
                            -- slice = 4,
                            -- lines_per_file = 4,
                            -- line_length = 4,
                            -- width = 476,
                            -- height = 340,
                            -- frame_count = 16,
                            -- shift = {0,0},
                            -- direction_count = 16,
                            -- scale = 0.5 * scale,
                        -- }
                -- },
                -- {
                    -- filenames =
                        -- {
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-mask1-01.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-mask1-02.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-mask1-03.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-mask1-04.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-mask1-05.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-mask1-06.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-mask1-07.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-mask1-08.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-mask1-09.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-mask1-10.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-mask1-11.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-mask1-12.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-mask1-13.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-mask1-14.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-mask1-15.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-mask1-16.png"
                        -- },
                    -- slice = 4,
                    -- lines_per_file = 4,
                    -- flags = { "mask" },
                    -- line_length = 4,
                    -- width = 238,
                    -- height = 170,
                    -- frame_count = 16,
                    -- direction_count = 16,
                    -- shift = {0,0},
                    -- scale = scale,
                    -- tint = tint2,
                    -- hr_version =
                        -- {
                            -- filenames =
                                -- {
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-mask1-01.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-mask1-02.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-mask1-03.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-mask1-04.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-mask1-05.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-mask1-06.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-mask1-07.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-mask1-08.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-mask1-09.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-mask1-10.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-mask1-11.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-mask1-12.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-mask1-13.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-mask1-14.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-mask1-15.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-mask1-16.png"
                                -- },
                            -- slice = 4,
                            -- lines_per_file = 4,
                            -- line_length = 4,
                            -- width = 476,
                            -- height = 340,
                            -- frame_count = 16,
                            -- shift = {0,0},
                            -- direction_count = 16,
                            -- scale = 0.5 * scale,
                            -- tint = tint1,
                        -- }
                -- },
                -- {
                    -- filenames =
                        -- {
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-mask2-01.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-mask2-02.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-mask2-03.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-mask2-04.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-mask2-05.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-mask2-06.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-mask2-07.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-mask2-08.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-mask2-09.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-mask2-10.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-mask2-11.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-mask2-12.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-mask2-13.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-mask2-14.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-mask2-15.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-mask2-16.png"
                        -- },
                    -- slice = 4,
                    -- lines_per_file = 4,
                    -- flags = { "mask" },
                    -- line_length = 4,
                    -- width = 238,
                    -- height = 170,
                    -- frame_count = 16,
                    -- direction_count = 16,
                    -- shift = {0,0},
                    -- scale = scale,
                    -- tint = tint2,
                    -- hr_version =
                        -- {
                            -- filenames =
                                -- {
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-mask2-01.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-mask2-02.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-mask2-03.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-mask2-04.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-mask2-05.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-mask2-06.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-mask2-07.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-mask2-08.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-mask2-09.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-mask2-10.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-mask2-11.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-mask2-12.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-mask2-13.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-mask2-14.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-mask2-15.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-mask2-16.png"
                                -- },
                            -- slice = 4,
                            -- lines_per_file = 4,
                            -- line_length = 4,
                            -- width = 476,
                            -- height = 340,
                            -- frame_count = 16,
                            -- shift = {0,0},
                            -- direction_count = 16,
                            -- scale = 0.5 * scale,
                            -- tint = tint2,
                        -- }
                -- },
                -- {
                    -- filenames =
                        -- {
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-shadow-01.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-shadow-02.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-shadow-03.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-shadow-04.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-shadow-05.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-shadow-06.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-shadow-07.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-shadow-08.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-shadow-09.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-shadow-10.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-shadow-11.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-shadow-12.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-shadow-13.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-shadow-14.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-shadow-15.png",
                            -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-die-shadow-16.png"
                        -- },
                    -- slice = 4,
                    -- lines_per_file = 4,
                    -- line_length = 4,
                    -- width = 238,
                    -- height = 170,
                    -- frame_count = 16,
                    -- shift = {0,0},
                    -- direction_count = 16,
                    -- scale = scale,
                    -- draw_as_shadow = true,
                    -- hr_version =
                        -- {
                            -- filenames =
                                -- {
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-shadow-01.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-shadow-02.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-shadow-03.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-shadow-04.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-shadow-05.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-shadow-06.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-shadow-07.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-shadow-08.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-shadow-09.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-shadow-10.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-shadow-11.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-shadow-12.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-shadow-13.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-shadow-14.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-shadow-15.png",
                                    -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-die-shadow-16.png"
                                -- },
                            -- slice = 4,
                            -- lines_per_file = 4,
                            -- line_length = 4,
                            -- width = 476,
                            -- height = 340,
                            -- frame_count = 16,
                            -- shift = {0,0},
                            -- direction_count = 16,
                            -- scale = 0.5 * scale,
                            -- draw_as_shadow = true,
                        -- }
                -- }
            -- }
    -- }
-- end

local function vanillaAttackBiter(scale, tint1, tint2)
  return
  {
    layers=
    {
      util.sprite_load("__base__/graphics/entity/biter/biter-attack",
        {
          slice = 11,
          frame_count = 11,
          direction_count = 16,
          scale = scale * 0.5,
          animation_speed = 0.4,
          multiply_shift = scale,
          allow_forced_downscale = true,
          surface = "nauvis",
          usage = "enemy",
        }
      ),
      util.sprite_load("__base__/graphics/entity/biter/biter-attack-mask1",
        {
          slice = 11,
          frame_count = 11,
          direction_count = 16,
          scale = scale * 0.5,
          tint = tint1,
          animation_speed = 0.4,
          multiply_shift = scale,
          allow_forced_downscale = true,
          surface = "nauvis",
          usage = "enemy",
        }
      ),
      util.sprite_load("__base__/graphics/entity/biter/biter-attack-mask2",
        {
          slice = 11,
          frame_count = 11,
          direction_count = 16,
          scale = scale * 0.5,
          tint = tint2,
          animation_speed = 0.4,
          multiply_shift = scale,
          allow_forced_downscale = true,
          surface = "nauvis",
          usage = "enemy",
        }
      ),
      util.sprite_load("__base__/graphics/entity/biter/biter-attack-shadow",
        {
          slice = 11,
          frame_count = 11,
          direction_count = 16,
          scale = scale * 0.5,
          draw_as_shadow = true,
          animation_speed = 0.4,
          multiply_shift = scale,
          allow_forced_downscale = true,
          surface = "nauvis",
          usage = "enemy",
        }
      )
    }
  }
end

-- local function armoredAttackBiter(scale, tint1, tint2)
    -- return
        -- {
            -- layers=
                -- {
                    -- {
                        -- filenames =
                            -- {
                                -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-attack-01.png",
                                -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-attack-02.png",
                                -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-attack-03.png",
                                -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-attack-04.png",
                            -- },
                        -- slice = 11,
                        -- lines_per_file = 4,
                        -- line_length = 16,
                        -- width = 238,
                        -- height = 170,
                        -- frame_count = 11,
                        -- direction_count = 16,
                        -- animation_speed = 0.4,
                        -- shift = {0,0},
                        -- tint=tint1,
                        -- scale = scale,
                        -- hr_version =
                            -- {
                                -- filenames =
                                    -- {
                                        -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-attack-01.png",
                                        -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-attack-02.png",
                                        -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-attack-03.png",
                                        -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-attack-04.png",
                                    -- },
                                -- slice = 11,
                                -- lines_per_file = 4,
                                -- line_length = 16,
                                -- width = 476,
                                -- height = 340,
                                -- frame_count = 11,
                                -- shift = {0,0},
                                -- direction_count = 16,
                                -- animation_speed = 0.4,
                                -- scale = 0.5 * scale,
                            -- }
                    -- },
                    -- {
                        -- filenames =
                            -- {
                                -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-attack-mask1-01.png",
                                -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-attack-mask1-02.png",
                                -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-attack-mask1-03.png",
                                -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-attack-mask1-04.png",
                            -- },
                        -- slice = 11,
                        -- lines_per_file = 4,
                        -- flags = { "mask" },
                        -- line_length = 16,
                        -- width = 238,
                        -- height = 170,
                        -- frame_count = 11,
                        -- direction_count = 16,
                        -- animation_speed = 0.4,
                        -- shift = {0,0},
                        -- scale = scale,
                        -- tint = tint2,
                        -- hr_version =
                            -- {
                                -- filenames =
                                    -- {
                                        -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-attack-mask1-01.png",
                                        -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-attack-mask1-02.png",
                                        -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-attack-mask1-03.png",
                                        -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-attack-mask1-04.png",
                                    -- },
                                -- slice = 11,
                                -- lines_per_file = 4,
                                -- line_length = 16,
                                -- width = 476,
                                -- height = 340,
                                -- frame_count = 11,
                                -- shift = {0,0},
                                -- direction_count = 16,
                                -- animation_speed = 0.4,
                                -- scale = 0.5 * scale,
                                -- tint = tint1,
                            -- }
                    -- },
                    -- {
                        -- filenames =
                            -- {
                                -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-attack-mask2-01.png",
                                -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-attack-mask2-02.png",
                                -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-attack-mask2-03.png",
                                -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-attack-mask2-04.png",
                            -- },
                        -- slice = 11,
                        -- lines_per_file = 4,
                        -- flags = { "mask" },
                        -- line_length = 16,
                        -- width = 238,
                        -- height = 170,
                        -- frame_count = 11,
                        -- direction_count = 16,
                        -- animation_speed = 0.4,
                        -- shift = {0,0},
                        -- scale = scale,
                        -- tint = tint2,
                        -- hr_version =
                            -- {
                                -- filenames =
                                    -- {
                                        -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-attack-mask2-01.png",
                                        -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-attack-mask2-02.png",
                                        -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-attack-mask2-03.png",
                                        -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-attack-mask2-04.png",
                                    -- },
                                -- slice = 11,
                                -- lines_per_file = 4,
                                -- line_length = 16,
                                -- width = 476,
                                -- height = 340,
                                -- frame_count = 11,
                                -- shift = {0,0},
                                -- direction_count = 16,
                                -- animation_speed = 0.4,
                                -- scale = 0.5 * scale,
                                -- tint = tint2,
                            -- }
                    -- },
                    -- {
                        -- filenames =
                            -- {
                                -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-attack-shadow-01.png",
                                -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-attack-shadow-02.png",
                                -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-attack-shadow-03.png",
                                -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-attack-shadow-04.png",
                            -- },
                        -- slice = 11,
                        -- lines_per_file = 4,
                        -- line_length = 16,
                        -- width = 238,
                        -- height = 170,
                        -- frame_count = 11,
                        -- shift = {0,0},
                        -- direction_count = 16,
                        -- animation_speed = 0.4,
                        -- scale = scale,
                        -- draw_as_shadow = true,
                        -- hr_version =
                            -- {
                                -- filenames =
                                    -- {
                                        -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-attack-shadow-01.png",
                                        -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-attack-shadow-02.png",
                                        -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-attack-shadow-03.png",
                                        -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-attack-shadow-04.png",
                                    -- },
                                -- slice = 11,
                                -- lines_per_file = 4,
                                -- line_length = 16,
                                -- width = 476,
                                -- height = 340,
                                -- frame_count = 11,
                                -- shift = {0,0},
                                -- direction_count = 16,
                                -- animation_speed = 0.4,
                                -- scale = 0.5 * scale,
                                -- draw_as_shadow = true,
                            -- }
                    -- },
                -- }
        -- }
-- end

-- local function armoredRunBiter(scale, tint1, tint2)
    -- return
        -- {
            -- layers=
                -- {
                    -- {
                        -- filenames =
                            -- {
                                -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-run-01.png",
                                -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-run-02.png",
                                -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-run-03.png",
                                -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-run-04.png",
                            -- },
                        -- slice = 8,
                        -- lines_per_file = 8,
                        -- line_length = 8,
                        -- width = 238,
                        -- height = 170,
                        -- frame_count = 16,
                        -- direction_count = 16,
                        -- shift = {0,0},
                        -- scale = scale,
                        -- tint = tint1,
                        -- hr_version =
                            -- {
                                -- filenames =
                                    -- {
                                        -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-run-01.png",
                                        -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-run-02.png",
                                        -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-run-03.png",
                                        -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-run-04.png",
                                    -- },
                                -- slice = 8,
                                -- lines_per_file = 8,
                                -- line_length = 8,
                                -- width = 476,
                                -- height = 340,
                                -- frame_count = 16,
                                -- shift = {0,0},
                                -- direction_count = 16,
                                -- scale = 0.5 * scale,
                            -- }
                    -- },
                    -- {
                        -- filenames =
                            -- {
                                -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-run-mask1-01.png",
                                -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-run-mask1-02.png",
                                -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-run-mask1-03.png",
                                -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-run-mask1-04.png",
                            -- },
                        -- slice = 8,
                        -- lines_per_file = 8,
                        -- flags = { "mask" },
                        -- line_length = 8,
                        -- width = 238,
                        -- height = 170,
                        -- frame_count = 16,
                        -- direction_count = 16,
                        -- shift = {0,0},
                        -- scale = scale,
                        -- tint = tint2,
                        -- hr_version =
                            -- {
                                -- filenames =
                                    -- {
                                        -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-run-mask1-01.png",
                                        -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-run-mask1-02.png",
                                        -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-run-mask1-03.png",
                                        -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-run-mask1-04.png",
                                    -- },
                                -- slice = 8,
                                -- lines_per_file = 8,
                                -- line_length = 8,
                                -- width = 476,
                                -- height = 340,
                                -- frame_count = 16,
                                -- shift = {0,0},
                                -- direction_count = 16,
                                -- scale = 0.5 * scale,
                                -- tint = tint1,
                            -- }
                    -- },
                    -- {
                        -- filenames =
                            -- {
                                -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-run-mask2-01.png",
                                -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-run-mask2-02.png",
                                -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-run-mask2-03.png",
                                -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-run-mask2-04.png",
                            -- },
                        -- slice = 8,
                        -- lines_per_file = 8,
                        -- flags = { "mask" },
                        -- line_length = 8,
                        -- width = 238,
                        -- height = 170,
                        -- frame_count = 16,
                        -- direction_count = 16,
                        -- shift = {0,0},
                        -- scale = scale,
                        -- tint = tint2,
                        -- hr_version =
                            -- {
                                -- filenames =
                                    -- {
                                        -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-run-mask2-01.png",
                                        -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-run-mask2-02.png",
                                        -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-run-mask2-03.png",
                                        -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-run-mask2-04.png",
                                    -- },
                                -- slice = 8,
                                -- lines_per_file = 8,
                                -- line_length = 8,
                                -- width = 476,
                                -- height = 340,
                                -- frame_count = 16,
                                -- shift = {0,0},
                                -- direction_count = 16,
                                -- scale = 0.5 * scale,
                                -- tint = tint2,
                            -- }
                    -- },
                    -- {
                        -- filenames =
                            -- {
                                -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-run-shadow-01.png",
                                -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-run-shadow-02.png",
                                -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-run-shadow-03.png",
                                -- "__ArmouredBiters__/graphics/armoured-biter/LowRes/armoured-biter-run-shadow-04.png",
                            -- },
                        -- slice = 8,
                        -- lines_per_file = 8,
                        -- line_length = 8,
                        -- width = 238,
                        -- height = 170,
                        -- frame_count = 16,
                        -- shift = {0,0},
                        -- direction_count = 16,
                        -- scale = scale,
                        -- draw_as_shadow = true,
                        -- hr_version =
                            -- {
                                -- filenames =
                                    -- {
                                        -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-run-shadow-01.png",
                                        -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-run-shadow-02.png",
                                        -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-run-shadow-03.png",
                                        -- "__ArmouredBiters__/graphics/armoured-biter/HighRes/hr-armoured-biter-run-shadow-04.png",
                                    -- },
                                -- slice = 8,
                                -- lines_per_file = 8,
                                -- line_length = 8,
                                -- width = 476,
                                -- height = 340,
                                -- frame_count = 16,
                                -- shift = {0,0},
                                -- direction_count = 16,
                                -- scale = 0.5 * scale,
                                -- draw_as_shadow = true,
                            -- }
                    -- }
                -- }
        -- }
-- end

local function vanillaRunBiter(scale, tint1, tint2)
    return
        {
            layers=
                {
				 
					util.sprite_load("__base__/graphics/entity/biter/biter-run",
						{
						slice = 8,
						frame_count = 16,
						direction_count = 16,
						scale = scale* 0.5,
						multiply_shift = scale,
						allow_forced_downscale = true,
						surface = "nauvis",
						usage = "enemy",
						}
					  ),
				  util.sprite_load("__base__/graphics/entity/biter/biter-run-mask1",
					{
					  slice = 8,
					  frame_count = 16,
					  direction_count = 16,
					  flags = { "mask" },
					  tint = tint1,
					  scale = scale* 0.5,
					  multiply_shift = scale,
					  allow_forced_downscale = true,
					  surface = "nauvis",
					  usage = "enemy",
					}
				  ),
				  util.sprite_load("__base__/graphics/entity/biter/biter-run-mask2",
					{
					  slice = 8,
					  frame_count = 16,
					  direction_count = 16,
					  flags = { "mask" },
					  tint = tint2,
					  scale = scale* 0.5,
					  multiply_shift = scale,
					  allow_forced_downscale = true,
					  surface = "nauvis",
					  usage = "enemy",
					}
				  ),
				  util.sprite_load("__base__/graphics/entity/biter/biter-run-shadow",
					{
					  slice = 8,
					  frame_count = 16,
					  direction_count = 16,
					  draw_as_shadow = true,
					  scale = scale* 0.5,
					  multiply_shift = scale,
					  allow_forced_downscale = true,
					  surface = "nauvis",
					  usage = "enemy",
					}
				  )
                }
        }
end

-------------- arachnids ---------
local function arachnidsrunanimation(scale, tint1, tint2)
  return
  {
    layers=
    {
      {
        filenames =
        {
          "__Arachnids__/graphics/Arachnids-run-01.png",
          "__Arachnids__/graphics/Arachnids-run-02.png",
          "__Arachnids__/graphics/Arachnids-run-03.png",
          "__Arachnids__/graphics/Arachnids-run-04.png"
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
            "__Arachnids__/graphics/hr-Arachnids-run-01.png",
            "__Arachnids__/graphics/hr-Arachnids-run-02.png",
            "__Arachnids__/graphics/hr-Arachnids-run-03.png",
            "__Arachnids__/graphics/hr-Arachnids-run-04.png"
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
          "__Arachnids__/graphics/Arachnids-run-mask1-01.png",
          "__Arachnids__/graphics/Arachnids-run-mask1-02.png",
          "__Arachnids__/graphics/Arachnids-run-mask1-03.png",
          "__Arachnids__/graphics/Arachnids-run-mask1-04.png"
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
            "__Arachnids__/graphics/hr-Arachnids-run-mask1-01.png",
            "__Arachnids__/graphics/hr-Arachnids-run-mask1-02.png",
            "__Arachnids__/graphics/hr-Arachnids-run-mask1-03.png",
            "__Arachnids__/graphics/hr-Arachnids-run-mask1-04.png"
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
          "__Arachnids__/graphics/Arachnids-run-mask2-01.png",
          "__Arachnids__/graphics/Arachnids-run-mask2-02.png",
          "__Arachnids__/graphics/Arachnids-run-mask2-03.png",
          "__Arachnids__/graphics/Arachnids-run-mask2-04.png"
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
            "__Arachnids__/graphics/hr-Arachnids-run-mask2-01.png",
            "__Arachnids__/graphics/hr-Arachnids-run-mask2-02.png",
            "__Arachnids__/graphics/hr-Arachnids-run-mask2-03.png",
            "__Arachnids__/graphics/hr-Arachnids-run-mask2-04.png"
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
          "__Arachnids__/graphics/Arachnids-run-shadow-01.png",
          "__Arachnids__/graphics/Arachnids-run-shadow-02.png",
          "__Arachnids__/graphics/Arachnids-run-shadow-03.png",
          "__Arachnids__/graphics/Arachnids-run-shadow-04.png"
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
            "__Arachnids__/graphics/hr-Arachnids-run-shadow-01.png",
            "__Arachnids__/graphics/hr-Arachnids-run-shadow-02.png",
            "__Arachnids__/graphics/hr-Arachnids-run-shadow-03.png",
            "__Arachnids__/graphics/hr-Arachnids-run-shadow-04.png"
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

local function arachnidsattackanimation(scale, tint1, tint2)
  return
  {
    layers=
    {
      {
        filenames =
        {
          "__Arachnids__/graphics/Arachnids-attack-01.png",
          "__Arachnids__/graphics/Arachnids-attack-02.png",
          "__Arachnids__/graphics/Arachnids-attack-03.png",
          "__Arachnids__/graphics/Arachnids-attack-04.png"
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
            "__Arachnids__/graphics/hr-Arachnids-attack-01.png",
            "__Arachnids__/graphics/hr-Arachnids-attack-02.png",
            "__Arachnids__/graphics/hr-Arachnids-attack-03.png",
            "__Arachnids__/graphics/hr-Arachnids-attack-04.png"
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
          scale = 0.5 * scale
        }
      },
      {
        filenames =
        {
          "__Arachnids__/graphics/Arachnids-attack-mask1-01.png",
          "__Arachnids__/graphics/Arachnids-attack-mask1-02.png",
          "__Arachnids__/graphics/Arachnids-attack-mask1-03.png",
          "__Arachnids__/graphics/Arachnids-attack-mask1-04.png"
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
            "__Arachnids__/graphics/hr-Arachnids-attack-mask1-01.png",
            "__Arachnids__/graphics/hr-Arachnids-attack-mask1-02.png",
            "__Arachnids__/graphics/hr-Arachnids-attack-mask1-03.png",
            "__Arachnids__/graphics/hr-Arachnids-attack-mask1-04.png"
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
          scale = 0.5 * scale,
          tint = tint1
        }
      },
      {
        filenames =
        {
          "__Arachnids__/graphics/Arachnids-attack-mask2-01.png",
          "__Arachnids__/graphics/Arachnids-attack-mask2-02.png",
          "__Arachnids__/graphics/Arachnids-attack-mask2-03.png",
          "__Arachnids__/graphics/Arachnids-attack-mask2-04.png"
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
            "__Arachnids__/graphics/hr-Arachnids-attack-mask2-01.png",
            "__Arachnids__/graphics/hr-Arachnids-attack-mask2-02.png",
            "__Arachnids__/graphics/hr-Arachnids-attack-mask2-03.png",
            "__Arachnids__/graphics/hr-Arachnids-attack-mask2-04.png"
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
          scale = 0.5 * scale,
          tint = tint2
        }
      },
      {
        filenames =
        {
          "__Arachnids__/graphics/Arachnids-attack-shadow-01.png",
          "__Arachnids__/graphics/Arachnids-attack-shadow-02.png",
          "__Arachnids__/graphics/Arachnids-attack-shadow-03.png",
          "__Arachnids__/graphics/Arachnids-attack-shadow-04.png"
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
        scale = 1.24 * scale,
        draw_as_shadow = true,
        hr_version =
        {
          filenames =
          {
            "__Arachnids__/graphics/hr-Arachnids-attack-shadow-01.png",
            "__Arachnids__/graphics/hr-Arachnids-attack-shadow-02.png",
            "__Arachnids__/graphics/hr-Arachnids-attack-shadow-03.png",
            "__Arachnids__/graphics/hr-Arachnids-attack-shadow-04.png"
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
          scale = 0.62 * scale,
          draw_as_shadow = true
        }
      }
    }
  }
end

local function arachnidsdieanimation(scale, tint1, tint2)
  return
  {
    layers=
    {
      {
        filenames =
        {

		"__Arachnids__/graphics/Arachnids-die-01.png",
		"__Arachnids__/graphics/Arachnids-die-02.png",
		"__Arachnids__/graphics/Arachnids-die-03.png",
		"__Arachnids__/graphics/Arachnids-die-04.png",
		"__Arachnids__/graphics/Arachnids-die-05.png",
		"__Arachnids__/graphics/Arachnids-die-06.png",
		"__Arachnids__/graphics/Arachnids-die-07.png",
		"__Arachnids__/graphics/Arachnids-die-08.png",
		"__Arachnids__/graphics/Arachnids-die-09.png",
		"__Arachnids__/graphics/Arachnids-die-10.png",
		"__Arachnids__/graphics/Arachnids-die-11.png",
		"__Arachnids__/graphics/Arachnids-die-12.png",
		"__Arachnids__/graphics/Arachnids-die-13.png",
		"__Arachnids__/graphics/Arachnids-die-14.png",
		"__Arachnids__/graphics/Arachnids-die-15.png",
		"__Arachnids__/graphics/Arachnids-die-16.png",
		"__Arachnids__/graphics/Arachnids-die-17.png"
		
         
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
            "__Arachnids__/graphics/hr-Arachnids-die-01.png",
            "__Arachnids__/graphics/hr-Arachnids-die-02.png",
            "__Arachnids__/graphics/hr-Arachnids-die-03.png",
            "__Arachnids__/graphics/hr-Arachnids-die-04.png",
            "__Arachnids__/graphics/hr-Arachnids-die-05.png",
            "__Arachnids__/graphics/hr-Arachnids-die-06.png",
            "__Arachnids__/graphics/hr-Arachnids-die-07.png",
            "__Arachnids__/graphics/hr-Arachnids-die-08.png",
            "__Arachnids__/graphics/hr-Arachnids-die-09.png",
            "__Arachnids__/graphics/hr-Arachnids-die-10.png",
            "__Arachnids__/graphics/hr-Arachnids-die-11.png",
            "__Arachnids__/graphics/hr-Arachnids-die-12.png",
            "__Arachnids__/graphics/hr-Arachnids-die-13.png",
            "__Arachnids__/graphics/hr-Arachnids-die-14.png",
            "__Arachnids__/graphics/hr-Arachnids-die-15.png",
            "__Arachnids__/graphics/hr-Arachnids-die-16.png",
            "__Arachnids__/graphics/hr-Arachnids-die-17.png"
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



--[[



      {
        filenames =
        {
          "__base__/graphics/entity/biter/biter-die-mask1-01.png",
          "__base__/graphics/entity/biter/biter-die-mask1-02.png",
          "__base__/graphics/entity/biter/biter-die-mask1-03.png",
          "__base__/graphics/entity/biter/biter-die-mask1-04.png",
          "__base__/graphics/entity/biter/biter-die-mask1-05.png",
          "__base__/graphics/entity/biter/biter-die-mask1-06.png",
          "__base__/graphics/entity/biter/biter-die-mask1-07.png",
          "__base__/graphics/entity/biter/biter-die-mask1-08.png",
          "__base__/graphics/entity/biter/biter-die-mask1-09.png",
          "__base__/graphics/entity/biter/biter-die-mask1-10.png",
          "__base__/graphics/entity/biter/biter-die-mask1-11.png",
          "__base__/graphics/entity/biter/biter-die-mask1-12.png",
          "__base__/graphics/entity/biter/biter-die-mask1-13.png",
          "__base__/graphics/entity/biter/biter-die-mask1-14.png",
          "__base__/graphics/entity/biter/biter-die-mask1-15.png",
          "__base__/graphics/entity/biter/biter-die-mask1-16.png",
          "__base__/graphics/entity/biter/biter-die-mask1-17.png"
        },
        slice = 4,
        lines_per_file = 4,
        flags = { "mask" },
        line_length = 4,
        width = 198,
        height = 166,
        frame_count = 17,
        direction_count = 16,
        --shift = util.mul_shift(util.by_pixel(0, -22), scale),
        scale = scale,
        tint = tint1,
        hr_version =
        {
          filenames =
          {
            "__base__/graphics/entity/biter/hr-biter-die-mask1-01.png",
            "__base__/graphics/entity/biter/hr-biter-die-mask1-02.png",
            "__base__/graphics/entity/biter/hr-biter-die-mask1-03.png",
            "__base__/graphics/entity/biter/hr-biter-die-mask1-04.png",
            "__base__/graphics/entity/biter/hr-biter-die-mask1-05.png",
            "__base__/graphics/entity/biter/hr-biter-die-mask1-06.png",
            "__base__/graphics/entity/biter/hr-biter-die-mask1-07.png",
            "__base__/graphics/entity/biter/hr-biter-die-mask1-08.png",
            "__base__/graphics/entity/biter/hr-biter-die-mask1-09.png",
            "__base__/graphics/entity/biter/hr-biter-die-mask1-10.png",
            "__base__/graphics/entity/biter/hr-biter-die-mask1-11.png",
            "__base__/graphics/entity/biter/hr-biter-die-mask1-12.png",
            "__base__/graphics/entity/biter/hr-biter-die-mask1-13.png",
            "__base__/graphics/entity/biter/hr-biter-die-mask1-14.png",
            "__base__/graphics/entity/biter/hr-biter-die-mask1-15.png",
            "__base__/graphics/entity/biter/hr-biter-die-mask1-16.png",
            "__base__/graphics/entity/biter/hr-biter-die-mask1-17.png"
          },
          slice = 4,
          lines_per_file = 4,
          line_length = 4,
          width = 398,
          height = 328,
          frame_count = 17,
          --shift = util.mul_shift(util.by_pixel(-1, -21), scale),
          direction_count = 16,
          scale = 0.5 * scale,
          tint = tint1
        }
      },
      {
        filenames =
        {
          "__base__/graphics/entity/biter/biter-die-mask2-01.png",
          "__base__/graphics/entity/biter/biter-die-mask2-02.png",
          "__base__/graphics/entity/biter/biter-die-mask2-03.png",
          "__base__/graphics/entity/biter/biter-die-mask2-04.png",
          "__base__/graphics/entity/biter/biter-die-mask2-05.png",
          "__base__/graphics/entity/biter/biter-die-mask2-06.png",
          "__base__/graphics/entity/biter/biter-die-mask2-07.png",
          "__base__/graphics/entity/biter/biter-die-mask2-08.png",
          "__base__/graphics/entity/biter/biter-die-mask2-09.png",
          "__base__/graphics/entity/biter/biter-die-mask2-10.png",
          "__base__/graphics/entity/biter/biter-die-mask2-11.png",
          "__base__/graphics/entity/biter/biter-die-mask2-12.png",
          "__base__/graphics/entity/biter/biter-die-mask2-13.png",
          "__base__/graphics/entity/biter/biter-die-mask2-14.png",
          "__base__/graphics/entity/biter/biter-die-mask2-15.png",
          "__base__/graphics/entity/biter/biter-die-mask2-16.png",
          "__base__/graphics/entity/biter/biter-die-mask2-17.png"
        },
        slice = 4,
        lines_per_file = 4,
        flags = { "mask" },
        line_length = 4,
        width = 200,
        height = 166,
        frame_count = 17,
        direction_count = 16,
        --shift = util.mul_shift(util.by_pixel(-2, -22), scale),
        scale = scale,
        tint = tint2,
        hr_version =
        {
          filenames =
          {
            "__base__/graphics/entity/biter/hr-biter-die-mask2-01.png",
            "__base__/graphics/entity/biter/hr-biter-die-mask2-02.png",
            "__base__/graphics/entity/biter/hr-biter-die-mask2-03.png",
            "__base__/graphics/entity/biter/hr-biter-die-mask2-04.png",
            "__base__/graphics/entity/biter/hr-biter-die-mask2-05.png",
            "__base__/graphics/entity/biter/hr-biter-die-mask2-06.png",
            "__base__/graphics/entity/biter/hr-biter-die-mask2-07.png",
            "__base__/graphics/entity/biter/hr-biter-die-mask2-08.png",
            "__base__/graphics/entity/biter/hr-biter-die-mask2-09.png",
            "__base__/graphics/entity/biter/hr-biter-die-mask2-10.png",
            "__base__/graphics/entity/biter/hr-biter-die-mask2-11.png",
            "__base__/graphics/entity/biter/hr-biter-die-mask2-12.png",
            "__base__/graphics/entity/biter/hr-biter-die-mask2-13.png",
            "__base__/graphics/entity/biter/hr-biter-die-mask2-14.png",
            "__base__/graphics/entity/biter/hr-biter-die-mask2-15.png",
            "__base__/graphics/entity/biter/hr-biter-die-mask2-16.png",
            "__base__/graphics/entity/biter/hr-biter-die-mask2-17.png"
          },
          slice = 4,
          lines_per_file = 4,
          line_length = 4,
          width = 396,
          height = 330,
          frame_count = 17,
          --shift = util.mul_shift(util.by_pixel(-1, -22), scale),
          direction_count = 16,
          scale = 0.5 * scale,
          tint = tint2
        }
      },



 --]]



      {
        filenames =
        {

          	"__Arachnids__/graphics/Arachnids-die-shadow-01.png",
		"__Arachnids__/graphics/Arachnids-die-shadow-02.png",
		"__Arachnids__/graphics/Arachnids-die-shadow-03.png",
		"__Arachnids__/graphics/Arachnids-die-shadow-04.png",
		"__Arachnids__/graphics/Arachnids-die-shadow-05.png",
		"__Arachnids__/graphics/Arachnids-die-shadow-06.png",
		"__Arachnids__/graphics/Arachnids-die-shadow-07.png",
		"__Arachnids__/graphics/Arachnids-die-shadow-08.png",
		"__Arachnids__/graphics/Arachnids-die-shadow-09.png",
		"__Arachnids__/graphics/Arachnids-die-shadow-10.png",
		"__Arachnids__/graphics/Arachnids-die-shadow-11.png",
		"__Arachnids__/graphics/Arachnids-die-shadow-12.png",
		"__Arachnids__/graphics/Arachnids-die-shadow-13.png",
		"__Arachnids__/graphics/Arachnids-die-shadow-14.png",
		"__Arachnids__/graphics/Arachnids-die-shadow-15.png",
		"__Arachnids__/graphics/Arachnids-die-shadow-16.png",
		"__Arachnids__/graphics/Arachnids-die-shadow-17.png"
		
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
            "__Arachnids__/graphics/hr-Arachnids-die-shadow-01.png",
            "__Arachnids__/graphics/hr-Arachnids-die-shadow-02.png",
            "__Arachnids__/graphics/hr-Arachnids-die-shadow-03.png",
            "__Arachnids__/graphics/hr-Arachnids-die-shadow-04.png",
            "__Arachnids__/graphics/hr-Arachnids-die-shadow-05.png",
            "__Arachnids__/graphics/hr-Arachnids-die-shadow-06.png",
            "__Arachnids__/graphics/hr-Arachnids-die-shadow-07.png",
            "__Arachnids__/graphics/hr-Arachnids-die-shadow-08.png",
            "__Arachnids__/graphics/hr-Arachnids-die-shadow-09.png",
            "__Arachnids__/graphics/hr-Arachnids-die-shadow-10.png",
            "__Arachnids__/graphics/hr-Arachnids-die-shadow-11.png",
            "__Arachnids__/graphics/hr-Arachnids-die-shadow-12.png",
            "__Arachnids__/graphics/hr-Arachnids-die-shadow-13.png",
            "__Arachnids__/graphics/hr-Arachnids-die-shadow-14.png",
            "__Arachnids__/graphics/hr-Arachnids-die-shadow-15.png",
            "__Arachnids__/graphics/hr-Arachnids-die-shadow-16.png",
            "__Arachnids__/graphics/hr-Arachnids-die-shadow-17.png"
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

----------------------------------

function unitUtils.biterdieanimation(scale, tint1, tint2, altBiter)
    if (altBiter == "armored") and mods["ArmouredBiters"] then
        return armoredDieBiter(scale, tint1, tint2)
    elseif (altBiter == "arachnid") and mods["Arachnids"] then
        return arachnidsdieanimation(scale, tint1, tint2)
    else
        return vanillaDieBiter(scale, tint1, tint2)
    end
end

function unitUtils.biterattackanimation(scale, tint1, tint2, altBiter)
    if (altBiter == "armored") and mods["ArmouredBiters"] then
        return armoredAttackBiter(scale, tint1, tint2)
    elseif (altBiter == "arachnid") and mods["Arachnids"] then
		return arachnidsattackanimation(scale, tint1, tint2)
    else
        return vanillaAttackBiter(scale, tint1, tint2)
    end
end


function unitUtils.biterrunanimation(scale, tint1, tint2, altBiter)
    if (altBiter == "armored") and mods["ArmouredBiters"] then
        return armoredRunBiter(scale, tint1, tint2)
    elseif (altBiter == "arachnid") and mods["Arachnids"] then
        return arachnidsrunanimation(scale, tint1, tint2)
    else
        return vanillaRunBiter(scale, tint1, tint2)
    end
end


return unitUtils
