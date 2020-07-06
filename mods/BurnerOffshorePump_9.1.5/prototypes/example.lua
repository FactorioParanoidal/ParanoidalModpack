-- not connected


code:

		{
          priority = "low",
          width = 100,
          height = 75,
          frame_count = 2,
          apply_runtime_tint = true,
          direction_count = 64,
          max_advance = 0.2,
          line_length = 2,
          shift = {0, -0.171875},
          stripes = util.multiplystripes(2,
          {
            {
              filename = "__base__/graphics/entity/car/car-mask-1.png",
              width_in_frames = 1,
              height_in_frames = 22
            },
            {
              filename = "__base__/graphics/entity/car/car-mask-2.png",
              width_in_frames = 1,
              height_in_frames = 22
            },
            {
              filename = "__base__/graphics/entity/car/car-mask-3.png",
              width_in_frames = 1,
              height_in_frames = 20
            }
          }),
          hr_version =
          {
            priority = "low",
            width = 199,
            height = 147,
            frame_count = 2,
            apply_runtime_tint = true,
            scale = 0.5,
            axially_symmetrical = false,
            direction_count = 64,
            max_advance = 0.2,
            shift = util.by_pixel(0+2, -11+8.5),
            line_length = 1,
            stripes = util.multiplystripes(2,
            {
              {
                filename = "__base__/graphics/entity/car/hr-car-mask-1.png",
                width_in_frames = 1,
                height_in_frames = 13
              },
              {
                filename = "__base__/graphics/entity/car/hr-car-mask-2.png",
                width_in_frames = 1,
                height_in_frames = 13
              },
              {
                filename = "__base__/graphics/entity/car/hr-car-mask-3.png",
                width_in_frames = 1,
                height_in_frames = 13
              },
              {
                filename = "__base__/graphics/entity/car/hr-car-mask-4.png",
                width_in_frames = 1,
                height_in_frames = 13
              },
              {
                filename = "__base__/graphics/entity/car/hr-car-mask-5.png",
                width_in_frames = 1,
                height_in_frames = 12
              }
            })
          }
        },
		

result:

data.raw.car.car.animation.layers[2].priority = "low"
data.raw.car.car.animation.layers[2].width = 100
data.raw.car.car.animation.layers[2].height = 75
data.raw.car.car.animation.layers[2].frame_count = 2
data.raw.car.car.animation.layers[2].apply_runtime_tint = true
data.raw.car.car.animation.layers[2].direction_count = 64
data.raw.car.car.animation.layers[2].max_advance = 0.2
data.raw.car.car.animation.layers[2].line_length = 2
data.raw.car.car.animation.layers[2].shift = {0, -0.171875}
data.raw.car.car.animation.layers[2].stripes[1] = {filename = "__base__/graphics/entity/car/car-mask-1.png", width_in_frames = 1, height_in_frames = 22}
data.raw.car.car.animation.layers[2].stripes[2] = {filename = "__base__/graphics/entity/car/car-mask-1.png", width_in_frames = 1, height_in_frames = 22}
data.raw.car.car.animation.layers[2].stripes[3] = {filename = "__base__/graphics/entity/car/car-mask-2.png", width_in_frames = 1, height_in_frames = 22}
data.raw.car.car.animation.layers[2].stripes[4] = {filename = "__base__/graphics/entity/car/car-mask-2.png", width_in_frames = 1, height_in_frames = 22}
data.raw.car.car.animation.layers[2].stripes[5] = {filename = "__base__/graphics/entity/car/car-mask-3.png", width_in_frames = 1, height_in_frames = 20}
data.raw.car.car.animation.layers[2].stripes[6] = {filename = "__base__/graphics/entity/car/car-mask-3.png", width_in_frames = 1, height_in_frames = 20}
data.raw.car.car.animation.layers[2].hr_version.priority = "low"
data.raw.car.car.animation.layers[2].hr_version.width = 199
data.raw.car.car.animation.layers[2].hr_version.height = 147
data.raw.car.car.animation.layers[2].hr_version.frame_count = 2
data.raw.car.car.animation.layers[2].hr_version.apply_runtime_tint = true
data.raw.car.car.animation.layers[2].hr_version.scale = 0.5
data.raw.car.car.animation.layers[2].hr_version.axially_symmetrical = false
data.raw.car.car.animation.layers[2].hr_version.direction_count = 64
data.raw.car.car.animation.layers[2].hr_version.max_advance = 0.2
data.raw.car.car.animation.layers[2].hr_version.shift = {0.0625, -0.078125}
data.raw.car.car.animation.layers[2].hr_version.line_length = 1
data.raw.car.car.animation.layers[2].hr_version.stripes[1] = {filename = "__base__/graphics/entity/car/hr-car-mask-1.png", width_in_frames = 1, height_in_frames = 13}
data.raw.car.car.animation.layers[2].hr_version.stripes[2] = {filename = "__base__/graphics/entity/car/hr-car-mask-1.png", width_in_frames = 1, height_in_frames = 13}
data.raw.car.car.animation.layers[2].hr_version.stripes[3] = {filename = "__base__/graphics/entity/car/hr-car-mask-2.png", width_in_frames = 1, height_in_frames = 13}
data.raw.car.car.animation.layers[2].hr_version.stripes[4] = {filename = "__base__/graphics/entity/car/hr-car-mask-2.png", width_in_frames = 1, height_in_frames = 13}
data.raw.car.car.animation.layers[2].hr_version.stripes[5] = {filename = "__base__/graphics/entity/car/hr-car-mask-3.png", width_in_frames = 1, height_in_frames = 13}
data.raw.car.car.animation.layers[2].hr_version.stripes[6] = {filename = "__base__/graphics/entity/car/hr-car-mask-3.png", width_in_frames = 1, height_in_frames = 13}
data.raw.car.car.animation.layers[2].hr_version.stripes[7] = {filename = "__base__/graphics/entity/car/hr-car-mask-4.png", width_in_frames = 1, height_in_frames = 13}
data.raw.car.car.animation.layers[2].hr_version.stripes[8] = {filename = "__base__/graphics/entity/car/hr-car-mask-4.png", width_in_frames = 1, height_in_frames = 13}
data.raw.car.car.animation.layers[2].hr_version.stripes[9] = {filename = "__base__/graphics/entity/car/hr-car-mask-5.png", width_in_frames = 1, height_in_frames = 12}
data.raw.car.car.animation.layers[2].hr_version.stripes[10] = {filename = "__base__/graphics/entity/car/hr-car-mask-5.png", width_in_frames = 1, height_in_frames = 12}