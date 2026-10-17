return
{
  light = {intensity = 0.5, size = 3, color = {r = 1.0, g = 1.0, b = 1.0}},
  picture =
  {
    north = { layers = {
      {
        filename = "__BigLight__/graphics/entity/train-stop/vert/train-stop-north-light-2.png",
        width = 9,
        height = 5,
        frame_count = 1,
        shift = util.by_pixel(-57.5, -43.5),
        --[[ hr_version =
        {
          filename = "__BigLight__/graphics/entity/train-stop/vert/hr-train-stop-north-light-2.png",
          width = 16,
          height = 9,
          frame_count = 1,
          shift = util.by_pixel(-57.5, -43.75),
          scale = 0.5
          } ]]
      },
      {
        filename = "__BigLight__/graphics/entity/train-stop/hr-N-light.png",
        width = 20,
        height = 20,
        blend_mode = led_blend_mode,
        tint = {0,1,0,0.5},
        shift = util.by_pixel(-57.5, -43.5),
        scale = 0.5,
        --[[ hr_version =
        {
          filename = "__BigLight__/graphics/entity/train-stop/hr-N-light.png",
          width = 20,
          height = 20,
          blend_mode = led_blend_mode,
          tint = {0,1,0,0.5},
          shift = util.by_pixel(-57.5, -43.75),
          scale = 1,
        } ]]
      }
    }},
    west = { layers = {
      {
        filename = "__BigLight__/graphics/entity/train-stop/vert/train-stop-east-light-2.png",
        width = 3,
        height = 8,
        frame_count = 1,
        shift = util.by_pixel(34.5, 10),
        --[[ hr_version =
        {
          filename = "__BigLight__/graphics/entity/train-stop/vert/hr-train-stop-east-light-2.png",
          width = 6,
          height = 16,
          frame_count = 1,
          shift = util.by_pixel(34.5, 10),
          scale = 0.5
          } ]]
      },
      {
        filename = "__BigLight__/graphics/entity/train-stop/hr-N-light.png",
        width = 20,
        height = 20,
        blend_mode = led_blend_mode,
        tint = {0,1,0,0.5},
        shift = util.by_pixel(34.5, 10),
        scale = 0.5,
        --[[ hr_version =
        {
          filename = "__BigLight__/graphics/entity/train-stop/hr-N-light.png",
          width = 20,
          height = 20,
          blend_mode = led_blend_mode,
          tint = {0,1,0,0.5},
          shift = util.by_pixel(34.5, 10),
          scale = 1,
        } ]]
      }
    }},
    south = { layers = {
      {
        filename = "__BigLight__/graphics/entity/train-stop/vert/train-stop-south-light-2.png",
        width = 8,
        height = 3,
        frame_count = 1,
        shift = util.by_pixel(57, -94.5),
        --[[ hr_version =
        {
          filename = "__BigLight__/graphics/entity/train-stop/vert/hr-train-stop-south-light-2.png",
          width = 16,
          height = 5,
          frame_count = 1,
          shift = util.by_pixel(57, -94.75),
          scale = 0.5
          } ]]
      },
      {
        filename = "__BigLight__/graphics/entity/train-stop/hr-N-light.png",
        width = 20,
        height = 20,
        blend_mode = led_blend_mode,
        tint = {0,1,0,0.5},
        shift = util.by_pixel(57, -94.5),
        scale = 0.5,
        --[[ hr_version =
        {
          filename = "__BigLight__/graphics/entity/train-stop/hr-N-light.png",
          width = 20,
          height = 20,
          blend_mode = led_blend_mode,
          tint = {0,1,0,0.5},
          shift = util.by_pixel(57, -94.75),
          scale = 1,
        } ]]
      }
    }},
    east = { layers = {
      {
        filename = "__BigLight__/graphics/entity/train-stop/vert/train-stop-west-light-2.png",
        width = 4,
        height = 8,
        frame_count = 1,
        shift = util.by_pixel(-31, -103),
        --[[ hr_version =
        {
          filename = "__BigLight__/graphics/entity/train-stop/vert/hr-train-stop-west-light-2.png",
          width = 7,
          height = 15,
          frame_count = 1,
          shift = util.by_pixel(-30.75, -102.75),
          scale = 0.5
          } ]]
      },
      {
        filename = "__BigLight__/graphics/entity/train-stop/hr-N-light.png",
        width = 20,
        height = 20,
        blend_mode = led_blend_mode,
        tint = {0,1,0,0.5},
        shift = util.by_pixel(-31, -103),
        scale = 0.5,
        --[[ hr_version =
        {
          filename = "__BigLight__/graphics/entity/train-stop/hr-N-light.png",
          width = 20,
          height = 20,
          blend_mode = led_blend_mode,
          tint = {0,1,0,0.5},
          shift = util.by_pixel(-30.75, -102.75),
          scale = 1,
        } ]]
      }
    }}
  },
  red_picture =
  {
    north = { layers = {
      {
        filename = "__base__/graphics/entity/train-stop/train-stop-north-red-light-2.png",
        width = 9,
        height = 5,
        frame_count = 1,
        shift = util.by_pixel(-57.5, -43.5),
        --[[ hr_version =
        {
          filename = "__base__/graphics/entity/train-stop/hr-train-stop-north-red-light-2.png",
          width = 16,
          height = 9,
          frame_count = 1,
          shift = util.by_pixel(-57.5, -43.75),
          scale = 0.5
          } ]]
      },
      {
        filename = "__BigLight__/graphics/entity/train-stop/hr-N-light.png",
        width = 20,
        height = 20,
        blend_mode = led_blend_mode,
        tint = {1,0,0,0.5},
        shift = util.by_pixel(-57.5, -43.5),
        scale = 0.5,
        --[[ hr_version =
        {
          filename = "__BigLight__/graphics/entity/train-stop/hr-N-light.png",
          width = 20,
          height = 20,
          blend_mode = led_blend_mode,
          tint = {1,0,0,0.5},
          shift = util.by_pixel(-57.5, -43.75),
          scale = 1,
        } ]]
      }
    }},
    west = { layers = {
      {
        filename = "__base__/graphics/entity/train-stop/train-stop-east-red-light-2.png",
        width = 3,
        height = 8,
        frame_count = 1,
        shift = util.by_pixel(34.5, 10),
        --[[ hr_version =
        {
          filename = "__base__/graphics/entity/train-stop/hr-train-stop-east-red-light-2.png",
          width = 6,
          height = 16,
          frame_count = 1,
          shift = util.by_pixel(34.5, 10),
          scale = 0.5
          } ]]
      },
      {
        filename = "__BigLight__/graphics/entity/train-stop/hr-N-light.png",
        width = 20,
        height = 20,
        blend_mode = led_blend_mode,
        tint = {1,0,0,0.5},
        shift = util.by_pixel(34.5, 10),
        scale = 0.5,
        --[[ hr_version =
        {
          filename = "__BigLight__/graphics/entity/train-stop/hr-N-light.png",
          width = 20,
          height = 20,
          blend_mode = led_blend_mode,
          tint = {1,0,0,0.5},
          shift = util.by_pixel(34.5, 10),
          scale = 1,
        } ]]
      }
    }},
    south = { layers = {
      {
        filename = "__base__/graphics/entity/train-stop/train-stop-south-red-light-2.png",
        width = 8,
        height = 3,
        frame_count = 1,
        shift = util.by_pixel(57, -94.5),
        --[[ hr_version =
        {
          filename = "__base__/graphics/entity/train-stop/hr-train-stop-south-red-light-2.png",
          width = 16,
          height = 5,
          frame_count = 1,
          shift = util.by_pixel(57, -94.75),
          scale = 0.5
          } ]]
      },
      {
        filename = "__BigLight__/graphics/entity/train-stop/hr-N-light.png",
        width = 20,
        height = 20,
        blend_mode = led_blend_mode,
        tint = {1,0,0,0.5},
        shift = util.by_pixel(57, -94.5),
        scale = 0.5,
        --[[ hr_version =
        {
          filename = "__BigLight__/graphics/entity/train-stop/hr-N-light.png",
          width = 20,
          height = 20,
          blend_mode = led_blend_mode,
          tint = {1,0,0,0.5},
          shift = util.by_pixel(57, -94.75),
          scale = 1,
        } ]]
      }
    }},
    east = { layers = {
      {
        filename = "__base__/graphics/entity/train-stop/train-stop-west-red-light-2.png",
        width = 4,
        height = 8,
        frame_count = 1,
        shift = util.by_pixel(-31, -103),
        --[[ hr_version =
        {
          filename = "__base__/graphics/entity/train-stop/hr-train-stop-west-red-light-2.png",
          width = 7,
          height = 15,
          frame_count = 1,
          shift = util.by_pixel(-30.75, -102.75),
          scale = 0.5
          } ]]
      },
      {
        filename = "__BigLight__/graphics/entity/train-stop/hr-N-light.png",
        width = 20,
        height = 20,
        blend_mode = led_blend_mode,
        tint = {1,0,0,0.5},
        shift = util.by_pixel(-31, -103),
        scale = 0.5,
        --[[ hr_version =
        {
          filename = "__BigLight__/graphics/entity/train-stop/hr-N-light.png",
          width = 20,
          height = 20,
          blend_mode = led_blend_mode,
          tint = {1,0,0,0.5},
          shift = util.by_pixel(-30.75, -102.75),
          scale = 1,
        } ]]
      }
    }}
  }
}