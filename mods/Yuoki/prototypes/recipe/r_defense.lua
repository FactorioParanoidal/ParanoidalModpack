data:extend({

	-- walls
	{
		type = "recipe",
		name = "y-mud-wall",
		energy_required = 2.0,
		enabled = true,
		ingredients = {
			{ type = "item", name = "y_slag_brick", amount = 8 },
			{ type = "item", name = "steel-plate", amount = 1 },
		},
		results = {
			{ type = "item", name = "y-mud-wall", amount = 1 },
		},
		main_product = "y-mud-wall",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/m_wall_icon.png",
		subgroup = "y_defense_walls",
		order = "w-a",
	},

	{
		type = "recipe",
		name = "y-rare-wall-basic",
		energy_required = 2.0,
		enabled = true,
		ingredients = {
			{ type = "item", name = "y_structure_element", amount = 5 },
			{ type = "item", name = "y-mud-wall", amount = 1 },
		},
		results = {
			{ type = "item", name = "y-rare-wall-basic", amount = 1 },
		},
		main_product = "y-rare-wall-basic",
		subgroup = "y_defense_walls",
		order = "w-b",
	},

	{
		type = "recipe",
		name = "y-rare-wall-adv",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/rare2-wall-icon2.png",
		energy_required = 2.0,
		enabled = true,
		ingredients = {
			{ type = "item", name = "y-orange-stuff", amount = 8 },
			{ type = "item", name = "y_structure_vessel", amount = 1 },
			{ type = "item", name = "y-rare-wall-basic", amount = 1 },
		},
		results = {
			{ type = "item", name = "y-rare-wall-adv", amount = 1 },
			{ type = "item", name = "y_rwtechsign", amount = 1 },
		},
		main_product = "y-rare-wall-adv",
		subgroup = "y_defense_walls",
		order = "w-c",
	},

	{
		type = "recipe",
		name = "y-wall-forcefield",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/wall-forcefield-icon.png",
		energy_required = 3.0,
		enabled = true,
		ingredients = {
			{ type = "item", name = "y-rare-wall-basic", amount = 1 },
			{ type = "item", name = "y-conductive-coil-1", amount = 3 },
			{ type = "item", name = "y-conductive-wire-1", amount = 1 },
		},
		results = {
			{ type = "item", name = "y-wall-forcefield", amount = 1 },
			{ type = "item", name = "y_rwtechsign", amount = 1 },
		},
		main_product = "y-wall-forcefield",
		subgroup = "y_defense_walls",
		order = "w-d",
	},

	{
		type = "recipe",
		name = "y_wall22_hardic",
		icon_size = 64,
		icon = "__Yuoki__/graphics/entity/walls/wall_hardic_icon.png",
		energy_required = 2.0,
		enabled = true,
		ingredients = {
			{ type = "item", name = "y_structure_vessel", amount = 4 },
			{ type = "item", name = "concrete", amount = 4 },
			{ type = "item", name = "y-richdust", amount = 4 },
		},
		results = {
			{ type = "item", name = "y_wall22_hardic", amount = 1 },
			{ type = "item", name = "y_rwtechsign", amount = 1 },
		},
		main_product = "y_wall22_hardic",
		subgroup = "y_defense_walls",
		order = "w-f",
	},

	--[[
	{
		type = "recipe",
		name = "y-laser-def-s4",
		enabled = true,
		energy_required = 4,
		ingredients = {
			{ type = "item", name = "y_turret_laser22f12", amount = 1 },
			{ type = "item", name = "y-conductive-coil-1", amount = 3 },
			{ type = "item", name = "y_wall22_hardic", amount = 1 },
		},
		results = {
			{ type = "item", name = "y-laser-def-s4", amount = 1 },
		},
		main_product = "y-laser-def-s4",
		order = "t-c",
	},
	]]
	{
		type = "recipe",
		name = "y_turret_laser22f12",
		enabled = true,
		energy_required = 4,
		ingredients = {
			{ type = "item", name = "y-basic-t2-mf", amount = 1 },
			{ type = "item", name = "y_blocked_capa", amount = 2 },
			{ type = "item", name = "y-conductive-coil-1", amount = 3 },
			{ type = "item", name = "y_structure_electric", amount = 4 },
			{ type = "item", name = "y_rwtechsign", amount = 1 },
		},
		results = {
			{ type = "item", name = "y_turret_laser22f12", amount = 1 },
		},
		main_product = "y_turret_laser22f12",
		order = "t-c",
	},

	{
		type = "recipe",
		name = "y_turret_gun2f12",
		enabled = true,
		energy_required = 4,
		ingredients = {
			{ type = "item", name = "y-basic-t1-mf", amount = 1 },
			{ type = "item", name = "y_structure_element", amount = 12 },
			{ type = "item", name = "y-bluegear", amount = 3 },
			{ type = "item", name = "y_rwtechsign", amount = 1 },
		},
		results = {
			{ type = "item", name = "y_turret_gun2f12", amount = 1 },
		},
		main_product = "y_turret_gun2f12",
		order = "t-a",
	},

	{
		type = "recipe",
		name = "y_turret_gun1f12",
		enabled = true,
		energy_required = 4,
		ingredients = {
			{ type = "item", name = "y-basic-t1-mf", amount = 1 },
			{ type = "item", name = "y_structure_element", amount = 12 },
			{ type = "item", name = "steel-plate", amount = 4 },
			{ type = "item", name = "y_rwtechsign", amount = 1 },
		},
		results = {
			{ type = "item", name = "y_turret_gun1f12", amount = 1 },
		},
		main_product = "y_turret_gun1f12",
		order = "t-b",
	},

	{
		type = "recipe",
		name = "y-weapon-ztt",
		energy_required = 3.0,
		enabled = true,
		ingredients = {
			{ type = "item", name = "y-rare-wall-adv", amount = 8 },
			{ type = "item", name = "y-basic-t2-mf", amount = 2 },
			{ type = "item", name = "y-chip-2", amount = 2 },
			{ type = "item", name = "y-accumulator-b-t2", amount = 1 },
			{ type = "item", name = "y-infused-uca2", amount = 1 },
			{ type = "item", name = "y_rwtechsign", amount = 5 },
		},
		results = {
			{ type = "item", name = "y-weapon-ztt", amount = 1 },
		},
		main_product = "y-weapon-ztt",
		subgroup = "y-defense",
		order = "t-d",
	},
})
