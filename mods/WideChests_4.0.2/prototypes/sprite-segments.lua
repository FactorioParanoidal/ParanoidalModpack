function CreateWideLogisticChestSegments(entity_sprite, center_sprite, shadow_sprite)
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

function CreateHighLogisticChestSegments(entity_sprite, center_sprite, shadow_sprite)
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

MergingChests.OTHER = "any-other"
MergingChests.SpriteSegmentsData =
{
	wide_segments =
	{
		["logistic-chest-passive-provider"] = CreateWideLogisticChestSegments(
			"__WideChests__/graphics/entity/logistic-chest/passive-provider-wide-chest.png",
			"__WideChests__/graphics/entity/logistic-chest/passive-provider-hatch-door.png",
			"__WideChests__/graphics/entity/wide-chest-shadow.png"
		),
		["logistic-chest-active-provider"] = CreateWideLogisticChestSegments(
			"__WideChests__/graphics/entity/logistic-chest/active-provider-wide-chest.png",
			"__WideChests__/graphics/entity/logistic-chest/active-provider-hatch-door.png",
			"__WideChests__/graphics/entity/wide-chest-shadow.png"
		),
		["logistic-chest-storage"] = CreateWideLogisticChestSegments(
			"__WideChests__/graphics/entity/logistic-chest/storage-wide-chest.png",
			"__WideChests__/graphics/entity/logistic-chest/storage-hatch-door.png",
			"__WideChests__/graphics/entity/wide-chest-shadow.png"
		),
		["logistic-chest-buffer"] = CreateWideLogisticChestSegments(
			"__WideChests__/graphics/entity/logistic-chest/buffer-wide-chest.png",
			"__WideChests__/graphics/entity/logistic-chest/buffer-hatch-door.png",
			"__WideChests__/graphics/entity/wide-chest-shadow.png"
		),
		["logistic-chest-requester"] = CreateWideLogisticChestSegments(
			"__WideChests__/graphics/entity/logistic-chest/requester-wide-chest.png",
			"__WideChests__/graphics/entity/logistic-chest/requester-hatch-door.png",
			"__WideChests__/graphics/entity/wide-chest-shadow.png"
		),

		["nullius-small-supply-chest-1"] = CreateWideLogisticChestSegments(
			"__WideChests__/graphics/entity/logistic-chest/passive-provider-wide-chest.png",
			"__WideChests__/graphics/entity/logistic-chest/passive-provider-hatch-door.png",
			"__WideChests__/graphics/entity/wide-chest-shadow.png"
		),
		["nullius-small-supply-chest-2"] = CreateWideLogisticChestSegments(
			"__WideChests__/graphics/entity/logistic-chest/passive-provider-wide-chest.png",
			"__WideChests__/graphics/entity/logistic-chest/passive-provider-hatch-door.png",
			"__WideChests__/graphics/entity/wide-chest-shadow.png"
		),
		["nullius-small-dispatch-chest-1"] = CreateWideLogisticChestSegments(
			"__WideChests__/graphics/entity/logistic-chest/active-provider-wide-chest.png",
			"__WideChests__/graphics/entity/logistic-chest/active-provider-hatch-door.png",
			"__WideChests__/graphics/entity/wide-chest-shadow.png"
		),
		["nullius-small-dispatch-chest-2"] = CreateWideLogisticChestSegments(
			"__WideChests__/graphics/entity/logistic-chest/active-provider-wide-chest.png",
			"__WideChests__/graphics/entity/logistic-chest/active-provider-hatch-door.png",
			"__WideChests__/graphics/entity/wide-chest-shadow.png"
		),
		["nullius-small-storage-chest-1"] = CreateWideLogisticChestSegments(
			"__WideChests__/graphics/entity/logistic-chest/storage-wide-chest.png",
			"__WideChests__/graphics/entity/logistic-chest/storage-hatch-door.png",
			"__WideChests__/graphics/entity/wide-chest-shadow.png"
		),
		["nullius-small-storage-chest-2"] = CreateWideLogisticChestSegments(
			"__WideChests__/graphics/entity/logistic-chest/storage-wide-chest.png",
			"__WideChests__/graphics/entity/logistic-chest/storage-hatch-door.png",
			"__WideChests__/graphics/entity/wide-chest-shadow.png"
		),
		["nullius-small-buffer-chest-1"] = CreateWideLogisticChestSegments(
			"__WideChests__/graphics/entity/logistic-chest/buffer-wide-chest.png",
			"__WideChests__/graphics/entity/logistic-chest/buffer-hatch-door.png",
			"__WideChests__/graphics/entity/wide-chest-shadow.png"
		),
		["nullius-small-buffer-chest-2"] = CreateWideLogisticChestSegments(
			"__WideChests__/graphics/entity/logistic-chest/buffer-wide-chest.png",
			"__WideChests__/graphics/entity/logistic-chest/buffer-hatch-door.png",
			"__WideChests__/graphics/entity/wide-chest-shadow.png"
		),
		["nullius-small-demand-chest-1"] = CreateWideLogisticChestSegments(
			"__WideChests__/graphics/entity/logistic-chest/requester-wide-chest.png",
			"__WideChests__/graphics/entity/logistic-chest/requester-hatch-door.png",
			"__WideChests__/graphics/entity/wide-chest-shadow.png"
		),
		["nullius-small-demand-chest-2"] = CreateWideLogisticChestSegments(
			"__WideChests__/graphics/entity/logistic-chest/requester-wide-chest.png",
			"__WideChests__/graphics/entity/logistic-chest/requester-hatch-door.png",
			"__WideChests__/graphics/entity/wide-chest-shadow.png"
		),

		[MergingChests.OTHER] = {
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
				scale = 0.5
			},
			shadow =
			{
				sprite = "__WideChests__/graphics/entity/wide-chest-shadow.png",
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
		["logistic-chest-passive-provider"] = CreateHighLogisticChestSegments(
			"__WideChests__/graphics/entity/logistic-chest/passive-provider-high-chest.png",
			"__WideChests__/graphics/entity/logistic-chest/passive-provider-hatch-door.png",
			"__WideChests__/graphics/entity/high-chest-shadow.png"
		),
		["logistic-chest-active-provider"] = CreateHighLogisticChestSegments(
			"__WideChests__/graphics/entity/logistic-chest/active-provider-high-chest.png",
			"__WideChests__/graphics/entity/logistic-chest/active-provider-hatch-door.png",
			"__WideChests__/graphics/entity/high-chest-shadow.png"
		),
		["logistic-chest-storage"] = CreateHighLogisticChestSegments(
			"__WideChests__/graphics/entity/logistic-chest/storage-high-chest.png",
			"__WideChests__/graphics/entity/logistic-chest/storage-hatch-door.png",
			"__WideChests__/graphics/entity/high-chest-shadow.png"
		),
		["logistic-chest-buffer"] = CreateHighLogisticChestSegments(
			"__WideChests__/graphics/entity/logistic-chest/buffer-high-chest.png",
			"__WideChests__/graphics/entity/logistic-chest/buffer-hatch-door.png",
			"__WideChests__/graphics/entity/high-chest-shadow.png"
		),
		["logistic-chest-requester"] = CreateHighLogisticChestSegments(
			"__WideChests__/graphics/entity/logistic-chest/requester-high-chest.png",
			"__WideChests__/graphics/entity/logistic-chest/requester-hatch-door.png",
			"__WideChests__/graphics/entity/high-chest-shadow.png"
		),

		["nullius-small-supply-chest-1"] = CreateHighLogisticChestSegments(
			"__WideChests__/graphics/entity/logistic-chest/passive-provider-high-chest.png",
			"__WideChests__/graphics/entity/logistic-chest/passive-provider-hatch-door.png",
			"__WideChests__/graphics/entity/high-chest-shadow.png"
		),
		["nullius-small-supply-chest-2"] = CreateHighLogisticChestSegments(
			"__WideChests__/graphics/entity/logistic-chest/passive-provider-high-chest.png",
			"__WideChests__/graphics/entity/logistic-chest/passive-provider-hatch-door.png",
			"__WideChests__/graphics/entity/high-chest-shadow.png"
		),
		["nullius-small-dispatch-chest-1"] = CreateHighLogisticChestSegments(
			"__WideChests__/graphics/entity/logistic-chest/active-provider-high-chest.png",
			"__WideChests__/graphics/entity/logistic-chest/active-provider-hatch-door.png",
			"__WideChests__/graphics/entity/high-chest-shadow.png"
		),
		["nullius-small-dispatch-chest-2"] = CreateHighLogisticChestSegments(
			"__WideChests__/graphics/entity/logistic-chest/active-provider-high-chest.png",
			"__WideChests__/graphics/entity/logistic-chest/active-provider-hatch-door.png",
			"__WideChests__/graphics/entity/high-chest-shadow.png"
		),
		["nullius-small-storage-chest-1"] = CreateHighLogisticChestSegments(
			"__WideChests__/graphics/entity/logistic-chest/storage-high-chest.png",
			"__WideChests__/graphics/entity/logistic-chest/storage-hatch-door.png",
			"__WideChests__/graphics/entity/high-chest-shadow.png"
		),
		["nullius-small-storage-chest-2"] = CreateHighLogisticChestSegments(
			"__WideChests__/graphics/entity/logistic-chest/storage-high-chest.png",
			"__WideChests__/graphics/entity/logistic-chest/storage-hatch-door.png",
			"__WideChests__/graphics/entity/high-chest-shadow.png"
		),
		["nullius-small-buffer-chest-1"] = CreateHighLogisticChestSegments(
			"__WideChests__/graphics/entity/logistic-chest/buffer-high-chest.png",
			"__WideChests__/graphics/entity/logistic-chest/buffer-hatch-door.png",
			"__WideChests__/graphics/entity/high-chest-shadow.png"
		),
		["nullius-small-buffer-chest-2"] = CreateHighLogisticChestSegments(
			"__WideChests__/graphics/entity/logistic-chest/buffer-high-chest.png",
			"__WideChests__/graphics/entity/logistic-chest/buffer-hatch-door.png",
			"__WideChests__/graphics/entity/high-chest-shadow.png"
		),
		["nullius-small-demand-chest-1"] = CreateHighLogisticChestSegments(
			"__WideChests__/graphics/entity/logistic-chest/requester-high-chest.png",
			"__WideChests__/graphics/entity/logistic-chest/requester-hatch-door.png",
			"__WideChests__/graphics/entity/high-chest-shadow.png"
		),
		["nullius-small-demand-chest-2"] = CreateHighLogisticChestSegments(
			"__WideChests__/graphics/entity/logistic-chest/requester-high-chest.png",
			"__WideChests__/graphics/entity/logistic-chest/requester-hatch-door.png",
			"__WideChests__/graphics/entity/high-chest-shadow.png"
		),

		[MergingChests.OTHER] = {
			entity =
			{
				sprite = "__WideChests__/graphics/entity/high-chest.png",
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
				sprite = "__WideChests__/graphics/entity/high-chest-shadow.png",
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
		[MergingChests.OTHER] = {
			entity =
			{
				sprite = "__WideChests__/graphics/entity/warehouse.png",
			
				top_left = { x = 4, y = 23, shift = { y = 16 } },
				top = { x = 68, y = 23, shift = { y = 16 } },
				top_right = { x = 132, y = 23, shift = { y = 16 } },
			
				left = {
					{ x = 4, y = 75 },
					{ x = 318, y = 75 },
					{ x = 632, y = 75 },
					{ x = 946, y = 75 },
					{ x = 1260, y = 75 },
					{ x = 1574, y = 75 }
				},
				middle = {
					{ x = 68, y = 75 },
					{ x = 382, y = 75 },
					{ x = 696, y = 75 },
					{ x = 1010, y = 75 },
					{ x = 1324, y = 75 },
					{ x = 1638, y = 75 }
				},
				right = {
					{ x = 132, y = 75 },
					{ x = 446, y = 75 },
					{ x = 760, y = 75 },
					{ x = 1074, y = 75 },
					{ x = 1388, y = 75 },
					{ x = 1702, y = 75 }
				},
			
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
				scale = 32.0 / 64.0
			},
			shadow =
			{
				sprite = "__WideChests__/graphics/entity/warehouse.png",
			
				top_right = { x = 197, y = 114, shift = { y = 19 } },
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
				shadow = true
			}
		}
	},
	trashdump_segments =
	{
		[MergingChests.OTHER] = {
			entity =
			{
				sprite = "__WideChests__/graphics/entity/trashdump-entity.png",
			
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
				sprite = "__WideChests__/graphics/entity/trashdump-shadow.png",
			
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

function TransformSegmentData(segment)
	local oldWidths = segment.widths
	segment.widths = { oldWidths.left, oldWidths.middle, oldWidths.right }
	
	local oldHeights = segment.heights
	segment.heights = { oldHeights.top, oldHeights.middle, oldHeights.bottom }
	
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
for _, segments in pairs(MergingChests.SpriteSegmentsData) do
	for __, segment in pairs(segments) do
		if segment.entity then
			TransformSegmentData(segment.entity)
		end
		if segment.shadow then
			TransformSegmentData(segment.shadow)
		end
	end
end