local radiation_funcs = require("__Stuckez12_Radiation__/scripts/radiation_damage")

storage.logo = game.surfaces.nauvis.find_entities_filtered{name = "factorio-logo-11tiles", limit = 1}[1]
storage.logo.destructible = false
local center = {storage.logo.position.x, storage.logo.position.y + 9.75}
game.simulation.camera_position = center
game.simulation.camera_zoom = 1
game.tick_paused = false
game.surfaces.nauvis.daytime = 1
game.map_settings.steering.moving.force_unit_fuzzy_goto_behavior = true
game.map_settings.steering.moving.radius = 3

local player = game.players[1]
player.game_view_settings = {
    show_controller_gui = false,
    show_entity_info = false,
    show_minimap = false,
    show_quickbar = false
}

storage.timer = game.tick

storage.active_characters = storage.active_characters or {}
storage.player_connections = storage.player_connections or {}
storage.biters = storage.biters or {}
storage.radiation_items = {
  ["uranium-ore"] = 10
}

script.on_nth_tick(20, radiation_funcs.player_radiation_damage)

local character = game.surfaces[1].create_entity{
    name = "character",
    position = {storage.logo.position.x, storage.logo.position.y + 10.5},
    force = "player",
}
character.insert{name = "uranium-ore", count = 50}

storage.sim_char = character

character.die()
