-- Paranoidal fork: Yuoki/Engines content removed by user decision 2026-10-24 (start-game trivia, duplicates of
-- the build, worse than the build). Every prototype with one of these names is deleted at the end of data.lua.
return {
	-- inserters
	"y-inserter-fast", "y-inserter-s4", "y-inserter-smart", "y-inserter-smart-long", "y_inserter_diagonal",
	"y_inserter_evade_shortL", "y_inserter_evade_shortR", "y_inserter_smart_LL", "y_inserter_smart_RR",
	"y_inserter_smart_leftR2", "y_inserter_smart_rightR2",
	-- lamps and the owner's monument
	"y-powerlamp", "y-tinylamp", "yi-monument1", "y_lampe_44basement_a", "y_lampe_44basement_b", "y_lampe_66basement",
	"y_lampe_corner", "y_lampe_neotix", "y_lampe_yuoki", "y_old_bodenlampe",
	-- walls (the Vitduo force field stays), tiles, slag bricks
	"y-mud-wall", "y-rare-wall-adv", "y-rare-wall-basic", "y_wall22_hardic", "y_wood_wall", "y_tile_blue",
	"y_tile_slagbricks", "y_tile_slagfilled", "y_tile_slagpattern", "y_tile_slagstones", "y_slag_brick",
	"y_slag_granulate", "y_slag_brick_burn",
	-- storage
	"y_c22", "y_cg33", "y_sc11", "y_sc44", "y-rare-chest-log", "y-rare-m1bunker-log", "y_pc22", "y_rc22", "y_bc22",
	"j-dl-buffer", "j-dl-provider", "j-dl-request",
	-- basic accumulators (the Bob accumulators take their place in the Yuoki chain)
	"y-accumulator-m", "y-accumulator-b",
	-- tanks, pipes, poles (the AEET station stays)
	"y-tank-1000", "y-tank-4500", "y-tank-8000", "y_flowcheck_10", "y_mftank", "y-pipe-ec", "y-pipe-h", "y-pipe-hc",
	"y-pipe-v", "yi_pipe_green", "y-pipe-to-ground-ec", "y-pipe-to-ground-hc", "yi_pipe_underground_green",
	"y-substation-m", "y_signal_pole",
	-- robots, roboports, radar, beacon, mining drills
	"yi_construction-robot", "yi_logistic-robot", "j_construction2-robot", "j_logistic2-robot", "yi_roboport",
	"j_yi_roboport1", "yi_radar", "yi_beacon", "y-mining-drill", "y-mining-drill-e2", "y_mc_e2_mining_drill",
	-- modules
	"y-green-module-1", "y-green-module-2", "y-pink-module-1", "y-pink-module-2", "y-pink-module-3",
	"y-quality-module-1", "y-speed-module-1", "y-speed-module-2", "y_modul_green_op", "y_modul_red2", "y_modul_science",
	-- personal equipment, guns, bullets, shells, mines
	"yi_equip_battery_a", "yi_equip_generator_a", "yi_equip_legs_a", "yi_equip_roboport", "yi_equip_shield_a",
	"yi_equip_shield_b", "yi_pld_equipment", "yi_minigun", "yi_lasergun", "yi_ammo_energie", "y-ammo-acid-2",
	"y-ammo-biggun", "y-ammo-explosiv", "y-ammo-hohlspitz", "y-ammo-krakon", "y-ammo-poison", "y-bullet-case",
	"yi_cannon_shell", "yi_cannon_shell_projectile", "yi_artillery_shell", "yi_artillery_shell_projectile",
	"yi_mine_impact", "yi_mine_plasma",
	-- transport tubes and the special sheet metal
	"ye_tranport_tube_green", "ye_tranport_tube_green_splitter", "ye_tranport_tube_green_underground",
	"ye_tranport_tube_orange", "ye_tranport_tube_orange_splitter", "ye_tranport_tube_orange_underground",
	"ye_buechsenblech", "yie_import_blech_blau",
	-- canisters (barrels of the build cover them), sealing
	"ye_canister", "ye_can_blood", "ye_can_co", "ye_can_eth", "ye_can_ho", "ye_can_lub", "ye_can_mf", "ye_can_petrol",
	"ye_can_sa", "ye_can_slurry", "ye_can_unicomp", "ye_can_veg", "ye_can_water", "ye_can_cw", "ye_sealing",
	"ye_canister2plates_smelt", "ye_tradeblood", "yie_import_sealing",
	-- water generators, burner-tier crusher and form press, MF water pump
	"y-water-gen", "y-water-gen-e", "y_water_mixer", "y-water-gen-fluid", "y-crusher", "y-heat-form-press",
	"y-mwater-pump", "y-mfwater", "ye_water2mf",
	-- fuel trivia
	"y-coal-brikett", "y-coal-stack", "y-wooden-brikett",
	-- exchanges into vanilla science packs and batteries
	"y_military_science", "y_chemical_science", "y_production_science", "y_high-tech_science", "y_space_science",
	"y-battery-rip1",
	-- JATMN air filters (the Fatmice engine keeps producing fly ash)
	"j-airfilter", "j-airfilter_dirty", "j-airfilter_cleaning",
	-- orphans without producers or consumers
	"y_catalyst_base", "y-slag", "yie_crystal_grey", "ye_crystalite", "ye_ferrotin", "ye_magnalit",
	"ye_liquid_quantrinum", "ye_steam", "yie_refrigerant",
	-- agronomy reduction: smoker, smoked food, extra fish, extra cans, packages and exports, the carnivorous plant
	"ye_smoker", "ye_smoked_meat", "ye_smoked_fish", "ye_fish3", "ye_fish4", "ye_futtermittel_a", "ye_futtermittel_b",
	"ye_buechse_blau", "ye_buechse_braun", "ye_buechse_rosa", "ye_buechse_blau_export", "ye_buechse_fleisch_export",
	"ye_buechse_rosa_export", "ye_package_fish1", "ye_package_spliced_cells", "ye_package_substratin",
	"ye_package_organic", "ye_package_carni", "ye_export01", "ye_export04", "ye_export05", "ye_export06",
	"ye_export_fish1", "ye_plant_carni", "ye_chitrotin", "ye_grow_plant2", "ye_dna_plant4", "ye_grow_fish1",
	-- crystallisation recipes that bypassed the centrifuge (replaced by crystal seeds)
	"y_chunks1", "y_chunks2",
	-- UC-A2 -> chunk recipes (chunks only from the centrifuge)
	"y-ac-uc2y-res1", "y-ac-uc2y-res2",
	-- steam boilers and turbines (user, 2026-10-25): capped at 265-500 °C and 74-90 % they lose to Bob's boilers and
	-- turbines of the same stage; the mastercrafted versions are built from them
	"y-boiler-iv", "y-steam-turbine", "y_boiler4_mc", "y_boiler4_tech", "y_steam_turbine_mc", "y_steam_turbine_gr",
}
