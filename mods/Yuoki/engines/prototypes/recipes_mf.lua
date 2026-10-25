data:extend({

	-- 2020 mfheatmotor 3.2 MW
	{
		type = "recipe",
		name = "ye_mf_mfheatmotor_m",
		category = "yrcat_mfheatmotor_m",
		enabled = true,
		energy_required = 1.00,
		ingredients = {
			--{ type = "fluid", name = "water" , amount = 500.0, minimum_temperature = 15},
		},
		results = {
			{ type = "fluid", name = "y-mechanical-force", amount = 8.0, temperature = 150 },
		},
		icon_size = 64,
		icon = "__Yuoki__/engines/graphics/mf-1.png",
		order = "0",
		group = "yi_engines",
		subgroup = "yie-fluids",
	},

	-- water->MF heat-transmission
	{
		type = "recipe",
		name = "ye_water2mf",
		category = "yrcat_transform",
		enabled = true,
		energy_required = 1.00,
		ingredients = {
			{ type = "fluid", name = "water", amount = 500.0, minimum_temperature = 15 },
		},
		results = {
			{ type = "fluid", name = "y-mechanical-force", amount = 5.0, temperature = 90 },
		},
		icon_size = 64,
		icon = "__Yuoki__/engines/graphics/steam.png",
		order = "0",
		group = "yi_engines",
		subgroup = "yie-fluids",
	},

	-- make steam - needs lua-code
	{
		type = "recipe",
		name = "ye_makesteam",
		category = "yrcat-heater", -- overheater for steam
		enabled = true,
		energy_required = 1.00,
		ingredients = {
			{ type = "fluid", name = "water", amount = 200.0, minimum_temperature = 15 },
		},
		results = {
			{ type = "fluid", name = "steam", amount = 565.0, temperature = 500 },
		},
		icon_size = 64,
		icon = "__Yuoki__/engines/graphics/steam.png",
		order = "0",
		group = "yi_engines",
		subgroup = "yie-fluids",
	},

	-- gearbox transmission without lubricant
	{
		type = "recipe",
		name = "y-mf2b",
		category = "yrcat-mf2", -- gearbox
		enabled = true,
		energy_required = 0.50,
		ingredients = {
			{ type = "fluid", name = "y-mechanical-force", amount = 1.6, minimum_temperature = 100 },
			{ type = "fluid", name = "water", amount = 50 },
		},
		results = {
			{ type = "fluid", name = "y-mechanical-force", amount = 1.4, temperature = 215 },
		},
		icon_size = 32,
		icon = "__Yuoki__/engines/graphics/gears_br.png",
		order = "0",
		group = "yi_engines",
		subgroup = "yie-fluids",
	},

	-- steam to mechanical power
	{
		type = "recipe",
		name = "ye_steam2mf",
		category = "yrcat_turbine", -- steam to mechanical power
		enabled = true,
		energy_required = 1.00,
		ingredients = {
			{ type = "fluid", name = "steam", amount = 560, minimum_temperature = 500 },
		},
		results = {
			{ type = "fluid", name = "y-mechanical-force", amount = 25.0, temperature = 400 },
			{ type = "fluid", name = "water", amount = 180, temperature = 75 },
		},
		icon_size = 64,
		icon = "__Yuoki__/engines/graphics/mf-1.png",
		order = "0",
		group = "yi_engines",
		subgroup = "yie-fluids",
	},

	-- steam to mechanical power
	{
		type = "recipe",
		name = "ye_steam3mf",
		category = "yrcat_turbine", -- steam to mechanical power
		enabled = true,
		energy_required = 1.0,
		ingredients = {
			{ type = "fluid", name = "steam", amount = 800, minimum_temperature = 950 },
		},
		results = {
			{ type = "fluid", name = "y-mechanical-force", amount = 75.0, temperature = 400 },
			{ type = "fluid", name = "steam", amount = 75, temperature = 265 },
		},
		icon_size = 64,
		icon = "__Yuoki__/engines/graphics/mf-3.png",
		order = "0",
		group = "yi_engines",
		subgroup = "yie-fluids",
	},

	-- quantrium-reactor power-generation recipe 1
	{
		type = "recipe",
		name = "y-mf1-q1",
		category = "yrcat-mf1q", -- mechanical force quantrinum-reactor
		enabled = true,
		energy_required = 2.00,
		ingredients = {
			{ type = "item", name = "y-infused-uca2", amount = 1.0 },
		},
		results = {
			{ type = "fluid", name = "y-mechanical-force", amount = 60.0, temperature = 150 },
		},
		icon_size = 64,
		icon = "__Yuoki__/engines/graphics/gear_xtra.png",
		order = "0",
		group = "yi_engines",
		subgroup = "yie-fluids",
	},

	-- quantrium-reactor power-generation recipe 2
	{
		type = "recipe",
		name = "y-mf1-q2",
		category = "yrcat-mf1q", -- mechanical force quantrinum-reactor
		enabled = true,
		energy_required = 2.00,
		ingredients = {
			{ type = "item", name = "y-quantrinum", amount = 1.0 },
		},
		results = {
			{ type = "fluid", name = "y-mechanical-force", amount = 100.0, temperature = 150 },
		},
		icon_size = 64,
		icon = "__Yuoki__/engines/graphics/gear_xtra.png",
		order = "0",
		group = "yi_engines",
		subgroup = "yie-fluids",
	},

	-- quantrium-reactor power-generation recipe 3
	{
		type = "recipe",
		name = "y-mf1-q3",
		category = "yrcat-mf1q", -- mechanical force quantrinum-reactor
		enabled = true,
		energy_required = 2.00,
		ingredients = {
			{ type = "item", name = "y-quantrinum-charge", amount = 1.0 },
		},
		results = {
			{ type = "fluid", name = "y-mechanical-force", amount = 300.0, temperature = 400 },
		},
		icon_size = 64,
		icon = "__Yuoki__/engines/graphics/gear_xtra.png",
		order = "0",
		group = "yi_engines",
		subgroup = "yie-fluids",
	},

	-- gearbox transmission with lubricant
	{
		type = "recipe",
		name = "y-mf2a",
		category = "yrcat-mf2", -- gearbox
		enabled = true,
		energy_required = 0.25,
		ingredients = {
			{ type = "fluid", name = "y-mechanical-force", amount = 2.6, minimum_temperature = 100 },
			{ type = "fluid", name = "lubricant", amount = 0.1 },
		},
		results = {
			{ type = "fluid", name = "y-mechanical-force", amount = 2.5, temperature = 250 },
		},
		icon_size = 32,
		icon = "__Yuoki__/engines/graphics/gears_br.png",
		order = "0",
		group = "yi_engines",
		subgroup = "yie-fluids",
	},

	--[[
	-- HP gearbox transmission without lubricant
	{
	  type = "recipe",
	  name = "y_mfhp_gearbox1",
	  category = "yrcat-mf2b", -- gearbox
	  enabled = true,
	  energy_required = 1.5,
	  ingredients = {
		{ type = "fluid", name = "y-mechanical-force" , amount = 24, minimum_temperature = 200 },
		{ type = "fluid", name = "water" , amount = 50, },
	  },
	  results = {
		{ type = "fluid", name = "y-mechanical-force", amount = 18, temperature = 340, },
	  },
	  icon_size = 32, icon =  "__Yuoki__/engines/graphics/gears_br.png",
	  order = "0", group = "yi_engines", subgroup = "yie-fluids",
	},


	-- HP gearbox transmission with lubricant
	{
	  type = "recipe",
	  name = "y_mfhp_gearbox2",
	  category = "yrcat-mf2b", -- gearbox
	  enabled = true,
	  energy_required = 1,
	  ingredients = {
		{ type = "fluid", name = "y-mechanical-force" , amount = 30, minimum_temperature = 200 },
		{ type = "fluid", name = "lubricant" , amount = 3, },
	  },
	  results = {
		{ type = "fluid", name = "y-mechanical-force", amount = 27, temperature = 400, },
	  },
	  icon_size = 32, icon =  "__Yuoki__/engines/graphics/gears_br.png",
	  order = "0", group = "yi_engines", subgroup = "yie-fluids",
	},
	]]

	-- without lubricant, still water for cooling - sfe
	{
		type = "recipe",
		name = "y-mf1a1",
		category = "yrcat-mf1a", -- mechanical force primary - sfe
		enabled = true,
		energy_required = 1.00,
		ingredients = {
			{ type = "fluid", name = "water", amount = 20.0 },
		},
		results = {
			{ type = "fluid", name = "y-mechanical-force", amount = 5, temperature = 150 },
		},
		icon_size = 64,
		icon = "__Yuoki__/engines/graphics/gear_basic.png",
		order = "0",
		group = "yi_engines",
		subgroup = "yie-fluids",
	},

	{
		type = "recipe",
		name = "y-mf1a",
		category = "yrcat-mf1a", -- mechanical force primary - sfe
		enabled = true,
		energy_required = 1.00,
		ingredients = {
			{ type = "fluid", name = "water", amount = 100 },
			{ type = "fluid", name = "lubricant", amount = 2 },
		},
		results = {
			{ type = "fluid", name = "y-mechanical-force", amount = 6, temperature = 150 },
		},
		icon_size = 64,
		icon = "__Yuoki__/engines/graphics/gear_wet.png",
		order = "0",
		group = "yi_engines",
		subgroup = "yie-fluids",
	},

	-- SFE trocken
	{
		type = "recipe",
		name = "y-mf1f",
		category = "yrcat-mf1a", -- mechanical force primary - sfe
		enabled = true,
		energy_required = 1.00,
		ingredients = {},
		results = {
			{ type = "fluid", name = "y-mechanical-force", amount = 4.5, temperature = 150 },
		},
		icon_size = 64,
		icon = "__Yuoki__/engines/graphics/gear_basic.png",
		order = "0",
		group = "yi_engines",
		subgroup = "yie-fluids",
	},

	-- FFE - Hydromechanical Power
	{
		type = "recipe",
		name = "y-mf2a",
		category = "yrcat-mf1b", -- mechanical force primary - ffe
		enabled = true,
		energy_required = 1.00,
		ingredients = {
			{ type = "fluid", name = "heavy-oil", amount = 30 },
			{ type = "fluid", name = "lubricant", amount = 2 },
			{ type = "fluid", name = "water", amount = 150 },
		},
		results = {
			{ type = "fluid", name = "y-mechanical-force", amount = 6, temperature = 150 },
		},
		icon_size = 64,
		icon = "__Yuoki__/engines/graphics/gear_wet.png",
		order = "1",
		group = "yi_engines",
		subgroup = "yie-fluids",
	},

	--
	{
		type = "recipe",
		name = "y-mf2b",
		category = "yrcat-mf1b", -- mechanical force primary - ffe
		enabled = true,
		energy_required = 1.00,
		ingredients = {
			{ type = "fluid", name = "light-oil", amount = 20 },
			{ type = "fluid", name = "lubricant", amount = 2 },
			{ type = "fluid", name = "water", amount = 150 },
		},
		results = {
			{ type = "fluid", name = "y-mechanical-force", amount = 7, temperature = 150 },
		},
		icon_size = 64,
		icon = "__Yuoki__/engines/graphics/gear_wet.png",
		order = "2",
		group = "yi_engines",
		subgroup = "yie-fluids",
	},

	-- FFE - burn corn-oil - self lubricant
	{
		type = "recipe",
		name = "y-mf2e",
		category = "yrcat-mf1b", -- mechanical force primary - ffe
		enabled = true,
		energy_required = 1.00,
		ingredients = {
			{ type = "fluid", name = "ye_cornoil", amount = 30 },
			{ type = "fluid", name = "water", amount = 150 },
		},
		results = {
			{ type = "fluid", name = "y-mechanical-force", amount = 4, temperature = 150 },
		},
		icon_size = 64,
		icon = "__Yuoki__/engines/graphics/gear_wet.png",
		order = "3",
		group = "yi_engines",
		subgroup = "yie-fluids",
	},

	-- GM - burn petroleum - need lubricant
	-- ab 4.5.2022 gasmotor
	{
		type = "recipe",
		name = "y-mf2c",
		category = "yrcat-mf1gm", -- mechanical force primary
		enabled = true,
		energy_required = 1.00,
		ingredients = {
			{ type = "fluid", name = "petroleum-gas", amount = 30 },
			{ type = "fluid", name = "lubricant", amount = 3 },
			{ type = "fluid", name = "water", amount = 100 },
		},
		results = {
			{ type = "fluid", name = "y-mechanical-force", amount = 8, temperature = 150 },
		},
		icon_size = 64,
		icon = "__Yuoki__/engines/graphics/gears2-lub.png",
		order = "4",
		group = "yi_engines",
		subgroup = "yie-fluids",
	},

	-- GM - burn hydrogen - need lubricant
	{
		type = "recipe",
		name = "y-mf2d",
		category = "yrcat-mf1gm", -- mechanical force primary
		enabled = true,
		energy_required = 1.00,
		ingredients = {
			{ type = "fluid", name = "y_hydrogen", amount = 25 },
			{ type = "fluid", name = "lubricant", amount = 4 },
		},
		results = {
			{ type = "fluid", name = "y-mechanical-force", amount = 6, temperature = 150 },
		},
		icon_size = 64,
		icon = "__Yuoki__/engines/graphics/gears2-lub.png",
		order = "5",
		group = "yi_engines",
		subgroup = "yie-fluids",
	},

	-- Medium Water Generator - Special Recipe
	--ID:330
	{
		type = "recipe",
		name = "y_mpump_mf",
		category = "yrcat_pump_2", -- Medium Pump
		enabled = true,
		energy_required = 1.00,
		ingredients = {
			{ type = "fluid", name = "water", amount = 1800.0 },
		},
		results = {
			{ type = "fluid", name = "y-mechanical-force", amount = 2.0, temperature = 150 },
		},
		main_product = "y-mechanical-force",
		icon = "__Yuoki__/engines/graphics/mf-1.png",
		icon_size = 64,
		order = "0",
		group = "yi_engines",
		subgroup = "yie-fluids",
	},
})
