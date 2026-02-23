local radiation_funcs = require("__Stuckez12_Radiation__/scripts/radiation_damage")
local player_management = require("__Stuckez12_Radiation__/scripts/player_management")

local logo = game.surfaces.nauvis.find_entities_filtered{name = "factorio-logo-11tiles", limit = 1}[1]
logo.destructible = false
local center = {logo.position.x, logo.position.y+9.75}
game.simulation.camera_position = center
game.simulation.camera_zoom = 1
game.tick_paused = false
game.map_settings.steering.moving.force_unit_fuzzy_goto_behavior = true
game.map_settings.steering.moving.radius = 2

storage.timer = game.tick

local player = game.players[1]
player.game_view_settings = {
    show_controller_gui = false,
    show_entity_info = false,
    show_minimap = false,
    show_quickbar = false
}

local bop = function()
    local surface = game.surfaces[1]
    local targets = surface.find_entities_filtered{force = "player", position = {center[1] + 10, center[2]}, radius = 8}
    local count = #targets
    local names = {"big-biter", "behemoth-biter"}
    for k = 1, 50 do
        local spawn_position = {center[1] - 40 + math.random(-25, 5), center[2] + 2 + math.random(-5, 5)}
        local name = names[math.random(#names)]
        local biter = surface.create_entity{name = name, position = spawn_position}
        biter.commandable.set_command
        {
            type = defines.command.compound,
            structure_type = defines.compound_command.return_last,
            commands =
            {
            {type = defines.command.attack, target = targets[math.random(count)]},
            {type = defines.command.attack_area, destination = {center[1] + 20, center[2]}, radius = math.random(5, 10)},
            {type = defines.command.attack_area, destination = {center[1] + 35, center[2]}, radius = math.random(2, 5)},
            {type = defines.command.go_to_location, destination = {center[1] + 120, center[2]}}
            }
        }
        biter.speed = 0.24 + (math.random() / 20)
    end
end

bop()

local surface = game.surfaces["nauvis"]
local character = surface.create_entity{
  name = "character",
  position = {logo.position.x + 21, logo.position.y + 9},
  force = "player",
  direction = defines.direction.west,
}
character.health = 100

storage.active_characters = {}
storage.player_connections = {}
storage.biters = {
    ["big-biter"] = 100,
    ["behemoth-biter"] = 500
}
storage.radiation_items = {}

player_management.add_character_reference(character)

local inv = character.get_inventory(defines.inventory.character_guns)
inv[1].set_stack{name = "submachine-gun"}

local ammo_inv = character.get_inventory(defines.inventory.character_ammo)
ammo_inv[1].set_stack{name = "piercing-rounds-magazine", count = 400}

storage.sim_char = character

script.on_nth_tick(20, radiation_funcs.player_radiation_damage)
