data:extend({

	--YI-Basics, Storage, Defense
	{
		type = "item-group",
		name = "yuoki",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/yuoki-ind-icon.png",
		inventory_order = "y",
		order = "yi-a",
	},
	--YI-Energy, Lamps, Fuel
	{
		type = "item-group",
		name = "yuoki-energy",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/yuoki-energy.png",
		inventory_order = "y",
		order = "yi-b",
	},
	--YI-Transmutation & Trade
	{
		type = "item-group",
		name = "yuoki-atomics",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/yuoki-atomics-icon.png",
		inventory_order = "y",
		order = "yi-c",
	},
	--YI-Refinery & Fluids
	{
		type = "item-group",
		name = "yuoki_liquids",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/yuoki-liquids.png",
		inventory_order = "y",
		order = "yi-d",
	},

	-- YI Logistics (JATMN)
	{
		type = "item-group",
		name = "j_yuoki_logistics",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/j_icon_yuoki_logistics.png",
		inventory_order = "y",
		order = "yi-d",
	},

	{ type = "item-subgroup", group = "yuoki", order = "7-c", name = "y-ammo" },
	{ type = "item-subgroup", group = "yuoki", order = "4-e", name = "y-crush" },
	{ type = "item-subgroup", group = "yuoki", order = "7-a", name = "y-defense" },
	{ type = "item-subgroup", group = "yuoki", order = "4-h", name = "y-ore" },
	{ type = "item-subgroup", group = "yuoki", order = "7-a", name = "y-parts" },
	{ type = "item-subgroup", group = "yuoki", order = "4-g", name = "y-raw-material" },
	{ type = "item-subgroup", group = "yuoki", order = "4-f", name = "y-smelting" },
	{ type = "item-subgroup", group = "yuoki", order = "5-c", name = "y-storage" },
	{ type = "item-subgroup", group = "yuoki", order = "a2", name = "y-tools" },
	{ type = "item-subgroup", group = "yuoki", order = "6-a", name = "yuoki-archaeology" },
	{ type = "item-subgroup", group = "yuoki", order = "4-d", name = "yuoki-formpress" },
	{ type = "item-subgroup", group = "yuoki", order = "2-a", name = "y_basic_machinery" },
	{ type = "item-subgroup", group = "yuoki", order = "7-b", name = "y_defense_walls" },
	{ type = "item-subgroup", group = "yuoki", order = "1-a", name = "y_drilling" },
	{ type = "item-subgroup", group = "yuoki", order = "1A", name = "y_line1" },
	{ type = "item-subgroup", group = "yuoki", order = "1B", name = "y_line1b" },
	{ type = "item-subgroup", group = "yuoki", order = "2", name = "y_line2" },
	{ type = "item-subgroup", group = "yuoki", order = "3", name = "y_line3" },
	{ type = "item-subgroup", group = "yuoki", order = "4", name = "y_line4" },
	{ type = "item-subgroup", group = "yuoki", order = "5", name = "y_line5" },
	{ type = "item-subgroup", group = "yuoki", order = "6", name = "y_line6" },
	{ type = "item-subgroup", group = "yuoki", order = "7", name = "y_line7" },
	{ type = "item-subgroup", group = "yuoki", order = "8", name = "y_line8" },
	{ type = "item-subgroup", group = "yuoki", order = "9", name = "y_line9" },
	{ type = "item-subgroup", group = "yuoki", order = "7-a", name = "y_parts_e" },
	{ type = "item-subgroup", group = "yuoki", order = "za", name = "y_tiles" }, --old + new tiles
	{ type = "item-subgroup", group = "yuoki-energy", order = "a2", name = "y-boiler" },
	{ type = "item-subgroup", group = "yuoki-energy", order = "a4", name = "y-e-gens" },
	{ type = "item-subgroup", group = "yuoki-energy", order = "4-c", name = "y-electric" },
	{ type = "item-subgroup", group = "yuoki-energy", order = "4", name = "y-energy" },
	{ type = "item-subgroup", group = "yuoki-energy", order = "4-a", name = "y-energy-2" },
	{ type = "item-subgroup", group = "yuoki-energy", order = "a1", name = "y-fuel" },
	{ type = "item-subgroup", group = "yuoki-energy", order = "2A", name = "y-lamps" },
	{ type = "item-subgroup", group = "yuoki-energy", order = "a5", name = "y-module" },
	{ type = "item-subgroup", group = "yuoki-energy", order = "4-h", name = "y-tech" },
	{ type = "item-subgroup", group = "yuoki-energy", order = "4-b", name = "yuoki-energy-gen" },
	{ type = "item-subgroup", group = "yuoki-energy", order = "4-b", name = "yuoki_energy_gen_steam" },
	{ type = "item-subgroup", group = "yuoki-energy", order = "y", name = "y_erfolge" }, --Statuen
	{ type = "item-subgroup", group = "yuoki-energy", order = "2B", name = "y_lamps_deco" },
	{ type = "item-subgroup", group = "yuoki-energy", order = "xx", name = "y_mastercrafted" }, --mastercrafted
	{ type = "item-subgroup", group = "yuoki-energy", order = "xa", name = "y_personal" }, --Ausr�stung
	{ type = "item-subgroup", group = "yuoki-energy", order = "xb", name = "y_personal_equip" }, --Power Armor Equipment
	{ type = "item-subgroup", group = "yuoki-energy", order = "a6", name = "y_ultimate_products" },
	{ type = "item-subgroup", group = "yuoki-atomics", order = "1c", name = "y-atomics" },
	{ type = "item-subgroup", group = "yuoki-atomics", order = "1a", name = "y-atomics-f" },
	{ type = "item-subgroup", group = "yuoki-atomics", order = "1b", name = "y-atomics-r" },
	{ type = "item-subgroup", group = "yuoki-atomics", order = "2-0", name = "y-stargate" },
	{ type = "item-subgroup", group = "yuoki-atomics", order = "2-1", name = "y-stargate-1" },
	{ type = "item-subgroup", group = "yuoki-atomics", order = "2-2", name = "y-stargate-2" },
	{ type = "item-subgroup", group = "yuoki-atomics", order = "2-3", name = "y-stargate-3" },
	{ type = "item-subgroup", group = "yuoki-atomics", order = "2-4", name = "y-stargate-4" },
	{ type = "item-subgroup", group = "yuoki-atomics", order = "2-6", name = "y-stargate-f" }, --fame
	{ type = "item-subgroup", group = "yuoki-atomics", order = "2-5", name = "y-stargate-r" },
	{ type = "item-subgroup", group = "yuoki_liquids", order = "3-a", name = "y-fluid" }, --alte Rezepte
	{ type = "item-subgroup", group = "yuoki_liquids", order = "3-c", name = "y-fluid-storage" },
	{ type = "item-subgroup", group = "yuoki_liquids", order = "3-b", name = "y-pipe" },
	{ type = "item-subgroup", group = "yuoki_liquids", order = "5-a", name = "y_refine_machinery" }, --machinery to refine/handle fluids
	{ type = "item-subgroup", group = "yuoki_liquids", order = "5-b", name = "y_refine_material" }, --for materials
	{ type = "item-subgroup", group = "yuoki_liquids", order = "3-d", name = "y_refine_parts" }, --Mechanical Parts
	{ type = "item-subgroup", group = "yuoki_liquids", order = "5-c", name = "y_refine_raws" }, --base materials

	-- YI Logistics (JATMN)
	{ type = "item-subgroup", group = "j_yuoki_logistics", order = "1a", name = "j-y-logi-1" },
	{ type = "item-subgroup", group = "j_yuoki_logistics", order = "1b", name = "j-y-logi-2" },
	{ type = "item-subgroup", group = "j_yuoki_logistics", order = "1c", name = "j-y-logi-3" },
	{ type = "item-subgroup", group = "j_yuoki_logistics", order = "1d", name = "j-y-logi-4" },
	{ type = "item-subgroup", group = "j_yuoki_logistics", order = "1e", name = "j-y-logi-5" },
	{ type = "item-subgroup", group = "j_yuoki_logistics", order = "1e", name = "j-y-logi-6" },
	{ type = "item-subgroup", group = "j_yuoki_logistics", order = "1e", name = "j-y-logi-7" },
	{ type = "item-subgroup", group = "j_yuoki_logistics", order = "1e", name = "j-y-logi-8" },
	{ type = "item-subgroup", group = "j_yuoki_logistics", order = "1e", name = "j-y-logi-9" },

	-- Atomic's New Sub Groups to re-arrange the crafting menu!
	-- The unused subgroups are for future use with optional proliferation mode(s) coming soon(tm)
	-- (JATMN)
	{ type = "item-subgroup", group = "yuoki-atomics", order = "1a", name = "j-y-atomics-1" }, -- Unicomp 2 Unicomp
	{ type = "item-subgroup", group = "yuoki-atomics", order = "1b", name = "j-y-atomics-2" }, -- Vanilla solid resources to Unicomp
	{ type = "item-subgroup", group = "yuoki-atomics", order = "1c", name = "j-y-atomics-3" }, -- Space Age solid resources to Unicomp
	{ type = "item-subgroup", group = "yuoki-atomics", order = "1d", name = "j-y-atomics-4" }, -- Integration Overhaul mods solid resources to Unicomp
	{ type = "item-subgroup", group = "yuoki-atomics", order = "1e", name = "j-y-atomics-5" }, -- Yuoki Crafted resources to Unicomp
	{ type = "item-subgroup", group = "yuoki-atomics", order = "1f", name = "j-y-atomics-6" },
	{ type = "item-subgroup", group = "yuoki-atomics", order = "1g", name = "j-y-atomics-7" }, -- Vanilla liquid resources to Unicomp
	{ type = "item-subgroup", group = "yuoki-atomics", order = "1h", name = "j-y-atomics-8" }, -- Space Age liquid resources to Unicomp
	{ type = "item-subgroup", group = "yuoki-atomics", order = "1i", name = "j-y-atomics-9" }, -- Integration Overhaul mods liquid resources to Unicomp
	{ type = "item-subgroup", group = "yuoki-atomics", order = "1j", name = "j-y-atomics-10" },
	{ type = "item-subgroup", group = "yuoki-atomics", order = "1j", name = "j-y-atomics-11" }, -- Vanilla solid resources from Unicomp
	{ type = "item-subgroup", group = "yuoki-atomics", order = "1j", name = "j-y-atomics-12" }, -- Space Age solid resources from Unicomp
	{ type = "item-subgroup", group = "yuoki-atomics", order = "1j", name = "j-y-atomics-13" }, -- Integration Overhaul mods solid resources from Unicomp
	{ type = "item-subgroup", group = "yuoki-atomics", order = "1j", name = "j-y-atomics-14" }, -- Vanilla liquid resources from Unicomp
	{ type = "item-subgroup", group = "yuoki-atomics", order = "1j", name = "j-y-atomics-15" }, -- Integration Overhaul mods liquid resources from Unicomp
	{ type = "item-subgroup", group = "yuoki-atomics", order = "1j", name = "j-y-atomics-16" }, -- Vanilla Crafted resources from Unicomp
	{ type = "item-subgroup", group = "yuoki-atomics", order = "1j", name = "j-y-atomics-17" },
	{ type = "item-subgroup", group = "yuoki-atomics", order = "1j", name = "j-y-atomics-18" },
	{ type = "item-subgroup", group = "yuoki-atomics", order = "1j", name = "j-y-atomics-19" },
	{ type = "item-subgroup", group = "yuoki-atomics", order = "1j", name = "j-y-atomics-20" },

	{ type = "recipe-category", name = "y-crushing" }, --
	{ type = "recipe-category", name = "yrcat_crystalize" }, --
	{ type = "recipe-category", name = "yrcat_emulsion" }, --
	{ type = "recipe-category", name = "yrcat_hppump" }, --
	{ type = "recipe-category", name = "yrcat_mfheatmotor_m" }, --
	{ type = "recipe-category", name = "yrcat_refine_a" }, --gas reformer
	{ type = "recipe-category", name = "yrcat_refine_b" }, --Phase Reactor
	{ type = "recipe-category", name = "yrcat_refine_c" }, --sulfur extractor
	{ type = "recipe-category", name = "yrcat_refine_d" }, --vergaser
	{ type = "recipe-category", name = "yrcat_trockner" }, --
	{ type = "recipe-category", name = "yuoki-alien" }, --infuser ?
	{ type = "recipe-category", name = "yuoki-archaeology" }, --
	{ type = "recipe-category", name = "yuoki-archaeology-wash" }, --
	{ type = "recipe-category", name = "yuoki-atomics" }, --
	{ type = "recipe-category", name = "yuoki-defense" }, --
	{ type = "recipe-category", name = "yuoki-energy" }, --
	{ type = "recipe-category", name = "yuoki-fame" }, --
	{ type = "recipe-category", name = "yuoki-formpress" }, --
	{ type = "recipe-category", name = "yuoki-pipe" }, --
	{ type = "recipe-category", name = "yuoki-raw-material" }, --
	{ type = "recipe-category", name = "yuoki-repair" }, --repair stuff
	{ type = "recipe-category", name = "yuoki-stargate" }, --stargate-trades
	{ type = "recipe-category", name = "yuoki-watergen" }, --
	{ type = "recipe-category", name = "yuoki-wonder" }, --
	{ type = "recipe-category", name = "yuoki_charger_recipe" }, --
	{ type = "recipe-category", name = "yuoki_green_ultimate" }, --Green-Ultimates
	{ type = "recipe-category", name = "yuoki_mf" }, --reactor-recipes 2019
	{ type = "recipe-category", name = "yuoki_mox" }, --fuel-mixer
	{ type = "recipe-category", name = "yuoki_science_ultimate" }, --Science-Ultimate
	{ type = "recipe-category", name = "yuoki_smelter_recipe" }, --
	{ type = "recipe-category", name = "yuoki_tech_ultimate" }, --Tech-Ultimates
	{ type = "recipe-category", name = "yuoki_trader_ultimate" }, --Trader-Ultimates
})
