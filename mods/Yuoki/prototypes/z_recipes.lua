data:extend({

	--ID:355
	{
		type = "recipe",
		name = "y_crystal_dust",
		category = "yrcat_trockner",
		enabled = true,
		energy_required = 8.00,
		ingredients = {
			{ type = "fluid", name = "y_richemulsion", amount = 50.0 },
		},
		results = {
			{ type = "item", name = "y_crystal_dust", amount = 2.0 },
		},
		main_product = "y_crystal_dust",
		icon = "__Yuoki__/graphics/icons/yb-dusts.png",
		icon_size = 64,
		order = "0",
		group = "yuoki",
		subgroup = "y_line3",
	},

	--ID:353
	{
		type = "recipe",
		name = "y_richemulsion",
		category = "yrcat_hppump",
		enabled = true,
		energy_required = 8.00,
		ingredients = {
			{ type = "fluid", name = "y_emulsion", amount = 100.0 },
		},
		results = {
			{ type = "fluid", name = "y_richemulsion", amount = 100.0 },
		},
		main_product = "y_richemulsion",
		icon = "__Yuoki__/graphics/icons/hydraulik-fluid.png",
		icon_size = 64,
		order = "0",
		group = "yuoki_liquids",
		subgroup = "y-fluid",
	},

	--ID:352
	{
		type = "recipe",
		name = "y_emulsion",
		category = "yrcat_emulsion",
		enabled = true,
		energy_required = 4.00,
		ingredients = {
			{ type = "item", name = "y_steinmehl", amount = 4.0 },
			{ type = "fluid", name = "water", amount = 200.0 },
		},
		results = {
			{ type = "fluid", name = "y_emulsion", amount = 50.0 },
		},
		main_product = "y_emulsion",
		icon = "__Yuoki__/graphics/icons/liquid_air_icon.png",
		icon_size = 64,
		order = "0",
		group = "yuoki_liquids",
		subgroup = "y-fluid",
	},

	--ID:351
	{
		type = "recipe",
		name = "y_trockner",
		category = "crafting",
		enabled = true,
		energy_required = 2.00,
		ingredients = {
			{ type = "item", name = "assembling-machine-2", amount = 1.0 },
			{ type = "item", name = "electric-furnace", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "y_trockner", amount = 1.0 },
		},
		main_product = "y_trockner",
		icon = "__Yuoki__/graphics/entity/base_factory_icon.png",
		icon_size = 64,
		order = "u",
		group = "yuoki",
		subgroup = "y_line1",
	},

	--ID:350
	{
		type = "recipe",
		name = "y_hppump",
		category = "crafting",
		enabled = true,
		energy_required = 3.00,
		ingredients = {
			{ type = "item", name = "assembling-machine-2", amount = 1.0 },
			{ type = "item", name = "offshore-pump", amount = 2.0 },
		},
		results = {
			{ type = "item", name = "y_hppump", amount = 1.0 },
		},
		main_product = "y_hppump",
		icon = "__Yuoki__/graphics/entity/hppump_icon.png",
		icon_size = 64,
		order = "v",
		group = "yuoki_liquids",
		subgroup = "y_refine_machinery",
	},

	--ID:349
	{
		type = "recipe",
		name = "y_crystalizer",
		category = "crafting",
		enabled = true,
		energy_required = 3.00,
		ingredients = {
			{ type = "item", name = "assembling-machine-2", amount = 1.0 },
			{ type = "item", name = "solar-panel", amount = 2.0 },
		},
		results = {
			{ type = "item", name = "y_crystalizer", amount = 1.0 },
		},
		main_product = "y_crystalizer",
		icon = "__Yuoki__/graphics/entity/crys_icon.png",
		icon_size = 64,
		order = "u",
		group = "yuoki",
		subgroup = "y_line1b",
	},

	--ID:348
	{
		type = "recipe",
		name = "y_mixer_emu",
		category = "crafting",
		enabled = true,
		energy_required = 2.00,
		ingredients = {
			{ type = "item", name = "engine-unit", amount = 4.0 },
			{ type = "item", name = "storage-tank", amount = 2.0 },
			{ type = "item", name = "automation-science-pack", amount = 5.0 },
		},
		results = {
			{ type = "item", name = "y_mixer_emu", amount = 1.0 },
		},
		main_product = "y_mixer_emu",
		icon = "__Yuoki__/graphics/entity/water_mixer_icon.png",
		icon_size = 64,
		order = "u",
		group = "yuoki_liquids",
		subgroup = "y_refine_machinery",
	},

	--ID:347
	{
		type = "recipe",
		name = "y_steinmehl",
		category = "y-crushing",
		enabled = true,
		energy_required = 2.00,
		ingredients = {
			{ type = "item", name = "stone-brick", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "y_steinmehl", amount = 8.0 },
		},
		main_product = "y_steinmehl",
		icon = "__Yuoki__/graphics/icons/stone-dust.png",
		icon_size = 64,
		order = "f",
		group = "yuoki",
		subgroup = "y_line3",
	},

	--ID:345
	{
		type = "recipe",
		name = "ye_createbluesigns",
		category = "crafting",
		enabled = true,
		energy_required = 10.00,
		ingredients = {
			{ type = "item", name = "chemical-science-pack", amount = 1.0 },
			{ type = "item", name = "production-science-pack", amount = 1.0 },
			{ type = "item", name = "logistic-science-pack", amount = 1.0 },
			{ type = "item", name = "automation-science-pack", amount = 1.0 },
			{ type = "item", name = "military-science-pack", amount = 1.0 },
			{ type = "item", name = "utility-science-pack", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "ye_science_blue", amount = 1.0 },
		},
		main_product = "ye_science_blue",
		icon = "__Yuoki__/graphics/icons/sign_science_icon.png",
		icon_size = 64,
		order = "9",
		group = "yuoki-atomics",
		subgroup = "y-stargate-4",
		auto_recycle = false,
	},

	--ID:344
	{
		type = "recipe",
		name = "y_mox2fuelsplited",
		category = "yuoki-wonder",
		enabled = true,
		energy_required = 20.00,
		ingredients = {
			{ type = "item", name = "y_mox2fuel", amount = 1.0 },
			{ type = "item", name = "y_block_cold", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "y_mox2fuelsplited", amount = 10.0 },
		},
		main_product = "y_mox2fuelsplited",
		icon = "__Yuoki__/graphics/icons/mox-c_splitted_icon.png",
		icon_size = 64,
		order = "9",
		group = "yuoki-energy",
		subgroup = "y-fuel",
	},

	--ID:341
	{
		type = "recipe",
		name = "y_wood_wall",
		category = "crafting",
		enabled = true,
		energy_required = 1.50,
		ingredients = {
			{ type = "item", name = "wood", amount = 3.0 },
		},
		results = {
			{ type = "item", name = "y_wood_wall", amount = 1.0 },
		},
		main_product = "y_wood_wall",
		icon = "__Yuoki__/graphics/entity/walls/wood_wall_icon.png",
		icon_size = 64,
		order = "1",
		group = "yuoki",
		subgroup = "y_defense_walls",
	},

	--ID:340
	{
		type = "recipe",
		name = "y_mox2fuel",
		category = "yuoki-archaeology-wash",
		enabled = true,
		energy_required = 10.00,
		ingredients = {
			{ type = "item", name = "y_mox2heated", amount = 1.0 },
			{ type = "fluid", name = "water", amount = 500.0 },
		},
		results = {
			{ type = "item", name = "y_mox2fuel", amount = 1.0 },
		},
		main_product = "y_mox2fuel",
		icon = "__Yuoki__/graphics/icons/mox2l.png",
		icon_size = 64,
		order = "8",
		group = "yuoki-energy",
		subgroup = "y-fuel",
	},

	--ID:338
	{
		type = "recipe",
		name = "y_mox2mixed",
		category = "yuoki_mox",
		enabled = true,
		energy_required = 7.00,
		ingredients = {
			{ type = "item", name = "yi_graphite", amount = 1.0 },
			{ type = "item", name = "y-infused-uca2", amount = 1.0 },
			{ type = "item", name = "uranium-ore", amount = 6.0 },
		},
		results = {
			{ type = "item", name = "y_mox2mixed", amount = 1.0 },
		},
		main_product = "y_mox2mixed",
		icon = "__Yuoki__/graphics/icons/mox2p.png",
		icon_size = 64,
		order = "8",
		group = "yuoki-energy",
		subgroup = "y-fuel",
	},

	--ID:337
	{
		type = "recipe",
		name = "y_mox1fuel",
		category = "yuoki-archaeology-wash",
		enabled = true,
		energy_required = 10.00,
		ingredients = {
			{ type = "item", name = "y_mox1heated", amount = 1.0 },
			{ type = "fluid", name = "water", amount = 500.0 },
		},
		results = {
			{ type = "item", name = "y_mox1fuel", amount = 1.0 },
		},
		main_product = "y_mox1fuel",
		icon = "__Yuoki__/graphics/icons/mox1f.png",
		icon_size = 64,
		order = "8",
		group = "yuoki-energy",
		subgroup = "y-fuel",
	},

	--ID:335
	{
		type = "recipe",
		name = "y_mox1mixed",
		category = "yuoki_mox",
		enabled = true,
		energy_required = 4.00,
		ingredients = {
			{ type = "item", name = "yi_graphite", amount = 1.0 },
			{ type = "item", name = "y-raw-fuelnium", amount = 1.0 },
			{ type = "item", name = "uranium-ore", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "y_mox1mixed", amount = 1.0 },
		},
		main_product = "y_mox1mixed",
		icon = "__Yuoki__/graphics/icons/mox1e.png",
		icon_size = 64,
		order = "8",
		group = "yuoki-energy",
		subgroup = "y-fuel",
	},

	--ID:334
	{
		type = "recipe",
		name = "y_moxmixer",
		category = "crafting",
		enabled = true,
		energy_required = 5.00,
		ingredients = {
			{ type = "item", name = "assembling-machine-2", amount = 1.0 },
			{ type = "item", name = "y_structure_vessel", amount = 2.0 },
			{ type = "item", name = "y-basic-t2-mf", amount = 2.0 },
		},
		results = {
			{ type = "item", name = "y_moxmixer", amount = 1.0 },
		},
		main_product = "y_moxmixer",
		icon = "__Yuoki__/graphics/entity/boiler-sh_icon.png",
		icon_size = 64,
		order = "9",
		group = "yuoki",
		subgroup = "y_line1b",
	},

	--ID:333
	{
		type = "recipe",
		name = "yi_graphite",
		category = "yuoki-formpress",
		enabled = true,
		energy_required = 5.00,
		ingredients = {
			{ type = "item", name = "y-coal-dust", amount = 12.0 },
			{ type = "item", name = "y-richdust", amount = 3.0 },
		},
		results = {
			{ type = "item", name = "yi_graphite", amount = 1.0 },
		},
		main_product = "yi_graphite",
		icon = "__Yuoki__/graphics/icons/graphite_rod.png",
		icon_size = 64,
		order = "u",
		group = "yuoki",
		subgroup = "yuoki-formpress",
	},

	--ID:300
	{
		type = "recipe",
		name = "y_signal_pole",
		category = "crafting",
		enabled = true,
		energy_required = 1.50,
		ingredients = {
			{ type = "item", name = "y_structure_electric", amount = 1.0 },
			{ type = "item", name = "iron-stick", amount = 12.0 },
			{ type = "item", name = "y-conductive-coil-1", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "y_signal_pole", amount = 1.0 },
		},
		main_product = "y_signal_pole",
		icon = "__Yuoki__/graphics/entity/signal_pole_icon.png",
		icon_size = 64,
		order = "h",
		group = "yuoki-energy",
		subgroup = "y-electric",
	},

	--ID:297
	{
		type = "recipe",
		name = "y-orange-stuff",
		category = "smelting",
		enabled = true,
		energy_required = 3.00,
		ingredients = {
			{ type = "item", name = "y-richdust", amount = 3.0 },
		},
		results = {
			{ type = "item", name = "y-orange-stuff", amount = 2.0 },
		},
		main_product = "y-orange-stuff",
		icon = "__Yuoki__/graphics/icons/orange_stuff_icon.png",
		icon_size = 64,
		order = "m-refined-x2",
		group = "yuoki",
		subgroup = "yuoki-formpress",
	},

	--ID:296
	{
		type = "recipe",
		name = "y-conductive-wire-1",
		category = "crafting",
		enabled = true,
		energy_required = 2.00,
		ingredients = {
			{ type = "item", name = "y-orange-stuff", amount = 1.0 },
			{ type = "item", name = "copper-plate", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "y-conductive-wire-1", amount = 4.0 },
		},
		main_product = "y-conductive-wire-1",
		icon = "__Yuoki__/graphics/icons/wire_1.png",
		icon_size = 64,
		order = "pe6",
		group = "yuoki",
		subgroup = "y_parts_e",
	},

	--ID:295
	{
		type = "recipe",
		name = "y_structure_electric",
		category = "crafting",
		enabled = true,
		energy_required = 4.00,
		ingredients = {
			{ type = "item", name = "y_structure_element", amount = 2.0 },
			{ type = "item", name = "y-conductive-wire-1", amount = 4.0 },
			{ type = "item", name = "plastic-bar", amount = 2.0 },
		},
		results = {
			{ type = "item", name = "y_structure_electric", amount = 2.0 },
		},
		main_product = "y_structure_electric",
		icon = "__Yuoki__/graphics/icons/caseing-n4wCable_icon.png",
		icon_size = 64,
		order = "p-g2a",
		group = "yuoki",
		subgroup = "y-parts",
	},

	--ID:245
	{
		type = "recipe",
		name = "y_tile_slagbricks",
		category = "yuoki-formpress",
		enabled = true,
		energy_required = 2.00,
		ingredients = {
			{ type = "item", name = "y_slag_brick", amount = 2.0 },
			{ type = "item", name = "y_slag_granulate", amount = 4.0 },
		},
		results = {
			{ type = "item", name = "y_tile_slagbricks", amount = 4.0 },
		},
		main_product = "y_tile_slagbricks",
		icon = "__Yuoki__/graphics/entity/path_tiles/bricks_3.png",
		icon_size = 64,
		order = "c",
		group = "yuoki-energy",
		subgroup = "y_tiles",
	},

	--ID:244
	{
		type = "recipe",
		name = "y_tile_slagpattern",
		category = "yuoki-formpress",
		enabled = true,
		energy_required = 2.00,
		ingredients = {
			{ type = "item", name = "y_slag_brick", amount = 3.0 },
		},
		results = {
			{ type = "item", name = "y_tile_slagpattern", amount = 2.0 },
		},
		main_product = "y_tile_slagpattern",
		icon = "__Yuoki__/graphics/entity/path_tiles/muster_2.png",
		icon_size = 64,
		order = "b",
		group = "yuoki-energy",
		subgroup = "y_tiles",
	},

	--ID:243
	{
		type = "recipe",
		name = "y_tile_slagfilled",
		category = "yuoki-formpress",
		enabled = true,
		energy_required = 2.00,
		ingredients = {
			{ type = "item", name = "y-slag", amount = 4.0 },
		},
		results = {
			{ type = "item", name = "y_tile_slagfilled", amount = 2.0 },
		},
		main_product = "y_tile_slagfilled",
		icon = "__Yuoki__/graphics/entity/path_tiles/pslag_icon.png",
		icon_size = 64,
		order = "a",
		group = "yuoki-energy",
		subgroup = "y_tiles",
	},

	--ID:242
	{
		type = "recipe",
		name = "y_slag_brick_burn",
		category = "smelting",
		enabled = true,
		energy_required = 3.00,
		ingredients = {
			{ type = "item", name = "y_slag_brick", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "stone-brick", amount = 1.0 },
		},
		main_product = "stone-brick",
		icon = "__Yuoki__/graphics/icons/slag_brick_burn_recipe_64.png",
		icon_size = 64,
		order = "m",
		group = "yuoki",
		subgroup = "yuoki-formpress",
	},

	--ID:241
	{
		type = "recipe",
		name = "y_slag_brick",
		category = "yuoki-formpress",
		enabled = true,
		energy_required = 3.00,
		ingredients = {
			{ type = "item", name = "y_slag_granulate", amount = 5.0 },
		},
		results = {
			{ type = "item", name = "y_slag_brick", amount = 1.0 },
		},
		main_product = "y_slag_brick",
		icon = "__Yuoki__/graphics/icons/slag_brick_64.png",
		icon_size = 64,
		order = "l",
		group = "yuoki",
		subgroup = "y_line4",
	},

	--ID:240
	{
		type = "recipe",
		name = "y_slag_granulate",
		category = "y-crushing",
		enabled = true,
		energy_required = 3.00,
		ingredients = {
			{ type = "item", name = "y-slag", amount = 2.0 },
		},
		results = {
			{ type = "item", name = "y_slag_granulate", amount = 8.0 },
		},
		main_product = "y_slag_granulate",
		icon = "__Yuoki__/graphics/icons/dust_slag.png",
		icon_size = 64,
		order = "k",
		group = "yuoki",
		subgroup = "y_line3",
	},

	--ID:239
	{
		type = "recipe",
		name = "y_hps_steel",
		category = "yuoki_smelter_recipe",
		enabled = true,
		energy_required = 3.00,
		ingredients = {
			{ type = "fluid", name = "water", amount = 10.0 },
			{ type = "item", name = "y_block_heat", amount = 1.0 },
			{ type = "item", name = "y-pure-iron", amount = 14.0 },
		},
		results = {
			{ type = "item", name = "steel-plate", amount = 6.0 },
			{ type = "item", name = "y_block_cold", amount = 1.0, ignored_by_stats = 1, ignored_by_productivity = 1 },
			{ type = "item", name = "y-slag", amount = 8.0 },
		},
		main_product = "steel-plate",
		icon = "__Yuoki__/graphics/icons/stahl_recipe.png",
		icon_size = 64,
		order = "0",
		group = "yuoki",
		subgroup = "yuoki-formpress",
	},

	--ID:238
	{
		type = "recipe",
		name = "y_hps_purecopper",
		category = "yuoki_smelter_recipe",
		enabled = true,
		energy_required = 3.00,
		ingredients = {
			{ type = "item", name = "y_block_heat", amount = 1.0 },
			{ type = "fluid", name = "water", amount = 10.0 },
			{ type = "item", name = "y-pure-copper", amount = 9.0 },
		},
		results = {
			{ type = "item", name = "y_block_cold", amount = 1.0, ignored_by_stats = 1, ignored_by_productivity = 1 },
			{ type = "item", name = "copper-plate", amount = 18.0 },
			{ type = "item", name = "y-slag", amount = 4.0 },
		},
		main_product = "copper-plate",
		icon = "__Yuoki__/graphics/icons/copper_recipe.png",
		icon_size = 64,
		order = "0",
		group = "yuoki",
		subgroup = "yuoki-formpress",
	},

	--ID:237
	{
		type = "recipe",
		name = "y_hps_pureiron",
		category = "yuoki_smelter_recipe",
		enabled = true,
		energy_required = 3.00,
		ingredients = {
			{ type = "fluid", name = "water", amount = 10.0 },
			{ type = "item", name = "y-pure-iron", amount = 9.0 },
			{ type = "item", name = "y_block_heat", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "y_block_cold", amount = 1.0, ignored_by_stats = 1, ignored_by_productivity = 1 },
			{ type = "item", name = "y-slag", amount = 4.0 },
			{ type = "item", name = "iron-plate", amount = 18.0 },
		},
		main_product = "iron-plate",
		icon = "__Yuoki__/graphics/icons/plates_recipe.png",
		icon_size = 64,
		order = "0",
		group = "yuoki",
		subgroup = "yuoki-formpress",
	},

	--ID:236
	{
		type = "recipe",
		name = "y_block_heat",
		category = "yuoki_charger_recipe",
		enabled = true,
		energy_required = 5.00,
		ingredients = {
			{ type = "item", name = "y_block_cold", amount = 10.0 },
			{ type = "item", name = "y-richdust", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "y_block_heat", amount = 10.0 },
		},
		main_product = "y_block_heat",
		icon = "__Yuoki__/graphics/entity/block_heat_icon.png",
		icon_size = 64,
		order = "t",
		group = "yuoki",
		subgroup = "y_parts_e",
		allow_quality = false,
		auto_recycle = false,
	},

	--ID:235
	{
		type = "recipe",
		name = "y_block_cold",
		category = "yuoki-formpress",
		enabled = true,
		energy_required = 4.00,
		ingredients = {
			{ type = "item", name = "y-raw-fuelnium", amount = 2.0 },
			{ type = "item", name = "y_structure_element", amount = 6.0 },
			{ type = "item", name = "y-richdust", amount = 3.0 },
		},
		results = {
			{ type = "item", name = "y_block_cold", amount = 1.0 },
		},
		main_product = "y_block_cold",
		icon = "__Yuoki__/graphics/entity/block_cold_icon.png",
		icon_size = 64,
		order = "s",
		group = "yuoki",
		subgroup = "y_parts_e",
		allow_quality = false,
		auto_recycle = false,
	},

	--ID:234
	{
		type = "recipe",
		name = "y_smelter",
		category = "crafting",
		enabled = true,
		energy_required = 5.00,
		ingredients = {
			{ type = "item", name = "y-basic-t2-mf", amount = 2.0 },
			{ type = "item", name = "y_rwtechsign", amount = 300.0 },
			{ type = "item", name = "y_structure_vessel", amount = 4.0 },
			{ type = "item", name = "y-chip-2", amount = 2.0 },
		},
		results = {
			{ type = "item", name = "y_smelter", amount = 1.0 },
		},
		main_product = "y_smelter",
		icon = "__Yuoki__/graphics/entity/smelter_icon.png",
		icon_size = 64,
		order = "t",
		group = "yuoki",
		subgroup = "y_line1b",
	},

	--ID:233
	{
		type = "recipe",
		name = "y_charger",
		category = "crafting",
		enabled = true,
		energy_required = 5.00,
		ingredients = {
			{ type = "item", name = "y-basic-t1-mf", amount = 1.0 },
			{ type = "item", name = "y_crystal2_combined", amount = 75.0 },
			{ type = "item", name = "y_structure_vessel", amount = 8.0 },
			{ type = "item", name = "y_gauge", amount = 8.0 },
		},
		results = {
			{ type = "item", name = "y_charger", amount = 1.0 },
		},
		main_product = "y_charger",
		icon = "__Yuoki__/graphics/entity/charger_icon.png",
		icon_size = 64,
		order = "s",
		group = "yuoki",
		subgroup = "y_line1b",
	},

	--ID:232
	{
		type = "recipe",
		name = "ypfw_trader_sign",
		category = "yuoki_trader_ultimate",
		enabled = true,
		energy_required = 30.00,
		ingredients = {},
		results = {
			{ type = "item", name = "ypfw_trader_sign", amount = 1.0 },
		},
		main_product = "ypfw_trader_sign",
		icon = "__Yuoki__/graphics/icons/sign_trader_icon.png",
		icon_size = 64,
		order = "a",
		group = "yuoki",
		subgroup = "y-stargate-4",
	},

	--ID:230
	{
		type = "recipe",
		name = "y_greensign_ulti",
		category = "yuoki_green_ultimate",
		enabled = true,
		energy_required = 30.00,
		ingredients = {},
		results = {
			{ type = "item", name = "y_greensign", amount = 1.0 },
		},
		main_product = "y_greensign",
		icon = "__Yuoki__/graphics/icons/sign_green_icon.png",
		icon_size = 64,
		order = "d1",
		group = "yuoki-energy",
		subgroup = "y_ultimate_products",
	},

	--ID:222
	{
		type = "recipe",
		name = "y_exchange_b1",
		category = "yuoki-stargate",
		enabled = true,
		energy_required = 1.00,
		ingredients = {
			{ type = "item", name = "y_greensign", amount = 200.0 },
		},
		results = {
			{ type = "item", name = "y-fame", amount = 1.0 },
		},
		main_product = "y-fame",
		icons = yi.lib.recipe.atomics.item_down("y_greensign"),
		order = "b1",
		group = "yuoki-atomics",
		subgroup = "y-stargate-f",
		auto_recycle = false,
	},

	--ID:220
	{
		type = "recipe",
		name = "y_exchange_b4",
		category = "yuoki-stargate",
		enabled = true,
		energy_required = 1.00,
		ingredients = {
			{ type = "item", name = "ye_science_blue", amount = 100.0 },
		},
		results = {
			{ type = "item", name = "y-fame", amount = 1.0 },
		},
		main_product = "y-fame",
		icons = yi.lib.recipe.atomics.item_down("ye_science_blue"),
		order = "b4",
		group = "yuoki-atomics",
		subgroup = "y-stargate-f",
		auto_recycle = false,
	},

	--ID:219
	{
		type = "recipe",
		name = "y_exchange_b3",
		category = "yuoki-stargate",
		enabled = true,
		energy_required = 1.00,
		ingredients = {
			{ type = "item", name = "y_rwtechsign", amount = 2000.0 },
		},
		results = {
			{ type = "item", name = "y-fame", amount = 1.0 },
		},
		main_product = "y-fame",
		icons = yi.lib.recipe.atomics.item_down("y_rwtechsign"),
		order = "b3",
		group = "yuoki-atomics",
		subgroup = "y-stargate-f",
		auto_recycle = false,
	},

	--ID:218
	{
		type = "recipe",
		name = "y_exchange_b2",
		category = "yuoki-stargate",
		enabled = true,
		energy_required = 1.00,
		ingredients = {
			{ type = "item", name = "ypfw_trader_sign", amount = 1000.0 },
		},
		results = {
			{ type = "item", name = "y-fame", amount = 1.0 },
		},
		main_product = "y-fame",
		icons = yi.lib.recipe.atomics.item_down("ypfw_trader_sign"),
		order = "b2",
		group = "yuoki-atomics",
		subgroup = "y-stargate-f",
		auto_recycle = false,
	},

	--ID:178
	{
		type = "recipe",
		name = "yi_slayerfame",
		category = "yuoki-stargate",
		enabled = true,
		energy_required = 5.00,
		ingredients = {
			{ type = "item", name = "ypfw_trader_sign", amount = 500.0 },
		},
		results = {
			{ type = "item", name = "y-fame", amount = 1.0 },
		},
		main_product = "y-fame",
		icon = "__Yuoki__/graphics/icons/fame-icon.png",
		icon_size = 64,
		order = "a",
		group = "yuoki-atomics",
		subgroup = "y-stargate-f",
		auto_recycle = false,
	},

	--ID:151
	{
		type = "recipe",
		name = "yi_construction-robot",
		category = "crafting",
		enabled = true,
		energy_required = 4.00,
		ingredients = {
			{ type = "item", name = "y-infused-uca2", amount = 1.0 },
			{ type = "item", name = "y_structure_element", amount = 3.0 },
			{ type = "item", name = "construction-robot", amount = 1.0 },
			{ type = "item", name = "yi_magnetron", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "yi_construction-robot", amount = 1.0 },
			{ type = "item", name = "ypfw_trader_sign", amount = 1.0 },
		},
		main_product = "yi_construction-robot",
		icon = "__Yuoki__/graphics/icons/rob_con_icon.png",
		icon_size = 64,
		order = "d",
		group = "yuoki",
		subgroup = "j-y-logi-9",
	},
	-- Construction 2 bot - (JATMN)
	{
		type = "recipe",
		name = "j_construction2-robot",
		category = "crafting",
		enabled = true,
		energy_required = 240,
		ingredients = {
			{ type = "item", name = "y-crystal-cnd", amount = 1.0 },
			{ type = "item", name = "y-basic-t2-mf", amount = 4.0 },
			{ type = "item", name = "yi_construction-robot", amount = 5.0 },
			{ type = "item", name = "y-chip-2", amount = 2.0 },
		},
		results = {
			{ type = "item", name = "j_construction2-robot", amount = 1.0 },
			{ type = "item", name = "ye_science_blue", amount = 1.0 },
		},
		main_product = "j_construction2-robot",
		icons = {
			{
				icon = "__Yuoki__/graphics/icons/rob_con_icon.png",
				tint = { r = 224 / 255, g = 158 / 255, b = 158 / 255 },
			},
		},
		icon_size = 64,
		order = "d",
		group = "yuoki",
		subgroup = "j-y-logi-9",
	},

	--ID:150
	{
		type = "recipe",
		name = "yi_logistic-robot",
		category = "crafting",
		enabled = true,
		energy_required = 4.00,
		ingredients = {
			{ type = "item", name = "y-infused-uca2", amount = 1.0 },
			{ type = "item", name = "y_structure_element", amount = 3.0 },
			{ type = "item", name = "logistic-robot", amount = 1.0 },
			{ type = "item", name = "yi_magnetron", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "yi_logistic-robot", amount = 1.0 },
			{ type = "item", name = "ypfw_trader_sign", amount = 1.0 },
		},
		main_product = "yi_logistic-robot",
		icon = "__Yuoki__/graphics/icons/rob_log_icon.png",
		icon_size = 64,
		order = "a",
		group = "yuoki",
		subgroup = "j-y-logi-9",
	},
	-- logistics 2 bot - (JATMN)
	{
		type = "recipe",
		name = "j_logistic2-robot",
		category = "crafting",
		enabled = true,
		energy_required = 240,
		ingredients = {
			{ type = "item", name = "y-crystal-cnd", amount = 1.0 },
			{ type = "item", name = "y-basic-t2-mf", amount = 4.0 },
			{ type = "item", name = "yi_logistic-robot", amount = 5.0 },
			{ type = "item", name = "y-chip-2", amount = 2.0 },
		},
		results = {
			{ type = "item", name = "j_logistic2-robot", amount = 1.0 },
			{ type = "item", name = "ye_science_blue", amount = 1.0 },
		},
		main_product = "j_logistic2-robot",
		icon = "__Yuoki__/graphics/icons/j_logistic2-robot_icon.png",
		icon_size = 64,
		order = "a2",
		group = "yuoki",
		subgroup = "j-y-logi-9",
	},

	--ID:116
	{
		type = "recipe",
		name = "y_gauge_analog",
		category = "crafting",
		enabled = true,
		energy_required = 2.00,
		ingredients = {
			{ type = "item", name = "y_structure_vessel", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "y_gauge", amount = 1.0 },
		},
		main_product = "y_gauge",
		icon = "__Yuoki__/graphics/icons/gauge.png",
		icon_size = 64,
		order = "0",
		group = "yuoki_liquids",
		subgroup = "y_refine_parts",
	},

	--ID:115
	{
		type = "recipe",
		name = "y_flowcheck_10",
		category = "crafting",
		enabled = true,
		energy_required = 2.00,
		ingredients = {
			{ type = "item", name = "y_gauge", amount = 1.0 },
			{ type = "item", name = "y_structure_vessel", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "y_flowcheck_10", amount = 1.0 },
		},
		main_product = "y_flowcheck_10",
		icon = "__Yuoki__/graphics/icons/flow_indicator_icon.png",
		icon_size = 64,
		order = "0",
		group = "yuoki_liquids",
		subgroup = "y_refine_parts",
	},

	--ID:106
	{
		type = "recipe",
		name = "y_quantrinum_infusion",
		category = "yuoki-alien",
		enabled = true,
		energy_required = 60.00,
		ingredients = {
			{ type = "item", name = "y-quantrinum", amount = 1.0 },
			{ type = "item", name = "y-crystal-cnd", amount = 1.0 },
			{ type = "item", name = "y-unicomp-a2", amount = 5.0 },
		},
		results = {
			{ type = "item", name = "y_quantrinum_infused", amount = 1.0 },
			{ type = "item", name = "ye_science_blue", amount = 1.0 },
		},
		main_product = "y_quantrinum_infused",
		icon = "__Yuoki__/graphics/icons/quantrinum_charged_icon.png",
		icon_size = 64,
		order = "0",
		group = "vanilla",
		subgroup = "y-tech",
		allow_quality = true,
	},

	--ID:105 for recipes that uses research
	{
		type = "recipe",
		name = "y_data_crystal",
		category = "yuoki-wonder",
		enabled = true,
		energy_required = 8.00,
		ingredients = {
			{ type = "item", name = "y-crystal2", amount = 20.0 },
			{ type = "item", name = "logistic-science-pack", amount = 5.0 },
		},
		results = {
			{ type = "item", name = "y_crystal2_combined", amount = 1.0 },
		},
		main_product = "y_crystal2_combined",
		icon = "__Yuoki__/graphics/icons/blue_style.png",
		icon_size = 64,
		order = "0",
		group = "vanilla",
		subgroup = "y-tech",
	},

	--ID:87
	{
		type = "recipe",
		name = "y_ft",
		category = "chemistry",
		enabled = true,
		energy_required = 5.00,
		ingredients = {
			{ type = "fluid", name = "y_syngas_raw", amount = 140.0 },
			{ type = "item", name = "y_catalyst_ft", amount = 1.0 },
		},
		results = {
			{ type = "fluid", name = "light-oil", amount = 10.0 },
			{ type = "fluid", name = "petroleum-gas", amount = 30.0 },
			{ type = "item", name = "y_usedcatalyst", amount = 1.0 },
		},
		main_product = "light-oil",
		icon = "__Yuoki__/graphics/icons/ctl_ft_32.png",
		icon_size = 64,
		order = "c2",
		group = "yuoki_liquids",
		subgroup = "y-fluid",
	},

	--ID:86
	{
		type = "recipe",
		name = "y_rawsyngas2",
		category = "chemistry",
		enabled = true,
		energy_required = 1.50,
		ingredients = {
			{ type = "item", name = "y_organic_dust", amount = 4.0 },
		},
		results = {
			{ type = "fluid", name = "y_syngas_raw", amount = 20.0 },
		},
		main_product = "y_syngas_raw",
		icon = "__Yuoki__/graphics/icons/obs/h2o_c_icon.png",
		icon_size = 64,
		order = "c4",
		group = "yuoki_liquids",
		subgroup = "y-fluid",
	},

	--ID:83
	{
		type = "recipe",
		name = "y_regcatft",
		category = "chemistry",
		enabled = true,
		energy_required = 3.00,
		ingredients = {
			{ type = "item", name = "y_usedcatalyst", amount = 10.0 },
			{ type = "item", name = "y-richdust", amount = 2.0 },
		},
		results = {
			{ type = "item", name = "y_catalyst_ft", amount = 10.0 },
		},
		main_product = "y_catalyst_ft",
		icon = "__Yuoki__/graphics/icons/icon_regftcat32.png",
		icon_size = 64,
		order = "bb",
		group = "yuoki_liquids",
		subgroup = "y_refine_material",
	},

	--ID:82
	{
		type = "recipe",
		name = "y_regcatbp",
		category = "chemistry",
		enabled = true,
		energy_required = 3.00,
		ingredients = {
			{ type = "item", name = "y_usedcatalyst", amount = 10.0 },
			{ type = "item", name = "y-unicomp-a2", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "y_catalyst_bp", amount = 10.0 },
		},
		main_product = "y_catalyst_bp",
		icon = "__Yuoki__/graphics/icons/icon_regbpcat28.png",
		icon_size = 64,
		order = "ba",
		group = "yuoki_liquids",
		subgroup = "y_refine_material",
	},

	--ID:81
	{
		type = "recipe",
		name = "y_coal2liquid",
		category = "chemistry",
		enabled = true,
		energy_required = 5.00,
		ingredients = {
			{ type = "fluid", name = "y_hydrogen", amount = 20.0 },
			{ type = "item", name = "y-coal-dust", amount = 10.0 },
			{ type = "item", name = "y_catalyst_bp", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "y_usedcatalyst", amount = 1.0 },
			{ type = "fluid", name = "crude-oil", amount = 10.0 },
		},
		main_product = "y_usedcatalyst",
		icon = "__Yuoki__/graphics/icons/ctl_b32.png",
		icon_size = 64,
		order = "c1",
		group = "yuoki_liquids",
		subgroup = "y-fluid",
	},

	--ID:80
	{
		type = "recipe",
		name = "y_refinehydrogen",
		category = "chemistry",
		enabled = true,
		energy_required = 3,
		ingredients = {
			{ type = "fluid", name = "y_syngas_raw", amount = 60.0 },
			{ type = "fluid", name = "water", amount = 60.0 },
		},
		results = {
			{ type = "fluid", name = "y_hydrogen", amount = 50.0 },
			{ type = "fluid", name = "petroleum-gas", amount = 10.0 },
		},
		main_product = "y_hydrogen",
		icon = "__Yuoki__/graphics/icons/obs/hydrogen_i32.png",
		icon_size = 64,
		order = "d",
		group = "yuoki_liquids",
		subgroup = "y-fluid",
	},

	--ID:79
	{
		type = "recipe",
		name = "y_rawsyngas1",
		category = "chemistry",
		enabled = true,
		energy_required = 1.50,
		ingredients = {
			{ type = "item", name = "y-coal-dust", amount = 1.0 },
		},
		results = {
			{ type = "fluid", name = "y_syngas_raw", amount = 10.0 },
		},
		main_product = "y_syngas_raw",
		icon = "__Yuoki__/graphics/icons/obs/h2o_c_icon.png",
		icon_size = 64,
		order = "c3",
		group = "yuoki_liquids",
		subgroup = "y-fluid",
	},

	--ID:75
	{
		type = "recipe",
		name = "y_catalyst_ft",
		category = "crafting",
		enabled = true,
		energy_required = 3.00,
		ingredients = {
			{ type = "item", name = "y-raw-fuelnium", amount = 1.0 },
			{ type = "item", name = "y-unicomp-raw", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "y_catalyst_ft", amount = 4.0 },
		},
		main_product = "y_catalyst_ft",
		icon = "__Yuoki__/graphics/icons/icon_ftcat32.png",
		icon_size = 64,
		order = "ab",
		group = "yuoki_liquids",
		subgroup = "y_refine_material",
	},

	--ID:74
	{
		type = "recipe",
		name = "y_catalyst_bp",
		category = "crafting",
		enabled = true,
		energy_required = 3.00,
		ingredients = {
			{ type = "item", name = "y-unicomp-raw", amount = 1.0 },
			{ type = "item", name = "y-raw-fuelnium", amount = 1.0 },
			{ type = "item", name = "iron-plate", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "y_catalyst_bp", amount = 1.0 },
		},
		main_product = "y_catalyst_bp",
		icon = "__Yuoki__/graphics/icons/icon_bpcat28.png",
		icon_size = 64,
		order = "aa",
		group = "yuoki_liquids",
		subgroup = "y_refine_material",
	},

	--ID:73
	{
		type = "recipe",
		name = "y_granulate_wood",
		category = "y-crushing",
		enabled = true,
		energy_required = 2.00,
		ingredients = {
			{ type = "item", name = "wood", amount = 1.0 },
		},
		results = {
			{ type = "item", name = "y_organic_dust", amount = 7.0 },
		},
		main_product = "y_organic_dust",
		icon = "__Yuoki__/graphics/icons/sawdust_32.png",
		icon_size = 64,
		order = "0",
		group = "yuoki_liquids",
		subgroup = "y_refine_raws",
	},
})
