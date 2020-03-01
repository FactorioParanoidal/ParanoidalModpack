if data.raw["construction-robot"]["bob-construction-robot-2"] then
bobicon("construction-robot","construction-robot",1,1,0)
bobicon("bob-construction-robot","construction-robot",2,5,0)
end

if data.raw["logistic-robot"]["bob-logistic-robot-2"] then
bobicon("logistic-robot","logistic-robot",1,1,0)
bobicon("bob-logistic-robot","logistic-robot",2,5,0)
end

local constr = {"construction-robot","bob-construction-robot-2","bob-construction-robot-3","bob-construction-robot-4","bob-construction-robot-5"}
local logis = {"logistic-robot","bob-logistic-robot-2","bob-logistic-robot-3","bob-logistic-robot-4","bob-logistic-robot-5"}

for mk = 1,5 do
	local entity = data.raw["construction-robot"][constr[mk]]
	if not entity then goto skip end
	log(entity.name.."  zz44")
	entity.idle =
    {
      filename = "__ShinyBobGFX__/graphics/entity/robots/construction-robot-"..mk..".png",
      priority = "high",
      line_length = 16,
      width = 32,
      height = 36,
      frame_count = 1,
      shift = {0, -0.15625},
      direction_count = 16,
      hr_version = {
        filename = "__ShinyBobGFX__/graphics/entity/robots/hr-construction-robot-"..mk..".png",
        priority = "high",
        line_length = 16,
        width = 66,
        height = 76,
        frame_count = 1,
        shift = util.by_pixel(0,-4.5),
        direction_count = 16,
        scale = 0.5
      }
    }
	entity.in_motion =
    {
      filename = "__ShinyBobGFX__/graphics/entity/robots/construction-robot-"..mk..".png",
      priority = "high",
      line_length = 16,
      width = 32,
      height = 36,
      frame_count = 1,
      shift = {0, -0.15625},
      direction_count = 16,
      y = 36,
      hr_version = {
        filename = "__ShinyBobGFX__/graphics/entity/robots/hr-construction-robot-"..mk..".png",
        priority = "high",
        line_length = 16,
        width = 66,
        height = 76,
        frame_count = 1,
        shift = util.by_pixel(0, -4.5),
        direction_count = 16,
        y = 76,
        scale = 0.5
      }
    }
	entity.shadow_idle =
    {
      filename = "__base__/graphics/entity/construction-robot/construction-robot-shadow.png",
      priority = "high",
      line_length = 16,
      width = 50,
      height = 24,
      frame_count = 1,
      shift = {1.09375, 0.59375},
      direction_count = 16,
      hr_version = {
        filename = "__base__/graphics/entity/construction-robot/hr-construction-robot-shadow.png",
        priority = "high",
        line_length = 16,
        width = 104,
        height = 49,
        frame_count = 1,
        shift = util.by_pixel(33.5, 18.75),
        direction_count = 16,
        scale = 0.5
      }
    }
	entity.shadow_in_motion =
    {
      filename = "__base__/graphics/entity/construction-robot/construction-robot-shadow.png",
      priority = "high",
      line_length = 16,
      width = 50,
      height = 24,
      frame_count = 1,
      shift = {1.09375, 0.59375},
      direction_count = 16,
      hr_version = {
        filename = "__base__/graphics/entity/construction-robot/hr-construction-robot-shadow.png",
        priority = "high",
        line_length = 16,
        width = 104,
        height = 49,
        frame_count = 1,
        shift = util.by_pixel(33.5, 18.75),
        direction_count = 16,
        scale = 0.5
      }
    }
	entity.working =
    {
      filename = "__ShinyBobGFX__/graphics/entity/robots/construction-robot-working-"..mk..".png",
      priority = "high",
      line_length = 2,
      width = 28,
      height = 36,
      frame_count = 2,
      shift = {0, -0.15625},
      direction_count = 16,
      animation_speed = 0.3,
	  hr_version = {
        filename = "__ShinyBobGFX__/graphics/entity/robots/hr-construction-robot-working-"..mk..".png",
        priority = "high",
        line_length = 2,
        width = 57,
        height = 74,
        frame_count = 2,
        shift = util.by_pixel(-0.25, -5),
        direction_count = 16,
        animation_speed = 0.3,
        scale = 0.5
      }
    }
	entity.shadow_working =
    {
      stripes = util.multiplystripes(2,
      {
        {
          filename = "__base__/graphics/entity/construction-robot/construction-robot-shadow.png",
          width_in_frames = 16,
          height_in_frames = 1,
        }
      }),
      priority = "high",
      width = 50,
      height = 24,
      frame_count = 2,
      shift = {1.09375, 0.59375},
      direction_count = 16
    }
	::skip::
end	


for mk = 1,5 do
	local entity = data.raw["logistic-robot"][logis[mk]]
	if not entity then goto skip end
	log(entity.name.."  zz44")
	entity.idle =
    {
      filename = "__ShinyBobGFX__/graphics/entity/robots/logistic-robot-"..mk..".png",
      priority = "high",
      line_length = 16,
      width = 41,
      height = 42,
      frame_count = 1,
      shift = {0.015625, -0.09375},
      direction_count = 16,
      y = 42,
      hr_version = {
        filename = "__ShinyBobGFX__/graphics/entity/robots/hr-logistic-robot-"..mk..".png",
        priority = "high",
        line_length = 16,
        width = 80,
        height = 84,
        frame_count = 1,
        shift = util.by_pixel(0, -3),
        direction_count = 16,
        y = 84,
        scale = 0.5
      }
    }
	entity.idle_with_cargo =
    {
      filename = "__ShinyBobGFX__/graphics/entity/robots/logistic-robot-"..mk..".png",
      priority = "high",
      line_length = 16,
      width = 41,
      height = 42,
      frame_count = 1,
      shift = {0.015625, -0.09375},
      direction_count = 16,
      hr_version = {
        filename = "__ShinyBobGFX__/graphics/entity/robots/hr-logistic-robot-"..mk..".png",
        priority = "high",
        line_length = 16,
        width = 80,
        height = 84,
        frame_count = 1,
        shift = util.by_pixel(0, -3),
        direction_count = 16,
        scale = 0.5
	  }
    }
	entity.in_motion =
    {
      filename = "__ShinyBobGFX__/graphics/entity/robots/logistic-robot-"..mk..".png",
      priority = "high",
      line_length = 16,
      width = 41,
      height = 42,
      frame_count = 1,
      shift = {0.015625, -0.09375},
      direction_count = 16,
      y = 126,
      hr_version = {
        filename = "__ShinyBobGFX__/graphics/entity/robots/hr-logistic-robot-"..mk..".png",
        priority = "high",
        line_length = 16,
        width = 80,
        height = 84,
        frame_count = 1,
        shift = util.by_pixel(0, -3),
        direction_count = 16,
        y = 252,
        scale = 0.5
      }
    }
	entity.in_motion_with_cargo =
    {
      filename = "__ShinyBobGFX__/graphics/entity/robots/logistic-robot-"..mk..".png",
      priority = "high",
      line_length = 16,
      width = 41,
      height = 42,
      frame_count = 1,
      shift = {0.015625, -0.09375},
      direction_count = 16,
      y = 84,
      hr_version = {
        filename = "__ShinyBobGFX__/graphics/entity/robots/hr-logistic-robot-"..mk..".png",
        priority = "high",
        line_length = 16,
        width = 80,
        height = 84,
        frame_count = 1,
        shift = util.by_pixel(0, -3),
        direction_count = 16,
        y = 168,
        scale = 0.5
      }
    }
	entity.shadow_idle =
    {
      filename = "__base__/graphics/entity/logistic-robot/logistic-robot-shadow.png",
      priority = "high",
      line_length = 16,
      width = 59,
      height = 23,
      frame_count = 1,
      shift = {0.96875, 0.609375},
      direction_count = 16,
      y = 23
    }
	entity.shadow_idle_with_cargo =
    {
      filename = "__base__/graphics/entity/logistic-robot/logistic-robot-shadow.png",
      priority = "high",
      line_length = 16,
      width = 59,
      height = 23,
      frame_count = 1,
      shift = {0.96875, 0.609375},
      direction_count = 16
    }
	entity.shadow_in_motion =
    {
      filename = "__base__/graphics/entity/logistic-robot/logistic-robot-shadow.png",
      priority = "high",
      line_length = 16,
      width = 59,
      height = 23,
      frame_count = 1,
      shift = {0.96875, 0.609375},
      direction_count = 16,
      y = 23
    }
	entity.shadow_in_motion_with_cargo =
    {
      filename = "__base__/graphics/entity/logistic-robot/logistic-robot-shadow.png",
      priority = "high",
      line_length = 16,
      width = 59,
      height = 23,
      frame_count = 1,
      shift = {0.96875, 0.609375},
      direction_count = 16
    }


if data.raw["combat-robot"]["bob-laser-robot"] then
data.raw["combat-robot"]["bob-laser-robot"].idle = 
	{
	filename = "__ShinyBobGFX__/graphics/entity/robots/combot-1.png",
	priority = "high",
	width = 44,
	height = 44,
	frame_count = 1,
	direction_count = 1,
	hr_version = {
		filename = "__ShinyBobGFX__/graphics/entity/robots/hr-combot-2.png",
		priority = "high",
		width = 88,
		height = 88,
		frame_count = 1,
		direction_count = 1,
		scale = 0.5
		}
	}
data.raw["combat-robot"]["bob-laser-robot"].shadow_idle = 
	{
	filename = "__ShinyBobGFX__/graphics/entity/robots/combot-shadow.png",
	priority = "high",
	width = 44,
	height = 25,
	frame_count = 1,
	direction_count = 1,
	shift = {0.859375, 0.609375},
	hr_version = {
		filename = "__ShinyBobGFX__/graphics/entity/robots/hr-combot-shadow.png",
		priority = "high",
		width = 88,
		height = 50,
		frame_count = 1,
		direction_count = 1,
		shift = util.by_pixel(25.5, 19),
		scale = 0.5
		}
	}
data.raw["combat-robot"]["bob-laser-robot"].in_motion = 
	{
	filename = "__ShinyBobGFX__/graphics/entity/robots/combot-1.png",
	priority = "high",
	width = 44,
	height = 44,
	frame_count = 1,
	direction_count = 1,
	hr_version = {
		filename = "__ShinyBobGFX__/graphics/entity/robots/hr-combot-2.png",
		priority = "high",
		width = 88,
		height = 88,
		frame_count = 1,
		direction_count = 1,
		scale = 0.5
		}
	}
data.raw["combat-robot"]["bob-laser-robot"].shadow_in_motion = 
	{
	filename = "__ShinyBobGFX__/graphics/entity/robots/combot-shadow.png",
	priority = "high",
	width = 44,
	height = 25,
	frame_count = 1,
	direction_count = 1,
	shift = {0.859375, 0.609375},
	hr_version = {
		filename = "__ShinyBobGFX__/graphics/entity/robots/hr-combot-shadow.png",
		priority = "high",
		width = 88,
		height = 50,
		frame_count = 1,
		direction_count = 1,
		shift = util.by_pixel(25.5, 19),
		scale = 0.5
		}
	}	
end	
	
	
::skip::
end