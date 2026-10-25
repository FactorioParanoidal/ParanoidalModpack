data:extend({
	{
		type = "ammo-category",
		name = "plasma",
	},
	-- recipes
	{
		type = "recipe",
		name = "y-bullet-case",
		category = "yuoki-formpress",
		enabled = true,
		energy_required = 2,
		ingredients = {
			{ type = "item", name = "y-pure-copper", amount = 1 },
			{ type = "item", name = "y-refined-yres1", amount = 1 },
		},
		results = {
			{ type = "item", name = "y-bullet-case", amount = 7 },
		},
		main_product = "y-bullet-case",
		subgroup = "y-ammo",
		order = "a1",
	},

	{
		type = "recipe",
		name = "y-ammo-acid-2",
		category = "crafting-with-fluid",
		enabled = true,
		energy_required = 17.5,
		ingredients = {
			{ type = "item", name = "y-bullet-case", amount = 5 },
			{ type = "item", name = "copper-plate", amount = 3 },
			{ type = "fluid", name = "sulfuric-acid", amount = 1 },
		},
		results = {
			{ type = "item", name = "y-ammo-acid-2", amount = 5 },
			{ type = "item", name = "y_rwtechsign", amount = 1 },
		},
		main_product = "y-ammo-acid-2",
		subgroup = "y-ammo",
		order = "b1",
	},

	{
		type = "recipe",
		name = "y-ammo-hohlspitz",
		enabled = true,
		energy_required = 15,
		ingredients = {
			{ type = "item", name = "y-bullet-case", amount = 5 },
			{ type = "item", name = "y-pure-copper", amount = 2 },
		},
		results = {
			{ type = "item", name = "y-ammo-hohlspitz", amount = 5 },
		},
		main_product = "y-ammo-hohlspitz",
		subgroup = "y-ammo",
		order = "c1",
	},

	{
		type = "recipe",
		name = "y-ammo-explosiv",
		enabled = true,
		energy_required = 20,
		ingredients = {
			{ type = "item", name = "y-bullet-case", amount = 5 },
			{ type = "item", name = "y-richdust", amount = 10 },
			{ type = "item", name = "y-coal-dust", amount = 5 },
		},
		results = {
			{ type = "item", name = "y-ammo-explosiv", amount = 5 },
			{ type = "item", name = "ypfw_trader_sign", amount = 1 },
		},
		main_product = "y-ammo-explosiv",
		subgroup = "y-ammo",
		order = "d1",
	},

	{
		type = "recipe",
		name = "y-ammo-poison",
		enabled = true,
		energy_required = 20,
		ingredients = {
			{ type = "item", name = "y-bullet-case", amount = 5 },
			{ type = "item", name = "y-pure-iron", amount = 2 },
			{ type = "item", name = "y-toxic-dust", amount = 40 },
		},
		results = {
			{ type = "item", name = "y-ammo-poison", amount = 5 },
			{ type = "item", name = "ypfw_trader_sign", amount = 1 },
		},
		main_product = "y-ammo-poison",
		subgroup = "y-ammo",
		order = "e1",
	},

	{
		type = "recipe",
		name = "y-ammo-biggun",
		enabled = true,
		energy_required = 20,
		ingredients = {
			{ type = "item", name = "y-bullet-case", amount = 5 },
			{ type = "item", name = "y-refined-yres1", amount = 5 },
			{ type = "item", name = "y-coal-dust", amount = 5 },
		},
		results = {
			{ type = "item", name = "y-ammo-biggun", amount = 5 },
			{ type = "item", name = "ypfw_trader_sign", amount = 1 },
		},
		main_product = "y-ammo-biggun",
		subgroup = "y-ammo",
		order = "f1",
	},

	{
		type = "recipe",
		name = "y-ammo-krakon",
		enabled = true,
		energy_required = 20,
		ingredients = {
			{ type = "item", name = "y-bullet-case", amount = 5 },
			{ type = "item", name = "y-crush-yres2", amount = 10 },
			{ type = "item", name = "y-pure-iron", amount = 2 },
		},
		results = {
			{ type = "item", name = "y-ammo-krakon", amount = 5 },
			{ type = "item", name = "ypfw_trader_sign", amount = 1 },
		},
		main_product = "y-ammo-krakon",
		subgroup = "y-ammo",
		order = "g1",
	},

	{
		type = "recipe",
		name = "y_ammo_case",
		category = "yuoki-formpress",
		enabled = true,
		energy_required = 2,
		ingredients = {
			{ type = "item", name = "y-pure-iron", amount = 1 },
			{ type = "item", name = "y-refined-yres2", amount = 1 },
		},
		results = {
			{ type = "item", name = "y_ammo_case", amount = 6 },
		},
		main_product = "y_ammo_case",
		subgroup = "y-ammo",
		order = "a2",
	},

	{
		type = "recipe",
		name = "y_ammo_plasma",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/ammo_plasma_64.png",
		enabled = true,
		energy_required = 4,
		ingredients = {
			{ type = "item", name = "y_ammo_case", amount = 4 },
			{ type = "item", name = "y-raw-fuelnium", amount = 1 },
		},
		results = {
			{ type = "item", name = "y_ammo_plasma", amount = 8 },
			{ type = "item", name = "y_rwtechsign", amount = 1 },
		},
		main_product = "y_ammo_plasma",
		subgroup = "y-ammo",
		order = "h1",
	},

	{
		type = "recipe",
		name = "y_ammo_flame",
		enabled = true,
		energy_required = 4,
		ingredients = {
			{ type = "item", name = "y_ammo_case", amount = 1 },
			{ type = "item", name = "y-toxic-dust", amount = 10 },
			{ type = "item", name = "y-c_mud", amount = 10 },
			{ type = "item", name = "y-richdust", amount = 2 },
		},
		results = {
			{ type = "item", name = "y_ammo_flame", amount = 8 },
			{ type = "item", name = "ypfw_trader_sign", amount = 1 },
		},
		main_product = "y_ammo_flame",
		subgroup = "y-ammo",
		order = "h2",
	},

	{
		type = "recipe",
		name = "yi_cannon_shell",
		enabled = true,
		energy_required = 4,
		ingredients = {
			{ type = "item", name = "y-bullet-case", amount = 5 },
			{ type = "item", name = "y-coal-dust", amount = 14 },
			{ type = "item", name = "y-raw-fuelnium", amount = 1 },
			{ type = "item", name = "y-richdust", amount = 10 },
		},
		results = {
			{ type = "item", name = "yi_cannon_shell", amount = 2 },
			{ type = "item", name = "ypfw_trader_sign", amount = 1 },
		},
		main_product = "yi_cannon_shell",
		subgroup = "y-ammo",
		order = "h2",
	},

	{
		type = "recipe",
		name = "yi_artillery_shell",
		enabled = true,
		energy_required = 4,
		ingredients = {
			{ type = "item", name = "y_ammo_case", amount = 5 },
			{ type = "item", name = "y-toxic-dust", amount = 20 },
			{ type = "item", name = "y-raw-fuelnium", amount = 4 },
		},
		results = {
			{ type = "item", name = "yi_artillery_shell", amount = 1 },
			{ type = "item", name = "ypfw_trader_sign", amount = 3 },
		},
		main_product = "yi_artillery_shell",
		subgroup = "y-ammo",
		order = "h2",
	},

	-- ammo
	{
		type = "item",
		name = "y-bullet-case",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/shell-case.png",
		group = "yuoki",
		subgroup = "y-ammo",
		order = "a1",
		stack_size = 250,
	},

	{
		type = "item",
		name = "y_ammo_case",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/ammo_kapsel_64.png",
		group = "yuoki",
		subgroup = "y-ammo",
		order = "a2",
		stack_size = 250,
	},

	{
		type = "ammo",
		name = "y-ammo-acid-2",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/ammo_poison.png",
		ammo_category = "bullet",
		ammo_type = {
			--category = "bullet",
			action = {
				type = "direct",
				action_delivery = {
					type = "instant",
					source_effects = {
						type = "create-explosion",
						entity_name = "explosion-gunshot",
					},
					target_effects = {
						{
							type = "create-entity",
							entity_name = "explosion-hit",
						},
						{
							type = "damage",
							damage = { amount = 8, type = "fire" },
						},
						{
							type = "damage",
							damage = { amount = 3, type = "physical" },
						},
					},
				},
			},
		},
		magazine_size = 50,
		subgroup = "y-ammo",
		order = "b1",
		stack_size = 200,
	},
	{
		type = "ammo",
		name = "y-ammo-hohlspitz",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/ammo_fire_64.png",
		ammo_category = "bullet",
		ammo_type = {
			--category = "bullet",
			action = {
				type = "direct",
				action_delivery = {
					type = "instant",
					source_effects = {
						type = "create-explosion",
						entity_name = "explosion-gunshot",
					},
					target_effects = {
						{
							type = "create-entity",
							entity_name = "explosion-hit",
						},
						{ type = "damage", damage = { amount = 7, type = "physical" } },
						{ type = "damage", damage = { amount = 3, type = "impact" } },
					},
				},
			},
		},
		magazine_size = 50,
		subgroup = "y-ammo",
		order = "c1",
		stack_size = 200,
	},
	{
		type = "ammo",
		name = "y-ammo-explosiv",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/ammo_wot.png",
		ammo_category = "bullet",
		ammo_type = {
			--category = "bullet",
			action = {
				type = "direct",
				action_delivery = {
					type = "instant",
					source_effects = {
						type = "create-explosion",
						entity_name = "explosion-gunshot",
					},
					target_effects = {
						{
							type = "create-entity",
							entity_name = "explosion-hit",
						},
						{
							type = "damage",
							damage = { amount = 12, type = "explosion" },
						},
					},
				},
			},
		},
		magazine_size = 50,
		subgroup = "y-ammo",
		order = "d1",
		stack_size = 200,
	},
	{
		type = "ammo",
		name = "y-ammo-poison",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/ammo_silver.png",
		ammo_category = "bullet",
		ammo_type = {
			--category = "bullet",
			action = {
				type = "direct",
				action_delivery = {
					type = "instant",
					source_effects = {
						type = "create-explosion",
						entity_name = "explosion-gunshot",
					},
					target_effects = {
						{
							type = "create-entity",
							entity_name = "explosion-hit",
						},
						{ type = "damage", damage = { amount = 9, type = "poison" } },
						{ type = "damage", damage = { amount = 3, type = "physical" } },
					},
				},
			},
		},
		magazine_size = 50,
		subgroup = "y-ammo",
		order = "e1",
		stack_size = 200,
	},
	{
		type = "ammo",
		name = "y-ammo-biggun",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/ammo_std.png",
		ammo_category = "bullet",
		ammo_type = {
			--category = "bullet",
			action = {
				type = "direct",
				action_delivery = {
					type = "instant",
					source_effects = {
						type = "create-explosion",
						entity_name = "explosion-gunshot",
					},
					target_effects = {
						{
							type = "create-entity",
							entity_name = "explosion-hit",
						},
						{ type = "damage", damage = { amount = 10, type = "electric" } },
						{ type = "damage", damage = { amount = 2, type = "physical" } },
					},
				},
			},
		},
		magazine_size = 50,
		subgroup = "y-ammo",
		order = "f1",
		stack_size = 200,
	},
	{
		type = "ammo",
		name = "y-ammo-krakon",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/ammo_wolfram.png",
		ammo_category = "bullet",
		ammo_type = {
			--category = "bullet",
			action = {
				type = "direct",
				action_delivery = {
					type = "instant",
					source_effects = {
						type = "create-explosion",
						entity_name = "explosion-gunshot",
					},
					target_effects = {
						{
							type = "create-entity",
							entity_name = "explosion-hit",
						},
						{ type = "damage", damage = { amount = 10, type = "impact" } },
						{ type = "damage", damage = { amount = 4, type = "physical" } },
					},
				},
			},
		},
		magazine_size = 50,
		subgroup = "y-ammo",
		order = "g1",
		stack_size = 200,
	},
	{
		type = "ammo",
		name = "y_ammo_plasma",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/ammo_plasma_64.png",
		ammo_category = "plasma",
		ammo_type = {
			--category = "plasma",
			target_type = "direction",
			source_effects = {
				type = "create-explosion",
				entity_name = "explosion-gunshot",
			},
			action = {
				type = "direct",
				action_delivery = {
					type = "projectile",
					--projectile = "shotgun-pellet",
					projectile = "green-plasma",
					starting_speed = 1,
					direction_deviation = 0.3,
					range_deviation = 0.3,
					--max_range = 28,

					source_effects = {
						type = "create-explosion",
						entity_name = "explosion-gunshot",
					},
					target_effects = {
						{
							type = "create-entity",
							entity_name = "explosion-hit",
						},
						{ type = "damage", damage = { amount = 90, type = "plasma" } },
						{ type = "damage", damage = { amount = 20, type = "fire" } },
						{ type = "damage", damage = { amount = 10, type = "poison" } },
					},
				},
			},
		},
		magazine_size = 100,
		subgroup = "y-ammo",
		order = "h1",
		stack_size = 200,
	},
	{
		type = "ammo",
		name = "y_ammo_flame",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/capsule_fire.png",
		ammo_category = "flamethrower",
		ammo_type = {
			--category = "flamethrower",
			target_type = "direction",
			action = {
				type = "direct",
				action_delivery = {
					type = "stream",
					stream = "handheld-flamethrower-fire-stream",
					max_length = 15,
					duration = 160,
				},
			},
		},
		magazine_size = 200,
		subgroup = "y-ammo",
		order = "h2",
		stack_size = 200,
	},
	{
		type = "ammo",
		name = "yi_cannon_shell",
		icon = "__Yuoki__/graphics/icons/c_shell_icon.png",
		icon_size = 64,
		ammo_category = "cannon-shell",
		ammo_type = {
			--category = "cannon-shell",
			target_type = "direction",
			action = {
				type = "direct",
				action_delivery = {
					type = "projectile",
					projectile = "yi_cannon_shell_projectile",
					starting_speed = 1,
					direction_deviation = 0.1,
					range_deviation = 0.1,
					max_range = 30,
					min_range = 5,
					source_effects = {
						type = "create-explosion",
						entity_name = "explosion-gunshot",
					},
				},
			},
		},
		subgroup = "y-ammo",
		order = "d[cannon-shell]-c[explosive]",
		stack_size = 200,
	},
	{
		type = "ammo",
		name = "yi_artillery_shell",
		icon = "__Yuoki__/graphics/icons/a_shell_icon.png",
		icon_size = 64,
		ammo_category = "artillery-shell",
		ammo_type = {
			--category = "artillery-shell",
			target_type = "position",
			action = {
				type = "direct",
				action_delivery = {
					type = "artillery",
					projectile = "yi_artillery_shell_projectile",
					starting_speed = 1,
					direction_deviation = 0,
					range_deviation = 0,
					source_effects = {
						type = "create-explosion",
						entity_name = "artillery-cannon-muzzle-flash",
					},
				},
			},
		},
		subgroup = "y-ammo",
		order = "d[explosive-cannon-shell]-d[artillery]",
		stack_size = 25,
	},

	{
		type = "projectile",
		name = "yi_cannon_shell_projectile",
		flags = { "not-on-map" },
		collision_box = { { -0.3, -1.1 }, { 0.3, 1.1 } },
		acceleration = 0,
		direction_only = true,
		piercing_damage = 300,
		action = {
			type = "direct",
			action_delivery = {
				type = "instant",
				target_effects = {
					{
						type = "damage",
						damage = { amount = 300, type = "impact" },
					},
					{
						type = "damage",
						damage = { amount = 150, type = "explosion" },
					},
					{
						type = "create-entity",
						entity_name = "explosion",
					},
				},
			},
		},
		final_action = {
			type = "direct",
			action_delivery = {
				type = "instant",
				target_effects = {
					{
						type = "create-entity",
						entity_name = "small-scorchmark",
						check_buildability = true,
					},
				},
			},
		},
		animation = {
			filename = "__base__/graphics/entity/bullet/bullet.png",
			frame_count = 1,
			width = 3,
			height = 50,
			priority = "high",
		},
	},
	{
		type = "artillery-projectile",
		name = "yi_artillery_shell_projectile",
		flags = { "not-on-map" },
		acceleration = 0,
		direction_only = true,
		reveal_map = true,
		map_color = { r = 1, g = 1, b = 0 },
		picture = {
			filename = "__base__/graphics/entity/artillery-projectile/shell.png",
			width = 64,
			height = 64,
			scale = 0.5,
		},
		shadow = {
			filename = "__base__/graphics/entity/artillery-projectile/shell-shadow.png",
			width = 64,
			height = 64,
			scale = 0.5,
		},
		chart_picture = {
			filename = "__base__/graphics/entity/artillery-projectile/artillery-shoot-map-visualization.png",
			flags = { "icon" },
			frame_count = 1,
			width = 64,
			height = 64,
			priority = "high",
			scale = 0.25,
		},
		action = {
			type = "direct",
			action_delivery = {
				type = "instant",
				target_effects = {
					{
						type = "nested-result",
						action = {
							type = "area",
							radius = 4.0,
							action_delivery = {
								type = "instant",
								target_effects = {
									{
										type = "damage",
										damage = { amount = 300, type = "explosion" },
									},
									{
										type = "damage",
										damage = { amount = 300, type = "impact" },
									},
								},
							},
						},
					},
					{
						type = "create-trivial-smoke",
						smoke_name = "artillery-smoke",
						initial_height = 0,
						speed_from_center = 0.05,
						speed_from_center_deviation = 0.005,
						offset_deviation = { { -4, -4 }, { 4, 4 } },
						max_radius = 3.5,
						repeat_count = 4 * 4 * 15,
					},
					{
						type = "create-entity",
						entity_name = "big-artillery-explosion",
					},
					{
						type = "show-explosion-on-chart",
						scale = 8 / 32,
					},
				},
			},
		},
		final_action = {
			type = "direct",
			action_delivery = {
				type = "instant",
				target_effects = {
					{
						type = "create-entity",
						entity_name = "small-scorchmark",
						check_buildability = true,
					},
				},
			},
		},
		animation = {
			filename = "__base__/graphics/entity/bullet/bullet.png",
			frame_count = 1,
			width = 3,
			height = 50,
			priority = "high",
		},
		height_from_ground = 280 / 64,
	},
})
