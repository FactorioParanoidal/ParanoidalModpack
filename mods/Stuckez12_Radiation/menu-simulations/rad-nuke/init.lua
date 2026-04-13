local radiation_funcs = require("__Stuckez12_Radiation__/scripts/radiation_damage")
local player_management = require("__Stuckez12_Radiation__/scripts/player_management")

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

local surface = game.surfaces[1]
local character = surface.create_entity{
  name = "character",
  position = {logo.position.x + 51, logo.position.y + 9},
  force = "player",
  direction = defines.direction.west,
}

local bop = function()
    local surface = game.surfaces[1]
    local targets = surface.find_entities_filtered{type = "character"}
    local count = #targets
    local names = {"big-biter"}
    for k = 1, 15 do
        local spawn_position = {center[1] + 90 + math.random(-5, 3), center[2] + 2 + math.random(-3, 3)}
        local name = names[math.random(#names)]
        local biter = surface.create_entity{name = name, position = spawn_position}
        biter.commandable.set_command
        {
            type = defines.command.compound,
            structure_type = defines.compound_command.return_last,
            commands =
            {
                {type = defines.command.attack, target = targets[math.random(count)]},
            }
        }
        biter.speed = 0.22 + (math.random() / 20)
    end
end

bop()

storage.active_characters = {}
storage.player_connections = {}
storage.biters = { ["big-biter"] = 10 }
storage.radiation_items = {}

storage.timer = game.tick

player_management.add_character_reference(character)

local inv = character.get_inventory(defines.inventory.character_guns)
inv[1].set_stack{name = "rocket-launcher"}

local ammo_inv = character.get_inventory(defines.inventory.character_ammo)
ammo_inv[1].set_stack{name = "atomic-bomb", count = 1}

storage.sim_char = character

storage.sim_char.character_running_speed_modifier = 0.6
storage.sim_char.walking_state = {walking = true, direction = defines.direction.west}

script.on_nth_tick(20, radiation_funcs.player_radiation_damage)
