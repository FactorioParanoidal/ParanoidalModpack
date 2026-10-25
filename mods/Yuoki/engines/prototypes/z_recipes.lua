--automatically generated file | fMT-Export (c)YT v0.04-216Mrz03
--export-date: 2020-Feb-06


data:extend({

	--ID:346
	{
		type = "recipe",
		name = "ye_mfheatmotor_m",
		category = "crafting", --
		enabled = true,
		energy_required = 3.00,
		ingredients = {
			{ type = "item", name = "ye_emotor_m", amount = 1.0 },
			{ type = "item", name = "y-iron-case", amount = 2.0 },
			{ type = "item", name = "y-heat-pipe", amount = 6.0 },
		},
		results = {
			{ type = "item", name = "ye_mfheatmotor_m", amount = 1.0 },
		},
		main_product = "ye_mfheatmotor_m",
		icon = "__Yuoki__/engines/graphics/entity/mf_heater_icon.png",
		icon_size = 64,
		order = "m3",
		group = "yi_engines",
		subgroup = "yie-engines",
	},

	--ID:343
	{
		type = "recipe",
		name = "ye_tfmw_turbine-s",
		category = "crafting", --
		enabled = true,
		energy_required = 5.00,
		ingredients = {
			{ type = "item", name = "ye_emotor_m", amount = 5.0 },
			{ type = "item", name = "ye_science_blue", amount = 10.0 },
			{ type = "item", name = "yie_hard_metals", amount = 50.0 },
			{ type = "item", name = "y_greensign", amount = 1000.0 },
		},
		results = {
			{ type = "item", name = "ye_tfmw_turbine-s", amount = 1.0 },
		},
		main_product = "ye_tfmw_turbine-s",
		icon = "__Yuoki__/engines/graphics/entity/turbine_70_icon.png",
		icon_size = 64,
		order = "2",
		group = "yi_engines",
		subgroup = "yie_machinery",
	},

	--ID:342
	{
		type = "recipe",
		name = "yie_pureiron",
		category = "smelting", -- all furnace stuff
		enabled = true,
		energy_required = 3.00,
		ingredients = {
			{ type = "item", name = "ye_organic_metall", amount = 2.0 },
		},
		results = {
			{ type = "item", name = "y-pure-iron", amount = 7.0 },
		},
		main_product = "y-pure-iron",
		icon = "__Yuoki__/graphics/icons/pure-iron-n.png",
		icon_size = 64,
		order = "C",
		group = "yie_harvest",
		subgroup = "yie-processed",
	},

	--ID:331
	{
		type = "recipe",
		name = "ye_motorm_mf",
		category = "yrcat_motor", -- medium motor
		enabled = true,
		energy_required = 2.00,
		ingredients = {},
		results = {
			{ type = "fluid", name = "y-mechanical-force", amount = 8.0 },
		},
		main_product = "y-mechanical-force",
		icon = "__Yuoki__/engines/graphics/gear_basic.png",
		icon_size = 64,
		order = "0",
		group = "yi_engines",
		subgroup = "yie-fluids",
	},

	--ID:330
	{
		type = "recipe",
		name = "y_mpump_mf",
		category = "yrcat_pump_2", -- Medium Pump
		enabled = true,
		energy_required = 1.00,
		ingredients = {
			{ type = "fluid", name = "water", amount = 1200.0 },
		},
		results = {
			{ type = "fluid", name = "y-mechanical-force", amount = 2.0 },
		},
		main_product = "y-mechanical-force",
		icon = "__Yuoki__/engines/graphics/mf-1.png",
		icon_size = 64,
		order = "0",
		group = "yi_engines",
		subgroup = "yie-fluids",
	},

	--ID:329
	{
		type = "recipe",
		name = "y_mpump_water",
		category = "yrcat_pump_2", -- Medium Pump
		enabled = true,
		energy_required = 1.00,
		ingredients = {
			{ type = "fluid", name = "y-mechanical-force", amount = 2.0 },
		},
		results = {
			{ type = "fluid", name = "water", amount = 900.0 },
		},
		main_product = "water",
		icon = "__Yuoki__/engines/graphics/water-clean2.png",
		icon_size = 64,
		order = "0",
		group = "yi_engines",
		subgroup = "yie-fluids",
	},

	--ID:328
	{
		type = "recipe",
		name = "ye_wpump_m",
		category = "crafting", --
		enabled = true,
		energy_required = 3.00,
		ingredients = {
			{ type = "item", name = "y-mftrans-shaft", amount = 4.0 },
			{ type = "item", name = "y-bluegear", amount = 3.0 },
			{ type = "item", name = "y-basic-t2-mf", amount = 2.0 },
			{ type = "item", name = "y-iron-case", amount = 4.0 },
		},
		results = {
			{ type = "item", name = "ye_wpump_m", amount = 1.0 },
		},
		main_product = "ye_wpump_m",
		icon = "__Yuoki__/engines/graphics/entity/pump3x3_icon.png",
		icon_size = 64,
		order = "t2",
		group = "yi_engines",
		subgroup = "yie_machinery",
	},

	--ID:327
	{
		type = "recipe",
		name = "ye_emotor_m",
		category = "crafting", --
		enabled = true,
		energy_required = 3.00,
		ingredients = {
			{ type = "item", name = "y-iron-case", amount = 4.0 },
			{ type = "item", name = "y-conductive-coil-1", amount = 14.0 },
			{ type = "item", name = "y-winding", amount = 24.0 },
			{ type = "item", name = "ye_science_blue", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "ye_emotor_m", amount = 1.0 },
		},
		main_product = "ye_emotor_m",
		icon = "__Yuoki__/engines/graphics/entity/e-motor-m_icon.png",
		icon_size = 64,
		order = "m2",
		group = "yi_engines",
		subgroup = "yie-engines",
	},

	--ID:325
	{
		type = "recipe",
		name = "ye_pool_slurry",
		category = "yrcat-fish", -- fishing things
		enabled = true,
		energy_required = 180.00,
		ingredients = {
			{ type = "fluid", name = "ye_blood", amount = 200.0 },
			{ type = "fluid", name = "water", amount = 800.0 },
			{ type = "item", name = "y_greensign", amount = 30.0 },
		},
		results = {
			{ type = "fluid", name = "ye_slurry", amount = 1100.0 },
		},
		main_product = "ye_slurry",
		icon = "__Yuoki__/engines/graphics/slurry.png",
		icon_size = 64,
		order = "x",
		group = "yie_harvest",
		subgroup = "yie_fish",
	},

	--ID:315
	{
		type = "recipe",
		name = "yie_import_sealing",
		category = "yuoki-stargate", -- stargate-trades
		enabled = true,
		energy_required = 5.00,
		ingredients = {
			{ type = "item", name = "ypfw_trader_sign", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "ye_sealing", amount = 4.0 },
		},
		main_product = "ye_sealing",
		icon = "__Yuoki__/engines/graphics/icons/sealing_import.png",
		icon_size = 32,
		order = "a10",
		group = "yi_engines",
		subgroup = "yie_engines_import_a",
	},

	--ID:311
	{
		type = "recipe",
		name = "yie_import_blech_blau",
		category = "yuoki-stargate", -- stargate-trades
		enabled = true,
		energy_required = 5.00,
		ingredients = {
			{ type = "item", name = "ypfw_trader_sign", amount = 10.0 },
		},
		results = {
			{ type = "item", name = "ye_buechsenblech", amount = 1.0 },
		},
		main_product = "ye_buechsenblech",
		icon = "__Yuoki__/engines/graphics/icons/blech_blue_import.png",
		icon_size = 32,
		order = "a1",
		group = "yi_engines",
		subgroup = "yie_engines_import_a",
	},

	--ID:309
	{
		type = "recipe",
		name = "ye_tranport_tube_orange_underground",
		category = "crafting", --
		enabled = true, -- disabled due to graphics issues
		energy_required = 5.00,
		ingredients = {
			{ type = "item", name = "ye_tranport_tube_orange", amount = 11.0 },
			{ type = "item", name = "y-iron-case", amount = 2.0 },
		},
		results = {
			{ type = "item", name = "ye_tranport_tube_orange_underground", amount = 2.0 },
		},
		main_product = "ye_tranport_tube_orange_underground",
		icon = "__Yuoki__/engines/graphics/icons/ubo_icon.png",
		icon_size = 32,
		order = "b3",
		group = "yi_engines",
		subgroup = "yie_tubes",
	},
	--ID:307
	{
		type = "recipe",
		name = "ye_tranport_tube_orange",
		category = "crafting", --
		enabled = true, -- disabled due to graphics issues
		energy_required = 4.00,
		ingredients = {
			{ type = "item", name = "pipe", amount = 2 },
			{ type = "item", name = "iron-stick", amount = 2 },
			{ type = "item", name = "y-refined-yres1", amount = 2 },
			{ type = "item", name = "y-refined-yres2", amount = 1 },
		},
		results = {
			{ type = "item", name = "ye_tranport_tube_orange", amount = 2.0 },
		},
		main_product = "ye_tranport_tube_orange",
		icon = "__Yuoki__/engines/graphics/icons/ye_transport_orange_icon.png",
		icon_size = 32,
		order = "b1",
		group = "yi_engines",
		subgroup = "yie_tubes",
	},

	--ID:318
	{
		type = "recipe",
		name = "ye_tranport_tube_orange_splitter",
		category = "crafting", --
		enabled = true,
		energy_required = 5.00,
		ingredients = {
			{ type = "item", name = "iron-plate", amount = 6.0 },
			{ type = "item", name = "y_chip_plate", amount = 3.0 },
			{ type = "item", name = "ye_tranport_tube_orange", amount = 4.0 },
		},
		results = {
			{ type = "item", name = "ye_tranport_tube_orange_splitter", amount = 1.0 },
		},
		main_product = "ye_tranport_tube_orange_splitter",
		icon = "__Yuoki__/engines/graphics/icons/orange_splitter_icon.png",
		icon_size = 32,
		order = "b5",
		group = "yi_engines",
		subgroup = "yie_tubes",
	},

	--ID:310

	{
		type = "recipe",
		name = "ye_tranport_tube_green_underground",
		category = "crafting", --
		enabled = true, -- disabled due to graphics issues
		energy_required = 5.00,
		ingredients = {
			{ type = "item", name = "ye_tranport_tube_orange_underground", amount = 2.0 },
			{ type = "item", name = "y-iron-case", amount = 4.0 },
		},
		results = {
			{ type = "item", name = "ye_tranport_tube_green_underground", amount = 2.0 },
		},
		main_product = "ye_tranport_tube_green_underground",
		icon = "__Yuoki__/engines/graphics/icons/ubg_icon.png",
		icon_size = 32,
		order = "b4",
		group = "yi_engines",
		subgroup = "yie_tubes",
	},

	--ID:308
	{
		type = "recipe",
		name = "ye_tranport_tube_green",
		category = "crafting", --
		enabled = true, -- disabled due to graphics issues
		energy_required = 5.00,
		ingredients = {
			{ type = "item", name = "y-winding", amount = 4.0 },
			{ type = "item", name = "y-conductive-coil-1", amount = 2.0 },
			{ type = "item", name = "ye_buechsenblech", amount = 4.0 },
			{ type = "item", name = "ye_tranport_tube_orange", amount = 2.0 },
		},
		results = {
			{ type = "item", name = "ye_tranport_tube_green", amount = 2.0 },
		},
		main_product = "ye_tranport_tube_green",
		icon = "__Yuoki__/engines/graphics/icons/ye_transport_green_icon.png",
		icon_size = 32,
		order = "b2",
		group = "yi_engines",
		subgroup = "yie_tubes",
	},

	--ID:319

	{
		type = "recipe",
		name = "ye_tranport_tube_green_splitter",
		category = "crafting", --
		enabled = true,
		energy_required = 5.00,
		ingredients = {
			{ type = "item", name = "ye_tranport_tube_orange_splitter", amount = 1.0 },
			{ type = "item", name = "ye_buechsenblech", amount = 4.0 },
			{ type = "item", name = "y-emotor-s", amount = 4.0 },
			{ type = "item", name = "y-bluegear", amount = 4.0 },
		},
		results = {
			{ type = "item", name = "ye_tranport_tube_green_splitter", amount = 1.0 },
		},
		main_product = "ye_tranport_tube_green_splitter",
		icon = "__Yuoki__/engines/graphics/icons/green_splitter_icon.png",
		icon_size = 32,
		order = "b6",
		group = "yi_engines",
		subgroup = "yie_tubes",
	},

	--ID:294
	{
		type = "recipe",
		name = "ye_buechse_weiss_export",
		category = "yuoki-stargate", -- stargate-trades
		enabled = true,
		energy_required = 4.00,
		ingredients = {
			{ type = "item", name = "ye_buechse_white", amount = 2.0 },
		},
		results = {
			{ type = "item", name = "ypfw_trader_sign", amount = 800.0 },
			{ type = "item", name = "utility-science-pack", amount = 12.0 },
		},
		main_product = "ypfw_trader_sign",
		icon = "__Yuoki__/engines/graphics/icons/export_buechse_weiss.png",
		icon_size = 64,
		order = "f2",
		group = "yie_harvest",
		subgroup = "yie_trades_line2",
	},

	--ID:293
	{
		type = "recipe",
		name = "ye_buechse_rosa_export",
		category = "yuoki-stargate", -- stargate-trades
		enabled = true,
		energy_required = 4.00,
		ingredients = {
			{ type = "item", name = "ye_buechse_rosa", amount = 2.0 },
		},
		results = {
			{ type = "item", name = "ypfw_trader_sign", amount = 600.0 },
			{ type = "item", name = "chemical-science-pack", amount = 8.0 },
		},
		main_product = "ypfw_trader_sign",
		icon = "__Yuoki__/engines/graphics/icons/export_buechse_rosa.png",
		icon_size = 32,
		order = "f2",
		group = "yie_harvest",
		subgroup = "yie_trades_line2",
	},

	--ID:292
	{
		type = "recipe",
		name = "ye_buechse_fleisch_export",
		category = "yuoki-stargate", -- stargate-trades
		enabled = true,
		energy_required = 4.00,
		ingredients = {
			{ type = "item", name = "ye_buechse_braun", amount = 2.0 },
		},
		results = {
			{ type = "item", name = "ypfw_trader_sign", amount = 400.0 },
			{ type = "item", name = "production-science-pack", amount = 8.0 },
		},
		main_product = "ypfw_trader_sign",
		icon = "__Yuoki__/engines/graphics/icons/export_buechse_fleisch.png",
		icon_size = 32,
		order = "f3",
		group = "yie_harvest",
		subgroup = "yie_trades_line2",
	},

	--ID:291
	{
		type = "recipe",
		name = "ye_buechse_gelb_export",
		category = "yuoki-stargate", -- stargate-trades
		enabled = true,
		energy_required = 4.00,
		ingredients = {
			{ type = "item", name = "ye_buechse_gelb", amount = 4.0 },
		},
		results = {
			{ type = "item", name = "ypfw_trader_sign", amount = 400.0 },
			{ type = "item", name = "military-science-pack", amount = 16.0 },
		},
		main_product = "ypfw_trader_sign",
		icon = "__Yuoki__/engines/graphics/icons/export_buechse_gelb.png",
		icon_size = 64,
		order = "f2",
		group = "yie_harvest",
		subgroup = "yie_trades_line2",
	},

	--ID:290
	{
		type = "recipe",
		name = "ye_buechse_blau_export",
		category = "yuoki-stargate", -- stargate-trades
		enabled = true,
		energy_required = 4.00,
		ingredients = {
			{ type = "item", name = "ye_buechse_blau", amount = 2.0 },
		},
		results = {
			{ type = "item", name = "ypfw_trader_sign", amount = 400.0 },
			{ type = "item", name = "production-science-pack", amount = 12.0 },
		},
		main_product = "ypfw_trader_sign",
		icon = "__Yuoki__/engines/graphics/icons/export_buechse_blau.png",
		icon_size = 32,
		order = "f1",
		group = "yie_harvest",
		subgroup = "yie_trades_line2",
	},

	--ID:288
	{
		type = "recipe",
		name = "ye_smoker",
		category = "crafting", --
		enabled = true,
		energy_required = 5.00,
		ingredients = {
			{ type = "item", name = "stone-brick", amount = 24.0 },
			{ type = "item", name = "y_tile_slagbricks", amount = 12.0 },
			{ type = "item", name = "y_slag_brick", amount = 8.0 },
			{ type = "item", name = "ypfw_trader_sign", amount = 1500.0 },
		},
		results = {
			{ type = "item", name = "ye_smoker", amount = 1.0 },
		},
		main_product = "ye_smoker",
		icon = "__Yuoki__/engines/graphics/entity/yie_smoker_icon.png",
		icon_size = 32,
		order = "5",
		group = "yi_engines",
		subgroup = "yie_agromachinery",
	},

	--ID:287
	{
		type = "recipe",
		name = "ye_smoked_meat",
		category = "yrcat_smoker", -- smoker
		enabled = true,
		energy_required = 5.00,
		ingredients = {
			{ type = "item", name = "ye_rawmeat", amount = 4.0 },
			{ type = "item", name = "wood", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "ye_smoked_meat", amount = 4.0 },
		},
		main_product = "ye_smoked_meat",
		icon = "__Yuoki__/engines/graphics/icons/dry_meat.png",
		icon_size = 32,
		order = "d14",
		group = "yie_harvest",
		subgroup = "yie_agroproducts_crafted",
	},

	--ID:286
	{
		type = "recipe",
		name = "ye_smoked_fish",
		category = "yrcat_smoker", -- smoker
		enabled = true,
		energy_required = 5.00,
		ingredients = {
			{ type = "item", name = "ye_fish4", amount = 3.0 },
			{ type = "item", name = "wood", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "ye_smoked_fish", amount = 3.0 },
		},
		main_product = "ye_smoked_fish",
		icon = "__Yuoki__/engines/graphics/icons/smoked_fisch_2.png",
		icon_size = 32,
		order = "d13",
		group = "yi_engines",
		subgroup = "yie_agroproducts_crafted",
	},

	--ID:285
	{
		type = "recipe",
		name = "ye_grow_animal3fast",
		category = "yrcat_meat", -- meat-category
		enabled = true,
		energy_required = 900.00,
		ingredients = {
			{ type = "item", name = "ye_krakon2", amount = 1.0 },
			{ type = "item", name = "ye_substrat", amount = 36.0 },
			{ type = "item", name = "ye_futtermittel_c", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "ye_verotin", amount = 36.0 },
			{ type = "fluid", name = "ye_blood", amount = 5.0 },
			{ type = "item", name = "ye_rawmeat", amount = 12.0 },
		},
		main_product = "ye_verotin",
		icon = "__Yuoki__/engines/graphics/icons/animal_3.png",
		icon_size = 64,
		order = "fa3",
		group = "yie_harvest",
		subgroup = "yie_animals",
	},

	--ID:284
	{
		type = "recipe",
		name = "ye_futtermittel_d",
		category = "crafting", --
		enabled = true,
		energy_required = 5.00,
		ingredients = {
			{ type = "item", name = "ye_sugar", amount = 8.0 },
			{ type = "item", name = "ye_corn_a", amount = 32.0 },
			{ type = "item", name = "y_organic_dust", amount = 4.0 },
		},
		results = {
			{ type = "item", name = "ye_futtermittel_d", amount = 1.0 },
		},
		main_product = "ye_futtermittel_d",
		icon = "__Yuoki__/engines/graphics/icons/futtermittel_white.png",
		icon_size = 64,
		order = "f4",
		group = "yie_harvest",
		subgroup = "yie_agroproducts_crafted",
	},

	--ID:283
	{
		type = "recipe",
		name = "ye_futtermittel_c",
		category = "crafting", --
		enabled = true,
		energy_required = 5.00,
		ingredients = {
			{ type = "item", name = "ye_celluose", amount = 1.0 },
			{ type = "item", name = "raw-fish", amount = 12.0 },
			{ type = "item", name = "ye_sugar", amount = 8.0 },
		},
		results = {
			{ type = "item", name = "ye_futtermittel_c", amount = 1.0 },
		},
		main_product = "ye_futtermittel_c",
		icon = "__Yuoki__/engines/graphics/icons/futtermittel_rose.png",
		icon_size = 64,
		order = "f3",
		group = "yie_harvest",
		subgroup = "yie_agroproducts_crafted",
	},

	--ID:282
	{
		type = "recipe",
		name = "ye_futtermittel_b",
		category = "yuoki-stargate", -- stargate-trades
		enabled = true,
		energy_required = 5.00,
		ingredients = {
			{ type = "item", name = "ypfw_trader_sign", amount = 9000.0 },
		},
		results = {
			{ type = "item", name = "ye_futtermittel_b", amount = 1.0 },
		},
		main_product = "ye_futtermittel_b",
		icon = "__Yuoki__/engines/graphics/icons/dna_fish_3_imp.png",
		icon_size = 32,
		order = "f2",
		group = "yie_harvest",
		subgroup = "yie_trades_import_line1",
	},

	--ID:281
	{
		type = "recipe",
		name = "ye_futtermittel_a",
		category = "yuoki-stargate", -- stargate-trades
		enabled = true,
		energy_required = 5.00,
		ingredients = {
			{ type = "item", name = "ypfw_trader_sign", amount = 4000.0 },
		},
		results = {
			{ type = "item", name = "ye_futtermittel_a", amount = 1.0 },
		},
		main_product = "ye_futtermittel_a",
		icon = "__Yuoki__/engines/graphics/icons/dna_fish_1_imp.png",
		icon_size = 32,
		order = "f1",
		group = "yie_harvest",
		subgroup = "yie_trades_import_line1",
	},

	--ID:280
	{
		type = "recipe",
		name = "yie_bloodfrommeat",
		category = "yrcat_fluidhandle", -- fluid handling
		enabled = true,
		energy_required = 5.00,
		ingredients = {
			{ type = "fluid", name = "y-mechanical-force", amount = 4.0 },
			{ type = "item", name = "ye_rawmeat", amount = 4.0 },
		},
		results = {
			{ type = "fluid", name = "ye_blood", amount = 1.0 },
		},
		main_product = "ye_blood",
		icon = "__Yuoki__/engines/graphics/blood.png",
		icon_size = 64,
		order = "a3",
		group = "yie_harvest",
		subgroup = "yie_agroproducts",
	},

	--ID:279
	{
		type = "recipe",
		name = "ye_buechse_white",
		category = "yrcat_fluidhandle", -- fluid handling
		enabled = true,
		energy_required = 5.00,
		ingredients = {
			{ type = "item", name = "ye_buechse_empty", amount = 12.0 },
			{ type = "item", name = "ye_corn_b", amount = 4.0 },
			{ type = "item", name = "ye_sugar", amount = 8.0 },
			{ type = "item", name = "ye_fish2", amount = 4.0 },
			{ type = "fluid", name = "y-mechanical-force", amount = 3.0 },
		},
		results = {
			{ type = "item", name = "ye_buechse_white", amount = 12.0 },
		},
		main_product = "ye_buechse_white",
		icon = "__Yuoki__/engines/graphics/icons/buechse_weiss.png",
		icon_size = 64,
		order = "e5",
		group = "yie_harvest",
		subgroup = "yie_agro_package_l2",
	},

	--ID:278
	{
		type = "recipe",
		name = "ye_buechse_rosa",
		category = "yrcat_fluidhandle", -- fluid handling
		enabled = true,
		energy_required = 5.00,
		ingredients = {
			{ type = "item", name = "ye_buechse_empty", amount = 12.0 },
			{ type = "item", name = "ye_smoked_fish", amount = 12.0 },
			{ type = "fluid", name = "y_hydrogen", amount = 6.0 },
			{ type = "fluid", name = "y-mechanical-force", amount = 3.0 },
		},
		results = {
			{ type = "item", name = "ye_buechse_rosa", amount = 12.0 },
		},
		main_product = "ye_buechse_rosa",
		icon = "__Yuoki__/engines/graphics/icons/buechse_rosa.png",
		icon_size = 32,
		order = "e4",
		group = "yie_harvest",
		subgroup = "yie_agro_package_l2",
	},

	--ID:277
	{
		type = "recipe",
		name = "ye_buechse_braun",
		category = "yrcat_fluidhandle", -- fluid handling
		enabled = true,
		energy_required = 5.00,
		ingredients = {
			{ type = "item", name = "ye_buechse_empty", amount = 12.0 },
			{ type = "fluid", name = "y_hydrogen", amount = 6.0 },
			{ type = "fluid", name = "y-mechanical-force", amount = 3.0 },
			{ type = "item", name = "ye_smoked_meat", amount = 12.0 },
		},
		results = {
			{ type = "item", name = "ye_buechse_braun", amount = 12.0 },
		},
		main_product = "ye_buechse_braun",
		icon = "__Yuoki__/engines/graphics/icons/buechse_fleisch.png",
		icon_size = 32,
		order = "e3",
		group = "yie_harvest",
		subgroup = "yie_agro_package_l2",
	},

	--ID:276
	{
		type = "recipe",
		name = "ye_buechse_gelb",
		category = "yrcat_fluidhandle", -- fluid handling
		enabled = true,
		energy_required = 5.00,
		ingredients = {
			{ type = "item", name = "ye_buechse_empty", amount = 12.0 },
			{ type = "item", name = "ye_corn_a", amount = 120.0 },
			{ type = "fluid", name = "y_hydrogen", amount = 6.0 },
			{ type = "fluid", name = "y-mechanical-force", amount = 3.0 },
		},
		results = {
			{ type = "item", name = "ye_buechse_gelb", amount = 12.0 },
		},
		main_product = "ye_buechse_gelb",
		icon = "__Yuoki__/engines/graphics/icons/buechse_gelb.png",
		icon_size = 64,
		order = "e2",
		group = "yie_harvest",
		subgroup = "yie_agro_package_l2",
	},

	--ID:275
	{
		type = "recipe",
		name = "ye_fish4",
		category = "yrcat-fish", -- fishing things
		enabled = true,
		energy_required = 300.00,
		ingredients = {
			{ type = "item", name = "ye_futtermittel_b", amount = 1.0 },
			{ type = "item", name = "ye_futtermittel_d", amount = 1.0 },
			{ type = "fluid", name = "y-con_water", amount = 300.0 },
		},
		results = {
			{ type = "item", name = "ye_fish4", amount = 10.0 },
		},
		main_product = "ye_fish4",
		icon = "__Yuoki__/engines/graphics/icons/fisch_2.png",
		icon_size = 32,
		order = "d12",
		group = "yie_harvest",
		subgroup = "yie_fish",
	},

	--ID:274
	{
		type = "recipe",
		name = "ye_fish3",
		category = "yrcat-fish", -- fishing things
		enabled = true,
		energy_required = 360.00,
		ingredients = {
			{ type = "item", name = "ye_futtermittel_a", amount = 1.0 },
			{ type = "item", name = "ye_futtermittel_d", amount = 1.0 },
			{ type = "fluid", name = "water", amount = 250.0 },
		},
		results = {
			{ type = "item", name = "ye_fish3", amount = 100.0 },
		},
		main_product = "ye_fish3",
		icon = "__Yuoki__/engines/graphics/icons/fisch_1.png",
		icon_size = 32,
		order = "d11",
		group = "yie_harvest",
		subgroup = "yie_fish",
	},

	--ID:269
	{
		type = "recipe",
		name = "ye_buechse_blau",
		category = "yrcat_fluidhandle", -- fluid handling
		enabled = true,
		energy_required = 4.00,
		ingredients = {
			{ type = "item", name = "ye_fish3", amount = 3.0 },
			{ type = "item", name = "ye_buechse_empty", amount = 12.0 },
			{ type = "fluid", name = "ye_cornoil", amount = 3.0 },
			{ type = "fluid", name = "y-mechanical-force", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "ye_buechse_blau", amount = 12.0 },
		},
		main_product = "ye_buechse_blau",
		icon = "__Yuoki__/engines/graphics/icons/buechse_blau.png",
		icon_size = 32,
		order = "e1",
		group = "yie_harvest",
		subgroup = "yie_agro_package_l2",
	},

	--ID:268
	{
		type = "recipe",
		name = "ye_buechsenblech",
		category = "yuoki-formpress", --
		enabled = true,
		energy_required = 5.00,
		ingredients = {
			{ type = "item", name = "ye_verotin", amount = 9.0 },
			{ type = "item", name = "steel-plate", amount = 3.0 },
		},
		results = {
			{ type = "item", name = "ye_buechsenblech", amount = 3.0 },
		},
		main_product = "ye_buechsenblech",
		icon = "__Yuoki__/engines/graphics/icons/blech_blue.png",
		icon_size = 32,
		order = "c2",
		group = "yi_engines",
		subgroup = "yie-processed",
	},

	--ID:267
	{
		type = "recipe",
		name = "ye_buechse_empty",
		category = "yuoki-formpress", --
		enabled = true,
		energy_required = 5.00,
		ingredients = {
			{ type = "fluid", name = "y-mechanical-force", amount = 3.0 },
			{ type = "item", name = "yie_hard_metals", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "ye_buechse_empty", amount = 12.0 },
		},
		main_product = "ye_buechse_empty",
		icon = "__Yuoki__/engines/graphics/icons/buechse_leer.png",
		icon_size = 64,
		order = "s4",
		group = "yie_harvest",
		subgroup = "yie_agroproducts_packages",
	},

	--ID:265
	{
		type = "recipe",
		name = "ye_export_fish2",
		category = "yuoki-stargate", -- stargate-trades
		enabled = true,
		energy_required = 3.00,
		ingredients = {
			{ type = "item", name = "ye_package_fish2", amount = 2.0 },
		},
		results = {
			{ type = "item", name = "ypfw_trader_sign", amount = 370.0 },
			{ type = "item", name = "ye_ice_container_empty", amount = 2.0 },
		},
		main_product = "ypfw_trader_sign",
		icon = "__Yuoki__/engines/graphics/icons/ice_container_red_export.png",
		icon_size = 64,
		order = "exp10",
		group = "yie_harvest",
		subgroup = "yie_trades_line2",
	},

	--ID:263
	{
		type = "recipe",
		name = "ye_package_fish2",
		category = "crafting", --
		enabled = true,
		energy_required = 3.00,
		ingredients = {
			{ type = "item", name = "ye_fish2", amount = 10.0 },
			{ type = "item", name = "ye_ice_container_filled", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "ye_package_fish2", amount = 1.0 },
		},
		main_product = "ye_package_fish2",
		icon = "__Yuoki__/engines/graphics/icons/ice_container_red.png",
		icon_size = 64,
		order = "d10",
		group = "yie_harvest",
		subgroup = "yie_agro_package_l2",
	},

	--ID:262
	{
		type = "recipe",
		name = "ye_fish2",
		category = "yrcat-fish", -- fishing things
		enabled = true,
		energy_required = 270.00,
		ingredients = {
			{ type = "item", name = "ye_dna_fish2", amount = 1.0 },
			{ type = "item", name = "ye_rawmeat", amount = 10.0 },
			{ type = "item", name = "ye_corn_b", amount = 30.0 },
			{ type = "fluid", name = "ye_cornoil", amount = 50.0 },
		},
		results = {
			{ type = "item", name = "ye_fish2", amount = 60.0 },
			{ type = "fluid", name = "petroleum-gas", amount = 20.0 },
		},
		main_product = "ye_fish2",
		icon = "__Yuoki__/engines/graphics/icons/ematrix_rot_32.png",
		icon_size = 64,
		order = "d10",
		group = "yie_harvest",
		subgroup = "yie_fish",
	},

	--ID:261
	{
		type = "recipe",
		name = "ye_dna_fish2",
		category = "yuoki-stargate", -- stargate-trades
		enabled = true,
		energy_required = 3.00,
		ingredients = {
			{ type = "item", name = "ypfw_trader_sign", amount = 5000.0 },
		},
		results = {
			{ type = "item", name = "ye_dna_fish2", amount = 5.0 },
		},
		main_product = "ye_dna_fish2",
		icon = "__Yuoki__/engines/graphics/icons/dna_fish_2_imp.png",
		icon_size = 64,
		order = "imp1",
		group = "yie_harvest",
		subgroup = "yie_trades_import_line1",
	},

	--ID:260
	{
		type = "recipe",
		name = "ye_export_fish1",
		category = "yuoki-stargate", -- stargate-trades
		enabled = true,
		energy_required = 3.00,
		ingredients = {
			{ type = "item", name = "ye_package_fish1", amount = 6.0 },
		},
		results = {
			{ type = "item", name = "ypfw_trader_sign", amount = 40.0 },
			{ type = "item", name = "ye_ice_container_empty", amount = 6.0 },
		},
		main_product = "ypfw_trader_sign",
		icon = "__Yuoki__/engines/graphics/icons/ice_container_lachs_export.png",
		icon_size = 32,
		order = "exp09",
		group = "yie_harvest",
		subgroup = "yie_trades_line2",
	},

	--ID:259
	{
		type = "recipe",
		name = "ye_grow_fish1",
		category = "yrcat-fish", -- fishing things
		enabled = true,
		energy_required = 210.00,
		ingredients = {
			{ type = "item", name = "raw-fish", amount = 3.0 },
			{ type = "fluid", name = "water", amount = 200.0 },
			{ type = "item", name = "ye_corn_a", amount = 30.0 },
			{ type = "fluid", name = "y-mechanical-force", amount = 20.0 },
		},
		results = {
			{ type = "item", name = "raw-fish", amount = 30.0 },
		},
		main_product = "raw-fish",
		icon = "__base__/graphics/icons/fish.png",
		icon_size = 64,
		order = "1",
		group = "yie_harvest",
		subgroup = "yie_fish",
	},

	--ID:258
	{
		type = "recipe",
		name = "ye_package_fish1",
		category = "crafting", --
		enabled = true,
		energy_required = 3.00,
		ingredients = {
			{ type = "item", name = "ye_ice_container_filled", amount = 1.0 },
			{ type = "item", name = "raw-fish", amount = 12.0 },
		},
		results = {
			{ type = "item", name = "ye_package_fish1", amount = 1.0 },
		},
		main_product = "ye_package_fish1",
		icon = "__Yuoki__/engines/graphics/icons/ice_container_lachs.png",
		icon_size = 32,
		order = "a9",
		group = "yie_harvest",
		subgroup = "yie_agro_package_l2",
	},

	--ID:257
	{
		type = "recipe",
		name = "ye_pool",
		category = "crafting", --
		enabled = true,
		energy_required = 3.00,
		ingredients = {
			{ type = "item", name = "y-mwater-pump", amount = 2.0 },
			{ type = "item", name = "stone-brick", amount = 20.0 },
		},
		results = {
			{ type = "item", name = "ye_pool", amount = 1.0 },
		},
		main_product = "ye_pool",
		icon = "__Yuoki__/engines/graphics/icons/pool_icon.png",
		icon_size = 64,
		order = "d4",
		group = "yie_harvest",
		subgroup = "yie_agromachinery",
	},

	--ID:229
	{
		type = "recipe",
		name = "y_unlimited_wood",
		category = "yuoki_green_ultimate", -- Green-Ultimates
		enabled = true,
		energy_required = 5.00,
		ingredients = {},
		results = {
			{ type = "item", name = "wood", amount = 1.0 },
		},
		main_product = "wood",
		icon = "__base__/graphics/icons/wood.png",
		icon_size = 64,
		order = "1",
		group = "yuoki-energy",
		subgroup = "y_ultimate_products",
	},

	--ID:227
	{
		type = "recipe",
		name = "ye_dna_plant4",
		category = "yrcat_dna", -- DNA-Line
		enabled = true,
		energy_required = 10.00,
		ingredients = {
			{ type = "fluid", name = "y-mechanical-force", amount = 8.0 },
			{ type = "item", name = "ye_zells", amount = 4.0 },
		},
		results = {
			{ type = "item", name = "ye_plant_carni", amount = 1.0 },
			{ type = "item", name = "y_greensign", amount = 10.0 },
		},
		main_product = "ye_plant_carni",
		icon = "__Yuoki__/engines/graphics/icons/dna_plant_4.png",
		icon_size = 32,
		order = "p3",
		group = "yie_harvest",
		subgroup = "yie_dnaline",
	},

	--ID:226
	{
		type = "recipe",
		name = "ye_grow_plant2",
		category = "yrcat-farm", -- farm itself
		enabled = true,
		energy_required = 450.00,
		ingredients = {
			{ type = "item", name = "ye_plant_carni", amount = 1.0 },
			{ type = "fluid", name = "water", amount = 300.0 },
			{ type = "item", name = "ye_rawmeat", amount = 30.0 },
		},
		results = {
			{ type = "item", name = "ye_chitrotin", amount = 10.0 },
			{ type = "item", name = "ye_zells", amount = 8.0 },
		},
		main_product = "ye_chitrotin",
		icon = "__Yuoki__/engines/graphics/icons/carni.png",
		icon_size = 32,
		order = "a15",
		group = "yie_harvest",
		subgroup = "yie_farming",
	},

	--ID:225
	{
		type = "recipe",
		name = "ye_package_carni",
		category = "crafting", --
		enabled = true,
		energy_required = 4.00,
		ingredients = {
			{ type = "item", name = "ye_package_empty", amount = 1.0 },
			{ type = "item", name = "ye_chitrotin", amount = 10.0 },
		},
		results = {
			{ type = "item", name = "ye_package_carni", amount = 1.0 },
		},
		main_product = "ye_package_carni",
		icon = "__Yuoki__/engines/graphics/icons/package_carni.png",
		icon_size = 32,
		order = "d9",
		group = "yi_engines",
		subgroup = "yie_agro_package",
	},

	--ID:224
	{
		type = "recipe",
		name = "ye_export06",
		category = "yuoki-stargate", -- stargate-trades
		enabled = true,
		energy_required = 3.00,
		ingredients = {
			{ type = "item", name = "ye_package_carni", amount = 5.0 },
		},
		results = {
			{ type = "item", name = "ypfw_trader_sign", amount = 15.0 },
			{ type = "item", name = "ye_base_green", amount = 3.0 },
		},
		main_product = "ypfw_trader_sign",
		icon = "__Yuoki__/engines/graphics/icons/package_carni_retrade.png",
		icon_size = 32,
		order = "exp08",
		group = "yie_harvest",
		subgroup = "yie_trades_line1",
	},

	--ID:223
	{
		type = "recipe",
		name = "ye_neutralisatzion",
		category = "yuoki-archaeology-wash", --
		enabled = true,
		energy_required = 2.00,
		ingredients = {
			{ type = "fluid", name = "sulfuric-acid", amount = 9.0 },
			{ type = "item", name = "ye_substrat", amount = 40.0 },
			{ type = "fluid", name = "water", amount = 100.0 },
		},
		results = {
			{ type = "fluid", name = "y-con_water", amount = 20.0 },
			{ type = "fluid", name = "y-mechanical-force", amount = 9.0 },
		},
		main_product = "y-con_water",
		icon = "__Yuoki__/engines/graphics/icons/wh_plateq32.png",
		icon_size = 64,
		order = "v4",
		group = "yi_engines",
		subgroup = "yie-fluids",
	},

	--ID:212
	{
		type = "recipe",
		name = "ye_canister2plates_smelt",
		category = "smelting", -- all furnace stuff
		enabled = true,
		energy_required = 3.00,
		ingredients = {
			{ type = "item", name = "ye_canister", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "iron-plate", amount = 14.0 },
		},
		main_product = "iron-plate",
		icon = "__Yuoki__/engines/graphics/canister.png",
		icon_size = 32,
		order = "0",
		group = "yi_engines",
		subgroup = "y-parts",
	},

	--ID:211
	{
		type = "recipe",
		name = "ye_export05",
		category = "yuoki-stargate", -- stargate-trades
		enabled = true,
		energy_required = 3.00,
		ingredients = {
			{ type = "item", name = "ye_package_spliced_cells", amount = 10.0 },
		},
		results = {
			{ type = "item", name = "ypfw_trader_sign", amount = 5.0 },
			{ type = "item", name = "ye_science_blue", amount = 5.0 },
			{ type = "item", name = "ye_krakon2", amount = 1.0 },
		},
		main_product = "ypfw_trader_sign",
		icon = "__Yuoki__/engines/graphics/icons/package_cells_trade.png",
		icon_size = 32,
		order = "exp07",
		group = "yie_harvest",
		subgroup = "yie_trades_line1",
	},

	--ID:210
	{
		type = "recipe",
		name = "ye_export04",
		category = "yuoki-stargate", -- stargate-trades
		enabled = true,
		energy_required = 3.00,
		ingredients = {
			{ type = "item", name = "ye_package_organic", amount = 10.0 },
		},
		results = {
			{ type = "item", name = "ypfw_trader_sign", amount = 100.0 },
			{ type = "item", name = "ye_science_blue", amount = 2.0 },
		},
		main_product = "ypfw_trader_sign",
		icon = "__Yuoki__/engines/graphics/icons/package_om_trade.png",
		icon_size = 32,
		order = "exp06",
		group = "yie_harvest",
		subgroup = "yie_trades_line1",
	},

	--ID:209
	{
		type = "recipe",
		name = "ye_export03",
		category = "yuoki-stargate", -- stargate-trades
		enabled = true,
		energy_required = 3.00,
		ingredients = {
			{ type = "item", name = "ye_package_verotin", amount = 10.0 },
			{ type = "item", name = "y-fame", amount = 2.0 },
		},
		results = {
			{ type = "item", name = "ypfw_trader_sign", amount = 20.0 },
			{ type = "item", name = "y-infused-uca2", amount = 20.0 },
		},
		main_product = "ypfw_trader_sign",
		icon = "__Yuoki__/engines/graphics/icons/package_verotin_trade.png",
		icon_size = 64,
		order = "exp05",
		group = "yie_harvest",
		subgroup = "yie_trades_line1",
	},

	--ID:208
	{
		type = "recipe",
		name = "ye_export02",
		category = "yuoki-stargate", -- stargate-trades
		enabled = true,
		energy_required = 3.00,
		ingredients = {
			{ type = "item", name = "ye_package_omtrinit", amount = 10.0 },
		},
		results = {
			{ type = "item", name = "ypfw_trader_sign", amount = 50.0 },
			{ type = "item", name = "y-fame", amount = 1.0 },
		},
		main_product = "ypfw_trader_sign",
		icon = "__Yuoki__/engines/graphics/icons/package-omtrinit-trade.png",
		icon_size = 64,
		order = "exp04",
		group = "yie_harvest",
		subgroup = "yie_trades_line1",
	},

	--ID:205
	{
		type = "recipe",
		name = "ye_export01",
		category = "yuoki-stargate", -- stargate-trades
		enabled = true,
		energy_required = 3.00,
		ingredients = {
			{ type = "item", name = "ye_package_substratin", amount = 10.0 },
		},
		results = {
			{ type = "item", name = "ypfw_trader_sign", amount = 50.0 },
			{ type = "item", name = "y_greensign", amount = 20.0 },
			{ type = "item", name = "ye_biomixed", amount = 3.0 },
		},
		main_product = "ypfw_trader_sign",
		icon = "__Yuoki__/engines/graphics/icons/package_substrat_trade.png",
		icon_size = 32,
		order = "exp03",
		group = "yie_harvest",
		subgroup = "yie_trades_line1",
	},

	--ID:200
	{
		type = "recipe",
		name = "ye_dna_plant3",
		category = "yrcat_dna", -- DNA-Line
		enabled = true,
		energy_required = 12.00,
		ingredients = {
			{ type = "fluid", name = "y-mechanical-force", amount = 8.0 },
			{ type = "item", name = "ye_corn_b", amount = 18.0 },
		},
		results = {
			{ type = "item", name = "ye_seed_b", amount = 3.0 },
			{ type = "item", name = "ye_zells", amount = 1.0 },
			{ type = "item", name = "y_greensign", amount = 5.0 },
		},
		main_product = "ye_seed_b",
		icon = "__Yuoki__/engines/graphics/icons/dna_plant_2.png",
		icon_size = 64,
		order = "p2",
		group = "yie_harvest",
		subgroup = "yie_dnaline",
	},

	--ID:199
	{
		type = "recipe",
		name = "ye_icemaker",
		category = "crafting", --
		enabled = true,
		energy_required = 6.00,
		ingredients = {
			{ type = "item", name = "ye_fassembly1", amount = 1.0 },
			{ type = "item", name = "y-electric-air-heater", amount = 1.0 },
			{ type = "item", name = "y-mftrans-shaft", amount = 4.0 },
			{ type = "item", name = "pipe", amount = 8.0 },
			{ type = "item", name = "y_gauge", amount = 3.0 },
		},
		results = {
			{ type = "item", name = "ye_icemaker", amount = 1.0 },
		},
		main_product = "ye_icemaker",
		icon = "__Yuoki__/engines/graphics/entity/icemaker_icon.png",
		icon_size = 64,
		order = "f1",
		group = "yi_engines",
		subgroup = "yie_machinery2",
	},

	--ID:198
	{
		type = "recipe",
		name = "ye_ice_container_empty",
		category = "crafting", --
		enabled = true,
		energy_required = 4.00,
		ingredients = {
			{ type = "item", name = "y-heat-pipe", amount = 2.0 },
			{ type = "item", name = "y-iron-case", amount = 2.0 },
		},
		results = {
			{ type = "item", name = "ye_ice_container_empty", amount = 1.0 },
		},
		main_product = "ye_ice_container_empty",
		icon = "__Yuoki__/engines/graphics/icons/ice_container_empty.png",
		icon_size = 64,
		order = "s2",
		group = "yie_harvest",
		subgroup = "yie_agroproducts_packages",
	},

	--ID:197
	{
		type = "recipe",
		name = "ye_package_spliced_cells",
		category = "crafting", --
		enabled = true,
		energy_required = 4.00,
		ingredients = {
			{ type = "item", name = "ye_ice_container_filled", amount = 1.0 },
			{ type = "item", name = "ye_zells", amount = 10.0 },
			{ type = "item", name = "ye_package_empty", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "ye_package_spliced_cells", amount = 1.0 },
		},
		main_product = "ye_package_spliced_cells",
		icon = "__Yuoki__/engines/graphics/icons/package_cells.png",
		icon_size = 32,
		order = "d8",
		group = "yi_engines",
		subgroup = "yie_agro_package",
	},

	--ID:196
	{
		type = "recipe",
		name = "ye_package_verotin",
		category = "crafting", --
		enabled = true,
		energy_required = 4.00,
		ingredients = {
			{ type = "item", name = "ye_package_empty", amount = 1.0 },
			{ type = "item", name = "ye_verotin", amount = 10.0 },
		},
		results = {
			{ type = "item", name = "ye_package_verotin", amount = 1.0 },
		},
		main_product = "ye_package_verotin",
		icon = "__Yuoki__/engines/graphics/icons/package_verotin.png",
		icon_size = 64,
		order = "d6",
		group = "yi_engines",
		subgroup = "yie_agro_package",
	},

	--ID:195
	{
		type = "recipe",
		name = "ye_package_omtrinit",
		category = "crafting", --
		enabled = true,
		energy_required = 4.00,
		ingredients = {
			{ type = "item", name = "ye_package_empty", amount = 1.0 },
			{ type = "item", name = "ye_omtrinit", amount = 12.0 },
		},
		results = {
			{ type = "item", name = "ye_package_omtrinit", amount = 1.0 },
		},
		main_product = "ye_package_omtrinit",
		icon = "__Yuoki__/engines/graphics/icons/package-omtrinit.png",
		icon_size = 64,
		order = "d5",
		group = "yi_engines",
		subgroup = "yie_agro_package",
	},

	--ID:194
	{
		type = "recipe",
		name = "ye_package_organic",
		category = "crafting", --
		enabled = true,
		energy_required = 6.00,
		ingredients = {
			{ type = "item", name = "ye_ice_container_filled", amount = 1.0 },
			{ type = "item", name = "ye_organic_metall", amount = 10.0 },
			{ type = "item", name = "ye_package_empty", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "ye_package_organic", amount = 1.0 },
			{ type = "item", name = "ye_ice_container_empty", amount = 1.0 },
		},
		main_product = "ye_package_organic",
		icon = "__Yuoki__/engines/graphics/icons/package_om.png",
		icon_size = 32,
		order = "d7",
		group = "yi_engines",
		subgroup = "yie_agro_package",
	},

	--ID:193
	{
		type = "recipe",
		name = "ye_package_substratin",
		category = "crafting", --
		enabled = true,
		energy_required = 6.00,
		ingredients = {
			{ type = "item", name = "ye_ice_container_filled", amount = 1.0 },
			{ type = "item", name = "ye_substrat", amount = 40.0 },
			{ type = "item", name = "ye_package_empty", amount = 2.0 },
		},
		results = {
			{ type = "item", name = "ye_package_substratin", amount = 2.0 },
			{ type = "item", name = "ye_ice_container_empty", amount = 1.0 },
		},
		main_product = "ye_package_substratin",
		icon = "__Yuoki__/engines/graphics/icons/package_substrat.png",
		icon_size = 32,
		order = "d4",
		group = "yi_engines",
		subgroup = "yie_agro_package",
	},

	--ID:192
	{
		type = "recipe",
		name = "ye_package_c_meat",
		category = "crafting", --
		enabled = true,
		energy_required = 6.00,
		ingredients = {
			{ type = "item", name = "ye_ice_container_filled", amount = 1.0 },
			{ type = "item", name = "ye_meatcooked", amount = 7.0 },
			{ type = "item", name = "ye_package_empty", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "ye_package_c_meat", amount = 1.0 },
			{ type = "item", name = "ye_ice_container_empty", amount = 1.0 },
		},
		main_product = "ye_package_c_meat",
		icon = "__Yuoki__/engines/graphics/icons/package_cooked_meat.png",
		icon_size = 64,
		order = "d2",
		group = "yi_engines",
		subgroup = "yie_agro_package",
	},

	--ID:191
	{
		type = "recipe",
		name = "ye_package_r_meat",
		category = "crafting", --
		enabled = true,
		energy_required = 6.00,
		ingredients = {
			{ type = "item", name = "ye_ice_container_filled", amount = 2.0 },
			{ type = "item", name = "ye_package_empty", amount = 4.0 },
			{ type = "item", name = "ye_rawmeat", amount = 120.0 },
		},
		results = {
			{ type = "item", name = "ye_package_r_meat", amount = 4.0 },
			{ type = "item", name = "ye_ice_container_empty", amount = 2.0 },
		},
		main_product = "ye_package_r_meat",
		icon = "__Yuoki__/engines/graphics/icons/package_raw_meat.png",
		icon_size = 64,
		order = "d1",
		group = "yi_engines",
		subgroup = "yie_agro_package",
	},

	--ID:190
	{
		type = "recipe",
		name = "ye_package_empty",
		category = "crafting", --
		enabled = true,
		energy_required = 4.00,
		ingredients = {
			{ type = "item", name = "y-iron-case", amount = 1.0 },
			{ type = "item", name = "y_organic_dust", amount = 6.0 },
		},
		results = {
			{ type = "item", name = "ye_package_empty", amount = 1.0 },
		},
		main_product = "ye_package_empty",
		icon = "__Yuoki__/engines/graphics/icons/package_empty.png",
		icon_size = 64,
		order = "s1",
		group = "yie_harvest",
		subgroup = "yie_agroproducts_packages",
	},

	--ID:189
	{
		type = "recipe",
		name = "ye_ice_container_filled",
		category = "yrcat_icemaker", -- Ice-Maker
		enabled = true,
		energy_required = 60.00,
		ingredients = {
			{ type = "item", name = "ye_ice_container_empty", amount = 20.0 },
			{ type = "fluid", name = "y-mechanical-force", amount = 8.0 },
			{ type = "fluid", name = "water", amount = 400.0 },
		},
		results = {
			{ type = "item", name = "ye_ice_container_filled", amount = 20.0 },
		},
		main_product = "ye_ice_container_filled",
		icon = "__Yuoki__/engines/graphics/icons/ice_container_filled.png",
		icon_size = 64,
		order = "s3",
		group = "yie_harvest",
		subgroup = "yie_agroproducts_packages",
	},

	--ID:188
	{
		type = "recipe",
		name = "ye_grow_animal4",
		category = "yrcat_meat", -- meat-category
		enabled = true,
		energy_required = 600.00,
		ingredients = {
			{ type = "item", name = "ye_krakon3", amount = 1.0 },
			{ type = "item", name = "yie_hard_metals", amount = 32.0 },
			{ type = "fluid", name = "lubricant", amount = 22.0 },
			{ type = "item", name = "y-slag", amount = 62.0 },
		},
		results = {
			{ type = "item", name = "ye_organic_metall", amount = 40.0 },
			{ type = "fluid", name = "ye_slurry", amount = 36.0 },
			{ type = "item", name = "ye_science_blue", amount = 3.0 },
			{ type = "fluid", name = "sulfuric-acid", amount = 18.0 },
		},
		main_product = "ye_organic_metall",
		icon = "__Yuoki__/engines/graphics/icons/animal_4.png",
		icon_size = 64,
		order = "fa4",
		group = "yie_harvest",
		subgroup = "yie_animals",
	},

	--ID:187
	{
		type = "recipe",
		name = "ye_dna_animal4",
		category = "yrcat_dna", -- DNA-Line
		enabled = true,
		energy_required = 20.00,
		ingredients = {
			{ type = "item", name = "ye_verotin", amount = 3.0 },
			{ type = "item", name = "ye_dna", amount = 1.0 },
			{ type = "item", name = "ye_substrat", amount = 5.0 },
			{ type = "item", name = "ye_science_blue", amount = 2.0 },
			{ type = "fluid", name = "y-mechanical-force", amount = 100.0 },
		},
		results = {
			{ type = "item", name = "ye_krakon3", amount = 1.0 },
			{ type = "item", name = "y_greensign", amount = 10.0 },
		},
		main_product = "ye_krakon3",
		icon = "__Yuoki__/engines/graphics/icons/dna_meat_4.png",
		icon_size = 64,
		order = "g3",
		group = "yie_harvest",
		subgroup = "yie_dnaline",
	},

	--ID:185
	{
		type = "recipe",
		name = "ye_dna_plant0",
		category = "yrcat_dna", -- DNA-Line
		enabled = true,
		energy_required = 10.00,
		ingredients = {
			{ type = "item", name = "ye_corn_a", amount = 20.0 },
			{ type = "fluid", name = "y-mechanical-force", amount = 6.0 },
		},
		results = {
			{ type = "item", name = "ye_seed_a", amount = 4.0 },
			{ type = "item", name = "ye_zells", amount = 1.0 },
			{ type = "item", name = "y_greensign", amount = 5.0 },
		},
		main_product = "ye_seed_a",
		icon = "__Yuoki__/engines/graphics/icons/dna_plant_1.png",
		icon_size = 64,
		order = "p1",
		group = "yie_harvest",
		subgroup = "yie_dnaline",
	},

	--ID:184
	{
		type = "recipe",
		name = "ye_dna_plant1",
		category = "yrcat_dna", -- DNA-Line
		enabled = true,
		energy_required = 20.00,
		ingredients = {
			{ type = "item", name = "ye_zells", amount = 9.0 },
			{ type = "item", name = "ye_science_blue", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "ye_base_green", amount = 3.0 },
			{ type = "item", name = "y_greensign", amount = 10.0 },
		},
		main_product = "ye_base_green",
		icon = "__Yuoki__/engines/graphics/icons/dna_plant_3.png",
		icon_size = 64,
		order = "p2",
		group = "yie_harvest",
		subgroup = "yie_dnaline",
	},

	--ID:183
	{
		type = "recipe",
		name = "ye_grow_plant1",
		category = "yrcat-farm", -- farm itself
		enabled = true,
		energy_required = 450.00,
		ingredients = {
			{ type = "item", name = "ye_base_green", amount = 1.0 },
			{ type = "fluid", name = "y-con_water", amount = 80.0 },
		},
		results = {
			{ type = "item", name = "ye_substrat", amount = 80.0 },
			{ type = "item", name = "ye_zells", amount = 3.0 },
		},
		main_product = "ye_substrat",
		icon = "__Yuoki__/engines/graphics/icons/substrat_32.png",
		icon_size = 64,
		order = "a14",
		group = "yie_harvest",
		subgroup = "yie_farming",
	},

	--ID:182
	{
		type = "recipe",
		name = "ye_grow_animal3",
		category = "yrcat_meat", -- meat-category
		enabled = true,
		energy_required = 1200.00,
		ingredients = {
			{ type = "item", name = "ye_krakon2", amount = 1.0 },
			{ type = "item", name = "ye_substrat", amount = 30.0 },
			{ type = "fluid", name = "crude-oil", amount = 10.0 },
		},
		results = {
			{ type = "item", name = "ye_verotin", amount = 30.0 },
			{ type = "item", name = "ye_rawmeat", amount = 8.0 },
			{ type = "fluid", name = "ye_blood", amount = 2.0 },
			{ type = "fluid", name = "petroleum-gas", amount = 34.0 },
		},
		main_product = "ye_verotin",
		icon = "__Yuoki__/engines/graphics/icons/animal_3.png",
		icon_size = 64,
		order = "fa3",
		group = "yie_harvest",
		subgroup = "yie_animals",
	},

	--ID:181
	{
		type = "recipe",
		name = "ye_grow_animal2",
		category = "yrcat_meat", -- meat-category
		enabled = true,
		energy_required = 900.00,
		ingredients = {
			{ type = "item", name = "ye_krakon1", amount = 1.0 },
			{ type = "item", name = "y-pol-waste", amount = 70.0 },
			{ type = "item", name = "ye_seed_b", amount = 40.0 },
			{ type = "fluid", name = "ye_cornoil", amount = 30.0 },
		},
		results = {
			{ type = "item", name = "ye_rawmeat", amount = 20.0 },
			{ type = "fluid", name = "ye_blood", amount = 3.0 },
			{ type = "item", name = "ye_omtrinit", amount = 24.0 },
			{ type = "fluid", name = "ye_slurry", amount = 42.0 },
		},
		main_product = "ye_rawmeat",
		icon = "__Yuoki__/engines/graphics/icons/animal_2.png",
		icon_size = 64,
		order = "fa2",
		group = "yie_harvest",
		subgroup = "yie_animals",
	},

	--ID:180
	{
		type = "recipe",
		name = "ye_dna_animal3",
		category = "yrcat_dna", -- DNA-Line
		enabled = true,
		energy_required = 20.00,
		ingredients = {
			{ type = "item", name = "ye_science_blue", amount = 1.0 },
			{ type = "item", name = "ye_dna", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "ye_krakon2", amount = 1.0 },
			{ type = "item", name = "y_greensign", amount = 10.0 },
		},
		main_product = "ye_krakon2",
		icon = "__Yuoki__/engines/graphics/icons/dna_meat_3.png",
		icon_size = 64,
		order = "g2",
		group = "yie_harvest",
		subgroup = "yie_dnaline",
	},

	--ID:179
	{
		type = "recipe",
		name = "ye_dna_animal2",
		category = "yrcat_dna", -- DNA-Line
		enabled = true,
		energy_required = 20.00,
		ingredients = {
			{ type = "item", name = "ye_dna", amount = 1.0 },
			{ type = "item", name = "y_rwtechsign", amount = 6.0 },
		},
		results = {
			{ type = "item", name = "ye_krakon1", amount = 1.0 },
			{ type = "item", name = "y_greensign", amount = 5.0 },
		},
		main_product = "ye_krakon1",
		icon = "__Yuoki__/engines/graphics/icons/dna_meat_2.png",
		icon_size = 64,
		order = "g1",
		group = "yie_harvest",
		subgroup = "yie_dnaline",
	},

	--ID:177
	{
		type = "recipe",
		name = "ye_dnasplicer",
		category = "yuoki-wonder", --
		enabled = true,
		energy_required = 5.00,
		ingredients = {
			{ type = "item", name = "ye_fassembly2", amount = 1.0 },
			{ type = "item", name = "ye_science_blue", amount = 4.0 },
			{ type = "item", name = "y_rwtechsign", amount = 20.0 },
			{ type = "item", name = "y_structure_vessel", amount = 8.0 },
		},
		results = {
			{ type = "item", name = "ye_dnasplicer", amount = 1.0 },
		},
		main_product = "ye_dnasplicer",
		icon = "__Yuoki__/engines/graphics/entity/dna_splicer_icon.png",
		icon_size = 64,
		order = "a",
		group = "yi_engines",
		subgroup = "yie_agromachinery",
	},

	--ID:176
	{
		type = "recipe",
		name = "ye_fassembly1",
		category = "crafting", --
		enabled = true,
		energy_required = 5.00,
		ingredients = {
			{ type = "item", name = "arithmetic-combinator", amount = 1.0 },
			{ type = "item", name = "y-basic-t1-mf", amount = 2.0 },
			{ type = "item", name = "y-chip-1", amount = 4.0 },
			{ type = "item", name = "y-bluegear", amount = 4.0 },
		},
		results = {
			{ type = "item", name = "ye_fassembly1", amount = 1.0 },
		},
		main_product = "ye_fassembly1",
		icon = "__Yuoki__/engines/graphics/entity/factory_var_1_icon.png",
		icon_size = 64,
		order = "as-a",
		group = "yi_engines",
		subgroup = "yie_machinery2",
	},

	--ID:175
	{
		type = "recipe",
		name = "ye_fassembly_sp",
		category = "crafting", --
		enabled = true,
		energy_required = 5.00,
		ingredients = {
			{ type = "item", name = "ye_science_blue", amount = 3.0 },
			{ type = "item", name = "yie_hard_metals", amount = 8.0 },
			{ type = "item", name = "ye_fassembly1", amount = 1.0 },
			{ type = "item", name = "y_structure_element", amount = 8.0 },
		},
		results = {
			{ type = "item", name = "ye_fassembly_sp", amount = 1.0 },
		},
		main_product = "ye_fassembly_sp",
		icon = "__Yuoki__/engines/graphics/entity/factory_var_3_icon.png",
		icon_size = 64,
		order = "as-c",
		group = "yi_engines",
		subgroup = "yie_machinery2",
	},

	--ID:174
	{
		type = "recipe",
		name = "ye_fassembly2",
		category = "crafting", --
		enabled = true,
		energy_required = 5.00,
		ingredients = {
			{ type = "item", name = "ye_science_blue", amount = 1.0 },
			{ type = "item", name = "yie_hard_metals", amount = 4.0 },
			{ type = "item", name = "ye_fassembly1", amount = 1.0 },
			{ type = "item", name = "y_structure_element", amount = 4.0 },
		},
		results = {
			{ type = "item", name = "ye_fassembly2", amount = 1.0 },
		},
		main_product = "ye_fassembly2",
		icon = "__Yuoki__/engines/graphics/entity/factory_var_2_icon.png",
		icon_size = 64,
		order = "as-b",
		group = "yi_engines",
		subgroup = "yie_machinery2",
	},

	--ID:170
	{
		type = "recipe",
		name = "ye_can_uc_empty",
		category = "crafting-with-fluid", --
		enabled = true,
		energy_required = 2.00,
		ingredients = {
			{ type = "item", name = "ye_can_unicomp", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "ye_canister", amount = 1.0 },
			{ type = "fluid", name = "y-liquid-uc2", amount = 500.0 },
		},
		main_product = "ye_canister",
		icon = "__Yuoki__/engines/graphics/can_uc_e.png",
		icon_size = 32,
		order = "f85",
		group = "yi_engines",
		subgroup = "yie_fluid_handle",
	},

	--ID:168
	{
		type = "recipe",
		name = "ye_science_blue",
		category = "yrcat_science", -- Science-Way
		enabled = true,
		energy_required = 20.00,
		ingredients = {},
		results = {
			{ type = "item", name = "ye_science_blue", amount = 1.0 },
		},
		main_product = "ye_science_blue",
		icon = "__Yuoki__/engines/graphics/icons/tech02_32.png",
		icon_size = 64,
		order = "a",
		group = "yi_engines",
		subgroup = "yie-parts",
	},

	--ID:167
	{
		type = "recipe",
		name = "yie_science_blue_gen",
		category = "crafting", --
		enabled = true,
		energy_required = 10.00,
		ingredients = {
			{ type = "item", name = "yie_hard_metals", amount = 10.0 },
			{ type = "item", name = "ye_fassembly1", amount = 1.0 },
			{ type = "item", name = "y_rwtechsign", amount = 20.0 },
		},
		results = {
			{ type = "item", name = "yie_science_blue_gen", amount = 1.0 },
		},
		main_product = "yie_science_blue_gen",
		icon = "__Yuoki__/engines/graphics/entity/science_gen_icon.png",
		icon_size = 64,
		order = "a",
		group = "yi_engines",
		subgroup = "yie_machinery2",
	},

	--ID:166
	{
		type = "recipe",
		name = "ye_center",
		category = "crafting", --
		enabled = true,
		energy_required = 1.00,
		ingredients = {
			{ type = "item", name = "y-infused-uca2", amount = 1.0 },
			{ type = "item", name = "y-unicomp-raw", amount = 10.0 },
			{ type = "item", name = "yie_hard_metals", amount = 16.0 },
		},
		results = {
			{ type = "item", name = "ye_center", amount = 1.0 },
		},
		main_product = "ye_center",
		icon = "__Yuoki__/engines/graphics/icons/uni-k_zer_32.png",
		icon_size = 64,
		order = "a",
		group = "yi_engines",
		subgroup = "yie-parts",
	},

	--ID:165
	{
		type = "recipe",
		name = "y-quantrinum-reactor",
		category = "crafting", --
		enabled = true,
		energy_required = 5.00,
		ingredients = {
			{ type = "item", name = "yie_hard_metals", amount = 30.0 },
			{ type = "item", name = "ye_science_blue", amount = 8.0 },
			{ type = "item", name = "y-winding", amount = 30.0 },
			{ type = "item", name = "ye_center", amount = 8.0 },
			{ type = "item", name = "y-raw-fuelnium", amount = 8.0 },
		},
		results = {
			{ type = "item", name = "y-quantrinum-reactor", amount = 1.0 },
		},
		main_product = "y-quantrinum-reactor",
		icon = "__Yuoki__/engines/graphics/entity/energy2/qr-icon.png",
		icon_size = 64,
		order = "a",
		group = "yi_engines",
		subgroup = "yie-engines",
	},

	--ID:152
	{
		type = "recipe",
		name = "yie_hard_metals",
		category = "yuoki-formpress", --
		enabled = true,
		energy_required = 4.00,
		ingredients = {
			{ type = "item", name = "steel-plate", amount = 2.0 },
			{ type = "item", name = "y-coal-dust", amount = 3.0 },
		},
		results = {
			{ type = "item", name = "yie_hard_metals", amount = 1.0 },
		},
		main_product = "yie_hard_metals",
		icon = "__Yuoki__/engines/graphics/icons/blechrolle_grau.png",
		icon_size = 64,
		order = "c1",
		group = "yi_engines",
		subgroup = "yie-processed",
	},

	--ID:114
	{
		type = "recipe",
		name = "ye_can_petrol_empty",
		category = "crafting-with-fluid", --
		enabled = true,
		energy_required = 2.00,
		ingredients = {
			{ type = "item", name = "ye_can_petrol", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "ye_canister", amount = 1.0 },
			{ type = "fluid", name = "petroleum-gas", amount = 500.0 },
		},
		main_product = "ye_canister",
		icon = "__Yuoki__/engines/graphics/can_petrol_e.png",
		icon_size = 32,
		order = "f84",
		group = "yi_engines",
		subgroup = "yie_fluid_handle",
	},

	--ID:109
	{
		type = "recipe",
		name = "ye_can_co_empty",
		category = "crafting-with-fluid", --
		enabled = true,
		energy_required = 2.00,
		ingredients = {
			{ type = "item", name = "ye_can_co", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "ye_canister", amount = 1.0 },
			{ type = "fluid", name = "crude-oil", amount = 500.0 },
		},
		main_product = "ye_canister",
		icon = "__Yuoki__/engines/graphics/can_co_e.png",
		icon_size = 32,
		order = "f81",
		group = "yi_engines",
		subgroup = "yie_fluid_handle",
	},

	--ID:108
	{
		type = "recipe",
		name = "ye_can_ho_empty",
		category = "crafting-with-fluid", --
		enabled = true,
		energy_required = 2.00,
		ingredients = {
			{ type = "item", name = "ye_can_ho", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "ye_canister", amount = 1.0 },
			{ type = "fluid", name = "heavy-oil", amount = 500.0 },
		},
		main_product = "ye_canister",
		icon = "__Yuoki__/engines/graphics/can_ho_e.png",
		icon_size = 32,
		order = "f82",
		group = "yi_engines",
		subgroup = "yie_fluid_handle",
	},

	--ID:107
	{
		type = "recipe",
		name = "ye_can_sa_empty",
		category = "crafting-with-fluid", --
		enabled = true,
		energy_required = 2.00,
		ingredients = {
			{ type = "item", name = "ye_can_sa", amount = 4.0 },
		},
		results = {
			{ type = "item", name = "ye_canister", amount = 3.0 },
			{ type = "fluid", name = "sulfuric-acid", amount = 500.0 },
		},
		main_product = "ye_canister",
		icon = "__Yuoki__/engines/graphics/can_sa_e.png",
		icon_size = 32,
		order = "f83",
		group = "yi_engines",
		subgroup = "yie_fluid_handle",
	},

	--ID:88
	{
		type = "recipe",
		name = "ye_granulate_trifitan",
		category = "y-crushing", --
		enabled = true,
		energy_required = 3.00,
		ingredients = {
			{ type = "item", name = "ye_celluose", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "y_organic_dust", amount = 14.0 },
			{ type = "item", name = "y_greensign", amount = 2.0 },
		},
		main_product = "y_organic_dust",
		icon = "__Yuoki__/graphics/icons/sawdust_32.png",
		icon_size = 64,
		order = "4",
		group = "yuoki_liquids",
		subgroup = "y_refine_raws",
	},

	--ID:85
	{
		type = "recipe",
		name = "ye_granulate_vuger",
		category = "y-crushing", --
		enabled = true,
		energy_required = 3.00,
		ingredients = {
			{ type = "item", name = "ye_corn_b", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "y_organic_dust", amount = 2.0 },
		},
		main_product = "y_organic_dust",
		icon = "__Yuoki__/graphics/icons/sawdust_32.png",
		icon_size = 64,
		order = "2",
		group = "yuoki_liquids",
		subgroup = "y_refine_raws",
	},

	--ID:84
	{
		type = "recipe",
		name = "ye_granulate_corn",
		category = "y-crushing", --
		enabled = true,
		energy_required = 3.00,
		ingredients = {
			{ type = "item", name = "ye_corn_a", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "y_organic_dust", amount = 1.0 },
		},
		main_product = "y_organic_dust",
		icon = "__Yuoki__/graphics/icons/sawdust_32.png",
		icon_size = 64,
		order = "1",
		group = "yuoki_liquids",
		subgroup = "y_refine_raws",
	},

	--ID:77
	{
		type = "recipe",
		name = "ye-corn2fluid",
		category = "yuoki-formpress", --
		enabled = true,
		energy_required = 30.00,
		ingredients = {
			{ type = "fluid", name = "y-mechanical-force", amount = 0.3 },
			{ type = "item", name = "ye_corn_a", amount = 100.0 },
		},
		results = {
			{ type = "fluid", name = "ye_cornoil", amount = 20.0 },
			{ type = "item", name = "y_greensign", amount = 1.0 },
		},
		main_product = "ye_cornoil",
		icon = "__Yuoki__/engines/graphics/steam-low.png",
		icon_size = 64,
		order = "a1",
		group = "yie_harvest",
		subgroup = "yie_agroproducts",
	},

	--ID:72
	{
		type = "recipe",
		name = "ye_cooking_meat",
		category = "smelting", -- all furnace stuff
		enabled = true,
		energy_required = 4.00,
		ingredients = {
			{ type = "item", name = "ye_rawmeat", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "ye_meatcooked", amount = 1.0 },
		},
		main_product = "ye_meatcooked",
		icon = "__Yuoki__/engines/graphics/cooked_meat.png",
		icon_size = 64,
		order = "p07",
		group = "yie_harvest",
		subgroup = "yie_agroproducts",
	},

	--ID:71
	{
		type = "recipe",
		name = "ye_trademeat2",
		category = "yuoki-stargate", -- stargate-trades
		enabled = true,
		energy_required = 3.00,
		ingredients = {
			{ type = "item", name = "ye_package_c_meat", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "y-quantrinum", amount = 1.0 },
		},
		main_product = "y-quantrinum",
		icon = "__Yuoki__/engines/graphics/icons/package_cooked_meat_trade.png",
		icon_size = 64,
		order = "t01",
		group = "yie_harvest",
		subgroup = "yie_trades_line1",
	},

	--ID:70
	{
		type = "recipe",
		name = "ye_trademeat1",
		category = "yuoki-stargate", -- stargate-trades
		enabled = true,
		energy_required = 3.00,
		ingredients = {
			{ type = "item", name = "ye_package_r_meat", amount = 4.0 },
		},
		results = {
			{ type = "item", name = "y-unicomp-a2", amount = 4.0 },
			{ type = "item", name = "ye_dna", amount = 1.0 },
		},
		main_product = "y-unicomp-a2",
		icon = "__Yuoki__/engines/graphics/icons/package_raw_meat_trade.png",
		icon_size = 64,
		order = "t00",
		group = "yie_harvest",
		subgroup = "yie_trades_line1",
	},

	--ID:69
	{
		type = "recipe",
		name = "ye_slurry2ethanol",
		category = "chemistry", --
		enabled = true,
		energy_required = 90.00,
		ingredients = {
			{ type = "fluid", name = "ye_slurry", amount = 150.0 },
			{ type = "item", name = "ye_sugar", amount = 2.0 },
		},
		results = {
			{ type = "fluid", name = "y_syngas_raw", amount = 30.0 },
		},
		main_product = "y_syngas_raw",
		icon = "__Yuoki__/graphics/icons/obs/h2o_c_icon.png",
		icon_size = 64,
		order = "c04",
		group = "yuoki_liquids",
		subgroup = "y-fluid",
	},

	--ID:68
	{
		type = "recipe",
		name = "ye_tradeblood",
		category = "yuoki-stargate", -- stargate-trades
		enabled = true,
		energy_required = 5.00,
		ingredients = {
			{ type = "item", name = "ye_can_blood", amount = 10.0 },
		},
		results = {
			{ type = "item", name = "y-fame", amount = 1.0 },
		},
		main_product = "y-fame",
		icon = "__Yuoki__/engines/graphics/icons/ice_container_blood_trade.png",
		icon_size = 32,
		order = "exp8",
		group = "yie_harvest",
		subgroup = "yie_trades_line2",
	},

	--ID:67
	{
		type = "recipe",
		name = "ye_cornb_ws",
		category = "yrcat-farm", -- farm itself
		enabled = true,
		energy_required = 270.00,
		ingredients = {
			{ type = "fluid", name = "water", amount = 500.0 },
			{ type = "item", name = "ye_seed_b", amount = 2.0 },
			{ type = "fluid", name = "ye_slurry", amount = 62.0 },
		},
		results = {
			{ type = "item", name = "ye_corn_b", amount = 400.0 },
		},
		main_product = "ye_corn_b",
		icon = "__Yuoki__/engines/graphics/icons/icon_sugarcane_ws.png",
		icon_size = 64,
		order = "a14",
		group = "yie_harvest",
		subgroup = "yie_farming",
	},

	--ID:66
	{
		type = "recipe",
		name = "ye-growcorn_ws",
		category = "yrcat-farm", -- farm itself
		enabled = true,
		energy_required = 200.00,
		ingredients = {
			{ type = "fluid", name = "water", amount = 500.0 },
			{ type = "fluid", name = "ye_slurry", amount = 48.0 },
			{ type = "item", name = "ye_seed_a", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "ye_corn_a", amount = 600.0 },
		},
		main_product = "ye_corn_a",
		icon = "__Yuoki__/engines/graphics/icons/icon_corn_ws.png",
		icon_size = 64,
		order = "a11",
		group = "yie_harvest",
		subgroup = "yie_farming",
	},

	--ID:65
	{
		type = "recipe",
		name = "ye_dna_animal1",
		category = "yrcat_dna", -- DNA-Line
		enabled = true,
		energy_required = 8.00,
		ingredients = {
			{ type = "item", name = "ye_rawmeat", amount = 3.0 },
			{ type = "item", name = "automation-science-pack", amount = 8.0 },
			{ type = "fluid", name = "y-mechanical-force", amount = 3.0 },
			{ type = "fluid", name = "ye_blood", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "ye_dna", amount = 1.0 },
			{ type = "item", name = "y_greensign", amount = 5.0 },
		},
		main_product = "ye_dna",
		icon = "__Yuoki__/engines/graphics/icons/dna_meat_1.png",
		icon_size = 64,
		order = "p06",
		group = "yie_harvest",
		subgroup = "yie_dnaline",
	},

	--ID:64
	{
		type = "recipe",
		name = "ye_grow_animal_a",
		category = "yrcat_meat", -- meat-category
		enabled = true,
		energy_required = 600.00,
		ingredients = {
			{ type = "fluid", name = "water", amount = 600.0 },
			{ type = "item", name = "ye_corn_a", amount = 140.0 },
			{ type = "item", name = "ye_dna", amount = 1.0 },
			{ type = "item", name = "ye_corn_b", amount = 50.0 },
		},
		results = {
			{ type = "item", name = "ye_rawmeat", amount = 52.0 },
			{ type = "fluid", name = "ye_blood", amount = 16.0 },
			{ type = "fluid", name = "ye_slurry", amount = 57.0 },
		},
		main_product = "ye_rawmeat",
		icon = "__Yuoki__/engines/graphics/icons/animal_1.png",
		icon_size = 64,
		order = "fa1",
		group = "yie_harvest",
		subgroup = "yie_animals",
	},

	--ID:63
	{
		type = "recipe",
		name = "ye_dna_animal0",
		category = "crafting", --
		enabled = true,
		energy_required = 30.00,
		ingredients = {
			{ type = "item", name = "logistic-science-pack", amount = 100.0 },
			{ type = "item", name = "chemical-science-pack", amount = 20.0 },
		},
		results = {
			{ type = "item", name = "ye_dna", amount = 1.0 },
			{ type = "item", name = "y_greensign", amount = 20.0 },
		},
		main_product = "ye_dna",
		icon = "__Yuoki__/engines/graphics/icons/dna_meat_1.png",
		icon_size = 64,
		order = "p05",
		group = "yie_harvest",
		subgroup = "yie_dnaline",
	},

	--ID:62
	{
		type = "recipe",
		name = "ye_meatfarm",
		category = "crafting", --
		enabled = true,
		energy_required = 3.00,
		ingredients = {
			{ type = "item", name = "stone-brick", amount = 12.0 },
			{ type = "item", name = "pipe", amount = 4.0 },
			{ type = "item", name = "y-iron-case", amount = 3.0 },
		},
		results = {
			{ type = "item", name = "ye_meatfarm", amount = 1.0 },
		},
		main_product = "ye_meatfarm",
		icon = "__Yuoki__/engines/graphics/entity/cage_empty_icon.png",
		icon_size = 64,
		order = "mf2",
		group = "yie_harvest",
		subgroup = "yie_agromachinery",
	},

	--ID:61
	{
		type = "recipe",
		name = "ye_can_blood_fill",
		category = "yrcat_fluidhandle", -- fluid handling
		enabled = true,
		energy_required = 3.00,
		ingredients = {
			{ type = "item", name = "ye_canister", amount = 1.0 },
			{ type = "item", name = "ye_sealing", amount = 1.0 },
			{ type = "item", name = "ye_ice_container_filled", amount = 1.0 },
			{ type = "fluid", name = "y-mechanical-force", amount = 1.0 },
			{ type = "fluid", name = "ye_blood", amount = 200.0 },
		},
		results = {
			{ type = "item", name = "ye_can_blood", amount = 1.0 },
			{ type = "item", name = "ye_ice_container_empty", amount = 1.0 },
		},
		main_product = "ye_can_blood",
		icon = "__Yuoki__/engines/graphics/can_red_f.png",
		icon_size = 32,
		order = "f07",
		group = "yi_engines",
		subgroup = "yie_fluid_handle",
	},

	--ID:60
	{
		type = "recipe",
		name = "ye_can_blood_empty",
		category = "crafting-with-fluid", --
		enabled = true,
		energy_required = 2.00,
		ingredients = {
			{ type = "item", name = "ye_can_blood", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "ye_canister", amount = 1.0 },
			{ type = "fluid", name = "ye_blood", amount = 200.0 },
		},
		main_product = "ye_canister",
		icon = "__Yuoki__/engines/graphics/can_red_e.png",
		icon_size = 32,
		order = "f61",
		group = "yi_engines",
		subgroup = "yie_fluid_handle",
	},

	--ID:59
	{
		type = "recipe",
		name = "ye_can_slurry_empty",
		category = "crafting-with-fluid", --
		enabled = true,
		energy_required = 2.00,
		ingredients = {
			{ type = "item", name = "ye_can_slurry", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "ye_canister", amount = 1.0 },
			{ type = "fluid", name = "ye_slurry", amount = 500.0 },
		},
		main_product = "ye_canister",
		icon = "__Yuoki__/engines/graphics/can_dg_e.png",
		icon_size = 32,
		order = "f51",
		group = "yi_engines",
		subgroup = "yie_fluid_handle",
	},

	--ID:58
	{
		type = "recipe",
		name = "ye_can_mf_empty",
		category = "crafting-with-fluid", --
		enabled = true,
		energy_required = 2.00,
		ingredients = {
			{ type = "item", name = "ye_can_mf", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "ye_canister", amount = 1.0 },
			{ type = "fluid", name = "y-mechanical-force", amount = 500.0 },
		},
		main_product = "ye_canister",
		icon = "__Yuoki__/engines/graphics/can_mf_e.png",
		icon_size = 32,
		order = "f41",
		group = "yi_engines",
		subgroup = "yie_fluid_handle",
	},

	--ID:57
	{
		type = "recipe",
		name = "ye_can_lub_empty",
		category = "crafting-with-fluid", --
		enabled = true,
		energy_required = 2.00,
		ingredients = {
			{ type = "item", name = "ye_can_lub", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "ye_canister", amount = 1.0 },
			{ type = "fluid", name = "lubricant", amount = 500.0 },
		},
		main_product = "ye_canister",
		icon = "__Yuoki__/engines/graphics/can_lub_e.png",
		icon_size = 32,
		order = "f41",
		group = "yi_engines",
		subgroup = "yie_fluid_handle",
	},

	--ID:56
	{
		type = "recipe",
		name = "ye_can_veg_empty",
		category = "crafting-with-fluid", --
		enabled = true,
		energy_required = 2.00,
		ingredients = {
			{ type = "item", name = "ye_can_veg", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "ye_canister", amount = 1.0 },
			{ type = "fluid", name = "ye_cornoil", amount = 500.0 },
		},
		main_product = "ye_canister",
		icon = "__Yuoki__/engines/graphics/can_veg_e.png",
		icon_size = 32,
		order = "f21",
		group = "yi_engines",
		subgroup = "yie_fluid_handle",
	},

	--ID:55
	{
		type = "recipe",
		name = "ye_can_eth_empty",
		category = "crafting-with-fluid", --
		enabled = true,
		energy_required = 2.00,
		ingredients = {
			{ type = "item", name = "ye_can_eth", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "ye_canister", amount = 1.0 },
			{ type = "fluid", name = "light-oil", amount = 500.0 },
		},
		main_product = "ye_canister",
		icon = "__Yuoki__/engines/graphics/can_eth_e.png",
		icon_size = 32,
		order = "f11",
		group = "yi_engines",
		subgroup = "yie_fluid_handle",
	},

	--ID:49
	{
		type = "recipe",
		name = "ye_sealing",
		category = "yrcat_fluidhandle", -- fluid handling
		enabled = true,
		energy_required = 2.00,
		ingredients = {
			{ type = "item", name = "copper-plate", amount = 8.0 },
			{ type = "fluid", name = "y-mechanical-force", amount = 0.7 },
			{ type = "item", name = "y-unicomp-raw", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "ye_sealing", amount = 22.0 },
		},
		main_product = "ye_sealing",
		icon = "__Yuoki__/engines/graphics/sealing.png",
		icon_size = 32,
		order = "f00",
		group = "yi_engines",
		subgroup = "yie-parts",
	},

	--ID:48 fluid handling
	{
		type = "recipe",
		name = "ye_canmachine",
		category = "crafting", --
		enabled = true,
		energy_required = 2.00,
		ingredients = {
			{ type = "item", name = "y-sfe", amount = 1.0 },
			{ type = "item", name = "y-iron-case", amount = 4.0 },
			{ type = "item", name = "y-mwater-pump", amount = 3.0 },
		},
		results = {
			{ type = "item", name = "ye_canmachine", amount = 1.0 },
		},
		main_product = "ye_canmachine",
		icon = "__Yuoki__/engines/graphics/canning-icon.png",
		icon_size = 64,
		order = "0",
		group = "yuoki_liquids",
		subgroup = "y_refine_machinery",
	},

	--ID:47
	{
		type = "recipe",
		name = "ye_canister",
		category = "yrcat_fluidhandle", -- fluid handling
		enabled = true,
		energy_required = 1.00,
		ingredients = {
			{ type = "item", name = "y_structure_vessel", amount = 1.0 },
			{ type = "item", name = "y-iron-case", amount = 1.0 },
			{ type = "fluid", name = "y-mechanical-force", amount = 1.3 },
		},
		results = {
			{ type = "item", name = "ye_canister", amount = 1.0 },
		},
		main_product = "ye_canister",
		icon = "__Yuoki__/engines/graphics/canister.png",
		icon_size = 32,
		order = "f01",
		group = "yi_engines",
		subgroup = "yie_fluid_handle",
	},

	--ID:46
	{
		type = "recipe",
		name = "ye_tfmw_generator-s",
		category = "crafting", --
		enabled = true,
		energy_required = 1.00,
		ingredients = {
			{ type = "item", name = "yie_hard_metals", amount = 30.0 },
			{ type = "item", name = "ye_science_blue", amount = 20.0 },
			{ type = "item", name = "y_rwtechsign", amount = 20.0 },
		},
		results = {
			{ type = "item", name = "ye_tfmw_generator-s", amount = 1.0 },
		},
		main_product = "ye_tfmw_generator-s",
		icon = "__Yuoki__/engines/graphics/entity/energy2/hngen-o-icon.png",
		icon_size = 64,
		order = "0",
		group = "yi_engines",
		subgroup = "yie_machinery",
	},

	--ID:45
	{
		type = "recipe",
		name = "ye_biofuel",
		category = "y-crushing", --
		enabled = true,
		energy_required = 1.00,
		ingredients = {
			{ type = "item", name = "ye_biomixed", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "y_organic_dust", amount = 72.0 },
			{ type = "item", name = "y_greensign", amount = 10.0 },
		},
		main_product = "y_organic_dust",
		icon = "__Yuoki__/graphics/icons/sawdust_32.png",
		icon_size = 64,
		order = "p04",
		group = "yuoki_liquids",
		subgroup = "y_refine_raws",
	},

	--ID:44
	{
		type = "recipe",
		name = "ye_synwood",
		category = "crafting", --
		enabled = true,
		energy_required = 4.00,
		ingredients = {
			{ type = "item", name = "ye_celluose", amount = 18.0 },
		},
		results = {
			{ type = "item", name = "wood", amount = 3.0 },
			{ type = "item", name = "y_greensign", amount = 5.0 },
		},
		main_product = "wood",
		icon = "__base__/graphics/icons/wood.png",
		icon_size = 64,
		order = "p05",
		group = "yie_harvest",
		subgroup = "yie_agroproducts",
	},

	--ID:43 sugar
	{
		type = "recipe",
		name = "ye_sugar",
		category = "crafting", --
		enabled = true,
		energy_required = 6.00,
		ingredients = {
			{ type = "item", name = "ye_corn_b", amount = 30.0 },
		},
		results = {
			{ type = "item", name = "ye_sugar", amount = 3.0 },
			{ type = "item", name = "y_greensign", amount = 1.0 },
		},
		main_product = "ye_sugar",
		icon = "__Yuoki__/engines/graphics/sugar.png",
		icon_size = 64,
		order = "p03",
		group = "yie_harvest",
		subgroup = "yie_agroproducts",
	},

	--ID:41 rabio
	{
		type = "recipe",
		name = "ye_biomixed",
		category = "advanced-crafting", --
		enabled = true,
		energy_required = 1.00,
		ingredients = {
			{ type = "item", name = "ye_sugar", amount = 4.0 },
			{ type = "item", name = "ye_corn_a", amount = 70.0 },
		},
		results = {
			{ type = "item", name = "ye_biomixed", amount = 1.0 },
			{ type = "item", name = "y_greensign", amount = 3.0 },
		},
		main_product = "ye_biomixed",
		icon = "__Yuoki__/engines/graphics/biomixed.png",
		icon_size = 64,
		order = "p02",
		group = "yie_harvest",
		subgroup = "yie_agroproducts",
	},

	--ID:40
	{
		type = "recipe",
		name = "ye_seed_b",
		category = "crafting", --
		enabled = true,
		energy_required = 1.00,
		ingredients = {
			{ type = "item", name = "ye_corn_a", amount = 20.0 },
			{ type = "item", name = "logistic-science-pack", amount = 35.0 },
		},
		results = {
			{ type = "item", name = "ye_seed_b", amount = 1.0 },
			{ type = "item", name = "y_greensign", amount = 20.0 },
		},
		main_product = "ye_seed_b",
		icon = "__Yuoki__/engines/graphics/sugar-seed.png",
		icon_size = 64,
		order = "a03",
		group = "yie_harvest",
		subgroup = "yie_farming",
	},

	--ID:39
	{
		type = "recipe",
		name = "ye_celluose",
		category = "y-crushing", --
		enabled = true,
		energy_required = 1.00,
		ingredients = {
			{ type = "item", name = "ye_corn_a", amount = 40.0 },
			{ type = "item", name = "ye_corn_b", amount = 80.0 },
			{ type = "fluid", name = "water", amount = 30.0 },
		},
		results = {
			{ type = "item", name = "ye_celluose", amount = 12.0 },
			{ type = "item", name = "y_greensign", amount = 2.0 },
		},
		main_product = "ye_celluose",
		icon = "__Yuoki__/engines/graphics/cellulose.png",
		icon_size = 64,
		order = "p01",
		group = "yie_harvest",
		subgroup = "yie_agroproducts",
	},

	--ID:38
	{
		type = "recipe",
		name = "ye_cornb",
		category = "yrcat-farm", -- farm itself
		enabled = true,
		energy_required = 420.00,
		ingredients = {
			{ type = "fluid", name = "water", amount = 500.0 },
			{ type = "item", name = "ye_seed_b", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "ye_corn_b", amount = 300.0 },
		},
		main_product = "ye_corn_b",
		icon = "__Yuoki__/engines/graphics/sugarcane.png",
		icon_size = 64,
		order = "a13",
		group = "yie_harvest",
		subgroup = "yie_farming",
	},

	--ID:37 only for testings
	{
		type = "recipe",
		name = "ye_rheinsberg",
		category = "crafting", --
		enabled = true,
		energy_required = 5.00,
		ingredients = {
			{ type = "item", name = "ye_science_blue", amount = 25.0 },
			{ type = "item", name = "ye_wpump_m", amount = 2.0 },
			{ type = "item", name = "ye_omtrinit", amount = 96.0 },
			{ type = "item", name = "y_mox2mixed", amount = 64.0 },
			{ type = "item", name = "ye_center", amount = 12.0 },
			{ type = "item", name = "y-emotor-s", amount = 14.0 },
		},
		results = {
			{ type = "item", name = "ye_rheinsberg", amount = 1.0 },
		},
		main_product = "ye_rheinsberg",
		icon = "__Yuoki__/engines/graphics/entity/rheinsberg-icon.png",
		icon_size = 64,
		order = "0",
		group = "yi_engines",
		subgroup = "yie_machinery",
	},

	--ID:36 steam to mechanical power
	{
		type = "recipe",
		name = "ye_steam2mf",
		category = "yrcat_turbine", -- steam to mechanical power
		enabled = true,
		energy_required = 1.20,
		ingredients = {
			{ type = "fluid", name = "ye_steam", amount = 480.0 },
		},
		results = {
			{ type = "fluid", name = "y-mechanical-force", amount = 24.0 },
			{ type = "fluid", name = "water", amount = 40.0 },
		},
		main_product = "y-mechanical-force",
		icon = "__Yuoki__/engines/graphics/mf-1.png",
		icon_size = 64,
		order = "0",
		group = "yi_engines",
		subgroup = "yie-fluids",
	},

	--ID:35 Steam-Turbine
	{
		type = "recipe",
		name = "ye_sturbine",
		category = "crafting", --
		enabled = true,
		energy_required = 1.00,
		ingredients = {
			{ type = "item", name = "yie_hard_metals", amount = 20.0 },
			{ type = "item", name = "ye_science_blue", amount = 10.0 },
		},
		results = {
			{ type = "item", name = "ye_sturbine", amount = 1.0 },
		},
		main_product = "ye_sturbine",
		icon = "__Yuoki__/engines/graphics/entity/energy2/turbine_icon.png",
		icon_size = 64,
		order = "0",
		group = "yi_engines",
		subgroup = "yie-engines",
	},

	--ID:34 overheater for steam
	{
		type = "recipe",
		name = "ye_overheater",
		category = "crafting", --
		enabled = true,
		energy_required = 1.00,
		ingredients = {
			{ type = "item", name = "yie_hard_metals", amount = 10.0 },
			{ type = "item", name = "ye_science_blue", amount = 3.0 },
		},
		results = {
			{ type = "item", name = "ye_overheater", amount = 1.0 },
		},
		main_product = "ye_overheater",
		icon = "__Yuoki__/engines/graphics/entity/heater55_icon.png",
		icon_size = 64,
		order = "0",
		group = "yi_engines",
		subgroup = "yie_machinery",
	},

	--ID:33 make steam - needs lua-code
	{
		type = "recipe",
		name = "ye_makesteam",
		category = "yrcat-heater", -- overheater for steam
		enabled = true,
		energy_required = 1.00,
		ingredients = {
			{ type = "fluid", name = "water", amount = 20.0 },
		},
		results = {
			{ type = "fluid", name = "ye_steam", amount = 240.0 },
		},
		main_product = "ye_steam",
		icon = "__Yuoki__/engines/graphics/steam.png",
		icon_size = 64,
		order = "0",
		group = "yi_engines",
		subgroup = "yie-fluids",
	},

	--ID:32 gearbox transmission without lubricant
	{
		type = "recipe",
		name = "y-mf2b",
		category = "yrcat-mf2", -- gearbox
		enabled = true,
		energy_required = 0.50,
		ingredients = {
			{ type = "fluid", name = "y-mechanical-force", amount = 1.6 },
			{ type = "fluid", name = "water", amount = 5.0 },
		},
		results = {
			{ type = "fluid", name = "y-mechanical-force", amount = 1.4 },
		},
		main_product = "y-mechanical-force",
		icon = "__Yuoki__/engines/graphics/gears_br.png",
		icon_size = 32,
		order = "0",
		group = "yi_engines",
		subgroup = "yie-fluids",
	},

	--ID:31 water-pump
	{
		type = "recipe",
		name = "y-mfwater",
		category = "yrcat-pump", -- water-pump
		enabled = true,
		energy_required = 2.00,
		ingredients = {
			{ type = "fluid", name = "y-mechanical-force", amount = 0.1 },
		},
		results = {
			{ type = "fluid", name = "water", amount = 600.0 },
		},
		main_product = "water",
		icon = "__Yuoki__/engines/graphics/water-clean2.png",
		icon_size = 64,
		order = "0",
		group = "yi_engines",
		subgroup = "yie-fluids",
	},

	--ID:29 elektromotor + stirling
	{
		type = "recipe",
		name = "y-mf1c",
		category = "yrcat-mf1c", -- mechanical force primary - stirling
		enabled = true,
		energy_required = 1.00,
		ingredients = {},
		results = {
			{ type = "fluid", name = "y-mechanical-force", amount = 0.4 },
		},
		main_product = "y-mechanical-force",
		icon = "__Yuoki__/engines/graphics/gear_basic.png",
		icon_size = 64,
		order = "0",
		group = "yi_engines",
		subgroup = "yie-fluids",
	},

	--ID:19 small e-motor
	{
		type = "recipe",
		name = "y-emotor-s",
		category = "crafting", --
		enabled = true,
		energy_required = 1.00,
		ingredients = {
			{ type = "item", name = "copper-cable", amount = 2.0 },
			{ type = "item", name = "y-iron-case", amount = 1.0 },
			{ type = "item", name = "y-winding", amount = 1.0 },
			{ type = "item", name = "y-heat-pipe", amount = 2.0 },
		},
		results = {
			{ type = "item", name = "y-emotor-s", amount = 1.0 },
		},
		main_product = "y-emotor-s",
		icon = "__Yuoki__/engines/graphics/entity/e-motor-icon.png",
		icon_size = 64,
		order = "m1",
		group = "yi_engines",
		subgroup = "yie-engines",
	},

	--ID:18 Little Stirling Engine
	{
		type = "recipe",
		name = "y-1stirling-engine",
		category = "crafting", --
		enabled = true,
		energy_required = 1.00,
		ingredients = {
			{ type = "item", name = "iron-gear-wheel", amount = 3.0 },
			{ type = "item", name = "engine-unit", amount = 1.0 },
			{ type = "item", name = "y-heat-pipe", amount = 2.0 },
		},
		results = {
			{ type = "item", name = "y-1stirling-engine", amount = 1.0 },
		},
		main_product = "y-1stirling-engine",
		icon = "__Yuoki__/engines/graphics/icons/fce-icon.png",
		icon_size = 64,
		order = "a",
		group = "yuoki-energy",
		subgroup = "y-parts",
	},

	--ID:17 Electric Air-Heater
	{
		type = "recipe",
		name = "y-electric-air-heater",
		category = "crafting", --
		enabled = true,
		energy_required = 2.00,
		ingredients = {
			{ type = "item", name = "engine-unit", amount = 1.0 },
			{ type = "item", name = "iron-gear-wheel", amount = 2.0 },
			{ type = "item", name = "copper-cable", amount = 7.0 },
			{ type = "item", name = "y-heat-pipe", amount = 4.0 },
		},
		results = {
			{ type = "item", name = "y-electric-air-heater", amount = 1.0 },
		},
		main_product = "y-electric-air-heater",
		icon = "__Yuoki__/engines/graphics/entity/energy2/air-heater-icon.png",
		icon_size = 64,
		order = "d",
		group = "yi_engines",
		subgroup = "yie_machinery",
	},

	--ID:15 shaft-blue
	{
		type = "recipe",
		name = "y-mftrans-shaft",
		category = "crafting", --
		enabled = true,
		energy_required = 1.00,
		ingredients = {
			{ type = "item", name = "yie_hard_metals", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "y-mftrans-shaft", amount = 1.0 },
		},
		main_product = "y-mftrans-shaft",
		icon = "__Yuoki__/engines/graphics/entity/shaft-pipe/shaft-icon.png",
		icon_size = 64,
		order = "1a",
		group = "yi_engines",
		subgroup = "yie_tubes",
	},

	--ID:14 Shaft-Red
	{
		type = "recipe",
		name = "y-mftrans-shaft-red",
		category = "crafting", --
		enabled = true,
		energy_required = 1.00,
		ingredients = {
			{ type = "item", name = "yie_hard_metals", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "y-mftrans-shaft-red", amount = 1.0 },
		},
		main_product = "y-mftrans-shaft-red",
		icon = "__Yuoki__/engines/graphics/entity/shaft-pipe/shaft-r-icon.png",
		icon_size = 64,
		order = "1c",
		group = "yi_engines",
		subgroup = "yie_tubes",
	},

	--ID:13 Underground-Shaft
	{
		type = "recipe",
		name = "y-mftrans-shaft-ground",
		category = "crafting", --
		enabled = true,
		energy_required = 1.00,
		ingredients = {
			{ type = "item", name = "yie_hard_metals", amount = 10.0 },
		},
		results = {
			{ type = "item", name = "y-mftrans-shaft-ground", amount = 1.0 },
		},
		main_product = "y-mftrans-shaft-ground",
		icon = "__Yuoki__/engines/graphics/entity/shaft-pipe/shaft-ground-icon.png",
		icon_size = 64,
		order = "1b",
		group = "yi_engines",
		subgroup = "yie_tubes",
	},

	--ID:12 growing corn
	{
		type = "recipe",
		name = "ye-growcorn",
		category = "yrcat-farm", -- farm itself
		enabled = true,
		energy_required = 300.00,
		ingredients = {
			{ type = "item", name = "ye_seed_a", amount = 1.0 },
			{ type = "fluid", name = "water", amount = 500.0 },
		},
		results = {
			{ type = "item", name = "ye_corn_a", amount = 500.0 },
		},
		main_product = "ye_corn_a",
		icon = "__Yuoki__/engines/graphics/corn-icon.png",
		icon_size = 64,
		order = "a10",
		group = "yie_harvest",
		subgroup = "yie_farming",
	},

	--ID:11 process corn-oil to lubricant
	{
		type = "recipe",
		name = "ye-cf2lubricant",
		category = "chemistry", --
		enabled = true,
		energy_required = 1.00,
		ingredients = {
			{ type = "fluid", name = "ye_cornoil", amount = 30.0 },
		},
		results = {
			{ type = "fluid", name = "lubricant", amount = 10.0 },
			{ type = "item", name = "y_greensign", amount = 1.0 },
		},
		main_product = "lubricant",
		icon = "__Yuoki__/engines/graphics/lubricant.png",
		icon_size = 64,
		order = "a2",
		group = "yie_harvest",
		subgroup = "yie_agroproducts",
	},

	--ID:10 Underground-Shaft-Red
	{
		type = "recipe",
		name = "y-mftrans-shaft-ground-red",
		category = "crafting", --
		enabled = true,
		energy_required = 1.00,
		ingredients = {
			{ type = "item", name = "yie_hard_metals", amount = 10.0 },
		},
		results = {
			{ type = "item", name = "y-mftrans-shaft-ground-red", amount = 1.0 },
		},
		main_product = "y-mftrans-shaft-ground-red",
		icon = "__Yuoki__/engines/graphics/entity/shaft-pipe/shaft-ground-r-icon.png",
		icon_size = 64,
		order = "1d",
		group = "yi_engines",
		subgroup = "yie_tubes",
	},

	--ID:9 core seed
	{
		type = "recipe",
		name = "ye-seed_a2",
		category = "crafting", --
		enabled = true,
		energy_required = 1.00,
		ingredients = {
			{ type = "item", name = "ye_corn_a", amount = 20.0 },
		},
		results = {
			{ type = "item", name = "ye_seed_a", amount = 1.0 },
			{ type = "item", name = "y_greensign", amount = 1.0 },
		},
		main_product = "ye_seed_a",
		icon = "__Yuoki__/engines/graphics/seed-icon.png",
		icon_size = 64,
		order = "a01",
		group = "yie_harvest",
		subgroup = "yie_farming",
	},

	--ID:8 core seed
	{
		type = "recipe",
		name = "ye-seed_a1",
		category = "crafting", --
		enabled = true,
		energy_required = 7.00,
		ingredients = {
			{ type = "item", name = "logistic-science-pack", amount = 35.0 },
			{ type = "item", name = "y-dirt", amount = 40.0 },
		},
		results = {
			{ type = "item", name = "ye_seed_a", amount = 1.0 },
		},
		main_product = "ye_seed_a",
		icon = "__Yuoki__/engines/graphics/icons/icon_iseed.png",
		icon_size = 64,
		order = "a00",
		group = "yie_harvest",
		subgroup = "yie_farming",
	},

	--ID:7 iron case
	{
		type = "recipe",
		name = "y-iron-case",
		category = "crafting", --
		enabled = true,
		energy_required = 1.00,
		ingredients = {
			{ type = "item", name = "yie_hard_metals", amount = 2.0 },
		},
		results = {
			{ type = "item", name = "y-iron-case", amount = 1.0 },
		},
		main_product = "y-iron-case",
		icon = "__Yuoki__/engines/graphics/caseing-icon.png",
		icon_size = 64,
		order = "a",
		group = "yi_engines",
		subgroup = "yie-parts",
	},

	--ID:6 Farm itself
	{
		type = "recipe",
		name = "ye_farm",
		category = "crafting", --
		enabled = true,
		energy_required = 1.00,
		ingredients = {
			{ type = "item", name = "stone-brick", amount = 12.0 },
			{ type = "item", name = "pipe", amount = 2.0 },
			{ type = "item", name = "y-iron-case", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "ye_farm", amount = 1.0 },
		},
		main_product = "ye_farm",
		icon = "__Yuoki__/engines/graphics/entity/farm-icon.png",
		icon_size = 64,
		order = "mf1",
		group = "yie_harvest",
		subgroup = "yie_agromachinery",
	},

	--ID:5 removes pollution, add waste
	{
		type = "recipe",
		name = "y-rmvpol",
		category = "yrcat-eg4", -- stirlings
		enabled = true,
		energy_required = 2.00,
		ingredients = {
			{ type = "fluid", name = "water", amount = 60.0 },
			{ type = "fluid", name = "y-mechanical-force", amount = 0.2 },
		},
		results = {
			{ type = "item", name = "y-pol-waste", amount = 1.0 },
		},
		main_product = "y-pol-waste",
		icon = "__Yuoki__/engines/graphics/icons/kalkstein_32.png",
		icon_size = 64,
		order = "a1",
		group = "yi_engines",
		subgroup = "yie-processed",
	},

	--ID:4 Motor Wicklung
	{
		type = "recipe",
		name = "y-winding",
		category = "crafting", --
		enabled = true,
		energy_required = 1.00,
		ingredients = {
			{ type = "item", name = "iron-plate", amount = 2.0 },
			{ type = "item", name = "copper-cable", amount = 14.0 },
		},
		results = {
			{ type = "item", name = "y-winding", amount = 3.0 },
		},
		main_product = "y-winding",
		icon = "__Yuoki__/engines/graphics/winding-icon.png",
		icon_size = 64,
		order = "i1",
		group = "yi_engines",
		subgroup = "yie-parts",
	},

	--ID:2 quantrinum-charge
	{
		type = "recipe",
		name = "y-quantrinum-charge",
		category = "crafting", --
		enabled = true,
		energy_required = 30.00,
		ingredients = {
			{ type = "item", name = "y-iron-case", amount = 1.0 },
			{ type = "item", name = "y_quantrinum_infused", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "y-quantrinum-charge", amount = 2.0 },
		},
		main_product = "y-quantrinum-charge",
		icon = "__Yuoki__/engines/graphics/quantrinum-32.png",
		icon_size = 64,
		order = "a",
		group = "yi_engines",
		subgroup = "yie-parts",
	},

	--ID:1 craft water-pump
	{
		type = "recipe",
		name = "y-mwater-pump",
		category = "crafting", --
		enabled = true,
		energy_required = 2.00,
		ingredients = {
			{ type = "item", name = "iron-gear-wheel", amount = 4.0 },
			{ type = "item", name = "pipe", amount = 3.0 },
		},
		results = {
			{ type = "item", name = "y-mwater-pump", amount = 1.0 },
		},
		main_product = "y-mwater-pump",
		icon = "__Yuoki__/engines/graphics/entity/pump-icon.png",
		icon_size = 32,
		order = "t1",
		group = "yi_engines",
		subgroup = "yie_machinery",
	},
})
