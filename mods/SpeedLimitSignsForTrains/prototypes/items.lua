data:extend(
	{
		{
			type = "item",
			name = "train-limit",
			icon = "__SpeedLimitSignsForTrains__/graphics/train-limit-itm.png",
			icon_size = 32,
			subgroup = "transport",
			place_result = "placed-train-limit",
			stack_size = 50
		},
        {
            type = "constant-combinator",
            name = "placed-train-limit",
            icon = "__SpeedLimitSignsForTrains__/graphics/train-limit.png",
			icon_size = 32,
            flags = {"placeable-neutral", "player-creation"},
            fast_replaceable_group = "railway-sign",
            minable = {hardness = 0.2, mining_time = 0.5, result = "train-limit"},
            max_health = 80,
            corpse = "small-remnants",
            
            item_slot_count = 1,
            collision_box = {{-0.2, -0.2}, {0.2, 0.2}},
            building_collision_box = {{-0.2, -0.2}, {0.2, 0.2}},
            selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
            render_layer = "object",
            
            resistances =
            {
                {
                    type = "fire",
                    percent = 100
                }
            },
            sprites =
            {
                north =
                {
                    filename = "__SpeedLimitSignsForTrains__/graphics/train-limit.png",
                    priority = "high",
                    width = 32,
                    height = 64,
                    shift = {0, -0.8}
                },
                east =
                {
                    filename = "__SpeedLimitSignsForTrains__/graphics/train-limit.png",
                    priority = "high",
                    width = 32,
                    height = 64,
                    shift = {0, -0.8}
                },
                south =
                {
                    filename = "__SpeedLimitSignsForTrains__/graphics/train-limit.png",
                    priority = "high",
                    width = 32,
                    height = 64,
                    shift = {0, -0.8}
                },
                west =
                {
                    filename = "__SpeedLimitSignsForTrains__/graphics/train-limit.png",
                    priority = "high",
                    width = 32,
                    height = 64,
                    shift = {0, -0.8}
                }
            },
            activity_led_sprites =
            {
              north =
              {
                filename = "__SpeedLimitSignsForTrains__/graphics/activity-leds/combinator-led-constant-north.png",
                width = 11,
                height = 10,
                frame_count = 1,
                shift = {0.296875, -0.40625},
              },
              east =
              {
                filename = "__SpeedLimitSignsForTrains__/graphics/activity-leds/combinator-led-constant-east.png",
                width = 14,
                height = 12,
                frame_count = 1,
                shift = {0.25, -0.03125},
              },
              south =
              {
                filename = "__SpeedLimitSignsForTrains__/graphics/activity-leds/combinator-led-constant-south.png",
                width = 11,
                height = 11,
                frame_count = 1,
                shift = {-0.296875, -0.078125},
              },
              west =
              {
                filename = "__SpeedLimitSignsForTrains__/graphics/activity-leds/combinator-led-constant-west.png",
                width = 12,
                height = 12,
                frame_count = 1,
                shift = {-0.21875, -0.46875},
              }
            },

            activity_led_light =
            {
              intensity = 0.8,
              size = 1,
            },

            activity_led_light_offsets =
            {
              {0.296875, -0.40625},
              {0.25, -0.03125},
              {-0.296875, -0.078125},
              {-0.21875, -0.46875}
            },
            
            circuit_wire_connection_points =
            {
              {
                shadow =
                {
                  red = {0.15625, -0.28125},
                  green = {0.65625, -0.25}
                },
                wire =
                {
                  red = {-0.05, -0.60},
                  green = {0.05, -0.60},
                }
              },
              {
                shadow =
                {
                  red = {0.15625, -0.28125},
                  green = {0.65625, -0.25}
                },
                wire =
                {
                  red = {-0.05, -0.60},
                  green = {0.05, -0.60},
                }
              },
              {
                shadow =
                {
                  red = {0.15625, -0.28125},
                  green = {0.65625, -0.25}
                },
                wire =
                {
                  red = {-0.05, -0.60},
                  green = {0.05, -0.60},
                }
              },
              {
                shadow =
                {
                  red = {0.15625, -0.28125},
                  green = {0.65625, -0.25}
                },
                wire =
                {
                  red = {-0.05, -0.60},
                  green = {0.05, -0.60},
                }
              }
            },
            
            circuit_wire_max_distance = 5
        },
        {
			type = "item",
			name = "train-unlimit",
			icon = "__SpeedLimitSignsForTrains__/graphics/train-unlimit-itm.png",
			icon_size = 32,
			subgroup = "transport",
			place_result = "placed-train-unlimit",
			stack_size = 50
		},
        {
            type = "constant-combinator",
            name = "placed-train-unlimit",
            icon = "__SpeedLimitSignsForTrains__/graphics/train-unlimit.png",
			icon_size = 32,
            flags = {"placeable-neutral", "player-creation"},
            fast_replaceable_group = "railway-sign",
            minable = {hardness = 0.2, mining_time = 0.5, result = "train-unlimit"},
            max_health = 80,
            corpse = "small-remnants",
            
            item_slot_count = 1,
            collision_box = {{-0.2, -0.2}, {0.2, 0.2}},
            building_collision_box = {{-0.2, -0.2}, {0.2, 0.2}},
            selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
            render_layer = "object",
            
            resistances =
            {
                {
                    type = "fire",
                    percent = 100
                }
            },
            sprites =
            {
                north =
                {
                    filename = "__SpeedLimitSignsForTrains__/graphics/train-unlimit.png",
                    priority = "high",
                    width = 32,
                    height = 64,
                    shift = {0, -0.8}
                },
                east =
                {
                    filename = "__SpeedLimitSignsForTrains__/graphics/train-unlimit.png",
                    priority = "high",
                    width = 32,
                    height = 64,
                    shift = {0, -0.8}
                },
                south =
                {
                    filename = "__SpeedLimitSignsForTrains__/graphics/train-unlimit.png",
                    priority = "high",
                    width = 32,
                    height = 64,
                    shift = {0, -0.8}
                },
                west =
                {
                    filename = "__SpeedLimitSignsForTrains__/graphics/train-unlimit.png",
                    priority = "high",
                    width = 32,
                    height = 64,
                    shift = {0, -0.8}
                }
            },
            activity_led_sprites =
            {
              north =
              {
                filename = "__SpeedLimitSignsForTrains__/graphics/activity-leds/combinator-led-constant-north.png",
                width = 11,
                height = 10,
                frame_count = 1,
                shift = {0.296875, -0.40625},
              },
              east =
              {
                filename = "__SpeedLimitSignsForTrains__/graphics/activity-leds/combinator-led-constant-east.png",
                width = 14,
                height = 12,
                frame_count = 1,
                shift = {0.25, -0.03125},
              },
              south =
              {
                filename = "__SpeedLimitSignsForTrains__/graphics/activity-leds/combinator-led-constant-south.png",
                width = 11,
                height = 11,
                frame_count = 1,
                shift = {-0.296875, -0.078125},
              },
              west =
              {
                filename = "__SpeedLimitSignsForTrains__/graphics/activity-leds/combinator-led-constant-west.png",
                width = 12,
                height = 12,
                frame_count = 1,
                shift = {-0.21875, -0.46875},
              }
            },

            activity_led_light =
            {
              intensity = 0.8,
              size = 1,
            },

            activity_led_light_offsets =
            {
              {0.296875, -0.40625},
              {0.25, -0.03125},
              {-0.296875, -0.078125},
              {-0.21875, -0.46875}
            },
            
            circuit_wire_connection_points =
            {
              {
                shadow =
                {
                  red = {0.15625, -0.28125},
                  green = {0.65625, -0.25}
                },
                wire =
                {
                  red = {-0.05, -0.60},
                  green = {0.05, -0.60},
                }
              },
              {
                shadow =
                {
                  red = {0.15625, -0.28125},
                  green = {0.65625, -0.25}
                },
                wire =
                {
                  red = {-0.05, -0.60},
                  green = {0.05, -0.60},
                }
              },
              {
                shadow =
                {
                  red = {0.15625, -0.28125},
                  green = {0.65625, -0.25}
                },
                wire =
                {
                  red = {-0.05, -0.60},
                  green = {0.05, -0.60},
                }
              },
              {
                shadow =
                {
                  red = {0.15625, -0.28125},
                  green = {0.65625, -0.25}
                },
                wire =
                {
                  red = {-0.05, -0.60},
                  green = {0.05, -0.60},
                }
              }
            },
            
            circuit_wire_max_distance = 5
        },
	}
)