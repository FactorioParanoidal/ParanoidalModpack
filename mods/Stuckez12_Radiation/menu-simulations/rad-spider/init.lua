local radiation_funcs = require("__Stuckez12_Radiation__/scripts/radiation_damage")
local player_management = require("__Stuckez12_Radiation__/scripts/player_management")

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

storage.active_characters = storage.active_characters or {}
storage.player_connections = storage.player_connections or {}
storage.biters = storage.biters or {}
storage.radiation_items = {
  ["nuclear-fuel"] = 10
}
storage.radiation_fluids = {}

script.on_nth_tick(20, radiation_funcs.player_radiation_damage)


local character = game.surfaces[1].create_entity{
    name = "character",
    position = {storage.logo.position.x-6, storage.logo.position.y + 10.5},
    force = "player",
    direction = defines.direction.south,
}

storage.sim_char = character

player_management.add_character_reference(character)

local spider = game.surfaces[1].find_entities_filtered{name="spidertron"}[1]
spider.autopilot_destination = {x=storage.logo.position.x + 12, y=storage.logo.position.y + 11}

storage.timer = game.tick
