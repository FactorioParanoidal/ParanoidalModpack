local function make_plasma_sounds(volume)
	return {
		{
			filename = "__Yuoki__/sounds/plasma-1.ogg",
			volume = 0.7,
		},
		{
			filename = "__Yuoki__/sounds/plasma-2.ogg",
			volume = 0.85,
		},
		--[[
	{
		filename = "__base__/sound/fight/laser-3.ogg",
		volume = 0.5
	}
	]]
	}
end

turret_plasma = {
	filename = "__Yuoki__/graphics/entity/defense/turm_plasma_place.png",
	priority = "medium",
	width = 256,
	height = 256,
	direction_count = 8,
	frame_count = 1,
	axially_symmetrical = false,
	scale = 0.5,
	shift = { 0.0, -0.0 },
}

data:extend({

	{
		type = "damage-type",
		name = "plasma",
	},

	{
		type = "recipe",
		name = "y_turret_plasma",
		enabled = true,
		ingredients = {
			{ type = "item", name = "y_structure_element", amount = 8 },
			{ type = "item", name = "y_structure_vessel", amount = 2 },
			{ type = "item", name = "y-basic-t2-mf", amount = 1 },
			{ type = "item", name = "y-conductive-coil-1", amount = 4 },
			{ type = "item", name = "y-raw-fuelnium", amount = 1 },
			{ type = "item", name = "y_rwtechsign", amount = 5 },
		},
		results = { { type = "item", name = "y_turret_plasma", amount = 1 } },
		--result = "y_turret_plasma",
		order = "p1",
	},

	{
		type = "item",
		name = "y_turret_plasma",
		icon_size = 64,
		icon = "__Yuoki__/graphics/entity/defense/turm_plasma_icon.png",
		group = "yuoki",
		--subgroup = "y-storage",
		subgroup = "y-defense",
		order = "p1",
		place_result = "y_turret_plasma",
		stack_size = 10,
	},

	{
		type = "ammo-turret",
		name = "y_turret_plasma",
		icon_size = 64,
		icon = "__Yuoki__/graphics/entity/defense/turm_plasma_icon.png",
		flags = { "placeable-player", "player-creation" },
		minable = { mining_time = 0.5, result = "y_turret_plasma" },
		max_health = 4000,
		resistances = {
			{ type = "physical", decrease = 5, percent = 75 },
			{ type = "fire", percent = 100 },
		},
		corpse = "small-remnants",
		collision_box = { { -0.7, -0.7 }, { 0.7, 0.7 } },
		selection_box = { { -1.0, -1.0 }, { 1.0, 1.0 } },
		rotation_speed = 0.020, -- 0.015 orginal
		preparing_speed = 0.08,
		folding_speed = 0.08,
		dying_explosion = "medium-explosion",
		inventory_size = 1,
		automated_ammo_count = 20,

		circuit_wire_max_distance = 7.5,

		folded_animation = (function()
			local res = util.table.deepcopy(turret_plasma)
			res.frame_count = 1
			res.line_length = 1
			return res
		end)(),
		preparing_animation = turret_plasma,

		prepared_animation = {
			filename = "__Yuoki__/graphics/entity/defense/turm_plasma_sheet.png",
			priority = "medium",
			width = 256,
			height = 256,
			direction_count = 64,
			frame_count = 1,
			line_length = 8,
			axially_symmetrical = false,
			scale = 0.5,
			shift = { 0.0, -0.0 },
		},

		folding_animation = (function()
			local res = util.table.deepcopy(turret_plasma)
			res.run_mode = "backward"
			return res
		end)(),

		graphics_set = blank_sprite,

		attack_parameters = {
			range = 35,
			type = "projectile",
			ammo_category = "plasma",
			cooldown = 8,
			projectile_creation_distance = 1.39375,
			projectile_center = { 0.0625, -0.0875 }, -- same as gun_turret_attack shift
			damage_modifier = 1,
			--[[
			action =
			{
				{
					type = "direct",
					action_delivery =
					{
						{
							type = "projectile",
							projectile = "green-plasma",
							starting_speed = 0.35,
						},
					}
				}
			},
			]]
			shell_particle = {
				name = "shell-particle",
				direction_deviation = 0.1,
				speed = 0.1,
				speed_deviation = 0.03,
				center = { 0, 0 },
				creation_distance = -1.925,
				starting_frame_speed = 0.2,
				starting_frame_speed_deviation = 0.1,
			},
			sound = make_plasma_sounds(),
		},
		call_for_help_radius = 40,
	},
})
