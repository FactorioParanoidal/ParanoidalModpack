MergingChests.SpriteSegmentsData =
{
	wide_segments =
	{
		entity =
		{
			sprite = "__WideChests__/graphics/entity/wide-chest.png",
			top_left = { x = 0, y = 0 },
			top = { x = 32, y = 0 },
			top_right = { x = 64, y = 0 },

			widths = { left = 64, middle = 64, right = 64 },
			heights =
			{
				top = 80,
				middle = 0,
				bottom = 0 
			},
			shift = { x = -0.25, y = -4.5 },
			scale = 0.5,
		},
		shadow = 
		{
			sprite = "__WideChests__/graphics/entity/wide-chest-shadow.png",
			top_right = { x = 60, y = 0, shiftX = 30 },
		
			widths = { left = 0, middle = 0, right = 50 },
			heights =
			{
				top = 46, 
				middle = 0, 
				bottom = 0
			},
			shift = { x = 0.75, y = 12.5 },
			scale = 0.5,
			shadow = true
		}
	},
	high_segments =
	{
		entity =
		{
			sprite = "__WideChests__/graphics/entity/high-chest.png",
			top_left = { x = 0, y = 0, shiftY = 5 },
			left = { x = 0, y = 22 },
			bottom_left = { x = 0, y = 54 },

			widths = { left = 64, middle = 0, right = 0 },
			heights =
			{
				top = 54,
				middle = 64,
				bottom = 90
			},
			shift = { x = -0.25, y = -9.5 },
			scale = 0.5
		},
		shadow = 
		{
			sprite = "__WideChests__/graphics/entity/high-chest-shadow.png",
			top_right = { x = 0, y = 0, shiftY = 6.5 },
			right = { x = 0, y = 18 },
			bottom_right = { x = 0, y = 45 },

			widths = { left = 0, middle = 0, right = 110 },
			heights =
			{
				top = 55,
				middle = 64,
				bottom = 55
			},
			shift = { x = 0.75, y = 6 },
			scale = 0.5,
			shadow = true
		}
	},
	warehouse_segments =
	{
		entity = 
		{
			sprite = "__WideChests__/graphics/entity/warehouse.png",
			
			top_left = { x = 4, y = 23, shiftY = 16 },
			top = { x = 68, y = 23, shiftY = 16 },
			top_right = { x = 132, y = 23, shiftY = 16 },
			
			left = { x = 4, y = 75 },
			middle = { x = 68, y = 75 },
			right = { x = 132, y = 75 },
			
			bottom_left = { x = 4, y = 149 },
			bottom = { x = 68, y = 149 },
			bottom_right = { x = 132, y = 149 },

			widths = { left = 64, middle = 64, right = 64 },
			heights =
			{
				top = 32,
				middle = 64,
				bottom = 110
			},
			shift = { x = 0, y = -23 },
			scale = 32.0 / 64.0,
			
			spritesheet = 
			{
				width = 314,
				height = 314,
				columns = 5,
				count = 5,
			},
		},
		shadow =
		{
			sprite = "__WideChests__/graphics/entity/warehouse.png",
			
			top_right = { x = 197, y = 114, shiftY = 19 },
			right = { x = 197, y = 153 },
			bottom_right = { x = 197, y = 233 },

			widths = { left = 0, middle = 0, right = 112 },
			heights =
			{
				top = 26,
				middle = 64,
				bottom = 26
			},
			shift = { x = 32, y = 19 },
			scale = 32.0 / 64.0,
			shadow = true,
		}
	},
	trashdump_segments =
	{
		entity = 
		{
			sprite = "__WideChests__/graphics/entity/trashdump-entity.png",
			
			top_left = { x = 0, y = 0 },
			top = { x = 36, y = 0 },
			top_right = { x = 72, y = 0 },
			
			left = { x = 0, y = 41 },
			right = { x = 72, y = 41 },
			
			bottom_left = { x = 0, y = 85, shiftX = 1 },
			bottom = { x = 36, y = 85 },
			bottom_right = { x = 72, y = 85 },

			widths = { left = 32, middle = 32, right = 32 },
			heights =
			{
				top = 37,
				middle = 40,
				bottom = 35
			},
			shift = { x = 0, y = -8 },
		},
		shadow =
		{
			sprite = "__WideChests__/graphics/entity/trashdump-shadow.png",
			
			top_left = { x = 0, y = 0 },
			top = { x = 63, y = 0, shiftX = -16 },
			top_right = { x = 136, y = 0, shiftX = -17 },
			
			left = { x = 0, y = 60 },
			right = { x = 0, y = 60 },
			
			bottom_left = { x = 0, y = 116 },
			bottom = { x = 63, y = 0, shiftX = -16 },
			bottom_right = { x = 136, y = 116, shiftX = -16 },

			widths = { left = 42, middle = 58, right = 44 },
			heights =
			{
				top = 50,
				middle = 47,
				bottom = 16
			},
			shift = { x = 18, y = 27 },
			shadow = true,
		}
	},
}

-- transform widths and heights maps to arrays
for _, segment in pairs(MergingChests.SpriteSegmentsData) do
	if segment.entity then
		local oldWidths = segment.entity.widths
		segment.entity.widths = { oldWidths.left, oldWidths.middle, oldWidths.right }
		
		local oldHeights = segment.entity.heights
		segment.entity.heights = { oldHeights.top, oldHeights.middle, oldHeights.bottom }
	end
	if segment.shadow then
		local oldWidths = segment.shadow.widths
		segment.shadow.widths = { oldWidths.left, oldWidths.middle, oldWidths.right }
		
		local oldHeights = segment.shadow.heights
		segment.shadow.heights = { oldHeights.top, oldHeights.middle, oldHeights.bottom }
	end
end