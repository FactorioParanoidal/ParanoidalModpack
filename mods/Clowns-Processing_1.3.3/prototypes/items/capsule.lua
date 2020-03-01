data:extend(
{
	{
		type = "capsule",
		name = "neurotoxin-capsule",
		icon = "__Clowns-Processing__/graphics/icons/neurotoxin-capsule.png",
		icon_size = 32,
		capsule_action =
		{
			type = "throw",
			attack_parameters =
			{
				type = "projectile",
				ammo_category = "capsule",
				cooldown = 60,
				projectile_creation_distance = 0.6,
				range = 35,
				ammo_type =
				{
					category = "capsule",
					target_type = "position",
					action =
					{
						type = "direct",
						action_delivery =
						{
							type = "projectile",
							projectile = "neurotoxin-capsule",
							starting_speed = 0.2
						}
					}
				}
			}
		},
		subgroup = "capsule",
		order = "c-a",--Just after slowdown-capsule
		stack_size = 50
	}
}
)