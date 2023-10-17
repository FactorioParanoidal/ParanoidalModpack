--- @alias position { x?: number, y?: number }

--- @alias sprite_segment
--- | { sprite?: string, width?: number, height?: number, frame_count?: number, scale?: number, shift?: position }
--- | position

--- @alias sprite_segment_variants sprite_segment | sprite_segment[]

--- @alias widths { left: number, middle: number, right: number } | number[]
--- @alias heights { top: number, middle: number, bottom: number } | number[]

--- @alias sprite_definition
--- | { [number]: sprite_segment_variants }
--- | { top_left?: sprite_segment_variants }
--- | { top?: sprite_segment_variants }
--- | { top_right?: sprite_segment_variants }
--- | { left?: sprite_segment_variants }
--- | { middle?: sprite_segment_variants }
--- | { right?: sprite_segment_variants }
--- | { bottom_left?: sprite_segment_variants }
--- | { bottom?: sprite_segment_variants }
--- | { bottom_right?: sprite_segment_variants }
--- | { top_center?: sprite_segment_variants }
--- | { left_center?: sprite_segment_variants }
--- | { center?: sprite_segment_variants }
--- | { right_center?: sprite_segment_variants }
--- | { bottom_center?: sprite_segment_variants }
--- | { sprite: string, scale: number, shift: position, widths: widths, heights: heights }
--- | { shadow?: boolean }

--- @alias entity_sprite
--- | { entity: sprite_definition, shadow?: sprite_definition }

--- @param entity_sprite string
--- @param center_sprite string
--- @param shadow_sprite string
--- @return entity_sprite
function CreateLogisticWideChestSegments(entity_sprite, center_sprite, shadow_sprite)
	return {
		entity =
		{
			sprite = entity_sprite,
			top_left = { x = 0, y = 0 },
			top = { x = 64, y = 0 },
			top_right = { x = 128, y = 0 },

			widths = { left = 64, middle = 64, right = 64 },
			heights =
			{
				top = 80,
				middle = 0,
				bottom = 0
			},
			shift = { x = -0.5, y = -4.5 },
			scale = 0.5,

			center = {
				sprite = center_sprite,
				width = 66,
				height = 32,
				frame_count = 7
			}
		},
		shadow =
		{
			sprite = shadow_sprite,
			top_right = { x = 60, y = 0, shift = { x = 30 } },
		
			widths = { left = 0, middle = 0, right = 50 },
			heights =
			{
				top = 46,
				middle = 0,
				bottom = 0
			},
			shift = { x = -4, y = 10 },
			scale = 0.5,
			shadow = true
		}
	}
end

--- @param entity_sprite string
--- @param center_sprite string
--- @param shadow_sprite string
--- @return entity_sprite
function CreateLogisticHighChestSegments(entity_sprite, center_sprite, shadow_sprite)
	return {
		entity =
		{
			sprite = entity_sprite,
			top_left = { x = 0, y = 0, shift = { y = -8 } },
			left = { x = 0, y = 80 },
			bottom_left = { x = 0, y = 144 },

			widths = { left = 64, middle = 0, right = 0 },
			heights =
			{
				top = 80,
				middle = 64,
				bottom = 64
			},
			shift = { x = 0, y = -0.5 },
			scale = 0.5,

			center = {
				sprite = center_sprite,
				width = 66,
				height = 32,
				shift = { x = -0.5, y = -4 },
				frame_count = 7
			}
		},
		shadow =
		{
			sprite = shadow_sprite,
			top_right = { x = 8, y = 0, shift = { y = 6.5 } },
			right = { x = 8, y = 18 },
			bottom_right = { x = 8, y = 45 },

			widths = { left = 0, middle = 0, right = 102 },
			heights =
			{
				top = 55,
				middle = 64,
				bottom = 55
			},
			shift = { x = 0.75, y = 4 },
			scale = 0.5,
			shadow = true
		}
	}
end

--- @param entity_sprite string
--- @param center_sprite string
--- @param shadow_sprite string
--- @return entity_sprite
function CreateLogisticWarehouseSegments(entity_sprite, center_sprite, shadow_sprite)
	return {
		entity =
		{
			sprite = entity_sprite,

			top_left = { x = 190, y = 177, shift = { y = 7 } },
			top = { x = 256, y = 177, shift = { y = 7 } },
			top_right = { x = 320, y = 177, shift = { y = 7 } },

			left = { x = 190, y = 252 },
			middle = { x = 256, y = 252 },
			right = { x = 320, y = 252 },

			bottom_left = { x = 190, y = 316 },
			bottom = { x = 256, y = 316 },
			bottom_right = { x = 320, y = 316 },

			center = {
				sprite = center_sprite,
				width = 66,
				height = 32,
				shift = { y = 3 },
				frame_count = 7
			},

			widths = { left = 66, middle = 64, right = 66 },
			heights =
			{
				top = 50,
				middle = 64,
				bottom = 110
			},
			shift = { x = 0, y = -23 },
			scale = 0.5
		},
		shadow =
		{
			sprite = shadow_sprite,

			top_right = { x = 384, y = 261, shift = { x = 32, y = 7 } },

			right = { x = 384, y = 310, shift = { x = 32 } },

			bottom_left = { x = 193, y = 374 },
			bottom = { x = 259, y = 374 },
			bottom_right = { x = 384, y = 374, shift = { x = 32 } },

			widths = { left = 110, middle = 64, right = 120 },
			heights =
			{
				top = 50,
				middle = 64,
				bottom = 50
			},
			shift = { x = -1, y = 6 },
			scale = 0.5,
			shadow = true
		}
	}
end

MergingChests.OTHER = "any-other"

--- @type
--- | { wide_segments: { [string]: entity_sprite } }
--- | { high_segments: { [string]: entity_sprite } }
--- | { warehouse_segments: { [string]: entity_sprite } }
--- | { trashdump_segments: { [string]: entity_sprite } }
sprite_segments_data =
{
	wide_segments =
	{
		["logistic-chest-active-provider"] = CreateLogisticWideChestSegments(
			"__WideChests__/graphics/entity/logistic-chest-active-provider/wide-chest/active-provider-wide-chest.png",
			"__WideChests__/graphics/entity/logistic-chest-active-provider/active-provider-hatch-door.png",
			"__WideChests__/graphics/entity/logistic-chest-active-provider/wide-chest/wide-chest-shadow.png"
		),
		["logistic-chest-buffer"] = CreateLogisticWideChestSegments(
			"__WideChests__/graphics/entity/logistic-chest-buffer/wide-chest/buffer-wide-chest.png",
			"__WideChests__/graphics/entity/logistic-chest-buffer/buffer-hatch-door.png",
			"__WideChests__/graphics/entity/logistic-chest-buffer/wide-chest/wide-chest-shadow.png"
		),
		["logistic-chest-passive-provider"] = CreateLogisticWideChestSegments(
			"__WideChests__/graphics/entity/logistic-chest-passive-provider/wide-chest/passive-provider-wide-chest.png",
			"__WideChests__/graphics/entity/logistic-chest-passive-provider/passive-provider-hatch-door.png",
			"__WideChests__/graphics/entity/logistic-chest-passive-provider/wide-chest/wide-chest-shadow.png"
		),
		["logistic-chest-requester"] = CreateLogisticWideChestSegments(
			"__WideChests__/graphics/entity/logistic-chest-requester/wide-chest/requester-wide-chest.png",
			"__WideChests__/graphics/entity/logistic-chest-requester/requester-hatch-door.png",
			"__WideChests__/graphics/entity/logistic-chest-requester/wide-chest/wide-chest-shadow.png"
		),
		["logistic-chest-storage"] = CreateLogisticWideChestSegments(
			"__WideChests__/graphics/entity/logistic-chest-storage/wide-chest/storage-wide-chest.png",
			"__WideChests__/graphics/entity/logistic-chest-storage/storage-hatch-door.png",
			"__WideChests__/graphics/entity/logistic-chest-storage/wide-chest/wide-chest-shadow.png"
		),

		[MergingChests.OTHER] = {
			entity =
			{
				sprite = "__WideChests__/graphics/entity/steel-chest/wide-chest/wide-chest.png",
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
				scale = 0.5
			},
			shadow =
			{
				sprite = "__WideChests__/graphics/entity/steel-chest/wide-chest/wide-chest-shadow.png",
				top_right = { x = 60, y = 0, shift = { x = 30 } },
			
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
		}
	},
	high_segments =
	{
		["logistic-chest-active-provider"] = CreateLogisticHighChestSegments(
			"__WideChests__/graphics/entity/logistic-chest-active-provider/high-chest/active-provider-high-chest.png",
			"__WideChests__/graphics/entity/logistic-chest-active-provider/active-provider-hatch-door.png",
			"__WideChests__/graphics/entity/logistic-chest-active-provider/high-chest/high-chest-shadow.png"
		),
		["logistic-chest-buffer"] = CreateLogisticHighChestSegments(
			"__WideChests__/graphics/entity/logistic-chest-buffer/high-chest/buffer-high-chest.png",
			"__WideChests__/graphics/entity/logistic-chest-buffer/buffer-hatch-door.png",
			"__WideChests__/graphics/entity/logistic-chest-buffer/high-chest/high-chest-shadow.png"
		),
		["logistic-chest-passive-provider"] = CreateLogisticHighChestSegments(
			"__WideChests__/graphics/entity/logistic-chest-passive-provider/high-chest/passive-provider-high-chest.png",
			"__WideChests__/graphics/entity/logistic-chest-passive-provider/passive-provider-hatch-door.png",
			"__WideChests__/graphics/entity/logistic-chest-passive-provider/high-chest/high-chest-shadow.png"
		),
		["logistic-chest-requester"] = CreateLogisticHighChestSegments(
			"__WideChests__/graphics/entity/logistic-chest-requester/high-chest/requester-high-chest.png",
			"__WideChests__/graphics/entity/logistic-chest-requester/requester-hatch-door.png",
			"__WideChests__/graphics/entity/logistic-chest-requester/high-chest/high-chest-shadow.png"
		),
		["logistic-chest-storage"] = CreateLogisticHighChestSegments(
			"__WideChests__/graphics/entity/logistic-chest-storage/high-chest/storage-high-chest.png",
			"__WideChests__/graphics/entity/logistic-chest-storage/storage-hatch-door.png",
			"__WideChests__/graphics/entity/logistic-chest-storage/high-chest/high-chest-shadow.png"
		),

		[MergingChests.OTHER] = {
			entity =
			{
				sprite = "__WideChests__/graphics/entity/steel-chest/high-chest/high-chest.png",
				top_left = { x = 0, y = 0, shift = { y = 5 } },
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
				sprite = "__WideChests__/graphics/entity/steel-chest/high-chest/high-chest-shadow.png",
				top_right = { x = 0, y = 0, shift = { y = 6.5 } },
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
		}
	},
	warehouse_segments =
	{
		["logistic-chest-active-provider"] = CreateLogisticWarehouseSegments(
			"__WideChests__/graphics/entity/logistic-chest-active-provider/warehouse/warehouse.png",
			"__WideChests__/graphics/entity/logistic-chest-active-provider/active-provider-hatch-door.png",
			"__WideChests__/graphics/entity/logistic-chest-active-provider/warehouse/warehouse-shadow.png"
		),
		["logistic-chest-buffer"] = CreateLogisticWarehouseSegments(
			"__WideChests__/graphics/entity/logistic-chest-buffer/warehouse/warehouse.png",
			"__WideChests__/graphics/entity/logistic-chest-buffer/buffer-hatch-door.png",
			"__WideChests__/graphics/entity/logistic-chest-buffer/warehouse/warehouse-shadow.png"
		),
		["logistic-chest-passive-provider"] = CreateLogisticWarehouseSegments(
			"__WideChests__/graphics/entity/logistic-chest-passive-provider/warehouse/warehouse.png",
			"__WideChests__/graphics/entity/logistic-chest-passive-provider/passive-provider-hatch-door.png",
			"__WideChests__/graphics/entity/logistic-chest-passive-provider/warehouse/warehouse-shadow.png"
		),
		["logistic-chest-requester"] = CreateLogisticWarehouseSegments(
			"__WideChests__/graphics/entity/logistic-chest-requester/warehouse/warehouse.png",
			"__WideChests__/graphics/entity/logistic-chest-requester/requester-hatch-door.png",
			"__WideChests__/graphics/entity/logistic-chest-requester/warehouse/warehouse-shadow.png"
		),
		["logistic-chest-storage"] = CreateLogisticWarehouseSegments(
			"__WideChests__/graphics/entity/logistic-chest-storage/warehouse/warehouse.png",
			"__WideChests__/graphics/entity/logistic-chest-storage/storage-hatch-door.png",
			"__WideChests__/graphics/entity/logistic-chest-storage/warehouse/warehouse-shadow.png"
		),

		[MergingChests.OTHER] = {
			entity =
			{
				sprite = "__WideChests__/graphics/entity/steel-chest/warehouse/warehouse.png",
			
				top_left = { x = 190, y = 177, shift = { y = 7 } },
				top = { x = 256, y = 177, shift = { y = 7 } },
				top_right = { x = 320, y = 177, shift = { y = 7 } },
			
				left = {
					{ x = 190, y = 252 },
					{
						sprite = "__WideChests__/graphics/entity/steel-chest/warehouse/warehouse-alternatives-2.png",
						y = 234
					},
					{
						sprite = "__WideChests__/graphics/entity/steel-chest/warehouse/warehouse-alternatives-3.png",
						y = 234
					},
					{
						sprite = "__WideChests__/graphics/entity/steel-chest/warehouse/warehouse-alternatives-4.png",
						y = 234
					},
					{
						sprite = "__WideChests__/graphics/entity/steel-chest/warehouse/warehouse-alternatives-5.png",
						y = 234
					},
					{
						sprite = "__WideChests__/graphics/entity/steel-chest/warehouse/warehouse-alternatives-6.png",
						y = 234
					}
				},
				middle = {
					{ x = 256, y = 252 },
					{
						sprite = "__WideChests__/graphics/entity/steel-chest/warehouse/warehouse-alternatives-2.png",
						y = 234
					},
					{
						sprite = "__WideChests__/graphics/entity/steel-chest/warehouse/warehouse-alternatives-3.png",
						y = 234
					},
					{
						sprite = "__WideChests__/graphics/entity/steel-chest/warehouse/warehouse-alternatives-4.png",
						y = 234
					},
					{
						sprite = "__WideChests__/graphics/entity/steel-chest/warehouse/warehouse-alternatives-5.png",
						y = 234
					},
					{
						sprite = "__WideChests__/graphics/entity/steel-chest/warehouse/warehouse-alternatives-6.png",
						y = 234
					}
				},
				right = {
					{ x = 320, y = 252 },
					{
						sprite = "__WideChests__/graphics/entity/steel-chest/warehouse/warehouse-alternatives-2.png",
						y = 234
					},
					{
						sprite = "__WideChests__/graphics/entity/steel-chest/warehouse/warehouse-alternatives-3.png",
						y = 234
					},
					{
						sprite = "__WideChests__/graphics/entity/steel-chest/warehouse/warehouse-alternatives-4.png",
						y = 234
					},
					{
						sprite = "__WideChests__/graphics/entity/steel-chest/warehouse/warehouse-alternatives-5.png",
						y = 234
					},
					{
						sprite = "__WideChests__/graphics/entity/steel-chest/warehouse/warehouse-alternatives-6.png",
						y = 234
					}
				},
			
				bottom_left = { x = 190, y = 316 },
				bottom = {
					{ x = 256, y = 316 },
					{
						sprite = "__WideChests__/graphics/entity/steel-chest/warehouse/warehouse-alternatives-1.png"
					}
				},
				bottom_right = { x = 320, y = 316 },

				widths = { left = 66, middle = 64, right = 66 },
				heights =
				{
					top = 50,
					middle = 64,
					bottom = 110
				},
				shift = { x = 0, y = -23 },
				scale = 0.5
			},
			shadow =
			{
				sprite = "__WideChests__/graphics/entity/steel-chest/warehouse/warehouse-shadow.png",
			
				top_right = { x = 384, y = 261, shift = { x = 32, y = 7 } },

				right = { x = 384, y = 310, shift = { x = 32 } },

				bottom_left = { x = 193, y = 374 },
				bottom = { x = 259, y = 374 },
				bottom_right = { x = 384, y = 374, shift = { x = 32 } },

				widths = { left = 110, middle = 64, right = 120 },
				heights =
				{
					top = 50,
					middle = 64,
					bottom = 50
				},
				shift = { x = -1, y = 6 },
				scale = 0.5,
				shadow = true
			}
		}
	},
	trashdump_segments =
	{
		[MergingChests.OTHER] = {
			entity =
			{
				sprite = "__WideChests__/graphics/entity/steel-chest/trashdump/trashdump-entity.png",
			
				top_left = { x = 0, y = 0 },
				top = { x = 36, y = 0 },
				top_right = { x = 72, y = 0 },
			
				left = { x = 0, y = 41 },
				right = { x = 72, y = 41 },
			
				bottom_left = { x = 0, y = 85, shift = { x = 1 } },
				bottom = { x = 36, y = 85 },
				bottom_right = { x = 72, y = 85 },

				widths = { left = 32, middle = 32, right = 32 },
				heights =
				{
					top = 37,
					middle = 40,
					bottom = 35
				},
				shift = { x = 0, y = -8 }
			},
			shadow =
			{
				sprite = "__WideChests__/graphics/entity/steel-chest/trashdump/trashdump-shadow.png",
			
				top_left = { x = 0, y = 0 },
				top = { x = 63, y = 0, shift = { x = -16 } },
				top_right = { x = 136, y = 0, shift = { x = -17 } },
			
				left = { x = 0, y = 60 },
				right = { x = 0, y = 60 },
			
				bottom_left = { x = 0, y = 116 },
				bottom = { x = 63, y = 0, shift = { x = -16 } },
				bottom_right = { x = 136, y = 116, shift = { x = -16 } },

				widths = { left = 42, middle = 58, right = 44 },
				heights =
				{
					top = 50,
					middle = 47,
					bottom = 16
				},
				shift = { x = 18, y = 27 },
				shadow = true
			}
		}
	}
}

-- make copies
sprite_segments_data.wide_segments['nullius-small-dispatch-chest-1'] = sprite_segments_data.wide_segments['logistic-chest-active-provider']
sprite_segments_data.wide_segments['nullius-small-dispatch-chest-2'] = sprite_segments_data.wide_segments['logistic-chest-active-provider']
sprite_segments_data.wide_segments['nullius-small-buffer-chest-1'] = sprite_segments_data.wide_segments['logistic-chest-buffer']
sprite_segments_data.wide_segments['nullius-small-buffer-chest-2'] = sprite_segments_data.wide_segments['logistic-chest-buffer']
sprite_segments_data.wide_segments['nullius-small-supply-chest-1'] = sprite_segments_data.wide_segments['logistic-chest-passive-provider']
sprite_segments_data.wide_segments['nullius-small-supply-chest-2'] = sprite_segments_data.wide_segments['logistic-chest-passive-provider']
sprite_segments_data.wide_segments['nullius-small-demand-chest-1'] = sprite_segments_data.wide_segments['logistic-chest-requester']
sprite_segments_data.wide_segments['nullius-small-demand-chest-2'] = sprite_segments_data.wide_segments['logistic-chest-requester']
sprite_segments_data.wide_segments['nullius-small-storage-chest-1'] = sprite_segments_data.wide_segments['logistic-chest-storage']
sprite_segments_data.wide_segments['nullius-small-storage-chest-2'] = sprite_segments_data.wide_segments['logistic-chest-storage']

sprite_segments_data.high_segments['nullius-small-dispatch-chest-1'] = sprite_segments_data.high_segments['logistic-chest-active-provider']
sprite_segments_data.high_segments['nullius-small-dispatch-chest-2'] = sprite_segments_data.high_segments['logistic-chest-active-provider']
sprite_segments_data.high_segments['nullius-small-buffer-chest-1'] = sprite_segments_data.high_segments['logistic-chest-buffer']
sprite_segments_data.high_segments['nullius-small-buffer-chest-2'] = sprite_segments_data.high_segments['logistic-chest-buffer']
sprite_segments_data.high_segments['nullius-small-supply-chest-1'] = sprite_segments_data.high_segments['logistic-chest-passive-provider']
sprite_segments_data.high_segments['nullius-small-supply-chest-2'] = sprite_segments_data.high_segments['logistic-chest-passive-provider']
sprite_segments_data.high_segments['nullius-small-demand-chest-1'] = sprite_segments_data.high_segments['logistic-chest-requester']
sprite_segments_data.high_segments['nullius-small-demand-chest-2'] = sprite_segments_data.high_segments['logistic-chest-requester']
sprite_segments_data.high_segments['nullius-small-storage-chest-1'] = sprite_segments_data.high_segments['logistic-chest-storage']
sprite_segments_data.high_segments['nullius-small-storage-chest-2'] = sprite_segments_data.high_segments['logistic-chest-storage']

sprite_segments_data.warehouse_segments['nullius-small-dispatch-chest-1'] = sprite_segments_data.warehouse_segments['logistic-chest-active-provider']
sprite_segments_data.warehouse_segments['nullius-small-dispatch-chest-2'] = sprite_segments_data.warehouse_segments['logistic-chest-active-provider']
sprite_segments_data.warehouse_segments['nullius-small-buffer-chest-1'] = sprite_segments_data.warehouse_segments['logistic-chest-buffer']
sprite_segments_data.warehouse_segments['nullius-small-buffer-chest-2'] = sprite_segments_data.warehouse_segments['logistic-chest-buffer']
sprite_segments_data.warehouse_segments['nullius-small-supply-chest-1'] = sprite_segments_data.warehouse_segments['logistic-chest-passive-provider']
sprite_segments_data.warehouse_segments['nullius-small-supply-chest-2'] = sprite_segments_data.warehouse_segments['logistic-chest-passive-provider']
sprite_segments_data.warehouse_segments['nullius-small-demand-chest-1'] = sprite_segments_data.warehouse_segments['logistic-chest-requester']
sprite_segments_data.warehouse_segments['nullius-small-demand-chest-2'] = sprite_segments_data.warehouse_segments['logistic-chest-requester']
sprite_segments_data.warehouse_segments['nullius-small-storage-chest-1'] = sprite_segments_data.warehouse_segments['logistic-chest-storage']
sprite_segments_data.warehouse_segments['nullius-small-storage-chest-2'] = sprite_segments_data.warehouse_segments['logistic-chest-storage']
	
--- @param segment sprite_definition
function TransformSegmentData(segment)
	segment.widths[0] = segment.widths.left
	segment.widths[1] = segment.widths.middle
	segment.widths[2] = segment.widths.right

	segment.heights[0] = segment.heights.top
	segment.heights[1] = segment.heights.middle
	segment.heights[2] = segment.heights.bottom
	
	segment[0] = segment.top_left
	segment[1] = segment.top
	segment[2] = segment.top_right
	segment[3] = segment.left
	segment[4] = segment.middle
	segment[5] = segment.right
	segment[6] = segment.bottom_left
	segment[7] = segment.bottom
	segment[8] = segment.bottom_right
	
	segment[11] = segment.top_center
	segment[13] = segment.left_center
	segment[14] = segment.center
	segment[15] = segment.right_center
	segment[17] = segment.bottom_center
end

-- transform widths and heights maps to arrays and stores segments in an array
for _, segments in pairs(sprite_segments_data) do
	for __, segment in pairs(segments) do
		if segment.entity then
			TransformSegmentData(segment.entity)
		end
		if segment.shadow then
			TransformSegmentData(segment.shadow)
		end
	end
end

--- @param entity_name string
--- @return entity_sprite
function MergingChests.GetWideChestSpriteSegmentsData(entity_name)
	return sprite_segments_data.wide_segments[entity_name] or sprite_segments_data.wide_segments[MergingChests.OTHER]
end

--- @param entity_name string
--- @return entity_sprite
function MergingChests.GetHighChestSpriteSegmentsData(entity_name)
	return sprite_segments_data.high_segments[entity_name] or sprite_segments_data.high_segments[MergingChests.OTHER]
end

--- @param entity_name string
--- @return entity_sprite
function MergingChests.GetWarehouseSpriteSegmentsData(entity_name)
	return sprite_segments_data.warehouse_segments[entity_name] or sprite_segments_data.warehouse_segments[MergingChests.OTHER]
end

--- @param entity_name string
--- @return entity_sprite
function MergingChests.GetTrashdumpSpriteSegmentsData(entity_name)
	return sprite_segments_data.trashdump_segments[entity_name] or sprite_segments_data.trashdump_segments[MergingChests.OTHER]
end
