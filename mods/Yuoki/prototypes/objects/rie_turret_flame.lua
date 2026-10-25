turret_flame = {
	layers = {
		{
			filename = "__Yuoki__/graphics/entity/defense/turm_flamer_place.png",
			priority = "medium",
			width = 256,
			height = 256,
			direction_count = 8,
			frame_count = 1,
			axially_symmetrical = false,
			scale = 0.5,
			shift = { 0.0, -0.325 },
		},
	},
}

data:extend({

	{
		type = "recipe",
		name = "y_turret_flame",
		icon_size = 64,
		icon = "__Yuoki__/graphics/entity/defense/turm_flamer_icon.png",
		enabled = true,
		ingredients = {
			{ type = "item", name = "y_structure_element", amount = 4 },
			{ type = "item", name = "y_structure_vessel", amount = 4 },
			{ type = "item", name = "y-basic-t1-mf", amount = 2 },
			{ type = "item", name = "pipe", amount = 4 },
			{ type = "item", name = "y_ammo_flame", amount = 1 },
		},
		results = {
			{ type = "item", name = "y_turret_flame", amount = 1 },
			{ type = "item", name = "y_rwtechsign", amount = 3 },
		},
		main_product = "y_turret_flame",
		subgroup = "y-defense",
		order = "f1",
	},

	{
		type = "item",
		name = "y_turret_flame",
		icon_size = 64,
		icon = "__Yuoki__/graphics/entity/defense/turm_flamer_icon.png",
		group = "yuoki",
		subgroup = "y-defense",
		order = "f1",
		place_result = "y_turret_flame",
		stack_size = 10,
	},

	{
		type = "ammo-turret",
		name = "y_turret_flame",
		icon_size = 64,
		icon = "__Yuoki__/graphics/entity/defense/turm_flamer_icon.png",
		flags = { "placeable-player", "player-creation" },
		minable = { mining_time = 0.5, result = "y_turret_flame" },
		max_health = 5000,
		resistances = {
			{ type = "physical", decrease = 4, percent = 75 },
			{ type = "fire", percent = 100 },
		},
		corpse = "small-remnants",
		collision_box = { { -0.7, -0.7 }, { 0.7, 0.7 } },
		selection_box = { { -1.0, -1.0 }, { 1.0, 1.0 } },
		rotation_speed = 0.020, -- 0.015 orginal
		preparing_speed = 0.08,
		folding_speed = 0.08,
		dying_explosion = "medium-explosion",
		inventory_size = 2,
		automated_ammo_count = 20,
		circuit_wire_max_distance = 7.5,
		folded_animation = (function()
			local res = util.table.deepcopy(turret_flame)
			res.frame_count = 1
			res.line_length = 1
			return res
		end)(),
		preparing_animation = turret_flame,
		prepared_animation = {
			layers = {
				{
					filename = "__Yuoki__/graphics/entity/defense/turm_flame_sheet.png",
					priority = "medium",
					width = 256,
					height = 256,
					direction_count = 64,
					frame_count = 1,
					line_length = 8,
					axially_symmetrical = false,
					scale = 0.5,
					shift = { 0.0, -0.325 },
				},
				--[[
					{
						filename = "__Yuoki__/graphics/entity/defense/turm_flamer_layer.png",
						line_length = 1,
						width = 96,
						height = 96,
						frame_count = 1,
						axially_symmetrical = false,
						apply_runtime_tint = true,
						direction_count = 1,
						shift = { 0.5, -0.375 },
					},
					]]
			},
		},
		folding_animation = (function()
			local res = util.table.deepcopy(turret_flame)
			res.run_mode = "backward"
			return res
		end)(),
		graphics_set = blank_sprite,

		attack_parameters = {
			type = "projectile",
			ammo_category = "flamethrower",
			cooldown = 2,
			projectile_creation_distance = 0.6,
			range = 30,
			cyclic_sound = {
				begin_sound = {
					{
						filename = "__base__/sound/fight/flamethrower-start.ogg",
						volume = 0.7,
					},
				},
				middle_sound = {
					{
						filename = "__base__/sound/fight/flamethrower-mid.ogg",
						volume = 0.7,
					},
				},
				end_sound = {
					{
						filename = "__base__/sound/fight/flamethrower-end.ogg",
						volume = 0.7,
					},
				},
			},
		},
		call_for_help_radius = 40,
	},
})
