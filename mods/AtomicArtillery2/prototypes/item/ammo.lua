data:extend(
{
	{
        type = "ammo",
        ammo_category = "artillery-shell",
		name = "atomic-artillery-shell",
		icon = "__AtomicArtillery2__/graphics/icons/atomic-artillery-shell.png",
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
					projectile = "atomic-artillery-projectile",
					starting_speed = 1,
					direction_deviation = 0,
					range_deviation = 0,
					source_effects =
					{
						type = "create-explosion",
						entity_name = "artillery-cannon-muzzle-flash"
					},
				}
			},
		},
		subgroup = "ammo",
		order = "d[explosive-cannon-shell]-d[artillery]",
		stack_size = 1
	}
}
)