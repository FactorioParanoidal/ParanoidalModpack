local moshine_simulations = "__Moshine-assets__/menu-simulations/"

local menu_sims = data.raw["utility-constants"]["default"].main_menu_simulations

-- Remove Vanilla + Expansion menu simulations
-- Base

--[[
menu_sims.nauvis_solar_power_construction = nil
menu_sims.nauvis_lab = nil
menu_sims.nauvis_burner_city = nil
menu_sims.nauvis_mining_defense = nil
menu_sims.nauvis_forest_fire = nil
menu_sims.nauvis_oil_pumpjacks = nil
menu_sims.nauvis_oil_refinery = nil
menu_sims.nauvis_early_smelting = nil
menu_sims.nauvis_train_station = nil
menu_sims.nauvis_logistic_robots = nil
menu_sims.nauvis_nuclear_power = nil
menu_sims.nauvis_train_junction = nil
menu_sims.nauvis_artillery = nil
menu_sims.nauvis_biter_base_spidertron = nil
menu_sims.nauvis_biter_base_artillery = nil
menu_sims.nauvis_biter_base_laser_defense = nil
menu_sims.nauvis_biter_base_player_attack = nil
menu_sims.nauvis_biter_base_steamrolled = nil
menu_sims.nauvis_chase_player = nil
menu_sims.nauvis_big_defense = nil
menu_sims.nauvis_brutal_defeat = nil
menu_sims.nauvis_spider_ponds = nil
menu_sims.nauvis_uranium_processing = nil
-- Elevated Rails
menu_sims.nauvis_ship_rails = nil
menu_sims.nauvis_river_bridge = nil
menu_sims.nauvis_t_section = nil
-- Space Age
menu_sims.nauvis_biolab = nil
menu_sims.nauvis_tank_building = nil
menu_sims.nauvis_power_up = nil
menu_sims.nauvis_bus = nil
menu_sims.platform_science = nil
menu_sims.platform_moving = nil
menu_sims.platform_messy_nuclear = nil
menu_sims.vulcanus_lava_forge = nil
menu_sims.vulcanus_crossing = nil
menu_sims.vulcanus_punishmnent = nil
menu_sims.vulcanus_sulfur_drop = nil
menu_sims.gleba_agri_towers = nil
menu_sims.gleba_pentapod_ponds = nil
menu_sims.gleba_egg_escape = nil
menu_sims.gleba_farm_attack = nil
menu_sims.gleba_grotto = nil
menu_sims.fulgora_city_crossing = nil
menu_sims.fulgora_recycling_hell = nil
menu_sims.fulgora_nightfall = nil
menu_sims.fulgora_race = nil
menu_sims.aquilo_send_help = nil
menu_sims.aquilo_starter = nil
menu_sims.nauvis_rocket_factory = nil
]]


menu_sims.moshine_snouz1 = { --neural computer
  checkboard = false,
  game_view_settings = {default_show_value = false, show_shortcut_bar = false, show_quickbar = false, show_tool_bar = false},
  init_update_count = 60,
  save = moshine_simulations .. "moshine_snouz1.zip",
  length = 16 * second,
  init = [[
    game.simulation.camera_zoom = 1
    game.simulation.camera_player = "snouz"
    game.simulation.camera_position = {28.5,8.75}
    game.simulation.camera_alt_info = false
    game.simulation.hide_cursor = true
    game.tick_paused = false
  ]],
}

menu_sims.moshine_snouz2_a = { -- compute farm
  checkboard = false,
  game_view_settings = {default_show_value = false, show_shortcut_bar = false, show_quickbar = false, show_tool_bar = false},
  init_update_count = 60,
  save = moshine_simulations .. "moshine_snouz2.zip",
  length = 18 * second,
  init = [[
    game.simulation.camera_zoom = 1
    game.simulation.camera_player = "snouz"
    game.simulation.camera_position = {-66.5,79.75}
    game.simulation.camera_alt_info = false
    game.simulation.hide_cursor = true
    game.tick_paused = false
  ]],
}

menu_sims.moshine_snouz2_b = { --fast train
  checkboard = false,
  game_view_settings = {default_show_value = false, show_shortcut_bar = false, show_quickbar = false, show_tool_bar = false},
  init_update_count = 60,
  save = moshine_simulations .. "moshine_snouz2.zip",
  length = 16 * second,
  init = [[
    game.simulation.camera_zoom = 1
    game.simulation.camera_player = "snouz"
    game.simulation.camera_position = {17.5,56.75}
    game.simulation.camera_alt_info = false
    game.simulation.hide_cursor = true
    game.tick_paused = false
  ]],
}

menu_sims.moshine_snouz3 = { --exploding processors
  checkboard = false,
  game_view_settings = {default_show_value = false, show_shortcut_bar = false, show_quickbar = false, show_tool_bar = false},
  init_update_count = 60,
  save = moshine_simulations .. "moshine_snouz3.zip",
  length = 14 * second,
  init = [[
    game.simulation.camera_zoom = 1
    game.simulation.camera_player = "snouz"
    game.simulation.camera_position = {7.5,2.75}
    game.simulation.camera_alt_info = false
    game.simulation.hide_cursor = true
    game.tick_paused = false
  ]],
}


menu_sims.moshine_snouz4 = { --ai trainers
  checkboard = false,
  game_view_settings = {default_show_value = false, show_shortcut_bar = false, show_quickbar = false, show_tool_bar = false},
  init_update_count = 60,
  save = moshine_simulations .. "moshine_snouz4.zip",
  length = 20 * second,
  init = [[
    game.simulation.camera_zoom = 1
    game.simulation.camera_player = "snouz"
    game.simulation.camera_position = {-44.5,-45.25}
    game.simulation.camera_alt_info = false
    game.simulation.hide_cursor = true
    game.tick_paused = false
  ]],
}


menu_sims.moshine_snouz5 = { --space platform + solar + cosmic scanner
  checkboard = false,
  game_view_settings = {default_show_value = false, show_shortcut_bar = false, show_quickbar = false, show_tool_bar = false},
  init_update_count = 60,
  save = moshine_simulations .. "moshine_snouz5.zip",
  length = 16 * second,
  init = [[
    game.simulation.camera_zoom = 1
    game.simulation.camera_player = "snouz"
    game.simulation.camera_position = {12.5,11.75}
    game.simulation.camera_alt_info = false
    game.simulation.hide_cursor = true
    game.tick_paused = false
  ]],
}


menu_sims.moshine_snouz6 = { --destroying a platform
  checkboard = false,
  game_view_settings = {default_show_value = false, show_shortcut_bar = false, show_quickbar = false, show_tool_bar = false},
  init_update_count = 60,
  save = moshine_simulations .. "moshine_snouz6.zip",
  length = 15 * 2 * second,
  init = [[
    game.simulation.camera_zoom = 1
    game.simulation.camera_player = "snouz"
    game.simulation.camera_position = {12.5,11.75}
    game.simulation.camera_alt_info = false
    game.simulation.hide_cursor = true
    game.tick_paused = false
  ]],
}
-- from the logo: +0 +9.75
