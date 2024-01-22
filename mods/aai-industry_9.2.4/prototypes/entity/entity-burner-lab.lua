data.raw.lab.lab.fast_replaceable_group = data.raw.lab.lab.fast_replaceable_group or "lab"
local burner_lab = table.deepcopy(data.raw.lab.lab)
if not burner_lab then
	error("burner-lab can't copied!")
end
burner_lab.name = "burner-lab"
burner_lab.minable.result = "burner-lab"
burner_lab.next_upgrade = "lab"
burner_lab.energy_source = {
	type = "burner",
	fuel_category = "chemical",
	effectivity = 0.5, --0.9 drd
	energy_usage = "1500kW", --drd
	fuel_inventory_size = 1,
	emissions_per_minute = 40, --4 drd
	light_flicker = {
		minimum_light_size = 1,
		light_intensity_to_size_coefficient = 0.25,
		color = { 1, 0.4, 0 },
		minimum_intensity = 0.1,
		maximum_intensity = 0.3,
	},
	smoke = {
		{
			name = "smoke",
			deviation = { 0.1, 0.1 },
			position = { 0.0, -0.9 },
			frequency = 4,
			--drd
			color = {
				r = 0,
				g = 0,
				b = 0,
			},
		},
	},
}

burner_lab.icon = "__aai-industry__/graphics/icons/burner-lab.png"
burner_lab.icon_size = 64
burner_lab.icon_mipmaps = 1
burner_lab.on_animation = {
	layers = {
		{
			filename = "__aai-industry__/graphics/entity/burner-lab/burner-lab.png",
			width = 97,
			height = 87,
			frame_count = 33,
			line_length = 11,
			animation_speed = 1 / 3,
			shift = util.by_pixel(0, 1.5),
			hr_version = {
				filename = "__aai-industry__/graphics/entity/burner-lab/hr-burner-lab.png",
				width = 194,
				height = 174,
				frame_count = 33,
				line_length = 11,
				animation_speed = 1 / 3,
				shift = util.by_pixel(0, 1.5),
				scale = 0.5,
			},
		},
		{
			filename = "__aai-industry__/graphics/entity/burner-lab/burner-lab-light.png",
			width = 97,
			height = 87,
			frame_count = 33,
			line_length = 11,
			animation_speed = 1 / 3,
			shift = util.by_pixel(0, 1.5),
			draw_as_light = true,
			hr_version = {
				filename = "__aai-industry__/graphics/entity/burner-lab/hr-burner-lab-light.png",
				width = 194,
				height = 174,
				frame_count = 33,
				line_length = 11,
				animation_speed = 1 / 3,
				shift = util.by_pixel(0, 1.5),
				draw_as_light = true,
				scale = 0.5,
			},
		},
		{
			filename = "__base__/graphics/entity/lab/lab-integration.png",
			width = 122,
			height = 81,
			frame_count = 1,
			line_length = 1,
			repeat_count = 33,
			animation_speed = 1 / 3,
			shift = util.by_pixel(0, 15.5),
			hr_version = {
				filename = "__base__/graphics/entity/lab/hr-lab-integration.png",
				width = 242,
				height = 162,
				frame_count = 1,
				line_length = 1,
				repeat_count = 33,
				animation_speed = 1 / 3,
				shift = util.by_pixel(0, 15.5),
				scale = 0.5,
			},
		},
		{
			filename = "__base__/graphics/entity/lab/lab-shadow.png",
			width = 122,
			height = 68,
			frame_count = 1,
			line_length = 1,
			repeat_count = 33,
			animation_speed = 1 / 3,
			shift = util.by_pixel(13, 11),
			draw_as_shadow = true,
			hr_version = {
				filename = "__base__/graphics/entity/lab/hr-lab-shadow.png",
				width = 242,
				height = 136,
				frame_count = 1,
				line_length = 1,
				repeat_count = 33,
				animation_speed = 1 / 3,
				shift = util.by_pixel(13, 11),
				scale = 0.5,
				draw_as_shadow = true,
			},
		},
	},
}
burner_lab.off_animation = {
	layers = {
		{
			filename = "__aai-industry__/graphics/entity/burner-lab/burner-lab.png",
			width = 97,
			height = 87,
			frame_count = 1,
			shift = util.by_pixel(0, 1.5),
			hr_version = {
				filename = "__aai-industry__/graphics/entity/burner-lab/hr-burner-lab.png",
				width = 194,
				height = 174,
				frame_count = 1,
				shift = util.by_pixel(0, 1.5),
				scale = 0.5,
			},
		},
		{
			filename = "__base__/graphics/entity/lab/lab-integration.png",
			width = 122,
			height = 81,
			frame_count = 1,
			shift = util.by_pixel(0, 15.5),
			hr_version = {
				filename = "__base__/graphics/entity/lab/hr-lab-integration.png",
				width = 242,
				height = 162,
				frame_count = 1,
				shift = util.by_pixel(0, 15.5),
				scale = 0.5,
			},
		},
		{
			filename = "__base__/graphics/entity/lab/lab-shadow.png",
			width = 122,
			height = 68,
			frame_count = 1,
			shift = util.by_pixel(13, 11),
			draw_as_shadow = true,
			hr_version = {
				filename = "__base__/graphics/entity/lab/hr-lab-shadow.png",
				width = 242,
				height = 136,
				frame_count = 1,
				shift = util.by_pixel(13, 11),
				draw_as_shadow = true,
				scale = 0.5,
			},
		},
	},
}
burner_lab.module_specification = nil

data:extend({ burner_lab })
