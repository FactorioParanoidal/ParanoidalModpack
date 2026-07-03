local beam_blend_mode = "additive"
local beam_non_light_flags = { "trilinear-filtering" }


local path = util.path("data/entities/repair_turret/grey_beams/")

function attach_beam_graphics(beam_table, blend_mode, beam_flags, beam_tint, light_tint)
  beam_table.start =
  {
    filename = path.."tileable-beam-START-wtf.png",
    flags = beam_flags or beam_non_light_flags,
    line_length = 4,
    width = 52,
    height = 40,
    frame_count = 16,
    direction_count = 1,
    shift = {-0.03125, 0},
    tint = beam_tint,
    hr_version =
    {
      filename = path.."hr-tileable-beam-START-wtf.png",
      flags = beam_flags or beam_non_light_flags,
      line_length = 4,
      width = 94,
      height = 66,
      frame_count = 16,
      direction_count = 1,
      shift = {0.53125, 0},
      tint = beam_tint,
      scale = 0.5
    }
  }

  beam_table.ending =
  {
    filename = path.."tileable-beam-END-wtf.png",
    flags = beam_flags or beam_non_light_flags,
    line_length = 4,
    width = 49,
    height = 54,
    frame_count = 16,
    direction_count = 1,
    shift = {-0.046875, 0},
    tint = beam_tint,
    hr_version =
    {
      filename = path.."hr-tileable-beam-END-wtf.png",
      flags = beam_flags or beam_non_light_flags,
      line_length = 4,
      width = 91,
      height = 93,
      frame_count = 16,
      direction_count = 1,
      shift = {-0.078125, -0.046875},
      tint = beam_tint,
      scale = 0.5
    }
  }

  beam_table.head =
  {
    filename = path.."beam-head-wtf.png",
    flags = beam_flags or beam_non_light_flags,
    line_length = 16,
    width = 45 - 7,
    height = 39,
    frame_count = 16,
    shift = util.by_pixel(-7/2, 0),
    tint = beam_tint,
    blend_mode = blend_mode or beam_blend_mode
  }

  beam_table.tail =
  {
    filename = path.."beam-tail-wtf.png",
    flags = beam_flags or beam_non_light_flags,
    line_length = 16,
    width = 45 - 6,
    height = 39,
    frame_count = 16,
    shift = util.by_pixel(6/2, 0),
    tint = beam_tint,
    blend_mode = blend_mode or beam_blend_mode
  }

  beam_table.body =
  {
    {
      filename = path.."beam-body-1-wtf.png",
      flags = beam_flags or beam_non_light_flags,
      line_length = 16,
      width = 32,
      height = 39,
      frame_count = 16,
      tint = beam_tint,
      blend_mode = blend_mode or beam_blend_mode
    },
    {
      filename = path.."beam-body-2-wtf.png",
      flags = beam_flags or beam_non_light_flags,
      line_length = 16,
      width = 32,
      height = 39,
      frame_count = 16,
      blend_mode = blend_mode or beam_blend_mode
    },
    {
      filename = path.."beam-body-3-wtf.png",
      flags = beam_flags or beam_non_light_flags,
      line_length = 16,
      width = 32,
      height = 39,
      frame_count = 16,
      blend_mode = blend_mode or beam_blend_mode
    },
    {
      filename = path.."beam-body-4-wtf.png",
      flags = beam_flags or beam_non_light_flags,
      line_length = 16,
      width = 32,
      height = 39,
      frame_count = 16,
      blend_mode = blend_mode or beam_blend_mode
    },
    {
      filename = path.."beam-body-5-wtf.png",
      flags = beam_flags or beam_non_light_flags,
      line_length = 16,
      width = 32,
      height = 39,
      frame_count = 16,
      blend_mode = blend_mode or beam_blend_mode
    },
    {
      filename = path.."beam-body-6-wtf.png",
      flags = beam_flags or beam_non_light_flags,
      line_length = 16,
      width = 32,
      height = 39,
      frame_count = 16,
      blend_mode = blend_mode or beam_blend_mode
    }
  }

  beam_table.light_animations =
  {
    start =
    {
      filename = path.."hr-tileable-beam-START-light-wtf.png",
      line_length = 4,
      width = 94,
      height = 66,
      frame_count = 16,
      direction_count = 1,
      shift = {0.53125, 0},
      scale = 0.5,
      tint = light_tint
    },

    ending =
    {
      filename = path.."hr-tileable-beam-END-light-wtf.png",
      line_length = 4,
      width = 91,
      height = 93,
      frame_count = 16,
      direction_count = 1,
      shift = {-0.078125, -0.046875},
      scale = 0.5,
      tint = light_tint
    },

    head =
    {
      filename = path.."beam-head-light-wtf.png",
      line_length = 16,
      width = 45 - 7,
      height = 39,
      frame_count = 16,
      shift = util.by_pixel(-7/2, 0),
      tint = light_tint
    },

    tail =
    {
      filename = path.."beam-tail-light-wtf.png",
      line_length = 16,
      width = 45 - 6,
      height = 39,
      shift = util.by_pixel(6/2, 0),
      frame_count = 16,
      tint = light_tint
    },

    body =
    {
      {
        filename = path.."beam-body-1-light-wtf.png",
        line_length = 16,
        width = 32,
        height = 39,
        frame_count = 16,
        tint = light_tint
      },
      {
        filename = path.."beam-body-2-light-wtf.png",
        line_length = 16,
        width = 32,
        height = 39,
        frame_count = 16,
        tint = light_tint
      },
      {
        filename = path.."beam-body-3-light-wtf.png",
        line_length = 16,
        width = 32,
        height = 39,
        frame_count = 16,
        tint = light_tint
      },
      {
        filename = path.."beam-body-4-light-wtf.png",
        line_length = 16,
        width = 32,
        height = 39,
        frame_count = 16,
        tint = light_tint
      },
      {
        filename = path.."beam-body-5-light-wtf.png",
        line_length = 16,
        width = 32,
        height = 39,
        frame_count = 16,
        tint = light_tint
      },
      {
        filename = path.."beam-body-6-light-wtf.png",
        line_length = 16,
        width = 32,
        height = 39,
        frame_count = 16,
        tint = light_tint
      }
    }
  }

  return beam_table
end

return attach_beam_graphics