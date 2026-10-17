local led_blend_mode = nil

return
{
  light = {intensity = 0.5, size = 3, color = {r = 1.0, g = 1.0, b = 1.0}},
  picture =
  {
    north = { layers = {
        {
          filename = "__BigLight__/graphics/entity/train-stop/jaune/train-stop-north-light-1.png",
          width = 9,
          height = 5,
          frame_count = 1,
          shift = util.by_pixel(-70.5, -44.5),
          --[[ hr_version =
          {
            filename = "__BigLight__/graphics/entity/train-stop/jaune/hr-train-stop-north-light-1.png",
            width = 17,
            height = 9,
            frame_count = 1,
            shift = util.by_pixel(-70.75, -44.25),
            scale = 0.5
            } ]]
        },
        {
          filename = "__BigLight__/graphics/entity/train-stop/hr-N-light.png",
          width = 20,
          height = 20,
          blend_mode = led_blend_mode,
          tint = {1,1,0,0.5},
          shift = util.by_pixel(-70.5, -44.5),
          scale = 0.5,
          --[[ hr_version =
          {
            filename = "__BigLight__/graphics/entity/train-stop/hr-N-light.png",
            width = 20,
            height = 20,
            blend_mode = led_blend_mode,
            tint = {1,1,0,0.5},
            shift = util.by_pixel(-70.75, -44.25),
            scale = 1,
          } ]]
        }
    }},
    west = { layers = {
      {
        filename = "__BigLight__/graphics/entity/train-stop/jaune/train-stop-east-light-1.png",
        width = 3,
        height = 9,
        frame_count = 1,
        shift = util.by_pixel(34.5, 19.5),
        --[[ hr_version =
        {
          filename = "__BigLight__/graphics/entity/train-stop/jaune/hr-train-stop-east-light-1.png",
          width = 6,
          height = 16,
          frame_count = 1,
          shift = util.by_pixel(34.5, 19.5),
          scale = 0.5
          } ]]
      },
      {
        filename = "__BigLight__/graphics/entity/train-stop/hr-E-light.png",
        width = 20,
        height = 20,
        blend_mode = led_blend_mode,
        tint = {1,1,0,0.5},
        shift = util.by_pixel(34.5, 19.5),
        scale = 0.5,
        --[[ hr_version =
        {
          filename = "__BigLight__/graphics/entity/train-stop/hr-E-light.png",
          width = 20,
          height = 20,
          blend_mode = led_blend_mode,
          tint = {1,1,0,0.5},
          shift = util.by_pixel(34.5, 19.5),
          scale = 1,
        } ]]
      }
    }},
    south = { layers = {
      {
        filename = "__BigLight__/graphics/entity/train-stop/jaune/train-stop-south-light-1.png",
        width = 8,
        height = 2,
        frame_count = 1,
        shift = util.by_pixel(70, -95),
        --[[ hr_version =
        {
          filename = "__BigLight__/graphics/entity/train-stop/jaune/hr-train-stop-south-light-1.png",
          width = 16,
          height = 4,
          frame_count = 1,
          shift = util.by_pixel(70, -95),
          scale = 0.5
          } ]]
      },
      {
        filename = "__BigLight__/graphics/entity/train-stop/hr-S-light.png",
        width = 20,
        height = 20,
        blend_mode = led_blend_mode,
        tint = {1,1,0,0.5},
        shift = util.by_pixel(70, -95),
        scale = 0.5,
        --[[ hr_version =
        {
          filename = "__BigLight__/graphics/entity/train-stop/hr-S-light.png",
          width = 20,
          height = 20,
          blend_mode = led_blend_mode,
          tint = {1,1,0,0.5},
          shift = util.by_pixel(70, -95),
          scale = 1,
        } ]]
      }
    }},
    east = { layers = {
      {
        filename = "__BigLight__/graphics/entity/train-stop/jaune/train-stop-west-light-1.png",
        width = 3,
        height = 8,
        frame_count = 1,
        shift = util.by_pixel(-30.5, -112),
        --[[ hr_version =
        {
          filename = "__BigLight__/graphics/entity/train-stop/jaune/hr-train-stop-west-light-1.png",
          width = 6,
          height = 16,
          frame_count = 1,
          shift = util.by_pixel(-30.5, -112),
          scale = 0.5
          } ]]
      },
      {
        filename = "__BigLight__/graphics/entity/train-stop/hr-W-light.png",
        width = 20,
        height = 20,
        blend_mode = led_blend_mode,
        tint = {1,1,0,0.5},
        shift = util.by_pixel(-30.5, -112),
        scale = 0.5,
        --[[ hr_version =
        {
          filename = "__BigLight__/graphics/entity/train-stop/hr-W-light.png",
          width = 20,
          height = 20,
          blend_mode = led_blend_mode,
          tint = {1,1,0,0.5},
          shift = util.by_pixel(-30.5, -112),
          scale = 1,
        } ]]
      }
    }}
  },
  red_picture =
  {
    north = { layers = {
      {
        filename = "__base__/graphics/entity/train-stop/train-stop-north-red-light-1.png",
        width = 9,
        height = 5,
        frame_count = 1,
        shift = util.by_pixel(-70.5, -44.5),
        --[[ hr_version =
        {
          filename = "__base__/graphics/entity/train-stop/hr-train-stop-north-red-light-1.png",
          width = 17,
          height = 9,
          frame_count = 1,
          shift = util.by_pixel(-70.75, -44.25),
          scale = 0.5
          } ]]
      },
      {
        filename = "__BigLight__/graphics/entity/train-stop/hr-N-light.png",
        width = 20,
        height = 20,
        blend_mode = led_blend_mode,
        tint = {1,0,0,0.5},
        shift = util.by_pixel(-70.5, -44.5),
        scale = 0.5,
        --[[ hr_version =
        {
          filename = "__BigLight__/graphics/entity/train-stop/hr-N-light.png",
          width = 20,
          height = 20,
          blend_mode = led_blend_mode,
          tint = {1,0,0,0.5},
          shift = util.by_pixel(-70.75, -44.25),
          scale = 1,
        } ]]
      }
    }},
    west = { layers = {
      {
        filename = "__base__/graphics/entity/train-stop/train-stop-east-red-light-1.png",
        width = 3,
        height = 9,
        frame_count = 1,
        shift = util.by_pixel(34.5, 19.5),
        --[[ hr_version =
        {
          filename = "__base__/graphics/entity/train-stop/hr-train-stop-east-red-light-1.png",
          width = 6,
          height = 16,
          frame_count = 1,
          shift = util.by_pixel(34.5, 19.5),
          scale = 0.5
          } ]]
      },
      {
        filename = "__BigLight__/graphics/entity/train-stop/hr-E-light.png",
        width = 20,
        height = 20,
        blend_mode = led_blend_mode,
        tint = {1,0,0,0.5},
        shift = util.by_pixel(34.5, 19.5),
        scale = 0.5,
        --[[ hr_version =
        {
          filename = "__BigLight__/graphics/entity/train-stop/hr-E-light.png",
          width = 20,
          height = 20,
          blend_mode = led_blend_mode,
          tint = {1,0,0,0.5},
          shift = util.by_pixel(34.5, 19.5),
          scale = 1,
        } ]]
      }
    }},
    south = { layers = {
      {
        filename = "__base__/graphics/entity/train-stop/train-stop-south-red-light-1.png",
        width = 8,
        height = 2,
        frame_count = 1,
        shift = util.by_pixel(70, -95),
        --[[ hr_version =
        {
          filename = "__base__/graphics/entity/train-stop/hr-train-stop-south-red-light-1.png",
          width = 16,
          height = 4,
          frame_count = 1,
          shift = util.by_pixel(70, -95),
          scale = 0.5
          } ]]
      },
      {
        filename = "__BigLight__/graphics/entity/train-stop/hr-S-light.png",
        width = 20,
        height = 20,
        blend_mode = led_blend_mode,
        tint = {1,0,0,0.5},
        shift = util.by_pixel(70, -95),
        scale = 0.5,
        --[[ hr_version =
        {
          filename = "__BigLight__/graphics/entity/train-stop/hr-S-light.png",
          width = 20,
          height = 20,
          blend_mode = led_blend_mode,
          tint = {1,0,0,0.5},
          shift = util.by_pixel(70, -95),
          scale = 1,
        } ]]
      }
    }},
    east = { layers = {
      {
        filename = "__base__/graphics/entity/train-stop/train-stop-west-red-light-1.png",
        width = 3,
        height = 8,
        frame_count = 1,
        shift = util.by_pixel(-30.5, -112),
        --[[ hr_version =
        {
          filename = "__base__/graphics/entity/train-stop/hr-train-stop-west-red-light-1.png",
          width = 6,
          height = 16,
          frame_count = 1,
          shift = util.by_pixel(-30.5, -112),
          scale = 0.5
          } ]]
      },
      {
        filename = "__BigLight__/graphics/entity/train-stop/hr-W-light.png",
        width = 20,
        height = 20,
        blend_mode = led_blend_mode,
        tint = {1,0,0,0.5},
        shift = util.by_pixel(-30.5, -112),
        scale = 0.5,
        --[[ hr_version =
        {
          filename = "__BigLight__/graphics/entity/train-stop/hr-W-light.png",
          width = 20,
          height = 20,
          blend_mode = led_blend_mode,
          tint = {1,0,0,0.5},
          shift = util.by_pixel(-30.5, -112),
          scale = 1,
        } ]]
      }
    }}
  }
}