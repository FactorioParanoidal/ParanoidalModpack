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

log("X")
log(logo.position.x)
log("Y")
log(logo.position.y)

local player = game.players[1]
player.game_view_settings = {
    show_controller_gui = false,
    show_entity_info = false,
    show_minimap = false,
    show_quickbar = false
}

local surface = game.surfaces["nauvis"]
local character = surface.create_entity{
  name = "character",
  position = {logo.position.x+34, logo.position.y + 11.5},
  force = "player",
  direction = defines.direction.north,
}
character.health = 200

storage.active_characters = storage.active_characters or {}
storage.player_connections = storage.player_connections or {}
storage.biters = storage.biters or {}
storage.radiation_items = {
  ["uranium-ore"] = 10
}

storage.placed_blueprints = {
    ["1"] = false,
    ["2"] = false,
    ["3"] = false,
    ["4"] = false,
    ["5"] = false,
    ["6"] = false,
}

local inv = character.get_inventory(defines.inventory.character_main)
inv.insert{name = "construction-robot", count = 200}
inv.insert{name = "electric-mining-drill", count = 200}
inv.insert{name = "express-transport-belt", count = 200}
inv.insert{name = "express-underground-belt", count = 200}
inv.insert{name = "medium-electric-pole", count = 200}

local armour_inv = character.get_inventory(defines.inventory.character_armor)
armour_inv.insert{name = "radiation-suit", count = 1}

local armor_stack = armour_inv.find_item_stack("radiation-suit")
local grid = armor_stack.grid

grid.put{ name = "radiation-absorption-equipment-mk3", position = {0,0} }
grid.put{ name = "radiation-absorption-equipment-mk3", position = {1,0} }
grid.put{ name = "radiation-absorption-equipment-mk3", position = {2,0} }
grid.put{ name = "radiation-absorption-equipment-mk3", position = {3,0} }
grid.put{ name = "radiation-absorption-equipment-mk3", position = {4,0} }

grid.put{ name = "radiation-reduction-equipment-mk3", position = {0,1} }
grid.put{ name = "radiation-reduction-equipment-mk3", position = {1,1} }
grid.put{ name = "radiation-reduction-equipment-mk3", position = {2,1} }
grid.put{ name = "radiation-reduction-equipment-mk3", position = {3,1} }
grid.put{ name = "radiation-reduction-equipment-mk3", position = {4,1} }

grid.put{ name = "personal-roboport-mk2-equipment", position = {2,2} }


local equipment = grid.put{name = "battery-equipment", position = {2, 4}}





if equipment then
    equipment.energy = equipment.max_energy
end

player_management.add_character_reference(character)

storage.sim_char = character
storage.sim_char.walking_state = {walking = true, direction = defines.direction.west}

script.on_nth_tick(20, radiation_funcs.player_radiation_damage)

local blueprint_string = '0eNql1G1rgzAQB/Dvcq/j8CFq41cZY7R6yEFMQhJHpfjdlzqw22rHYl8ZQ/L/cZ7cBU5yRGNJeWguQK1WDprXCzjq1VFe99RxQGgAJbbeUpsMpEj1SWdJSpgZkOrwDE02vzFA5ckTfkUsL9O7GocT2nCA/R3FwGgXbmt1VUNiIsRLyWAKKx5WgerIhpvLicPM7oQ8XqjihCJeKOIEfhPOxqJzibdH5Yy2Pjmh9BtElqarUf82+IZR3hlj6KHtrQ7PR8q3ZtwjDPxkroGkzOhhw6xWc8COxiFZP6DREre8+oe3EVnvKqP6Txl69A/qOMT3R/C49ogdRBlHZOkOI480sh1GEWnkzwyVcvu/yopn5sijUP7M6FhCw3wlj0NIuM1sBh9o3XKprHLBhShrwYtcVPP8CWST7Eg='
local inventory = game.create_inventory(1)
local stack = inventory[1]
stack.import_stack(blueprint_string)
local function build_blueprint(position)
    stack.build_blueprint{ surface = 'nauvis', position = position, force = 'player', build_mode = defines.build_mode.forced }
end

local tiktok =
{
    [4 * 60] = {logo.position.x-13, logo.position.y-3},
    [4.2 * 60] = {logo.position.x-4, logo.position.y-3},
    [4.4 * 60] = {logo.position.x+5, logo.position.y-3},
    [4.6 * 60] = {logo.position.x+14, logo.position.y-3},

    [5 * 60] = {logo.position.x-13, logo.position.y+4},
    [5.2 * 60] = {logo.position.x-4, logo.position.y+4},
    [5.4 * 60] = {logo.position.x+5, logo.position.y+4},
    [5.6 * 60] = {logo.position.x+14, logo.position.y+4},

    [6 * 60] = {logo.position.x-13, logo.position.y+11},
    [6.2 * 60] = {logo.position.x-4, logo.position.y+11},
    [6.4 * 60] = {logo.position.x+5, logo.position.y+11},
    [6.6 * 60] = {logo.position.x+14, logo.position.y+11},

    [7 * 60] = {logo.position.x-13, logo.position.y+18},
    [7.2 * 60] = {logo.position.x-4, logo.position.y+18},
    [7.4 * 60] = {logo.position.x+5, logo.position.y+18},
    [7.6 * 60] = {logo.position.x+14, logo.position.y+18},
}

local start_tick = game.tick
script.on_event(defines.events.on_tick, function()
    local tick_from_start = game.tick - start_tick
    local position = tiktok[tick_from_start]
    if position then build_blueprint(position) end
end)