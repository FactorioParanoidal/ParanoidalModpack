--THERMONUCLEAR EXPLOSION

local thermonuclear_action =
{
	type = "direct",
	action_delivery =
		{
		type = "instant",
		target_effects =
		{
			{
				repeat_count = 300,
				type = "create-trivial-smoke",
				smoke_name = "nuclear-smoke",
				offset_deviation = {{-1, -1}, {1, 1}},
				slow_down_factor = 1,
				starting_frame = 3,
				starting_frame_deviation = 5,
				starting_frame_speed = 0,
				starting_frame_speed_deviation = 5,
				speed_from_center = 0.5,
				speed_deviation = 0.2
			},
			{
				type = "create-entity",
				entity_name = "explosion"
			},
			{
				type = "damage",
				damage = {amount = 4000, type = "explosion"}
			},
			{
				type = "create-entity",
				entity_name = "small-scorchmark",
				check_buildability = true
			},
			{
				type = "nested-result",
				action =
				{
					type = "area",
					target_entities = false,
					trigger_from_target = true,
					repeat_count = 8000,
					radius = 70,
					action_delivery =
					{
						type = "projectile",
						projectile = "atomic-bomb-wave",
						starting_speed = 0.3
					}
				}
			},
			{
				type = "nested-result",
				action =
				{
					type = "area",
					target_entities = false,
					trigger_from_target = true,
					repeat_count = 6000,
					radius = 60,
					action_delivery =
					{
						type = "projectile",
						projectile = "atomic-bomb-wave",
						starting_speed = 0.4
					}
				}
			},
			{
				type = "nested-result",
				action =
				{
					type = "area",
					target_entities = false,
					trigger_from_target = true,
					repeat_count = 4000,
					radius = 50,
					action_delivery =
					{
						type = "projectile",
						projectile = "atomic-bomb-wave",
						starting_speed = 0.5
					}
				}
			}
		}
	}
}

--NUCLEAR EXPLOSION

local nuclear_action =
{
	type = "nested-result",
	action =
	{
		type = "area",
		target_entities = false,
		trigger_from_target = true,
		repeat_count = 2000,
		radius = 35,
		action_delivery =
		{
			type = "projectile",
			projectile = "atomic-bomb-wave",
			starting_speed = 0.5
		}
	}
}

--THERMONUCLEAR BOMB PROJECTILE

data:extend(
{
	{
    type = "projectile",
    name = "thermonuclear-rocket",
    flags = {"not-on-map"},
    acceleration = 0.002,
    action = thermonuclear_action,
    light = {intensity = 0.8, size = 15},
    animation =
    {
      filename = "__base__/graphics/entity/rocket/rocket.png",
      frame_count = 8,
      line_length = 8,
      width = 9,
      height = 35,
      shift = {0, 0},
      priority = "high"
    },
    shadow =
    {
      filename = "__base__/graphics/entity/rocket/rocket-shadow.png",
      frame_count = 1,
      width = 7,
      height = 24,
      priority = "high",
      shift = {0, 0}
    },
    smoke =
    {
      {
        name = "smoke-fast",
        deviation = {0.15, 0.15},
        frequency = 1,
        position = {0, -1},
        slow_down_factor = 1,
        starting_frame = 3,
        starting_frame_deviation = 5,
        starting_frame_speed = 0,
        starting_frame_speed_deviation = 5
      }
    }
	}
}
)

--ARTILLERY SHELL PROJECTILES

local nuclear_artillery_projectile = util.table.deepcopy(data.raw["artillery-projectile"]["artillery-projectile"])
nuclear_artillery_projectile.name = "artillery-projectile-nuclear"
table.insert(nuclear_artillery_projectile.action.action_delivery.target_effects, nuclear_action)


local thermonuclear_artillery_projectile = util.table.deepcopy(data.raw["artillery-projectile"]["artillery-projectile"])
thermonuclear_artillery_projectile.name = "artillery-projectile-thermonuclear"
thermonuclear_artillery_projectile.action = thermonuclear_action


if settings.startup["artillery-shells"].value == true then
	data:extend(
	{
		nuclear_artillery_projectile,
		thermonuclear_artillery_projectile,
		{
			type = "ammo",
			name = "artillery-shell-nuclear",
			icons =
			{
				{
					icon = "__base__/graphics/icons/artillery-shell.png",
				},
				{
					icon = "__base__/graphics/icons/atomic-bomb.png",
					scale = 0.4,
					shift = {-10, -10},
				},
			},
			icon_size = 32,
			ammo_type =
			{
				category = "artillery-shell",
				target_type = "position",
				action =
				{
					type = "direct",
					action_delivery =
					{
						type = "artillery",
						projectile = "artillery-projectile-nuclear",
						starting_speed = 1,
						direction_deviation = 0,
						range_deviation = 0,
						source_effects =
						{
							type = "create-explosion",
							entity_name = "artillery-cannon-muzzle-flash"
						}
					}
				}
			},
			subgroup = "ammo",
			order = "d[explosive-cannon-shell]-d[artillery]2",
			stack_size = 1
		},

		{
			type = "ammo",
			name = "artillery-shell-thermonuclear",
			icons =
			{
				{
					icon = "__base__/graphics/icons/artillery-shell.png",
				},
				{
					icon = "__Clowns-Nuclear__/graphics/icons/thermonuclear-bomb.png",
					scale = 0.4,
					shift = {-10, -10},
				},
			},
			icon_size = 32,
			ammo_type =
			{
				category = "artillery-shell",
				target_type = "position",
				action =
				{
					type = "direct",
					action_delivery =
					{
						type = "artillery",
						projectile = "artillery-projectile-thermonuclear",
						starting_speed = 1,
						direction_deviation = 0,
						range_deviation = 0,
						source_effects =
						{
							type = "create-explosion",
							entity_name = "artillery-cannon-muzzle-flash"
						}
					}
				}
			},
			subgroup = "ammo",
			order = "d[explosive-cannon-shell]-d[artillery]2",
			stack_size = 1
		},
	}
	)
end
