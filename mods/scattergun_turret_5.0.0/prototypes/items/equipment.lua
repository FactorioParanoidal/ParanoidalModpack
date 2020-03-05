data:extend({
{
	type = "active-defense-equipment",
	name = "w93-modular-gun-tlaser",
	sprite =
	{
		filename = "__scattergun_turret__/graphics/icons/equipment/tlaser-gun.png",
		width = 64,
		height = 64,
		priority = "medium",
	},
	shape =
	{
		width = 2,
		height = 2,
		type = "full",
	},
	energy_source =
	{
		type = "electric",
		usage_priority = "secondary-input",

		buffer_capacity = "8MJ"
	},
	attack_parameters =
	{
		type = "projectile",
		ammo_category = "electric",
		cooldown = 90,
		projectile_creation_distance = 0.6,
		projectile_center = {0.0, 0.0},
		min_range = 10,
		range = 35,
		ammo_type =
		{
        		target_type = "entity",

			category = "laser-turret",

			energy_consumption = "4MJ",
			action =
			{
				type = "direct",
				action_delivery =
				{
					type = "instant",
					target_effects =
					{
						{
							type = "create-explosion",
							entity_name = "w93-tlaser"
						},
						{
							type = "damage",
							damage = { amount = 120, type="fire"}
						},
					},
				},
			},
		},
		sound = 
		{
			{
				filename = "__scattergun_turret__/sound/tlaser-turret-fire.ogg",
				volume = 0.75
			}
		}
	},
	automatic = true,
	categories = { "armor" }
}})