local ion_cannon_targeter = util.table.deepcopy(data.raw["ammo-turret"]["gun-turret"])

ion_cannon_targeter.name = "ion-cannon-targeter"
ion_cannon_targeter.icon = "__Orbital Ion Cannon__/graphics/crosshairs64.png"
ion_cannon_targeter.icon_size = 64
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
			filename = "__Orbital Ion Cannon__/graphics/crosshairs64.png",
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

data:extend({
	{
		type = "projectile",
		name = "crosshairs",
		flags = {"not-on-map"},
		acceleration = .0009 / (settings.startup["ion-cannon-heatup-multiplier"].value * settings.startup["ion-cannon-heatup-multiplier"].value),
		action =
		{
			{
				type = "direct",
				action_delivery =
				{
					type = "instant",
					target_effects =
					{
						{
							type = "create-entity",
							entity_name = "huge-explosion"
						},
						{
							type = "create-entity",
							entity_name = "ion-cannon-beam"
						},
						{
							type = "create-entity",
							entity_name = "enormous-scorchmark",
							check_buildability = true
						},
						{
							type = "create-entity",
							entity_name = "ion-cannon-explosion",
							trigger_created_entity = "true"
						},
						{
							type = "show-explosion-on-chart",
							scale = settings.startup["ion-cannon-radius"].value / 20
						},
					}
				}
			},
			{
				type = "area",
				radius = settings.startup["ion-cannon-radius"].value * 0.8,
				action_delivery =
				{
					type = "instant",
					target_effects =
					{
						{
							type = "create-fire",
							entity_name = "fire-flame"
						},
						{
							type = "create-fire",
							entity_name = "fire-flame-on-tree"
						}
					}
				}
			},
			{
				type = "area",
				radius = settings.startup["ion-cannon-radius"].value * 0.8,
				action_delivery =
				{
					type = "instant",
					target_effects =
					{
						{
							type = "damage",
							damage = {amount = settings.startup["ion-cannon-laser-damage"].value, type = "laser"}
						},
						{
							type = "damage",
							damage = {amount = settings.startup["ion-cannon-explosion-damage"].value, type = "explosion"}
						}
					}
				}
			},
			{
				type = "area",
				radius = settings.startup["ion-cannon-radius"].value,
				action_delivery =
				{
					type = "instant",
					target_effects =
					{
						{
							type = "create-sticker",
							sticker = "fire-sticker"
						},
						{
							type = "create-fire",
							entity_name = "fire-flame"
						},
						{
							type = "create-fire",
							entity_name = "fire-flame-on-tree"
						}
					}
				}
			}
		},
		light = {intensity = 0, size = 0},
		animation =
		{
			filename = "__core__/graphics/empty.png",
			priority = "low",
			width = 1,
			height = 1,
			frame_count = 1
		},
		shadow =
		{
			filename = "__core__/graphics/empty.png",
			priority = "low",
			width = 1,
			height = 1,
			frame_count = 1
		}
	},

	{
		type = "projectile",
		name = "dummy-crosshairs",
		flags = {"not-on-map"},
		acceleration = .0009 / (settings.startup["ion-cannon-heatup-multiplier"].value * settings.startup["ion-cannon-heatup-multiplier"].value),
		action =
		{
			{
				type = "area",
				radius = settings.startup["ion-cannon-radius"].value * 0.8,
				action_delivery =
				{
					type = "instant",
					target_effects =
					{
						{
							type = "damage",
							damage = {amount = settings.startup["ion-cannon-laser-damage"].value, type = "laser"}
						},
						{
							type = "damage",
							damage = {amount = settings.startup["ion-cannon-explosion-damage"].value, type = "explosion"}
						}
					}
				}
			},
			{
				type = "area",
				radius = settings.startup["ion-cannon-radius"].value,
				action_delivery =
				{
					type = "instant",
					target_effects =
					{
						{
							type = "create-fire",
							entity_name = "fire-flame"
						}
					}
				}
			}
		},
		light = {intensity = 0, size = 0},
		animation =
		{
			filename = "__core__/graphics/empty.png",
			priority = "low",
			width = 1,
			height = 1,
			frame_count = 1
		},
		shadow =
		{
			filename = "__core__/graphics/empty.png",
			priority = "low",
			width = 1,
			height = 1,
			frame_count = 1
		}
	},

	{
		type = "sound",
		name = "ion-cannon-klaxon",
		variations =
		{
			{
				filename = "__Orbital Ion Cannon__/sound/Klaxon.ogg",
				volume = 0.75
			},
		},
	},

	{
		type = "simple-entity",
		name = "ion-cannon-target",
		icon = "__Orbital Ion Cannon__/graphics/crosshairs64.png",
		icon_size = 64,
		flags = {"placeable-off-grid", "not-on-map"},
		max_health = 1,
		render_layer = "air-object",
		final_render_layer = "air-object",
		collision_box = {{0,0}, {0,0}},
		selection_box = {{0,0}, {0,0}},
		resistances = {},
		animations =
		{
			{
				filename = "__Orbital Ion Cannon__/graphics/crosshairs_anim.png",
				priority = "low",
				width = 64,
				height = 64,
				frame_count = 32,
				animation_speed = 0.35,
				line_length = 8,
				shift = {0, -1},
				scale = 1,
			}
		},
		-- pictures =
		-- {
			-- {
				-- filename = "__Orbital Ion Cannon__/graphics/crosshairsEntity.png",
				-- priority = "low",
				-- width = 64,
				-- height = 64,
				-- scale = 1,
				-- shift = {0, -1},
				-- frame_count = 1
			-- },
		-- }
	},

	{
		type = "smoke-with-trigger",
		name = "ion-cannon-explosion",
		flags = {"not-on-map"},
		show_when_smoke_off = true,
		animation =
		{
			filename = "__Orbital Ion Cannon__/graphics/explosion.png",
			priority = "low",
			width = 192,
			height = 192,
			frame_count = 25,
			animation_speed = 0.2,
			line_length = 5,
			scale = 5 * (settings.startup["ion-cannon-radius"].value / 15),
		},
		slow_down_factor = 0,
		affected_by_wind = false,
		cyclic = false,
		duration = 60 * 5,
		spread_duration = 10,
	},

	{
		type = "smoke-with-trigger",
		name = "ion-cannon-beam",
		flags = {"not-on-map"},
		show_when_smoke_off = true,
		animation =
		{
			filename = "__Orbital Ion Cannon__/graphics/IonBeam.png",
			priority = "low",
			width = 110,
			height = 1280,
			frame_count = 1,
			animation_speed = 0.01,
			line_length = 1,
			shift = {-0.1, -27.5},
			scale = 1,
		},
		slow_down_factor = 0,
		affected_by_wind = false,
		cyclic = false,
		duration = 60 * 2,
		fade_away_duration = 60 * 1,
		spread_duration = 10,
	},

	{
		type = "explosion",
		name = "huge-explosion",
		flags = {"not-on-map"},
		animations =
		{
			{
				filename = "__base__/graphics/entity/medium-explosion/medium-explosion.png",
				priority = "high",
				width = 112,
				height = 94,
				scale = 0.8,
				frame_count = 54,
				line_length = 6,
				shift = {-0.56, -0.96},
				animation_speed = 0.5
			},
		},
		light = {intensity = 2, size = settings.startup["ion-cannon-radius"].value * 3},
		sound =
		{
			{
				filename = "__Orbital Ion Cannon__/sound/OrbitalIonCannon.ogg",
				volume = 2.0
			},
		},
		created_effect =
		{
			type = "direct",
			action_delivery =
			{
				type = "instant",
				target_effects =
				{
					{
						type = "create-particle",
						repeat_count = 60,
						entity_name = "explosion-remnants-particle",
						initial_height = 0.5,
						speed_from_center = 0.15,
						speed_from_center_deviation = 0.15,
						initial_vertical_speed = 0.1,
						initial_vertical_speed_deviation = 0.15,
						offset_deviation = {{-0.2, -0.2}, {0.2, 0.2}}
					}
				}
			}
		}
	}
})

local yuge_crater = util.table.deepcopy(data.raw["corpse"]["small-scorchmark"])

yuge_crater.name = "enormous-scorchmark"
yuge_crater.order = "d[remnants]-b[scorchmark]-b[yuge]"
yuge_crater.animation.scale = settings.startup["ion-cannon-radius"].value / 4
yuge_crater.ground_patch.sheet.scale = settings.startup["ion-cannon-radius"].value / 4
yuge_crater.ground_patch_higher.sheet.scale = settings.startup["ion-cannon-radius"].value / 4,

data:extend({yuge_crater})

if not settings.startup["ion-cannon-flames"].value then
	data.raw["projectile"]["crosshairs"].action =
	{
		{
			type = "area",
			radius = settings.startup["ion-cannon-radius"].value,
			action_delivery =
			{
				type = "instant",
				target_effects =
				{
					{
						type = "damage",
						damage = {amount = settings.startup["ion-cannon-laser-damage"].value / 2, type = "laser"}
					},
					{
						type = "damage",
						damage = {amount = settings.startup["ion-cannon-explosion-damage"].value / 2, type = "explosion"}
					}
				}
			}
		},
		{
			type = "direct",
			action_delivery =
			{
				type = "instant",
				target_effects =
				{
					{
						type = "create-entity",
						entity_name = "huge-explosion"
					},
					{
						type = "create-entity",
						entity_name = "ion-cannon-beam"
					},
					{
						type = "create-entity",
						entity_name = "enormous-scorchmark",
						check_buildability = true
					},
					{
						type = "create-entity",
						entity_name = "ion-cannon-explosion",
						trigger_created_entity = "true"
					}
				}
			}
		},
		{
			type = "area",
			radius = settings.startup["ion-cannon-radius"].value,
			action_delivery =
			{
				type = "instant",
				target_effects =
				{
					{
						type = "create-fire",
						entity_name = "fire-flame-on-tree"
					},
					{
						type = "damage",
						damage = {amount = settings.startup["ion-cannon-laser-damage"].value / 2, type = "laser"}
					},
					{
						type = "damage",
						damage = {amount = settings.startup["ion-cannon-explosion-damage"].value / 2, type = "explosion"}
					}
				}
			}
		}
	}
end
