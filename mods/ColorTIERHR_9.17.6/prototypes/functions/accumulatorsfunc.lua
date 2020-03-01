function baseACCUMULATORS(base_picture)
	return
	{
	
			filename = ColorTIER_path.."/graphics/low-res/entity/accumulator/"..base_picture..".png",
			priority = "extra-high",
			width = 66,
			height = 94,
			repeat_count = 24,
			shift = util.by_pixel(0, -10),
			tint = tint,
			animation_speed = 0.5,
			hr_version =
			{
				filename = ColorTIER_path.."/graphics/high-res/entity/accumulator/"..base_picture..".png",
				priority = "extra-high",
				
				width = 130,
				height = 189,
				repeat_count = 24,
				shift = util.by_pixel(0, -11),
				tint = tint,
				animation_speed = 0.5,
				scale = 0.5
			}

	}
	
end

function xtraACCUMULATORSnorepeat(mask_layer)
	return
	{

			filename = ColorTIER_path.."/graphics/low-res/entity/accumulator/"..mask_layer..".png",
			priority = "extra-high",
			width = 66,
			height = 94,
			shift = util.by_pixel(0, -10),
			animation_speed = 0.5,
			hr_version =
			{
				filename = ColorTIER_path.."/graphics/high-res/entity/accumulator/"..mask_layer..".png",
				priority = "extra-high",
				width = 130,
				height = 189,
				shift = util.by_pixel(0, -11),
				animation_speed = 0.5,
				scale = 0.5
			}

	}

end

function xtraACCUMULATORS(extra_layer)
	return
	{

			filename = ColorTIER_path.."/graphics/low-res/entity/accumulator/"..extra_layer..".png",
			priority = "extra-high",
			width = 66,
			height = 94,
			repeat_count = 24,
			shift = util.by_pixel(0, -10),
			animation_speed = 0.5,
			hr_version =
			{
				filename = ColorTIER_path.."/graphics/high-res/entity/accumulator/"..extra_layer..".png",
				priority = "extra-high",
				width = 130,
				height = 189,
				repeat_count = 24,
				shift = util.by_pixel(0, -11),
				animation_speed = 0.5,
				scale = 0.5
			}

	}

end


