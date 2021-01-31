data:extend({
	{
		type = "item",
		name = "ion-cannon-targeter",
		icon = ModPath.."graphics/crosshairs64.png",
		icon_size = 64,
		place_result = "ion-cannon-targeter",
		subgroup = "capsule",
		order = "c[target]",
		stack_size = 1,
	}
})

data:extend({
	{
		type = "recipe",
		name = "ion-cannon-targeter",
		energy_required = 0.5,
		enabled = false,
		category = "crafting",
		ingredients =
		{
			{"processing-unit", 1},
			{"plastic-bar", 2},
			{"battery", 1}
		},
		result = "ion-cannon-targeter"
	},
})

local ion_cannon_targeter = util.table.deepcopy(data.raw["ammo-turret"]["gun-turret"])
--local ion_cannon_targeter = util.table.deepcopy(data.raw["capsule"]["artillery-targeting-remote"])
-- artillery-wagon-cannon (item)
-- artillery-turret (entity)
-- artillery-targeting-remote

ion_cannon_targeter.name = "ion-cannon-targeter"
ion_cannon_targeter.icon = ModPath.."graphics/crosshairs64.png"
ion_cannon_targeter.icon_size = 64
ion_cannon_targeter.icon_mipmaps = 0
ion_cannon_targeter.flags = {"placeable-off-grid", "not-on-map"}
ion_cannon_targeter.collision_mask = {}
ion_cannon_targeter.max_health = 1
ion_cannon_targeter.inventory_size = 0
ion_cannon_targeter.collision_box = {{0, 0}, {0, 0}}
ion_cannon_targeter.selection_box = {{0, 0}, {0, 0}}
ion_cannon_targeter.folded_animation =
{
	layers =
	{
		{
			filename = "__core__/graphics/empty.png",
			priority = "low",
			width = 1,
			height = 1,
			frame_count = 1,
			line_length = 1,
			run_mode = "forward",
			axially_symmetrical = false,
			direction_count = 1,
			shift = {0, 0}
		}
	}
}
ion_cannon_targeter.base_picture =
{
	layers =
	{
		{
			filename = ModPath.."graphics/crosshairs64.png",
			line_length = 1,
			width = 64,
			height = 64,
			frame_count = 1,
			axially_symmetrical = false,
			direction_count = 1,
			shift = {0, 0}
		}
	}
}
ion_cannon_targeter.attack_parameters =
{
	type = "projectile",
	ammo_category = "melee",
	cooldown = 1,
	projectile_center = {0, 0},
	projectile_creation_distance = 1.4,
	range = settings.startup["ion-cannon-radius"].value,
	damage_modifier = 1,
	ammo_type =
	{
		type = "projectile",
		category = "melee",
		energy_consumption = "0J",
		action =
		{
			{
				type = "direct",
				action_delivery =
				{
					{
						type = "projectile",
						projectile = "dummy-crosshairs",
						starting_speed = 0.28
					}
				}
			}
		}
	}
}

data:extend({ion_cannon_targeter})