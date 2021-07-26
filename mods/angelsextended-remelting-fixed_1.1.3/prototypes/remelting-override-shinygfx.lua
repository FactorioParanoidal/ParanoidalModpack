local function iconset(name,suf,tier)
	data.raw["item"][name..suf].icons = {
		{
			icon = "__angelsextended-remelting-fixed__/graphics/icons/"..name.."-gfx"..tier..".png",
		},
		{
			icon = "__ShinyAngelGFX__/graphics/icons/num"..tier..".png",
		}
	}
	data.raw["assembling-machine"][name..suf].icons = {
		{
			icon = "__angelsextended-remelting-fixed__/graphics/icons/"..name.."-gfx"..tier..".png",
		},
		{
			icon = "__ShinyAngelGFX__/graphics/icons/num"..tier..".png",
		}
	}
end

if data.raw["assembling-machine"]["alloy-mixer"] then
	if data.raw["assembling-machine"]["alloy-mixer"] then
		iconset("alloy-mixer","","-1")
		data.raw["assembling-machine"]["alloy-mixer"].animation = {
			layers = {
				{
					filename = "__angelsextended-remelting-fixed__/graphics/entity/alloy-mixer/alloy-mixer.png",
					width = 224,
					height = 256,
					line_length = 6,
					frame_count = 36,
					shift = {0, -0.5},
					animation_speed = 0.5,
				},
				{
					filename = "__angelsextended-remelting-fixed__/graphics/entity/alloy-mixer/alloy-mixer-gfx-1.png",
					width = 224,
					height = 256,
					line_length = 6,
					frame_count = 36,
					shift = {0, -0.5},
					animation_speed = 0.5,
				}
			}
		}
		data.raw["assembling-machine"]["alloy-mixer"].fluid_boxes = {
			{
				production_type = "input",
				pipe_covers = pipecoverspictures2(),
				base_area = 10,
				base_level = -1,
				pipe_connections = {{ type="input", position = {2, 3} }}
			},
			{
				production_type = "input",
				pipe_covers = pipecoverspictures2(),
				base_area = 10,
				base_level = -1,
				pipe_connections = {{ type="input", position = {0, 3} }}
			},
			{
				production_type = "input",
				pipe_covers = pipecoverspictures2(),
				base_area = 10,
				base_level = -1,
				pipe_connections = {{ type="input", position = {-2, 3} }}
			},
			{
				production_type = "output",
				pipe_covers = pipecoverspictures2(),
				base_level = 1,
				pipe_connections = {{ position = {0, -3} }}
			},
		}

	end


	if data.raw["assembling-machine"]["alloy-mixer-2"] then
		iconset("alloy-mixer","-2","-2")
		data.raw["assembling-machine"]["alloy-mixer-2"].animation = {
			layers = {
				{
					filename = "__angelsextended-remelting-fixed__/graphics/entity/alloy-mixer/alloy-mixer.png",
					width = 224,
					height = 256,
					line_length = 6,
					frame_count = 36,
					shift = {0, -0.5},
					animation_speed = 0.5,
				},
				{
					filename = "__angelsextended-remelting-fixed__/graphics/entity/alloy-mixer/alloy-mixer-gfx-2.png",
					width = 224,
					height = 256,
					line_length = 6,
					frame_count = 36,
					shift = {0, -0.5},
					animation_speed = 0.5,
				}
			}
		}
		data.raw["assembling-machine"]["alloy-mixer-2"].fluid_boxes = {
			{
				production_type = "input",
				pipe_covers = pipecoverspictures2(),
				base_area = 10,
				base_level = -1,
				pipe_connections = {{ type="input", position = {2, 3} }}
			},
			{
				production_type = "input",
				pipe_covers = pipecoverspictures2(),
				base_area = 10,
				base_level = -1,
				pipe_connections = {{ type="input", position = {0, 3} }}
			},
			{
				production_type = "input",
				pipe_covers = pipecoverspictures2(),
				base_area = 10,
				base_level = -1,
				pipe_connections = {{ type="input", position = {-2, 3} }}
			},
			{
				production_type = "output",
				pipe_covers = pipecoverspictures2(),
				base_level = 1,
				pipe_connections = {{ position = {0, -3} }}
			},
		}

	end


	if data.raw["assembling-machine"]["alloy-mixer-3"] then
		iconset("alloy-mixer","-3","-3")
		data.raw["assembling-machine"]["alloy-mixer-3"].animation = {
			layers = {
				{
					filename = "__angelsextended-remelting-fixed__/graphics/entity/alloy-mixer/alloy-mixer.png",
					width = 224,
					height = 256,
					line_length = 6,
					frame_count = 36,
					shift = {0, -0.5},
					animation_speed = 0.5,
				},
				{
					filename = "__angelsextended-remelting-fixed__/graphics/entity/alloy-mixer/alloy-mixer-gfx-3.png",
					width = 224,
					height = 256,
					line_length = 6,
					frame_count = 36,
					shift = {0, -0.5},
					animation_speed = 0.5,
				}
			}
		}
		data.raw["assembling-machine"]["alloy-mixer-3"].fluid_boxes = {
			{
				production_type = "input",
				pipe_covers = pipecoverspictures2(),
				base_area = 10,
				base_level = -1,
				pipe_connections = {{ type="input", position = {2, 3} }}
			},
			{
				production_type = "input",
				pipe_covers = pipecoverspictures2(),
				base_area = 10,
				base_level = -1,
				pipe_connections = {{ type="input", position = {0, 3} }}
			},
			{
				production_type = "input",
				pipe_covers = pipecoverspictures2(),
				base_area = 10,
				base_level = -1,
				pipe_connections = {{ type="input", position = {-2, 3} }}
			},
			{
				production_type = "output",
				pipe_covers = pipecoverspictures2(),
				base_level = 1,
				pipe_connections = {{ position = {0, -3} }}
			},
		}

	end


	if data.raw["assembling-machine"]["alloy-mixer-4"] then
		iconset("alloy-mixer","-4","-4")
		data.raw["assembling-machine"]["alloy-mixer-4"].animation = {
			layers = {
				{
					filename = "__angelsextended-remelting-fixed__/graphics/entity/alloy-mixer/alloy-mixer.png",
					width = 224,
					height = 256,
					line_length = 6,
					frame_count = 36,
					shift = {0, -0.5},
					animation_speed = 0.5,
				},
				{
					filename = "__angelsextended-remelting-fixed__/graphics/entity/alloy-mixer/alloy-mixer-gfx-4.png",
					width = 224,
					height = 256,
					line_length = 6,
					frame_count = 36,
					shift = {0, -0.5},
					animation_speed = 0.5,
				}
			}
		}
		data.raw["assembling-machine"]["alloy-mixer-4"].fluid_boxes = {
			{
				production_type = "input",
				pipe_covers = pipecoverspictures2(),
				base_area = 10,
				base_level = -1,
				pipe_connections = {{ type="input", position = {2, 3} }}
			},
			{
				production_type = "input",
				pipe_covers = pipecoverspictures2(),
				base_area = 10,
				base_level = -1,
				pipe_connections = {{ type="input", position = {0, 3} }}
			},
			{
				production_type = "input",
				pipe_covers = pipecoverspictures2(),
				base_area = 10,
				base_level = -1,
				pipe_connections = {{ type="input", position = {-2, 3} }}
			},
			{
				production_type = "output",
				pipe_covers = pipecoverspictures2(),
				base_level = 1,
				pipe_connections = {{ position = {0, -3} }}
			},
		}

	end
end