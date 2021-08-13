local anim_speed = 0.2

data:extend({
	{
		type = "explosion",
		name = "uranium-explosion-LUQ",
		flags = {"not-on-map"},
		animations =
		{
			{
				filename = "__True-Nukes__/MushroomCloudInBuilt/graphics/explosion/LUQ.png",
				priority = "extra-high",
				width = 256,
				height = 256,
				frame_count = 64,
				line_length = 8,
				scale = 4,
				shift = {-16, -16},
				animation_speed = anim_speed
			},
		},
		light = {intensity = 10, size = 120},
		smoke = "smoke-fast",
		smoke_count = 2,
		smoke_slow_down_factor = 1,
		sound =
		{
			aggregation =
			{
				max_count = 1,
				remove = false
			},
			variations =
			{
				{
					filename = "__True-Nukes__/MushroomCloudInBuilt/sound/nuclear_detonation_in_vincinity_1.ogg", -- only audible up to 40 tiles
					volume = 0.5
				},
			}
		},
	},
	{
		type = "explosion",
		name = "uranium-explosion-RUQ",
		flags = {"not-on-map"},
		animations =
		{
			{
				filename = "__True-Nukes__/MushroomCloudInBuilt/graphics/explosion/RUQ.png",
				priority = "extra-high",
				width = 256,
				height = 256,
				frame_count = 64,
				line_length = 8,
				scale = 4,
				shift = {16, -16},
				animation_speed = anim_speed
			},
		},
		light = {intensity = 10, size = 120},
		smoke = "smoke-fast",
		smoke_count = 2,
		smoke_slow_down_factor = 1,
		sound =
		{
			aggregation =
			{
				max_count = 1,
				remove = false
			},
			variations =
			{
				{
					filename = "__True-Nukes__/MushroomCloudInBuilt/sound/nuclear_detonation_in_vincinity_1.ogg",
					volume = 0.5
				},
			}
		},
	},
	{
		type = "explosion",
		name = "uranium-explosion-LLQ",
		flags = {"not-on-map"},
		animations =
		{
			{
				filename = "__True-Nukes__/MushroomCloudInBuilt/graphics/explosion/LLQ.png",
				priority = "extra-high",
				width = 256,
				height = 256,
				frame_count = 64,
				line_length = 8,
				scale = 4,
				shift = {-16, 16},
				animation_speed = anim_speed
			},
		},
		light = {intensity = 10, size = 120},
		smoke = "smoke-fast",
		smoke_count = 2,
		smoke_slow_down_factor = 1,
		sound =
		{
			aggregation =
			{
				max_count = 1,
				remove = false
			},
			variations =
			{	
				{
					filename = "__True-Nukes__/MushroomCloudInBuilt/sound/nuclear_detonation_in_vincinity_1.ogg",
					volume = 0.5,
				},
			}
		},
	},
	{
		type = "explosion",
		name = "uranium-explosion-RLQ",
		flags = {"not-on-map"},
		animations =
		{
			{
				filename = "__True-Nukes__/MushroomCloudInBuilt/graphics/explosion/RLQ.png",
				priority = "extra-high",
				width = 256,
				height = 256,
				frame_count = 64,
				line_length = 8,
				scale = 4,
				shift = {16, 16},
				animation_speed = anim_speed
			},
		},
		light = {intensity = 10, size = 120},
		smoke = "smoke-fast",
		smoke_count = 2,
		smoke_slow_down_factor = 1,
		sound =
		{
			aggregation =
			{
				max_count = 1,
				remove = false
			},
			variations =
			{
				{
					filename = "__True-Nukes__/MushroomCloudInBuilt/sound/nuclear_detonation_in_vincinity_1.ogg",
					volume = 0.5
				},
			}
		},
	}
})
