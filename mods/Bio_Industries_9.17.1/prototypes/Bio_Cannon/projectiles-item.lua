if BI.Settings.Bio_Cannon then

	data:extend({

		-- Hive Buster Basic Ammo
		{
			type = "ammo",
			name = "bi-bio-cannon-basic-ammo",
			icon = "__Bio_Industries__/graphics/entities/bio_cannon/projectiles/Bio_Cannon_Basic_Ammo_Icon.png",
			icon_size = 32,
			--flags = {  },
			ammo_type =
			{
				category = "artillery-shell",
				target_type = "direction",
				action =
				{
					{
						type = "direct",
						action_delivery =
						{				
							type = "projectile",
							projectile = "bi-bio-cannon-basic-ammo",
							starting_speed = 1,
							direction_deviation = 0.8,
							range_deviation = 0.8,
							max_range = 90
						}
					}
				}
			},
			subgroup = "ammo",
			order = "z[Bio_Cannon_Ammo]-a[Basic]",
			stack_size = 50,
		},

			-- Poison Ammo
		{
			type = "ammo",
			name = "bi-bio-cannon-poison-ammo",
			icon = "__Bio_Industries__/graphics/entities/bio_cannon/projectiles/Bio_Cannon_Poison_Ammo_Icon.png",
			icon_size = 32,
			--flags = {  },
			ammo_type =
			{
				category = "artillery-shell",
				target_type = "direction",
				action =
				{
					{
						type = "direct",
						action_delivery =
						{				
							type = "projectile",
							projectile = "bi-bio-cannon-poison-ammo",
							starting_speed = 1,
							direction_deviation = 0.8,
							range_deviation = 0.8,
							max_range = 90
						}
					}
				}
			},
			subgroup = "ammo",
			order = "z[Bio_Cannon_Ammo]-b[Poison]",
			stack_size = 50,
		},

		
	})

end