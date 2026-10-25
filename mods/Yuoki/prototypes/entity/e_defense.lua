y_weapon_ztt = {
	filename = "__Yuoki__/graphics/entity/defense/zzt-place.png",
	priority = "medium",
	width = 160,
	height = 160,
	shift = { 0.31, -0.75 },
	--filename = "__Yuoki__/graphics/entity/y_weapon-ztt-c.png",
	--priority = "medium", width = 112, height = 112, shift = {0.35, 0.2},
	direction_count = 8,
	frame_count = 1,
	line_length = 1,
	axially_symmetrical = false,
}
y_laser2x2 = {
	filename = "__Yuoki__/graphics/entity/defense/laser22f12-h-place.png",
	priority = "medium",
	width = 128,
	height = 128,
	direction_count = 8,
	frame_count = 1,
	axially_symmetrical = false,
	shift = { 0.1875, -0.625 },
}

data:extend({
	{
		type = "electric-turret",
		name = "y-weapon-ztt",
		icon_size = 64,
		icon = "__Yuoki__/graphics/entity/defense/zzt-icon.png",
		flags = { "placeable-player", "placeable-enemy", "player-creation" },
		minable = { mining_time = 0.5, result = "y-weapon-ztt" },
		max_health = 6000,
		corpse = "small-remnants",
		collision_box = { { -1.4, -1.4 }, { 1.4, 1.4 } },
		selection_box = { { -1.4, -1.4 }, { 1.4, 1.4 } },
		rotation_speed = 0.01,
		preparing_speed = 0.05,
		dying_explosion = "medium-explosion",
		folding_speed = 0.05,
		resistances = {
			{ type = "physical", decrease = 5, percent = 60 },
			{ type = "explosion", decrease = 5, percent = 60 },
			{ type = "fire", percent = 50 },
		},
		energy_source = {
			type = "electric",
			buffer_capacity = "50MJ",
			input_flow_limit = "12.5MW",
			drain = "500kW",
			usage_priority = "primary-input",
		},
		folded_animation = (function()
			local res = util.table.deepcopy(y_weapon_ztt)
			res.frame_count = 1
			res.line_length = 1
			return res
		end)(),
		preparing_animation = y_weapon_ztt,

		--[[
			preparing_animation =
			{
				filename = "__Yuoki__/graphics/entity/wall-forcefield-ae.png",
				priority = "medium", width = 48, height = 48, shift = {0.075, 0},
				direction_count = 1,
				frame_count = 1,
				line_length = 1,
				axially_symmetrical = false,

			},
			]]
		prepared_animation = {
			filename = "__Yuoki__/graphics/entity/defense/zzt-sheet.png",
			priority = "medium",
			width = 160,
			height = 160,
			shift = { 0.31, -0.75 },
			direction_count = 64,
			frame_count = 1,
			line_length = 8,
			axially_symmetrical = false,
		},
		folding_animation = (function()
			local res = util.table.deepcopy(y_weapon_ztt)
			res.run_mode = "backward"
			return res
		end)(),

		graphics_set = blank_sprite,

		--[[
			base_picture =
			{
				filename = "__Yuoki__/graphics/entity/wall-forcefield-ae.png",
				priority = "high", width = 48, height = 48, shift = {0.075, 0}
			},
			]]
		attack_parameters = {
			type = "projectile",
			damage_modifier = 4,
			ammo_category = "laser", -- "electric",
			cooldown = 5,
			damage = 3,
			projectile_center = { 0, 0 },
			projectile_creation_distance = 0.75,
			range = 38,
			sound = { { filename = "__base__/sound/fight/laser-1.ogg", volume = 0.1 } },
			ammo_type = {
				type = "projectile",
				category = "laser",
				energy_consumption = "500kJ",
				action = {
					{
						type = "direct",
						action_delivery = {
							{
								type = "projectile",
								projectile = "cyan-laser",
								starting_speed = 0.9,
							},
						},
					},
				},
			},
		},
		order = "a",
		call_for_help_radius = 40,
	},
	--[=[ y-laser-def-s4 disabled because the matching recipe is commented out
	{
		type = "electric-turret",
		name = "y-laser-def-s4",
		icon_size = 64,
		icon = "__Yuoki__/graphics/entity/defense/laser2x2_r16n-icon.png",
		flags = { "placeable-player", "placeable-enemy", "player-creation" },
		minable = { mining_time = 0.5, result = "y-laser-def-s4" },
		max_health = 2800,
		corpse = "small-remnants",
		collision_box = { { -0.9, -0.9 }, { 0.9, 0.9 } },
		selection_box = { { -1.0, -1.0 }, { 1.0, 1.0 } },
		rotation_speed = 0.01,
		preparing_speed = 0.05,
		dying_explosion = "medium-explosion",
		folding_speed = 0.05,
		resistances = {
			{ type = "physical", decrease = 5, percent = 60 },
			{ type = "explosion", decrease = 5, percent = 60 },
			{ type = "fire", percent = 50 },
		},
		energy_source = {
			type = "electric",
			buffer_capacity = "20MJ",
			input_flow_limit = "5MW",
			drain = "200kW",
			usage_priority = "primary-input",
		},
		folded_animation = (function()
			local res = util.table.deepcopy(y_laser2x2)
			res.frame_count = 1
			res.line_length = 1
			return res
		end)(),
		preparing_animation = y_laser2x2,
		prepared_animation = {
			filename = "__Yuoki__/graphics/entity/defense/laser22f12-h-sheet.png",
			priority = "medium",
			width = 128,
			height = 128,
			shift = { 0.1875, -0.625 },
			direction_count = 64,
			frame_count = 1,
			line_length = 8,
			axially_symmetrical = false,
		},
		folding_animation = (function()
			local res = util.table.deepcopy(y_laser2x2)
			res.run_mode = "backward"
			return res
		end)(),

		graphics_set = blank_sprite,

		attack_parameters = {
			type = "beam",
			cooldown = 12,
			range = 26,
			source_direction_count = 64,
			source_offset = { 0, -3.423489 / 4 },
			damage_modifier = 3,
			ammo_category = "laser",
			ammo_type = {
				--category = "laser",
				energy_consumption = "800kJ",
				action = {
					type = "direct",
					action_delivery = {
						type = "beam",
						beam = "laser-beam",
						max_length = 26,
						duration = 12,
						source_offset = { 0, -1.31439 },
					},
				},
			},
		},

		--[[
			attack_parameters = {
				type = "projectile",
				damage_modifier = 3,
				ammo_category = "electric",
				cooldown = 12,
				damage = 6,
				projectile_center = {0, 0},
				projectile_creation_distance = 0.2,
				range = 26,
				sound = {{filename = "__base__/sound/fight/laser-1.ogg", volume = 0.1}},
				ammo_type = {
					type = "projectile",
					category = "laser-turret",
					energy_consumption = "325KJ",
					action = {
						{
							type = "direct",
							action_delivery = {
								{
									type = "projectile",
									projectile = "white-laser",
									starting_speed = 0.35
								}
							}
						}
					}
				}
			},
			]]
		order = "a",
		call_for_help_radius = 40,
	},
	]=]
})
