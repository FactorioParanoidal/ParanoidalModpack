local graphics = {}
local mod_name = "__BigLight__/mods/krastorio2"

local function electric_mining_drill_status_leds_working_visualisation()
	local led_blend_mode = nil
	local led_tint = {1,1,1,0.5}
	return
	{
	  apply_tint = "status",
	  always_draw = true,
	  draw_as_sprite = true,
	  -- draw_as_light = true,
	  north_animation =
	  {
		filename = "__base__/graphics/entity/electric-mining-drill/electric-mining-drill-N-light.png",
		width = 16,
		height = 16,
		blend_mode = led_blend_mode,
		tint = led_tint,
		shift = util.by_pixel(26, -47),
		hr_version =
		{
		  filename = "__base__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-N-light.png",
		  width = 32,
		  height = 32,
		  blend_mode = led_blend_mode,
		  tint = led_tint,
		  shift = util.by_pixel(26, -47),
		  scale = 0.5,
		}
	  },
	  east_animation =
	  {
		filename = "__base__/graphics/entity/electric-mining-drill/electric-mining-drill-E-light.png",
		width = 16,
		height = 18,
		blend_mode = led_blend_mode,
		tint = led_tint,
		shift = util.by_pixel(38, -32),
		hr_version =
		{
		  filename = "__base__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-E-light.png",
		  width = 32,
		  height = 34,
		  blend_mode = led_blend_mode,
		  tint = led_tint,
		  shift = util.by_pixel(38, -32),
		  scale = 0.5,
		}
	  },
	  south_animation =
	  {
		filename = "__base__/graphics/entity/electric-mining-drill/electric-mining-drill-S-light.png",
		width = 20,
		height = 24,
		blend_mode = led_blend_mode,
		tint = led_tint,
		shift = util.by_pixel(26, 26),
		hr_version =
		{
		  filename = "__base__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-S-light.png",
		  width = 38,
		  height = 46,
		  blend_mode = led_blend_mode,
		  tint = led_tint,
		  shift = util.by_pixel(26, 26),
		  scale = 0.5,
		}
	  },
	  west_animation =
	  {
		filename = "__base__/graphics/entity/electric-mining-drill/electric-mining-drill-W-light.png",
		width = 18,
		height = 18,
		blend_mode = led_blend_mode,
		tint = led_tint,
		shift = util.by_pixel(-40, -32),
		hr_version =
		{
		  filename = "__base__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-W-light.png",
		  width = 32,
		  height = 34,
		  blend_mode = led_blend_mode,
		  tint = led_tint,
		  shift = util.by_pixel(-39, -32),
		  scale = 0.5,
		}
	  }
	}
  end



local function graphics_set(tier)
	return {
			  drilling_vertical_movement_duration = 10 / electric_drill_animation_speed,
			  animation_progress = 1,
			  min_animation_progress = 0,
			  max_animation_progress = 30,
		
			  status_colors = electric_mining_drill_status_colors(),
		
			  circuit_connector_layer = "object",
			  circuit_connector_secondary_draw_order = { north = 14, east = 30, south = 30, west = 30 },
		
			  animation =
			  {
				north =
				{
				  layers =
				  {
					{
					  priority = "high",
					  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-N.png",
					  line_length = 1,
					  width = 96,
					  height = 104,
					  frame_count = 1,
					  animation_speed = electric_drill_animation_speed,
					  direction_count = 1,
					  shift = util.by_pixel(0, -4),
					  repeat_count = 5,
					  hr_version =
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-N.png",
						line_length = 1,
						width = 190,
						height = 208,
						frame_count = 1,
						animation_speed = electric_drill_animation_speed,
						direction_count = 1,
						shift = util.by_pixel(0, -4),
						repeat_count = 5,
						scale = 0.5,
					  }
					},
					{
					  priority = "high",
					  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-N-output.png",
					  line_length = 5,
					  width = 32,
					  height = 34,
					  frame_count = 5,
					  animation_speed = electric_drill_animation_speed,
					  direction_count = 1,
					  shift = util.by_pixel(-4, -44),
					  hr_version =
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-N-output.png",
						line_length = 5,
						width = 60,
						height = 66,
						frame_count = 5,
						animation_speed = electric_drill_animation_speed,
						direction_count = 1,
						shift = util.by_pixel(-3, -44),
						scale = 0.5,
					  }
					},
					{
					  priority = "high",
					  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-N-shadow.png",
					  line_length = 1,
					  width = 106,
					  height = 104,
					  frame_count = 1,
					  animation_speed = electric_drill_animation_speed,
					  draw_as_shadow = true,
					  shift = util.by_pixel(6, -4),
					  repeat_count = 5,
					  hr_version =
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-N-shadow.png",
						line_length = 1,
						width = 212,
						height = 204,
						frame_count = 1,
						animation_speed = electric_drill_animation_speed,
						draw_as_shadow = true,
						shift = util.by_pixel(6, -3),
						repeat_count = 5,
						scale = 0.5,
					  }
					}
				  }
				},
				east =
				{
				  layers =
				  {
					{
					  priority = "high",
					  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-E.png",
					  line_length = 1,
					  width = 96,
					  height = 94,
					  frame_count = 1,
					  animation_speed = electric_drill_animation_speed,
					  direction_count = 1,
					  shift = util.by_pixel(0, -4),
					  repeat_count = 5,
					  hr_version =
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-E.png",
						line_length = 1,
						width = 192,
						height = 188,
						frame_count = 1,
						animation_speed = electric_drill_animation_speed,
						direction_count = 1,
						shift = util.by_pixel(0, -4),
						repeat_count = 5,
						scale = 0.5,
					  }
					},
					{
					  priority = "high",
					  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-E-output.png",
					  line_length = 5,
					  width = 26,
					  height = 38,
					  frame_count = 5,
					  animation_speed = electric_drill_animation_speed,
					  direction_count = 1,
					  shift = util.by_pixel(30, -8),
					  hr_version =
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-E-output.png",
						line_length = 5,
						width = 50,
						height = 74,
						frame_count = 5,
						animation_speed = electric_drill_animation_speed,
						direction_count = 1,
						shift = util.by_pixel(30, -8),
						scale = 0.5,
					  }
					},
					{
					  priority = "high",
					  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-E-shadow.png",
					  line_length = 1,
					  width = 112,
					  height = 92,
					  frame_count = 1,
					  animation_speed = electric_drill_animation_speed,
					  draw_as_shadow = true,
					  shift = util.by_pixel(10, 2),
					  repeat_count = 5,
					  hr_version =
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-E-shadow.png",
						line_length = 1,
						width = 222,
						height = 182,
						frame_count = 1,
						animation_speed = electric_drill_animation_speed,
						draw_as_shadow = true,
						shift = util.by_pixel(10, 2),
						repeat_count = 5,
						scale = 0.5,
					  }
					}
				  }
				},
				south =
				{
				  layers =
				  {
					{
					  priority = "high",
					  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-S.png",
					  line_length = 1,
					  width = 92,
					  height = 98,
					  frame_count = 1,
					  animation_speed = electric_drill_animation_speed,
					  direction_count = 1,
					  shift = util.by_pixel(0, -2),
					  repeat_count = 5,
					  hr_version =
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-S.png",
						line_length = 1,
						width = 184,
						height = 192,
						frame_count = 1,
						animation_speed = electric_drill_animation_speed,
						direction_count = 1,
						shift = util.by_pixel(0, -1),
						repeat_count = 5,
						scale = 0.5,
					  }
					},
					{
					  priority = "high",
					  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-S-shadow.png",
					  line_length = 1,
					  width = 106,
					  height = 102,
					  frame_count = 1,
					  animation_speed = electric_drill_animation_speed,
					  draw_as_shadow = true,
					  shift = util.by_pixel(6, 2),
					  repeat_count = 5,
					  hr_version =
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-S-shadow.png",
						line_length = 1,
						width = 212,
						height = 204,
						frame_count = 1,
						animation_speed = electric_drill_animation_speed,
						draw_as_shadow = true,
						shift = util.by_pixel(6, 2),
						repeat_count = 5,
						scale = 0.5,
					  }
					}
				  }
				},
				west =
				{
				  layers =
				  {
					{
					  priority = "high",
					  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-W.png",
					  line_length = 1,
					  width = 96,
					  height = 94,
					  frame_count = 1,
					  animation_speed = electric_drill_animation_speed,
					  direction_count = 1,
					  shift = util.by_pixel(0, -4),
					  repeat_count = 5,
					  hr_version =
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-W.png",
						line_length = 1,
						width = 192,
						height = 188,
						frame_count = 1,
						animation_speed = electric_drill_animation_speed,
						direction_count = 1,
						shift = util.by_pixel(0, -4),
						repeat_count = 5,
						scale = 0.5,
					  }
					},
					{
					  priority = "high",
					  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-W-output.png",
					  line_length = 5,
					  width = 24,
					  height = 28,
					  frame_count = 5,
					  animation_speed = electric_drill_animation_speed,
					  direction_count = 1,
					  shift = util.by_pixel(-30, -12),
					  hr_version =
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-W-output.png",
						line_length = 5,
						width = 50,
						height = 60,
						frame_count = 5,
						animation_speed = electric_drill_animation_speed,
						direction_count = 1,
						shift = util.by_pixel(-31, -13),
						scale = 0.5,
					  }
					},
					{
					  priority = "high",
					  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-W-shadow.png",
					  line_length = 1,
					  width = 102,
					  height = 92,
					  frame_count = 1,
					  animation_speed = electric_drill_animation_speed,
					  draw_as_shadow = true,
					  shift = util.by_pixel(-6, 2),
					  repeat_count = 5,
					  hr_version =
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-W-shadow.png",
						line_length = 1,
						width = 200,
						height = 182,
						frame_count = 1,
						animation_speed = electric_drill_animation_speed,
						draw_as_shadow = true,
						shift = util.by_pixel(-5, 2),
						repeat_count = 5,
						scale = 0.5,
					  }
					}
				  }
				},
			  },
		
			  shift_animation_waypoints =
			  {
				-- Movement should be between 0.25-0.4 distance
				-- Bounds -0.5 - 0.6
				north = { {0, 0}, {0, -0.3}, {0, 0.1}, {0, 0.5}, {0, 0.2}, {0, -0.1}, {0, -0.5}, {0, -0.15}, {0, 0.25}, {0, 0.6}, {0, 0.3} },
				-- Bounds -1 - 0
				east = { {0, 0}, {-0.4, 0}, {-0.1, 0}, {-0.5, 0}, {-0.75, 0}, {-1, 0}, {-0.65, 0}, {-0.3, 0}, {-0.9, 0}, {-0.6, 0}, {-0.3, 0} },
				-- Bounds -1 - 0
				south = { {0, 0}, {0, -0.4}, {0, -0.1}, {0, -0.5}, {0, -0.75}, {0, -1}, {0, -0.65}, {0, -0.3}, {0, -0.9}, {0, -0.6}, {0, -0.3} },
				-- Bounds 0 - 1
				west = { {0, 0}, {0.4, 0}, {0.1, 0}, {0.5, 0}, {0.75, 0}, {1, 0}, {0.65, 0}, {0.3, 0}, {0.9, 0}, {0.6, 0}, {0.3, 0} },
			  },
		
			  shift_animation_waypoint_stop_duration = 195 / electric_drill_animation_speed,
			  shift_animation_transition_duration = 30 / electric_drill_animation_speed,
		
			  working_visualisations =
			  {
				-- dust animation 1
				{
				  constant_speed = true,
				  synced_fadeout = true,
				  align_to_waypoint = true,
				  apply_tint = "resource-color",
				  animation = electric_mining_drill_smoke(),
				  north_position = { 0, 0.25 },
				  east_position = { 0, 0 },
				  south_position = { 0, 0.25 },
				  west_position = { 0, 0 },
				},
		
				-- dust animation directional 1
				{
				  constant_speed = true,
				  fadeout = true,
				  apply_tint = "resource-color",
				  north_animation =
				  {
					layers =
					{
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-N-smoke.png",
						line_length = 5,
						width = 24,
						height = 30,
						frame_count = 10,
						animation_speed = electric_drill_animation_speed,
						direction_count = 1,
						shift = util.by_pixel(-2, -44),
						hr_version =
						{
						  priority = "high",
						  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-N-smoke.png",
						  line_length = 5,
						  width = 42,
						  height = 58,
						  frame_count = 10,
						  animation_speed = electric_drill_animation_speed,
						  direction_count = 1,
						  shift = util.by_pixel(-1, -44),
						  scale = 0.5,
						}
					  }
					}
				  },
				  east_animation = nil,
				  south_animation = nil,
				  west_animation = nil,
				},
		
				-- drill back animation
				{
				  animated_shift = true,
				  always_draw = true,
				  north_animation =
				  {
					layers =
					{
					  electric_mining_drill_animation(),
					  electric_mining_drill_shadow_animation()
					}
				  },
				  east_animation =
				  {
					layers =
					{
					  electric_mining_drill_horizontal_animation(),
					  electric_mining_drill_horizontal_shadow_animation()
					}
				  },
				  south_animation =
				  {
					layers =
					{
					  electric_mining_drill_animation(),
					  electric_mining_drill_shadow_animation()
					}
				  },
				  west_animation =
				  {
					layers =
					{
					  electric_mining_drill_horizontal_animation(),
					  electric_mining_drill_horizontal_shadow_animation()
					}
				  },
				},
		
				-- dust animation 2
				{
				  constant_speed = true,
				  synced_fadeout = true,
				  align_to_waypoint = true,
				  apply_tint = "resource-color",
				  animation = electric_mining_drill_smoke_front(),
				  north_position = { 0, 0.25 },
				  east_position = { 0, 0 },
				  south_position = { 0, 0.25 },
				  west_position = { 0, 0 },
				},
		
				-- dust animation directional 2
				{
				  constant_speed = true,
				  fadeout = true,
				  apply_tint = "resource-color",
				  north_animation = nil,
				  east_animation =
				  {
					layers =
					{
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-E-smoke.png",
						line_length = 5,
						width = 24,
						height = 28,
						frame_count = 10,
						animation_speed = electric_drill_animation_speed,
						direction_count = 1,
						shift = util.by_pixel(24, -12),
						hr_version =
						{
						  priority = "high",
						  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-E-smoke.png",
						  line_length = 5,
						  width = 46,
						  height = 56,
						  frame_count = 10,
						  animation_speed = electric_drill_animation_speed,
						  direction_count = 1,
						  shift = util.by_pixel(24, -12),
						  scale = 0.5,
						}
					  }
					}
				  },
				  south_animation =
				  {
					layers =
					{
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-S-smoke.png",
						line_length = 5,
						width = 24,
						height = 18,
						frame_count = 10,
						animation_speed = electric_drill_animation_speed,
						direction_count = 1,
						shift = util.by_pixel(-2, 20),
						hr_version =
						{
						  priority = "high",
						  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-S-smoke.png",
						  line_length = 5,
						  width = 48,
						  height = 36,
						  frame_count = 10,
						  animation_speed = electric_drill_animation_speed,
						  direction_count = 1,
						  shift = util.by_pixel(-2, 20),
						  scale = 0.5,
						}
					  }
					}
				  },
				  west_animation =
				  {
					layers =
					{
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-W-smoke.png",
						line_length = 5,
						width = 26,
						height = 30,
						frame_count = 10,
						animation_speed = electric_drill_animation_speed,
						direction_count = 1,
						shift = util.by_pixel(-26, -12),
						hr_version =
						{
						  priority = "high",
						  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-W-smoke.png",
						  line_length = 5,
						  width = 46,
						  height = 54,
						  frame_count = 10,
						  animation_speed = electric_drill_animation_speed,
						  direction_count = 1,
						  shift = util.by_pixel(-25, -11),
						  scale = 0.5,
						}
					  }
					}
				  }
				},
		
				-- drill front animation
				{
				  animated_shift = true,
				  always_draw = true,
				  --north_animation = util.empty_sprite(),
				  east_animation = electric_mining_drill_horizontal_front_animation(),
				  --south_animation = util.empty_sprite(),
				  west_animation = electric_mining_drill_horizontal_front_animation(),
				},
		
				-- front frame
				{
				  always_draw = true,
				  north_animation = nil,
				  east_animation =
				  {
					priority = "high",
					filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-E-front.png",
					line_length = 1,
					width = 66,
					height = 74,
					frame_count = 1,
					animation_speed = electric_drill_animation_speed,
					direction_count = 1,
					shift = util.by_pixel(22, 10),
					hr_version =
					{
					  priority = "high",
					  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-E-front.png",
					  line_length = 1,
					  width = 136,
					  height = 148,
					  frame_count = 1,
					  animation_speed = electric_drill_animation_speed,
					  direction_count = 1,
					  shift = util.by_pixel(21, 10),
					  scale = 0.5,
					}
				  },
				  south_animation =
				  {
					layers =
					{
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-S-output.png",
						line_length = 5,
						width = 44,
						height = 28,
						frame_count = 5,
						animation_speed = electric_drill_animation_speed,
						shift = util.by_pixel(-2, 34),
						hr_version =
						{
						  priority = "high",
						  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-S-output.png",
						  line_length = 5,
						  width = 84,
						  height = 56,
						  frame_count = 5,
						  animation_speed = electric_drill_animation_speed,
						  shift = util.by_pixel(-1, 34),
						  scale = 0.5,
						}
					  },
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-S-front.png",
						line_length = 1,
						width = 96,
						height = 54,
						frame_count = 1,
						animation_speed = electric_drill_animation_speed,
						repeat_count = 5,
						shift = util.by_pixel(0, 26),
						hr_version =
						{
						  priority = "high",
						  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-S-front.png",
						  line_length = 1,
						  width = 190,
						  height = 104,
						  frame_count = 1,
						  animation_speed = electric_drill_animation_speed,
						  repeat_count = 5,
						  shift = util.by_pixel(0, 27),
						  scale = 0.5,
						}
					  },
					}
				  },
				  west_animation =
				  {
					priority = "high",
					filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-W-front.png",
					line_length = 1,
					width = 68,
					height = 70,
					frame_count = 1,
					animation_speed = electric_drill_animation_speed,
					direction_count = 1,
					shift = util.by_pixel(-22, 12),
					hr_version =
					{
					  priority = "high",
					  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-W-front.png",
					  line_length = 1,
					  width = 134,
					  height = 140,
					  frame_count = 1,
					  animation_speed = electric_drill_animation_speed,
					  direction_count = 1,
					  shift = util.by_pixel(-22, 12),
					  scale = 0.5,
					}
				  }
				},
		
				-- LEDs
				electric_mining_drill_status_leds_working_visualisation(),
		
				-- light
				electric_mining_drill_primary_light,
				electric_mining_drill_secondary_light
			  }
            }
end
		
local function wet_mining_graphics_set(tier)
	return {
			  drilling_vertical_movement_duration = 10 / electric_drill_animation_speed,
			  animation_progress = 1,
			  min_animation_progress = 0,
			  max_animation_progress = 30,
		
			  status_colors = electric_mining_drill_status_colors(),
		
			  circuit_connector_layer = "object",
			  circuit_connector_secondary_draw_order = { north = 14, east = 48, south = 48, west = 48 },
		
			  animation =
			  {
				north =
				{
				  layers =
				  {
					{
					  priority = "high",
					  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-N-wet.png",
					  line_length = 1,
					  width = 96,
					  height = 100,
					  frame_count = 1,
					  animation_speed = electric_drill_animation_speed,
					  direction_count = 1,
					  shift = util.by_pixel(0, -8),
					  repeat_count = 5,
					  hr_version =
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-N-wet.png",
						line_length = 1,
						width = 190,
						height = 198,
						frame_count = 1,
						animation_speed = electric_drill_animation_speed,
						direction_count = 1,
						shift = util.by_pixel(0, -7),
						repeat_count = 5,
						scale = 0.5,
					  }
					},
					{
					  priority = "high",
					  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-N-output.png",
					  line_length = 5,
					  width = 32,
					  height = 34,
					  frame_count = 5,
					  animation_speed = electric_drill_animation_speed,
					  direction_count = 1,
					  shift = util.by_pixel(-4, -44),
					  hr_version =
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-N-output.png",
						line_length = 5,
						width = 60,
						height = 66,
						frame_count = 5,
						animation_speed = electric_drill_animation_speed,
						direction_count = 1,
						shift = util.by_pixel(-3, -44),
						scale = 0.5,
					  }
					},
					{
					  priority = "high",
					  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-N-wet-shadow.png",
					  line_length = 1,
					  width = 124,
					  height = 110,
					  frame_count = 1,
					  animation_speed = electric_drill_animation_speed,
					  draw_as_shadow = true,
					  shift = util.by_pixel(12, 2),
					  repeat_count = 5,
					  hr_version =
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-N-wet-shadow.png",
						line_length = 1,
						width = 248,
						height = 222,
						frame_count = 1,
						animation_speed = electric_drill_animation_speed,
						draw_as_shadow = true,
						shift = util.by_pixel(12, 1),
						repeat_count = 5,
						scale = 0.5,
					  }
					}
				  }
				},
				west =
				{
				  layers =
				  {
					{
					  priority = "high",
					  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-W-wet.png",
					  line_length = 1,
					  width = 96,
					  height = 106,
					  frame_count = 1,
					  animation_speed = electric_drill_animation_speed,
					  direction_count = 1,
					  shift = util.by_pixel(2, -10),
					  repeat_count = 5,
					  hr_version =
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-W-wet.png",
						line_length = 1,
						width = 194,
						height = 208,
						frame_count = 1,
						animation_speed = electric_drill_animation_speed,
						direction_count = 1,
						shift = util.by_pixel(1, -9),
						repeat_count = 5,
						scale = 0.5,
					  }
					},
					{
					  priority = "high",
					  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-W-output.png",
					  line_length = 5,
					  width = 24,
					  height = 28,
					  frame_count = 5,
					  animation_speed = electric_drill_animation_speed,
					  direction_count = 1,
					  shift = util.by_pixel(-30, -12),
					  hr_version =
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-W-output.png",
						line_length = 5,
						width = 50,
						height = 60,
						frame_count = 5,
						animation_speed = electric_drill_animation_speed,
						direction_count = 1,
						shift = util.by_pixel(-31, -13),
						scale = 0.5,
					  }
					},
					{
					  priority = "high",
					  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-W-wet-shadow.png",
					  line_length = 1,
					  width = 132,
					  height = 102,
					  frame_count = 1,
					  animation_speed = electric_drill_animation_speed,
					  draw_as_shadow = true,
					  shift = util.by_pixel(8, 6),
					  repeat_count = 5,
					  hr_version =
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-W-wet-shadow.png",
						line_length = 1,
						width = 260,
						height = 202,
						frame_count = 1,
						animation_speed = electric_drill_animation_speed,
						draw_as_shadow = true,
						shift = util.by_pixel(9, 6),
						repeat_count = 5,
						scale = 0.5,
					  }
					}
				  }
				},
				south =
				{
				  layers =
				  {
					{
					  priority = "high",
					  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-S-wet.png",
					  line_length = 1,
					  width = 98,
					  height = 106,
					  frame_count = 1,
					  animation_speed = electric_drill_animation_speed,
					  direction_count = 1,
					  shift = util.by_pixel(0, -6),
					  repeat_count = 5,
					  hr_version =
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-S-wet.png",
						line_length = 1,
						width = 192,
						height = 208,
						frame_count = 1,
						animation_speed = electric_drill_animation_speed,
						direction_count = 1,
						shift = util.by_pixel(1, -5),
						repeat_count = 5,
						scale = 0.5,
					  }
					},
					{
					  priority = "high",
					  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-S-wet-shadow.png",
					  line_length = 1,
					  width = 124,
					  height = 98,
					  frame_count = 1,
					  animation_speed = electric_drill_animation_speed,
					  draw_as_shadow = true,
					  shift = util.by_pixel(12, 4),
					  repeat_count = 5,
					  hr_version =
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-S-wet-shadow.png",
						line_length = 1,
						width = 248,
						height = 192,
						frame_count = 1,
						animation_speed = electric_drill_animation_speed,
						draw_as_shadow = true,
						shift = util.by_pixel(12, 5),
						repeat_count = 5,
						scale = 0.5,
					  }
					}
				  }
				},
				east =
				{
				  layers =
				  {
					{
					  priority = "high",
					  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-E-wet.png",
					  line_length = 1,
					  width = 98,
					  height = 106,
					  frame_count = 1,
					  animation_speed = electric_drill_animation_speed,
					  direction_count = 1,
					  shift = util.by_pixel(-2, -10),
					  repeat_count = 5,
					  hr_version =
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-E-wet.png",
						line_length = 1,
						width = 194,
						height = 208,
						frame_count = 1,
						animation_speed = electric_drill_animation_speed,
						direction_count = 1,
						shift = util.by_pixel(-2, -9),
						repeat_count = 5,
						scale = 0.5,
					  }
					},
					{
					  priority = "high",
					  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-E-output.png",
					  line_length = 5,
					  width = 26,
					  height = 38,
					  frame_count = 5,
					  animation_speed = electric_drill_animation_speed,
					  direction_count = 1,
					  shift = util.by_pixel(30, -8),
					  hr_version =
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-E-output.png",
						line_length = 5,
						width = 50,
						height = 74,
						frame_count = 5,
						animation_speed = electric_drill_animation_speed,
						direction_count = 1,
						shift = util.by_pixel(30, -8),
						scale = 0.5,
					  }
					},
					{
					  priority = "high",
					  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-E-wet-shadow.png",
					  line_length = 1,
					  width = 112,
					  height = 100,
					  frame_count = 1,
					  animation_speed = electric_drill_animation_speed,
					  draw_as_shadow = true,
					  shift = util.by_pixel(10, 6),
					  repeat_count = 5,
					  hr_version =
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-E-wet-shadow.png",
						line_length = 1,
						width = 226,
						height = 202,
						frame_count = 1,
						animation_speed = electric_drill_animation_speed,
						draw_as_shadow = true,
						shift = util.by_pixel(9, 5),
						repeat_count = 5,
						scale = 0.5,
					  }
					}
				  }
				},
			  },
		
			  shift_animation_waypoints =
			  {
				-- Movement should be between 0.25-0.4 distance
				-- Bounds -0.5 - 0.2
				north = { {0, 0}, {0, -0.4}, {0, -0.1}, {0, 0.2} },
				-- Bounds -0.3 - 0
				east = { {0, 0}, {-0.3, 0}, {0, 0}, {-0.25, 0} },
				-- Bounds -0.7 - 0
				south = { {0, 0}, {0, -0.4}, {0, -0.7}, {0, -0.3} },
				-- Bounds 0 - 0.3
				west = { {0, 0}, {0.3, 0}, {0, 0}, {0.25, 0} },
			  },
		
			  shift_animation_waypoint_stop_duration = 195 / electric_drill_animation_speed,
			  shift_animation_transition_duration = 30 / electric_drill_animation_speed,
		
			  working_visualisations =
			  {
				-- dust animation 1
				{
				  constant_speed = true,
				  synced_fadeout = true,
				  align_to_waypoint = true,
				  apply_tint = "resource-color",
				  animation = electric_mining_drill_smoke(),
				  north_position = { 0, 0.25 },
				  east_position = { 0, 0 },
				  south_position = { 0, 0.25 },
				  west_position = { 0, 0 },
				},
		
				-- dust animation directional 1
				{
				  constant_speed = true,
				  fadeout = true,
				  apply_tint = "resource-color",
				  north_animation =
				  {
					layers =
					{
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-N-smoke.png",
						line_length = 5,
						width = 24,
						height = 30,
						frame_count = 10,
						animation_speed = electric_drill_animation_speed,
						direction_count = 1,
						shift = util.by_pixel(-2, -44),
						hr_version =
						{
						  priority = "high",
						  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-N-smoke.png",
						  line_length = 5,
						  width = 42,
						  height = 58,
						  frame_count = 10,
						  animation_speed = electric_drill_animation_speed,
						  direction_count = 1,
						  shift = util.by_pixel(-1, -44),
						  scale = 0.5,
						}
					  }
					}
				  },
				  east_animation = nil,
				  south_animation = nil,
				  west_animation = nil
				},
		
				-- drill back animation
				{
				  animated_shift = true,
				  always_draw = true,
				  north_animation =
				  {
					layers =
					{
					  electric_mining_drill_animation(),
					  electric_mining_drill_shadow_animation()
					}
				  },
				  east_animation =
				  {
					layers =
					{
					  electric_mining_drill_horizontal_animation(),
					  electric_mining_drill_horizontal_shadow_animation()
					}
				  },
				  south_animation =
				  {
					layers =
					{
					  electric_mining_drill_animation(),
					  electric_mining_drill_shadow_animation()
					}
				  },
				  west_animation =
				  {
					layers =
					{
					  electric_mining_drill_horizontal_animation(),
					  electric_mining_drill_horizontal_shadow_animation()
					}
				  },
				},
		
				-- dust animation 2
				{
				  constant_speed = true,
				  synced_fadeout = true,
				  align_to_waypoint = true,
				  apply_tint = "resource-color",
				  animation = electric_mining_drill_smoke_front(),
				},
		
				-- dust animation directional 2
				{
				  constant_speed = true,
				  fadeout = true,
				  apply_tint = "resource-color",
				  north_animation = nil,
				  east_animation =
				  {
					layers =
					{
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-E-smoke.png",
						line_length = 5,
						width = 24,
						height = 28,
						frame_count = 10,
						animation_speed = electric_drill_animation_speed,
						direction_count = 1,
						shift = util.by_pixel(24, -12),
						hr_version =
						{
						  priority = "high",
						  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-E-smoke.png",
						  line_length = 5,
						  width = 46,
						  height = 56,
						  frame_count = 10,
						  animation_speed = electric_drill_animation_speed,
						  direction_count = 1,
						  shift = util.by_pixel(24, -12),
						  scale = 0.5,
						}
					  }
					}
				  },
				  south_animation =
				  {
					layers =
					{
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-S-smoke.png",
						line_length = 5,
						width = 24,
						height = 18,
						frame_count = 10,
						animation_speed = electric_drill_animation_speed,
						direction_count = 1,
						shift = util.by_pixel(-2, 20),
						hr_version =
						{
						  priority = "high",
						  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-S-smoke.png",
						  line_length = 5,
						  width = 48,
						  height = 36,
						  frame_count = 10,
						  animation_speed = electric_drill_animation_speed,
						  direction_count = 1,
						  shift = util.by_pixel(-2, 20),
						  scale = 0.5,
						}
					  }
					}
				  },
				  west_animation =
				  {
					layers =
					{
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-W-smoke.png",
						line_length = 5,
						width = 26,
						height = 30,
						frame_count = 10,
						animation_speed = electric_drill_animation_speed,
						direction_count = 1,
						shift = util.by_pixel(-26, -12),
						hr_version =
						{
						  priority = "high",
						  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-W-smoke.png",
						  line_length = 5,
						  width = 46,
						  height = 54,
						  frame_count = 10,
						  animation_speed = electric_drill_animation_speed,
						  direction_count = 1,
						  shift = util.by_pixel(-25, -11),
						  scale = 0.5,
						}
					  }
					}
				  }
				},
		
				-- fluid window background (bottom)
				{
				  -- render_layer = "lower-object-above-shadow",
				  secondary_draw_order = -49,
				  always_draw = true,
				  north_animation = nil,
				  east_animation =
				  {
					layers =
					{
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-E-wet-window-background.png",
						line_length = 1,
						width = 12,
						height = 8,
						frame_count = 1,
						animation_speed = electric_drill_animation_speed,
						direction_count = 1,
						shift = util.by_pixel(0, -52),
						hr_version =
						{
						  priority = "high",
						  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-E-wet-window-background.png",
						  line_length = 1,
						  width = 22,
						  height = 14,
						  frame_count = 1,
						  animation_speed = electric_drill_animation_speed,
						  direction_count = 1,
						  shift = util.by_pixel(0, -52),
						  scale = 0.5,
						}
					  },
					}
				  },
				  south_animation =
				  {
					layers =
					{
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-S-wet-window-background.png",
						line_length = 1,
						width = 16,
						height = 12,
						frame_count = 1,
						animation_speed = electric_drill_animation_speed,
						direction_count = 1,
						shift = util.by_pixel(-2, -44),
						hr_version =
						{
						  priority = "high",
						  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-S-wet-window-background.png",
						  line_length = 1,
						  width = 30,
						  height = 20,
						  frame_count = 1,
						  animation_speed = electric_drill_animation_speed,
						  direction_count = 1,
						  shift = util.by_pixel(-2, -43),
						  scale = 0.5,
						}
					  },
					}
				  },
				  west_animation =
				  {
					layers =
					{
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-W-wet-window-background.png",
						line_length = 1,
						width = 12,
						height = 8,
						frame_count = 1,
						animation_speed = electric_drill_animation_speed,
						direction_count = 1,
						shift = util.by_pixel(0, -52),
						hr_version =
						{
						  priority = "high",
						  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-W-wet-window-background.png",
						  line_length = 1,
						  width = 22,
						  height = 14,
						  frame_count = 1,
						  animation_speed = electric_drill_animation_speed,
						  direction_count = 1,
						  shift = util.by_pixel(0, -52),
						  scale = 0.5,
						}
					  },
					}
				  },
				},
		
				-- fluid base (bottom)
				{
				  always_draw = true,
				  -- render_layer = "lower-object-above-shadow",
				  secondary_draw_order = -48,
				  apply_tint = "input-fluid-base-color",
				  north_animation = nil,
				  east_animation =
				  {
					layers =
					{
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-E-wet-fluid-background.png",
						line_length = 1,
						width = 12,
						height = 8,
						frame_count = 1,
						animation_speed = electric_drill_animation_speed,
						direction_count = 1,
						shift = util.by_pixel(0, -52),
						hr_version =
						{
						  priority = "high",
						  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-E-wet-fluid-background.png",
						  line_length = 1,
						  width = 22,
						  height = 14,
						  frame_count = 1,
						  animation_speed = electric_drill_animation_speed,
						  direction_count = 1,
						  shift = util.by_pixel(0, -52),
						  scale = 0.5,
						}
					  },
					}
				  },
				  south_animation =
				  {
					layers =
					{
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-S-wet-fluid-background.png",
						line_length = 1,
						width = 14,
						height = 8,
						frame_count = 1,
						animation_speed = electric_drill_animation_speed,
						direction_count = 1,
						shift = util.by_pixel(-2, -42),
						hr_version =
						{
						  priority = "high",
						  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-S-wet-fluid-background.png",
						  line_length = 1,
						  width = 28,
						  height = 18,
						  frame_count = 1,
						  animation_speed = electric_drill_animation_speed,
						  direction_count = 1,
						  shift = util.by_pixel(-2, -43),
						  scale = 0.5,
						}
					  },
					}
				  },
				  west_animation =
				  {
					layers =
					{
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-W-wet-fluid-background.png",
						line_length = 1,
						width = 12,
						height = 8,
						frame_count = 1,
						animation_speed = electric_drill_animation_speed,
						direction_count = 1,
						shift = util.by_pixel(0, -52),
						hr_version =
						{
						  priority = "high",
						  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-W-wet-fluid-background.png",
						  line_length = 1,
						  width = 22,
						  height = 14,
						  frame_count = 1,
						  animation_speed = electric_drill_animation_speed,
						  direction_count = 1,
						  shift = util.by_pixel(0, -52),
						  scale = 0.5,
						}
					  },
					}
				  },
				},
		
				-- fluid flow (bottom)
				{
				  --render_layer = "lower-object-above-shadow",
				  secondary_draw_order = -47,
				  always_draw = true,
				  apply_tint = "input-fluid-flow-color",
				  north_animation = nil,
				  east_animation =
				  {
					layers =
					{
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-E-wet-fluid-flow.png",
						line_length = 1,
						width = 12,
						height = 8,
						frame_count = 1,
						animation_speed = electric_drill_animation_speed,
						direction_count = 1,
						shift = util.by_pixel(0, -52),
						hr_version =
						{
						  priority = "high",
						  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-E-wet-fluid-flow.png",
						  line_length = 1,
						  width = 24,
						  height = 14,
						  frame_count = 1,
						  animation_speed = electric_drill_animation_speed,
						  direction_count = 1,
						  shift = util.by_pixel(0, -52),
						  scale = 0.5,
						}
					  },
					}
				  },
				  south_animation =
				  {
					layers =
					{
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-S-wet-fluid-flow.png",
						line_length = 1,
						width = 14,
						height = 8,
						frame_count = 1,
						animation_speed = electric_drill_animation_speed,
						direction_count = 1,
						shift = util.by_pixel(-2, -42),
						hr_version =
						{
						  priority = "high",
						  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-S-wet-fluid-flow.png",
						  line_length = 1,
						  width = 26,
						  height = 16,
						  frame_count = 1,
						  animation_speed = electric_drill_animation_speed,
						  direction_count = 1,
						  shift = util.by_pixel(-2, -42),
						  scale = 0.5,
						}
					  },
					}
				  },
				  west_animation =
				  {
					layers =
					{
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-W-wet-fluid-flow.png",
						line_length = 1,
						width = 12,
						height = 8,
						frame_count = 1,
						animation_speed = electric_drill_animation_speed,
						direction_count = 1,
						shift = util.by_pixel(0, -52),
						hr_version =
						{
						  priority = "high",
						  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-W-wet-fluid-flow.png",
						  line_length = 1,
						  width = 24,
						  height = 14,
						  frame_count = 1,
						  animation_speed = electric_drill_animation_speed,
						  direction_count = 1,
						  shift = util.by_pixel(0, -52),
						  scale = 0.5,
						}
					  },
					}
				  },
				},
		
				-- drill front animation
				{
				  animated_shift = true,
				  always_draw = true,
				  --north_animation = util.empty_sprite(),
				  east_animation = electric_mining_drill_horizontal_front_animation(),
				  --south_animation = util.empty_sprite(),
				  west_animation = electric_mining_drill_horizontal_front_animation(),
				},
		
				-- fluid window background (front)
				{
				  always_draw = true,
				  north_animation =
				  {
					layers =
					{
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-N-wet-window-background.png",
						line_length = 1,
						width = 86,
						height = 44,
						frame_count = 1,
						animation_speed = electric_drill_animation_speed,
						direction_count = 1,
						shift = util.by_pixel(0, 10),
						hr_version =
						{
						  priority = "high",
						  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-N-wet-window-background.png",
						  line_length = 1,
						  width = 172,
						  height = 90,
						  frame_count = 1,
						  animation_speed = electric_drill_animation_speed,
						  direction_count = 1,
						  shift = util.by_pixel(0, 9),
						  scale = 0.5,
						}
					  },
					}
				  },
				  west_animation =
				  {
					layers =
					{
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-W-wet-window-background-front.png",
						line_length = 1,
						width = 40,
						height = 54,
						frame_count = 1,
						animation_speed = electric_drill_animation_speed,
						direction_count = 1,
						shift = util.by_pixel(14, 10),
						hr_version =
						{
						  priority = "high",
						  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-W-wet-window-background-front.png",
						  line_length = 1,
						  width = 80,
						  height = 106,
						  frame_count = 1,
						  animation_speed = electric_drill_animation_speed,
						  direction_count = 1,
						  shift = util.by_pixel(14, 10),
						  scale = 0.5,
						}
					  }
					}
				  },
				  south_animation =
				  {
					layers =
					{
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-S-wet-window-background-front.png",
						line_length = 1,
						width = 86,
						height = 14,
						frame_count = 1,
						animation_speed = electric_drill_animation_speed,
						direction_count = 1,
						shift = util.by_pixel(0, -8),
						hr_version =
						{
						  priority = "high",
						  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-S-wet-window-background-front.png",
						  line_length = 1,
						  width = 172,
						  height = 22,
						  frame_count = 1,
						  animation_speed = electric_drill_animation_speed,
						  direction_count = 1,
						  shift = util.by_pixel(0, -7),
						  scale = 0.5,
						}
					  }
					}
				  },
				  east_animation =
				  {
					layers =
					{
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-E-wet-window-background-front.png",
						line_length = 1,
						width = 40,
						height = 54,
						frame_count = 1,
						animation_speed = electric_drill_animation_speed,
						direction_count = 1,
						shift = util.by_pixel(-14, 10),
						hr_version =
						{
						  priority = "high",
						  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-E-wet-window-background-front.png",
						  line_length = 1,
						  width = 82,
						  height = 110,
						  frame_count = 1,
						  animation_speed = electric_drill_animation_speed,
						  direction_count = 1,
						  shift = util.by_pixel(-15, 9),
						  scale = 0.5,
						}
					  },
					}
				  },
				},
		
				-- fluid base (front)
				{
				  always_draw = true,
				  apply_tint = "input-fluid-base-color",
				  north_animation =
				  {
					layers =
					{
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-N-wet-fluid-background.png",
						line_length = 1,
						width = 90,
						height = 46,
						frame_count = 1,
						animation_speed = electric_drill_animation_speed,
						direction_count = 1,
						shift = util.by_pixel(0, 10),
						hr_version =
						{
						  priority = "high",
						  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-N-wet-fluid-background.png",
						  line_length = 1,
						  width = 178,
						  height = 94,
						  frame_count = 1,
						  animation_speed = electric_drill_animation_speed,
						  direction_count = 1,
						  shift = util.by_pixel(0, 9),
						  scale = 0.5,
						}
					  },
					}
				  },
				  west_animation =
				  {
					layers =
					{
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-W-wet-fluid-background-front.png",
						line_length = 1,
						width = 40,
						height = 54,
						frame_count = 1,
						animation_speed = electric_drill_animation_speed,
						direction_count = 1,
						shift = util.by_pixel(14, 10),
						hr_version =
						{
						  priority = "high",
						  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-W-wet-fluid-background-front.png",
						  line_length = 1,
						  width = 80,
						  height = 102,
						  frame_count = 1,
						  animation_speed = electric_drill_animation_speed,
						  direction_count = 1,
						  shift = util.by_pixel(14, 11),
						  scale = 0.5,
						}
					  }
					}
				  },
				  south_animation =
				  {
					layers =
					{
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-S-wet-fluid-background-front.png",
						line_length = 1,
						width = 90,
						height = 16,
						frame_count = 1,
						animation_speed = electric_drill_animation_speed,
						direction_count = 1,
						shift = util.by_pixel(0, -8),
						hr_version =
						{
						  priority = "high",
						  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-S-wet-fluid-background-front.png",
						  line_length = 1,
						  width = 178,
						  height = 28,
						  frame_count = 1,
						  animation_speed = electric_drill_animation_speed,
						  direction_count = 1,
						  shift = util.by_pixel(0, -7),
						  scale = 0.5,
						}
					  }
					}
				  },
				  east_animation =
				  {
					layers =
					{
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-E-wet-fluid-background-front.png",
						line_length = 1,
						width = 40,
						height = 54,
						frame_count = 1,
						animation_speed = electric_drill_animation_speed,
						direction_count = 1,
						shift = util.by_pixel(-14, 10),
						hr_version =
						{
						  priority = "high",
						  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-E-wet-fluid-background-front.png",
						  line_length = 1,
						  width = 82,
						  height = 106,
						  frame_count = 1,
						  animation_speed = electric_drill_animation_speed,
						  direction_count = 1,
						  shift = util.by_pixel(-15, 10),
						  scale = 0.5,
						}
					  },
					}
				  },
				},
		
				-- fluid flow (front)
				{
				  always_draw = true,
				  apply_tint = "input-fluid-flow-color",
				  north_animation =
				  {
					layers =
					{
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-N-wet-fluid-flow.png",
						line_length = 1,
						width = 86,
						height = 44,
						frame_count = 1,
						animation_speed = electric_drill_animation_speed,
						direction_count = 1,
						shift = util.by_pixel(0, 10),
						hr_version =
						{
						  priority = "high",
						  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-N-wet-fluid-flow.png",
						  line_length = 1,
						  width = 172,
						  height = 88,
						  frame_count = 1,
						  animation_speed = electric_drill_animation_speed,
						  direction_count = 1,
						  shift = util.by_pixel(0, 10),
						  scale = 0.5,
						}
					  },
					}
				  },
				  west_animation =
				  {
					layers =
					{
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-W-wet-fluid-flow-front.png",
						line_length = 1,
						width = 40,
						height = 50,
						frame_count = 1,
						animation_speed = electric_drill_animation_speed,
						direction_count = 1,
						shift = util.by_pixel(14, 12),
						hr_version =
						{
						  priority = "high",
						  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-W-wet-fluid-flow-front.png",
						  line_length = 1,
						  width = 78,
						  height = 102,
						  frame_count = 1,
						  animation_speed = electric_drill_animation_speed,
						  direction_count = 1,
						  shift = util.by_pixel(14, 11),
						  scale = 0.5,
						}
					  }
					}
				  },
				  south_animation =
				  {
					layers =
					{
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-S-wet-fluid-flow-front.png",
						line_length = 1,
						width = 86,
						height = 12,
						frame_count = 1,
						animation_speed = electric_drill_animation_speed,
						direction_count = 1,
						shift = util.by_pixel(0, -8),
						hr_version =
						{
						  priority = "high",
						  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-S-wet-fluid-flow-front.png",
						  line_length = 1,
						  width = 172,
						  height = 22,
						  frame_count = 1,
						  animation_speed = electric_drill_animation_speed,
						  direction_count = 1,
						  shift = util.by_pixel(0, -8),
						  scale = 0.5,
						}
					  }
					}
				  },
				  east_animation =
				  {
					layers =
					{
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-E-wet-fluid-flow-front.png",
						line_length = 1,
						width = 40,
						height = 54,
						frame_count = 1,
						animation_speed = electric_drill_animation_speed,
						direction_count = 1,
						shift = util.by_pixel(-14, 10),
						hr_version =
						{
						  priority = "high",
						  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-E-wet-fluid-flow-front.png",
						  line_length = 1,
						  width = 78,
						  height = 106,
						  frame_count = 1,
						  animation_speed = electric_drill_animation_speed,
						  direction_count = 1,
						  shift = util.by_pixel(-14, 10),
						  scale = 0.5,
						}
					  },
					}
				  },
				},
		
				-- front frame (wet)
				{
				  always_draw = true,
				  north_animation =
				  {
					layers =
					{
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-N-wet-front.png",
						line_length = 1,
						width = 100,
						height = 66,
						frame_count = 1,
						animation_speed = electric_drill_animation_speed,
						direction_count = 1,
						shift = util.by_pixel(0, 16),
						hr_version =
						{
						  priority = "high",
						  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-N-wet-front.png",
						  line_length = 1,
						  width = 200,
						  height = 130,
						  frame_count = 1,
						  animation_speed = electric_drill_animation_speed,
						  direction_count = 1,
						  shift = util.by_pixel(0, 16),
						  scale = 0.5,
						}
					  },
					}
				  },
				  west_animation =
				  {
					layers =
					{
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-W-wet-front.png",
						line_length = 1,
						width = 104,
						height = 72,
						frame_count = 1,
						animation_speed = electric_drill_animation_speed,
						direction_count = 1,
						shift = util.by_pixel(-4, 12),
						hr_version =
						{
						  priority = "high",
						  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-W-wet-front.png",
						  line_length = 1,
						  width = 208,
						  height = 144,
						  frame_count = 1,
						  animation_speed = electric_drill_animation_speed,
						  direction_count = 1,
						  shift = util.by_pixel(-4, 12),
						  scale = 0.5,
						}
					  }
					}
				  },
				  south_animation =
				  {
					layers =
					{
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-S-output.png",
						line_length = 5,
						width = 44,
						height = 28,
						frame_count = 5,
						animation_speed = electric_drill_animation_speed,
						shift = util.by_pixel(-2, 34),
						hr_version =
						{
						  priority = "high",
						  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-S-output.png",
						  line_length = 5,
						  width = 84,
						  height = 56,
						  frame_count = 5,
						  animation_speed = electric_drill_animation_speed,
						  shift = util.by_pixel(-1, 34),
						  scale = 0.5,
						}
					  },
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-S-wet-front.png",
						line_length = 1,
						width = 96,
						height = 70,
						frame_count = 1,
						animation_speed = electric_drill_animation_speed,
						repeat_count = 5,
						shift = util.by_pixel(0, 18),
						hr_version =
						{
						  priority = "high",
						  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-S-wet-front.png",
						  line_length = 1,
						  width = 192,
						  height = 140,
						  frame_count = 1,
						  animation_speed = electric_drill_animation_speed,
						  repeat_count = 5,
						  shift = util.by_pixel(0, 18),
						  scale = 0.5,
						}
					  },
					}
				  },
				  east_animation =
				  {
					layers =
					{
					  {
						priority = "high",
						filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-E-wet-front.png",
						line_length = 1,
						width = 106,
						height = 76,
						frame_count = 1,
						animation_speed = electric_drill_animation_speed,
						direction_count = 1,
						shift = util.by_pixel(2, 10),
						hr_version =
						{
						  priority = "high",
						  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-E-wet-front.png",
						  line_length = 1,
						  width = 208,
						  height = 148,
						  frame_count = 1,
						  animation_speed = electric_drill_animation_speed,
						  direction_count = 1,
						  shift = util.by_pixel(3, 11),
						  scale = 0.5,
						}
					  },
					}
				  },
				},
		
				-- LEDs
				electric_mining_drill_status_leds_working_visualisation(),
		
				-- light
				electric_mining_drill_primary_light,
				electric_mining_drill_secondary_light
			  }
            }
end
		
local function integration_patch(tier)
	return {
			  north =
			  {
				priority = "high",
				filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-N-integration.png",
				line_length = 1,
				width = 110,
				height = 108,
				frame_count = 1,
				animation_speed = electric_drill_animation_speed,
				direction_count = 1,
				shift = util.by_pixel(-2, 2),
				repeat_count = 5,
				hr_version =
				{
				  priority = "high",
				  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-N-integration.png",
				  line_length = 1,
				  width = 216,
				  height = 218,
				  frame_count = 1,
				  animation_speed = electric_drill_animation_speed,
				  direction_count = 1,
				  shift = util.by_pixel(-1, 1),
				  repeat_count = 5,
				  scale = 0.5,
				}
			  },
			  east =
			  {
				priority = "high",
				filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-E-integration.png",
				line_length = 1,
				width = 116,
				height = 108,
				frame_count = 1,
				animation_speed = electric_drill_animation_speed,
				direction_count = 1,
				shift = util.by_pixel(4, 2),
				repeat_count = 5,
				hr_version =
				{
				  priority = "high",
				  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-E-integration.png",
				  line_length = 1,
				  width = 236,
				  height = 214,
				  frame_count = 1,
				  animation_speed = electric_drill_animation_speed,
				  direction_count = 1,
				  shift = util.by_pixel(3, 2),
				  repeat_count = 5,
				  scale = 0.5,
				}
			  },
			  south =
			  {
				priority = "high",
				filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-S-integration.png",
				line_length = 1,
				width = 108,
				height = 114,
				frame_count = 1,
				animation_speed = electric_drill_animation_speed,
				direction_count = 1,
				shift = util.by_pixel(0, 4),
				repeat_count = 5,
				hr_version =
				{
				  priority = "high",
				  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-S-integration.png",
				  line_length = 1,
				  width = 214,
				  height = 230,
				  frame_count = 1,
				  animation_speed = electric_drill_animation_speed,
				  direction_count = 1,
				  shift = util.by_pixel(0, 3),
				  repeat_count = 5,
				  scale = 0.5,
				}
			  },
			  west =
			  {
				priority = "high",
				filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/electric-mining-drill-W-integration.png",
				line_length = 1,
				width = 118,
				height = 106,
				frame_count = 1,
				animation_speed = electric_drill_animation_speed,
				direction_count = 1,
				shift = util.by_pixel(-4, 2),
				repeat_count = 5,
				hr_version =
				{
				  priority = "high",
				  filename = mod_name.."/graphics/entity/electric-mining-drill-"..tier.."/hr-electric-mining-drill-W-integration.png",
				  line_length = 1,
				  width = 234,
				  height = 214,
				  frame_count = 1,
				  animation_speed = electric_drill_animation_speed,
				  direction_count = 1,
				  shift = util.by_pixel(-4, 1),
				  repeat_count = 5,
				  scale = 0.5,
				}
			  }
            }
end
            

graphics.graphics_set = graphics_set
graphics.wet_mining_graphics_set = wet_mining_graphics_set
graphics.integration_patch = integration_patch

return graphics