function make_stripes (count, filename)
	local stripe = {filename=filename, width_in_frames = 1, height_in_frames = 1}
	local stripes = {}
    for i = 1, count do
      stripes[i] = stripe
    end
  return stripes
end

local mod_name = "__BurnerOffshorePump__"
local dir = mod_name .. "/graphics/entity/burner/"

local animation = 
{	
	north =
	{
		layers =
		{
			{
				filename = "__base__/graphics/entity/offshore-pump/offshore-pump_North.png",
				priority = "high",
				line_length = 8,
				frame_count = 32,
				animation_speed = 0.25,
				width = 48,
				height = 84,
				shift = util.by_pixel(-2, -16),
				hr_version =
				{
					filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_North.png",
					priority = "high",
					line_length = 8,
					frame_count = 32,
					animation_speed = 0.25,
					width = 90,
					height = 162,
					shift = util.by_pixel(-1, -15),
					scale = 0.5
				}
			},
			{
				filename = "__base__/graphics/entity/offshore-pump/offshore-pump_North-shadow.png",
				priority = "high",
				line_length = 8,
				frame_count = 32,
				animation_speed = 0.25,
				width = 78,
				height = 70,
				shift = util.by_pixel(12, -8),
				draw_as_shadow = true,
				hr_version =
				{
					filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_North-shadow.png",
					priority = "high",
					line_length = 8,
					frame_count = 32,
					animation_speed = 0.25,
					width = 150,
					height = 134,
					shift = util.by_pixel(13, -7),
					draw_as_shadow = true,
					scale = 0.5
				}
			},
			{
--				filename = "__base__/graphics/entity/offshore-pump/offshore-pump_north.png",
				stripes = make_stripes (8*4, dir .. "offshore-pump_north.png"),
				priority = "high",
--				line_length = 1,
--				frame_count = 1,
				frame_count = 32,
				animation_speed = 0.25,
				width = 48,
				height = 84,
				shift = util.by_pixel(-2, -16),
				hr_version =
				{
--					filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_north.png",
					stripes = make_stripes (8*4, dir .. "hr-offshore-pump_north.png"),
					priority = "high",
--					line_length = 1,
--					frame_count = 1,
					frame_count = 32,
					animation_speed = 0.25,
					width = 90,
					height = 162,
					shift = util.by_pixel(-1, -15),
					scale = 0.5
				}
			}
		}
	},
	east =
	{
		layers =
		{
			{
				--filename = "__base__/graphics/entity/offshore-pump/offshore-pump_east.png",
				filename = "__base__/graphics/entity/offshore-pump/offshore-pump_East.png",
				priority = "high",
				line_length = 8,
				frame_count = 32,
				animation_speed = 0.25,
				width = 64,
				height = 52,
				shift = util.by_pixel(14, -2),
				hr_version =
				{
					--filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_east.png",
					filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_East.png",
					priority = "high",
					line_length = 8,
					frame_count = 32,
					animation_speed = 0.25,
					width = 124,
					height = 102,
					shift = util.by_pixel(15, -2),
					scale = 0.5
				}
			},
			{
				filename = "__base__/graphics/entity/offshore-pump/offshore-pump_East-shadow.png",
				priority = "high",
				line_length = 8,
				frame_count = 32,
				animation_speed = 0.25,
				width = 88,
				height = 34,
				shift = util.by_pixel(28, 8),
				draw_as_shadow = true,
				hr_version =
				{
					filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_East-shadow.png",
					priority = "high",
					line_length = 8,
					frame_count = 32,
					animation_speed = 0.25,
					width = 180,
					height = 66,
					shift = util.by_pixel(27, 8),
					draw_as_shadow = true,
					scale = 0.5
				}
			},
			{
--				filename = "__base__/graphics/entity/offshore-pump/offshore-pump_east.png",
				stripes = make_stripes (8*4, dir .. "offshore-pump_east.png"),
				priority = "high",
--				line_length = 1,
--				frame_count = 1,
				frame_count = 32,
				animation_speed = 0.25,
				width = 64,
				height = 52,
				shift = util.by_pixel(14, -2),
				hr_version =
				{
--					filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_east.png",
					stripes = make_stripes (8*4, dir .. "hr-offshore-pump_east.png"),
					priority = "high",
--					line_length = 1,
--					frame_count = 1,
					frame_count = 32,
					animation_speed = 0.25,
					width = 124,
					height = 102,
					shift = util.by_pixel(15, -2),
					scale = 0.5
				}
			}
		}
	},
	south =
	{
		layers =
		{
			{
				filename = "__base__/graphics/entity/offshore-pump/offshore-pump_South.png",
				priority = "high",
				line_length = 8,
				frame_count = 32,
				animation_speed = 0.25,
				width = 48,
				height = 96,
				shift = util.by_pixel(-2, 0),
				hr_version =
				{
					filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_South.png",
					priority = "high",
					line_length = 8,
					frame_count = 32,
					animation_speed = 0.25,
					width = 92,
					height = 192,
					shift = util.by_pixel(-1, 0),
					scale = 0.5
				}
			},
			{
				filename = "__base__/graphics/entity/offshore-pump/offshore-pump_South-shadow.png",
				priority = "high",
				line_length = 8,
				frame_count = 32,
				animation_speed = 0.25,
				width = 80,
				height = 66,
				shift = util.by_pixel(16, 22),
				draw_as_shadow = true,
				hr_version =
				{
					filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_South-shadow.png",
					priority = "high",
					line_length = 8,
					frame_count = 32,
					animation_speed = 0.25,
					width = 164,
					height = 128,
					shift = util.by_pixel(15, 23),
					draw_as_shadow = true,
					scale = 0.5
				}
			},
			{
--				filename = "__base__/graphics/entity/offshore-pump/offshore-pump_south.png",
				stripes = make_stripes (8*4, dir .. "offshore-pump_south.png"),
				priority = "high",
--				line_length = 1,
--				frame_count = 1,
				frame_count = 32,
				animation_speed = 0.25,
				width = 48,
				height = 96,
				shift = util.by_pixel(-2, 0),
				hr_version =
				{
	--				filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_south.png",
					stripes = make_stripes (8*4, dir .. "hr-offshore-pump_south.png"),
					priority = "high",
--					line_length = 1,
--					frame_count = 1,
					frame_count = 32,
					animation_speed = 0.25,
					width = 92,
					height = 192,
					shift = util.by_pixel(-1, 0),
					scale = 0.5
				}
			}
		}
	},
	west =
	{
		layers =
		{
			{
				filename = "__base__/graphics/entity/offshore-pump/offshore-pump_West.png",
				priority = "high",
				line_length = 8,
				frame_count = 32,
				animation_speed = 0.25,
				width = 64,
				height = 52,
				shift = util.by_pixel(-16, -2),
				hr_version =
				{
					filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_West.png",
					priority = "high",
					line_length = 8,
					frame_count = 32,
					animation_speed = 0.25,
					width = 124,
					height = 102,
					shift = util.by_pixel(-15, -2),
					scale = 0.5
				}
			},
			{
				filename = "__base__/graphics/entity/offshore-pump/offshore-pump_West-shadow.png",
				priority = "high",
				line_length = 8,
				frame_count = 32,
				animation_speed = 0.25,
				width = 88,
				height = 34,
				shift = util.by_pixel(-4, 8),
				draw_as_shadow = true,
				hr_version =
				{
					filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_West-shadow.png",
					priority = "high",
					line_length = 8,
					frame_count = 32,
					animation_speed = 0.25,
					width = 172,
					height = 66,
					shift = util.by_pixel(-3, 8),
					draw_as_shadow = true,
					scale = 0.5
				}
			},
			{
--				filename = "__base__/graphics/entity/offshore-pump/offshore-pump_west.png",
				stripes = make_stripes (8*4, dir .. "offshore-pump_west.png"),
				priority = "high",
--				line_length = 1,
--				frame_count = 1,
				frame_count = 32,
				animation_speed = 0.25,
				width = 64,
				height = 52,
				shift = util.by_pixel(-16, -2),
				hr_version =
				{
	--				filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_west.png",
					stripes = make_stripes (8*4, dir .. "hr-offshore-pump_west.png"),
					priority = "high",
--					line_length = 1,
--					frame_count = 1,
					frame_count = 32,
					animation_speed = 0.25,
					width = 124,
					height = 102,
					shift = util.by_pixel(-15, -2),
					scale = 0.5
				}
			}
		}
	}
}

return animation