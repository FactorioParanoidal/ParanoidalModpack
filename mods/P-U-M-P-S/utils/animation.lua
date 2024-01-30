-----------------------------------------------------------
---- here is where all animation properties are stored ----
-----------------------------------------------------------

local animation_set = {}

-- Recolor Masks
function animation_set.assign_tier_color()

	local offshore_pumps =
	{
		"offshore-pump-0",
		"offshore-pump-2",
		"offshore-pump-3",
		"offshore-pump-4"
	}

	for _, offshore_pump in pairs (offshore_pumps) do

		local animation_table = {}
		
		if data.raw["assembling-machine"][offshore_pump] then
			table.insert(animation_table, data.raw["assembling-machine"][offshore_pump].animation)
			table.insert(animation_table, data.raw["offshore-pump"][offshore_pump.."-placeholder"].graphics_set.animation)
		elseif data.raw["offshore-pump"][offshore_pump] then
			table.insert(animation_table, data.raw["offshore-pump"][offshore_pump].graphics_set.animation)
		end
		
		for _, animation in pairs (animation_table) do
			-- North
			table.insert(animation.north.layers,
			{
				stripes = OSM.utils.make_stripes (8*4, "__P-U-M-P-S__/graphics/entity/"..offshore_pump.."/"..offshore_pump.."-mask_North.png"),
				priority = "high",
				frame_count = 32,
				animation_speed = 0.25,
				width = 48,
				height = 84,
				shift = util.by_pixel(-2, -16),
				hr_version =
				{
					stripes = OSM.utils.make_stripes (8*4, "__P-U-M-P-S__/graphics/entity/"..offshore_pump.."/hr-"..offshore_pump.."-mask_North.png"),
					priority = "high",
					frame_count = 32,
					animation_speed = 0.25,
					width = 90,
					height = 162,
					shift = util.by_pixel(-1, -15),
					scale = 0.5
				}
			})
			-- East
			table.insert(animation.east.layers,
			{
				stripes = OSM.utils.make_stripes (8*4, "__P-U-M-P-S__/graphics/entity/"..offshore_pump.."/"..offshore_pump.."-mask_East.png"),
				priority = "high",
				frame_count = 32,
				animation_speed = 0.25,
				width = 52,
				height = 16,
				shift = util.by_pixel(14, -2),
				hr_version =
				{
					stripes = OSM.utils.make_stripes (8*4, "__P-U-M-P-S__/graphics/entity/"..offshore_pump.."/hr-"..offshore_pump.."-mask_East.png"),
					priority = "high",
					frame_count = 32,
					animation_speed = 0.25,
					width = 124,
					height = 102,
					shift = util.by_pixel(15, -2),
					scale = 0.5
				}
			})
			-- South
			table.insert(animation.south.layers,
			{
				stripes = OSM.utils.make_stripes (8*4, "__P-U-M-P-S__/graphics/entity/"..offshore_pump.."/"..offshore_pump.."-mask_South.png"),
				priority = "high",
				frame_count = 32,
				animation_speed = 0.25,
				width = 48,
				height = 96,
				shift = util.by_pixel(-2, 0),
				hr_version =
				{
					stripes = OSM.utils.make_stripes (8*4, "__P-U-M-P-S__/graphics/entity/"..offshore_pump.."/hr-"..offshore_pump.."-mask_South.png"),
					priority = "high",
					frame_count = 32,
					animation_speed = 0.25,
					width = 92,
					height = 192,
					shift = util.by_pixel(-1, 0),
					scale = 0.5
				}
			})
			-- West
			table.insert(animation.west.layers,
			{
				stripes = OSM.utils.make_stripes (8*4, "__P-U-M-P-S__/graphics/entity/"..offshore_pump.."/"..offshore_pump.."-mask_West.png"),
				priority = "high",
				frame_count = 32,
				animation_speed = 0.25,
				width = 64,
				height = 52,
				shift = util.by_pixel(-16, -2),
				hr_version =
				{
					stripes = OSM.utils.make_stripes (8*4, "__P-U-M-P-S__/graphics/entity/"..offshore_pump.."/hr-"..offshore_pump.."-mask_West.png"),
					priority = "high",
					frame_count = 32,
					animation_speed = 0.25,
					width = 124,
					height = 102,
					shift = util.by_pixel(-15, -2),
					scale = 0.5
				}
			})
		end
	end
end

function animation_set.template_unpowered_animation()
	return
	{
		underwater_sprite_layer_offset = 30,
		base_render_layer = "ground-patch",
		animation =
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
					}
				}
			},
			east =
			{
				layers =
				{
					{
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
					}
				}
			}
		},
		fluid_animation =
		{
			north =
			{
				layers =
				{
					{
						filename = "__base__/graphics/entity/offshore-pump/offshore-pump_North-fluid.png",
						tint = {r=0, g=0.34, b=0.6},
						line_length = 8,
						frame_count = 32,
						animation_speed = 0.25,
						width = 22,
						height = 20,
						shift = util.by_pixel(-2, -22),
						hr_version =
						{
							filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_North-fluid.png",
							tint = {r=0, g=0.34, b=0.6},
							line_length = 8,
							frame_count = 32,
							animation_speed = 0.25,
							width = 40,
							height = 40,
							shift = util.by_pixel(-1, -22),
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
						filename = "__base__/graphics/entity/offshore-pump/offshore-pump_East-fluid.png",
						tint = {r=0, g=0.34, b=0.6},
						line_length = 8,
						frame_count = 32,
						animation_speed = 0.25,
						width = 20,
						height = 24,
						shift = util.by_pixel(6, -10),
						hr_version =
						{
							filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_East-fluid.png",
							tint = {r=0, g=0.34, b=0.6},
							line_length = 8,
							frame_count = 32,
							animation_speed = 0.25,
							width = 38,
							height = 50,
							shift = util.by_pixel(6, -11),
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
						filename = "__base__/graphics/entity/offshore-pump/offshore-pump_South-fluid.png",
						tint = {r=0, g=0.34, b=0.6},
						line_length = 8,
						frame_count = 32,
						animation_speed = 0.25,
						width = 20,
						height = 8,
						shift = util.by_pixel(-2, -4),
						hr_version =
						{
							filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_South-fluid.png",
							tint = {r=0, g=0.34, b=0.6},
							line_length = 8,
							frame_count = 32,
							animation_speed = 0.25,
							width = 36,
							height = 14,
							shift = util.by_pixel(-1, -4),
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
						filename = "__base__/graphics/entity/offshore-pump/offshore-pump_West-fluid.png",
						tint = {r=0, g=0.34, b=0.6},
						line_length = 8,
						frame_count = 32,
						animation_speed = 0.25,
						width = 20,
						height = 24,
						shift = util.by_pixel(-8, -10),
						hr_version =
						{
							filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_West-fluid.png",
							tint = {r=0, g=0.34, b=0.6},
							line_length = 8,
							frame_count = 32,
							animation_speed = 0.25,
							width = 36,
							height = 50,
							shift = util.by_pixel(-7, -11),
							scale = 0.5
						}
					}
				}
			}
		},
		glass_pictures =
		{
			north =
			{
				filename = "__base__/graphics/entity/offshore-pump/offshore-pump_North-glass.png",
				width = 18,
				height = 20,
				shift = util.by_pixel(-2, -22),
				hr_version =
				{
					filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_North-glass.png",
					width = 36,
					height = 40,
					shift = util.by_pixel(-2, -22),
					scale = 0.5
				}
			},
			east =
			{
				filename = "__base__/graphics/entity/offshore-pump/offshore-pump_East-glass.png",
				width = 18,
				height = 18,
				shift = util.by_pixel(4, -14),
				hr_version =
				{
					filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_East-glass.png",
					width = 30,
					height = 32,
					shift = util.by_pixel(5, -13),
					scale = 0.5
				}
			},
			south =
			{
				filename = "__base__/graphics/entity/offshore-pump/offshore-pump_South-glass.png",
				width = 22,
				height = 12,
				shift = util.by_pixel(-2, -6),
				hr_version =
				{
					filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_South-glass.png",
					width = 40,
					height = 24,
					shift = util.by_pixel(-1, -6),
					scale = 0.5
				}
			},
			west =
			{
				filename = "__base__/graphics/entity/offshore-pump/offshore-pump_West-glass.png",
				width = 16,
				height = 16,
				shift = util.by_pixel(-6, -14),
				hr_version =
				{
					filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_West-glass.png",
					width = 30,
					height = 32,
					shift = util.by_pixel(-6, -14),
					scale = 0.5
				}
			}
		},
		base_pictures =
		{
			north =
			{
				filename = "__base__/graphics/entity/offshore-pump/offshore-pump_North-legs.png",
				width = 60,
				height = 52,
				shift = util.by_pixel(-2, -4),
				hr_version =
				{
					filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_North-legs.png",
					width = 114,
					height = 106,
					shift = util.by_pixel(-1, -5),
					scale = 0.5
				}
			},
			east =
			{
				filename = "__base__/graphics/entity/offshore-pump/offshore-pump_East-legs.png",
				width = 54,
				height = 32,
				shift = util.by_pixel(4, 12),
				hr_version =
				{
					filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_East-legs.png",
					width = 106,
					height = 60,
					shift = util.by_pixel(4, 13),
					scale = 0.5
				}
			},
			south =
			{
				filename = "__base__/graphics/entity/offshore-pump/offshore-pump_South-legs.png",
				width = 56,
				height = 54,
				shift = util.by_pixel(-2, 6),
				hr_version =
				{
					filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_South-legs.png",
					width = 110,
					height = 108,
					shift = util.by_pixel(-2, 6),
					scale = 0.5
				}
			},
			west =
			{
				filename = "__base__/graphics/entity/offshore-pump/offshore-pump_West-legs.png",
				width = 54,
				height = 32,
				shift = util.by_pixel(-6, 12),
				hr_version =
				{
					filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_West-legs.png",
					width = 108,
					height = 64,
					shift = util.by_pixel(-6, 12),
					scale = 0.5
				}
			}
		},
		underwater_pictures =
		{
			north =
			{
				filename = "__base__/graphics/entity/offshore-pump/offshore-pump_North-underwater.png",
				width = 52,
				height = 16,
				shift = util.by_pixel(-2, -34),
				hr_version =
				{
					filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_North-underwater.png",
					width = 98,
					height = 36,
					shift = util.by_pixel(-1, -32),
					scale = 0.5
				}
			},
			east =
			{
				filename = "__base__/graphics/entity/offshore-pump/offshore-pump_East-underwater.png",
				width = 18,
				height = 38,
				shift = util.by_pixel(40, 16),
				hr_version =
				{
					filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_East-underwater.png",
					width = 40,
					height = 72,
					shift = util.by_pixel(39, 17),
					scale = 0.5
				}
			},
			south =
			{
				filename = "__base__/graphics/entity/offshore-pump/offshore-pump_South-underwater.png",
				width = 52,
				height = 26,
				shift = util.by_pixel(-2, 48),
				hr_version =
				{
					filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_South-underwater.png",
					width = 98,
					height = 48,
					shift = util.by_pixel(-1, 49),
					scale = 0.5
				}
			},
			west =
			{
				filename = "__base__/graphics/entity/offshore-pump/offshore-pump_West-underwater.png",
				width = 20,
				height = 34,
				shift = util.by_pixel(-40, 18),
				hr_version =
				{
					filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_West-underwater.png",
					width = 40,
					height = 72,
					shift = util.by_pixel(-40, 17),
					scale = 0.5
				}
			}
		}
	}
end

function animation_set.template_powered_animation(animation_speed)
	
	if not animation_speed then animation_speed = 0.25 end
	
	return
	{
		north =
		{
			layers =
			{
				{
					stripes = OSM.utils.make_stripes (8*4, "__P-U-M-P-S__/graphics/entity/common/offshore-pump_North-underwater.png"),
					priority = "high",
					frame_count = 32,
					animation_speed = animation_speed,
					width = 52,
					height = 16,
					shift = util.by_pixel(-2, -34),
					hr_version =
					{
						stripes = OSM.utils.make_stripes (8*4, "__P-U-M-P-S__/graphics/entity/common/hr-offshore-pump_North-underwater.png"),
						priority = "high",
						frame_count = 32,
						animation_speed = animation_speed,
						width = 98,
						height = 36,
						shift = util.by_pixel(-1, -32),
						scale = 0.5
					}
				},
				{
					filename = "__base__/graphics/entity/offshore-pump/offshore-pump_North.png",
					priority = "high",
					line_length = 8,
					frame_count = 32,
					animation_speed = animation_speed,
					width = 48,
					height = 84,
					shift = util.by_pixel(-2, -16),
					hr_version =
					{
						filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_North.png",
						priority = "high",
						line_length = 8,
						frame_count = 32,
						animation_speed = animation_speed,
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
					animation_speed = animation_speed,
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
						animation_speed = animation_speed,
						width = 150,
						height = 134,
						shift = util.by_pixel(13, -7),
						draw_as_shadow = true,
						scale = 0.5
					}
				},
				{
					filename = "__base__/graphics/entity/offshore-pump/offshore-pump_North-fluid.png",
					tint = {r=0, g=0.34, b=0.6},
					line_length = 8,
					frame_count = 32,
					animation_speed = animation_speed,
					width = 22,
					height = 20,
					shift = util.by_pixel(-2, -22),
					hr_version =
					{
						filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_North-fluid.png",
						tint = {r=0, g=0.34, b=0.6},
						line_length = 8,
						frame_count = 32,
						animation_speed = animation_speed,
						width = 40,
						height = 40,
						shift = util.by_pixel(-1, -22),
						scale = 0.5
					}
				},
				{
					stripes = OSM.utils.make_stripes (8*4, "__base__/graphics/entity/offshore-pump/offshore-pump_North-glass.png"),
					priority = "high",
					frame_count = 32,
					animation_speed = animation_speed,
					width = 18,
					height = 20,
					shift = util.by_pixel(-2, -22),
					hr_version =
					{
						stripes = OSM.utils.make_stripes (8*4, "__base__/graphics/entity/offshore-pump/hr-offshore-pump_North-glass.png"),
						priority = "high",
						frame_count = 32,
						animation_speed = animation_speed,
						width = 36,
						height = 40,
						shift = util.by_pixel(-2, -22),
						scale = 0.5
					}
				},
				{
					stripes = OSM.utils.make_stripes (8*4, "__base__/graphics/entity/offshore-pump/offshore-pump_North-legs.png"),
					priority = "high",
					frame_count = 32,
					animation_speed = animation_speed,
					width = 60,
					height = 52,
					shift = util.by_pixel(-2, -4),
					hr_version =
					{
						stripes = OSM.utils.make_stripes (8*4, "__base__/graphics/entity/offshore-pump/hr-offshore-pump_North-legs.png"),
						priority = "high",
						frame_count = 32,
						animation_speed = animation_speed,
						width = 114,
						height = 106,
						shift = util.by_pixel(-1, -5),
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
					stripes = OSM.utils.make_stripes (8*4, "__P-U-M-P-S__/graphics/entity/common/offshore-pump_East-underwater.png"),
					priority = "high",
					frame_count = 32,
					animation_speed = animation_speed,
					width = 18,
					height = 38,
					shift = util.by_pixel(40, 16),
					hr_version =
					{
						stripes = OSM.utils.make_stripes (8*4, "__P-U-M-P-S__/graphics/entity/common/hr-offshore-pump_East-underwater.png"),
						priority = "high",
						frame_count = 32,
						animation_speed = animation_speed,
						width = 40,
						height = 72,
						shift = util.by_pixel(39, 17),
						scale = 0.5
					}
				},
				{
					filename = "__base__/graphics/entity/offshore-pump/offshore-pump_East.png",
					priority = "high",
					line_length = 8,
					frame_count = 32,
					animation_speed = animation_speed,
					width = 64,
					height = 52,
					shift = util.by_pixel(14, -2),
					hr_version =
					{
						filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_East.png",
						priority = "high",
						line_length = 8,
						frame_count = 32,
						animation_speed = animation_speed,
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
					animation_speed = animation_speed,
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
						animation_speed = animation_speed,
						width = 180,
						height = 66,
						shift = util.by_pixel(27, 8),
						draw_as_shadow = true,
						scale = 0.5
					}
				},
				{
					filename = "__base__/graphics/entity/offshore-pump/offshore-pump_East-fluid.png",
					tint = {r=0, g=0.34, b=0.6},
					line_length = 8,
					frame_count = 32,
					animation_speed = animation_speed,
					width = 20,
					height = 24,
					shift = util.by_pixel(6, -10),
					hr_version =
					{
						filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_East-fluid.png",
						tint = {r=0, g=0.34, b=0.6},
						line_length = 8,
						frame_count = 32,
						animation_speed = animation_speed,
						width = 38,
						height = 50,
						shift = util.by_pixel(6, -11),
						scale = 0.5
					}
				},
				{
					stripes = OSM.utils.make_stripes (8*4, "__base__/graphics/entity/offshore-pump/offshore-pump_East-glass.png"),
					priority = "high",
					frame_count = 32,
					animation_speed = animation_speed,
					width = 18,
					height = 18,
					shift = util.by_pixel(4, -14),
					hr_version =
					{
						stripes = OSM.utils.make_stripes (8*4, "__base__/graphics/entity/offshore-pump/hr-offshore-pump_East-glass.png"),
						priority = "high",
						frame_count = 32,
						animation_speed = animation_speed,
						width = 30,
						height = 32,
						shift = util.by_pixel(5, -13),
						scale = 0.5
					}
				},
				{
					stripes = OSM.utils.make_stripes (8*4, "__base__/graphics/entity/offshore-pump/offshore-pump_East-legs.png"),
					priority = "high",
					frame_count = 32,
					animation_speed = animation_speed,
					width = 54,
					height = 32,
					shift = util.by_pixel(4, 12),
					hr_version =
					{
						stripes = OSM.utils.make_stripes (8*4, "__base__/graphics/entity/offshore-pump/hr-offshore-pump_East-legs.png"),
						priority = "high",
						frame_count = 32,
						animation_speed = animation_speed,
						width = 106,
						height = 60,
						shift = util.by_pixel(4, 13),
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
					stripes = OSM.utils.make_stripes (8*4, "__P-U-M-P-S__/graphics/entity/common/offshore-pump_South-underwater.png"),
					priority = "high",
					frame_count = 32,
					animation_speed = animation_speed,
					width = 52,
					height = 26,
					shift = util.by_pixel(-2, 48),
					hr_version =
					{
						stripes = OSM.utils.make_stripes (8*4, "__P-U-M-P-S__/graphics/entity/common/hr-offshore-pump_South-underwater.png"),
						priority = "high",
						frame_count = 32,
						animation_speed = animation_speed,
						width = 98,
						height = 48,
						shift = util.by_pixel(-1, 49),
						scale = 0.5
						}
				},
				{
					filename = "__base__/graphics/entity/offshore-pump/offshore-pump_South.png",
					priority = "high",
					line_length = 8,
					frame_count = 32,
					animation_speed = animation_speed,
					width = 48,
					height = 96,
					shift = util.by_pixel(-2, 0),
					hr_version =
					{
						filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_South.png",
						priority = "high",
						line_length = 8,
						frame_count = 32,
						animation_speed = animation_speed,
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
					animation_speed = animation_speed,
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
						animation_speed = animation_speed,
						width = 164,
						height = 128,
						shift = util.by_pixel(15, 23),
						draw_as_shadow = true,
						scale = 0.5
					}
				},
				{
					filename = "__base__/graphics/entity/offshore-pump/offshore-pump_South-fluid.png",
					tint = {r=0, g=0.34, b=0.6},
					line_length = 8,
					frame_count = 32,
					animation_speed = animation_speed,
					width = 20,
					height = 8,
					shift = util.by_pixel(-2, -4),
					hr_version =
					{
						filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_South-fluid.png",
						tint = {r=0, g=0.34, b=0.6},
						line_length = 8,
						frame_count = 32,
						animation_speed = animation_speed,
						width = 36,
						height = 14,
						shift = util.by_pixel(-1, -4),
						scale = 0.5
					}
				},
				{
					stripes = OSM.utils.make_stripes (8*4, "__base__/graphics/entity/offshore-pump/offshore-pump_South-glass.png"),
					priority = "high",
					frame_count = 32,
					animation_speed = animation_speed,
					width = 22,
					height = 12,
					shift = util.by_pixel(-2, -6),
					hr_version =
					{
						stripes = OSM.utils.make_stripes (8*4, "__base__/graphics/entity/offshore-pump/hr-offshore-pump_South-glass.png"),
						priority = "high",
						frame_count = 32,
						animation_speed = animation_speed,
						width = 40,
						height = 24,
						shift = util.by_pixel(-1, -6),
						scale = 0.5
					}
				},
				{
					stripes = OSM.utils.make_stripes (8*4, "__base__/graphics/entity/offshore-pump/offshore-pump_South-legs.png"),
					priority = "high",
					frame_count = 32,
					animation_speed = animation_speed,
					width = 56,
					height = 54,
					shift = util.by_pixel(-2, 6),
					hr_version =
					{
						stripes = OSM.utils.make_stripes (8*4, "__base__/graphics/entity/offshore-pump/hr-offshore-pump_South-legs.png"),
						priority = "high",
						frame_count = 32,
						animation_speed = animation_speed,
						width = 110,
						height = 108,
						shift = util.by_pixel(-2, 6),
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
					stripes = OSM.utils.make_stripes (8*4, "__P-U-M-P-S__/graphics/entity/common/offshore-pump_West-underwater.png"),
					priority = "high",
					frame_count = 32,
					animation_speed = animation_speed,
					width = 20,
					height = 34,
					shift = util.by_pixel(-40, 18),
					hr_version =
					{
						stripes = OSM.utils.make_stripes (8*4, "__P-U-M-P-S__/graphics/entity/common/hr-offshore-pump_West-underwater.png"),
						priority = "high",
						frame_count = 32,
						animation_speed = animation_speed,
						width = 40,
						height = 72,
						shift = util.by_pixel(-40, 17),
						scale = 0.5
					}
				},
				{
					filename = "__base__/graphics/entity/offshore-pump/offshore-pump_West.png",
					priority = "high",
					line_length = 8,
					frame_count = 32,
					animation_speed = animation_speed,
					width = 64,
					height = 52,
					shift = util.by_pixel(-16, -2),
					hr_version =
					{
						filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_West.png",
						priority = "high",
						line_length = 8,
						frame_count = 32,
						animation_speed = animation_speed,
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
					animation_speed = animation_speed,
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
						animation_speed = animation_speed,
						width = 172,
						height = 66,
						shift = util.by_pixel(-3, 8),
						draw_as_shadow = true,
						scale = 0.5
					}
				},
				{
					filename = "__base__/graphics/entity/offshore-pump/offshore-pump_West-fluid.png",
					tint = {r=0, g=0.34, b=0.6},
					line_length = 8,
					frame_count = 32,
					animation_speed = animation_speed,
					width = 20,
					height = 24,
					shift = util.by_pixel(-8, -10),
					hr_version =
					{
						filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_West-fluid.png",
						tint = {r=0, g=0.34, b=0.6},
						line_length = 8,
						frame_count = 32,
						animation_speed = animation_speed,
						width = 36,
						height = 50,
						shift = util.by_pixel(-7, -11),
						scale = 0.5
					}
				},
				{
	
					stripes = OSM.utils.make_stripes (8*4, "__base__/graphics/entity/offshore-pump/offshore-pump_North-glass.png"),
					priority = "high",
					frame_count = 32,
					animation_speed = animation_speed,
					width = 18,
					height = 20,
					shift = util.by_pixel(-2, -22),
					hr_version =
					{
						stripes = OSM.utils.make_stripes (8*4, "__base__/graphics/entity/offshore-pump/hr-offshore-pump_North-glass.png"),
						priority = "high",
						frame_count = 32,
						animation_speed = animation_speed,
						width = 36,
						height = 40,
						shift = util.by_pixel(-2, -22),
						scale = 0.5
					}
				},
				{
					stripes = OSM.utils.make_stripes (8*4, "__base__/graphics/entity/offshore-pump/offshore-pump_West-glass.png"),
					priority = "high",
					frame_count = 32,
					animation_speed = animation_speed,
					width = 16,
					height = 16,
					shift = util.by_pixel(-6, -14),
					hr_version =
					{
						stripes = OSM.utils.make_stripes (8*4, "__base__/graphics/entity/offshore-pump/hr-offshore-pump_West-glass.png"),
						priority = "high",
						frame_count = 32,
						animation_speed = animation_speed,
						width = 30,
						height = 32,
						shift = util.by_pixel(-6, -14),
						scale = 0.5
					}
				},
				{
					stripes = OSM.utils.make_stripes (8*4, "__base__/graphics/entity/offshore-pump/offshore-pump_West-legs.png"),
					priority = "high",
					frame_count = 32,
					animation_speed = animation_speed,
					width = 54,
					height = 32,
					shift = util.by_pixel(-6, 12),
					hr_version =
					{
						stripes = OSM.utils.make_stripes (8*4, "__base__/graphics/entity/offshore-pump/hr-offshore-pump_West-legs.png"),
						priority = "high",
						frame_count = 32,
						animation_speed = animation_speed,
						width = 108,
						height = 64,
						shift = util.by_pixel(-6, 12),
						scale = 0.5
					}
				}
			}
		}
	}
end

function animation_set.water_pumpjack_animation(animation_speed)

	if not animation_speed then animation_speed = 0.50 end

	return
	{
		north =
		{
			layers =
			{
				{
					stripes = OSM.utils.make_stripes (8*5, "__P-U-M-P-S__/graphics/entity/water-pumpjack/water-pumpjack_North-shadow.png"),
					priority = "high",
					frame_count = 40,
					animation_speed = animation_speed,
					width = 110,
					height = 111,
					shift = util.by_pixel(6, 0.5),
					draw_as_shadow = true,
					hr_version =
					{
						stripes = OSM.utils.make_stripes (8*5, "__P-U-M-P-S__/graphics/entity/water-pumpjack/hr-water-pumpjack_North-shadow.png"),
						priority = "high",
						frame_count = 40,
						animation_speed = animation_speed,
						width = 220,
						height = 220,
						shift = util.by_pixel(6, 0.5),
						draw_as_shadow = true,
						scale = 0.5,
					}
				},
				{
					stripes = OSM.utils.make_stripes (8*5, "__P-U-M-P-S__/graphics/entity/water-pumpjack/water-pumpjack_North-base.png"),
					priority = "high",
					frame_count = 40,
					animation_speed = animation_speed,
					width = 131,
					height = 137,
					shift = util.by_pixel(-2.5, -4.5),
					hr_version =
					{
						stripes = OSM.utils.make_stripes (8*5, "__P-U-M-P-S__/graphics/entity/water-pumpjack/hr-water-pumpjack_North-base.png"),
						priority = "high",
						frame_count = 40,
						animation_speed = animation_speed,
						width = 260,
						height = 273,
						shift = util.by_pixel(-2.25, -4.75),
						scale = 0.5
					}
				},
				{
					filename = "__P-U-M-P-S__/graphics/entity/water-pumpjack/water-pumpjack-horsehead.png",
					priority = "high",
					line_length = 8,
					frame_count = 40,
					animation_speed = animation_speed,
					width = 104,
					height = 102,
					shift = util.by_pixel(-4, -24),
					hr_version =
					{
						filename = "__P-U-M-P-S__/graphics/entity/water-pumpjack/hr-water-pumpjack-horsehead.png",
						priority = "high",
						line_length = 8,
						frame_count = 40,
						animation_speed = animation_speed,
						width = 206,
						height = 202,
						shift = util.by_pixel(-4, -24),
						scale = 0.5
					}
				},
				{
					priority = "high",
					filename = "__base__/graphics/entity/pumpjack/pumpjack-horsehead-shadow.png",
					animation_speed = animation_speed,
					line_length = 8,
					frame_count = 40,
					animation_speed = animation_speed,
					width = 155,
					height = 41,
					shift = util.by_pixel(17.5, 14.5),
					draw_as_shadow = true,
					hr_version =
					{
						priority = "high",
						filename = "__base__/graphics/entity/pumpjack/hr-pumpjack-horsehead-shadow.png",
						line_length = 8,
						frame_count = 40,
						animation_speed = animation_speed,
						width = 309,
						height = 82,
						shift = util.by_pixel(17.75, 14.5),
						draw_as_shadow = true,
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
					stripes = OSM.utils.make_stripes (8*5, "__P-U-M-P-S__/graphics/entity/water-pumpjack/water-pumpjack_East-shadow.png"),
					priority = "high",
					frame_count = 40,
					animation_speed = animation_speed,
					width = 110,
					height = 111,
					shift = util.by_pixel(6, 0.5),
					draw_as_shadow = true,
					hr_version =
					{
						stripes = OSM.utils.make_stripes (8*5, "__P-U-M-P-S__/graphics/entity/water-pumpjack/hr-water-pumpjack_East-shadow.png"),
						priority = "high",
						frame_count = 40,
						animation_speed = animation_speed,
						width = 220,
						height = 220,
						shift = util.by_pixel(6, 0.5),
						draw_as_shadow = true,
						scale = 0.5,
					}
				},
				{
					stripes = OSM.utils.make_stripes (8*5, "__P-U-M-P-S__/graphics/entity/water-pumpjack/water-pumpjack_East-base.png"),
					priority = "high",
					frame_count = 40,
					animation_speed = animation_speed,
					width = 131,
					height = 137,
					shift = util.by_pixel(-2.5, -4.5),
					hr_version =
					{
						stripes = OSM.utils.make_stripes (8*5, "__P-U-M-P-S__/graphics/entity/water-pumpjack/hr-water-pumpjack_East-base.png"),
						priority = "high",
						frame_count = 40,
						animation_speed = animation_speed,
						width = 260,
						height = 273,
						shift = util.by_pixel(-2.25, -4.75),
						scale = 0.5
					}
				},
				{
					filename = "__P-U-M-P-S__/graphics/entity/water-pumpjack/water-pumpjack-horsehead.png",
					priority = "high",
					line_length = 8,
					frame_count = 40,
					animation_speed = animation_speed,
					width = 104,
					height = 102,
					shift = util.by_pixel(-4, -24),
					hr_version =
					{
						filename = "__P-U-M-P-S__/graphics/entity/water-pumpjack/hr-water-pumpjack-horsehead.png",
						priority = "high",
						line_length = 8,
						frame_count = 40,
						animation_speed = animation_speed,
						width = 206,
						height = 202,
						shift = util.by_pixel(-4, -24),
						scale = 0.5
					}
				},
				{
					priority = "high",
					filename = "__base__/graphics/entity/pumpjack/pumpjack-horsehead-shadow.png",
					animation_speed = animation_speed,
					line_length = 8,
					frame_count = 40,
					animation_speed = animation_speed,
					width = 155,
					height = 41,
					shift = util.by_pixel(17.5, 14.5),
					draw_as_shadow = true,
					hr_version =
					{
						priority = "high",
						filename = "__base__/graphics/entity/pumpjack/hr-pumpjack-horsehead-shadow.png",
						line_length = 8,
						frame_count = 40,
						animation_speed = animation_speed,
						width = 309,
						height = 82,
						shift = util.by_pixel(17.75, 14.5),
						draw_as_shadow = true,
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
					stripes = OSM.utils.make_stripes (8*5, "__P-U-M-P-S__/graphics/entity/water-pumpjack/water-pumpjack_South-shadow.png"),
					priority = "high",
					frame_count = 40,
					animation_speed = animation_speed,
					width = 110,
					height = 111,
					shift = util.by_pixel(6, 0.5),
					draw_as_shadow = true,
					hr_version =
					{
						stripes = OSM.utils.make_stripes (8*5, "__P-U-M-P-S__/graphics/entity/water-pumpjack/hr-water-pumpjack_South-shadow.png"),
						priority = "high",
						frame_count = 40,
						animation_speed = animation_speed,
						width = 220,
						height = 220,
						shift = util.by_pixel(6, 0.5),
						draw_as_shadow = true,
						scale = 0.5,
					}
				},
				{
					stripes = OSM.utils.make_stripes (8*5, "__P-U-M-P-S__/graphics/entity/water-pumpjack/water-pumpjack_South-base.png"),
					priority = "high",
					frame_count = 40,
					animation_speed = animation_speed,
					width = 131,
					height = 137,
					shift = util.by_pixel(-2.5, -4.5),
					hr_version =
					{
						stripes = OSM.utils.make_stripes (8*5, "__P-U-M-P-S__/graphics/entity/water-pumpjack/hr-water-pumpjack_South-base.png"),
						priority = "high",
						frame_count = 40,
						animation_speed = animation_speed,
						width = 260,
						height = 273,
						shift = util.by_pixel(-2.25, -4.75),
						scale = 0.5
					}
				},
				{
					filename = "__P-U-M-P-S__/graphics/entity/water-pumpjack/water-pumpjack-horsehead.png",
					priority = "high",
					line_length = 8,
					frame_count = 40,
					animation_speed = animation_speed,
					width = 104,
					height = 102,
					shift = util.by_pixel(-4, -24),
					hr_version =
					{
						filename = "__P-U-M-P-S__/graphics/entity/water-pumpjack/hr-water-pumpjack-horsehead.png",
						priority = "high",
						line_length = 8,
						frame_count = 40,
						animation_speed = animation_speed,
						width = 206,
						height = 202,
						shift = util.by_pixel(-4, -24),
						scale = 0.5
					}
				},
				{
					priority = "high",
					filename = "__base__/graphics/entity/pumpjack/pumpjack-horsehead-shadow.png",
					animation_speed = animation_speed,
					line_length = 8,
					frame_count = 40,
					animation_speed = animation_speed,
					width = 155,
					height = 41,
					shift = util.by_pixel(17.5, 14.5),
					draw_as_shadow = true,
					hr_version =
					{
						priority = "high",
						filename = "__base__/graphics/entity/pumpjack/hr-pumpjack-horsehead-shadow.png",
						line_length = 8,
						frame_count = 40,
						animation_speed = animation_speed,
						width = 309,
						height = 82,
						shift = util.by_pixel(17.75, 14.5),
						draw_as_shadow = true,
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
					stripes = OSM.utils.make_stripes (8*5, "__P-U-M-P-S__/graphics/entity/water-pumpjack/water-pumpjack_West-shadow.png"),
					priority = "high",
					frame_count = 40,
					animation_speed = animation_speed,
					width = 110,
					height = 111,
					shift = util.by_pixel(6, 0.5),
					draw_as_shadow = true,
					hr_version =
					{
						stripes = OSM.utils.make_stripes (8*5, "__P-U-M-P-S__/graphics/entity/water-pumpjack/hr-water-pumpjack_West-shadow.png"),
						priority = "high",
						frame_count = 40,
						animation_speed = animation_speed,
						width = 220,
						height = 220,
						shift = util.by_pixel(6, 0.5),
						draw_as_shadow = true,
						scale = 0.5,
					}
				},
				{
					stripes = OSM.utils.make_stripes (8*5, "__P-U-M-P-S__/graphics/entity/water-pumpjack/water-pumpjack_West-base.png"),
					priority = "high",
					frame_count = 40,
					animation_speed = animation_speed,
					width = 131,
					height = 137,
					shift = util.by_pixel(-2.5, -4.5),
					hr_version =
					{
						stripes = OSM.utils.make_stripes (8*5, "__P-U-M-P-S__/graphics/entity/water-pumpjack/hr-water-pumpjack_West-base.png"),
						priority = "high",
						frame_count = 40,
						animation_speed = animation_speed,
						width = 260,
						height = 273,
						shift = util.by_pixel(-2.25, -4.75),
						scale = 0.5
					}
				},
				{
					filename = "__P-U-M-P-S__/graphics/entity/water-pumpjack/water-pumpjack-horsehead.png",
					priority = "high",
					line_length = 8,
					frame_count = 40,
					animation_speed = animation_speed,
					width = 104,
					height = 102,
					shift = util.by_pixel(-4, -24),
					hr_version =
					{
						filename = "__P-U-M-P-S__/graphics/entity/water-pumpjack/hr-water-pumpjack-horsehead.png",
						priority = "high",
						line_length = 8,
						frame_count = 40,
						animation_speed = animation_speed,
						width = 206,
						height = 202,
						shift = util.by_pixel(-4, -24),
						scale = 0.5
					}
				},
				{
					priority = "high",
					filename = "__base__/graphics/entity/pumpjack/pumpjack-horsehead-shadow.png",
					animation_speed = animation_speed,
					line_length = 8,
					frame_count = 40,
					animation_speed = animation_speed,
					width = 155,
					height = 41,
					shift = util.by_pixel(17.5, 14.5),
					draw_as_shadow = true,
					hr_version =
					{
						priority = "high",
						filename = "__base__/graphics/entity/pumpjack/hr-pumpjack-horsehead-shadow.png",
						line_length = 8,
						frame_count = 40,
						animation_speed = animation_speed,
						width = 309,
						height = 82,
						shift = util.by_pixel(17.75, 14.5),
						draw_as_shadow = true,
						scale = 0.5
					}
				}
			}
		}
	}
end
	
return animation_set