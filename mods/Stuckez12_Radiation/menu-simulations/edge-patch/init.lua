local logo = game.surfaces.nauvis.find_entities_filtered{name = "factorio-logo-11tiles", limit = 1}[1]
logo.destructible = false
local center = {logo.position.x, logo.position.y + 9.75}
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

storage.crafted = false
