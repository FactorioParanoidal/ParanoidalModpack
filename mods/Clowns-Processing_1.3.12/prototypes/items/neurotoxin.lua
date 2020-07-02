local neurotoxincloud=table.deepcopy(data.raw["smoke-with-trigger"]["poison-cloud"])

neurotoxincloud.name="neurotoxin-cloud"
neurotoxincloud.action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          type = "nested-result",
          action =
          {
            type = "area",
            radius = 16,--poison cloud has radius = 11,
            entity_flags = {"breaths-air"},
            action_delivery =
            {
              type = "instant",
              target_effects =
              {
                type = "damage",
                damage = { amount = 20, type = "poison"}--poison cloud has damage = { amount = 8, type = "poison"}
              }
            }
          }
        }
      }
    }
neurotoxincloud.particle_spread={ 4.5 * 1.05, 4.5 * 0.6 * 1.05 }
neurotoxincloud.particle_count=30
neurotoxincloud.created_effect = {
    {
      action_delivery = {
        target_effects = {
          entity_name = "poison-cloud-visual-dummy",
          initial_height = 0,
          show_in_tooltip = false,
          type = "create-smoke"
        },
        type = "instant"
      },
      cluster_count = 15,--10,
      distance = 7,--4,
      distance_deviation = 5,
      type = "cluster"
    },
    {
      action_delivery = {
        target_effects = {
          entity_name = "poison-cloud-visual-dummy",
          initial_height = 0,
          show_in_tooltip = false,
          type = "create-smoke"
        },
        type = "instant"
      },
      cluster_count = 15,--11,
      distance = 15,--8.8000000000000007,
      distance_deviation = 3, --2,
      type = "cluster"
    }
  },
data:extend({neurotoxincloud})
data:extend(
{
	{
		type = "projectile",
		name = "neurotoxin-capsule",
		flags = {"not-on-map"},
		acceleration = 0.005,
		action =
		{
			type = "direct",
			action_delivery =
			{
				type = "instant",
				target_effects =
				{
					type = "create-entity",
					show_in_tooltip = true,
					entity_name = "neurotoxin-cloud",
					initial_height = 0
				},
				{
					type = "create-particle",
					particle_name = "poison-capsule-metal-particle",
					repeat_count = 8,
					initial_height = 1,
					initial_vertical_speed = 0.1,
					initial_vertical_speed_deviation = 0.05,
					offset_deviation = {{-0.1, -0.1}, {0.1, 0.1}},
					speed_from_center = 0.05,
					speed_from_center_deviation = 0.01
				}
			}
		},
		light = {intensity = 0.5, size = 4},
		animation =
		{
			filename = "__base__/graphics/entity/poison-capsule/poison-capsule.png",
			frame_count = 16,
			line_length = 8,
			animation_speed = 0.250,
			width = 29,
			height = 29,
			shift = util.by_pixel(1, 0.5),
			priority = "high",
			hr_version =
			{
				filename = "__base__/graphics/entity/poison-capsule/hr-poison-capsule.png",
				frame_count = 16,
				line_length = 8,
				animation_speed = 0.250,
				width = 58,
				height = 59,
				shift = util.by_pixel(1, 0.5),
				priority = "high",
				scale = 0.5
			}

		},
		shadow =
		{
			filename = "__base__/graphics/entity/poison-capsule/poison-capsule-shadow.png",
			frame_count = 16,
			line_length = 8,
			animation_speed = 0.250,
			width = 27,
			height = 21,
			shift = util.by_pixel(1, 2),
			priority = "high",
			draw_as_shadow = true,
			hr_version =
			{
				filename = "__base__/graphics/entity/poison-capsule/hr-poison-capsule-shadow.png",
				frame_count = 16,
				line_length = 8,
				animation_speed = 0.250,
				width = 54,
				height = 42,
				shift = util.by_pixel(1, 2),
				priority = "high",
				draw_as_shadow = true,
				scale = 0.5
			}
		},
		smoke =
		{
			{
				name = "poison-capsule-smoke",
				deviation = {0.15, 0.15},
				frequency = 1,
				position = {0, 0},
				starting_frame = 3,
				starting_frame_deviation = 5,
				starting_frame_speed_deviation = 5
			}
		}
	},
}
)
